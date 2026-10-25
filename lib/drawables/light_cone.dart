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

class LightCone extends Drawable {
  LightCone(super.type, super.name, super.frame, super.color);

  // The speed of light for this cone, in observer frame. Going left and right.
  double lspeed = -1.0;
  double rspeed = 1.0;

  @override
  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    await super.update(transform, time, sticky);
    sticky.add(ptObs.t);
    switch (transform.lightSpeed) {
      case LightSpeed.lorentz:
        lspeed = -1.0;
        rspeed = 1.0;
        break;
      case LightSpeed.ether:
        lspeed = -1.0 - transform.frame.velocity;
        rspeed = 1.0 - transform.frame.velocity;
        break;
      case LightSpeed.emitter:
        lspeed = -1.0 + frame.velocity - transform.frame.velocity;
        rspeed = 1.0 + frame.velocity - transform.frame.velocity;
        break;
    }
  }

  @override
  double distance(Point obs, bool side) {
    // Take into account dz when looking at side view.
    double dz = side ? obs.z - ptObs.z : 0.0;
    double dt = obs.t - ptObs.t;
    // If below the light cone, just return the distance to the initial point.
    double dx = obs.x - ptObs.x;
    Log.select.log('DIST $name dx=${zzz(dx)}, dt=${zzz(dt)}, dz=${zzz(dz)}');
    // Otherwise, recompute dx as the distance to the closest light beam.
    if (dt > 0) {
      double x = ptObs.x + dt * ((dx > 0) ? rspeed : lspeed);
      dx = obs.x - x;
      dt = 0.0;
      Log.select.log('DIST $name dx=${zzz(dx)}, x=${zzz(x)}');
    }
    return math.sqrt(dx * dx + dt * dt + dz * dz);
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    double dt = transform.max.t - ptObs.t;
    Point pt1 = Point(x: ptObs.x + rspeed * dt, t: ptObs.t + dt);
    Point pt2 = Point(x: ptObs.x + lspeed * dt, t: ptObs.t + dt);
    Paint paint = getPaint(isSelected);
    Offset c = transform.toScreen(ptObs);
    Offset c1 = transform.toScreen(pt1);
    Offset c2 = transform.toScreen(pt2);
    canvas.drawLine(c, c1, paint);
    canvas.drawLine(c, c2, paint);
    double radius = SceneView.dotSize.value;
    textPainter.paint(canvas, Offset(c.dx + radius, c.dy));
    Log.update.log('Painting cone $this');
  }

  @override
  void paintHighlight(
    Canvas canvas,
    CoordinateTransform transform,
    Paint highlightPaint,
  ) {
    double dt = transform.max.t - ptObs.t;
    Point pt1 = Point(x: ptObs.x + rspeed * dt, t: ptObs.t + dt);
    Point pt2 = Point(x: ptObs.x + lspeed * dt, t: ptObs.t + dt);
    Offset c = transform.toScreen(ptObs);
    Offset c1 = transform.toScreen(pt1);
    Offset c2 = transform.toScreen(pt2);
    canvas.drawLine(c, c1, highlightPaint);
    canvas.drawLine(c, c2, highlightPaint);
    canvas.drawCircle(c, SceneView.dotSize.value + 3.0, highlightPaint);
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    Log.update.log('Painting Side cone $this');
    if (time < ptObs.t) return;
    Paint paint = getPaint(isSelected);
    double delta = time - ptObs.t;
    Point p1 = Point(x: ptObs.x + lspeed * delta, t: time, z: ptObs.z);
    Point p2 = Point(x: ptObs.x + rspeed * delta, t: time, z: ptObs.z);
    Offset c1 = transform.toSide(p1);
    Offset c2 = transform.toSide(p2);

    Offset a1 = c1 + const Offset(5, 5);
    Offset b1 = c1 + const Offset(5, -5);
    canvas.drawLine(a1, c1, paint);
    canvas.drawLine(b1, c1, paint);
    textPainter.paint(canvas, Offset(b1.dx + 4, b1.dy));
    Offset a2 = c2 + const Offset(-5, 5);
    Offset b2 = c2 + const Offset(-5, -5);
    canvas.drawLine(a2, c2, paint);
    canvas.drawLine(b2, c2, paint);
    textPainter.paint(canvas, Offset(c2.dx + 6, b2.dy));
  }

  @override
  void addToBounds(Bounds bounds) {
    // Go the left a bit, and down a bit for drawing the light cone.
    Point start = ptObs + Vector(dx: -1.0, dz: -.01);
    // And then go back to the right and up the same amount, and include
    // some forward in time.
    Vector delta = Vector(dx: 2.0, dt: 1.0, dz: 0.02);
    bounds.addBox(start, delta);
  }
}
