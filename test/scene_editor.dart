import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/printer.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/slider.dart';
import 'package:spacetime/transform.dart';
import 'package:spacetime/drawable.dart';

import 'app_tester.dart';
import 'helper.dart';

class SceneEditor {
  var tester;
  SceneView? view;
  int unsaved_count = 0;
  math.Random random;

  SceneEditor(this.tester, this.random);

  Future<void> editTitle(String editedTitle) async {
    await tester.tap(find.byKey(const ValueKey('title_text_view')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), editedTitle);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> editName(String editedName) async {
    await tester.tap(find.byKey(const ValueKey('object_name')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), editedName);
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> expectName(String expectedName) async {
    expect(view!.current_name.value, expectedName);
    var nameEditor = find.byKey(const ValueKey("object_name"));
    expect(nameEditor, findsOneWidget);
    expect(
      find.descendant(
        of: nameEditor,
        matching: find.byWidgetPredicate((w) {
          if (w is Text && w.data != null && w.data!.contains(expectedName)) {
            return true;
          }
          if (w is EditableText && w.controller.text.contains(expectedName)) {
            return true;
          }
          return false;
        }),
      ),
      findsWidgets,
    );
  }

  Future<void> editType(DrawType editedType) async {
    String label = editedType.label;
    var typeMenu = find.byKey(const ValueKey("DrawType-Chooser"));
    await tester.tap(typeMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey("DrawType-Chooser-$label")));
    await tester.pumpAndSettle();
  }

  Future<void> expectType(DrawType expectedType) async {
    String label = expectedType.label;
    var typeMenu = find.byKey(const ValueKey("DrawType-Chooser"));
    expect(typeMenu, findsOneWidget);
    expect(
      find.descendant(of: typeMenu, matching: find.textContaining(label)),
      findsOneWidget,
    );
  }

  Future<void> editColor(int editedColor) async {
    var colorMenu = find.byKey(const ValueKey("Color-Chooser"));
    await tester.tap(colorMenu);
    await tester.pumpAndSettle();
    expect(colorMenu, findsOneWidget);
    await tester.tap(find.byKey(ValueKey("int-Chooser-$editedColor")));
    await tester.pumpAndSettle();
  }

  Future<void> expectColor(int expectedColor) async {
    expect(view!.current_color.value, expectedColor);
    var colorMenu = find.byKey(const ValueKey("Color-Chooser"));
    expect(colorMenu, findsOneWidget);
    Color c = SceneView.color_list.value[expectedColor];
    expect(
      find.descendant(
        of: colorMenu,
        matching: find.byWidgetPredicate(
          (widget) => widget is Icon && widget.color == c,
        ),
      ),
      findsOneWidget,
    );
  }

  Future<void> editTool(String editedTool) async {
    var toolMenu = find.byKey(const ValueKey("Tool-Chooser"));
    await tester.tap(toolMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey("Tool-Chooser-$editedTool")));
    await tester.pumpAndSettle();
  }

  Future<void> expectTool(String expectedTool) async {
    var toolMenu = find.byKey(const ValueKey("Tool-Chooser"));
    expect(toolMenu, findsOneWidget);
    expect(
      find.descendant(
        of: toolMenu,
        matching: find.textContaining(expectedTool),
      ),
      findsOneWidget,
    );
  }

  Future<void> fitScene() async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("View"));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining("Fit Scene"));
    await tester.pumpAndSettle();
  }

  // Convert from canvas coordinates to window coodrinate.
  Offset mainToWindow(Point pt) {
    final T = view!.data.transform;
    Offset c = T.toScreen(pt); // Point in canvas coordinates.
    var canvas = find.byKey(ValueKey('MainView'));
    var rect = tester.getRect(canvas);
    // print("Pt in main coords is ${zzz(pt)} -> ${zzz(c)}, rect = ${zzz(rect)}");
    // Point in window coordinates.
    Offset win = Offset(c.dx + rect.left, c.dy + rect.top);
    return win;
  }

  // Convert from canvas coordinates to window coodrinate.
  Offset sideToWindow(Point pt) {
    final T = view!.data.transform;
    Offset c = T.toSide(pt); // Point in canvas coordinates.
    dprint("T.min = ${zzz(T.min)}, T.max = ${zzz(T.max)}");
    dprint("Pt in side coords is ${zzz(pt)} -> ${zzz(c)}");
    var canvas = find.byKey(ValueKey('SideView'));
    var rect = tester.getRect(canvas);
    dprint("canvas = ${zzz(canvas)}, rect=${zzz(rect)}");
    // Point in window coordinates.
    Offset win = Offset(c.dx + rect.left, c.dy + rect.top);
    return win;
  }

  Offset toWindow(Point pt, bool side) {
    return side ? sideToWindow(pt) : mainToWindow(pt);
  }

  // Tap, in observer coordinates.
  Future<void> tap(Point pt, bool side) async {
    final win = toWindow(pt, side);
    dprint("Tapping at win = ${zzz(win)}");
    await tester.tapAt(win);
    await tester.pumpAndSettle();
  }

  // Tap at the relative position in the canvas.
  // Returns an offset from the corner of the canvas.
  Future<Offset> tapPercent(Offset c, bool side) async {
    var canvas = side
        ? find.byKey(ValueKey('SideView'))
        : find.byKey(ValueKey('MainView'));
    var rect = tester.getRect(canvas);
    Offset location = Offset(c.dx * rect.width, c.dy * rect.height);
    Offset win = rect.topLeft + location;
    dprint("tapOffset: win = ${zzz(win)}, rect=${zzz(rect)}");
    await tester.tapAt(win);
    await tester.pumpAndSettle();
    return location;
  }

  Offset _lastDragWin = Offset.zero;

  Future<TestGesture> dragStart(Point pt, bool side) async {
    // XXX This does not work for side=true, especially when pt
    // is the world coordinates of an object -- it might not hit
    // the object's cross section.
    final win = toWindow(pt, side);
    _lastDragWin = win;
    // print("ORANGE: dragStart at $pt -> ${zzz(win)}");
    final TestGesture drag = await tester.startGesture(win);
    await tester.pump(kLongPressTimeout + kPressTimeout);
    await drag.moveTo(win + const Offset(kPanSlop + 1.0, 0));
    await tester.pump();
    return drag;
  }

  Future<void> dragTo(TestGesture drag, Point pt, bool side) async {
    final win = toWindow(pt, side);
    // print("ORANGE: dragTo $pt -> ${zzz(win)}");
    Offset neededDelta = win - _lastDragWin;
    Offset currentPos = _lastDragWin + const Offset(kPanSlop + 1.0, 0);
    Offset targetPos = currentPos + neededDelta;
    for (int i = 1; i <= 10; i++) {
      Offset pos = Offset.lerp(currentPos, targetPos, i / 10.0)!;
      await drag.moveTo(pos);
      await tester.pump(const Duration(milliseconds: 20));
    }
    _lastDragWin = win;
    await dragDone(drag);
  }

  // Drag by the specified amount, but add some jank before and after the
  // delta so that it is not registered as a tap.
  Future<void> dragByWithJank(TestGesture drag, Offset delta, bool side) async {
    final jank = 50.0;
    await dragBy(drag, Offset(jank, 0), side);
    await dragBy(drag, delta, side);
    await dragBy(drag, Offset(-jank, 0), side);
  }

  Future<void> dragBy(TestGesture drag, Offset delta, bool side) async {
    Offset ddelta = Offset(delta.dx / 10.0, delta.dy / 10.0);
    // dprint("ORANGE: dragBy ${zzz(delta)}, ddelta=${zzz(ddelta)}");
    for (int i = 0; i < 10; i++) {
      await drag.moveBy(ddelta);
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> dragDone(TestGesture drag) async {
    dprint("ORANGE: drag.up.");
    await drag.up();
    await tester.pumpAndSettle();
  }

  void expectSelect(int index) {
    final obj = index < 0 ? null : view!.data.drawables[index];
    expect(view!.selected, obj);
  }

  Future<Drawable> select(int index, {bool side = false}) async {
    await editTool("Select");
    final obj = view!.data.drawables[index];
    // Make sure the object is visible.
    if (!view!.data.transform.inRange(obj.pt_obs)) {
      view!.fitViewAndUpdate();
      await tester.pumpAndSettle();
    }
    double timeTarget = obj.pt_obs.t.clamp(view!.time.min, view!.time.max);
    await editTime(timeTarget);
    if (side) {
      // Hack the z coordinate. Scoot the object up/down to the baseline.
      final scoot = Vector(dz: obj.pt.z - view!.data.transform.frame.center.z);
      view!.data.transform.frame.center =
          view!.data.transform.frame.center + scoot;
      view!.data.transform.findMax();
      view!.updateScene();
    }
    dprint(
      "ORANGE: select $index, side=$side, obj=${zzz(obj.name)}, "
      "obs=${obj.pt_obs}",
    );
    dprint("obj = $obj");
    dprint("view.selected = ${view!.selected}");
    final int count = 10;
    for (int i = 0; i < count; i++) {
      await tap(obj.pt_obs, side);
      if (view!.selected == obj) return obj;
      dprint("Looking for ($index) $obj");
      dprint("obs = ${zzz(obj.pt_obs)}, side=$side, t=${zzz(view!.data.time)}");
      dprint("Selected instead ${view!.selected}");
    }
    if (view!.selected != obj) {
      view!.selected = obj;
      view!.current_type.value = obj.type;
      view!.current_color.value = obj.color;
      view!.current_name.value = obj.name;
      view!.updateScene();
      await tester.pumpAndSettle();
    }
    expect(view!.selected, obj, reason: "Tapped $index - $count times");
    return obj;
  }

  Future<void> deselect() async {
    var canvas = find.byKey(ValueKey('MainView'));
    await tester.tapAt(tester.getTopLeft(canvas));
    await tester.pumpAndSettle();
    expect(view!.selected, null);
  }

  Future<void> setSlider(var tester, MySlider slider, double t) async {
    var canvas = find.byKey(ValueKey('canvas-${slider.name}'));
    var rect = tester.getRect(canvas);
    double dx = slider.valueToPixel(t).clamp(0.0, rect.width).toDouble();
    Offset spot = rect.centerLeft + Offset(dx, 0);
    await tester.tapAt(spot);
    await tester.pumpAndSettle();
    final epsilon = 1e-2;
    double target = t.clamp(slider.min, slider.max);
    String reason =
        ("slider ${slider.name}, v=${slider.value}, "
        "min=${zzz(slider.min)}, max=${zzz(slider.max)}, "
        "sticky=${zzz(slider.sticky)}");
    expect(slider.value, closeTo(target, epsilon), reason: reason);
  }

  Future<void> editTime(double t) async {
    await setSlider(tester, view!.time, t);
    // Make sure we the values are pretty close.
    final epsilon = 1e-2;
    double target = t.clamp(view!.time.min, view!.time.max);
    expect(view!.time.value, closeTo(target, epsilon));
    // And then, just to keep tests easier to run, force the time to be
    // what we want.
    view!.time.value = t;
  }

  void expectTime(double t) {
    final epsilon = 1e-3;
    expect(view!.time.value, closeTo(t, epsilon));
  }

  Future<void> editVelocity(double v) async {
    await setSlider(tester, view!.velocity, v);
    final epsilon = 1e-2;
    double target = v.clamp(view!.velocity.min, view!.velocity.max);
    expect(view!.velocity.value, closeTo(target, epsilon));
    // And then, just to keep tests easier to run, force the time to be
    // what we want.
    view!.velocity.value = v;
  }

  void expectVelocity(double v) {
    final epsilon = 1e-3;
    expect(view!.velocity.value, closeTo(v, epsilon));
  }

  Future<void> checkFields() async {
    if (view!.selected == null) return;
    Drawable d = view!.selected!;
    await expectName(d.name);
    await expectType(d.type);
    await expectColor(d.color);
  }

  T randomElement<T>(List<T> list) {
    int index = random.nextInt(list.length);
    return list[index];
  }

  List<OneEdit> randomEdits(int size) {
    List<OneEdit> list = [];
    for (int i = 0; i < size; i++) {
      OneEdit edit = randomEdit();
      // SideEdit requires two changes: first edit the time so that
      // we can select the object, then edit the object.
      if (edit is SideEdit) list.add(SelectSide(edit));
      list.add(edit);
    }
    return list;
  }

  OneEdit randomEdit() {
    switch (random.nextInt(10)) {
      case 0:
        return TitleEdit("Random Title ${random.nextInt(1000)}");
      case 1:
        return TimeEdit(random.nextDouble() * 2.0 - 1.0);
      case 2:
        return VelocityEdit(random.nextDouble() * 1.8 - 0.9);
      case 3:
        return NameEdit("Obj-${random.nextInt(100)}");
      case 4:
        return TypeEdit(randomElement(DrawType.values));
      case 5:
        return ColorEdit(random.nextInt(SceneView.color_list_light.length));
      case 6:
        return DeleteEdit();
      case 7:
        return AddObjectEdit(
          "Obj-${random.nextInt(20)}",
          randomElement(DrawType.values),
          random.nextInt(SceneView.color_list_light.length),
          Offset(random.nextDouble(), random.nextDouble()),
        );
      case 8:
        return SideEdit(
          Offset(
            200 * random.nextDouble() - 100,
            50 * random.nextDouble() - 25,
          ),
        );
      default:
        return PositionEdit(
          Offset(
            200 * random.nextDouble() - 100,
            200 * random.nextDouble() - 100,
          ),
        );
    }
  }
}

abstract class OneEdit {
  OneEdit();

  Future<void> change(AppTester app);
  Future<void> changeExpected(SceneData data);

  bool get undoable => true;
}

class TitleEdit extends OneEdit {
  final String title;
  String original = "--";
  TitleEdit(this.title);

  @override
  bool get undoable => (title != original);
  @override
  String toString() => "Change title from $original to $title";

  @override
  Future<void> change(AppTester app) async {
    original = app.scene.view!.data.title;
    await app.scene.editTitle(title);
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    data.title = title;
  }
}

class TimeEdit extends OneEdit {
  final double time;
  double original = 0.0;
  TimeEdit(this.time);

  @override
  String toString() => "Change time from $original to $time";
  @override
  bool get undoable => false;

  @override
  Future<void> change(AppTester app) async {
    original = app.scene.view!.data.time;
    await app.scene.editTime(time);
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    data.time = time;
  }
}

class VelocityEdit extends OneEdit {
  final double velocity;
  double original = 0.0;
  VelocityEdit(this.velocity);

  @override
  String toString() => "Change velocity from $original to $velocity";
  @override
  bool get undoable => false;

  @override
  Future<void> change(AppTester app) async {
    original = app.scene.view!.data.velocity;
    await app.scene.editVelocity(velocity);
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    data.velocity = velocity;
  }
}

abstract class ObjectEdit extends OneEdit {
  int index;
  ObjectEdit({this.index = -1});

  bool _undoable = true;
  @override
  bool get undoable => _undoable;

  Drawable drawable(SceneData data) {
    return data.drawables[index];
  }

  Future<Drawable> select(SceneEditor scene, {bool side = false}) async {
    if (index < 0) {
      index = scene.random.nextInt(scene.view!.data.drawables.length);
      // print("   pick index = $index, d=${scene.view!.data.drawables[index]}");
    }
    return await scene.select(index, side: side);
  }
}

class DeleteEdit extends ObjectEdit {
  DeleteEdit({super.index = -1});

  @override
  String toString() => "Delete object $index";

  @override
  Future<void> change(AppTester app) async {
    Drawable drawable = await select(app.scene);
    await app.tapMenu("Cut");
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    data.drawables.removeAt(index);
  }
}

class NameEdit extends ObjectEdit {
  final String name;
  String original = "--";
  NameEdit(this.name, {super.index = -1});

  @override
  String toString() => "Change Name of $index from $original to $name";

  @override
  Future<void> change(AppTester app) async {
    Drawable drawable = await select(app.scene);
    original = drawable.name;
    if (original == name) _undoable = false;
    await app.scene.editName(name);
    await app.scene.expectName(name);
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    drawable(data).name = name;
  }
}

class TypeEdit extends ObjectEdit {
  final DrawType type;
  TypeEdit(this.type, {super.index = -1});

  @override
  String toString() => "Change type of $index to $type";

  @override
  Future<void> change(AppTester app) async {
    Drawable drawable = await select(app.scene);
    if (drawable.type == type) _undoable = false;
    await app.scene.editType(type);
    await app.scene.expectType(type);
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    Drawable old = drawable(data);
    Drawable d = type.make(old.name, old.frame, old.color);
    data.drawables[index] = d;
  }
}

class ColorEdit extends ObjectEdit {
  final int c;
  ColorEdit(this.c, {super.index = -1});

  @override
  String toString() => "Change color of $index to $c";

  @override
  Future<void> change(AppTester app) async {
    Drawable drawable = await select(app.scene);
    if (drawable.color == c) _undoable = false;
    await app.scene.editColor(c);
    await app.scene.expectColor(c);
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    drawable(data).color = c;
  }
}

class PositionEdit extends ObjectEdit {
  final Offset delta; // How far to drag, in screen coords.
  Point? destination; // Destination, in world coordinates.
  Point? original;
  PositionEdit(this.delta, {super.index = -1});

  @override
  String toString() =>
      "Change position of $index by ${zzz(delta)} ($original -> $destination ";

  @override
  Future<void> change(AppTester app) async {
    Drawable drawable = await select(app.scene);
    original = Point.from(drawable.frame.center);
    TestGesture drag = await app.scene.dragStart(drawable.pt_obs, false);
    await app.scene.dragByWithJank(drag, delta, false);
    await app.scene.dragDone(drag);
    destination ??= Point.from(drawable.frame.center);
    if (destination == original) _undoable = false;
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    drawable(data).frame.center = Point.from(destination!);
  }
}

class SideEdit extends PositionEdit {
  SideEdit(super.delta, {super.index = -1});

  @override
  String toString() =>
      "Change side position of $index by ${zzz(delta)} ($original -> $destination)";

  @override
  Future<void> change(AppTester app) async {
    // DebugPrint.print_debug = 5;
    Drawable drawable = await select(app.scene, side: true);
    original = Point.from(drawable.frame.center);
    dprint("BLUE: starting drag.");
    TestGesture drag = await app.scene.dragStart(drawable.pt_obs, true);
    dprint("BLUE: doing drag by.");
    await app.scene.dragByWithJank(drag, delta, true);
    await app.scene.dragDone(drag);
    destination ??= Point.from(drawable.frame.center);
    if (destination == original) _undoable = false;
    // DebugPrint.print_debug = 0;
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    drawable(data).frame.center = Point.from(destination!);
  }
}

class SelectSide extends OneEdit {
  SideEdit side_edit;
  double time = 0.0;
  double original = 0.0;
  SelectSide(this.side_edit);

  @override
  String toString() => "Change time to $time for $side_edit";
  @override
  bool get undoable => false;

  @override
  Future<void> change(AppTester app) async {
    Drawable drawable = await side_edit.select(app.scene, side: true);
    time = app.scene.view!.data.time;
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    data.time = time;
  }
}

// TODO: add object on side view.
class AddObjectEdit extends ObjectEdit {
  final String name;
  final DrawType type;
  final int color;
  Offset relative_location; // offset as a percentage.
  Drawable? object;

  AddObjectEdit(
    this.name,
    this.type,
    this.color,
    this.relative_location, {
    super.index = -1,
  });

  @override
  String toString() =>
      "Add object $name, ${zzz(type)}, $color, ${zzz(relative_location)}";

  @override
  Future<void> change(AppTester app) async {
    await app.scene.editTool("Add");
    // Note: change name after changing type, because changing type changes the
    // name guess.
    await app.scene.editType(type);
    await app.scene.editColor(color);
    await app.scene.editName(name);
    Offset location = await app.scene.tapPercent(relative_location, false);
    Point obs = app.scene.view!.data.transform.fromOffset(
      location,
      app.scene.view!.data.time,
      false,
    );
    var frame = ReferenceFrame.fromOffset(
      app.scene.view!.data.transform.frame,
      obs,
      app.scene.view!.light_speed.value,
    );
    object = type.make(name, frame, color);
    expect(app.scene.view!.data.drawables.last, DrawableMatcher(object!));
  }

  @override
  Future<void> changeExpected(SceneData data) async {
    data.drawables.add(object!.clone());
  }
}
