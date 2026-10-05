import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/scene.dart';
import 'package:spacetime/drawable.dart';
import 'app_tester.dart';
import 'scene_editor.dart';
import 'test_data.dart';

class Seeder {
  math.Random random = math.Random();
  int get seed => random.nextInt(123456);
}

abstract class EditTest {
  final String name;
  final int seed;
  EditTest(this.name, this.seed);

  List<OneEdit> makeList(app);

  // Verify that the first |count| edits in the array |edits| were applied
  // to the scene in |app|.
  Future<void> checkExpected(
    AppTester app,
    List<OneEdit> edits,
    int count,
  ) async {
    SceneData expected = TestData.sample.data;
    try {
      expect(count, lessThanOrEqualTo(edits.length));
      for (int i = 0; i < count; i++) {
        await edits[i].changeExpected(expected);
      }
      // Except time and velocity might be wrong. So let's just change them:
      await app.scene.editVelocity(expected.velocity);
      await app.scene.editTime(expected.time);
      expected.time = expected.time.clamp(
        app.scene.view!.time.min,
        app.scene.view!.time.max,
      );
      await app.findScene(expected);
    } catch (e, s) {
      print("For count = $count");
      print('Caught exception: $e');
      print('Stack trace: $s');
      print("YELLOW: list of edits.");
      for (var edit in edits) {
        print("   $edit (undoable=${edit.undoable})");
      }
      app.scene.view!.undo_manager.dumpList();
      print("GREEN: Expected:");
      for (var i = 0; i < expected.drawables.length; i++) {
        Drawable d = expected.drawables[i];
        print("   $i) $d");
      }
      print("RED: Current:");
      for (var i = 0; i < app.scene.view!.data.drawables.length; i++) {
        Drawable d = app.scene.view!.data.drawables[i];
        print("   $i) $d");
      }
      rethrow;
    }
  }

  // Run the tests, with a possible extra check to be performed at the end.
  void tests({Function(AppTester)? check}) {
    oneTest("unsaved", (app, edits) async {
      expect(app.manager.unsaved.value, false);
      int initialUnsavedCount = app.scene.unsaved_count;
      for (var edit in edits) {
        await edit.change(app);
        await app.scene.checkFields();
      }
      await checkExpected(app, edits, edits.length);
      expect(app.manager.unsaved.value, true);
      expect(app.scene.unsaved_count > initialUnsavedCount, true);
      int unsavedCountBeforeSave = app.scene.unsaved_count;
      await app.saveLocal("5");
      expect(app.manager.unsaved.value, false);
      expect(unsavedCountBeforeSave + 1, app.scene.unsaved_count);
      if (check != null) await check(app);
    });

    oneTest("one undo", (app, edits) async {
      expect(app.manager.unsaved.value, false);
      int initialUnsavedCount = app.scene.unsaved_count;
      for (var edit in edits) {
        await edit.change(app);
        await app.scene.checkFields();
      }
      // Not all edits are undoable. Time and velocity are not.
      if (edits.last.undoable) {
        await app.tapMenu("Undo");
        await checkExpected(app, edits, edits.length - 1);
      } else {
        await checkExpected(app, edits, edits.length);
      }
    });
    oneTest("undo-redo-undo", (app, edits) async {
      int cut1 = 0;
      int cut2 = 0;
      int cut3 = 0;
      int undoCount = 0;
      int redoCount = 0;
      int undoCount2 = 0;
      try {
        // This test does several edits, then does several undos, then several
        // redos and then some more undos.
        for (var edit in edits) {
          // Do N edits.
          await edit.change(app);
          await app.scene.checkFields();
        }
        await checkExpected(app, edits, edits.length);
        // Undo back to cut1.
        cut1 = app.scene.random.nextInt(edits.length);
        // Except, because some edits are not undoable, we have to move cut1
        // forward until it is just before an undoable one.
        while (cut1 < edits.length && !edits[cut1].undoable) {
          cut1++;
        }
        for (int i = cut1; i < edits.length; i++) {
          if (edits[i].undoable) {
            await app.tapMenu("Undo");
            undoCount++;
          }
        }
        await checkExpected(app, edits, cut1);
        expect(undoCount, app.scene.view!.undo_manager.redoList.length);
        // Now do a few redos.
        redoCount = undoCount == 0 ? 0 : app.scene.random.nextInt(undoCount);
        cut2 = cut1;
        // count from cut1 forward until we've done redo_count redos.
        int i = 0;
        while (i < redoCount) {
          cut2++;
          if (edits[cut2].undoable) {
            await app.tapMenu("Redo");
            i++;
          }
        }
        await checkExpected(app, edits, cut2);
        expect(
          undoCount - redoCount,
          app.scene.view!.undo_manager.redoList.length,
        );
        // Now, do some more undos back to cut3.
        cut3 = cut2 == 0 ? 0 : app.scene.random.nextInt(cut2);
        // Except, because some edits are not undoable, we have to move cut1
        // forward until it is just before an undoable one.
        while (cut3 < cut2 && !edits[cut3].undoable) {
          cut3++;
        }
        for (int i = cut3; i < cut2; i++) {
          if (edits[i].undoable) {
            await app.tapMenu("Undo");
            undoCount2++;
          }
        }
        await checkExpected(app, edits, cut3);
        expect(
          undoCount - redoCount + undoCount2,
          app.scene.view!.undo_manager.redoList.length,
        );
      } catch (e) {
        print("cut1 = $cut1, undo=$undoCount");
        print("cut2 = $cut2, redo=$redoCount");
        print("cut3 = $cut3, undo2=$undoCount2");
        rethrow;
      }
    });
  }

  Future<AppTester> setup(tester) async {
    AppTester app = AppTester(tester, random: math.Random(seed));
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());
    await app.openLocal("5", TestData.sample.data);
    return app;
  }

  void oneTest(
    String testName,
    Future<void> Function(AppTester, List<OneEdit>) doTest,
  ) {
    testWidgets('$name - $testName, $seed', (tester) async {
      final app = await setup(tester);
      List<OneEdit> edits = makeList(app);
      await doTest(app, edits);
      await app.teardown();
    });
  }
}

class EditArray extends EditTest {
  List<OneEdit> list;
  EditArray(super.name, super.seed, this.list);
  @override
  List<OneEdit> makeList(app) => list;
}

class RandomEditArray extends EditTest {
  RandomEditArray(int seed) : super("random", seed);
  @override
  List<OneEdit> makeList(app) => app.scene.randomEdits(15);
}

void main() {
  testWidgets('edit time with empty list', (tester) async {
    final app = AppTester(tester);
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());
    expect(app.manager.unsaved.value, false);
    int initialUnsavedCount = app.scene.unsaved_count;
    app.scene.expectTime(0.0); // An empty scene starts with t=0, v=0.
    app.scene.expectVelocity(0.0);
    // Change the time and velocity a few times.
    for (double x in [-0.2, 0.2, 0.1, -0.2, 0.2]) {
      await app.scene.editTime(x);
      app.scene.expectTime(x);
      app.scene.expectVelocity(0.0);
    }
    for (double x in [-0.2, 0.2, 0.1, -0.2, 0.2]) {
      await app.scene.editVelocity(x);
      app.scene.expectVelocity(x);
      app.scene.expectTime(0.2); //Last time from time changes.
    }
    // Expect that changing the time or veloicty when the scene has no objects
    // does not change anything.
    expect(initialUnsavedCount, app.scene.unsaved_count);
    expect(app.manager.unsaved.value, false);
    await app.teardown();
  });
  testWidgets('edit with nonempty list does change unsaved', (tester) async {
    final app = AppTester(tester);
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());
    await app.openLocal("3", TestData.train.data);
    expect(app.manager.unsaved.value, false);
    int initialUnsavedCount = app.scene.unsaved_count;
    // Starting values for TestData.train.
    app.scene.expectTime(0.5);
    app.scene.expectVelocity(0.123);
    // Change the time and velocity a few times.
    for (double x in [-0.2, 0.2, 0.1, -0.2, 0.2]) {
      await app.scene.editVelocity(x);
      app.scene.expectVelocity(x);
      app.scene.expectTime(0.5); // Time shouldn't change.
    }
    // Expect the unsaved variable is only updated on the first change.
    expect(initialUnsavedCount + 1, app.scene.unsaved_count);
    expect(app.manager.unsaved.value, true);
    await app.saveLocal("3");
    expect(initialUnsavedCount + 2, app.scene.unsaved_count);
    expect(app.manager.unsaved.value, false);
    for (double x in [-0.2, 0.2, 0.1, -0.2, 0.2]) {
      await app.scene.editTime(x);
      app.scene.expectTime(x);
      app.scene.expectVelocity(0.2); //Last velocity change.
    }
    expect(initialUnsavedCount + 3, app.scene.unsaved_count);
    expect(app.manager.unsaved.value, true);
    await app.saveLocal("3");
    expect(initialUnsavedCount + 4, app.scene.unsaved_count);
    expect(app.manager.unsaved.value, false);
    await app.teardown();
  });

  testWidgets('clone', (tester) async {
    SceneData original = TestData.sample.data;
    SceneData cloned = TestData.clone(original);
    expect(cloned, original);
    cloned.title = "This is a new title";
    expect(cloned, isNot(original));
  });

  group('Edit Arrays.', () {
    Seeder seeder = Seeder();
    EditArray("time and title", seeder.seed, [
      TitleEdit("title 1"),
      TimeEdit(1.25),
      VelocityEdit(0.1),
      TitleEdit("title 2"),
    ]).tests(
      check: (app) async {
        expect(find.textContaining("title 2"), findsOneWidget);
      },
    );
    // Try changing the time a few times.
    EditArray(
      "time",
      seeder.seed,
      [0.2, -0.2, 0.15, 0.1, -0.15, 0.2].map((t) => TimeEdit(t)).toList(),
    ).tests(
      check: (app) async {
        app.scene.expectTime(0.2);
      },
    );
    // Try changing the velocity a few times.
    EditArray(
      "velocity",
      seeder.seed,
      [0.12, -0.5, 0.25, 0.1, -0.3, 0.5].map((v) => VelocityEdit(v)).toList(),
    ).tests(
      check: (app) async {
        app.scene.expectVelocity(0.5);
      },
    );
    EditArray(
      "name",
      seeder.seed,
      ["one", "two", "three", "four", "five"].map((v) => NameEdit(v)).toList(),
    ).tests();
    EditArray(
      "type",
      seeder.seed,
      [
        DrawType.person,
        DrawType.event,
        DrawType.flag,
        DrawType.train,
      ].map((t) => TypeEdit(t)).toList(),
    ).tests();

    EditArray(
      "color",
      seeder.seed,
      [0, 3, 1, 2, 5].map((c) => ColorEdit(c)).toList(),
    ).tests();

    EditArray("position", seeder.seed, [
      PositionEdit(Offset(100, 50)),
      PositionEdit(Offset(50, 0)),
      PositionEdit(Offset(-50, 25)),
      PositionEdit(Offset(0, 10)),
      PositionEdit(Offset(50, 25)),
    ]).tests();

    EditArray("delete", seeder.seed, [
      DeleteEdit(),
      DeleteEdit(),
      DeleteEdit(),
      DeleteEdit(),
      DeleteEdit(),
      DeleteEdit(),
    ]).tests(
      check: (app) async {
        expect(app.scene.view!.data.drawables.length, 3);
      },
    );

    EditArray("add object", seeder.seed, [
      AddObjectEdit("P1", DrawType.train, 1, Offset(0.5, 0.5)),
      AddObjectEdit("P2", DrawType.cone, 1, Offset(0.1, 0.2)),
      AddObjectEdit("P3", DrawType.instant, 1, Offset(0.3, 0.7)),
      AddObjectEdit("P4", DrawType.event, 1, Offset(0.8, 0.1)),
    ]).tests(
      check: (app) async {
        expect(app.scene.view!.data.drawables.length, 13);
      },
    );

    EditArray(
      "side position",
      seeder.seed,
      [
        SideEdit(Offset(100, 25)),
        SideEdit(Offset(50, 0)),
        SideEdit(Offset(-50, 10)),
        SideEdit(Offset(0, 10)),
        SideEdit(Offset(50, 20)),
      ].map((edit) => [SelectSide(edit), edit]).expand((l) => l).toList(),
    ).tests();

    for (int i = 0; i < 50; i++) {
      RandomEditArray(seeder.seed).tests();
    }
  });
}
