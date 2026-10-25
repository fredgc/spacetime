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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../menus.dart';
import '../printer.dart';
import '../scene.dart';
import '../sprites.dart';
import '../transform.dart';
import 'event.dart';
import 'instant.dart';
import 'light_cone.dart';
import 'location.dart';

enum DrawType implements HasShortcut {
  event('event', 'Event', 'E', LogicalKeyboardKey.keyE),
  instant('instant', 'Instant', 'I', LogicalKeyboardKey.keyI),
  cone('cone', 'Light Cone', 'L', LogicalKeyboardKey.keyL),
  clock('clock', 'Clock', 'C', LogicalKeyboardKey.keyC),
  person('person', 'Person', 'P', LogicalKeyboardKey.keyP),
  train('train', 'Train', 'T', LogicalKeyboardKey.keyT),
  barn('barn', 'Barn', 'B', LogicalKeyboardKey.keyB),
  flag('flag', 'Flag', 'F', LogicalKeyboardKey.keyF);

  final String label;
  final String prefix;
  final String json;
  final LogicalKeyboardKey key;

  const DrawType(this.json, this.label, this.prefix, this.key);

  @override
  String toString() => label;

  @override
  MenuSerializableShortcut? get shortcut =>
      SingleActivator(key, control: false);

  /// Create an object in frame1, at pt (in world coordinates).
  Drawable make(String name, ReferenceFrame frame1, int color) {
    // Make copy of frame before using it.
    ReferenceFrame frame = ReferenceFrame.from(frame1);
    switch (this) {
      case event:
        return Event(this, name, frame, color);
      case instant:
        return Instant(this, name, frame, color);
      case cone:
        return LightCone(this, name, frame, color);
      case clock:
        return Location(this, name, frame, color, Sprite.clock);
      case person:
        return Location(this, name, frame, color, Sprite.person);
      case train:
        return Location(this, name, frame, color, Sprite.train);
      case barn:
        return Location(this, name, frame, color, Sprite.barn);
      case flag:
        return Location(this, name, frame, color, Sprite.flag);
    }
  }
}

abstract class Drawable {
  int color;
  String name;
  Point get pt => frame.center; // Point in default frame.
  ReferenceFrame frame;
  DrawType type;

  Point ptObs = Point(); // Point in observer frame (changed in update).
  late TextPainter textPainter = getTextPainter();

  Drawable(this.type, this.name, this.frame, this.color);

  Drawable clone() => type.make(name, frame, color);

  void moveTo(Point p) {
    Log.mouseScale.log('Move $this');
    Log.mouseScale.log('   from ${zzz(frame.center)}');
    Log.mouseScale.log('     to ${zzz(p)}');
    frame.center = p;
    Log.mouseScale.log(' now $this');
  }

  void moveBy(Vector v) {
    frame.center = frame.center + v;
  }

  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    ptObs = transform.worldToObserver(pt);
    textPainter = getTextPainter();
  }

  TextPainter getTextPainter() {
    final style = TextStyle(
      color: SceneView.colorList.value[color],
      fontSize: 12,
    );
    var span = TextSpan(text: name, style: style);
    textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    textPainter.layout();
    return textPainter;
  }

  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected);
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  );

  void paintHighlight(
    Canvas canvas,
    CoordinateTransform transform,
    Paint highlightPaint,
  ) {
    paint(canvas, transform, true);
  }

  Paint getHighlightPaint(Color accentColor, double pulse) {
    final p = pulse.clamp(0.0, 1.0);
    double baseWidth = SceneView.lineWidth.value;
    return Paint()
      ..color = accentColor.withValues(alpha: p)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = baseWidth * (2.0 + 4.0 * p)
      ..maskFilter = p > 0.05
          ? MaskFilter.blur(BlurStyle.normal, 4.0 * p)
          : null;
  }

  Paint getPaint(bool isSelected) {
    Color c = SceneView.colorList.value[color];
    double baseWidth = SceneView.lineWidth.value;
    return Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? baseWidth * 2.0 : baseWidth;
  }

  /// Used to paint the sideview when the object is selected.
  Paint getSelectedPaint() {
    double baseWidth = SceneView.lineWidth.value;
    return Paint()
      ..color = SceneView.selectColor.value
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth * 1.5;
  }

  /// Find distance from pt to this drawable, in observer coordinates.
  double distance(Point obs, bool side);

  void addToBounds(Bounds bounds) {
    bounds.add(ptObs);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    Drawable d = other as Drawable;
    return color == d.color && name == d.name && pt == d.pt && frame == d.frame;
  }

  @override
  int get hashCode => Object.hash(color, name, pt, frame);

  void dumpDebugInfo() {
    Log.dump.log('$name: ${zzz(pt)} -> ${zzz(ptObs)}');
  }

  static int jsonColor(Map<String, dynamic> json) {
    return (json['color'] as num?)?.toInt() ?? 0;
  }

  factory Drawable.fromJson(Map<String, dynamic> json) {
    String type = json['type'].toLowerCase();
    String name = json['name'];
    Log.update.log('type=$type, name=$name');
    Log.update.log('frame = ${json['frame']}');
    var frameMap = json['frame'];
    var velocity = json['velocity']?.toDouble() ?? 0.0;
    var frame = (frameMap == null
        ? ReferenceFrame.fromV(velocity)
        : ReferenceFrame.fromJson(frameMap!));
    Log.update.log('color');
    int color = jsonColor(json);
    Log.update.log('type=$type, name=$name');
    for (var item in DrawType.values) {
      if (type == item.json) {
        return item.make(name, frame, color);
      }
    }
    throw FormatException("Unknown drawable type ${json['type']}");
  }

  factory Drawable.fromJsonLegacy(Map<String, dynamic> json) {
    String type = json['type'].toLowerCase();
    String name = json['name'];
    double velocity = json['transform']['velocity'].toDouble();
    String icon = json['icon_name'];
    bool clock = json['clock'];

    String colorName = json['color'];
    final List<String> legacyColors = [
      'black',
      'aqua',
      'blue',
      'fuchsia',
      'gray',
      'green',
      'lime',
      'maroon',
      'navy',
      'olive',
      'purple',
      'red',
      'silver',
      'teal',
      'white',
      'yellow',
    ];
    int color = legacyColors.indexOf(colorName);
    color = color % SceneView.colorList.value.length;

    var frame = ReferenceFrame.fromV(velocity);
    frame.center = Point.fromJson(json['coords']);

    Drawable drawable;
    if (type == 'event') {
      drawable = DrawType.event.make(name, frame, color);
    } else if (type == 'instant') {
      drawable = DrawType.instant.make(name, frame, color);
    } else if (type == 'cone') {
      drawable = DrawType.cone.make(name, frame, color);
    } else if (clock) {
      drawable = DrawType.clock.make(name, frame, color);
    } else if (icon == 'spot') {
      drawable = DrawType.flag.make(name, frame, color);
    } else if (icon == 'train') {
      drawable = DrawType.train.make(name, frame, color);
    } else if (icon == 'barn') {
      drawable = DrawType.barn.make(name, frame, color);
    } else if (icon == 'person') {
      drawable = DrawType.person.make(name, frame, color);
    } else {
      throw FormatException("Unknown drawable type ${json['type']}");
    }
    if (type == 'path') {
      final pts = (json['pts'] as List).cast<Map<String, dynamic>>();
      (drawable as Location).path = (pts
          .map<Point>((json) => Point.fromJson(json))
          .toList());
    }
    return drawable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.json,
    'name': name,
    'color': color,
    'frame': frame.toJson(),
  };

  @override
  String toString() {
    return '$name ($type) at ${zzz(pt)}. c=$color, f=${zzz(frame)}';
  }
}
