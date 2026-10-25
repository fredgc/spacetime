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
  final double speedDelta = 2.0; // Delta for increasing speed with buttons.
  bool allowAnimate;
  bool stickAtZero = true; // Not for animation, but for sliding.

  int currentSticky = -1; // The current sticky point the slider is stuck on.
  int nextSticky = -1;
  double currentTimeAtStickyPoint = 0;
  List<double> sticky = []; //Sorted list of sticky points.

  VoidCallback? startAnimation;
  Color backgroundColor = Colors.black;
  Color textColor = Colors.white;
  Color gridColor = Colors.red;
  Size size = const Size(0, 0);
  bool loop = false;

  int paintCounter = 0;
  int buildCounter = 0;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;

  // TODO: make these all named parameters.

  MySlider(
    this.name,
    this.min,
    this.max,
    this._value, {
    this.allowAnimate = true,
  }) {
    // Log.widget.log("BLUE: created new slider.");
    speed = 0.0;
    if (min >= max) {
      max = min + 0.1;
    }
  }

  static SavableDouble stickyDelay = SavableDouble(
    "sticky_delay",
    "Sticky delay",
    0.1,
    tip: "How long in seconds a slider should dwell on a sticky point",
  );
  static SavableDouble stickyRadius = SavableDouble(
    "sticky_radius",
    "Sticky radius",
    1.0,
    tip: "How close the slider should be to a sticky point before snapping",
  );

  static void initSettings(Settings settings) {
    settings.add(stickyDelay);
    settings.add(stickyRadius);
    settings.add(EndOfGroup());
  }

  @override
  String toString() {
    // return "Slider $name";
    return "Slider-$_debugId $name (${zzz(value)})";
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
    return "SL ${zzz(value)}(sp=${zzz(speed)}, p$paintCounter,b$buildCounter), ";
  }

  set value(double x) {
    // If there is a sticky radius, find the closest sticky point.
    currentSticky = -1;
    if (stickyRadius.value > 0) {
      final double stickyWidth = (max - min) * stickyRadius.value * 0.01;
      int stickyPoint = 0;
      for (int i = 1; i < sticky.length; i++) {
        if ((x - sticky[i]).abs() < (x - sticky[stickyPoint]).abs()) {
          stickyPoint = i;
        }
        // If the closest sticky point is within the sticky radius (as a percent),
        // then move to that point.
        if ((x - sticky[stickyPoint]).abs() < stickyWidth) {
          x = sticky[stickyPoint];
          currentSticky = stickyPoint;
          currentTimeAtStickyPoint = 0.0;
          // Log.animate.log("GREEN: set value to sticky s[$currentSticky] = ${zzz(x)}");
        }
      }
      // If we didn't hit a sticky point, but 0 is a sticky point, then stick at 0.
      if (currentSticky < 0 && stickAtZero && x.abs() < stickyWidth) {
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
    // If at a sticky point, increment the currentTime.
    if (currentSticky >= 0) {
      currentTimeAtStickyPoint += dt;
      if (currentTimeAtStickyPoint > stickyDelay.value) {
        // Finished with this sticky point. move on.
        // Log.animate.log("BLUE: Ended sticky at time ${currentTimeAtStickyPoint}");
        dt = currentTimeAtStickyPoint - stickyDelay.value;
        currentTimeAtStickyPoint = 0;
        currentSticky = -1;
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
      currentSticky = nextSticky;
      _value = sticky[currentSticky];
      currentTimeAtStickyPoint = 0.0;
      // Log.animate.log("GREEN: hit next sticky s[$currentSticky] = ${zzz(_value)}");
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
    if (nextSticky < 0) return false;
    double a = speed > 0 ? _value : (_value + dh);
    double b = speed > 0 ? (_value + dh) : _value;
    double x = sticky[nextSticky];
    return (a <= x && x <= b);
  }

  void findNextSticky() {
    if (stickyDelay.value <= 0.0 || sticky.isEmpty) {
      nextSticky = -1;
      return;
    }
    if (speed > 0) {
      // The next sticky point is first point that is after the current value.
      for (int i = 0; i < sticky.length; i++) {
        if (_value < sticky[i]) {
          nextSticky = i;
          // Log.animate.log("BLUE: found next sticky s[$i] = ${zzz(sticky[i])}");
          return;
        }
      }
      // Log.animate.log("BLUE: found no sticky points.");
      nextSticky = -1; // No more sticky points.
    } else {
      // The next sticky point is the last point that is before the current value.
      for (int i = sticky.length - 1; i >= 0; i--) {
        if (_value > sticky[i]) {
          nextSticky = i;
          // Log.animate.log("BLUE: found next sticky s[$i] = ${zzz(sticky[i])}");
          return;
        }
      }
      // Log.animate.log("BLUE: found no sticky points.");
      nextSticky = -1; // No more sticky points.
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
    if (allowAnimate) {
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
    if (allowAnimate) setSpeed(v);
  }

  void tapUp(TapUpDetails info) {
    // Log.animate.log("TapUp pos ${zzz(info.localPosition)}.");
    value = pixelToValue(info.localPosition.dx);
    setSpeed(0.0);
  }

  void paint(Canvas canvas, Size size) {
    paintCounter++;
    this.size = size;
    // Paint the background.
    Paint background = Paint()..color = backgroundColor;
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    canvas.drawRect(rect, background);

    // Screen coordinate of the current value. This is where the handle is drawn.
    var x = valueToPixel(value);

    // Compute where the text will go, but paint it last.
    final style = TextStyle(color: textColor);
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
    Paint grid = Paint()..color = gridColor;
    double mid = painter.height + (size.height - painter.height) / 2.0;
    rect = Rect.fromLTWH(0.0, mid - 1.0, size.width, 2.0);
    canvas.drawRect(rect, grid);

    // Draw a dot at each sticky point. Radius = 2 pixels.
    for (double x in sticky) {
      Offset c = Offset(valueToPixel(x), mid);
      canvas.drawCircle(c, 2.0, grid);
    }

    // Draw the handle. Width = 4.
    Paint handlePaint = Paint()..color = textColor;
    rect = Rect.fromLTWH(x - 2, 0.0, 4.0, size.height);
    RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.0));
    canvas.drawRRect(rrect, handlePaint);

    // XXX canvas.drawRect(rect, background);
    painter.paint(canvas, offset);
  }

  // Build a single slider widget.
  Widget build(BuildContext context) {
    buildCounter++;
    ThemeData theme = Theme.of(context);
    backgroundColor = theme.colorScheme.surface;
    textColor = theme.colorScheme.onSurface;
    gridColor = theme.colorScheme.primary;
    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Text("$name: "),
          Opacity(
            opacity: allowAnimate ? 1.0 : 0.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () {
                Log.animate.log("Button $name decrease speed.");
                incrementSpeed(-speedDelta);
              },
            ),
          ),
          Expanded(
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
          Opacity(
            opacity: allowAnimate ? 1.0 : 0.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () {
                Log.animate.log("Button $name increase speed.");
                incrementSpeed(speedDelta);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build a table holding several slider widgets.
  static Table buildTable(
    BuildContext context,
    List<MySlider> sliders, {
    String? highlightId,
    double highlightPulse = 1.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? Colors.amberAccent.shade400
        : Colors.deepOrangeAccent.shade400;
    final p = highlightPulse.clamp(0.0, 1.0);
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      children: sliders.map((f) {
        final isHighlighted =
            (f.name.toLowerCase().contains("velocity") &&
                highlightId == "slider.velocity") ||
            (f.name.toLowerCase().contains("time") &&
                highlightId == "slider.time");
        return TableRow(
          decoration: isHighlighted
              ? BoxDecoration(
                  color: accentColor.withValues(alpha: 0.45 * p),
                  border: Border.all(
                    color: accentColor.withValues(alpha: p),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                )
              : null,
          children: f.buildRow(
            context,
            highlightPulse: isHighlighted ? p : 0.0,
          ),
        );
      }).toList(),
    );
  }

  // Build one row of a table holding this slider's widget.
  List<Widget> buildRow(BuildContext context, {double highlightPulse = 0.0}) {
    buildCounter++;
    ThemeData theme = Theme.of(context);
    if (highlightPulse > 0.0) {
      final isDark = theme.brightness == Brightness.dark;
      final accentColor = isDark
          ? Colors.amberAccent.shade400
          : Colors.deepOrangeAccent.shade400;
      backgroundColor = Color.lerp(
        theme.colorScheme.surface,
        accentColor,
        0.35 * highlightPulse.clamp(0.0, 1.0),
      )!;
    } else {
      backgroundColor = theme.colorScheme.surface;
    }
    textColor = theme.colorScheme.onSurface;
    gridColor = theme.colorScheme.primary;
    return <Widget>[
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Text(" $name:"),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Opacity(
          opacity: allowAnimate ? 1.0 : 0.0,
          child: IconButton(
            color: gridColor,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_left),
            onPressed: () {
              Log.animate.log("Button $name decrease speed.");
              incrementSpeed(-speedDelta);
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
          opacity: allowAnimate ? 1.0 : 0.0,
          child: IconButton(
            color: gridColor,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_right),
            onPressed: () {
              Log.animate.log("Button $name increase speed.");
              incrementSpeed(speedDelta);
            },
          ),
        ),
      ),
    ];
  }
}

class SliderPainter extends CustomPainter {
  final MySlider slider;
  SliderPainter({required this.slider, super.repaint});

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
