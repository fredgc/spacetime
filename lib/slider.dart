// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Code reused from polytope project.

import 'package:flutter/material.dart';

import "printer.dart";
import 'settings.dart';

class MySlider with ChangeNotifier {
  final String name;
  double _value;
  double get value => _value;
  double min;
  double max;
  double speed = 0.0;
  final double speed_delta = 2.0; // Delta for increasing speed with buttons.
  bool allow_animate;
  bool stick_at_zero = true; // Not for animation, but for sliding.

  int current_sticky = -1; // The current sticky point the slider is stuck on.
  int next_sticky = -1;
  double current_time_at_sticky_point = 0;
  List<double> sticky = []; //Sorted list of sticky points.

  VoidCallback? startAnimation;
  Color background_color = Colors.black;
  Color text_color = Colors.white;
  Color grid_color = Colors.red;
  Size size = Size(0, 0);
  bool loop = false;

  int paint_counter = 0;
  int build_counter = 0;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;

  // TODO: make these all named parameters.

  MySlider(
    this.name,
    this.min,
    this.max,
    this._value, {
    this.allow_animate = true,
  }) {
    // Log.widget.log("BLUE: created new slider.");
    speed = 0.0;
    if (min >= max) {
      max = min + 0.1;
    }
  }

  static SavableDouble sticky_delay = SavableDouble(
    "sticky_delay",
    "Sticky delay",
    0.1,
    tip: "How long in seconds a slider should dwell on a sticky point",
  );
  static SavableDouble sticky_radius = SavableDouble(
    "sticky_radius",
    "Sticky radius",
    1.0,
    tip: "How close the slider should be to a sticky point before snapping",
  );

  static void initSettings(Settings settings) {
    settings.add(sticky_delay);
    settings.add(sticky_radius);
    settings.add(EndOfGroup());
  }

  @override
  String toString() {
    // return "Slider $name";
    return "Slider-$debug_id $name (${zzz(value)})";
  }

  // Set the array of important points.
  void setSticky(Iterable<double> iterable) {
    sticky = [];
    addSticky(iterable);
  }

  // Add array of important points.
  void addSticky(Iterable<double> iterable) {
    Set<double> set = Set.from(sticky);
    set.addAll(iterable);
    sticky = set.toList();
    sticky.sort();
    findNextSticky();
    notifyListeners();
  }

  void autoRange() {
    if (sticky.isEmpty) return;
    min = sticky[0];
    max = sticky.last;
    if (_value < min) min = _value;
    if (_value > max) max = _value;
    if (max - min < 1.0e-9) {
      min -= 1.0e-3;
      max += 1.0e-3;
      return;
    }
    // Add 5% buffer around range.
    double buffer = (max - min) * 0.05;
    min -= buffer;
    max += buffer;
  }

  double valueToPixel(double x) {
    return size.width * (x - min) / (max - min);
  }

  double pixelToValue(double px) {
    return min + (px / size.width) * (max - min);
  }

  double pixelToVelocity(double px) {
    if (size.width == 0) return min;
    return (px / size.width) * (max - min);
  }

  // Add painter like in scene, w/paint changed.
  // add callback when value changes. It should trigger a repaint, or maybe start playback.

  String debugPrint() {
    return "SL ${zzz(value)}(sp=${zzz(speed)}, p$paint_counter,b$build_counter), ";
  }

  set value(double x) {
    // If there is a sticky radius, find the closest sticky point.
    current_sticky = -1;
    if (sticky_radius.value > 0) {
      final double sticky_width = (max - min) * sticky_radius.value * 0.01;
      int stickyPoint = 0;
      for (int i = 1; i < sticky.length; i++) {
        if ((x - sticky[i]).abs() < (x - sticky[stickyPoint]).abs()) {
          stickyPoint = i;
        }
        // If the closest sticky point is within the sticky radius (as a percent),
        // then move to that point.
        if ((x - sticky[stickyPoint]).abs() < sticky_width) {
          x = sticky[stickyPoint];
          current_sticky = stickyPoint;
          current_time_at_sticky_point = 0.0;
          // Log.animate.log("GREEN: set value to sticky s[$current_sticky] = ${zzz(x)}");
        }
      }
      // If we didn't hit a sticky point, but 0 is a sticky point, then stick at 0.
      if (current_sticky < 0 && stick_at_zero && x.abs() < sticky_width) {
        x = 0;
      }
    }
    _value = x;
    clamp();
    findNextSticky();
    notifyListeners();
  }

  bool updateTime(double dt, {bool notifyOnChange = true}) {
    if (speed == 0) {
      // Log.animate.log("BLUE: speed is now zero.");
      return false;
    }
    // If at a sticky point, increment the current_time.
    if (current_sticky >= 0) {
      current_time_at_sticky_point += dt;
      if (current_time_at_sticky_point > sticky_delay.value) {
        // Finished with this sticky point. move on.
        // Log.animate.log("BLUE: Ended sticky at time ${current_time_at_sticky_point}");
        dt = current_time_at_sticky_point - sticky_delay.value;
        current_time_at_sticky_point = 0;
        current_sticky = -1;
        findNextSticky();
      } else {
        return true;
      }
    }
    double dh = speed * dt;
    double range = (max - min);
    if (dh.abs() > range) {
      Log.errors.log("RED: dh is very big: ${zzz(dh)}");
      speed = 0.0;
      dh = 0;
      return false;
    }
    if (hitsNextSticky(dh)) {
      current_sticky = next_sticky;
      _value = sticky[current_sticky];
      current_time_at_sticky_point = 0.0;
      // Log.animate.log("GREEN: hit next sticky s[$current_sticky] = ${zzz(_value)}");
    } else {
      _value += dh;
    }
    if (loop) {
      if (_value > max) _value = min;
      if (_value < min) _value = max;
    } else {
      if (clamp()) setSpeed(0.0);
    }
    if (notifyOnChange) notifyListeners();
    return true;
  }

  // See if the next sticky point is between _value and _value + dh.
  bool hitsNextSticky(double dh) {
    if (next_sticky < 0) return false;
    double a = speed > 0 ? _value : (_value + dh);
    double b = speed > 0 ? (_value + dh) : _value;
    double x = sticky[next_sticky];
    return (a <= x && x <= b);
  }

  void findNextSticky() {
    if (sticky_delay.value <= 0.0 || sticky.isEmpty) {
      next_sticky = -1;
      return;
    }
    if (speed > 0) {
      // The next sticky point is first point that is after the current value.
      for (int i = 0; i < sticky.length; i++) {
        if (_value < sticky[i]) {
          next_sticky = i;
          // Log.animate.log("BLUE: found next sticky s[$i] = ${zzz(sticky[i])}");
          return;
        }
      }
      // Log.animate.log("BLUE: found no sticky points.");
      next_sticky = -1; // No more sticky points.
    } else {
      // The next sticky point is the last point that is before the current value.
      for (int i = sticky.length - 1; i >= 0; i--) {
        if (_value > sticky[i]) {
          next_sticky = i;
          // Log.animate.log("BLUE: found next sticky s[$i] = ${zzz(sticky[i])}");
          return;
        }
      }
      // Log.animate.log("BLUE: found no sticky points.");
      next_sticky = -1; // No more sticky points.
    }
  }

  // Keep value in range. Return true if we had to do anything.
  bool clamp() {
    if (_value > max) {
      _value = max;
      return true; //TODO: always set speed = 0?
    }
    if (_value < min) {
      _value = min;
      return true;
    }
    return false;
  }

  void setSpeed(double s) {
    speed = s;
    // Log.animate.log("slider $name speed = ${zzz(speed)}.");
    // Round off to zero.
    if (speed.abs() < 0.001 * (max - min)) speed = 0.0;
    if (speed != 0.0) {
      // Log.animate.log("GREEN: slider has nonzero speed ${zzz(speed)}.");
      startAnimation?.call();
    }
    findNextSticky();
  }

  // Increment speed by a percentage of the range.
  void incrementSpeed(double percent) {
    if (allow_animate) {
      setSpeed(speed + (max - min) * percent * 0.01);
    }
  }

  void scaleStart(ScaleStartDetails info) {
    // Log.animate.log("slider Scale start");
    setSpeed(0.0);
    value = pixelToValue(info.localFocalPoint.dx);
  }

  void scaleUpdate(ScaleUpdateDetails info) {
    value = pixelToValue(info.localFocalPoint.dx);
  }

  void scaleEnd(ScaleEndDetails info) {
    // Log.animate.log("Scale end: $info");
    double v = pixelToVelocity(info.velocity.pixelsPerSecond.dx);
    if (allow_animate) setSpeed(v);
  }

  void tapUp(TapUpDetails info) {
    // Log.animate.log("TapUp pos ${zzz(info.localPosition)}.");
    value = pixelToValue(info.localPosition.dx);
    setSpeed(0.0);
  }

  void paint(Canvas canvas, Size size) {
    paint_counter++;
    this.size = size;
    // Paint the background.
    Paint background = Paint()..color = background_color;
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    canvas.drawRect(rect, background);

    // Screen coordinate of the current value. This is where the handle is drawn.
    var x = valueToPixel(value);

    // Compute where the text will go, but paint it last.
    final style = TextStyle(color: text_color);
    var span = TextSpan(text: zzz(value), style: style);
    var painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    // Put the text 2 pixels from the top. And either to 10 pixels to the left or
    // right of the handle.
    painter.layout();
    Offset offset = (x < size.width / 2)
        ? Offset(x + 10, 2)
        : Offset(x - 10 - painter.width, 2);
    rect = Rect.fromLTWH(
      offset.dx - 2,
      offset.dy - 2,
      painter.width + 4,
      painter.height + 4,
    );

    // Paint a line down the middle. 2 pixels wide. Place it half way below the text.
    Paint grid = Paint()..color = grid_color;
    double mid = painter.height + (size.height - painter.height) / 2.0;
    rect = Rect.fromLTWH(0.0, mid - 1.0, size.width, 2.0);
    canvas.drawRect(rect, grid);

    // Draw a dot at each sticky point. Radius = 2 pixels.
    for (double x in sticky) {
      Offset c = Offset(valueToPixel(x), mid);
      canvas.drawCircle(c, 2.0, grid);
    }

    // Draw the handle. Width = 4.
    Paint handlePaint = Paint()..color = text_color;
    rect = Rect.fromLTWH(x - 2, 0.0, 4.0, size.height);
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(2.0));
    canvas.drawRRect(rrect, handlePaint);

    // XXX canvas.drawRect(rect, background);
    painter.paint(canvas, offset);
  }

  // Build a single slider widget.
  Widget build(BuildContext context) {
    build_counter++;
    ThemeData theme = Theme.of(context);
    background_color = theme.colorScheme.surface;
    text_color = theme.colorScheme.onSurface;
    grid_color = theme.colorScheme.primary;
    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Text("$name: "),
          Opacity(
            opacity: allow_animate ? 1.0 : 0.0,
            child: IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                Log.animate.log("Button $name decrease speed.");
                incrementSpeed(-speed_delta);
              },
            ),
          ),
          Expanded(
            child: Container(
              child: GestureDetector(
                onScaleStart: scaleStart,
                onScaleUpdate: scaleUpdate,
                onScaleEnd: scaleEnd,
                onTapUp: tapUp,
                child: ClipRect(
                  child: CustomPaint(
                    painter: SliderPainter(slider: this, repaint: this),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: allow_animate ? 1.0 : 0.0,
            child: IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                Log.animate.log("Button $name increase speed.");
                incrementSpeed(speed_delta);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build a table holding several slider widgets.
  static Table buildTable(BuildContext context, List<MySlider> sliders) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      children: sliders
          .map((f) => TableRow(children: f.buildRow(context)))
          .toList(),
    );
  }

  // Build one row of a table holding this slider's widget.
  List<Widget> buildRow(BuildContext context) {
    build_counter++;
    ThemeData theme = Theme.of(context);
    background_color = theme.colorScheme.surface;
    text_color = theme.colorScheme.onSurface;
    grid_color = theme.colorScheme.primary;
    return <Widget>[
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Text(" $name:"),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Opacity(
          opacity: allow_animate ? 1.0 : 0.0,
          child: IconButton(
            color: grid_color,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              Log.animate.log("Button $name decrease speed.");
              incrementSpeed(-speed_delta);
            },
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.fill,
        child: GestureDetector(
          key: ValueKey("canvas-$name"),
          onScaleStart: scaleStart,
          onScaleUpdate: scaleUpdate,
          onScaleEnd: scaleEnd,
          onTapUp: tapUp,
          child: ClipRect(
            child: CustomPaint(
              painter: SliderPainter(slider: this, repaint: this),
              child: Container(),
            ),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Opacity(
          opacity: allow_animate ? 1.0 : 0.0,
          child: IconButton(
            color: grid_color,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: Icon(Icons.arrow_right),
            onPressed: () {
              Log.animate.log("Button $name increase speed.");
              incrementSpeed(speed_delta);
            },
          ),
        ),
      ),
    ];
  }
}

class SliderPainter extends CustomPainter {
  MySlider slider;
  SliderPainter({required this.slider, repaint}) : super(repaint: repaint);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    bool should = (this != oldDelegate);
    return should;
  }

  @override
  void paint(Canvas canvas, Size size) {
    slider.paint(canvas, size);
  }
}
