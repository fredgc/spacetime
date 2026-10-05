import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'transform.dart';
import 'printer.dart';
import 'scene.dart';

/// Paints diagram axes and gridlines in main spacetime canvas.
class AxisPainter extends CustomPainter {
  CoordinateTransform transform;
  Color color;
  PlotAxis xAxis;
  PlotAxis tAxis;

  int _paintCount = 0;

  AxisPainter(this.transform, this.color, this.xAxis, this.tAxis);

  @override
  void paint(Canvas canvas, Size size) {
    _paintCount++;
    if (size.width == 0 || size.height == 0) {
      Log.update.log("RED: size is $size");
      return;
    }
    // Log.update.log("Axis Painting.");
    if (transform.sizeChanged(size)) {
      xAxis.printOnce = true;
      transform.resize(size);
      xAxis.resize(transform);
      tAxis.resize(transform);
    }
    var paint = Paint()
      ..color = color
      ..strokeWidth = SceneView.line_width.value
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    xAxis.paint(canvas, transform, paint);
    tAxis.paint(canvas, transform, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // XXX -- this seems to always be true.
    bool should = (this != oldDelegate);
    // Log.update.log("FDGC: calling shouldRepaint. should = $should.");
    return should;
  }
}

/// Paints spatial axis and gridlines in side observer view.
class SideAxisPainter extends CustomPainter {
  CoordinateTransform transform;
  Color color;
  PlotAxis xAxis;
  PlotAxis tAxis;

  int _paintCount = 0;

  SideAxisPainter(this.transform, this.color, this.xAxis, this.tAxis);

  @override
  void paint(Canvas canvas, Size size) {
    _paintCount++;
    if (size.width == 0 || size.height == 0) {
      Log.update.log("RED: size is $size");
      return;
    }
    var paint = Paint()
      ..color = color
      ..strokeWidth = SceneView.line_width.value
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    xAxis.paintSide(canvas, transform, paint, size.height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    bool should = (this != oldDelegate);
    return should;
  }
}

class Label {
  TextPainter painter;
  Offset offset;
  Label(this.painter, this.offset);
}

/// Models tick marks, grid lines, and labels for a plot axis.
class PlotAxis {
  bool vertical; // If this is the y-axis.
  double min = 0;
  double max = 0; // Min and max for axis.
  double dt2 = 0; // tick mark spacing.
  double dt = 0; // label spacing.
  double tickLength = 0;
  List<Label> labels = [];
  Color color = Colors.white;

  // Variables for debugging.
  int _paintCount = 0;
  bool printOnce = false;

  PlotAxis({required this.vertical});

  void paint(Canvas canvas, CoordinateTransform transform, Paint paint) {
    _paintCount++;
    if (printOnce) {
      Log.update.log(
        "ORANGE: Axis v=$vertical, min=${zzz(min)}, max=${zzz(max)}",
      );
    }
    if (SceneView.show_gridlines.value) {
      // The min/max in the cross direction.
      double min2 = vertical ? transform.min.x : transform.min.t;
      double max2 = vertical ? transform.max.x : transform.max.t;
      final gridPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.25)
        ..strokeWidth = math.max(0.5, paint.strokeWidth * 0.75)
        ..style = PaintingStyle.stroke;
      for (double tic = min; tic <= max; tic += dt) {
        drawLine(canvas, transform, gridPaint, min2, tic, max2, tic);
      }
    }
    drawLine(canvas, transform, paint, 0, min, 0, max);
    for (double tic = min; tic < max; tic += dt2) {
      // Small ticks.
      drawLine(canvas, transform, paint, -tickLength, tic, tickLength, tic);
    }
    for (Label label in labels) {
      label.painter.paint(canvas, label.offset);
    }
    printOnce = false;
  }

  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    Paint paint,
    double height,
  ) {
    _paintCount++;
    if (SceneView.show_gridlines.value) {
      final gridPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.25)
        ..strokeWidth = math.max(0.5, paint.strokeWidth * 0.75)
        ..style = PaintingStyle.stroke;
      for (double tic = min; tic <= max; tic += dt) {
        Offset off = transform.toSide(Point(x: tic, t: 0));
        canvas.drawLine(Offset(off.dx, 0), Offset(off.dx, height), gridPaint);
      }
    }
    for (double tic = min; tic < max; tic += dt2) {
      Offset off = transform.toSide(Point(x: tic, t: 0));
      Offset o1 = Offset(off.dx, height - 5);
      Offset o2 = Offset(off.dx, height);
      canvas.drawLine(o1, o2, paint);
    }
  }

  void drawLine(
    Canvas canvas,
    CoordinateTransform transform,
    Paint paint,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    if (vertical) {
      Point p1 = Point(x: x1, t: y1);
      Point p2 = Point(x: x2, t: y2);
      canvas.drawLine(transform.toScreen(p1), transform.toScreen(p2), paint);
    } else {
      Point p1 = Point(t: x1, x: y1);
      Point p2 = Point(t: x2, x: y2);
      canvas.drawLine(transform.toScreen(p1), transform.toScreen(p2), paint);
    }
  }

  void resize(CoordinateTransform transform) {
    if (vertical) {
      min = transform.min.t;
      max = transform.max.t;
    } else {
      min = transform.min.x;
      max = transform.max.x;
    }
    if (printOnce) {
      Log.update.log(
        "BLUE: axis resize: v=$vertical, "
        "New min=${zzz(min)}, max=${zzz(max)}",
      );
    }
    setupBounds(transform);
    createLabels(transform, color);
  }

  void setupBounds(CoordinateTransform transform) {
    if (!min.isFinite || !max.isFinite || max - min < 1e-9) {
      Log.update.log("RED: axis is bad. min=${zzz(min)}, max=${zzz(max)}");
      min = -2;
      max = 2;
    }
    double scale = (math.log(max - min) / math.log(10));
    dt = math.pow(10.0, scale.floor()).toDouble();
    dt2 = dt / 5;
    if ((((max - min) / dt)) < 3.0) {
      dt = dt / 5;
      dt2 = dt / 2;
    } else if ((max - min) / dt < 5.0) {
      dt = dt / 2;
      dt2 = dt / 5;
    }
    min = (min / dt).floor() * dt; // Round down.
    max = (max / dt).ceil() * dt; // Round up.
    tickLength = 5 / transform.zoom;
  }

  void createLabels(CoordinateTransform transform, Color color) {
    labels = [];
    if (!min.isFinite || !max.isFinite || !dt.isFinite || dt <= 0) return;
    final style = TextStyle(color: color, fontSize: 10.0);
    int labelCount = ((max - min) / dt).ceil();
    if (labelCount < 0 || labelCount > 500) return;
    for (int i = 0; i < labelCount; i++) {
      String text = (min + i * dt).toStringAsPrecision(2);
      double x = 0;
      double t = 0;
      if (vertical) {
        x = 1.5 * tickLength;
        t = (min + i * dt);
      } else {
        x = (min + i * dt);
        t = 1.5 * tickLength;
      }
      var span = TextSpan(text: text, style: style);
      var painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      );
      painter.layout();
      Offset lowerLeft = transform.toScreen(Point(x: x, t: t));
      Offset upperLeft = Offset(lowerLeft.dx, lowerLeft.dy - painter.height);
      labels.add(Label(painter, upperLeft));
    }
  }
}
