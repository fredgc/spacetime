@Tags(['release_audit'])
library audit_test;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:spacetime/keyboard_detector.dart';
import 'package:spacetime/l10n/l10n_extension.dart';
import 'package:spacetime/my_app.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'webview_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Spacetime Audit',
      packageName: 'org.gchouse.spacetime',
      version: '6.1.4',
      buildNumber: '4',
      buildSignature: 'signature',
    );
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    WebViewPlatform.instance = MockWebViewPlatform();
    LocaleController.currentLocale.value = null;
    KeyboardDetector.hasKeyboard.value = false;
  });

  group('Release Accessibility & Layout Audit', () {
    const supportedLocales = LocaleController.supportedLocales;
    const viewports = <String, Size>{
      'mobile_compact': Size(360, 640),
      'tablet': Size(768, 1024),
      'desktop': Size(1280, 800),
    };

    for (final entry in viewports.entries) {
      final viewportName = entry.key;
      final viewportSize = entry.value;

      testWidgets('Layout stability and control visibility on $viewportName '
          'with 1.5x text scaling', (WidgetTester tester) async {
        tester.view.physicalSize = viewportSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final locale in supportedLocales) {
          LocaleController.currentLocale.value = locale;

          final app = MyApp.fullApp();
          app.manager.driveAccess.isTesting = true;
          await app.initialize();

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: viewportSize,
                textScaler: const TextScaler.linear(1.5),
              ),
              child: app.build(),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason:
                'Layout overflow/error under locale $locale on $viewportName',
          );

          // Verify critical controls remain mounted on all viewports
          expect(
            find.byKey(const ValueKey('Tool-Chooser')),
            findsOneWidget,
            reason: 'Tool-Chooser missing on $viewportName under $locale',
          );
          expect(
            find.byKey(const ValueKey('object_name')),
            findsOneWidget,
            reason: 'object_name missing on $viewportName under $locale',
          );
          expect(
            find.byKey(const ValueKey('DrawType-Chooser')),
            findsOneWidget,
            reason: 'DrawType-Chooser missing on $viewportName under $locale',
          );
          expect(
            find.byKey(const ValueKey('Color-Chooser')),
            findsOneWidget,
            reason: 'Color-Chooser missing on $viewportName under $locale',
          );
          expect(
            find.byKey(const ValueKey('drawer-menu-btn')),
            findsOneWidget,
            reason: 'drawer-menu-btn missing on $viewportName under $locale',
          );
          expect(
            find.byKey(const ValueKey('title_text_view')),
            findsOneWidget,
            reason: 'title_text_view missing on $viewportName under $locale',
          );
          expect(
            find.byKey(const ValueKey('languageSwitcherButton')),
            findsOneWidget,
            reason: 'language button missing on $viewportName under $locale',
          );
          expect(
            find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.slider == true,
            ),
            findsAtLeastNWidgets(2),
            reason: 'Sliders missing on $viewportName under $locale',
          );
        }
      });
    }

    testWidgets(
      'Drawer and file dialog layout on mobile_compact with 1.5x text scale',
      (WidgetTester tester) async {
        const viewportSize = Size(360, 640);
        tester.view.physicalSize = viewportSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final app = MyApp.fullApp();
        app.manager.driveAccess.isTesting = true;
        await app.initialize();

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: viewportSize,
              textScaler: TextScaler.linear(1.5),
            ),
            child: app.build(),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Open drawer and verify items
        await tester.tap(find.byKey(const ValueKey('drawer-menu-btn')));
        await tester.pumpAndSettle();
        expect(find.byType(Drawer), findsOneWidget);
        expect(tester.takeException(), isNull);

        expect(find.text('File'), findsOneWidget);
        expect(find.text('Tutorials'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('View'), findsOneWidget);

        // 2. Open File menu in drawer and launch Open dialog
        await tester.tap(find.text('File'));
        await tester.pumpAndSettle();
        expect(find.text('Open'), findsOneWidget);

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Verify File Open Dialog with tabs
        expect(find.text('Recent'), findsOneWidget);
        expect(find.text('Local Data'), findsOneWidget);
        expect(find.text('Google Drive'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Switch to Local Data tab
        await tester.tap(find.text('Local Data'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Switch to Google Drive tab
        await tester.tap(find.text('Google Drive'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Close dialog
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Close drawer if still open
        final closeBtn = find.byKey(const ValueKey('closeDrawerButton'));
        if (closeBtn.evaluate().isNotEmpty) {
          await tester.tap(closeBtn);
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'Auxiliary screens layout on mobile_compact with 1.5x text scale',
      (WidgetTester tester) async {
        const viewportSize = Size(360, 640);
        tester.view.physicalSize = viewportSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final route in ['/settings', '/about', '/help']) {
          final app = MyApp.fullApp(url: route);
          app.manager.driveAccess.isTesting = true;
          await app.initialize();

          await tester.pumpWidget(
            MediaQuery(
              data: const MediaQueryData(
                size: viewportSize,
                textScaler: TextScaler.linear(1.5),
              ),
              child: app.build(),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason: 'Layout overflow/error on route $route on mobile_compact',
          );
        }
      },
    );

    testWidgets('Interactive elements satisfy accessibility guidelines', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final SemanticsHandle handle = tester.ensureSemantics();

      final app = MyApp.fullApp();
      app.manager.driveAccess.isTesting = true;
      await app.initialize();

      await tester.pumpWidget(app.build());
      await tester.pumpAndSettle();

      // Verify interactive widgets have labels for screen readers
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });
}
