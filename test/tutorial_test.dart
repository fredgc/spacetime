import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/drawable.dart';
import 'package:spacetime/file_holder.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/script.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/tutorial_widget.dart';
import 'package:spacetime/tutorials.g.dart';
import 'package:spacetime/widget.dart';

void main() {
  group('Tutorial Widget & Controller Flow', () {
    late Settings settings;
    late FileManager fileManager;
    late SceneView scene;

    setUp(() {
      settings = Settings();
      fileManager = FileManager(settings);
      scene = SceneView(fileManager, settings, SceneData());
    });

    testWidgets(
      'TutorialCard renders markdown bold, italic, and lists without raw syntax',
      (WidgetTester tester) async {
        final markdown = '''
# Markdown Tutorial Test

Description here.

## 1. Markdown Step
This has **bold text** and *italic text* and `code text`.

* Item 1
* Item 2

> ok
''';
        final tutorial = Tutorial.fromMarkdown(markdown);
        final controller = TutorialController(scene, tutorial);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TutorialCard(controller: controller, onClose: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify that raw markdown formatting markers are not displayed as literal text
        expect(find.textContaining('**bold text**'), findsNothing);
        expect(find.textContaining('* Item 1'), findsNothing);
        expect(find.textContaining('bold text'), findsOneWidget);
        expect(find.textContaining('Item 1'), findsOneWidget);
      },
    );

    testWidgets(
      'TutorialCard renders TeX math formulas without raw dollar signs',
      (WidgetTester tester) async {
        final markdown = '''
# TeX Tutorial Test

Description here.

## 1. Math Step
Space (\$x\$) is on the horizontal axis and time (\$t\$) is on the vertical axis.
The Lorentz factor is \$\\gamma = 1.25\$.
Display equation:
\$\$\\text{P1} \\rightarrow \\text{P2}\$\$

> ok
''';
        final tutorial = Tutorial.fromMarkdown(markdown);
        final controller = TutorialController(scene, tutorial);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TutorialCard(controller: controller, onClose: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify that raw dollar signs are not displayed as literal text
        expect(find.textContaining(r'$x$'), findsNothing);
        expect(find.textContaining(r'($x$)'), findsNothing);
        expect(find.textContaining(r'$t$'), findsNothing);
        expect(find.textContaining(r'$\gamma = 1.25$'), findsNothing);
        expect(find.textContaining(r'$$\text{P1}'), findsNothing);

        // Verify that Math widgets are rendered
        final mathFinder = find.byType(Math);
        expect(mathFinder, findsAtLeastNWidgets(3));
      },
    );

    testWidgets('TutorialCard renders all relativity math constructs cleanly', (
      WidgetTester tester,
    ) async {
      final markdown = '''
# Relativity Math Test

## 1. Math Step
* Variables: Space (\$x\$) and time (\$t\$)
* Slope: \$\\pm 1\$
* Lorentz factor: \$\\gamma = 1 / \\sqrt{1 - v^2}\$
* Degree: \$45^\\circ\$
* Rel velocity: (\$v_{\\text{rel}} \\approx -0.88\$)
* Bracketed display:
\\[ E = mc^2 \\]
* Inline paren math: \\( c = 1 \\)

> ok
''';
      final tutorial = Tutorial.fromMarkdown(markdown);
      final controller = TutorialController(scene, tutorial);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(controller: controller, onClose: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining(r'$x$'), findsNothing);
      expect(find.textContaining(r'$t$'), findsNothing);
      expect(find.textContaining(r'$\pm 1$'), findsNothing);
      expect(find.textContaining(r'$$'), findsNothing);
      expect(find.byType(Math), findsAtLeastNWidgets(6));
      controller.dispose();
    });

    testWidgets(
      'TutorialCard displays step title, body, and advances on Continue',
      (WidgetTester tester) async {
        final markdown = '''
# Speed of Light Test

Introductory description.

## Step 1: Start
Click continue to begin the lesson.

> ok

## Step 2: Set Velocity
Move velocity to 0.25.

> v = 0.25
''';

        final tutorial = Tutorial.fromMarkdown(markdown);
        final controller = TutorialController(scene, tutorial);
        bool closed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TutorialCard(
                controller: controller,
                onClose: () => closed = true,
              ),
            ),
          ),
        );

        // Verify Step 1 is displayed
        expect(find.text("Step 1 of 2"), findsOneWidget);
        expect(find.text("Start"), findsOneWidget);
        expect(
          find.text("Click continue to begin the lesson."),
          findsOneWidget,
        );
        expect(find.text("Click Continue to proceed"), findsOneWidget);

        // Tap continue button
        await tester.tap(find.byKey(const ValueKey('tutorial-next-btn')));
        await tester.pump();

        // Now on Step 2
        expect(find.text("Step 2 of 2"), findsOneWidget);
        expect(find.text("Set Velocity"), findsOneWidget);
        expect(find.text("Move velocity to 0.25."), findsOneWidget);
        expect(find.textContaining("Target: v = 0.25"), findsOneWidget);

        // Continue button should be DISABLED before criterion is met
        final nextBtnBefore = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('tutorial-next-btn')),
        );
        expect(nextBtnBefore.onPressed, isNull);

        // "Do it for me" button should be available
        expect(
          find.byKey(const ValueKey('tutorial-do-it-for-me-btn')),
          findsOneWidget,
        );

        // Test minimize and restore
        await tester.tap(find.byTooltip("Minimize"));
        await tester.pump();
        expect(find.text("Step 2/2"), findsOneWidget);
        expect(find.text("Set Velocity"), findsNothing);

        // Restore
        await tester.tap(find.text("Step 2/2"));
        await tester.pump();
        expect(find.text("Set Velocity"), findsOneWidget);

        // Tap "Do it for me"
        await tester.tap(
          find.byKey(const ValueKey('tutorial-do-it-for-me-btn')),
        );
        await tester.pump();
        expect(scene.velocity.value, equals(0.25));

        // Now Continue button is ENABLED
        final nextBtnAfter = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('tutorial-next-btn')),
        );
        expect(nextBtnAfter.onPressed, isNotNull);

        // Tap finish/continue
        await tester.tap(find.byKey(const ValueKey('tutorial-next-btn')));
        await tester.pump();

        // Completion screen
        expect(find.text("Tutorial Completed!"), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('tutorial-finish-btn')));
        await tester.pump();
        expect(closed, isTrue);

        controller.dispose();
      },
    );

    testWidgets('Tutorial completes and shows finish card', (
      WidgetTester tester,
    ) async {
      final markdown = '''
# Single Step Tutorial
## Only Step
Done immediately.
> ok
''';

      final tutorial = Tutorial.fromMarkdown(markdown);
      final controller = TutorialController(scene, tutorial);
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialCard(
              controller: controller,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      // Advance past the only step
      await tester.tap(find.byKey(const ValueKey('tutorial-next-btn')));
      await tester.pump();

      // Completion screen
      expect(find.text("Tutorial Completed!"), findsOneWidget);
      expect(find.byKey(const ValueKey('tutorial-finish-btn')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('tutorial-finish-btn')));
      await tester.pump();
      expect(closed, isTrue);

      controller.dispose();
    });

    test('AssetHolder creates correct title and type', () {
      final holder = AssetHolder('assets/tutorials/02_speed_of_light.md');
      expect(holder.type, equals('asset'));
      expect(holder.kind, equals(FileKind.tutorial));
      expect(holder.title, equals('02_speed_of_light'));
      expect(holder.userDescription(), equals('02_speed_of_light (tutorial)'));
    });

    testWidgets('AppWidget drawer contains File, Tutorials, Edit, and View', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(AppWidget(scene, settings, fileManager));
      await tester.pumpAndSettle();

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Verify the top-level section titles exist in drawer and are aligned
      expect(find.text("File"), findsOneWidget);
      expect(find.text("Tutorials"), findsOneWidget);
      expect(find.text("Edit"), findsOneWidget);
      expect(find.text("View"), findsOneWidget);

      final fileDx = tester.getTopLeft(find.text("File")).dx;
      final editDx = tester.getTopLeft(find.text("Edit")).dx;
      final viewDx = tester.getTopLeft(find.text("View")).dx;
      expect(viewDx, equals(fileDx));
      expect(viewDx, equals(editDx));
    });

    test(
      'getBuiltInTutorials toggles dev tutorials based on includeDev flag',
      () {
        final prodOnly = getBuiltInTutorials(includeDev: false);
        expect(prodOnly.length, equals(6));
        expect(
          prodOnly.any((t) => t.assetPath.contains('assets/dev/tutorials')),
          isFalse,
        );
        expect(
          prodOnly.any(
            (t) =>
                t.assetPath.contains('assets/tutorials/02_speed_of_light.md'),
          ),
          isTrue,
        );

        final withDev = getBuiltInTutorials(includeDev: true);
        expect(
          withDev.any(
            (t) => t.assetPath.contains('assets/dev/tutorials/debug_test.md'),
          ),
          isTrue,
        );
        expect(
          withDev.any(
            (t) =>
                t.assetPath.contains('assets/tutorials/02_speed_of_light.md'),
          ),
          isTrue,
        );
        expect(withDev.length, greaterThan(prodOnly.length));
      },
    );

    test(
      'FileManager builtInTutorials and makeTutorialMenu includes tutorials',
      () {
        final menu = fileManager.makeTutorialMenu();
        expect(menu.title, equals("Tutorials"));
        expect(menu.items.length, equals(fileManager.builtInTutorials.length));
        expect(
          menu.items.any(
            (item) => item.name == "2. Constant Speed of Light & Simultaneity",
          ),
          isTrue,
        );
        if (Settings.kDebugEnabled) {
          expect(
            menu.items.any(
              (item) => item.name == "Debug Tutorial Feature Test",
            ),
            isTrue,
          );
        }
      },
    );

    test(
      'All 6 built-in tutorials parse and complete every step via doItForMe',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        for (final holder in kBuiltInTutorials) {
          final md = await holder.loadData(fileManager);
          final tutorial = Tutorial.fromMarkdown(md);
          expect(
            tutorial.steps.length,
            greaterThanOrEqualTo(5),
            reason: '${holder.assetPath} should have at least 5 steps',
          );

          final controller = TutorialController(scene, tutorial);
          int guard = 0;
          while (!controller.isCompleted && guard < 50) {
            if (!controller.isContinueEnabled && controller.canDoItForMe) {
              controller.doItForMe();
            }
            expect(
              controller.isContinueEnabled,
              isTrue,
              reason:
                  'Step ${controller.currentStepIndex + 1} (${controller.currentStep?.title}) in ${holder.assetPath} should be satisfiable',
            );
            controller.nextStep();
            guard++;
          }
          expect(
            controller.isCompleted,
            isTrue,
            reason: '${holder.assetPath} should reach completion',
          );
          controller.dispose();
        }
      },
    );

    testWidgets(
      'AppWidget highlights tool.mode, tool.type, and canvas.point during add = cone directive, and canvas.object during select directive',
      (WidgetTester tester) async {
        fileManager.current.scene = scene;
        await tester.pumpWidget(AppWidget(scene, settings, fileManager));
        await tester.pumpAndSettle();

        final tutorial = Tutorial.fromMarkdown('''
# Highlight Test
## Add Cone
Place a light cone at (0.5, 0.2).
> add = cone(x=0.5, t=0.2)
## Select Cone
Select the light cone.
> select = L1
''');
        fileManager.startTutorial(tutorial);
        final activeScene = fileManager.current.scene!;
        await tester.pumpWidget(AppWidget(activeScene, settings, fileManager));
        await tester.pump();

        // Initially tool is Select, so highlight-tool.mode is active
        expect(
          find.byKey(const ValueKey('highlight-tool.mode')),
          findsOneWidget,
        );

        // Switch tool to Add -> highlight-tool.type becomes active
        activeScene.currentTool.value = Tool.add;
        await tester.pump();
        expect(
          find.byKey(const ValueKey('highlight-tool.type')),
          findsOneWidget,
        );

        // Switch type to Light Cone -> highlight-canvas.point becomes active (not canvas.main)
        activeScene.currentType.value = DrawType.cone;
        await tester.pump();
        expect(
          find.byKey(const ValueKey('highlight-canvas.point')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('highlight-canvas.main')),
          findsNothing,
        );

        // Tap Do it for me -> adds the cone at (0.5, 0.2) and satisfies step
        await tester.tap(
          find.byKey(const ValueKey('tutorial-do-it-for-me-btn')),
        );
        await tester.pump();
        expect(
          fileManager.activeTutorial.value!.isCurrentStepSatisfied,
          isTrue,
        );
        expect(activeScene.data.drawables.last.pt.x, closeTo(0.5, 0.01));
        expect(activeScene.data.drawables.last.pt.t, closeTo(0.2, 0.01));
        // Once satisfied, highlight switches to tutorial.continue
        expect(
          find.byKey(const ValueKey('highlight-tutorial.continue')),
          findsOneWidget,
        );

        // Advance to Step 2 (select = L1)
        await tester.tap(find.byKey(const ValueKey('tutorial-next-btn')));
        await tester.pump();

        // Switch tool to Select -> highlight-canvas.object is active (not canvas.main)
        activeScene.currentTool.value = Tool.select;
        await tester.pump();
        expect(
          find.byKey(const ValueKey('highlight-canvas.object')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('highlight-canvas.main')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'mode = ether highlights hamburger button, scrolls drawer to View even when other sections are expanded, and highlights Use Ether',
      (WidgetTester tester) async {
        fileManager.current.scene = scene;

        final tutorial = Tutorial.fromMarkdown('''
# Mode Switch Test
## Switch to Ether
Change mode from Lorentz to Ether.
> mode = ether
''');
        fileManager.startTutorial(tutorial);
        final activeScene = fileManager.current.scene!;
        final appWidget = AppWidget(activeScene, settings, fileManager);
        // Expand File, Tutorials, and Edit in advance to push View down
        appWidget.fileMenu.isExpanded = true;
        appWidget.tutorialMenu.isExpanded = true;
        appWidget.editMenu.isExpanded = true;

        await tester.pumpWidget(appWidget);
        await tester.pump();

        // 1. Hamburger menu button is highlighted while drawer is closed
        expect(
          find.byKey(const ValueKey('highlight-menu.light_speed')),
          findsOneWidget,
        );

        // 2. Tap hamburger button to open drawer
        await tester.tap(find.byKey(const ValueKey('drawer-menu-btn')));
        await tester.pumpAndSettle();

        // 3. View header in drawer is highlighted and scrolled into view
        expect(
          find.byKey(const ValueKey('highlight-menu.light_speed.view')),
          findsOneWidget,
        );

        // 4. Tap View to expand it
        await tester.tap(find.text("View"));
        await tester.pumpAndSettle();

        // 5. Now "Use Ether" radio option is highlighted
        expect(
          find.byKey(const ValueKey('highlight-menu.light_speed.Use Ether')),
          findsOneWidget,
        );

        // 6. Tap "Use Ether" -> sets light_speed to ether, closes drawer, and satisfies step
        await tester.tap(find.text("Use Ether"));
        await tester.pumpAndSettle();

        expect(
          fileManager.activeTutorial.value!.isCurrentStepSatisfied,
          isTrue,
        );
      },
    );

    testWidgets(
      'TutorialHighlight animates between normal (0.0) and highlighted (1.0)',
      (WidgetTester tester) async {
        TutorialHighlight.forceAnimationInTests = true;
        addTearDown(() => TutorialHighlight.forceAnimationInTests = null);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TutorialHighlight(
                highlightId: 'test.btn',
                activeHighlightId: 'test.btn',
                child: Text("Target"),
              ),
            ),
          ),
        );

        BoxDecoration getDecoration() {
          final box = tester.widget<DecoratedBox>(
            find.byKey(const ValueKey('highlight-test.btn')),
          );
          return box.decoration as BoxDecoration;
        }

        // At t = 0ms, pulse starts at 0.0 (transparent border)
        final initialAlpha = getDecoration().border!.top.color.a;
        expect(initialAlpha, closeTo(0.0, 0.05));

        // At t = 300ms (halfway through 600ms cycle), pulse is near 1.0 (opaque border)
        await tester.pump(const Duration(milliseconds: 300));
        final midAlpha = getDecoration().border!.top.color.a;
        expect(midAlpha, greaterThan(0.4));

        // At t = 600ms, pulse reaches 1.0
        await tester.pump(const Duration(milliseconds: 300));
        final peakAlpha = getDecoration().border!.top.color.a;
        expect(peakAlpha, closeTo(1.0, 0.05));
      },
    );

    test('Tutorial step satisfaction reverts on Undo and restores on Redo', () {
      final markdown = '''
# Undo Test Tutorial

## 1. Add Event
> add = event(x=0, t=0)
''';
      final tutorial = Tutorial.fromMarkdown(markdown);
      final controller = TutorialController(scene, tutorial);

      expect(controller.isCurrentStepSatisfied, false);
      expect(controller.isContinueEnabled, false);

      controller.doItForMe();
      expect(controller.isCurrentStepSatisfied, true);
      expect(controller.isContinueEnabled, true);

      scene.undoManager.undo();
      scene.updateScene();

      expect(controller.isCurrentStepSatisfied, false);
      expect(controller.isContinueEnabled, false);

      scene.undoManager.redo();
      scene.updateScene();

      expect(controller.isCurrentStepSatisfied, true);
      expect(controller.isContinueEnabled, true);
    });
  });
}
