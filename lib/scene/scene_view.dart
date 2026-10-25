import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../axis.dart';
import '../color.dart';
import '../drawable.dart';
import '../edit.dart';
import '../file_manager.dart';
import '../menus.dart';
import '../mouse.dart';
import '../name.dart';
import '../printer.dart';
import '../settings.dart';
import '../slider.dart';
import '../transform.dart';
import '../worker.dart';
import 'scene_data.dart';
import 'scene_painters.dart';

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

// A view of the scene. This holds the data, an undo manager, and some sliders
// for the current time and velocity.
class SceneView {
  final Settings settings;
  SceneData data;
  MyUndoManager undoManager = MyUndoManager();
  FileManager fileManager;
  MySlider time = MySlider("Time", -2.0, 2.0, 0.0);
  MySlider velocity = MySlider(
    "Velocity",
    -0.999,
    0.999,
    0.0,
    allowAnimate: false,
  );
  PlotAxis xAxis = PlotAxis(vertical: false);
  PlotAxis tAxis = PlotAxis(vertical: true);
  RadioChooser<LightSpeed> lightSpeed = RadioChooser(
    LightSpeed.values,
    tooltip: (choice) => choice.tip,
  );
  ListChooser<Tool> currentTool = ListChooser(Tool.values);
  ListChooser<DrawType> currentType = ListChooser(DrawType.values);
  NameGuess guess = NameGuess();
  ValueNotifier<String> currentName = ValueNotifier("-none-");
  ListChooser<int> currentColor = RangeChooser(
    SceneView.colorList.value.length,
    key: const ValueKey("Color-Chooser"),
    makeIcon: (int i) =>
        Icon(Icons.palette, color: SceneView.colorList.value[i]),
    tooltip: (int i) => "Select color $i of object",
    message: "Select color of object.",
  );
  MouseListener? _mainListener;
  MouseListener? _sideListener;

  VoidCallback? startAnimation;
  ValueNotifier<int> repaintCounter = ValueNotifier<int>(0);
  // A value notifier that only notifies when the time slider's value
  // changes. It does not notify when the slider's sticky points change. This is
  // used so that a file is not marked as "unsaved" whenever the window changes
  // size.
  final ValueNotifier<double> _timeBuffer = ValueNotifier<double>(0.0);

  // Managers updating the scene when there are multiple requests.
  late Worker worker;

  Drawable? selected;

  int paintCounter = 0;
  int sidePaintCounter = 0;
  int _buildCounter = 0;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString() => "viewer-$_debugId ($data)";

  SceneView(this.fileManager, this.settings, this.data) {
    // XXX update time and other stuff so that from scene data.
    // Log.widget.log("ORANGE: Creating new SceneView for $data.");
    // Log.widget.log("$this has slider $time and $velocity");
    time.value = data.time;
    _timeBuffer.value = data.time;
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
      _timeBuffer.value = time.value;
      data.time = time.value;
    }); // XXX dispose of this?
    time.addListener(requestRepaintScene); // XXX dispose of this?
    _timeBuffer.addListener(fileManager.maybeChange); //XXX dispose?
    velocity.addListener(updateScene); //XXX dispose of this?
    velocity.addListener(fileManager.maybeChange);
    undoManager.addListener(() {
      if (undoManager.isUnsaved) {
        fileManager.change();
      } else if (fileManager.unsaved.value) {
        fileManager.unsaved.value = false;
      }
    });
    setupEdits();
    fileManager.clearUnsaved();
    velocity.addListener(() => data.velocity = velocity.value);
    // Log.widget.log("ORANGE: Done creating $this.");
  }

  static SavableColor timeSliceColor = SavableColor(
    "time_slice_color",
    "Time Slice",
    Colors.yellow,
    (scheme) => scheme.secondary,
  );
  static SavableColor axisColor = SavableColor(
    "axis_color",
    "Axis",
    Colors.yellow,
    (scheme) => scheme.tertiary,
  );
  static SavableColor selectColor = SavableColor(
    "select_color",
    "Selected",
    Colors.yellow,
    (scheme) => (scheme.brightness == Brightness.light)
        ? Colors.yellow.shade900
        : Colors.yellow.shade300,
  );

  // XXX Legacy colors had 16 choices.
  static final List<Color> colorListDark = [
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
  static final List<Color> colorListLight = [
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

  static SavableColorArray colorList = SavableColorArray(
    "color_list",
    "Object Colors",
    colorListLight,
    (scheme) => (scheme.brightness == Brightness.light)
        ? List.from(colorListDark)
        : List.from(colorListLight),
  );

  static SavableBool useDebugRect = SavableBool(
    "debug_rect",
    "Draw a debug rect for clipping",
    false,
    debugOnly: true,
  );
  static SavableDouble fadeTime = SavableDouble(
    "fade_time",
    "Fade Time (normalized time)",
    0.05,
    tip: "How much world time an event shows up in the side view.",
  );
  static SavableDouble dotSize = SavableDouble(
    "dot_size",
    "Dot Size",
    5.0,
    tip: "How big an event circle is, in pixels.",
  );
  static SavableBool showClockTime = SavableBool(
    "show_clock_time",
    "Show Clock Time in Side View",
    true,
  );
  static SavableBool showGridlines = SavableBool(
    "show_gridlines",
    "Show Gridlines",
    false,
    tip: "Display gridlines in main canvas and side observer view.",
  );
  static SavableDouble lineWidth = SavableDouble(
    "line_width",
    "Line Width",
    1.5,
    tip: "Line width used when drawing objects and axes.",
  );

  static void initSettings(Settings settings) {
    settings.add(timeSliceColor);
    settings.add(axisColor);
    settings.add(selectColor);
    settings.add(colorList);
    settings.add(EndOfGroup());
    settings.add(fadeTime);
    settings.add(dotSize);
    settings.add(showClockTime);
    settings.add(showGridlines);
    settings.add(lineWidth);
    MySlider.initSettings(settings);
  }

  static void initDebugSettings(Settings settings) {
    settings.add(useDebugRect);
  }

  void dispose() {
    // Log.widget.log("ORANGE: Dispose of SceneView.");
    // XXX scene.dispose();
  }

  void updateSettings() {
    Log.widget.log("BLUE: Scene update settings.");
    xAxis.color = axisColor.value;
    tAxis.color = axisColor.value;
    updateScene(triggerRepaint: true);
    requestRepaintScene();
  }

  void clearScene() {
    Log.widget.log("BLUE: Clear Scene list.");
    final oldTransform = data.transform;
    final oldDrawables = data.drawables;
    undoManager.add(
      UndoCallback(
        "Clear Scene.",
        undoCallback: () {
          data.drawables = oldDrawables;
          data.transform = oldTransform;
          updateScene();
          fileManager.change();
        },
        redoCallback: () {
          selected = null;
          undoManager.rebuildMenu();
          data.drawables = [];
          data.transform = CoordinateTransform();
          data.transform.resize(oldTransform.size);
          updateScene();
          fileManager.change();
        },
      ),
    );
    // Log.update.log("After update list. repaint counter = ${repaintCounter}, $this");
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
      fileManager.change();
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
    xAxis.resize(data.transform);
    tAxis.resize(data.transform);
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
    paintCounter++;
    if (useDebugRect.value) {
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
      ..color = timeSliceColor.value
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
    sidePaintCounter++;
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
        "${settings.noKeyboard ? 'no' : 'with'} keyboard, "
        "t=${zzz(time.value)}, v = ${zzz(velocity.value)}/"
        "${zzz(data.transform.frame.velocity)}.  "
        "\n"
        "paint=$paintCounter/${repaintCounter.value}, "
        "sp=$sidePaintCounter, "
        "b$_buildCounter #=${data.drawables.length}, "
        "unsaved=${fileManager.unsaved.value}, "
        "uc=${undoManager.undoList.length}, rc=${undoManager.redoList.length}, ";
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
    repaintCounter.value++;
    // Log.update.log("Done request repaint $this.");
  }

  String debugPrint() {
    return "sc(r${repaintCounter.value}p$paintCounter/$sidePaintCounter,b$_buildCounter) ";
  }

  void dumpDebugInfo() {
    Log.dump.log("GREEN: ---- dumping debug info -----");
    Log.dump.log("this = $this, name = ${currentName.value}");
    Log.dump.log(data.transform.dumpDebugInfo());
    Log.dump.log("Data.Drawables:");
    for (var d in data.drawables) {
      d.dumpDebugInfo();
    }
    requestRepaintScene();
    undoManager.dumpList();
  }

  Widget buildSideView(BuildContext context, State state) {
    _buildCounter++;
    _sideListener ??= MouseListener(this, true);
    return _sideListener!.build(
      context,
      CustomPaint(
        key: const ValueKey("SideView"),
        foregroundPainter: SideViewPainter(
          sceneViewer: this,
          repaint: repaintCounter,
        ),
        painter: SideAxisPainter(data.transform, axisColor.value, xAxis, tAxis),
        child: Container(),
      ),
    );
  }

  Widget build(BuildContext context, State state) {
    _buildCounter++;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        data.transform.resize(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        updateScene(triggerRepaint: false);
        _mainListener ??= MouseListener(this, false);
        return _mainListener!.build(
          context,
          CustomPaint(
            key: const ValueKey("MainView"),
            foregroundPainter: ScenePainter(
              sceneViewer: this,
              repaint: repaintCounter,
            ),
            painter: AxisPainter(data.transform, axisColor.value, xAxis, tAxis),
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
      // XXX use sceneViewer.time.speedDelta?
      time.incrementSpeed(-1.0);
    }
    if ((character == "=") || (character == "+")) {
      Log.keys.log("fast. $this");
      // XXX
      time.incrementSpeed(1.0);
    }
    if (key == LogicalKeyboardKey.escape) {
      if (selected != null) undoManager.rebuildMenu();
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
      lightSpeed.value,
    );
    Log.objects.log("Current name = ${currentName.value}");
    final Drawable d = currentType.value.make(
      currentName.value,
      frame,
      currentColor.value,
    );
    // Log.objects.log("Add object: $d");
    undoManager.add(
      UndoCallback(
        "Add ${d.name}",
        undoCallback: () {
          if (selected == data.drawables.last) {
            undoManager.rebuildMenu();
            selected = null;
          }
          data.drawables.removeLast();
          updateScene();
          fileManager.change();
        },
        redoCallback: () {
          data.drawables.add(d);
          updateScene();
          fileManager.change();
        },
      ),
    );
    String old = guess.name;
    guess.increment();
    Log.objects.log("guess, inc '$old' to '${guess.name}'");
    currentName.value = guess.name;
  }

  /* If this is not a repeat, just find the closest object.
  If this is a repeat, then find the closest object that is not any closer than the current selected.
  */
  void selectClosest(Point obs, bool side, bool repeat) {
    Log.select.log(
      "selectClosest. obs = ${zzz(obs)}, side=$side, repeat=$repeat",
    );
    final double maxDist = dotSize.value / data.transform.zoom;
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
        "  dist=${zzz(distance)}, obs=${zzz(d.ptObs)}, name=${d.name}",
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
      currentName.value = "-none-";
      if (!wasEmpty) undoManager.rebuildMenu();
      return;
    }
    currentType.value = closest.type;
    currentColor.value = closest.color;
    currentName.value = closest.name;
    Log.select.log("select to current name = ${currentName.value}");
    selected = closest;
    // Check to see if the edit menu items copy/cut/paste need to change their
    // enabled bits.
    if (wasEmpty != (selected == null)) undoManager.rebuildMenu();

    // selected?.dumpDebugInfo();
  }

  // Returns the point if it is near the selected object, or null if it is not.
  // The point is in observer coordinates.
  Point? nearSelected(Offset screen, bool side) {
    if (selected == null) return null;
    final double maxDist = dotSize.value / data.transform.zoom;
    Point pt = data.transform.fromOffset(screen, time.value, side);
    // Log.select.log("near screen=${zzz(screen)} -> ${zzz(pt)}");
    // Log.select.log("  selected: $selected");
    if (selected != null && (selected!.distance(pt, side) <= maxDist)) {
      return pt;
    }
    return null;
  }

  // Updates the zoom of the current data.transform, and pans old point to
  // new point.
  void doScale(Offset pt1, Offset pt2, double zoom, bool side) {
    data.transform.doScale(pt1, pt2, zoom, side);
    xAxis.resize(data.transform);
    tAxis.resize(data.transform);
    time.min = data.transform.min.t;
    time.max = data.transform.max.t;
    updateScene();
  }

  void onTap(Offset screen, bool side, bool repeat) {
    Point obs = data.transform.fromOffset(screen, time.value, side);
    Log.select.log(
      "BLUE: scene onTap ${zzz(screen)} -> ${zzz(obs)}, tool=${currentTool.value}.",
    );
    switch (currentTool.value) {
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
    currentTool.addListener(() {
      Log.objects.log("Current tool is now ${currentTool.value}");
      switch (currentTool.value) {
        case Tool.select:
          break;
        case Tool.add:
          // When the tool changes to 'add', deselect current item and
          // update the name guess.
          selected = null;
          undoManager.rebuildMenu();
          guess.prefix = currentType.value.prefix;
          for (var d in data.drawables) {
            guess.riseAbove(d.name);
          }
          // XXX guess.increment()?
          Log.objects.log(
            "BLUE: Tool name from ${currentName.value} to ${guess.name}",
          );
          currentName.value = guess.name;
          break;
      }
    });
    currentType.addListener(() {
      guess.prefix = currentType.value.prefix;
      if (selected != null) {
        final int index = data.drawables.indexOf(selected!);
        Log.objects.log("Current type changed for index $index.");
        Drawable old = selected!;
        if (currentType.value != old.type) {
          Drawable d = currentType.value.make(old.name, old.frame, old.color);
          undoManager.add(
            Change<Drawable>("Type", old, d, (v) {
              Log.objects.log("do/undo type change for $index to $v.");
              bool changeSelected = (data.drawables[index] == selected);
              data.drawables[index] = v;
              if (changeSelected) {
                selected = v;
                currentType.value = v.type;
              }
              updateScene();
              fileManager.change();
            }),
          );
        }
      } else {
        Log.objects.log("type changed. change name to ${guess.name}");
        currentName.value = guess.name;
      }
    });
    currentColor.addListener(() {
      Log.objects.log("YELLOW: currentColor was set to ${currentColor.value}");
      if (selected != null) {
        final drawable = selected!;
        if (drawable.color == currentColor.value) {
          Log.objects.log("Color did not change (${drawable.color}).");
          return;
        }
        Log.objects.log(
          "Current color changed to ${drawable.color} (with selected).",
        );
        undoManager.add(
          Change<int>("Color", drawable.color, currentColor.value, (v) {
            Log.objects.log("YELLOW: do/undo color change to $v.");
            drawable.color = v;
            if (identical(drawable, selected)) currentColor.value = v;
            requestRepaintScene();
            fileManager.change();
          }),
        );
      }
    });
    currentName.addListener(() {
      Log.objects.log(
        "name changed. guess ${guess.name} to ${currentName.value}",
      );
      guess.name = currentName.value;
      if (selected != null) {
        final drawable = selected!;
        if (drawable.name == currentName.value) {
          // Log.objects.log("Name did not change (${drawable.name}).");
          return;
        }
        Log.objects.log(
          "Current name changed from ${drawable.name} to ${currentName.value}.",
        );
        final String oldName = drawable.name;
        drawable.name = currentName.value;
        undoManager.add(
          Change<String>("Name", oldName, currentName.value, (v) {
            Log.undo.log("do/undo name change to $v.");
            drawable.name = v;
            if (identical(drawable, selected)) currentName.value = v;
            requestRepaintScene();
            fileManager.change();
          }),
        );
      }
    });
    lightSpeed.addListener(() {
      Log.objects.log("Light speed is now ${lightSpeed.value}");
      data.transform.lightSpeed = lightSpeed.value;
      updateScene();
    });
  }

  void delete() {
    // Log.objects.log("delete. $selected");
    if (selected == null) return;
    final int index = data.drawables.indexOf(selected!);
    final Drawable d = selected!;
    undoManager.add(
      UndoCallback(
        "Delete ${d.name} at $index",
        undoCallback: () {
          data.drawables.insert(index, d);
          updateScene();
          fileManager.change();
        },
        redoCallback: () {
          if (selected == data.drawables[index]) {
            selected = null;
          }
          data.drawables.removeAt(index);
          updateScene();
          fileManager.change();
        },
      ),
    );
  }

  void cut() {
    copy();
    delete();
  }

  void copy() {
    var encoder = const JsonEncoder.withIndent("  ");
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

  @override
  int get hashCode => data.hashCode;
}
