import 'dart:math' as math;
import 'package:flutter/material.dart';

import "printer.dart";
import "settings.dart";

/*
option 1:
sprite has left, right, above, below.

option 2:
sprite has width, height, cx, cy.

option 3:
sprite has width, hieght, (bool isWide).
cy = 0, cx = 0.5 unless isWide. then cx=1. 


location computes box:
  x0 = x - width*cx,
  x1 = x0 + width,
  z0 = z - height *cy
  z1 = z + height

  location paintSide and distance uses box computation.

  sprite uses c and width/hieght (box = size)

  two types of widths: scaleable widths, (barn, train)
  and non scalable widths (clock, person, flag).

  width
  bool extension.
  if (extension) then box = (x, x+width)x(y, y+height)
  else then box = (x+/- width/2)x(y, y+height)

  scaleable width uses transform.
  nonscalable uses dz * dilation constant.

  consider having z scale same as x scale.

  drag from corner of box should resize.
  drag from middle of box should move.
  selected object should draw box outline.
  
*/

enum Sprite {
  clock("clock", 0.10, 0.10, false),
  person("person", 0.05, 0.20, false),
  train("train", 0.50, 0.2, true),
  barn("barn", 0.50, 0.22, true),
  flag("flag", 0.10, 0.25, false);

  const Sprite(this.label, this.width, this.height, this.isWide);
  factory Sprite.fromString(String l) {
    for (var v in values) {
      if (v.label == l) return v;
    }
    throw FormatException("Invalid sprite $l");
  }

  final String label;
  final double width, height; // Default values.
  final bool isWide; // If this object should have its width drawn.

  @override
  String toString() => label;

  // If we want to load something from the assets, do it here.
  static bool init_running = false;
  static bool initialized = false;
  static Future<void> initialize(
    BuildContext context,
    Settings settings,
  ) async {
    if (initialized) {
      Log.init.log("GREEN: sprite already initialized.");
    } else if (init_running) {
      Log.init.log("XXX Sprite init second time.");
    } else {
      init_running = true;
      await dsleep("sprites", 5);
      initialized = true;
      init_running = false;
      // XXX -- do this with files, too?
      settings.notify(); // Tell settings to notify everybody to rebuild.
    }
  }

  // Draw ths object in the specified rectangle, with the specified time.
  // Time is give in the objects reference frame.
  void paint(Canvas canvas, Paint paint, Rect bounds, double time) {
    final double x = bounds.center.dx; // Center line.
    final double w = bounds.width;
    final double h = bounds.height;
    switch (this) {
      case person:
        canvas.drawOval(
          Rect.fromLTWH(bounds.left, bounds.top, w, h * 0.2),
          paint,
        );
        Offset neck = Offset(x, bounds.top + 0.2 * h);
        Offset lhand = Offset(x - 0.5 * w, bounds.top + 0.5 * h);
        Offset rhand = Offset(x + 0.5 * w, bounds.top + 0.5 * h);
        canvas.drawLine(neck, lhand, paint);
        canvas.drawLine(neck, rhand, paint);
        Offset hip = Offset(x, bounds.top + 0.5 * h);
        canvas.drawLine(neck, hip, paint);
        Offset lfoot = Offset(bounds.left, bounds.bottom);
        Offset rfoot = Offset(bounds.right, bounds.bottom);
        canvas.drawLine(hip, lfoot, paint);
        canvas.drawLine(hip, rfoot, paint);
        return;
      case train:
        double xd = w * 0.2; //diameter in x direction.
        double yd = h * 0.4; //diameter in y direction.
        canvas.drawRect(
          Rect.fromLTWH(bounds.left, bounds.top, w, h - yd / 2),
          paint,
        );
        Rect lwheel = Rect.fromLTWH(bounds.left, bounds.bottom - yd, xd, yd);
        Rect rwheel = Rect.fromLTWH(
          bounds.right - xd,
          bounds.bottom - yd,
          xd,
          yd,
        );
        canvas.drawArc(lwheel, 0, 3.14159, true, paint);
        canvas.drawArc(rwheel, 0, 3.14159, true, paint);
        return;
      case barn:
        double peak = 0.2 * h;
        canvas.drawRect(
          Rect.fromLTWH(bounds.left, bounds.top + peak, w, h - peak),
          paint,
        );
        Offset left = Offset(bounds.left, bounds.top + peak);
        Offset right = Offset(bounds.right, bounds.top + peak);
        Offset top = Offset(x, bounds.top);
        canvas.drawLine(left, top, paint);
        canvas.drawLine(right, top, paint);
        return;
      case flag:
        Offset top = Offset(x, bounds.top);
        // Let the tip of the flag extend a little beyond the bounding box.
        // It looks nicer that way.
        Offset tip = Offset(bounds.right + w, bounds.top + 0.1 * h);
        Offset flagBottom = Offset(x, bounds.top + 0.2 * h);
        canvas.drawLine(Offset(x, bounds.bottom), top, paint); //staff.
        canvas.drawLine(tip, top, paint);
        canvas.drawLine(tip, flagBottom, paint);
        return;
      case clock:
        double y = bounds.center.dy;
        int hour = time.floor();
        double hourAngle = hour * 3.14159 / 6.0; // 6 hours = pi.
        Offset hourPoint = Offset(
          x + 0.3 * math.sin(hourAngle) * w,
          y - 0.3 * math.cos(hourAngle) * h,
        );
        int min = ((time - hour) * 60).toInt();
        double minAngle = min * 3.14159 / 30.0; // 30 minutes = pi.
        Offset minPoint = Offset(
          x + 0.5 * math.sin(minAngle) * w,
          y - 0.5 * math.cos(minAngle) * h,
        );
        Log.update.log("hour = $hour, min=$min");
        canvas.drawLine(bounds.center, hourPoint, paint);
        canvas.drawLine(bounds.center, minPoint, paint);
        canvas.drawOval(
          Rect.fromCenter(center: bounds.center, width: w, height: h),
          paint,
        );
        return;
    }
  }
}
