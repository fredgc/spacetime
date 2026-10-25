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

class Event extends Drawable {
  Event(super.type, super.name, super.frame, super.color);

  @override
  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    await super.update(transform, time, sticky);
    sticky.add(ptObs.t);
  }

  @override
  double distance(Point obs, bool side) {
    double dx = obs.x - ptObs.x;
    double dt = obs.t - ptObs.t;
    // Take into account dz when looking at side view.
    double dz = side ? obs.z - ptObs.z : 0.0;
    return math.sqrt(dx * dx + dt * dt + dz * dz);
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    Paint paint = getPaint(isSelected);
    Offset c = transform.toScreen(ptObs);
    double radius = SceneView.dotSize.value;
    canvas.drawCircle(c, radius, paint);
    textPainter.paint(canvas, Offset(c.dx + radius, c.dy - textPainter.height));
    Log.update.log('Painting event $this');
    Log.update.log('   c = ${zzz(c)}, radius = ${zzz(radius)}');
  }

  @override
  void paintHighlight(
    Canvas canvas,
    CoordinateTransform transform,
    Paint highlightPaint,
  ) {
    Offset c = transform.toScreen(ptObs);
    double radius = SceneView.dotSize.value;
    canvas.drawCircle(c, radius + 4.0, highlightPaint);
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    Log.update.log('Painting Side event $this');
    double timeDelta = (time - ptObs.t).abs();
    if (timeDelta > SceneView.fadeTime.value) return;
    var radius =
        SceneView.dotSize.value *
        (SceneView.fadeTime.value - timeDelta) /
        SceneView.fadeTime.value;
    Paint paint = getPaint(isSelected);
    Offset c = transform.toSide(ptObs);
    Log.update.log('pt = ${zzz(ptObs)}, c = ${zzz(c)}, raduis=${zzz(radius)}');
    if (timeDelta < SceneView.fadeTime.value * 0.01) {
      paint.style = PaintingStyle.fill;
    }
    if (isSelected) {
      canvas.drawRect(
        Rect.fromCenter(center: c, width: radius * 2, height: radius * 2),
        getSelectedPaint(),
      );
    }
    canvas.drawCircle(c, radius, paint);
    textPainter.paint(canvas, Offset(c.dx + radius, c.dy - textPainter.height));
  }
}
