import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/printer.dart';
import 'package:spacetime/scene.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:spacetime/settings.dart';

import 'app_tester.dart';

void main() {
  testWidgets('settings', (tester) async {
    final app = AppTester(tester, url: "/settings");

    SettingsStatus heardStatus = SettingsStatus.NotInitialized;
    StreamSubscription listener = app.settings.statusStream().listen((status) {
      heardStatus = status;
    });
    await app.setup();
    expect(find.text("Initiaizing Settings..."), findsOneWidget);
    expect(heardStatus, SettingsStatus.NotInitialized);
    await tester.pumpAndSettle();
    expect(heardStatus, SettingsStatus.NotInitialized);
    await app.finish("settings");
    await tester.pumpAndSettle();
    expect(heardStatus, SettingsStatus.Initialized);
    expect(find.text("Initiaizing Settings..."), findsNothing);
    expect(find.textContaining("Theme Brightness:"), findsOneWidget);
    expect(find.textContaining("Sticky delay:"), findsOneWidget);
    expect(find.textContaining("Sticky radius:"), findsOneWidget);
    expect(find.textContaining("Dot Size:"), findsOneWidget);
    await app.teardown();
  });

  testWidgets('theme swap updates object color palette', (tester) async {
    final app = AppTester(tester, url: "/settings");
    await app.setup();
    await app.finish("settings");
    await tester.pumpAndSettle();

    // Verify initial light theme background uses dark object colors for contrast.
    expect(SceneView.color_list.value.first, Colors.black);

    // Switch theme to dark.
    app.settings.theme.theme_mode = ThemeMode.dark;
    app.settings.theme.updateAndCallback();
    await tester.pumpAndSettle();

    // Dark theme background swaps palette to light object colors.
    expect(SceneView.color_list.value.first, Colors.white);

    // Switch theme back to light.
    app.settings.theme.theme_mode = ThemeMode.light;
    app.settings.theme.updateAndCallback();
    await tester.pumpAndSettle();

    expect(SceneView.color_list.value.first, Colors.black);

    await app.teardown();
  });

  testWidgets('SavableInt and gridlines/line_width settings', (tester) async {
    final app = AppTester(tester, url: "/settings");
    await app.setup();
    await app.finish("settings");
    await tester.pumpAndSettle();

    expect(find.textContaining("Show Gridlines:"), findsOneWidget);
    expect(find.textContaining("Line Width:"), findsOneWidget);

    SavableInt savableInt = SavableInt("test_int", "Test Int", 42);
    expect(savableInt.value, 42);

    expect(SceneView.show_gridlines.value, false);
    expect(SceneView.line_width.value, 1.5);

    SceneView.show_gridlines.value = true;
    SceneView.line_width.value = 2.5;

    expect(SceneView.show_gridlines.value, true);
    expect(SceneView.line_width.value, 2.5);

    await app.teardown();
  });

  testWidgets(
    'enable_debug gates debug_only settings and SavableBoolGroup works',
    (tester) async {
      final app = AppTester(tester, url: "/settings");
      await app.setup();
      await app.finish("settings");
      await tester.pumpAndSettle();

      // Initially enable_debug is false so debug_only options (like Log settings and Turn All On) are hidden
      expect(Settings.enable_debug.value, false);
      expect(find.textContaining("Log errors"), findsNothing);
      expect(find.text("Turn All On"), findsNothing);

      // Turn on enable_debug in Settings
      Settings.enable_debug.value = true;
      // Trigger rebuild of settings screen
      app.settings.notify();
      await tester.pumpAndSettle();

      // Now debug options and Turn All On / Turn All Off buttons are visible
      expect(find.textContaining("Log errors"), findsOneWidget);
      expect(find.text("Turn All On"), findsOneWidget);
      expect(find.text("Turn All Off"), findsOneWidget);

      // Tap Turn All On button
      await tester.tap(find.text("Turn All On"));
      await tester.pumpAndSettle();

      for (var savable in Log.group_active) {
        expect(savable.value, true);
      }

      // Tap Turn All Off button
      await tester.tap(find.text("Turn All Off"));
      await tester.pumpAndSettle();

      for (var savable in Log.group_active) {
        expect(savable.value, false);
      }

      // Reset enable_debug
      Settings.enable_debug.value = false;

      await app.teardown();
    },
  );

  testWidgets('settings labels and input fields are packaged in rows', (
    tester,
  ) async {
    final app = AppTester(tester, url: "/settings");
    await app.setup();
    await app.finish("settings");
    await tester.pumpAndSettle();

    // Verify Dot Size label and TextField are in the same Row with MainAxisSize.min
    final dotSizeLabelFinder = find.textContaining("Dot Size:");
    expect(dotSizeLabelFinder, findsOneWidget);
    final dotSizeRowFinder = find
        .ancestor(of: dotSizeLabelFinder, matching: find.byType(Row))
        .first;
    expect(dotSizeRowFinder, findsOneWidget);
    final Row dotSizeRow = tester.widget(dotSizeRowFinder);
    expect(dotSizeRow.mainAxisSize, MainAxisSize.min);
    expect(
      find.descendant(of: dotSizeRowFinder, matching: find.byType(TextField)),
      findsOneWidget,
    );

    // Verify Show Gridlines label and Checkbox are in the same Row with MainAxisSize.min
    final gridlinesLabelFinder = find.textContaining("Show Gridlines:");
    expect(gridlinesLabelFinder, findsOneWidget);
    final gridlinesRowFinder = find
        .ancestor(of: gridlinesLabelFinder, matching: find.byType(Row))
        .first;
    expect(gridlinesRowFinder, findsOneWidget);
    final Row gridlinesRow = tester.widget(gridlinesRowFinder);
    expect(gridlinesRow.mainAxisSize, MainAxisSize.min);
    expect(
      find.descendant(of: gridlinesRowFinder, matching: find.byType(Checkbox)),
      findsOneWidget,
    );

    // Verify Time Slice label and ColorIndicator are in the same Row with MainAxisSize.min
    final timeSliceLabelFinder = find.textContaining("Time Slice:");
    expect(timeSliceLabelFinder, findsOneWidget);
    final timeSliceRowFinder = find
        .ancestor(of: timeSliceLabelFinder, matching: find.byType(Row))
        .first;
    expect(timeSliceRowFinder, findsOneWidget);
    final Row timeSliceRow = tester.widget(timeSliceRowFinder);
    expect(timeSliceRow.mainAxisSize, MainAxisSize.min);
    expect(
      find.descendant(
        of: timeSliceRowFinder,
        matching: find.byType(ColorIndicator),
      ),
      findsOneWidget,
    );

    // Verify Object Colors label and its first ColorIndicator are in the same Row with MainAxisSize.min
    final objectColorsLabelFinder = find.textContaining("Object Colors:");
    expect(objectColorsLabelFinder, findsOneWidget);
    final objectColorsRowFinder = find
        .ancestor(of: objectColorsLabelFinder, matching: find.byType(Row))
        .first;
    expect(objectColorsRowFinder, findsOneWidget);
    final Row objectColorsRow = tester.widget(objectColorsRowFinder);
    expect(objectColorsRow.mainAxisSize, MainAxisSize.min);
    expect(
      find.descendant(
        of: objectColorsRowFinder,
        matching: find.byType(ColorIndicator),
      ),
      findsOneWidget,
    );

    await app.teardown();
  });
}
