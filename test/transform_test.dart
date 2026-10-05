import 'package:flutter/material.dart';

import 'package:test/test.dart';
import 'dart:math' as math;

import 'package:spacetime/transform.dart';
import 'package:spacetime/printer.dart';

import 'helper.dart';

void main() {
  group('points', () {
    test('arithmetic', () {
      Point a = Point(x: 1.0, t: 2.0, z: 3.0);
      Point b = Point(x: 40.0, t: 50.0, z: 60.0);
      Vector v = b - a;
      expect(v, VectorMatch(Vector(dx: 39.0, dt: 48.0, dz: 57.0)));
      expect(v.scale(2.0), VectorMatch(Vector(dx: 78.0, dt: 96.0, dz: 114.0)));

      math.Random random = math.Random();
      for (int i = 0; i < 25; i++) {
        Point p1 = makePoint(random);
        Point p2 = makePoint(random);
        Vector v = p1 - p2;
        Point p3 = p1 + v.scale(-1.0);
        String reason = "failed for p1=${zzz(p1)}, p2=${zzz(p2)}, v=${zzz(v)}";
        expect(p2, PointMatch(p3), reason: reason);
        Point p4 = p2 + v;
        expect(p1, PointMatch(p4), reason: reason);
      }
    });
  });
  group('frame', () {
    test('ranges', () {
      math.Random random = math.Random();
      for (int i = 0; i < 100; i++) {
        CoordinateTransform transform = makeTransform(random);
        final ReferenceFrame frame = transform.frame;
        expect(
          frame.velocity,
          lessThan(1.0),
          reason: 'bad velocity for ${zzz(frame)}',
        );
        expect(
          frame.velocity,
          greaterThan(-1.0),
          reason: 'bad velocity for ${zzz(frame)}',
        );
        expect(
          frame.gamma,
          greaterThan(1.0),
          reason: 'bad gamma for ${zzz(frame)}',
        );
      }
    });
    test('pt', () {
      math.Random random = math.Random();
      final int lightSpeedCount = LightSpeed.values.length;
      for (int i = 0; i < 100; i++) {
        CoordinateTransform transform = makeTransform(random);
        final ReferenceFrame frame = transform.frame;
        frame.center = makePoint(random);
        LightSpeed speed = LightSpeed.values[random.nextInt(lightSpeedCount)];
        Point a = makePoint(random);
        Point b = a.toFrame(frame, speed);
        Point c = b.fromFrame(frame, speed);
        expect(
          a,
          PointMatch(c),
          reason: "failed for ${zzz(frame)}, b=${zzz(b)}",
        );
      }
    });
    test('vector', () {
      final double epsilon = 1e-4;
      math.Random random = math.Random();
      final int lightSpeedCount = LightSpeed.values.length;
      for (int i = 0; i < 100; i++) {
        CoordinateTransform transform = makeTransform(random);
        final ReferenceFrame frame = transform.frame;
        frame.center = makePoint(random);
        LightSpeed speed = LightSpeed.values[random.nextInt(lightSpeedCount)];
        Vector v1 = makeVector(random);
        Vector v2 = v1.toFrame(frame, speed);
        Vector v3 = v2.fromFrame(frame, speed);
        expect(
          v1,
          VectorMatch(v3),
          reason: "failed for ${zzz(frame)}, v2=${zzz(v2)}",
        );
      }
    });
  });
  group('transform', () {
    test('make', () {
      final double epsilon = 1e-4;
      ReferenceFrame frame = ReferenceFrame();
      expect(frame.velocity, 0.0);
      expect(frame.gamma, closeTo(1.0, epsilon));
      frame = ReferenceFrame.fromV(0.1);
      expect(frame.velocity, 0.1);
      expect(frame.gamma, closeTo(1.00503, epsilon));
      frame = ReferenceFrame.fromV(-0.1);
      expect(frame.velocity, -0.1);
      expect(frame.gamma, closeTo(1.00503, epsilon));
    });
    test('size', () {
      math.Random random = math.Random();
      for (int i = 0; i < 25; i++) {
        CoordinateTransform transform = makeTransform(random);
        Size size = Size(
          100 + 100 * random.nextDouble(),
          100 + 100 * random.nextDouble(),
        );
        expect(transform.sizeChanged(size), true);
        transform.resize(size);
        expect(transform.sizeChanged(size), false);
      }
    });
    test('to-screen', () {
      math.Random random = math.Random();
      for (int i = 0; i < 100; i++) {
        CoordinateTransform transform = makeTransform(random);
        Offset offset = makeOffset(random);
        Point pt = transform.fromScreen(offset);
        Offset offset2 = transform.toScreen(pt);
        expect(
          offset,
          OffsetMatch(offset2),
          reason: "failed for ${zzz(transform)}, pt=${zzz(pt)}",
        );
      }
    });
    test('screen-delta', () {
      math.Random random = math.Random();

      for (int i = 0; i < 100; i++) {
        CoordinateTransform transform = makeTransform(random);
        Offset offset1 = makeOffset(random);
        Offset offset2 = makeOffset(random);
        Point p1 = transform.fromScreen(offset1);
        Point p2 = transform.fromScreen(offset2);
        Vector delta = transform.fromScreenDelta(offset1 - offset2);
        expect(
          p2 + delta,
          PointMatch(p1),
          reason: "Failed for offsets = ${zzz(offset1)}, $offset2",
        );
      }
    });
    test('to-side', () {
      math.Random random = math.Random();
      for (int i = 0; i < 100; i++) {
        CoordinateTransform transform = makeTransform(random);
        Offset offset = makeOffset(random);
        double time = random.nextDouble() * 4.0 - 2.0;
        Point pt = transform.fromSide(offset, time);
        Offset offset2 = transform.toSide(pt);
        String reason =
            ("failed for\n   ${zzz(transform)},\n"
            "   pt=${zzz(pt)}, time=${zzz(time)}");
        expect(offset, OffsetMatch(offset2), reason: reason);
      }
    });
    test('side-view coordinate transformation', () {
      CoordinateTransform transform = CoordinateTransform();
      transform.resize(Size(400, 400));
      transform.sideHeight = 200.0;
      double time = 0.5;
      Point ptCenter = transform.fromSide(const Offset(200.0, 190.0), time);
      expect(ptCenter.x, closeTo(0.0, 1e-4));
      expect(ptCenter.z, closeTo(0.0, 1e-4));
      expect(ptCenter.t, closeTo(time, 1e-4));

      math.Random random = math.Random();
      for (int i = 0; i < 50; i++) {
        Offset click = Offset(
          400 * random.nextDouble(),
          200 * random.nextDouble(),
        );
        Point p = transform.fromSide(click, time);
        Offset mapped = transform.toSide(p);
        expect(click, OffsetMatch(mapped));
      }
    });

    void scaleTest(
      String name,
      bool useZoom,
      bool useMove, {
      bool side = false,
    }) {
      test('doScale $name', () {
        math.Random random = math.Random();
        for (int i = 0; i < 100; i++) {
          CoordinateTransform transform = makeTransform(random);
          transform.resize(Size(200, 300));
          String ts = zzz(transform);
          Point p1 = makePoint(random);
          Point p2 = makePoint(random);
          Offset o1 = side ? transform.toSide(p1) : transform.worldToScreen(p1);
          Offset o2 = side ? transform.toSide(p2) : transform.worldToScreen(p2);
          double d = distance(o1, o2);
          // Scale by zoom, and move p1 to p2.
          double zoom = useZoom
              ? math.exp(4.0 * random.nextDouble() - 2.0)
              : 1.0;
          transform.doScale(o1, useMove ? o2 : o1, zoom, side);
          Offset o1Post = side
              ? transform.toSide(p1)
              : transform.worldToScreen(p1);
          Offset o2Post = side
              ? transform.toSide(p2)
              : transform.worldToScreen(p2);
          double dPost = distance(o1Post, o2Post);
          String reason =
              ("failed for  zoom=${zzz(zoom)}, useMove=$useMove, side=$side\n"
              "  $ts ->\n"
              "  ${zzz(transform)},\n"
              "  p1=${zzz(p1)},  p2=${zzz(p2)},\n"
              "  o1=${zzz(o1)},  o2=${zzz(o2)},\n"
              "  n1=${zzz(o1Post)},  n2=${zzz(o2Post)},\n"
              "  d=${zzz(d)}, dp = ${zzz(dPost)}, ratio = ${zzz(dPost / d)}");
          expect(o1Post, OffsetMatch(o1Post), reason: reason);
          final double epsilon = 1e-4;
          expect(dPost, closeTo(d * zoom, epsilon), reason: reason);
        }
      });
    }

    scaleTest("noop", false, false);
    scaleTest("zoom", true, false);
    scaleTest("translate", false, true);
    scaleTest("scale", true, true);
    scaleTest("side noop", false, false, side: true);
    scaleTest("side zoom", true, false, side: true);
    scaleTest("side translate", false, true, side: true);
    scaleTest("side scale", true, true, side: true);

    test('fit', () {
      math.Random random = math.Random();
      for (int i = 0; i < 100; i++) {
        CoordinateTransform transform = makeTransform(random);
        transform.resize(Size(200, 300));
        transform.frame.velocity = 0.0;
        final original = CoordinateTransform.from(transform);
        expect(original, CoordinateTransformMatcher(transform));
        Point p1 = makePoint(random);
        Point p2 = makePoint(random);
        Point p1Obs = transform.worldToObserver(p1);
        Point p2Obs = transform.worldToObserver(p2);
        Point min = p1Obs.min(p2Obs);
        Point max = p1Obs.max(p2Obs);
        transform.fit(Bounds(min, max));
        final fit1 = CoordinateTransform.from(transform);
        expect(fit1, CoordinateTransformMatcher(transform));
        expect(fit1, isNot(CoordinateTransformMatcher(original)));
        // Idenpotent: calling fit twice results in same transform.
        final fit2 = CoordinateTransform.from(transform);
        expect(fit2, CoordinateTransformMatcher(fit1));
        // Recompute p1 and p2 in observer coordinates.
        Offset o1 = transform.worldToScreen(p1);
        Offset o2 = transform.worldToScreen(p2);
        String reason =
            ("$i) for ${zzz(transform)}, \n"
            "p1=$p1 -> ${zzz(o1)}, p2=$p2 -> ${zzz(o2)}\n"
            "min=$min, max=$max\n"
            "size=${zzz(transform.size)}, dz=${zzz(transform.dz)}\n"
            "Tmin=${transform.min}, Tmax=${transform.max}\n"
            "");
        Size size = transform.size;
        expect(o1.dx, greaterThan(0), reason: reason);
        expect(o1.dy, greaterThan(0), reason: reason);
        expect(o1.dx, lessThan(size.width), reason: reason);
        expect(o1.dy, lessThan(size.height), reason: reason);
        expect(o2.dx, greaterThan(0), reason: reason);
        expect(o2.dy, greaterThan(0), reason: reason);
        expect(o2.dx, lessThan(size.width), reason: reason);
        expect(o2.dy, lessThan(size.height), reason: reason);
      }
    });
  });
}
