import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/drawable.dart';
import 'package:spacetime/edit.dart';
import 'package:spacetime/keyboard_detector.dart';
import 'package:spacetime/menus.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';
import 'package:spacetime/widgets/app_widget.dart';

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

    testWidgets(
      'Toolbar shows undo, redo, delete when hasKeyboard is false and hides them when true',
      (tester) async {
        KeyboardDetector.reset(overrideValue: false);

        final app = AppTester(tester);
        await app.setup();
        await app.initialize();
        await app.loadAndFindScene('initial', SceneData());

        final undoFinder = find.byKey(const ValueKey('toolbar-undo-btn'));
        final redoFinder = find.byKey(const ValueKey('toolbar-redo-btn'));
        final deleteFinder = find.byKey(const ValueKey('toolbar-delete-btn'));

        expect(undoFinder, findsOneWidget);
        expect(redoFinder, findsOneWidget);
        expect(deleteFinder, findsOneWidget);

        // Initially disabled
        expect(tester.widget<IconButton>(undoFinder).onPressed, isNull);
        expect(tester.widget<IconButton>(redoFinder).onPressed, isNull);
        expect(tester.widget<IconButton>(deleteFinder).onPressed, isNull);

        // Access SceneView from AppWidget
        final appWidget = tester.widget<AppWidget>(find.byType(AppWidget));
        final scene = appWidget.sceneViewer;

        // Add a drawable via undoManager
        final d = DrawType.event.make('E1', ReferenceFrame(), 0);
        scene.undoManager.add(
          UndoCallback(
            'Add E1',
            undoCallback: () => scene.data.drawables.remove(d),
            redoCallback: () => scene.data.drawables.add(d),
          ),
        );
        await tester.pump();

        expect(scene.data.drawables.length, 1);
        expect(tester.widget<IconButton>(undoFinder).onPressed, isNotNull);
        expect(tester.widget<IconButton>(redoFinder).onPressed, isNull);

        // Tap Undo
        await tester.tap(undoFinder);
        await tester.pump();
        expect(scene.data.drawables.length, 0);
        expect(tester.widget<IconButton>(undoFinder).onPressed, isNull);
        expect(tester.widget<IconButton>(redoFinder).onPressed, isNotNull);

        // Tap Redo
        await tester.tap(redoFinder);
        await tester.pump();
        expect(scene.data.drawables.length, 1);
        expect(tester.widget<IconButton>(undoFinder).onPressed, isNotNull);
        expect(tester.widget<IconButton>(redoFinder).onPressed, isNull);

        // Select drawable and tap Delete
        scene.selected = d;
        scene.undoManager.rebuildMenu();
        await tester.pump();
        expect(tester.widget<IconButton>(deleteFinder).onPressed, isNotNull);

        await tester.tap(deleteFinder);
        await tester.pump();
        expect(scene.data.drawables.length, 0);
        expect(scene.selected, isNull);
        expect(tester.widget<IconButton>(deleteFinder).onPressed, isNull);

        // Transition hasKeyboard to true via key event
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pumpAndSettle();

        expect(KeyboardDetector.hasKeyboard.value, isTrue);
        expect(undoFinder, findsNothing);
        expect(redoFinder, findsNothing);
        expect(deleteFinder, findsNothing);
      },
    );

    testWidgets('Narrow mode flushes second toolbar left', (tester) async {
      KeyboardDetector.reset(overrideValue: true);

      final app = AppTester(tester);
      await app.setup();
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await app.initialize();
      await app.loadAndFindScene('initial', SceneData());

      final toolChooserTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('Tool-Chooser')),
      );
      expect(toolChooserTopLeft.dx, equals(0.0));
    });
  });
}
