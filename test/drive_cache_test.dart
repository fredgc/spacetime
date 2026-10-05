import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:spacetime/drive.dart';
import 'package:spacetime/file_holder.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/recent_file.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/sprites.dart';
import 'package:spacetime/widget.dart';

class MockDriveAccess extends MyDriveAccess {
  final List<drive.File> mockFiles;
  MockDriveAccess(this.mockFiles);

  @override
  Stream<List<drive.File>> listFiles({String specialQuery = ""}) async* {
    yield mockFiles;
  }
}

class PromptMockDriveAccess extends MyDriveAccess {
  bool getAuthorizationCalled = false;
  bool authorizationResult = false;

  @override
  Future<bool> getAuthorization(BuildContext? context) async {
    getAuthorizationCalled = true;
    if (authorizationResult) {
      setAuthorized(true);
    }
    return authorizationResult;
  }

  @override
  Future<bool> checkAuthorization() async {
    return status == DriveAccessStatus.Authorized;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('TokenStorage', () {
    test('saveCredentials and getTokens', () async {
      final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'test_access_token', expiry),
        'test_refresh_token',
        [MyDriveAccess.scopes.first],
        idToken: 'test_id_token',
      );

      await TokenStorage.saveCredentials(credentials);
      final tokens = await TokenStorage.getTokens();

      expect(tokens, isNotNull);
      expect(tokens!['access_token'], equals('test_access_token'));
      expect(tokens['refresh_token'], equals('test_refresh_token'));
      expect(tokens['id_token'], equals('test_id_token'));
      expect(tokens['expiry_date'], equals(expiry.toIso8601String()));
    });

    test('clearTokens', () async {
      final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'test_access_token', expiry),
        'test_refresh_token',
        [MyDriveAccess.scopes.first],
      );

      await TokenStorage.saveCredentials(credentials);
      expect(await TokenStorage.getTokens(), isNotNull);

      await TokenStorage.clearTokens();
      expect(await TokenStorage.getTokens(), isNull);
      expect(await TokenStorage.getUserInfo(), isNull);
    });

    test('clearCredentials keeps user info', () async {
      final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'test_access_token', expiry),
        'test_refresh_token',
        [MyDriveAccess.scopes.first],
      );

      await TokenStorage.saveCredentials(credentials);
      await TokenStorage.clearCredentials();
      expect(await TokenStorage.getTokens(), isNull);
    });

    test('saveUserInfo and getUserInfo', () async {
      final access = MyDriveAccess();
      access.isTesting = true;
      await TokenStorage.clearTokens();
      expect(await TokenStorage.getUserInfo(), isNull);
    });
  });

  group('MyDriveAccess getCachedDriveApi', () {
    test('returns null when no tokens stored', () async {
      final access = MyDriveAccess();
      final api = await access.getCachedDriveApi();
      expect(api, isNull);
    });

    test('returns DriveApi when valid non-expired tokens stored', () async {
      final expiry = DateTime.now().toUtc().add(const Duration(minutes: 30));
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'valid_token', expiry),
        null,
        [MyDriveAccess.scopes.first],
      );

      await TokenStorage.saveCredentials(credentials);

      final access = MyDriveAccess();
      final api = await access.getCachedDriveApi();
      expect(api, isNotNull);
    });

    test('returns null when cached token is expired', () async {
      final expiry = DateTime.now().toUtc().subtract(
        const Duration(minutes: 5),
      );
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'expired_token', expiry),
        null,
        [MyDriveAccess.scopes.first],
      );

      await TokenStorage.saveCredentials(credentials);

      final access = MyDriveAccess();
      final api = await access.getCachedDriveApi();
      expect(api, isNull);
    });
  });

  group('DriveTab Widget', () {
    testWidgets('renders top-aligned with checkbox and full-width buttons', (
      tester,
    ) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final settings = Settings();
      final manager = FileManager(settings);
      manager.drive_access.isTesting = true;

      final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'test_token', expiry),
        'refresh_token',
        [MyDriveAccess.scopes.first],
        idToken: 'test_id',
      );
      await TokenStorage.saveCredentials(credentials);
      manager.drive_access.cachedUserInfo = {
        'id': 'user1',
        'email': 'user@example.com',
        'displayName': 'Test User',
      };
      manager.drive_access.setAuthorized(true);

      final recent = RecentFiles();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DriveTab(true, manager, recent))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Load from Drive'), findsOneWidget);

      // Verify Column is top-aligned (MainAxisAlignment.start)
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);
      final Column column = tester.widget(columnFinder);
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.start));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.stretch));

      // Verify wrapped in SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets(
      'file item is full-width button that pops DriveHolder on click',
      (tester) async {
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.empty();
        final settings = Settings();
        final manager = FileManager(settings);
        final testFile = drive.File()
          ..id = 'file-abc-123'
          ..name = 'My Spacetime Diagram';
        final mockAccess = MockDriveAccess([testFile]);
        mockAccess.isTesting = true;
        manager.drive_access = mockAccess;

        final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
        final credentials = auth.AccessCredentials(
          auth.AccessToken('Bearer', 'test_token', expiry),
          'refresh_token',
          [MyDriveAccess.scopes.first],
          idToken: 'test_id',
        );
        await TokenStorage.saveCredentials(credentials);
        mockAccess.cachedUserInfo = {
          'id': 'user1',
          'email': 'user@example.com',
        };
        mockAccess.setAuthorized(true);

        DriveHolder? selectedHolder;
        final recent = RecentFiles();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    selectedHolder = await showDialog<DriveHolder>(
                      context: context,
                      builder: (_) =>
                          Dialog(child: DriveTab(true, manager, recent)),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        final fileButtonFinder = find.byKey(
          const ValueKey('open-drive-file-abc-123'),
        );
        expect(fileButtonFinder, findsOneWidget);

        // Verify the ElevatedButton contains both the icon and text
        expect(
          find.descendant(
            of: fileButtonFinder,
            matching: find.byIcon(Icons.file_open),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: fileButtonFinder,
            matching: find.text('My Spacetime Diagram (file-abc-123)'),
          ),
          findsOneWidget,
        );

        // Tap the full line button and verify it pops with the chosen file
        await tester.tap(fileButtonFinder);
        await tester.pumpAndSettle();

        expect(selectedHolder, isNotNull);
        expect(selectedHolder!.id, equals('file-abc-123'));
        expect(selectedHolder!.title, equals('My Spacetime Diagram'));
      },
    );

    testWidgets('displays owner when file is not owned by the current user', (
      tester,
    ) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final settings = Settings();
      final manager = FileManager(settings);

      final myFile = drive.File()
        ..id = 'my-file-1'
        ..name = 'My Own Diagram'
        ..owners = [
          drive.User()
            ..displayName = 'Test User'
            ..emailAddress = 'user@example.com'
            ..me = true,
        ];

      final sharedFile = drive.File()
        ..id = 'shared-file-2'
        ..name = 'Collaborator Diagram'
        ..owners = [
          drive.User()
            ..displayName = 'Alice Smith'
            ..emailAddress = 'alice@example.com'
            ..me = false,
        ];

      final mockAccess = MockDriveAccess([myFile, sharedFile]);
      mockAccess.isTesting = true;
      manager.drive_access = mockAccess;

      final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'test_token', expiry),
        'refresh_token',
        [MyDriveAccess.scopes.first],
        idToken: 'test_id',
      );
      await TokenStorage.saveCredentials(credentials);
      mockAccess.cachedUserInfo = {
        'id': 'user1',
        'email': 'user@example.com',
        'displayName': 'Test User',
      };
      mockAccess.setAuthorized(true);

      final recent = RecentFiles();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DriveTab(true, manager, recent))),
      );
      await tester.pumpAndSettle();

      // Own file button should not display owner
      final myFileFinder = find.byKey(const ValueKey('open-drive-my-file-1'));
      expect(myFileFinder, findsOneWidget);
      expect(
        find.descendant(
          of: myFileFinder,
          matching: find.textContaining('Owner:'),
        ),
        findsNothing,
      );

      // Shared file button should display owner
      final sharedFileFinder = find.byKey(
        const ValueKey('open-drive-shared-file-2'),
      );
      expect(sharedFileFinder, findsOneWidget);
      expect(
        find.descendant(
          of: sharedFileFinder,
          matching: find.text('Owner: Alice Smith (alice@example.com)'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays last modified date when modifiedTime is present', (
      tester,
    ) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final settings = Settings();
      final manager = FileManager(settings);

      final modifiedTime = DateTime(2026, 10, 4, 14, 5);
      final fileWithDate = drive.File()
        ..id = 'dated-file-1'
        ..name = 'Diagram With Date'
        ..modifiedTime = modifiedTime;

      final fileWithoutDate = drive.File()
        ..id = 'undated-file-2'
        ..name = 'Diagram Without Date';

      final mockAccess = MockDriveAccess([fileWithDate, fileWithoutDate]);
      mockAccess.isTesting = true;
      manager.drive_access = mockAccess;

      final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
      final credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', 'test_token', expiry),
        'refresh_token',
        [MyDriveAccess.scopes.first],
        idToken: 'test_id',
      );
      await TokenStorage.saveCredentials(credentials);
      mockAccess.cachedUserInfo = {'id': 'user1', 'email': 'user@example.com'};
      mockAccess.setAuthorized(true);

      final recent = RecentFiles();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: DriveTab(true, manager, recent))),
      );
      await tester.pumpAndSettle();

      final datedFinder = find.byKey(const ValueKey('open-drive-dated-file-1'));
      expect(datedFinder, findsOneWidget);
      expect(
        find.descendant(
          of: datedFinder,
          matching: find.text('Modified: 2026-10-04 14:05'),
        ),
        findsOneWidget,
      );

      final undatedFinder = find.byKey(
        const ValueKey('open-drive-undated-file-2'),
      );
      expect(undatedFinder, findsOneWidget);
      expect(
        find.descendant(
          of: undatedFinder,
          matching: find.textContaining('Modified:'),
        ),
        findsNothing,
      );
    });
  });

  group('formatFileModifiedTime', () {
    test('formats local DateTime with zero-padding', () {
      final dt = DateTime(2026, 4, 5, 9, 3);
      expect(formatFileModifiedTime(dt), equals('2026-04-05 09:03'));
    });

    test('converts UTC DateTime to local time representation', () {
      final utc = DateTime.utc(2026, 10, 4, 12, 0);
      final local = utc.toLocal();
      final expectedYear = local.year.toString().padLeft(4, '0');
      final expectedMonth = local.month.toString().padLeft(2, '0');
      final expectedDay = local.day.toString().padLeft(2, '0');
      final expectedHour = local.hour.toString().padLeft(2, '0');
      final expectedMinute = local.minute.toString().padLeft(2, '0');
      expect(
        formatFileModifiedTime(utc),
        equals(
          '$expectedYear-$expectedMonth-$expectedDay $expectedHour:$expectedMinute',
        ),
      );
    });
  });

  group('DriveAuthorizeWidget', () {
    testWidgets(
      'renders session expired and sign-in button when user is null',
      (tester) async {
        final access = MyDriveAccess();
        access.isTesting = true;
        access.cachedUserInfo = {'id': 'user-1', 'email': 'fredgc@gchouse.org'};
        access.setAuthorized(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DriveAuthorizeWidget(access, (_) {})),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Session expired for fredgc@gchouse.org'),
          findsOneWidget,
        );
        expect(find.text('REQUEST PERMISSIONS'), findsNothing);
      },
    );
  });

  group('buildDriveQuery', () {
    test('converts empty query to empty string', () {
      expect(buildDriveQuery(''), equals(''));
      expect(buildDriveQuery('   '), equals(''));
    });

    test('converts plain title search to name contains clause', () {
      expect(
        buildDriveQuery('relativity'),
        equals("name contains 'relativity'"),
      );
    });

    test('converts owner:me to me in owners clause', () {
      expect(buildDriveQuery('owner:me'), equals("'me' in owners"));
    });

    test('converts owner:me with search term to combined query', () {
      expect(
        buildDriveQuery('owner:me relativity'),
        equals("'me' in owners and name contains 'relativity'"),
      );
    });

    test('preserves direct drive query syntax', () {
      expect(
        buildDriveQuery("name contains 'demo'"),
        equals("name contains 'demo'"),
      );
    });
  });

  group('DriveHolder and FileManager auth detection and error handling', () {
    test(
      'DriveHolder loadData throws clear auth exception when not authorized',
      () async {
        final settings = Settings();
        final manager = FileManager(settings);
        manager.drive_access.isTesting = true;
        manager.drive_access.setAuthorized(false);

        final holder = DriveHolder('test-file-id');
        expect(
          () => holder.loadData(manager),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains(
                    'Not logged in or permissions not granted',
                  ) &&
                  !e.toString().contains('Could not find file with id'),
            ),
          ),
        );
      },
    );

    testWidgets(
      'FileManager loadFile checks authorization earlier and aborts if user cancels',
      (tester) async {
        final settings = Settings();
        final manager = FileManager(settings);
        final mockAccess = PromptMockDriveAccess();
        mockAccess.isTesting = true;
        mockAccess.setAuthorized(false);
        mockAccess.authorizationResult = false;
        manager.drive_access = mockAccess;

        final initialHolder = FileHolder('');
        manager.current.holder = initialHolder;
        manager.status = LoadingStatus.Loaded;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                manager.setContext('test', context);
                return const Scaffold(body: Text('Loaded Scene'));
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final targetDriveHolder = DriveHolder('test-drive-id');
        await manager.loadFile(targetDriveHolder);
        await tester.pumpAndSettle();

        // getAuthorization was prompted
        expect(mockAccess.getAuthorizationCalled, isTrue);
        // Because user cancelled authorization, manager should not have changed to drive holder
        expect(manager.current.holder, equals(initialHolder));
        expect(manager.status, equals(LoadingStatus.Loaded));
      },
    );

    testWidgets(
      'SplashWidget shows Sign In to Google Drive button when DriveHolder fails with auth error',
      (tester) async {
        final settings = Settings();
        settings.status = SettingsStatus.Initialized;
        Sprite.initialized = true;
        final manager = FileManager(settings);
        manager.isTesting = true;
        manager.drive_access.isTesting = true;
        manager.drive_access.setAuthorized(false);

        manager.current.holder = DriveHolder('test-drive-id');
        manager.status = LoadingStatus.Error;
        manager.exception = Exception(
          'Not logged in or permissions not granted for Google Drive.',
        );

        await tester.pumpWidget(
          MaterialApp(home: SplashWidget(settings, manager)),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('drive_sign_in_button')),
          findsOneWidget,
        );
        expect(find.text('Sign In to Google Drive'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('edit_json_syntax_button')),
          findsNothing,
        );
      },
    );
  });
}
