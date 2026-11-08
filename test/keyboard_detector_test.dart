import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/keyboard_detector.dart';
import 'package:spacetime/menus.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';

import 'app_tester.dart';

void main() {
  tearDown(() {
    KeyboardDetector.reset();
  });

  group('KeyboardDetector unit tests', () {
    test('hasKeyboard can be manually overridden and reset', () {
      KeyboardDetector.reset(overrideValue: false);
      expect(KeyboardDetector.hasKeyboard.value, isFalse);

      KeyboardDetector.reset(overrideValue: true);
      expect(KeyboardDetector.hasKeyboard.value, isTrue);
    });

    test('onKeyEvent transitions hasKeyboard from false to true', () {
      KeyboardDetector.reset(overrideValue: false);
      expect(KeyboardDetector.hasKeyboard.value, isFalse);

      KeyboardDetector.onKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyA,
          logicalKey: LogicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
      );
      expect(KeyboardDetector.hasKeyboard.value, isTrue);
    });

    testWidgets('MyMenuItem hides shortcut when hasKeyboard is false', (
      tester,
    ) async {
      KeyboardDetector.reset(overrideValue: false);

      final item = MyMenuItem(
        'Save',
        key: LogicalKeyboardKey.keyS,
        callback: () {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) => item.makeMenuButton(context)),
          ),
        ),
      );

      final button = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
      expect(button.shortcut, isNull);

      // Transition to true and rebuild
      KeyboardDetector.hasKeyboard.value = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) => item.makeMenuButton(context)),
          ),
        ),
      );

      final buttonWithShortcut = tester.widget<MenuItemButton>(
        find.byType(MenuItemButton),
      );
      expect(buttonWithShortcut.shortcut, isNotNull);
    });

    testWidgets('RadioItem hides shortcut when hasKeyboard is false', (
      tester,
    ) async {
      KeyboardDetector.reset(overrideValue: false);

      final group = ValueNotifier<LightSpeed>(LightSpeed.lorentz);
      final radioItem = RadioItem<LightSpeed>('Ether', LightSpeed.ether, group);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => radioItem.makeMenuButton(context),
            ),
          ),
        ),
      );

      final radioBtn = tester.widget<RadioMenuButton<LightSpeed>>(
        find.byType(RadioMenuButton<LightSpeed>),
      );
      expect(radioBtn.shortcut, isNull);

      // Transition to true
      KeyboardDetector.hasKeyboard.value = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => radioItem.makeMenuButton(context),
            ),
          ),
        ),
      );

      final radioBtnWithShortcut = tester.widget<RadioMenuButton<LightSpeed>>(
        find.byType(RadioMenuButton<LightSpeed>),
      );
      expect(radioBtnWithShortcut.shortcut, isNotNull);
    });
  });

  group('KeyboardDetector in AppWidget', () {
    testWidgets(
      'Key press transitions hasKeyboard and redraws menu shortcuts',
      (tester) async {
        KeyboardDetector.reset(overrideValue: false);

        final app = AppTester(tester);
        await app.setup();
        await app.initialize();
        await app.loadAndFindScene('initial', SceneData());

        // Open drawer to inspect File menu items
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // Find 'Cut' button
        final cutFinder = find.widgetWithText(MenuItemButton, 'Cut');
        expect(cutFinder, findsOneWidget);

        final cutButtonBefore = tester.widget<MenuItemButton>(cutFinder);
        expect(cutButtonBefore.shortcut, isNull);

        // Send a key event
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        expect(KeyboardDetector.hasKeyboard.value, isTrue);

        final cutButtonAfter = tester.widget<MenuItemButton>(cutFinder);
        expect(cutButtonAfter.shortcut, isNotNull);
      },
    );
  });
}
