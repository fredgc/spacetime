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
  final SceneView sceneViewer;
  final bool side;
  MyScaleListener? scaler;
  Offset start = const Offset(0, 0);
  bool repeat = false; // This is true when a user taps at the same spot.

  MouseListener(this.sceneViewer, this.side) {
    Log.mouseScale.log("XXX -- created new mouse listener.");
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
              sceneViewer.nearSelected(start, side) ??
              sceneViewer.nearSelected(info.localFocalPoint, side);
          Log.mouseScale.log(
            "BLUE: onScaleStart. start pt=${zzz(pt)}, side=$side, count=${info.pointerCount}",
          );
          Log.mouseScale.log("start = ${zzz(start)}");
          Log.mouseScale.log("focal = ${zzz(info.localFocalPoint)}");
          Log.mouseScale.log("pt = ${zzz(pt)}");
          if (info.pointerCount == 1 && pt != null) {
            var mover = MyObjectMover(
              sceneViewer,
              side,
              pt,
              sceneViewer.selected!,
              info.localFocalPoint,
            );
            scaler = mover;
          } else {
            scaler = MyScaleTransform(sceneViewer, side, info.localFocalPoint);
          }
        },
        onScaleUpdate: (info) => scaler?.update(info),
        onScaleEnd: (info) {
          Log.mouseScale.log(
            "BLUE: onScaleEnd. velocity= ${zzz(info.velocity)}",
          );
          scaler?.end(info);
          scaler = null;
        },
        onTapUp: (info) => sceneViewer.onTap(info.localPosition, side, repeat),
        child: child,
      ),
    );
  }

  void onScrollWheel(PointerScrollEvent event, {bool side = false}) {
    MyScaleTransform s = MyScaleTransform(
      sceneViewer,
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
  SceneView sceneViewer;

  MyScaleListener(this.sceneViewer, this.side);
  void update(ScaleUpdateDetails info);
  void end(ScaleEndDetails info);
}

class MyScaleTransform extends MyScaleListener {
  Offset focus;
  double _previousScale = 1.0;

  MyScaleTransform(super.sceneViewer, super.side, this.focus) {
    Log.mouseScale.log("Scale start. side=$side, focus = ${zzz(focus)}");
  }

  @override
  void update(ScaleUpdateDetails info) {
    doScale(info.localFocalPoint, info.scale);
  }

  void doScale(Offset focus2, double scale) {
    double zoom = scale / _previousScale;
    Log.mouseScale.log(
      "Zoom ${zzz(zoom)} = ${zzz(scale)} / ${zzz(_previousScale)}, "
      "p1 = ${zzz(focus)}, p2 = ${zzz(focus2)}",
    );
    sceneViewer.doScale(focus, focus2, zoom, side);
    focus = focus2;
    _previousScale = scale;
  }

  @override
  void end(ScaleEndDetails info) {
    Log.mouseScale.log("BLUE: Scale end. ");
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
    super.sceneViewer,
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
    Log.mouseScale.log("ObjectMover delta = ${zzz(delta)}");
    Vector obs = sceneViewer.data.transform.fromDelta(delta, side);
    Vector world = obs.fromFrame(
      sceneViewer.data.transform.frame,
      sceneViewer.lightSpeed.value,
    );
    Log.mouseScale.log("ObjMover. delta=${zzz(delta)}, obs=${zzz(obs)}");
    Log.mouseScale.log("         world=${zzz(world)}");
    object.moveBy(world);
    sceneViewer.updateScene();
  }

  @override
  void end(ScaleEndDetails info) {
    final Point p1 = objStart;
    final Point p2 = Point.from(object.pt);
    Log.mouseScale.log(
      "ObjMover end. ptObs=${object.ptObs}, p1=${zzz(p1)}, p2 = ${zzz(p2)}",
    );
    final drawable = object;
    sceneViewer.undoManager.add(
      Change<Point>("Point", p1, p2, (v) {
        Log.mouseScale.log("do/undo move $drawable to $v.");
        drawable.moveTo(v);
        sceneViewer.updateScene();
        sceneViewer.fileManager.change();
      }),
    );
  }
}
