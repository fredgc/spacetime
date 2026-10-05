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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import "printer.dart";
import "sprites.dart";
import "transform.dart";
import "scene.dart";
import "menus.dart";

enum DrawType implements HasShortcut {
  event("event", "Event", "E", LogicalKeyboardKey.keyE),
  instant("instant", "Instant", "I", LogicalKeyboardKey.keyI),
  cone("cone", "Light Cone", "L", LogicalKeyboardKey.keyL),
  clock("clock", "Clock", "C", LogicalKeyboardKey.keyC),
  person("person", "Person", "P", LogicalKeyboardKey.keyP),
  train("train", "Train", "T", LogicalKeyboardKey.keyT),
  barn("barn", "Barn", "B", LogicalKeyboardKey.keyB),
  flag("flag", "Flag", "F", LogicalKeyboardKey.keyF);

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

  // Create an object in frame1, at pt (in world coordinates).
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

  Point pt_obs = Point(); // Point in observer frame (changed in update).
  late TextPainter text_painter = getTextPainter();

  Drawable(this.type, this.name, this.frame, this.color);

  Drawable clone() => type.make(name, frame, color);

  void moveTo(Point p) {
    Log.mouse_scale.log("Move $this");
    Log.mouse_scale.log("   from ${zzz(frame.center)}");
    Log.mouse_scale.log("     to ${zzz(p)}");
    frame.center = p;
    Log.mouse_scale.log(" now $this");
  }

  void moveBy(Vector v) {
    frame.center = frame.center + v;
  }

  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    pt_obs = transform.worldToObserver(pt);
    text_painter = getTextPainter();
  }

  TextPainter getTextPainter() {
    final style = TextStyle(
      color: SceneView.color_list.value[color],
      fontSize: 12,
    );
    var span = TextSpan(text: name, style: style);
    text_painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    text_painter.layout();
    return text_painter;
  }

  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected);
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  );

  Paint getPaint(bool isSelected) {
    Color c = SceneView.color_list.value[color];
    double baseWidth = SceneView.line_width.value;
    return Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? baseWidth * 2.0 : baseWidth;
  }

  // Used to paint the sideview when the object is selected.
  Paint getSelectedPaint() {
    double baseWidth = SceneView.line_width.value;
    return Paint()
      ..color = SceneView.select_color.value
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth * 1.5;
  }

  // Find distance from pt to this drawable, in observer coordinates.
  double distance(Point obs, bool side);

  void addToBounds(Bounds bounds) {
    bounds.add(pt_obs);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    Drawable d = other as Drawable;
    return color == d.color && name == d.name && pt == d.pt && frame == d.frame;
  }

  void dumpDebugInfo() {
    Log.dump.log("$name: ${zzz(pt)} -> ${zzz(pt_obs)}");
  }

  static int jsonColor(Map<String, dynamic> json) {
    return (json['color'] as num?)?.toInt() ?? 0;
  }

  factory Drawable.fromJson(Map<String, dynamic> json) {
    String type = json['type'].toLowerCase();
    String name = json['name'];
    Log.update.log("type=$type, name=$name");
    Log.update.log("frame = ${json['frame']}");
    // XXX This is to support v1.0.1 which did not put a velocity on events.
    // XXX Is it really needed?
    var frameMap = json['frame'];
    var velocity = json['velocity']?.toDouble() ?? 0.0;
    var frame = (frameMap == null
        ? ReferenceFrame.fromV(velocity)
        : ReferenceFrame.fromJson(frameMap!));
    Log.update.log("color");
    int color = jsonColor(json);
    Log.update.log("type=$type, name=$name");
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
    double velocity = json["transform"]["velocity"].toDouble();
    String icon = json["icon_name"];
    bool clock = json["clock"]; //XXX handle this.
    // color_list, icon_list, item_name, clock_check, center_check.

    String colorName = json["color"];
    final List<String> legacyColors = [
      "black",
      "aqua",
      "blue",
      "fuchsia",
      "gray",
      "green",
      "lime",
      "maroon",
      "navy",
      "olive",
      "purple",
      "red",
      "silver",
      "teal",
      "white",
      "yellow",
    ];
    int color = legacyColors.indexOf(colorName);
    color = color % SceneView.color_list.value.length;

    // icon list: spot, train, barn, person,
    // clock check just changes text being printed. XXX add to new method?
    // center: I think this makes time follow this item?

    // type: event, instant, location, cone, path
    // XXX handle path.

    var frame = ReferenceFrame.fromV(velocity);
    frame.center = Point.fromJson(json["coords"]);

    Drawable drawable;
    if (type == "event") {
      drawable = DrawType.event.make(name, frame, color);
    } else if (type == "instant") {
      drawable = DrawType.instant.make(name, frame, color);
    } else if (type == "cone") {
      drawable = DrawType.cone.make(name, frame, color);
    } else if (clock) {
      // XXX handle type == path or location.
      drawable = DrawType.clock.make(name, frame, color);
    } else if (icon == "spot") {
      // XXX handle type == path or location.
      drawable = DrawType.flag.make(name, frame, color);
    } else if (icon == "train") {
      drawable = DrawType.train.make(name, frame, color);
    } else if (icon == "barn") {
      drawable = DrawType.barn.make(name, frame, color);
    } else if (icon == "person") {
      drawable = DrawType.person.make(name, frame, color);
    } else {
      throw FormatException("Unknown drawable type ${json['type']}");
    }
    if (type == "path") {
      final pts = (json["pts"] as List).cast<Map<String, dynamic>>();
      (drawable as Location).path = (pts
          .map<Point>((json) => Point.fromJson(json))
          .toList());
    }
    return drawable;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    "type": type.json,
    "name": name,
    "color": color,
    "frame": frame.toJson(),
  };

  @override
  String toString() {
    return "$name ($type) at ${zzz(pt)}. c=$color, f=${zzz(frame)}";
  }
}

class Event extends Drawable {
  Event(super.type, super.name, super.frame, super.color);

  @override
  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    await super.update(transform, time, sticky);
    sticky.add(pt_obs.t);
  }

  @override
  double distance(Point obs, bool side) {
    double dx = obs.x - pt_obs.x;
    double dt = obs.t - pt_obs.t;
    // Take into account dz when looking at side view.
    double dz = side ? obs.z - pt_obs.z : 0.0;
    return math.sqrt(dx * dx + dt * dt + dz * dz);
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    Paint paint = getPaint(isSelected);
    Offset c = transform.toScreen(pt_obs);
    double radius = SceneView.dot_size.value;
    canvas.drawCircle(c, radius, paint);
    text_painter.paint(
      canvas,
      Offset(c.dx + radius, c.dy - text_painter.height),
    );
    Log.update.log("Painting event $this");
    Log.update.log("   c = ${zzz(c)}, radius = ${zzz(radius)}");
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    Log.update.log("Painting Side event $this");
    double timeDelta = (time - pt_obs.t).abs();
    if (timeDelta > SceneView.fade_time.value) return;
    var radius =
        SceneView.dot_size.value *
        (SceneView.fade_time.value - timeDelta) /
        SceneView.fade_time.value;
    Paint paint = getPaint(isSelected);
    Offset c = transform.toSide(pt_obs);
    Log.update.log("pt = ${zzz(pt_obs)}, c = ${zzz(c)}, raduis=${zzz(radius)}");
    if (timeDelta < SceneView.fade_time.value * 0.01) {
      paint.style = PaintingStyle.fill;
    }
    if (isSelected) {
      canvas.drawRect(
        Rect.fromCenter(center: c, width: radius * 2, height: radius * 2),
        getSelectedPaint(),
      );
    }
    canvas.drawCircle(c, radius, paint);
    text_painter.paint(
      canvas,
      Offset(c.dx + radius, c.dy - text_painter.height),
    );
  }
}

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
    sticky.add(pt_obs.t);
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
    double dz = side ? obs.z - pt_obs.z : 0.0;
    double dt = obs.t - pt_obs.t;
    // If below the light cone, just return the distance to the initial point.
    double dx = obs.x - pt_obs.x;
    Log.select.log("DIST $name dx=${zzz(dx)}, dt=${zzz(dt)}, dz=${zzz(dz)}");
    // Otherwise, recompute dx as the distance to the closest light beam.
    if (dt > 0) {
      double x = pt_obs.x + dt * ((dx > 0) ? rspeed : lspeed);
      dx = obs.x - x;
      dt = 0.0;
      Log.select.log("DIST $name dx=${zzz(dx)}, x=${zzz(x)}");
    }
    return math.sqrt(dx * dx + dt * dt + dz * dz);
    // TODO: in the side view, this only allows clicking on the point of the
    // arrows.  It should allow anything within the box of the arrow, like we do
    // for a location.
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    double dt = transform.max.t - pt_obs.t;
    Point pt1 = Point(x: pt_obs.x + rspeed * dt, t: pt_obs.t + dt);
    Point pt2 = Point(x: pt_obs.x + lspeed * dt, t: pt_obs.t + dt);
    Paint paint = getPaint(isSelected);
    Offset c = transform.toScreen(pt_obs);
    Offset c1 = transform.toScreen(pt1);
    Offset c2 = transform.toScreen(pt2);
    canvas.drawLine(c, c1, paint);
    canvas.drawLine(c, c2, paint);
    double radius = SceneView.dot_size.value;
    text_painter.paint(canvas, Offset(c.dx + radius, c.dy));
    Log.update.log("Painting cone $this");
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    Log.update.log("Painting Side cone $this");
    if (time < pt_obs.t) return;
    Paint paint = getPaint(isSelected);
    double delta = time - pt_obs.t;
    Point p1 = Point(x: pt_obs.x + lspeed * delta, t: time, z: pt_obs.z);
    Point p2 = Point(x: pt_obs.x + rspeed * delta, t: time, z: pt_obs.z);
    Offset c1 = transform.toSide(p1);
    Offset c2 = transform.toSide(p2);

    Offset a1 = c1 + Offset(5, 5);
    Offset b1 = c1 + Offset(5, -5);
    canvas.drawLine(a1, c1, paint);
    canvas.drawLine(b1, c1, paint);
    text_painter.paint(canvas, Offset(b1.dx + 4, b1.dy));
    Offset a2 = c2 + Offset(-5, 5);
    Offset b2 = c2 + Offset(-5, -5);
    canvas.drawLine(a2, c2, paint);
    canvas.drawLine(b2, c2, paint);
    text_painter.paint(canvas, Offset(c2.dx + 6, b2.dy));
  }

  @override
  void addToBounds(Bounds bounds) {
    // Go the left a bit, and down a bit for drawing the light cone.
    Point start = pt_obs + Vector(dx: -1.0, dz: -.01);
    // And then go back to the right and up the same amount, and include
    // some forward in time.
    Vector delta = Vector(dx: 2.0, dt: 1.0, dz: 0.02);
    bounds.addBox(start, delta);
  }
}

class Instant extends Drawable {
  Vector v = Vector(); // Direction [0, 1] in local frame.
  Vector v_obs = Vector(); // Direction converted to observer frame.
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
    sticky.add(pt_obs.t);
    v = Vector(dt: 0.0, dx: 1.0).fromFrame(frame, transform.lightSpeed);
    v_obs = transform.worldToObserverV(v);
    // For an instant, we expect dt to be small. When drawing the side view, if
    // it is very small, we treat this as a horizontal line bigger than the
    // screen.
    if (v_obs.dt.abs() < 0.01) {
      horizontal = true;
    } else {
      horizontal = false;
      // Otherwise, it is a horizontal line with width depending on how big dt is.
      // Direction of the line is v_obs, i.e. slope of v.dx / v.dt.
      // Pick a dt = fade_time, so that dx = fade_time * v.dx / v.dt.
      radius = SceneView.fade_time.value * v_obs.dx / v_obs.dt;
    }
    // Log.mouse_scale.log("Update $name. h=$horizontal. r=${zzz(radius)}, v=${zzz(v_obs)}, fade=${zzz(SceneView.fade_time.value)}");
    // Log.mouse_scale.log("     pt = ${zzz(pt_obs)}");
    // XXX
  }

  @override
  double distance(Point obs, bool side) {
    // Take into account dz when looking at side view.
    double dz = side ? obs.z - pt_obs.z : 0.0;
    double dx = obs.x - pt_obs.x;
    double dt = obs.t - pt_obs.t;
    // Convert to coordinate system v_obs, perp(v_obs).
    // a = delta * v_obs / det,  b = delta * perp(v_obs) / det
    // det = |v_obs|^2.
    double det = v_obs.dx * v_obs.dx + v_obs.dt * v_obs.dt;
    // double a = (v_obs.dx * dx + v_obs.dt * dt) / det;
    double b = (v_obs.dt * dx - v_obs.dx * dt) / det;
    // Log.mouse_scale.log("DIST $name dx=${zzz(dx)}, dt=${zzz(dt)}, a=${zzz(a)}, b=${zzz(b)}");
    return math.sqrt(b * b + dz * dz);
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    // Draw the line pt_obs + s * v_obs = (x + s*dx, t + s*dt) from
    // x1 = transform.min.x to x2 = transform.max.x
    final double x1 = transform.min.x;
    final double x2 = transform.max.x;
    // x1 = x + s1*dx -> s1 = (x1 - x) / dx;
    // t1 = t + (x1-x)*dt/dx
    final double t1 = pt_obs.t + (x1 - pt_obs.x) * v_obs.dt / v_obs.dx;
    // Same for t2:
    final double t2 = pt_obs.t + (x2 - pt_obs.x) * v_obs.dt / v_obs.dx;
    Paint paint = getPaint(isSelected);
    Offset c1 = transform.toScreen(Point(t: t1, x: x1));
    Offset c2 = transform.toScreen(Point(t: t2, x: x2));
    canvas.drawLine(c1, c2, paint);
    text_painter.paint(canvas, transform.toScreen(pt_obs));
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    Log.update.log("Painting Side instant $this");
    double timeDelta = (time - pt_obs.t);
    if (horizontal) {
      // If the instant is close to an instant in this time frame, we draw a
      // horizontal line.
      if (timeDelta.abs() > SceneView.fade_time.value) return;
      var height =
          (SceneView.dot_size.value *
          0.5 *
          (SceneView.fade_time.value - timeDelta) /
          SceneView.fade_time.value);
      Paint paint = getPaint(isSelected);
      Offset c = transform.toSide(pt_obs);
      Offset right = transform.toSide(transform.max);
      if (timeDelta < SceneView.fade_time.value * 0.01) {
        paint.style = PaintingStyle.fill;
      }
      canvas.drawRect(Rect.fromLTWH(0.0, c.dy, right.dx, height), paint);
      text_painter.paint(canvas, Offset(2, c.dy + 4));
    } else {
      Paint paint = getPaint(isSelected);
      double center = pt_obs.x + ((time - pt_obs.t) * v_obs.dx / v_obs.dt);
      Point left = Point(x: center - radius, t: pt_obs.t, z: pt_obs.z);
      Point right = Point(x: center + radius, t: pt_obs.t, z: pt_obs.z);
      Offset l = transform.toSide(left);
      Offset r = transform.toSide(right);
      canvas.drawLine(l, r, paint);
      text_painter.paint(canvas, r);
    }
  }

  @override
  void dumpDebugInfo() {
    super.dumpDebugInfo();
    Log.dump.log("   v=${zzz(v)} -> v_obs=${zzz(v_obs)}");
  }
}

class Location extends Drawable {
  Sprite sprite;
  Vector v = Vector(); // Direction [1, 0] in local converted to global frame.
  Vector v_obs = Vector(); // Direction converted to observer frame.
  // Direction [0, 1] in local frame converted to global frame.
  // For drawing horizontal lines.
  // XXX
  // Vector h = Vector();
  // Vector h_obs = Vector(); // Direction converted to observer frame.
  double width, height; // Height/Width in location's frame.
  double contracted_width;
  List<Point>? path;

  Location(super.type, super.name, super.frame, super.color, this.sprite)
    : width = sprite.width,
      height = sprite.height,
      contracted_width = sprite.width;

  @override
  Future<void> update(
    CoordinateTransform transform,
    double time,
    List<double> sticky,
  ) async {
    await super.update(transform, time, sticky);
    // XXX handle path.
    if (transform.lightSpeed == LightSpeed.lorentz) {
      double v = frame.velocity;
      double u = transform.frame.velocity;
      double w = (v - u) / (1.0 - u * v); //Relative velocity.
      double gammaInv = math.sqrt(1.0 - w * w);
      contracted_width = width * gammaInv;
    } else {
      contracted_width = width;
    }

    // // Update vertical direction.
    v = Vector(dt: 1.0, dx: 0.0).fromFrame(frame, transform.lightSpeed);
    v_obs = transform.worldToObserverV(v);
  }

  @override
  double distance(Point obs, bool side) {
    if (side) {
      // XXX -- this should be obs.z - nearest z.
      // XXX -- same for obs.x - nearest x, or use width like for instant.
      double xLoc =
          pt_obs.x +
          (v_obs.dt != 0.0 ? (obs.t - pt_obs.t) * v_obs.dx / v_obs.dt : 0.0);
      double dx = 0.0;
      if (sprite.isWide) {
        if (obs.x < xLoc) {
          dx = xLoc - obs.x;
        } else if (obs.x > xLoc + contracted_width) {
          dx = obs.x - (xLoc + contracted_width);
        }
      } else {
        double halfW = contracted_width / 2.0;
        if (obs.x < xLoc - halfW) {
          dx = (xLoc - halfW) - obs.x;
        } else if (obs.x > xLoc + halfW) {
          dx = obs.x - (xLoc + halfW);
        }
      }
      double dz = 0.0;
      if (obs.z < pt_obs.z) {
        dz = pt_obs.z - obs.z;
      } else if (obs.z > pt_obs.z + height) {
        dz = obs.z - (pt_obs.z + height);
      }
      return math.sqrt(dx * dx + dz * dz);
    }
    double dx = obs.x - pt_obs.x;
    double dt = obs.t - pt_obs.t;
    // Convert to coordinate system v_obs, perp(v_obs).
    // a = delta * v_obs / det,  b = delta * perp(v_obs) / det
    // det = |v_obs|^2.
    double det = v_obs.dx * v_obs.dx + v_obs.dt * v_obs.dt;
    // double a = (v_obs.dx * dx + v_obs.dt * dt) / det;
    double b = (v_obs.dt * dx - v_obs.dx * dt) / det;
    // String extra = "";
    if (sprite.isWide) {
      // extra = ", w = ${zzz(contracted_width)}";
      if (b > contracted_width / 2.0) return (b - contracted_width).abs();
    }
    // Log.mouse_scale.log(
    //   "DIST $name dx=${zzz(dx)}, dt=${zzz(dt)}, a=${zzz(a)}, "
    //   "b=${zzz(b)}. width=${zzz(width)}$extra",
    // );
    return b.abs();
  }

  @override
  void addToBounds(Bounds bounds) {
    Vector delta = Vector(dx: sprite.width, dz: sprite.height);
    bounds.addBox(pt_obs, delta);
  }

  @override
  void paint(Canvas canvas, CoordinateTransform transform, bool isSelected) {
    Log.update.log("Painting $this");
    // This is like Instant.paint, except with a more vertical line, so
    // we use dx/dt instead of dt/dx.
    // Draw the line pt_obs + s * v_obs = (x + s*dx, t + s*dt) from
    // t1 = transform.min.t to t2 = transform.max.t
    final double tmin = transform.min.t;
    final double tmax = transform.max.t;
    Point pmin = findPoint(tmin, transform);
    Point pmax = findPoint(tmax, transform);
    Paint paint = getPaint(isSelected);
    Offset cmin = transform.toScreen(pmin);
    Offset cmax = transform.toScreen(pmax);
    canvas.drawLine(cmin, cmax, paint);
    Log.update.log("------------- sprite.width = ${zzz(sprite.width)}");
    if (sprite.isWide) {
      final double dx = contracted_width;
      Log.update.log("Rest of this ${zzz(pmin.x)} -> ${zzz(pmin.x + dx)}.");
      Offset cmin2 = transform.toScreen(Point(t: pmin.t, x: pmin.x + dx));
      Offset cmax2 = transform.toScreen(Point(t: pmax.t, x: pmax.x + dx));
      canvas.drawLine(cmin2, cmax2, paint);
    }
    Offset c = transform.toScreen(pt_obs);
    text_painter.paint(
      canvas,
      Offset(c.dx + 5, c.dy - text_painter.height * 0.5),
    );
  }

  @override
  void paintSide(
    Canvas canvas,
    CoordinateTransform transform,
    double time,
    bool isSelected,
  ) {
    // XXX -- review this. It looks non-optimal, and maybe incorrect.
    Log.update.log("Paint side of $this");
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
      color: SceneView.color_list.value[color],
      fontSize: 12,
    );
    String displayText = name;
    if (sprite == Sprite.clock && SceneView.show_clock_time.value) {
      displayText = "$name (t=${properTime.toStringAsFixed(2)})";
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

  // Find the coordinate of this object, at the specified time, in observer coord.
  // This should only be called after update.
  Point findPoint(double time, CoordinateTransform transform) {
    // x = cx + (t-ct)*dx/dt
    double dx = (time - pt_obs.t) * v_obs.dx / v_obs.dt;
    return Point(x: pt_obs.x + dx, t: time, z: pt_obs.z);
  }

  // Find the bounds of this object in the side view.
  Rect findBounds(double time, CoordinateTransform transform) {
    // Recompute just for debugging.
    if (true) {
      // Update horizontal and vertical directions.
      v = Vector(dt: 1.0, dx: 0.0).fromFrame(frame, transform.lightSpeed);
      v_obs = transform.worldToObserverV(v);
      // h = Vector(dt: 0.0, dx: 1.0).fromFrame(frame, transform.lightSpeed);
      // h_obs = transform.worldToObserverV(h);
      // Log.update.log("YELLOW: $name h=${zzz(v)} -> ${zzz(h_obs)}");
    }

    Point p = findPoint(time, transform);
    Offset c = transform.toSide(p);
    Offset box = transform.toSideSize(contracted_width, height);
    double left = sprite.isWide ? c.dx : c.dx - box.dx / 2;
    double top = c.dy - box.dy;
    Log.update.log(
      " contracted_width = ${zzz(contracted_width)}, "
      "box=${zzz(box)}, t=${zzz(time - pt_obs.t)}",
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
  void dumpDebugInfo() {
    super.dumpDebugInfo();
    Log.dump.log("   ${zzz(v)} -> ${zzz(v_obs)} -- XXX");
  }

  @override
  String toString() {
    return "$name ($sprite) at ${zzz(pt)}, c=$color, f=${zzz(frame)}";
  }
}
