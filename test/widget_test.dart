import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:spacetime/my_app.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/widgets/json_syntax_dialog.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Mock Spacetime',
      packageName: 'spacetime.gchouse.org',
      version: 'mock version',
      buildNumber: 'mock build number',
      buildSignature: 'signature',
    );
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    final app = MyApp.fullApp();
    app.manager.driveAccess.isTesting = true;
    await app.initialize();
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Help menu displays dynamic fullVersion and Developer Docs under kDebugEnabled',
    (WidgetTester tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Mock Spacetime',
        packageName: 'spacetime.gchouse.org',
        version: '6.0.4',
        buildNumber: '1',
        buildSignature: 'sig',
      );
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();

      final app = MyApp.fullApp();
      app.manager.driveAccess.isTesting = true;
      await app.initialize();
      await tester.pumpWidget(app.build());
      await tester.pumpAndSettle();

      // Open Help Menu
      final helpBtn = find.byIcon(Icons.help);
      expect(helpBtn, findsOneWidget);
      await tester.tap(helpBtn);
      await tester.pumpAndSettle();

      // Confirm dynamic fullVersion is rendered, NOT a stale hardcoded string
      expect(find.text('About Spacetime v6.0.4+1'), findsOneWidget);
      expect(find.text('Help & User Guides'), findsOneWidget);

      // Initially enableDebug is false, so Developer Docs is not visible
      expect(find.text('Developer Docs'), findsNothing);

      // Dismiss menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Enable debug mode
      Settings.enableDebug.value = true;
      await tester.tap(helpBtn);
      await tester.pumpAndSettle();

      if (Settings.kDebugEnabled && Settings.debugEnabled) {
        expect(find.text('Developer Docs'), findsOneWidget);
      }

      // Reset enableDebug
      Settings.enableDebug.value = false;
    },
  );

  testWidgets(
    'JsonSyntaxEditorDialog shows syntax error banner on invalid JSON and loads valid JSON',
    (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final app = MyApp.fullApp();
      app.manager.driveAccess.isTesting = true;
      await app.initialize();

      bool? dialogResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await showDialog<bool>(
                    context: context,
                    builder: (c) => JsonSyntaxEditorDialog(
                      fileManager: app.manager,
                      initialJson: '{ bad json syntax }',
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Validate & Load on invalid JSON
      final validateBtn = find.byKey(
        const ValueKey('validate_and_load_button'),
      );
      expect(validateBtn, findsOneWidget);
      await tester.tap(validateBtn);
      await tester.pumpAndSettle();

      // Verify error banner is visible
      expect(find.textContaining('Syntax Error:'), findsOneWidget);
      expect(dialogResult, isNull);

      // Enter valid JSON into the editor
      const validJson =
          '{"version": "2.0.0", "title": "Corrected", "drawables": []}';
      await tester.enterText(find.byType(TextField), validJson);
      await tester.pumpAndSettle();

      // Validate & Load again
      await tester.tap(validateBtn);
      await tester.pumpAndSettle();

      // Dialog should close and return true
      expect(dialogResult, isTrue);
      expect(find.byType(JsonSyntaxEditorDialog), findsNothing);
      expect(app.manager.current.scene?.data.title, 'Corrected');
    },
  );
}
