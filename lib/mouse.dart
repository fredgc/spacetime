import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import "drawable.dart";
import 'transform.dart';
import 'scene.dart';
import 'printer.dart';
import 'edit.dart';

// On scroll wheel. do scale.
// on tap down. save starting point.
// on tap up. let scene.tool handle it.
// on scale start. decide if it is move object or scale transform.
// on scale update. deal with it.
// on scale end. deal with it.

class MouseListener {
  final SceneView scene_viewer;
  final bool side;
  MyScaleListener? scaler;
  Offset start = Offset(0, 0);
  bool repeat = false; // This is true when a user taps at the same spot.

  MouseListener(this.scene_viewer, this.side) {
    Log.mouse_scale.log("XXX -- created new mouse listener.");
  }

  Widget build(BuildContext context, Widget child) {
    return Listener(
      onPointerSignal: (PointerSignalEvent pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          onScrollWheel(pointerSignal, side: side);
        }
      },
      child: GestureDetector(
        onTapDown: (info) {
          // If this tap down is very close to the previous, then
          // we assume it is a second tap -- which means we should not
          // reselect the current object.
          final oldStart = start;
          final dis = (info.localPosition - start).distance; //XXX
          repeat = ((info.localPosition - start).distance < 5.0);
          // Save the starting point for scaling.
          start = info.localPosition;
          Log.select.log(
            "BLUE: onTapDown side=$side, repeat=$repeat, "
            "start=${zzz(start)}, old=${zzz(oldStart)}",
          );
        },
        onScaleStart: (info) {
          Point? pt =
              scene_viewer.nearSelected(start, side) ??
              scene_viewer.nearSelected(info.localFocalPoint, side);
          Log.mouse_scale.log(
            "BLUE: onScaleStart. start pt=${zzz(pt)}, side=$side, count=${info.pointerCount}",
          );
          Log.mouse_scale.log("start = ${zzz(start)}");
          Log.mouse_scale.log("focal = ${zzz(info.localFocalPoint)}");
          Log.mouse_scale.log("pt = ${zzz(pt)}");
          if (info.pointerCount == 1 && pt != null) {
            var mover = MyObjectMover(
              scene_viewer,
              side,
              pt,
              scene_viewer.selected!,
              info.localFocalPoint,
            );
            scaler = mover;
          } else {
            scaler = MyScaleTransform(scene_viewer, side, info.localFocalPoint);
          }
        },
        onScaleUpdate: (info) => scaler?.update(info),
        onScaleEnd: (info) {
          Log.mouse_scale.log(
            "BLUE: onScaleEnd. velocity= ${zzz(info.velocity)}",
          );
          scaler?.end(info);
          scaler = null;
        },
        onTapUp: (info) => scene_viewer.onTap(info.localPosition, side, repeat),
        child: child,
      ),
    );
  }

  void onScrollWheel(PointerScrollEvent event, {bool side = false}) {
    MyScaleTransform s = MyScaleTransform(
      scene_viewer,
      side,
      event.localPosition,
    );
    double scrollScreen = event.scrollDelta.dx - event.scrollDelta.dy;
    double scale = math.exp(scrollScreen / 400.0);
    s.doScale(event.localPosition, scale);
  }
}

abstract class MyScaleListener {
  bool side;
  SceneView scene_viewer;

  MyScaleListener(this.scene_viewer, this.side);
  void update(ScaleUpdateDetails info);
  void end(ScaleEndDetails info);
}

class MyScaleTransform extends MyScaleListener {
  Offset focus;
  double previous_scale = 1.0;

  MyScaleTransform(super.scene_viewer, super.side, this.focus) {
    Log.mouse_scale.log("Scale start. side=$side, focus = ${zzz(focus)}");
  }

  @override
  void update(ScaleUpdateDetails info) {
    doScale(info.localFocalPoint, info.scale);
  }

  void doScale(Offset focus2, double scale) {
    double zoom = scale / previous_scale;
    Log.mouse_scale.log(
      "Zoom ${zzz(zoom)} = ${zzz(scale)} / ${zzz(previous_scale)}, "
      "p1 = ${zzz(focus)}, p2 = ${zzz(focus2)}",
    );
    scene_viewer.doScale(focus, focus2, zoom, side);
    focus = focus2;
    previous_scale = scale;
  }

  @override
  void end(ScaleEndDetails info) {
    Log.mouse_scale.log("BLUE: Scale end. ");
  }
}

class MyObjectMover extends MyScaleListener {
  // Where the pointer started, in observer coordinates.
  Point pointer1;
  Drawable object;
  // Where the selected object started, in world coordinates.
  Point objStart;
  Offset lastFocalPoint;

  MyObjectMover(
    super.scene_viewer,
    super.side,
    this.pointer1,
    this.object,
    this.lastFocalPoint,
  ) : objStart = Point.from(object.pt);

  @override
  void update(ScaleUpdateDetails info) {
    Offset delta = info.localFocalPoint - lastFocalPoint;
    lastFocalPoint = info.localFocalPoint;
    moveBy(delta);
  }

  void moveBy(Offset delta) {
    Log.mouse_scale.log("ObjectMover delta = ${zzz(delta)}");
    Vector obs = scene_viewer.data.transform.fromDelta(delta, side);
    Vector world = obs.fromFrame(
      scene_viewer.data.transform.frame,
      scene_viewer.light_speed.value,
    );
    Log.mouse_scale.log("ObjMover. delta=${zzz(delta)}, obs=${zzz(obs)}");
    Log.mouse_scale.log("         world=${zzz(world)}");
    object.moveBy(world);
    scene_viewer.updateScene();
  }

  @override
  void end(ScaleEndDetails info) {
    final Point p1 = objStart;
    final Point p2 = Point.from(object.pt);
    Log.mouse_scale.log(
      "ObjMover end. pt_obs=${object.pt_obs}, p1=${zzz(p1)}, p2 = ${zzz(p2)}",
    );
    final drawable = object;
    scene_viewer.undo_manager.add(
      Change<Point>("Point", p1, p2, (v) {
        Log.mouse_scale.log("do/undo move $drawable to $v.");
        drawable.moveTo(v);
        scene_viewer.updateScene();
        scene_viewer.file_manager.change();
      }),
    );
  }
}
