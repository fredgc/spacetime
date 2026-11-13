import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/drawable.dart';
import 'package:spacetime/file_holder.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/script.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/transform.dart';
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

    testWidgets('TutorialCard text and coaches are scrollable and selectable', (
      WidgetTester tester,
    ) async {
      final longBody = List.generate(
        20,
        (i) => 'Paragraph $i explaining relativity physics in detail.',
      ).join('\n\n');

      final markdown =
          '''
# Scrollable & Selectable Tutorial

Intro description.

## 1. Long Step Title
$longBody

> v = 0.5
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

      // Verify SelectionArea wraps tutorial content
      final selectionAreas = find.descendant(
        of: find.byType(TutorialCard),
        matching: find.byType(SelectionArea),
      );
      expect(selectionAreas, findsOneWidget);

      // Verify Scrollbar and SingleChildScrollView are present
      expect(find.byType(Scrollbar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify coaching text is present
      expect(find.textContaining("Target: v = 0.50"), findsOneWidget);

      // Verify scrollable behavior: can scroll down
      final scrollableFinder = find.byType(SingleChildScrollView);
      await tester.drag(scrollableFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify later paragraph becomes visible or was scrolled
      expect(find.textContaining("Paragraph"), findsWidgets);

      controller.dispose();
    });

    testWidgets(
      'German Tutorial 2 Step 1 fits within maxHeight and shows Continue button',
      (WidgetTester tester) async {
        final germanTutorial2 = File(
          'assets/tutorials/02_ether_vs_emitter_de.md',
        ).readAsStringSync();
        final tutorial = Tutorial.fromMarkdown(germanTutorial2);
        final controller = TutorialController(scene, tutorial);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 500,
                width: 400,
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      right: 16,
                      child: TutorialCard(
                        controller: controller,
                        maxHeight: 420,
                        onClose: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify TutorialCard does not exceed maxHeight
        final cardBox = tester.getRect(find.byType(Card));
        expect(cardBox.height, lessThanOrEqualTo(420.0));

        // Verify Continue and Back buttons are visible and rendered
        expect(find.byKey(const ValueKey('tutorial-next-btn')), findsOneWidget);
        final nextBtnBox = tester.getRect(
          find.byKey(const ValueKey('tutorial-next-btn')),
        );
        expect(nextBtnBox.bottom, lessThanOrEqualTo(cardBox.bottom));

        // Verify scrollable behavior works on long German text
        final scrollable = find.byType(SingleChildScrollView);
        expect(scrollable, findsOneWidget);
        await tester.drag(scrollable, const Offset(0, -200));
        await tester.pumpAndSettle();

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
      final holder = AssetHolder('assets/tutorials/03_speed_of_light.md');
      expect(holder.type, equals('asset'));
      expect(holder.kind, equals(FileKind.tutorial));
      expect(holder.title, equals('03_speed_of_light'));
      expect(holder.userDescription(), equals('03_speed_of_light (tutorial)'));
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
        expect(prodOnly.length, equals(7));
        expect(
          prodOnly.any((t) => t.assetPath.contains('assets/dev/tutorials')),
          isFalse,
        );
        expect(
          prodOnly.any(
            (t) =>
                t.assetPath.contains('assets/tutorials/03_speed_of_light.md'),
          ),
          isTrue,
        );
        expect(
          prodOnly.any(
            (t) =>
                t.assetPath.contains('assets/tutorials/02_ether_vs_emitter.md'),
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
                t.assetPath.contains('assets/tutorials/03_speed_of_light.md'),
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
            (item) => item.name == "2. Constant Speed of Light & Relativity",
          ),
          isTrue,
        );
        expect(
          menu.items.any(
            (item) => item.name == "3. Constant Speed of Light & Simultaneity",
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
      'All 7 built-in tutorials parse and complete every step via doItForMe',
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

    test('Slider value jumps to tutorial target when dragged close', () {
      final markdown = '''
# Slider Snapping Tutorial

## 1. Set Time
> t = 0.50 [tol 0.05]

## 2. Set Velocity
> v = 0.40 [tol 0.05]
''';
      final tutorial = Tutorial.fromMarkdown(markdown);
      final controller = TutorialController(scene, tutorial);

      expect(scene.time.snapTarget, equals(0.50));
      // Moving close to 0.50 (e.g. 0.48) should snap exactly to 0.50
      scene.time.value = 0.48;
      expect(scene.time.value, equals(0.50));
      expect(controller.isCurrentStepSatisfied, isTrue);

      // Moving far away should not snap
      scene.time.value = -0.50;
      expect(scene.time.value, equals(-0.50));
      expect(controller.isCurrentStepSatisfied, isFalse);

      controller.doItForMe();
      controller.nextStep();

      // Step 2: velocity
      expect(scene.velocity.snapTarget, equals(0.40));
      scene.velocity.value = 0.38;
      expect(scene.velocity.value, equals(0.40));
      expect(controller.isCurrentStepSatisfied, isTrue);

      controller.dispose();
      expect(scene.time.snapTarget, isNull);
      expect(scene.velocity.snapTarget, isNull);
    });

    test('Adding object near target coordinates snaps directly to target', () {
      final markdown = '''
# Canvas Snap Tutorial

## 1. Add Event
> add = event(x=0.20, t=1.00)
''';
      final tutorial = Tutorial.fromMarkdown(markdown);
      fileManager.activeTutorial.value = TutorialController(scene, tutorial);

      scene.currentTool.value = Tool.add;
      scene.currentType.value = DrawType.event;

      // Click near target: (x=0.18, t=0.95), tolerance is 0.5
      scene.addObject(Point(x: 0.18, t: 0.95));

      final added = scene.data.drawables.last;
      expect(added.pt.x, closeTo(0.20, 1e-6));
      expect(added.pt.t, closeTo(1.00, 1e-6));
      expect(fileManager.activeTutorial.value!.isCurrentStepSatisfied, isTrue);

      fileManager.activeTutorial.value!.dispose();
      fileManager.activeTutorial.value = null;
    });

    test(
      "Tutorial 3 initializes Alice's clock with z = 0.125 (50% flag height)",
      () async {
        final tutorials = getBuiltInTutorials();
        final tutHolder = tutorials.firstWhere(
          (t) => t.title.contains('Dilation'),
        );
        final md = await tutHolder.loadData(fileManager);
        final tut3 = Tutorial.fromMarkdown(md);
        final controller = TutorialController(scene, tut3);

        final alice = scene.data.drawables.firstWhere((d) => d.name == 'Alice');
        expect(alice.pt.z, equals(0.125));
        controller.dispose();
      },
    );

    test(
      'Tutorial 2 contains train sprite and ground flags at flash origins',
      () async {
        final tutorials = getBuiltInTutorials();
        final tutHolder = tutorials.firstWhere(
          (t) => t.title.contains('Constant Speed of Light & Relativity'),
        );
        final md = await tutHolder.loadData(fileManager);
        final tut2 = Tutorial.fromMarkdown(md);
        final controller = TutorialController(scene, tut2);

        expect(tut2.steps.length, equals(10));

        // Advance to step 2 (setup with train, flags, and end flashes)
        controller.doItForMe();
        controller.nextStep();

        final train = scene.data.drawables.firstWhere((d) => d.name == 'Train');
        expect(train.type, equals(DrawType.train));
        expect(train.frame.velocity, equals(0.25));

        final backFlag = scene.data.drawables.firstWhere((d) => d.name == 'BF');
        expect(backFlag.type, equals(DrawType.flag));
        expect(backFlag.frame.velocity, equals(0.0));
        expect(backFlag.pt.x, equals(-0.25));

        final frontFlag = scene.data.drawables.firstWhere(
          (d) => d.name == 'FF',
        );
        expect(frontFlag.type, equals(DrawType.flag));
        expect(frontFlag.frame.velocity, equals(0.0));
        expect(frontFlag.pt.x, equals(0.25));

        final backFlash = scene.data.drawables.firstWhere((d) => d.name == 'B');
        expect(backFlash.type, equals(DrawType.cone));

        final frontFlash = scene.data.drawables.firstWhere(
          (d) => d.name == 'F',
        );
        expect(frontFlash.type, equals(DrawType.cone));

        controller.dispose();
      },
    );

    test(
      'Tutorial 3 sets up train at v=0.25 and marks front and back hit events',
      () async {
        final tutorials = getBuiltInTutorials();
        final tutHolder = tutorials.firstWhere(
          (t) => t.title.contains('Constant Speed of Light & Simultaneity'),
        );
        final md = await tutHolder.loadData(fileManager);
        final tut3 = Tutorial.fromMarkdown(md);
        final controller = TutorialController(scene, tut3);

        expect(tut3.steps.length, equals(10));

        // Step 1: add flash cone in center of train
        controller.doItForMe();
        expect(controller.isContinueEnabled, isTrue);
        controller.nextStep();

        // Step 2: advance time in train frame to t=0.25
        controller.doItForMe();
        expect(scene.time.value, closeTo(0.25, 0.01));
        controller.nextStep();

        // Step 3: ground frame v=0, t=0
        controller.doItForMe();
        expect(scene.velocity.value, closeTo(0.0, 0.01));
        controller.nextStep();

        // Advance through remaining steps
        int guard = 0;
        while (!controller.isCompleted && guard < 20) {
          if (!controller.isContinueEnabled && controller.canDoItForMe) {
            controller.doItForMe();
          }
          controller.nextStep();
          guard++;
        }

        expect(controller.isCompleted, isTrue);
        final backHit = scene.data.drawables.firstWhere((d) => d.name == 'B');
        final frontHit = scene.data.drawables.firstWhere((d) => d.name == 'F');
        expect(backHit.type, equals(DrawType.event));
        expect(frontHit.type, equals(DrawType.event));

        final flash = scene.data.drawables.firstWhere((d) => d.name == 'Flash');
        expect(flash.pt.z, equals(0.15));

        controller.dispose();
      },
    );
  });
}
