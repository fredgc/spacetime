import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For list compare.

import "axis.dart";
import "edit.dart";
import "drawable.dart";
import "printer.dart";
import 'color.dart';
import 'file_manager.dart';
import 'menus.dart';
import 'mouse.dart';
import 'name.dart';
import 'settings.dart';
import 'slider.dart';
import 'transform.dart';
import 'worker.dart';

enum Tool implements HasShortcut {
  select("Select", SingleActivator(LogicalKeyboardKey.escape, control: false)),
  add("Add", SingleActivator(LogicalKeyboardKey.keyA, control: true));

  const Tool(this.label, this.shortcut);

  final String label;
  @override
  final MenuSerializableShortcut? shortcut;

  @override
  String toString() => label;
}

// All of the data in a scene. This is all the stuff that needs to be saved to a
// file.
class SceneData {
  static String version = "uninitialized";
  String title = "Untitled Drawing"; // or filename?
  String description = "";
  List<Drawable> drawables = [];
  // XXX Do this if the file holder can do realtime updates.
  // ValueNotifier<double> time = ValueNotifier(0.0);
  // ValueNotifier<double> velocity = ValueNotifier(0.0);
  double time = 0.0;
  double velocity = 0.0;
  CoordinateTransform transform = CoordinateTransform();

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;

  bool isLegacy = false;

  SceneData();

  // XXX -- when is this called? In file manager. It owns the current Data.
  void dispose() {
    // Log.widget.log("ORANGE: Dispose of $this.");
    // time.dispose();
    // velocity.dispose();
  }

  Future<void> updateDrawables(
    double t,
    List<double> sticky,
    Interrupter interrupter,
  ) async {
    for (var d in drawables) {
      if (interrupter.stop) return;
      await d.update(transform, t, sticky);
      // time.min, time.max. XXX -- change on resize. or findMax, or scaleUpdate.
      // XXX --need to think about when min/max are updated.
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    SceneData s = other as SceneData;
    return s.title == title &&
        listEquals(s.drawables, drawables) &&
        // time.value == s.time.value &&
        // velocity.value == s.velocity.value &&
        time == s.time &&
        velocity == s.velocity &&
        transform.frame.center == s.transform.frame.center &&
        transform.zoom == s.transform.zoom;
  }

  void verboseCompare(Object other) {
    if (other.runtimeType != runtimeType) {
      Log.errors.log("Wrong types ${other.runtimeType} and $runtimeType");
      return;
    }
    SceneData s = other as SceneData;

    if (s.title != title) Log.errors.log("XXX title: $title != ${s.title}");
    if (time != s.time) Log.errors.log("XXX time ");
    if (velocity != s.velocity) Log.errors.log("XXX velocity ");
    if (transform.frame.center != s.transform.frame.center) {
      Log.errors.log("XXX center ");
    }
    if (transform.zoom != s.transform.zoom) Log.errors.log("XXX zoom");

    if (s.drawables.length != drawables.length) {
      Log.errors.log(
        "XXX length unequal ${s.drawables.length} != ${drawables.length}",
      );
      return;
    }
    for (int i = 0; i < drawables.length; i++) {
      if (s.drawables[i] != drawables[i]) {
        Log.errors.log("XXX $i -> ${zzz(drawables[i])}");
        Log.errors.log("XXX s -> ${zzz(s.drawables[i])}");
        // XXX drawables[i].verboseCompare(s.drawables[i]);
        return;
      }
    }
  }

  @override
  String toString() {
    return "data-$debug_id '$title'";
  }

  void fitView() {
    // find the min and max point for the transform.
    // Change the transform so that min max define the box.
    Log.fit.log("GREEN: t = ${zzz(transform)}");
    Bounds bounds = Bounds(
      Point(x: -1.0, t: -1.0, z: 0.0),
      Point(x: 1.0, t: 1.0, z: 0.0),
    );
    Log.fit.log("initial bounds = ${zzz(bounds)}");
    for (var d in drawables) {
      d.addToBounds(bounds);
      Log.fit.log("world = ${zzz(d.pt)}");
      Log.fit.log("after ${d.name} bounds = ${zzz(bounds)}, ${zzz(d.pt_obs)}");
    }
    transform.fit(bounds);
    Log.fit.log("BLUE: t = ${zzz(transform)}");
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "drawables": drawables,
    "time": time,
    "velocity": velocity,
    "zoom": transform.zoom,
    // Offset to center of view window (relative to size):
    "dx": transform.offset.dx / transform.size.width.toDouble(),
    "dy": transform.offset.dy / transform.size.height.toDouble(),
    "dz": transform.dz,
    "version": version,
  };

  factory SceneData.fromJsonString(String json_string) {
    Log.json.log("json = $json_string");
    Map<String, dynamic> json;
    try {
      json = jsonDecode(json_string);
    } on FormatException catch (e) {
      if (e.offset != null) {
        final before = json_string.substring(0, e.offset!);
        final lines = before.split('\n');
        final lineNumber = lines.length;
        final columnNumber = lines.last.length + 1;
        final allLines = json_string.split('\n');
        final errorLine = allLines[lineNumber - 1];
        final pointer = ' ' * (columnNumber - 1) + '^';
        final message =
            'JSON Syntax Error at line $lineNumber, '
            'column $columnNumber:\n\n'
            '$errorLine\n'
            '$pointer\n\n'
            'Details: ${e.message}';
        Log.json.log("Format exception: $message");
        throw FormatException(message);
      }
      rethrow;
    }
    try {
      return SceneData.fromJson(json);
    } catch (ex1) {
      Log.json.log("RED: $ex1. Trying to parse as legacy save file");
      // Log.json.log(stacktrace);
      try {
        return SceneData.fromJsonLegacy(json);
      } catch (ex2) {
        Log.json.log("RED: $ex2. From the legacy file.");
        // Log.json.log("json_string = $json_string");
        // Log.json.log("json = $json");
        // Log.json.log(stacktrace2);
        throw ex1; // Use the first exception to show the user.
      }
    }
  }

  factory SceneData.fromJson(Map<String, dynamic> json) {
    String version = json['version'] ?? "old";
    Log.json.log("Version was $version");
    SceneData scene = SceneData();
    scene.title = json["title"] ?? "Untitled Drawing";
    scene.description = json["description"] ?? "";
    scene.time = (json["time"] as num?)?.toDouble() ?? 0.0;
    scene.velocity = (json["velocity"] as num?)?.toDouble() ?? 0.0;
    scene.transform.zoom = (json["zoom"] as num?)?.toDouble() ?? 1.0;
    double dx = (json["dx"] as num?)?.toDouble() ?? 0.5;
    double dy = (json["dy"] as num?)?.toDouble() ?? 0.5;
    scene.transform.offset = Offset(
      dx * scene.transform.size.width,
      dy * scene.transform.size.height,
    );
    scene.transform.dz = (json["dz"] as num?)?.toDouble() ?? 10.0;

    if (json["drawables"] != null) {
      if (json["drawables"] is List) {
        final l = (json["drawables"] as List).cast<Map<String, dynamic>>();
        scene.drawables = l
            .map<Drawable>((json) => Drawable.fromJson(json))
            .toList();
      } else {
        throw const FormatException("drawables is not a List");
      }
    }
    return scene;
  }

  factory SceneData.fromJsonLegacy(Map<String, dynamic> json) {
    // TODO: don't load if there are errors.
    SceneData scene = SceneData();
    scene.isLegacy = true;
    scene.title = "Untitled Drawing";
    scene.time = (json["time"] as num?)?.toDouble() ?? 0.0;
    scene.velocity = (json["velocity"] as num?)?.toDouble() ?? 0.0;
    scene.transform.frame.center = Point(
      x: (json["center_x"] as num?)?.toDouble() ?? 0.0,
      t: (json["center_t"] as num?)?.toDouble() ?? 0.0,
    );
    scene.transform.zoom = 1.0 / json["scale"];
    // Turn the json drawables into a list of json maps.
    final drawables = json["drawables"]["list"];
    final list = (drawables as List).cast<Map<String, dynamic>>();
    Log.json.log("Found ${list.length} drawables.");
    // Turn each element in the list to a drawable.
    scene.drawables = list
        .map<Drawable>((json) => Drawable.fromJsonLegacy(json))
        .toList();
    Log.json.log("Parsed legacy scene");
    scene.fitView();
    return scene;
  }
}

// A view of the scene. This holds the data, an undo manager, and some sliders
// for the current time and velocity.
class SceneView {
  final Settings settings;
  SceneData data;
  MyUndoManager undo_manager = MyUndoManager();
  FileManager file_manager;
  MySlider time = MySlider("Time", -2.0, 2.0, 0.0);
  MySlider velocity = MySlider(
    "Velocity",
    -0.999,
    0.999,
    0.0,
    allow_animate: false,
  );
  PlotAxis x_axis = PlotAxis(vertical: false);
  PlotAxis t_axis = PlotAxis(vertical: true);
  RadioChooser<LightSpeed> light_speed = RadioChooser(
    LightSpeed.values,
    tooltip: (choice) => choice.tip,
  );
  ListChooser<Tool> current_tool = ListChooser(Tool.values);
  ListChooser<DrawType> current_type = ListChooser(DrawType.values);
  NameGuess guess = NameGuess();
  ValueNotifier<String> current_name = ValueNotifier("-none-");
  ListChooser<int> current_color = RangeChooser(
    SceneView.color_list.value.length,
    key: ValueKey("Color-Chooser"),
    makeIcon: (int i) =>
        Icon(Icons.palette, color: SceneView.color_list.value[i]),
    tooltip: (int i) => "Select color $i of object",
    message: "Select color of object.",
  );
  MouseListener? main_listener;
  MouseListener? side_listener;

  VoidCallback? startAnimation;
  ValueNotifier<int> repaint_counter = ValueNotifier<int>(0);
  // A value notifier that only notifies when the time slider's value
  // changes. It does not notify when the slider's sticky points change. This is
  // used so that a file is not marked as "unsaved" whenever the window changes
  // size.
  ValueNotifier<double> time_buffer = ValueNotifier<double>(0.0);

  // Managers updating the scene when there are multiple requests.
  late Worker worker;

  Drawable? selected;

  int paint_counter = 0;
  int side_paint_counter = 0;
  int build_counter = 0;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString() => "viewer-$debug_id ($data)";

  SceneView(this.file_manager, this.settings, this.data) {
    // XXX update time and other stuff so that from scene data.
    // Log.widget.log("ORANGE: Creating new SceneView for $data.");
    // Log.widget.log("$this has slider $time and $velocity");
    time.value = data.time;
    time_buffer.value = data.time;
    velocity.value = data.velocity;
    // Log.widget.log("done with initializing time and velocity from data.");
    // time.addListener(() {
    //   Log.widget.log("FDGC: time value for $this changed to ${time.value}");
    // });
    // velocity.addListener(() {
    //   Log.widget.log("FDGC: velocity value for $this changed to ${velocity.value}");
    // });
    // Log.widget.log("done adding listeners.");
    // initScene(); //XXX change this back.
    worker = Worker<bool, List<double>>(updateDrawables, updateSticky);
    updateScene(triggerRepaint: false);
    // Log.widget.log("done with initScene.");

    time.addListener(() {
      time_buffer.value = time.value;
      data.time = time.value;
    }); // XXX dispose of this?
    time.addListener(requestRepaintScene); // XXX dispose of this?
    time_buffer.addListener(file_manager.maybeChange); //XXX dispose?
    velocity.addListener(updateScene); //XXX dispose of this?
    velocity.addListener(file_manager.maybeChange);
    undo_manager.addListener(() {
      if (undo_manager.isUnsaved) {
        file_manager.change();
      } else if (file_manager.unsaved.value) {
        file_manager.unsaved.value = false;
      }
    });
    setupEdits();
    file_manager.clearUnsaved();
    velocity.addListener(() => data.velocity = velocity.value);
    // Log.widget.log("ORANGE: Done creating $this.");
  }

  static SavableColor time_slice_color = SavableColor(
    "time_slice_color",
    "Time Slice",
    Colors.yellow,
    (scheme) => scheme.secondary,
  );
  static SavableColor axis_color = SavableColor(
    "axis_color",
    "Axis",
    Colors.yellow,
    (scheme) => scheme.tertiary,
  );
  static SavableColor select_color = SavableColor(
    "select_color",
    "Selected",
    Colors.yellow,
    (scheme) => (scheme.brightness == Brightness.light)
        ? Colors.yellow.shade900
        : Colors.yellow.shade300,
  );

  // XXX Legacy colors had 16 choices.
  static final List<Color> color_list_dark = [
    Colors.black,
    Colors.purple.shade900,
    Colors.blue.shade900,
    Colors.teal.shade900,
    Colors.cyan.shade900,
    Colors.green.shade900,
    Colors.orange.shade900,
    Colors.red.shade900,
    Colors.brown.shade900,
  ];
  static final List<Color> color_list_light = [
    Colors.white,
    Colors.purple.shade300,
    Colors.blue.shade300,
    Colors.teal.shade300,
    Colors.cyan.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.red.shade300,
    Colors.brown.shade300,
  ];

  static SavableColorArray color_list = SavableColorArray(
    "color_list",
    "Object Colors",
    color_list_light,
    (scheme) => (scheme.brightness == Brightness.light)
        ? List.from(color_list_dark)
        : List.from(color_list_light),
  );

  static SavableBool use_debug_rect = SavableBool(
    "debug_rect",
    "Draw a debug rect for clipping",
    false,
    debug_only: true,
  );
  static SavableDouble fade_time = SavableDouble(
    "fade_time",
    "Fade Time (normalized time)",
    0.05,
    tip: "How much world time an event shows up in the side view.",
  );
  static SavableDouble dot_size = SavableDouble(
    "dot_size",
    "Dot Size",
    5.0,
    tip: "How big an event circle is, in pixels.",
  );
  static SavableBool show_clock_time = SavableBool(
    "show_clock_time",
    "Show Clock Time in Side View",
    true,
  );
  static SavableBool show_gridlines = SavableBool(
    "show_gridlines",
    "Show Gridlines",
    false,
    tip: "Display gridlines in main canvas and side observer view.",
  );
  static SavableDouble line_width = SavableDouble(
    "line_width",
    "Line Width",
    1.5,
    tip: "Line width used when drawing objects and axes.",
  );

  static void initSettings(Settings settings) {
    settings.add(time_slice_color);
    settings.add(axis_color);
    settings.add(select_color);
    settings.add(color_list);
    settings.add(EndOfGroup());
    settings.add(fade_time);
    settings.add(dot_size);
    settings.add(show_clock_time);
    settings.add(show_gridlines);
    settings.add(line_width);
    MySlider.initSettings(settings);
  }

  static void initDebugSettings(Settings settings) {
    settings.add(use_debug_rect);
  }

  void dispose() {
    // Log.widget.log("ORANGE: Dispose of SceneView.");
    // XXX scene.dispose();
  }

  void updateSettings() {
    Log.widget.log("BLUE: Scene update settings.");
    x_axis.color = axis_color.value;
    t_axis.color = axis_color.value;
    updateScene(triggerRepaint: true);
    requestRepaintScene();
  }

  void clearScene() {
    Log.widget.log("BLUE: Clear Scene list.");
    final oldTransform = data.transform;
    final oldDrawables = data.drawables;
    undo_manager.add(
      UndoCallback(
        "Clear Scene.",
        undoCallback: () {
          data.drawables = oldDrawables;
          data.transform = oldTransform;
          updateScene();
          file_manager.change();
        },
        redoCallback: () {
          selected = null;
          undo_manager.rebuildMenu();
          data.drawables = [];
          data.transform = CoordinateTransform();
          data.transform.resize(oldTransform.size);
          updateScene();
          file_manager.change();
        },
      ),
    );
    // Log.update.log("After update list. repaint counter = ${repaint_counter}, $this");
  }

  // This is called to update the time from the animator.
  bool updateTime(double dt) {
    // Log.update.log("BLUE: updateTime. $this");
    bool changed = time.updateTime(dt);
    // bool changed = transform.updateTime(dt);
    // if (slice != null) {
    //   changed |= slice!.updateTime(dt);
    // }
    if (changed) {
      requestRepaintScene();
      file_manager.change();
    }
    return changed;
  }

  // This is called whenever the velocity changes, or the window size changes.
  // It is not called if only the time changes.
  void updateScene({bool triggerRepaint = true}) {
    worker.trigger(triggerRepaint);
  }

  // This is called to update all the drawables, but it might
  // be interrupted if
  Future<List<double>?> updateDrawables(
    bool triggerRepaint,
    Interrupter interrupter,
  ) async {
    List<double> sticky = [];
    data.transform.frame.velocity = velocity.value;
    x_axis.resize(data.transform);
    t_axis.resize(data.transform);
    sticky = [data.transform.min.t, data.transform.max.t];
    await data.updateDrawables(time.value, sticky, interrupter);
    return sticky;
  }

  Future<void> updateSticky(bool triggerRepaint, List<double> sticky) async {
    time.setSticky(sticky);
    time.min = data.transform.min.t;
    time.max = data.transform.max.t;
    if (triggerRepaint) requestRepaintScene();
  }

  // This paints the main canvas, not the time slice canvas.
  void paint(Canvas canvas, Size size) {
    // Log.update.log("paint $this.");
    // if (scene.transform.sizeChanged(size)) {
    //   Log.update.log("updating scene with resize.");
    //   scene.transform.resize(size);
    //   updateScene(triggerRepaint: false);
    //   Log.update.log("finished updating scene with resize.");
    // }
    paint_counter++;
    if (use_debug_rect.value) {
      Offset ll = data.transform.toScreen(data.transform.min);
      Offset ur = data.transform.toScreen(data.transform.max);
      canvas.drawRect(
        Rect.fromLTRB(ll.dx, ur.dy, ur.dx, ll.dy),
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke,
      );
    }
    // XXX paint time bar.  settings needs a time bar color.
    Offset c1 = data.transform.toScreen(
      Point(t: time.value, x: data.transform.min.x),
    );
    Offset c2 = data.transform.toScreen(
      Point(t: time.value, x: data.transform.max.x),
    );
    Paint paint = Paint()
      ..color = time_slice_color.value
      ..style = PaintingStyle.stroke;
    canvas.drawLine(c1, c2, paint);
    for (var d in data.drawables) {
      d.paint(canvas, data.transform, d == selected);
    }
    if (Settings.kDebugEnabled && Settings.debugEnabled) {
      paintTimeText(canvas, size);
    }
  }

  // Paint the time slice canvas.
  void paintSideView(Canvas canvas, Size size) {
    // Log.update.log("side paint $this.");
    side_paint_counter++;
    // XXX -- this was commented out for a while. why?
    data.transform.sideHeight = size.height;
    // var paint = Paint()
    //   ..color = Colors.white
    //   // ..strokeWidth = 5
    //   ..style = PaintingStyle.stroke
    //   ..strokeCap = StrokeCap.round;
    // // Not showing up.
    // canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    // canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
    for (var d in data.drawables) {
      d.paintSide(canvas, data.transform, time.value, d == selected);
    }
    // Log.update.log("Decrement debug print ${DebugPrint.print_debug}.");
    // DebugPrint.print_debug--;
  }

  void paintTimeText(Canvas canvas, Size size) {
    final style = TextStyle(
      color: settings.theme.scheme.onSurface,
      fontSize: 10.0,
    );
    String text =
        "count=${data.drawables.length}, selected=${selected?.name}"
            "\n"
            "isWeb=$kIsWeb, "
            "${settings.no_keyboard ? 'no' : 'with'} keyboard, "
            "t=${zzz(time.value)}, v = ${zzz(velocity.value)}/"
            "${zzz(data.transform.frame.velocity)}.  "
            "\n"
            "paint=$paint_counter/${repaint_counter.value}, "
            "sp=$side_paint_counter, "
            "b$build_counter #=${data.drawables.length}, "
            "unsaved=${file_manager.unsaved.value}, " +
        "uc=${undo_manager.undoList.length}, rc=${undo_manager.redoList.length}, ";
    var span = TextSpan(text: text, style: style);
    var painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    painter.layout();
    Offset offset = Offset(
      size.width - painter.width - 5,
      size.height - painter.height - 5,
    );
    painter.paint(canvas, offset);
  }

  void requestRepaintScene() {
    // Log.update.log("Request repaint $this.");
    repaint_counter.value++;
    // Log.update.log("Done request repaint $this.");
  }

  String debugPrint() {
    return "sc(r${repaint_counter.value}p$paint_counter/$side_paint_counter,b$build_counter) ";
  }

  void dumpDebugInfo() {
    Log.dump.log("GREEN: ---- dumping debug info -----");
    Log.dump.log("this = $this, name = ${current_name.value}");
    Log.dump.log(data.transform.dumpDebugInfo());
    Log.dump.log("Data.Drawables:");
    for (var d in data.drawables) {
      d.dumpDebugInfo();
    }
    requestRepaintScene();
    undo_manager.dumpList();
  }

  Widget buildSideView(BuildContext context, State state) {
    build_counter++;
    side_listener ??= MouseListener(this, true);
    return side_listener!.build(
      context,
      CustomPaint(
        key: ValueKey("SideView"),
        foregroundPainter: SideViewPainter(
          scene_viewer: this,
          repaint: repaint_counter,
        ),
        painter: SideAxisPainter(
          data.transform,
          axis_color.value,
          x_axis,
          t_axis,
        ),
        child: Container(),
      ),
    );
  }

  Widget build(BuildContext context, State state) {
    build_counter++;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        data.transform.resize(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        updateScene(triggerRepaint: false);
        main_listener ??= MouseListener(this, false);
        return main_listener!.build(
          context,
          CustomPaint(
            key: ValueKey("MainView"),
            foregroundPainter: ScenePainter(
              scene_viewer: this,
              repaint: repaint_counter,
            ),
            painter: AxisPainter(
              data.transform,
              axis_color.value,
              x_axis,
              t_axis,
            ),
            child: Container(),
          ),
        );
      },
    );
  }

  // Return true if the widget state should be updated.
  // That happens when the current tool changes.
  bool keyHandle(String? character, LogicalKeyboardKey key) {
    // Log.keys.log("Key Handle: character = '$character'");
    if (character == " ") {
      Log.keys.log("Character Space. Pause. $this");
      stopMovement();
    }
    if (character == "-") {
      Log.keys.log("slow. $this");
      // XXX use scene_viewer.time.speed_delta?
      time.incrementSpeed(-1.0);
    }
    if ((character == "=") || (character == "+")) {
      Log.keys.log("fast. $this");
      // XXX
      time.incrementSpeed(1.0);
    }
    if (key == LogicalKeyboardKey.escape) {
      if (selected != null) undo_manager.rebuildMenu();
      selected = null;
    }
    return false;
  }

  void stopMovement() {
    // XXX not used?
    Log.keys.log("Stop movement.");
    time.setSpeed(0);
  }

  void addObject(Point obs) {
    ReferenceFrame frame = ReferenceFrame.fromOffset(
      data.transform.frame,
      obs,
      light_speed.value,
    );
    Log.objects.log("Current name = ${current_name.value}");
    final Drawable d = current_type.value.make(
      current_name.value,
      frame,
      current_color.value,
    );
    // Log.objects.log("Add object: $d");
    undo_manager.add(
      UndoCallback(
        "Add ${d.name}",
        undoCallback: () {
          if (selected == data.drawables.last) {
            undo_manager.rebuildMenu();
            selected = null;
          }
          data.drawables.removeLast();
          updateScene();
          file_manager.change();
        },
        redoCallback: () {
          data.drawables.add(d);
          updateScene();
          file_manager.change();
        },
      ),
    );
    String old = guess.name;
    guess.increment();
    Log.objects.log("guess, inc '$old' to '${guess.name}'");
    current_name.value = guess.name;
  }

  /* If this is not a repeat, just find the closest object.
  If this is a repeat, then find the closest object that is not any closer than the current selected.
  */
  void selectClosest(Point obs, bool side, bool repeat) {
    Log.select.log(
      "selectClosest. obs = ${zzz(obs)}, side=$side, repeat=$repeat",
    );
    final double maxDist = dot_size.value / data.transform.zoom;
    double minDist = 0.0;
    if (repeat && selected != null) {
      minDist = selected!.distance(obs, side);
    }
    Log.select.log("min_dist = ${zzz(minDist)}, max=${zzz(maxDist)}");
    double closestDist = maxDist;
    Drawable? closest;
    for (Drawable d in data.drawables) {
      // Move up here just for debugging.
      double distance = d.distance(obs, side);
      Log.select.log(
        "  dist=${zzz(distance)}, obs=${zzz(d.pt_obs)}, name=${d.name}",
      );
      if (repeat && d == selected) {
        Log.select.log("Skipping $d because it is already selected.");
        continue;
      }
      // XXX double distance = d.distance(obs, side);
      if ((distance < closestDist) && (distance >= minDist)) {
        Log.select.log(
          "    GREEN: new closest ${d.name} (was ${closest?.name}) prev d = ${zzz(closestDist)}",
        );
        closest = d;
        closestDist = distance;
      } else if (distance < closestDist) {
        Log.select.log("  YELLOW: too close. min = ${zzz(minDist)}");
      }
    }
    Log.select.log(
      "Click hit $closest, dist = ${zzz(closestDist)}, "
      "max=${zzz(maxDist)}, r=${zzz(closestDist / maxDist)}",
    );
    setSelected(closest);
    requestRepaintScene();
  }

  void setSelected(Drawable? closest) {
    if (closest == selected) return;
    Log.select.log("GREEN: Selecting $closest");
    bool wasEmpty = (selected == null);
    // Set current selected to null so that the following changes to name, type,
    // etc do not also change the values for the previous selected.
    selected = null;
    if (closest == null) {
      current_name.value = "-none-";
      if (!wasEmpty) undo_manager.rebuildMenu();
      return;
    }
    current_type.value = closest.type;
    current_color.value = closest.color;
    current_name.value = closest.name;
    Log.select.log("select to current name = ${current_name.value}");
    selected = closest;
    // Check to see if the edit menu items copy/cut/paste need to change their
    // enabled bits.
    if (wasEmpty != (selected == null)) undo_manager.rebuildMenu();

    // selected?.dumpDebugInfo();
  }

  // Returns the point if it is near the selected object, or null if it is not.
  // The point is in observer coordinates.
  Point? nearSelected(Offset screen, bool side) {
    if (selected == null) return null;
    final double maxDist = dot_size.value / data.transform.zoom;
    Point pt = data.transform.fromOffset(screen, time.value, side);
    // Log.select.log("near screen=${zzz(screen)} -> ${zzz(pt)}");
    // Log.select.log("  selected: $selected");
    double d = selected!.distance(pt, side);
    // Log.select.log("  XXX dist=${zzz(d)}, max=${zzz(max_dist)}, r=${zzz(d / max_dist)}");
    if (selected != null && (selected!.distance(pt, side) <= maxDist)) {
      return pt;
    }
    return null;
  }

  // Updates the zoom of the current data.transform, and pans old point to
  // new point.
  void doScale(Offset pt1, Offset pt2, double zoom, bool side) {
    data.transform.doScale(pt1, pt2, zoom, side);
    x_axis.resize(data.transform);
    t_axis.resize(data.transform);
    time.min = data.transform.min.t;
    time.max = data.transform.max.t;
    updateScene();
  }

  void onTap(Offset screen, bool side, bool repeat) {
    Point obs = data.transform.fromOffset(screen, time.value, side);
    Log.select.log(
      "BLUE: scene onTap ${zzz(screen)} -> ${zzz(obs)}, tool=${current_tool.value}.",
    );
    switch (current_tool.value) {
      case Tool.add:
        addObject(obs);
        break;
      case Tool.select:
        selectClosest(obs, side, repeat);
        break;
    }
  }

  void fitViewAndUpdate() {
    data.fitView();
    updateScene();
  }

  void setupEdits() {
    current_tool.addListener(() {
      Log.objects.log("Current tool is now ${current_tool.value}");
      switch (current_tool.value) {
        case Tool.select:
          break;
        case Tool.add:
          // When the tool changes to 'add', deselect current item and
          // update the name guess.
          selected = null;
          undo_manager.rebuildMenu();
          guess.prefix = current_type.value.prefix;
          for (var d in data.drawables) {
            guess.riseAbove(d.name);
          }
          // XXX guess.increment()?
          Log.objects.log(
            "BLUE: Tool name from ${current_name.value} to ${guess.name}",
          );
          current_name.value = guess.name;
          break;
      }
    });
    current_type.addListener(() {
      guess.prefix = current_type.value.prefix;
      if (selected != null) {
        final int index = data.drawables.indexOf(selected!);
        Log.objects.log("Current type changed for index $index.");
        Drawable old = selected!;
        if (current_type.value != old.type) {
          Drawable d = current_type.value.make(old.name, old.frame, old.color);
          undo_manager.add(
            Change<Drawable>("Type", old, d, (v) {
              Log.objects.log("do/undo type change for $index to $v.");
              bool changeSelected = (data.drawables[index] == selected);
              data.drawables[index] = v;
              if (changeSelected) {
                selected = v;
                current_type.value = v.type;
              }
              updateScene();
              file_manager.change();
            }),
          );
        }
      } else {
        Log.objects.log("type changed. change name to ${guess.name}");
        current_name.value = guess.name;
      }
    });
    current_color.addListener(() {
      Log.objects.log(
        "YELLOW: current_color was set to ${current_color.value}",
      );
      if (selected != null) {
        final drawable = selected!;
        if (drawable.color == current_color.value) {
          Log.objects.log("Color did not change (${drawable.color}).");
          return;
        }
        Log.objects.log(
          "Current color changed to ${drawable.color} (with selected).",
        );
        undo_manager.add(
          Change<int>("Color", drawable.color, current_color.value, (v) {
            Log.objects.log("YELLOW: do/undo color change to $v.");
            drawable.color = v;
            if (identical(drawable, selected)) current_color.value = v;
            requestRepaintScene();
            file_manager.change();
          }),
        );
      }
    });
    current_name.addListener(() {
      Log.objects.log(
        "name changed. guess ${guess.name} to ${current_name.value}",
      );
      guess.name = current_name.value;
      if (selected != null) {
        final drawable = selected!;
        if (drawable.name == current_name.value) {
          // Log.objects.log("Name did not change (${drawable.name}).");
          return;
        }
        Log.objects.log(
          "Current name changed from ${drawable.name} to ${current_name.value}.",
        );
        final String oldName = drawable.name;
        drawable.name = current_name.value;
        undo_manager.add(
          Change<String>("Name", oldName, current_name.value, (v) {
            Log.undo.log("do/undo name change to $v.");
            drawable.name = v;
            if (identical(drawable, selected)) current_name.value = v;
            requestRepaintScene();
            file_manager.change();
          }),
        );
      }
    });
    light_speed.addListener(() {
      Log.objects.log("Light speed is now ${light_speed.value}");
      data.transform.lightSpeed = light_speed.value;
      updateScene();
    });
  }

  void delete() {
    // Log.objects.log("delete. $selected");
    if (selected == null) return;
    final int index = data.drawables.indexOf(selected!);
    final Drawable d = selected!;
    undo_manager.add(
      UndoCallback(
        "Delete ${d.name} at $index",
        undoCallback: () {
          data.drawables.insert(index, d);
          updateScene();
          file_manager.change();
        },
        redoCallback: () {
          if (selected == data.drawables[index]) {
            selected = null;
          }
          data.drawables.removeAt(index);
          updateScene();
          file_manager.change();
        },
      ),
    );
  }

  void cut() {
    copy();
    delete();
  }

  void copy() {
    var encoder = JsonEncoder.withIndent("  ");
    String text = encoder.convert(selected);
    Clipboard.setData(ClipboardData(text: text));
  }

  void paste() async {
    ClipboardData? scene = await Clipboard.getData(Clipboard.kTextPlain);
    if (scene == null || scene.text == null) {
      Log.files.log("Empty clipboard");
      return;
    }
    String text = scene.text!;
    Log.files.log("Paste $text");
    // XXX var json_map = jsonDecode(text);
    //     XXX do what?
    // XXX    data.drawables = l.map<Drawable>((json) => Drawable.fromJson(json)).toList();
  }

  // XXX clearAll(). addObject(Drawable). from chaos.

  // -------------------------------------------------
  // ------- json save/load stuff. -------------------
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    SceneView s = other as SceneView;
    return data == s.data;
  }
}

class ScenePainter extends CustomPainter {
  SceneView scene_viewer;
  ScenePainter({required this.scene_viewer, repaint}) : super(repaint: repaint);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    bool should = (this != oldDelegate);
    return should;
  }

  @override
  void paint(Canvas canvas, Size size) {
    scene_viewer.paint(canvas, size);
  }
}

class SideViewPainter extends CustomPainter {
  SceneView scene_viewer;
  SideViewPainter({required this.scene_viewer, repaint})
    : super(repaint: repaint);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    bool should = (this != oldDelegate);
    return should;
  }

  @override
  void paint(Canvas canvas, Size size) {
    scene_viewer.paintSideView(canvas, size);
  }
}
