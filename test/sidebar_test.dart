import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/drawable.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';

import 'app_tester.dart';

void main() {
  group('Sidebar Selection & Update Sync', () {
    testWidgets('Selecting objects updates sidebar properties', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());

      // Add a person and a clock to the scene
      await app.scene.editTool("Add");
      await app.scene.editType(DrawType.person);
      await app.scene.tap(Point(x: -0.5, t: 0.0), false);

      await app.scene.editType(DrawType.clock);
      await app.scene.tap(Point(x: 0.5, t: 0.0), false);

      // Switch to Select tool
      await app.scene.editTool("Select");
      expect(app.scene.view!.selected, null);

      // Select first object (P1)
      final obj1 = await app.scene.select(0, side: false);
      expect(obj1.name, "P1");
      await app.scene.expectName("P1");
      await app.scene.expectType(DrawType.person);

      // Select second object (C2)
      final obj2 = await app.scene.select(1, side: false);
      expect(obj2.name, "C2");
      await app.scene.expectName("C2");
      await app.scene.expectType(DrawType.clock);

      // Deselect
      await app.scene.deselect();
      expect(app.scene.view!.selected, null);
      await app.scene.expectName("-none-");

      await app.teardown();
    });

    testWidgets('Selection sync with identical names', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());

      // Add two objects with identical names
      ReferenceFrame frame1 = ReferenceFrame();
      ReferenceFrame frame2 = ReferenceFrame();
      frame2.center = Point(x: 1.0, t: 0.0);

      Drawable d1 = DrawType.person.make("SameName", frame1, 0);
      Drawable d2 = DrawType.clock.make("SameName", frame2, 2);

      app.scene.view!.data.drawables.addAll([d1, d2]);
      app.scene.view!.updateScene();

      await app.scene.editTool("Select");

      // Select first object
      await app.scene.select(0);
      expect(app.scene.view!.selected, d1);
      await app.scene.expectName("SameName");
      await app.scene.expectType(DrawType.person);
      await app.scene.expectColor(0);

      // Select second object with same name
      await app.scene.select(1);
      expect(app.scene.view!.selected, d2);
      await app.scene.expectName("SameName");
      await app.scene.expectType(DrawType.clock);
      await app.scene.expectColor(2);

      await app.teardown();
    });

    testWidgets(
      'Sidebar property edits sync to selected object and undo/redo',
      (tester) async {
        final app = AppTester(tester);
        await app.setup();
        await app.initialize();
        await app.loadAndFindScene("initial", SceneData());

        // Add object
        await app.scene.editTool("Add");
        await app.scene.tap(Point(x: 0.0, t: 0.0), false);
        final obj = app.scene.view!.data.drawables.last;

        await app.scene.editTool("Select");
        await app.scene.select(0);

        // Edit name from sidebar
        await app.scene.editName("RenamedObj");
        expect(obj.name, "RenamedObj");
        await app.scene.expectName("RenamedObj");

        // Edit type from sidebar
        await app.scene.editType(DrawType.barn);
        expect(app.scene.view!.selected!.type, DrawType.barn);
        await app.scene.expectType(DrawType.barn);

        // Edit color from sidebar
        await app.scene.editColor(3);
        expect(app.scene.view!.selected!.color, 3);
        await app.scene.expectColor(3);

        // Undo color edit
        app.scene.view!.undo_manager.undo();
        await tester.pumpAndSettle();
        await app.scene.expectColor(0);

        // Undo type edit
        app.scene.view!.undo_manager.undo();
        await tester.pumpAndSettle();
        await app.scene.expectType(DrawType.event);

        // Undo name edit
        app.scene.view!.undo_manager.undo();
        await tester.pumpAndSettle();
        await app.scene.expectName("E1");

        await app.teardown();
      },
    );
  });
}
