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
import '../sprites.dart';
import '../transform.dart';
import 'drawable.dart';

class Location extends Drawable {
  Sprite sprite;
  Vector v = Vector(); // Direction [1, 0] in local converted to global frame.
  Vector vObs = Vector(); // Direction converted to observer frame.
  double width, height; // Height/Width in location's frame.
  double contractedWidth;
  List<Point>? path;

  Location(super.type, super.name, super.frame, super.color, this.sprite)
    : width = sprite.width,
      height = sprite.height,
      contractedWidth = sprite.width;

  @override
  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    await super.update(transform, time, sticky);
    if (transform.lightSpeed == LightSpeed.lorentz) {
      double v = frame.velocity;
      double u = transform.frame.velocity;
      double w = (v - u) / (1.0 - u * v); // Relative velocity.
      double gammaInv = math.sqrt(1.0 - w * w);
      contractedWidth = width * gammaInv;
    } else {
      contractedWidth = width;
    }

    // Update vertical direction.
    v = Vector(dt: 1.0, dx: 0.0).fromFrame(frame, transform.lightSpeed);
    vObs = transform.worldToObserverV(v);
  }

  @override
  double distance(Point obs, bool side) {
    if (side) {
      double xLoc =
          ptObs.x +
          (vObs.dt != 0.0 ? (obs.t - ptObs.t) * vObs.dx / vObs.dt : 0.0);
      double dx = 0.0;
      if (sprite.isWide) {
        if (obs.x < xLoc) {
          dx = xLoc - obs.x;
        } else if (obs.x > xLoc + contractedWidth) {
          dx = obs.x - (xLoc + contractedWidth);
        }
      } else {
        double halfW = contractedWidth / 2.0;
        if (obs.x < xLoc - halfW) {
          dx = (xLoc - halfW) - obs.x;
        } else if (obs.x > xLoc + halfW) {
          dx = obs.x - (xLoc + halfW);
        }
      }
      double dz = 0.0;
      if (obs.z < ptObs.z) {
        dz = ptObs.z - obs.z;
      } else if (obs.z > ptObs.z + height) {
        dz = obs.z - (ptObs.z + height);
      }
      return math.sqrt(dx * dx + dz * dz);
    }
    double dx = obs.x - ptObs.x;
    double dt = obs.t - ptObs.t;
    // Convert to coordinate system vObs, perp(vObs).
    // a = delta * vObs / det,  b = delta * perp(vObs) / det
    // det = |vObs|^2.
    double det = vObs.dx * vObs.dx + vObs.dt * vObs.dt;
    double b = (vObs.dt * dx - vObs.dx * dt) / det;
    if (sprite.isWide) {
      if (b > contractedWidth / 2.0) return (b - contractedWidth).abs();
    }
    return b.abs();
  }

  @override
  void addToBounds(Bounds bounds) {
    Vector delta = Vector(dx: sprite.width, dz: sprite.height);
    bounds.addBox(ptObs, delta);
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    Log.update.log('Painting $this');
    final double tmin = transform.min.t;
    final double tmax = transform.max.t;
    Point pmin = findPoint(tmin, transform);
    Point pmax = findPoint(tmax, transform);
    Paint paint = getPaint(isSelected);
    Offset cmin = transform.toScreen(pmin);
    Offset cmax = transform.toScreen(pmax);
    canvas.drawLine(cmin, cmax, paint);
    Log.update.log('------------- sprite.width = ${zzz(sprite.width)}');
    if (sprite.isWide) {
      final double dx = contractedWidth;
      Log.update.log('Rest of this ${zzz(pmin.x)} -> ${zzz(pmin.x + dx)}.');
      Offset cmin2 = transform.toScreen(Point(t: pmin.t, x: pmin.x + dx));
      Offset cmax2 = transform.toScreen(Point(t: pmax.t, x: pmax.x + dx));
      canvas.drawLine(cmin2, cmax2, paint);
    }
    Offset c = transform.toScreen(ptObs);
    textPainter.paint(
      canvas,
      Offset(c.dx + 5, c.dy - textPainter.height * 0.5),
    );
  }

  @override
  void paintHighlight(
    Canvas canvas,
    CoordinateTransform transform,
    Paint highlightPaint,
  ) {
    final double tmin = transform.min.t;
    final double tmax = transform.max.t;
    Point pmin = findPoint(tmin, transform);
    Point pmax = findPoint(tmax, transform);
    Offset cmin = transform.toScreen(pmin);
    Offset cmax = transform.toScreen(pmax);
    canvas.drawLine(cmin, cmax, highlightPaint);
    if (sprite.isWide) {
      final double dx = contractedWidth;
      Offset cmin2 = transform.toScreen(Point(t: pmin.t, x: pmin.x + dx));
      Offset cmax2 = transform.toScreen(Point(t: pmax.t, x: pmax.x + dx));
      canvas.drawLine(cmin2, cmax2, highlightPaint);
    }
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    Log.update.log('Paint side of $this');
    Paint paint = getPaint(isSelected);
    Rect bounds = findBounds(time, transform);

    // Compute the proper time (local time of the object in its own reference frame)
    Point pObs = findPoint(time, transform);
    Point pWorld = pObs.fromFrame(transform.frame, transform.lightSpeed);
    Point pLocal = pWorld.toFrame(frame, transform.lightSpeed);
    double properTime = pLocal.t;

    sprite.paint(canvas, paint, bounds, properTime);
    if (isSelected) {
      canvas.drawRect(bounds, getSelectedPaint());
    }

    final style = TextStyle(
      color: SceneView.colorList.value[color],
      fontSize: 12,
    );
    String displayText = name;
    if (sprite == Sprite.clock && SceneView.showClockTime.value) {
      displayText = '$name (t=${properTime.toStringAsFixed(2)})';
    }

    final sideTextPainter = TextPainter(
      text: TextSpan(text: displayText, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    sideTextPainter.layout();

    sideTextPainter.paint(
      canvas,
      Offset(bounds.right + 3, bounds.bottom - sideTextPainter.height),
    );
  }

  /// Find the coordinate of this object, at the specified time, in observer coord.
  /// This should only be called after update.
  Point findPoint(double time, CoordinateTransform transform) {
    double dx = (time - ptObs.t) * vObs.dx / vObs.dt;
    return Point(x: ptObs.x + dx, t: time, z: ptObs.z);
  }

  /// Find the bounds of this object in the side view.
  Rect findBounds(double time, CoordinateTransform transform) {
    Point p = findPoint(time, transform);
    Offset c = transform.toSide(p);
    Offset box = transform.toSideSize(contractedWidth, height);
    double left = sprite.isWide ? c.dx : c.dx - box.dx / 2;
    double top = c.dy - box.dy;
    Log.update.log(
      ' contractedWidth = ${zzz(contractedWidth)}, '
      'box=${zzz(box)}, t=${zzz(time - ptObs.t)}',
    );
    return Rect.fromLTWH(left, top, box.dx, box.dy);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    if (!(super == (other))) return false;
    Location l = other as Location;
    return sprite == l.sprite;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, sprite);

  @override
  void dumpDebugInfo() {
    super.dumpDebugInfo();
    Log.dump.log('   ${zzz(v)} -> ${zzz(vObs)} -- XXX');
  }

  @override
  String toString() {
    return '$name ($sprite) at ${zzz(pt)}, c=$color, f=${zzz(frame)}';
  }
}
