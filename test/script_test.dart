import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/drawable.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/script.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/transform.dart';

void main() {
  group('Legacy script compatibility', () {
    test('simple test', () {
      String input = "this is a test.";
      MyScript s = MyScript(input);
      expect(input, s.script);
    });
  });

  group('Tutorial parsing and directives', () {
    test('parses title, steps, body, and combined directives', () {
      final markdown = '''
# Special Relativity Basics

An introduction to relativity.

## 1. Adjust Velocity
Move the slider to 0.25.

> v = 0.25

## 2. Check Time
Wait until time reaches 3.0.

> t = 3.0 tol=0.05

## 3. Switch to Ether
Change physics model.

> ether

## 4. Summary
Great job!

> ok
''';

      final tutorial = Tutorial.fromMarkdown(markdown);
      expect(tutorial.title, equals("Special Relativity Basics"));
      expect(tutorial.description, equals("An introduction to relativity."));
      expect(tutorial.steps.length, equals(4));

      // Step 1: velocity
      final step1 = tutorial.steps[0];
      expect(step1.stepNumber, equals(1));
      expect(step1.title, equals("Adjust Velocity"));
      expect(step1.body, equals("Move the slider to 0.25."));
      expect(step1.highlightId, equals("slider.velocity"));
      expect(step1.directives.first, isA<VelocityDirective>());
      final vDir = step1.directives.first as VelocityDirective;
      expect(vDir.targetVelocity, equals(0.25));
      expect(vDir.tolerance, equals(0.02));

      // Step 2: time with custom tolerance
      final step2 = tutorial.steps[1];
      expect(step2.title, equals("Check Time"));
      expect(step2.highlightId, equals("slider.time"));
      expect(step2.directives.first, isA<TimeDirective>());
      final tDir = step2.directives.first as TimeDirective;
      expect(tDir.targetTime, equals(3.0));
      expect(tDir.tolerance, equals(0.05));

      // Step 3: mode ether
      final step3 = tutorial.steps[2];
      expect(step3.highlightId, equals("menu.light_speed"));
      expect(step3.directives.first, isA<ModeDirective>());
      final mDir = step3.directives.first as ModeDirective;
      expect(mDir.targetMode, equals(LightSpeed.ether));

      // Step 4: acknowledge
      final step4 = tutorial.steps[3];
      expect(step4.highlightId, equals("tutorial.continue"));
      expect(step4.directives.first, isA<AcknowledgeDirective>());
    });

    test('setup directive parses multiple fields', () {
      final md = '''
## Initialize
> setup: v=0.5, t=1.0, mode=ether
> ok
''';
      final tutorial = Tutorial.fromMarkdown(md);
      expect(tutorial.steps.length, equals(1));
      final setupDir =
          tutorial.steps.first.directives.firstWhere((d) => d is SetupDirective)
              as SetupDirective;
      expect(setupDir.velocity, equals(0.5));
      expect(setupDir.time, equals(1.0));
      expect(setupDir.mode, equals(LightSpeed.ether));
    });

    test(
      'parses mdformat-merged single-line blockquote with reset, setup, object, and ok',
      () {
        final md = '''
## 1. Start Fresh
Welcome!

> reset setup: v=0.5, t=1.0, mode=lorentz object: person(name="Alice", x=-0.5, t=0.0, v=0.25, color=blue) ok
''';
        final tutorial = Tutorial.fromMarkdown(md);
        expect(tutorial.steps.length, equals(1));
        final directives = tutorial.steps.first.directives;
        expect(directives.whereType<ResetDirective>().length, equals(1));
        expect(directives.whereType<SetupDirective>().length, equals(1));
        expect(directives.whereType<ObjectDirective>().length, equals(1));
        expect(directives.whereType<AcknowledgeDirective>().length, equals(1));

        final setup = directives.whereType<SetupDirective>().first;
        expect(setup.velocity, equals(0.5));
        expect(setup.time, equals(1.0));
        expect(setup.mode, equals(LightSpeed.lorentz));

        final objDir = directives.whereType<ObjectDirective>().first;
        expect(objDir.drawables.length, equals(1));
        final alice = objDir.drawables.first;
        expect(alice.type, equals(DrawType.person));
        expect(alice.name, equals("Alice"));
        expect(alice.pt.x, equals(-0.5));
        expect(alice.frame.velocity, equals(0.25));
        expect(alice.color, equals(2));
      },
    );

    test('parses inline JSON objects in object directive', () {
      final md = '''
## Load JSON Object
> object: {"type": "train", "name": "Express", "x": -1.0, "t": 0.0, "v": 0.4, "color": 6}
> ok
''';
      final tutorial = Tutorial.fromMarkdown(md);
      final objDir = tutorial.steps.first.directives
          .whereType<ObjectDirective>()
          .first;
      expect(objDir.drawables.length, equals(1));
      final train = objDir.drawables.first;
      expect(train.type, equals(DrawType.train));
      expect(train.name, equals("Express"));
      expect(train.pt.x, equals(-1.0));
      expect(train.frame.velocity, equals(0.4));
      expect(train.color, equals(6));
    });
  });

  group('TutorialController execution', () {
    late Settings settings;
    late FileManager fileManager;
    late SceneView scene;

    setUp(() {
      settings = Settings();
      fileManager = FileManager(settings);
      scene = SceneView(fileManager, settings, SceneData());
      fileManager.current.scene = scene;
    });

    test('evaluates velocity criterion and requires manual advance', () {
      final md = '''
# Test
## Set v to 0.25
> v = 0.25
## Done
> ok
''';
      final tutorial = Tutorial.fromMarkdown(md);
      final controller = TutorialController(scene, tutorial);

      expect(controller.currentStepIndex, equals(0));
      expect(controller.isCurrentStepSatisfied, isFalse);
      expect(controller.isContinueEnabled, isFalse);
      expect(controller.canDoItForMe, isTrue);

      // Trigger doItForMe
      controller.doItForMe();
      expect(scene.velocity.value, equals(0.25));
      expect(controller.isCurrentStepSatisfied, isTrue);
      expect(controller.isContinueEnabled, isTrue);
      expect(controller.canDoItForMe, isFalse);

      controller.nextStep();
      expect(controller.currentStepIndex, equals(1));
      expect(controller.isContinueEnabled, isTrue);

      controller.previousStep();
      expect(controller.currentStepIndex, equals(0));

      controller.dispose();
    });

    test('no_auto directive disables doItForMe', () {
      final md = '''
# Test
> no_auto
## Set v to 0.25
> v = 0.25
''';
      final tutorial = Tutorial.fromMarkdown(md);
      expect(tutorial.allowDoItForMe, isFalse);

      final controller = TutorialController(scene, tutorial);
      expect(controller.canDoItForMe, isFalse);
      controller.dispose();
    });

    test('finishTutorial keeps scene and marks unsaved', () {
      final tutorial = Tutorial(title: "Test Lesson", steps: []);
      fileManager.startTutorial(tutorial);
      expect(fileManager.current.scene?.data.title, equals("Test Lesson"));

      fileManager.finishTutorial();
      expect(fileManager.activeTutorial.value, isNull);
      expect(fileManager.current.scene?.data.title, equals("Test Lesson"));
      expect(fileManager.unsaved.value, isTrue);
    });

    test(
      'interactive add, select, move, and color directives guide user and support doItForMe',
      () {
        final md = '''
# Interactive Tools Test
## 1. Setup Scene
> reset
> object: person(name="Alice", x=0.0, t=0.0, color=blue)
> ok

## 2. Add Light Cone
> add = cone

## 3. Select Alice
> select = Alice

## 4. Move Alice
> move = Alice(x=0.5, tol=0.2)

## 5. Color Alice Green
> color = green
''';
        final tutorial = Tutorial.fromMarkdown(md);
        final controller = TutorialController(scene, tutorial);

        // Step 1: Alice was added to scene
        expect(scene.data.drawables.length, equals(1));
        expect(scene.data.drawables.first.name, equals("Alice"));
        controller.nextStep();

        // Step 2: Add Light Cone
        expect(controller.currentStepIndex, equals(1));
        expect(controller.isCurrentStepSatisfied, isFalse);
        // Initially tool is Select, so highlight should be tool.mode
        expect(controller.currentHighlightId, equals('tool.mode'));

        // User switches tool to Add
        scene.currentTool.value = Tool.add;
        // Now type is Event (default), so highlight should switch to tool.type
        expect(controller.currentHighlightId, equals('tool.type'));

        // User selects Light Cone type
        scene.currentType.value = DrawType.cone;
        // Now highlight should point to the recommended point on the canvas
        expect(controller.currentHighlightId, equals('canvas.point'));
        expect(controller.highlightedPoint, equals(Point(x: 0.0, t: 0.0)));

        // User places the cone (or clicks Do it for me)
        scene.addObject(Point(x: 0.0, t: 0.0));
        expect(controller.isCurrentStepSatisfied, isTrue);
        controller.nextStep();

        // Step 3: Select Alice
        expect(controller.currentStepIndex, equals(2));
        expect(controller.isCurrentStepSatisfied, isFalse);
        // Tool is still Add from previous step, so it highlights tool.mode
        expect(controller.currentHighlightId, equals('tool.mode'));

        // Switch tool to Select -> highlights the specific object (Alice) on canvas
        scene.currentTool.value = Tool.select;
        expect(controller.currentHighlightId, equals('canvas.object'));
        expect(controller.highlightedDrawable?.name, equals('Alice'));

        controller.doItForMe();
        expect(scene.currentTool.value, equals(Tool.select));
        expect(scene.selected?.name, equals("Alice"));
        expect(controller.isCurrentStepSatisfied, isTrue);
        controller.nextStep();

        // Step 4: Move Alice to x=0.5
        expect(controller.currentStepIndex, equals(3));
        expect(controller.isCurrentStepSatisfied, isFalse);
        expect(controller.currentHighlightId, equals('canvas.object'));
        expect(controller.highlightedDrawable?.name, equals('Alice'));

        controller.doItForMe();
        expect(scene.selected?.pt.x, closeTo(0.5, 0.01));
        expect(controller.isCurrentStepSatisfied, isTrue);
        controller.nextStep();

        // Step 5: Change color to green (5)
        expect(controller.currentStepIndex, equals(4));
        expect(controller.isCurrentStepSatisfied, isFalse);
        expect(controller.currentHighlightId, equals('tool.color'));

        controller.doItForMe();
        expect(scene.currentColor.value, equals(5));
        expect(controller.isCurrentStepSatisfied, isTrue);

        controller.dispose();
      },
    );

    test('debug_test.md parses and completes all steps cleanly', () {
      final content = File(
        'assets/dev/tutorials/debug_test.md',
      ).readAsStringSync();
      final tutorial = Tutorial.fromMarkdown(content);
      expect(tutorial.steps.length, equals(8));

      final controller = TutorialController(scene, tutorial);
      expect(scene.data.drawables.length, equals(2));
      expect(scene.velocity.value, equals(0.5));

      while (!controller.isCompleted) {
        if (!controller.isContinueEnabled && controller.canDoItForMe) {
          controller.doItForMe();
        }
        expect(controller.isContinueEnabled, isTrue);
        controller.nextStep();
      }
      expect(controller.isCompleted, isTrue);
      controller.dispose();
    });
  });
}
