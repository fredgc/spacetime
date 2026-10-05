import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/drawable.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';

import 'app_tester.dart';
import 'test_data.dart';
import 'helper.dart';

void selectTests(String canvas, bool side) {
  group('Select $canvas.', () {
    // Tap on a single object, at the center of the scene.
    testWidgets('centered object', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("2", TestData.person.data);

      expect(app.scene.view!.selected, null);
      final obj = await app.scene.select(0, side: side);
      expect(obj.name, "P1");
      // For this scene, the object is in the same frame as the observer.
      expect(obj.pt_obs, obj.pt);
      await app.scene.expectName("P1");
      await app.scene.expectType(DrawType.person);
      await app.scene.expectColor(0);
      await app.scene.expectTool("Select");
      // Edit the properties and make sure that the menus have changed.
      // Edit twice to make sure the test code picks the right thing.
      await app.scene.editName("New Name");
      await app.scene.editName("New Name");
      await app.scene.editName("New Name");
      await app.scene.expectName("New Name");
      await app.scene.editType(DrawType.event);
      await app.scene.editType(DrawType.event);
      await app.scene.editType(DrawType.event);
      await app.scene.expectType(DrawType.event);
      await app.scene.editColor(4);
      await app.scene.editColor(4);
      await app.scene.editColor(4);
      await app.scene.expectColor(4);

      // When we deselect, it should go away.
      await app.scene.deselect();
      expect(app.scene.view!.selected, null);
      // But the menus should not change, except name.
      await app.scene.expectName("-none-");
      await app.scene.expectType(DrawType.event);
      await app.scene.expectColor(4);
      await app.scene.expectTool("Select");

      await app.teardown();
    });

    // Tap on a single object, but not at the center of the scene.
    testWidgets('offset object', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("3", TestData.train.data);

      expect(app.scene.view!.selected, null);
      final obj = await app.scene.select(0, side: side);
      expect(obj.name, "P1");
      await app.scene.expectName("P1");
      await app.scene.expectType(DrawType.train);
      await app.scene.expectColor(1);
      await app.scene.expectTool("Select");
      // Edit the properties and make sure that the menus have changed.
      // Edit twice to make sure the test code can also do a no-op change.
      await app.scene.editName("New Name");
      await app.scene.editName("New Name");
      await app.scene.editName("New Name");
      await app.scene.expectName("New Name");
      await app.scene.editType(DrawType.event);
      await app.scene.editType(DrawType.event);
      await app.scene.editType(DrawType.event);
      await app.scene.expectType(DrawType.event);
      await app.scene.editColor(4);
      await app.scene.editColor(4);
      await app.scene.editColor(4);
      await app.scene.expectColor(4);

      // When we deselect, it should go away.
      await app.scene.deselect();
      expect(app.scene.view!.selected, null);
      // But the menus should not change, except name.
      await app.scene.expectName("-none-");
      await app.scene.expectType(DrawType.event);
      await app.scene.expectColor(4);
      await app.scene.expectTool("Select");

      await app.teardown();
    });

    // Change tool to add should deselect the object.
    testWidgets('Change Tool', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("2", TestData.person.data);

      expect(app.scene.view!.selected, null);
      final obj = await app.scene.select(0, side: side);
      // Changing the tool to 'Add' should deselect and change the name.
      // But the type and color do not change.
      await app.scene.editTool("Add");
      expect(app.scene.view!.selected, null);
      await app.scene.expectName("P2");
      await app.scene.expectType(DrawType.person);
      await app.scene.expectColor(0);

      // Selecting "Add" again should not do anything.
      await app.scene.editTool("Add");
      expect(app.scene.view!.selected, null);
      await app.scene.expectName("P2");
      await app.scene.expectType(DrawType.person);
      await app.scene.expectColor(0);
      await app.scene.editTool("Add");
      expect(app.scene.view!.selected, null);
      await app.scene.expectName("P2");
      await app.scene.expectType(DrawType.person);
      await app.scene.expectColor(0);

      await app.scene.expectTool("Add");
      // Changing the tool to "Select" does not reselect the previous item.
      await app.scene.editTool("Select");
      await app.scene.expectTool("Select");
      expect(app.scene.view!.selected, null);
      await app.scene.expectName("P2");
      await app.scene.expectType(DrawType.person);
      await app.scene.expectColor(0);

      // Make sure we can go back and forth between add/select and nothing breaks.
      await app.scene.editTool("Add");
      await app.scene.expectTool("Add");
      await app.scene.editTool("Select");
      await app.scene.expectTool("Select");
      await app.scene.editTool("Select");
      await app.scene.expectTool("Select");

      await app.teardown();
    });

    testWidgets('Shortcut Change Tool (Ctrl-A / Escape)', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("2", TestData.person.data);

      await app.scene.expectTool("Select");
      expect(app.scene.view!.current_tool.value, Tool.select);

      // Press Ctrl-A
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      await app.scene.expectTool("Add");
      expect(app.scene.view!.current_tool.value, Tool.add);

      // Press Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      await app.scene.expectTool("Select");
      expect(app.scene.view!.current_tool.value, Tool.select);

      await app.teardown();
    });

    // Tap on each object in the sample scene.
    testWidgets('Several Objects', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("5", TestData.sample.data);
      await app.scene.fitScene();
      expect(app.scene.view!.selected, null);

      var obj = await app.scene.select(0, side: side);
      expect(obj.name, "an event");
      await app.scene.expectName("an event");
      await app.scene.expectType(DrawType.event);
      await app.scene.expectColor(0);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(1, side: side);
      expect(obj.name, "Inst");
      await app.scene.expectName("Inst");
      await app.scene.expectType(DrawType.instant);
      await app.scene.expectColor(1);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(2, side: side);
      expect(obj.name, "I2");
      await app.scene.expectName("I2");
      await app.scene.expectType(DrawType.instant);
      await app.scene.expectColor(2);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(3, side: side);
      expect(obj.name, "L1");
      await app.scene.expectName("L1");
      await app.scene.expectType(DrawType.cone);
      await app.scene.expectColor(3);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(4, side: side);
      expect(obj.name, "P");
      await app.scene.expectName("P");
      await app.scene.expectType(DrawType.person);
      await app.scene.expectColor(0);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(5, side: side);
      expect(obj.name, "T");
      await app.scene.expectName("T");
      await app.scene.expectType(DrawType.train);
      await app.scene.expectColor(1);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(6, side: side);
      expect(obj.name, "B");
      await app.scene.expectName("B");
      await app.scene.expectType(DrawType.barn);
      await app.scene.expectColor(2);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(7, side: side);
      expect(obj.name, "F");
      await app.scene.expectName("F");
      await app.scene.expectType(DrawType.flag);
      await app.scene.expectColor(4);
      await app.scene.expectTool("Select");

      obj = await app.scene.select(8, side: side);
      expect(obj.name, "C1");
      await app.scene.expectName("C1");
      await app.scene.expectType(DrawType.clock);
      await app.scene.expectColor(0);
      await app.scene.expectTool("Select");

      await app.teardown();
    });

    // Tap a second time on overlapped objects picks the second in the list.
    testWidgets('overlap', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.scene.editTool("Add");
      await app.scene.tap(Point(x: 0.001), side);
      await app.scene.tap(Point(x: 0.002), side);
      await app.scene.tap(Point(x: 0.003), side);
      await app.scene.editTool("Select");
      await app.scene.tap(Point(x: 0.0), side);
      await app.scene.expectName("E1"); // Closest.
      app.scene.expectSelect(0);
      await app.scene.tap(Point(x: 0.0), side);
      await app.scene.expectName("E2"); // Second closest.
      app.scene.expectSelect(1);
      await app.scene.tap(Point(x: 0.0), side);
      await app.scene.expectName("E3"); // Third closest.
      app.scene.expectSelect(2);
      await app.scene.tap(Point(x: 1.0), side);
      await app.scene.expectName("-none-"); // Third closest.
      app.scene.expectSelect(-1);
      await app.scene.tap(Point(x: 0.004), side);
      await app.scene.expectName("E3"); // Closest.
      app.scene.expectSelect(2);
      await app.scene.tap(Point(x: 0.004), side);
      await app.scene.expectName("E2"); // Second closest.
      app.scene.expectSelect(1);
      await app.scene.tap(Point(x: 0.004), side);
      await app.scene.expectName("E1"); // Third closest.
      app.scene.expectSelect(0);

      await app.teardown();
    });
  });
}

void main() {
  selectTests("Main", false);
  selectTests("Side", true);

  group('Drag.', () {
    testWidgets('Main', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("2", TestData.person.data);
      final obj = await app.scene.select(0);
      // print("PURPLE: Starting drag at ${obj.pt_obs}.");
      TestGesture drag = await app.scene.dragStart(obj.pt_obs, false);
      Point p2 = obj.pt_obs + Vector(dx: 0.1, dt: 0.15);
      // print("PURPLE: moving with drag to $p2.");
      await app.scene.dragTo(drag, p2, false);
      // print("PURPLE: done with drag.");
      expect(obj.pt_obs, PointMatch(p2)); // Object should have moved to p2.
      await app.teardown();
    });
    testWidgets('Side', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("2", TestData.person.data);
      final obj = await app.scene.select(0, side: true);
      // print("PURPLE: Starting drag at ${obj.pt_obs}.");
      TestGesture drag = await app.scene.dragStart(obj.pt_obs, true);
      Point p2 = obj.pt_obs + Vector(dx: 0.1, dz: 0.15);
      // print("PURPLE: moving with drag to $p2.");
      await app.scene.dragTo(drag, p2, true);
      // print("PURPLE: done with drag.");
      expect(obj.pt_obs, PointMatch(p2)); // Object should have moved to p2.
      await app.teardown();
    });
    testWidgets('Side offset', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("2", TestData.person.data);
      final obj = await app.scene.select(0, side: true);
      final original = Point.from(obj.pt_obs);
      // print("PURPLE: Starting drag at ${obj.pt_obs}.");
      TestGesture drag = await app.scene.dragStart(obj.pt_obs, true);
      Offset delta = Offset(20, 30);
      // print("PURPLE: moving with drag to $p2.");
      await app.scene.dragBy(drag, delta, true);
      await app.scene.dragDone(drag);
      // print("PURPLE: done with drag.");
      expect(obj.pt_obs, isNot(PointMatch(original)));
      await app.teardown();
    });

    testWidgets('Side view click object creation', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.scene.editTool("Add");
      Point targetPoint = Point(x: 0.2, t: 0.0, z: 0.15);
      await app.scene.tap(targetPoint, true);
      final added = app.scene.view!.data.drawables.last;
      expect(added.pt_obs.x, closeTo(targetPoint.x, 1e-3));
      expect(added.pt_obs.z, closeTo(targetPoint.z, 1e-3));
      await app.teardown();
    });

    testWidgets('Side view pan canvas without selection', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      final sideView = find.byKey(const ValueKey("SideView"));
      expect(sideView, findsOneWidget);

      final initialZoom = app.scene.view!.data.transform.zoom;
      final initialOffset = app.scene.view!.data.transform.offset;
      final initialDz = app.scene.view!.data.transform.dz;

      // Vertical drag
      TestGesture gesture = await tester.startGesture(
        tester.getCenter(sideView),
      );
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 30));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(app.scene.view!.data.transform.zoom, closeTo(initialZoom, 1e-3));
      expect(
        app.scene.view!.data.transform.dz,
        isNot(closeTo(initialDz, 1e-3)),
      );

      // Horizontal drag
      gesture = await tester.startGesture(tester.getCenter(sideView));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(app.scene.view!.data.transform.zoom, closeTo(initialZoom, 1e-3));
      expect(
        app.scene.view!.data.transform.offset.dx,
        isNot(closeTo(initialOffset.dx, 1e-3)),
      );

      await app.teardown();
    });

    testWidgets('Side view scroll wheel zoom', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      final sideView = find.byKey(const ValueKey("SideView"));
      expect(sideView, findsOneWidget);

      final initialZoom = app.scene.view!.data.transform.zoom;
      final center = tester.getCenter(sideView);

      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: center,
          scrollDelta: const Offset(0, -100),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        app.scene.view!.data.transform.zoom,
        isNot(closeTo(initialZoom, 1e-3)),
      );
      expect(app.scene.view!.data.transform.zoom.isFinite, isTrue);

      await app.teardown();
    });

    /*
  XXX  test drag/scroll/scale main/side.
    test select when not at center of object.
    deselect and then drag scene.
    - move from random pt to other random pt. should pan.
    - should also pan on side view.
    - write helper to pan side view so that object.z is in range.
    - - maybe that should be part of fit?
    - use two pointers to zoom.
    drag while tool is "add" should also pan.
    */
  });
}
