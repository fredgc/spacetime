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

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../printer.dart';
import '../scene.dart';
import '../transform.dart';
import 'drawable.dart';

class Instant extends Drawable {
  Vector v = Vector(); // Direction [0, 1] in local frame.
  Vector vObs = Vector(); // Direction converted to observer frame.
  bool horizontal = true;
  double radius = 1.0;

  Instant(super.type, super.name, super.frame, super.color);

  @override
  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    await super.update(transform, time, sticky);
    sticky.add(ptObs.t);
    v = Vector(dt: 0.0, dx: 1.0).fromFrame(frame, transform.lightSpeed);
    vObs = transform.worldToObserverV(v);
    // For an instant, we expect dt to be small. When drawing the side view, if
    // it is very small, we treat this as a horizontal line bigger than the
    // screen.
    if (vObs.dt.abs() < 0.01) {
      horizontal = true;
    } else {
      horizontal = false;
      // Otherwise, it is a horizontal line with width depending on how big dt is.
      // Direction of the line is vObs, i.e. slope of v.dx / v.dt.
      // Pick a dt = fadeTime, so that dx = fadeTime * v.dx / v.dt.
      radius = SceneView.fadeTime.value * vObs.dx / vObs.dt;
    }
  }

  @override
  double distance(Point obs, bool side) {
    // Take into account dz when looking at side view.
    double dz = side ? obs.z - ptObs.z : 0.0;
    double dx = obs.x - ptObs.x;
    double dt = obs.t - ptObs.t;
    // Convert to coordinate system vObs, perp(vObs).
    // a = delta * vObs / det,  b = delta * perp(vObs) / det
    // det = |vObs|^2.
    double det = vObs.dx * vObs.dx + vObs.dt * vObs.dt;
    double b = (vObs.dt * dx - vObs.dx * dt) / det;
    return math.sqrt(b * b + dz * dz);
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    // Draw the line ptObs + s * vObs = (x + s*dx, t + s*dt) from
    // x1 = transform.min.x to x2 = transform.max.x
    final double x1 = transform.min.x;
    final double x2 = transform.max.x;
    final double t1 = ptObs.t + (x1 - ptObs.x) * vObs.dt / vObs.dx;
    final double t2 = ptObs.t + (x2 - ptObs.x) * vObs.dt / vObs.dx;
    Paint paint = getPaint(isSelected);
    Offset c1 = transform.toScreen(Point(t: t1, x: x1));
    Offset c2 = transform.toScreen(Point(t: t2, x: x2));
    canvas.drawLine(c1, c2, paint);
    textPainter.paint(canvas, transform.toScreen(ptObs));
  }

  @override
  void paintHighlight(
    Canvas canvas,
    CoordinateTransform transform,
    Paint highlightPaint,
  ) {
    final double x1 = transform.min.x;
    final double x2 = transform.max.x;
    final double t1 = ptObs.t + (x1 - ptObs.x) * vObs.dt / vObs.dx;
    final double t2 = ptObs.t + (x2 - ptObs.x) * vObs.dt / vObs.dx;
    Offset c1 = transform.toScreen(Point(t: t1, x: x1));
    Offset c2 = transform.toScreen(Point(t: t2, x: x2));
    canvas.drawLine(c1, c2, highlightPaint);
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    Log.update.log('Painting Side instant $this');
    double timeDelta = (time - ptObs.t);
    if (horizontal) {
      if (timeDelta.abs() > SceneView.fadeTime.value) return;
      var height =
          (SceneView.dotSize.value *
          0.5 *
          (SceneView.fadeTime.value - timeDelta) /
          SceneView.fadeTime.value);
      Paint paint = getPaint(isSelected);
      Offset c = transform.toSide(ptObs);
      Offset right = transform.toSide(transform.max);
      if (timeDelta < SceneView.fadeTime.value * 0.01) {
        paint.style = PaintingStyle.fill;
      }
      canvas.drawRect(Rect.fromLTWH(0.0, c.dy, right.dx, height), paint);
      textPainter.paint(canvas, Offset(2, c.dy + 4));
    } else {
      Paint paint = getPaint(isSelected);
      double center = ptObs.x + ((time - ptObs.t) * vObs.dx / vObs.dt);
      Point left = Point(x: center - radius, t: ptObs.t, z: ptObs.z);
      Point right = Point(x: center + radius, t: ptObs.t, z: ptObs.z);
      Offset l = transform.toSide(left);
      Offset r = transform.toSide(right);
      canvas.drawLine(l, r, paint);
      textPainter.paint(canvas, r);
    }
  }

  @override
  void dumpDebugInfo() {
    super.dumpDebugInfo();
    Log.dump.log('   v=${zzz(v)} -> vObs=${zzz(vObs)}');
  }
}
