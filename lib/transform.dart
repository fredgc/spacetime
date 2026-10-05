import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

import "printer.dart";
import "scene.dart";
import "menus.dart";

part 'transform.g.dart';

/// Options for light speed physics model.
enum LightSpeed implements HasShortcut {
  lorentz(
    "Use Lorentz",
    LogicalKeyboardKey.keyL,
    "The speed of light is constant.",
  ),
  ether(
    "Use Ether",
    LogicalKeyboardKey.keyG,
    "The speed of light is relative to a preferred global frame.",
  ),
  emitter(
    "Use Emitter Speed",
    LogicalKeyboardKey.keyE,
    "The speed of light is relative to its emitter.",
  );

  final String name;
  final String tip;
  final LogicalKeyboardKey key;

  const LightSpeed(this.name, this.key, this.tip);
  @override
  String toString() => name;
  @override
  MenuSerializableShortcut? get shortcut => SingleActivator(key, control: true);
}

/// A point in space-time is a pair of space (x,z) and one time coordinate t.
/// With the default zoom, x is in the range -5 to 5 or so, and t is in the
/// range -2 to 8, and z is in the range 0 to 1.
@JsonSerializable()
class Point {
  final double x, t, z;
  Point({this.x = 0.0, this.t = 0.0, this.z = 0.0});
  Point.from(Point other) : x = other.x, t = other.t, z = other.z;

  /// Converts this point from default frame to target [frame].
  Point toFrame(ReferenceFrame frame, LightSpeed speed) {
    if (speed == LightSpeed.lorentz) {
      double x0 = frame.gamma * (x - frame.velocity * t);
      double t0 = frame.gamma * (t - frame.velocity * x);
      return Point(
        x: x0 - frame.center.x,
        t: t0 - frame.center.t,
        z: z - frame.center.z,
      );
    } else {
      double x0 = (x - frame.velocity * t);
      double t0 = t;
      return Point(
        x: x0 - frame.center.x,
        t: t0 - frame.center.t,
        z: z - frame.center.z,
      );
    }
  }

  /// Converts this point from specified [frame] to default frame.
  Point fromFrame(ReferenceFrame frame, LightSpeed speed) {
    double x0 = x + frame.center.x;
    double t0 = t + frame.center.t;
    double z0 = z + frame.center.z;
    if (speed == LightSpeed.lorentz) {
      return Point(
        x: frame.gamma * (x0 + frame.velocity * t0),
        t: frame.gamma * (t0 + frame.velocity * x0),
        z: z0,
      );
    } else {
      return Point(x: (x0 + frame.velocity * t0), t: t0, z: z0);
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    Point pt2 = other as Point;
    return x == pt2.x && t == pt2.t && z == pt2.z;
  }

  Point min(Point other) {
    return Point(
      x: math.min(x, other.x),
      t: math.min(t, other.t),
      z: math.min(z, other.z),
    );
  }

  Point max(Point other) {
    return Point(
      x: math.max(x, other.x),
      t: math.max(t, other.t),
      z: math.max(z, other.z),
    );
  }

  Point operator +(Vector delta) {
    return Point(x: x + delta.dx, t: t + delta.dt, z: z + delta.dz);
  }

  Vector operator -(Point other) {
    return Vector(dx: x - other.x, dt: t - other.t, dz: z - other.z);
  }

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
  Map<String, dynamic> toJson() => _$PointToJson(this);
  @override
  String toString() => zzz(this);
}

class Bounds {
  Point min;
  Point max;
  Bounds(this.min, this.max);
  void add(Point pt) {
    min = min.min(pt);
    max = max.max(pt);
  }

  void addBox(Point pt, Vector delta) {
    min = min.min(pt);
    max = max.max(pt + delta);
  }
}

/// A vector in spacetime (dx, dt, dz).
@JsonSerializable()
class Vector {
  final double dx, dt, dz;
  Vector({this.dx = 0.0, this.dt = 0.0, this.dz = 0.0});
  Vector.from(Vector other) : dx = other.dx, dt = other.dt, dz = other.dz;

  /// Converts vector from default frame to target [frame].
  Vector toFrame(ReferenceFrame frame, LightSpeed speed) {
    if (speed == LightSpeed.lorentz) {
      return Vector(
        dx: frame.gamma * (dx - frame.velocity * dt),
        dt: frame.gamma * (dt - frame.velocity * dx),
        dz: dz,
      );
    } else {
      return Vector(dx: dx - frame.velocity * dt, dt: dt, dz: dz);
    }
  }

  /// Converts vector from specified [frame] to default frame.
  Vector fromFrame(ReferenceFrame frame, LightSpeed speed) {
    if (speed == LightSpeed.lorentz) {
      return Vector(
        dx: frame.gamma * (dx + frame.velocity * dt),
        dt: frame.gamma * (dt + frame.velocity * dx),
        dz: dz,
      );
    } else {
      return Vector(dx: dx + frame.velocity * dt, dt: dt, dz: dz);
    }
  }

  Vector scale(double scale) {
    return Vector(dx: scale * dx, dt: scale * dt, dz: scale * dz);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    Vector pt2 = other as Vector;
    return dx == pt2.dx && dt == pt2.dt && dz == pt2.dz;
  }

  factory Vector.fromJson(Map<String, dynamic> json) => _$VectorFromJson(json);
  Map<String, dynamic> toJson() => _$VectorToJson(this);
  @override
  String toString() => zzz(this);
}

/// A local reference frame is specified by its velocity and center relative to
/// the default reference frame.
/// Computations will be looking at three different reference frames:
/// The default or global reference frame, from which all others are referenced.
/// Each object has its own local reference frame.
/// The screen or observer has a reference frame.
/// When the light speed is relative to the "ether", that refers to the default
/// or global reference frame.
@JsonSerializable()
class ReferenceFrame {
  Point center = Point(); // Center of this frame, relative to default.
  double _velocity = 0.0; // Velocity of this frame, relative to default.
  double _gamma = 1.0;
  double get gamma => _gamma;
  double get velocity => _velocity;

  set velocity(double v) {
    if (v > 0.999) v = 0.999; // Maximum gamma is 22.4.
    if (v < -0.999) v = -0.999;
    _velocity = v;
    _gamma = math.sqrt(1.0 / (1.0 - v * v));
  }

  ReferenceFrame();
  ReferenceFrame.fromV(double v) {
    velocity = v;
  }

  ReferenceFrame.from(ReferenceFrame other)
    : _velocity = other._velocity,
      _gamma = other._gamma,
      center = Point.from(other.center);

  ReferenceFrame.fromOffset(
    ReferenceFrame other,
    Point pt,
    LightSpeed lightSpeed,
  ) : _velocity = other._velocity,
      _gamma = other._gamma {
    center = pt.fromFrame(other, lightSpeed);
  }

  // TODO: Combine velocities:
  // v = (u+v)/(1+uv).  Is this needed?
  // Maybe when we add the ability to query an object, we'll want to know it's
  // velocity relative to the observer.

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    ReferenceFrame f2 = other as ReferenceFrame;
    return center == f2.center && _velocity == f2._velocity;
  }

  factory ReferenceFrame.fromJson(Map<String, dynamic> json) =>
      _$ReferenceFrameFromJson(json);
  Map<String, dynamic> toJson() => _$ReferenceFrameToJson(this);

  @override
  String toString() => zzz(this);
}

/// Transforms observer coordinates to screen canvas coordinates.
/// There are two canvases that we will be working with:
/// The top view, or main canvas, which displays (x,t).
/// The side view, or bottom canvas, which dislays (x, z).
/// Notice that x and t share a zoom factor.
class CoordinateTransform {
  Size size = Size(100, 100); // Screen size.
  double _sideHeight = 80.0; // height of side view window.
  ReferenceFrame frame = ReferenceFrame(); // Observer frame.
  // offset == screen coordintes mapped to by (0,0,0).
  Offset offset = Offset(50, 75);
  // Side view maps z=0 to (sideHeight - dz) pixels above bottom.
  double dz = 70;
  // This is the initial zoom value from world to screen. If you
  // change it, new scenes will be scaled differently.
  double zoom = 200.0;
  // Min and max points in observer coordinates.
  Point min = Point(x: -2, t: -2);
  Point max = Point(x: 2, t: 2);
  LightSpeed lightSpeed = LightSpeed.lorentz;

  CoordinateTransform();

  CoordinateTransform.from(CoordinateTransform other)
    : size = Size.copy(other.size),
      _sideHeight = other._sideHeight,
      frame = ReferenceFrame.from(other.frame),
      offset = Offset(other.offset.dx, other.offset.dy),
      dz = other.dz,
      zoom = other.zoom,
      min = Point.from(other.min),
      max = Point.from(other.max),
      lightSpeed = other.lightSpeed;

  double get sideHeight => _sideHeight;

  set sideHeight(double h) {
    // When changing the height, we still preserve how far off 0 maps to
    // relative to the bottom. That means we have to preserve side_height-dz.
    dz = h - (_sideHeight - dz);
    _sideHeight = h;
  }

  bool sizeChanged(Size size) {
    return size != this.size;
  }

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString() => "T${zzz(frame)} - ${zzz(offset)}, z=${zzz(zoom)}";

  /// Scales and pans the viewport based on gesture inputs.
  void doScale(Offset focus1, Offset focus2, double scale, bool side) {
    double dx = focus2.dx - focus1.dx;
    double dy = focus2.dy - focus1.dy;
    if (side) {
      offset = Offset(offset.dx + dx, offset.dy);
      dz = dz + dy;
      zoom = zoom * scale;
    } else {
      offset = Offset(offset.dx + dx, offset.dy + dy);
      zoom = zoom * scale;
    }
    findMax();
  }

  /// Resizes viewport screen dimensions.
  void resize(Size size) {
    Log.mouse_scale.log("YELLOW: transform size ${this.size} -> $size");
    if (size.width == 0) return;
    // Keep the relative percentage of the offset for the new offset.
    double dx = size.width * offset.dx / this.size.width;
    double dy = size.height * offset.dy / this.size.height;
    offset = Offset(dx, dy);
    this.size = size;
    findMax();
  }

  /// Recomputes min and max bounding points in observer coordinates.
  void findMax() {
    if (SceneView.use_debug_rect.value) {
      min = fromScreen(Offset(size.width * 0.10, size.height * 0.90));
      max = fromScreen(Offset(size.width * 0.90, size.height * 0.10));
    } else {
      min = fromScreen(Offset(0, size.height));
      max = fromScreen(Offset(size.width, 0));
    }
    min = fromSide(Offset(0, _sideHeight), min.t);
    max = fromSide(Offset(size.width, 0), max.t);
  }

  /// Fits viewport view bounds around [min] and [max] points.
  /// Adjust the coordinate transformation so that the screen is centered on
  /// these two points in the x and t direction. For the z direction we line up
  /// the minimum point with a base line that is 10 pixels above the bottom.
  void fit(Bounds bounds) {
    Log.fit.log("Fit to ${zzz(bounds)}");
    final double pad = 0.10;
    // Pad by 10% to make sure min & max are visible.
    double width = (1 + pad) * (bounds.max.x - bounds.min.x);
    double height = (1 + pad) * (bounds.max.t - bounds.min.t);
    if (width < 1e-3) width = 1.0;
    if (height < 1e-3) height = 1.0;
    zoom = math.min(size.width / width, size.height / height);

    // In side view, ground baseline is at (sideHeight - 10):
    // y = dz - pt.z * zoom
    // For min.z at baseline: dz = (sideHeight - 10) + min.z * zoom
    double depth = (1 + pad) * (bounds.max.z - bounds.min.z);
    double availableHeight = _sideHeight - 10.0;
    if (depth > 1e-3 && availableHeight > 0 && depth * zoom > availableHeight) {
      zoom = availableHeight / depth;
    }

    // Center viewport on min and max in x and t:
    offset = Offset(
      (size.width - (bounds.min.x + bounds.max.x) * zoom) / 2.0,
      (size.height + (bounds.min.t + bounds.max.t) * zoom) / 2.0,
    );

    dz = (_sideHeight - 10.0) + bounds.min.z * zoom;
    findMax();
  }

  bool inRange(Point pt) {
    return ((pt.x <= max.x) &&
        (pt.x >= min.x) &&
        (pt.t <= max.t) &&
        (pt.t >= min.t));
    // TODO: check z too? XXX
  }

  Point worldToObserver(Point pt) => pt.toFrame(frame, lightSpeed);
  Vector worldToObserverV(Vector v) => v.toFrame(frame, lightSpeed);
  Offset worldToScreen(Point pt) => toScreen(pt.toFrame(frame, lightSpeed));
  Offset worldToSide(Point pt) => toSide(pt.toFrame(frame, lightSpeed));

  /// From screen to observer reference frame.
  Point fromScreen(Offset pt) {
    return Point(x: (pt.dx - offset.dx) / zoom, t: (offset.dy - pt.dy) / zoom);
  }

  /// From screen delta to observer reference frame vector.
  Vector fromScreenDelta(Offset pt) {
    return Vector(dx: pt.dx / zoom, dt: -pt.dy / zoom);
  }

  /// From observer reference frame to screen.
  Offset toScreen(Point pt) {
    return Offset(offset.dx + pt.x * zoom, offset.dy - pt.t * zoom);
  }

  /// From observer reference frame to side view.
  Offset toSide(Point pt) {
    return Offset(offset.dx + pt.x * zoom, dz - pt.z * zoom);
  }

  /// To observer reference frame.
  Point fromSide(Offset off, double time) {
    double x = (off.dx - offset.dx) / zoom;
    double z = (dz - off.dy) / zoom;
    return Point(x: x, t: time, z: z);
  }

  /// From observer reference frame to screen.
  Offset toSideSize(double width, double height) {
    return Offset(width * zoom, height * zoom);
  }

  /// From screen delta to observer reference frame vector.
  Vector fromSideDelta(Offset pt) {
    return Vector(dx: pt.dx / zoom, dt: 0.0, dz: -pt.dy / zoom);
  }

  /// From screen offset to observer reference frame.
  Point fromOffset(Offset screen, double time, bool side) {
    return side ? fromSide(screen, time) : fromScreen(screen);
  }

  /// From screen offset to delta in observer reference frame.
  Vector fromDelta(Offset delta, bool side) {
    return side ? fromSideDelta(delta) : fromScreenDelta(delta);
  }

  String dumpDebugInfo() {
    return ("Transform (size $size, zoom = ${zzz(zoom)}, "
        "offset = ${zzz(offset)}, ${zzz(dz)},  h=${zzz(sideHeight)}\n"
        "frame = ${zzz(frame)}\n"
        "min = ${zzz(min)}, max = ${zzz(max)}");
  }
}
