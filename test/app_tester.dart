import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// TODO: look at this issue.
// https://github.com/flutter/flutter/issues/153108
// It recommends setting SharedPreferencesAsyncPlatform.instance
// to be in-memory preferences.
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:spacetime/drive.dart';
import 'package:spacetime/file_holder.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/local_file.dart';
import 'package:spacetime/my_app.dart';
import 'package:spacetime/printer.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/slider.dart';
import 'package:spacetime/sprites.dart';
import 'package:spacetime/upload.dart';

import 'local_file_mock.dart';
import 'helper.dart';
import 'mock_delay.dart';
import 'webview_mock.dart';
import 'test_data.dart';
import 'scene_editor.dart';
import 'app_tester.mocks.dart';

// Generate a MockFileSaverWrapper using the Mockito package
@GenerateMocks([DownloadManager])
class TestFileManager extends FileManager {
  TestFileManager(super.settings);

  // When this is nonempty, the next file that is loaded will use this tag for
  // debug sleeping.
  String tag = "";

  @override
  Future<void> loadFile(FileHolder holder, {bool navigate = true}) async {
    if (tag.isNotEmpty) holder.tag = tag;
    // print("GREEN: loadFile ${holder.tag}");
    tag = "";
    return await super.loadFile(holder, navigate: navigate);
  }
}

class AppTester {
  final tester;
  final Settings settings = Settings();
  MockDownloadManager download_manager = MockDownloadManager();
  final LocalFileMock local_files = LocalFileMock();
  late final TestFileManager manager;
  late final MyApp app;
  late final SceneEditor scene;
  final MockSleep debug_time = MockSleep();
  final MockWebViewDependencies webview = MockWebViewDependencies();
  int recent_count = 0;

  AppTester(this.tester, {String url = "/scene", math.Random? random}) {
    manager = TestFileManager(settings);
    manager.drive_access.isTesting = true;
    manager.isTesting = true;
    app = MyApp(settings, manager, url);
    DebugSleep.instance = debug_time;
    UploadHolder.download_manager = download_manager;

    // Avoid sliders getting stuck too often.
    MySlider.sticky_radius.value = 0.01;

    initSettings();
    initSprites();
    initFileManager();
    scene = SceneEditor(tester, random ?? math.Random());
    manager.recent.addListener(() {
      recent_count++;
    });
    manager.unsaved.addListener(() {
      // print("GREEN: Unsaved is now ${manager.unsaved.value}");
      scene.unsaved_count++;
    });
  }

  // Create the widget and initialize it, but don't actually start the ui
  // initialization.
  Future<void> setup() async {
    setSize(Size(1000, 2000)); // XXX why is this needed?

    // XXX await seedRecent();
    await local_files.initialize();
    await webview.init();
    await app.initialize();
    await tester.pumpWidget(
      MediaQuery(
        // Shrink the text avoid overflow caused by large Ahem font.
        data: const MediaQueryData(
          size: Size(1000, 2000),
          textScaler: TextScaler.linear(0.5),
        ),
        child: app.build(),
      ),
    );
    tagCurrentFile("initial");
    await tester.pumpAndSettle();
    // debugDumpApp(); // Dump the whole widget tree.
  }

  Future<void> teardown() async {
    // XXX webview.teardown();
    // Wait until the address bar has been updated.
    tester.pump(Duration(milliseconds: 200));
  }

  Future<void> finish(String s) {
    return debug_time.finish(s);
  }

  Future<void> finishFile(String s, String? tag) {
    if (tag == null) {
      return debug_time.finish("$s-${manager.current.holder.tag}");
    } else {
      return debug_time.finish("$s-$tag");
    }
  }

  Future<void> finishAll() {
    return debug_time.finishAll();
  }

  void listSleeps() => debug_time.listSleeps();

  void initSettings() {
    PackageInfo.setMockInitialValues(
      appName: "Mock Spacetime",
      packageName: "spacetime.gchouse.org",
      version: "mock version",
      buildNumber: "mock build number",
      buildSignature: "signature",
    );
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  }

  void initSprites() {
    // print("PURPLE: before test, Sprite.initialized = ${Sprite.initialized}");
    Sprite.initialized = false;
  }

  void initFileManager() {}

  // XXX rename to something like expectInitialize.
  Future<void> initialize() async {
    findOneInit(0);
    await finish("settings");
    await tester.pumpAndSettle();
    findOneInit(1);
    await finish("sprites");
    await tester.pumpAndSettle();
    findOneInit(2);
    await finish("file_manager");
    await tester.pumpAndSettle();
    findOneInit(3);
  }

  // These are the splash screen texts during initialization. There should be
  // only one.
  void findOneInit(int exp) {
    // print("BLUE: looking at init $exp");
    // listSleeps();
    final inits = [
      "Settings...",
      "Sprites...",
      "file access...",
      "Loading...",
      "Error Loading",
    ];
    for (int i = 0; i < inits.length; i++) {
      expect(
        find.textContaining(inits[i]),
        i == exp ? findsOneWidget : findsNothing,
      );
    }
  }

  Future<void> loadWithURL(String tag, String url) async {
    manager.tag = tag;
    // XXX Use the router instead.
    // Uri uri = await getUri(url);
    // manager.checkNavigation(uri.queryParameters);
    app.router.go(url);
    // XXX
    await tester.pumpAndSettle();
    findOneInit(3);
    // listSleeps();
  }

  // Open the drawer and tap a menu item.
  Future<void> tapMenu(String menu) async {
    // Open the menu/drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    if (find.text(menu).evaluate().isEmpty) {
      // Find and tap the parent ExpansionTile if collapsed (File, Edit, View).
      for (final parent in ['File', 'Edit', 'View']) {
        if (find.text(parent).evaluate().isNotEmpty) {
          await tester.tap(find.text(parent));
          await tester.pumpAndSettle();
          if (find.text(menu).evaluate().isNotEmpty) break;
        }
      }
    }
    await tester.tap(find.text(menu));
    await tester.pumpAndSettle();
  }

  // Tap a menu item, then a tab or other button.
  Future<void> tapMenus(String menu, String second) async {
    await tapMenu(menu);
    await tester.tap(find.text(second));
    await tester.pumpAndSettle();
  }

  void tagCurrentFile(String tag) {
    manager.current.holder.tag = tag;
  }

  Future<void> loadAndFindCurrentScene(SceneData expected) async {
    String tag = manager.current.holder.tag;
    await loadAndFindScene(tag, expected);
  }

  Future<void> loadAndFindScene(String? tag, SceneData expected) async {
    await loadScene(tag);
    await findScene(expected);
  }

  Future<void> loadScene(String? tag) async {
    // listSleeps();
    await finishFile("reload", tag);
    await tester.pumpAndSettle();
    findOneInit(5);
    scene.view = app.manager.current.scene;
  }

  Future<void> findScene(SceneData expected) async {
    // We should see the velocity and time sliders after all initialization.
    // print("findScene in view = ${manager.current.scene}");
    expect(manager.current.scene!.data.title, expected.title);
    expect(find.textContaining("Time"), findsOneWidget);
    expect(find.textContaining("Velocity"), findsOneWidget);
    expect(find.textContaining(expected.title), findsOneWidget);
    expect(scene.view!.data, SceneDataMatcher(expected));
    // When the scene is active, we expect the file menu/drawer to be closed.
    expect(find.textContaining("Open"), findsNothing);
    expect(find.textContaining("Save"), findsNothing);
  }

  Future<void> findError(String? tag) async {
    await finishFile("reload", tag);
    await tester.pumpAndSettle();
    findOneInit(4);
    // listSleeps();
    expect(find.textContaining("Go back"), findsOneWidget);
    expect(find.textContaining("Open empty scene"), findsOneWidget);
  }

  Future<void> openLocal(String id, SceneData expected) async {
    await tapMenus("Open", "Local Data");
    await tester.tap(find.byKey(ValueKey('open-local-$id')));
    await tester.pumpAndSettle();
    await loadAndFindScene(null, expected);
  }

  Future<void> saveLocal(String id) async {
    await tapMenu("Save");
    await finish("save-local-$id");
    await tester.pumpAndSettle();
  }

  Future<void> openRecent(int index, SceneData expected) async {
    // Open the menu/drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("File"));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MenuItemButton).at(index));
    await tester.pumpAndSettle();
    await loadAndFindScene(null, expected);
  }

  Future<void> openRecentDialog(int index, SceneData expected) async {
    await tapMenu("Open");
    await tester.tap(find.byKey(ValueKey('open-recent-$index')));
    await tester.pumpAndSettle();
    await loadAndFindScene(null, expected);
  }

  Future<void> saveAsLocal(String tag, SceneData expected) async {
    tagCurrentFile(tag);
    await tapMenus("Save As", "Local Data");
    await tester.tap(find.byKey(ValueKey(tag)));
    await tester.pumpAndSettle();
    await finishFile("saveas", tag);
    await tester.pumpAndSettle();
    await findScene(expected);
  }

  Future<void> saveAsDownload(String filename, SceneData expected) async {
    await tapMenu("Save As");
    await tester.tap(find.byKey(const ValueKey('download-filename')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), filename);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    when(
      download_manager.saveFile(name: anyNamed('name'), data: anyNamed('data')),
    ).thenAnswer((_) async => filename);

    await tester.tap(find.byKey(ValueKey("download-button")));
    await tester.pumpAndSettle();
    verify(
      download_manager.saveFile(
        name: filename,
        data: argThat(SceneDataMatcher(expected), named: 'data'),
      ),
    ).called(1); // Verify that saveFile was called exactly once
    await finishFile("saveas", null);
    await tester.pumpAndSettle();
    await findScene(expected);
  }

  Future<void> saveDownload(String filename, SceneData expected) async {
    when(
      download_manager.saveFile(name: anyNamed('name'), data: anyNamed('data')),
    ).thenAnswer((_) async => filename);
    // Open the menu/drawer.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("File"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Save"));
    await tester.pumpAndSettle();
    verify(
      download_manager.saveFile(
        name: filename,
        data: argThat(SceneDataMatcher(expected), named: 'data'),
      ),
    ).called(1); // Verify that saveFile was called exactly once
    await finishFile("save", null);
    await tester.pumpAndSettle();
    await findScene(expected);
  }

  Future<void> openUpload(String filename, SceneData data) async {
    await tapMenu("Open");
    // Expect a call to loadFile.
    String json = TestData.toJson(data);
    when(
      download_manager.loadFile(),
    ).thenAnswer((_) async => Future.value((filename, json)));
    // Start the upload.
    await tester.tap(find.byKey(ValueKey("upload-button")));
    await tester.pumpAndSettle();
    await loadAndFindScene(null, data);
    // Verify that load was called.
    verify(download_manager.loadFile()).called(1);
  }

  Future<void> uploadSkipped() async {
    await tapMenu("Open");
    when(
      download_manager.loadFile(),
    ).thenAnswer((_) async => Future.value(("", "")));
    await tester.tap(find.byKey(ValueKey("upload-button")));
    await tester.pumpAndSettle();
    findOneInit(5);
    // There should have been nothing loaded, and no change to the scene.
    verify(download_manager.loadFile()).called(1);
  }

  Future<void> uploadError() async {
    await tapMenu("Open");
    when(download_manager.loadFile()).thenAnswer(
      (_) async => Future.value(("filename.txt", "{ time: error }")),
    );
    await tester.tap(find.byKey(ValueKey("upload-button")));
    await tester.pumpAndSettle();
    // There should have been nothing loaded, and no change to the scene.
    verify(download_manager.loadFile()).called(1);
    await findError(null);
  }

  // A sample of different file types for seeding the "recent files" list.
  Future<void> seedRecent() async {
    await app.manager.recent.save([
      // ClipboardHolder is not saved in recent list, so we don't expect
      // to find it at the end.
      ClipboardHolder(true)..title = "From the clipboard",
      // This is not the right title. It will be corrected after the
      // file has been loaded.
      JsonHolder(TestData.person.json)..title = "Json person",
      LocalFileHolder("4")..title = "Third local",
      LocalFileHolder("2")..title = "First local",
      DriveHolder("drive_id")..title = "Drive File",
      UploadHolder("uploadfile")..title = "Upload File",
    ]);
  }

  Future<void> expectRecent(List<FileHolder> expectedRecent) async {
    List<FileHolder> recent = await manager.recent.fetchRecent();
    expect(recent, expectedRecent);
  }

  Future<void> expectLocal(List<HolderMock> expectedLocal) {
    return local_files.expectLocal(expectedLocal);
  }

  void setSize(Size size) {
    final dpi = tester.binding.window.devicePixelRatio;
    // print("RED: dpi = ${zzz(dpi)}, size = ${zzz(tester.view.physicalSize)}");
    // XXX Is this really needed? Maybe text size is too big?
    // XXX https://github.com/flutter/flutter/issues/59755 (text size?)
    // XXX see https://stackoverflow.com/questions/62447898/flutter-widget-test-cannot-emulate-different-screen-size-properly/62460566#62460566
    double width = size.width;
    double height = size.height;
    tester.binding.window.physicalSizeTestValue = Size(
      width * dpi,
      height * dpi,
    );
  }
}
