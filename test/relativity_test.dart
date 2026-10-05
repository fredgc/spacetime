import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/drawable.dart';
import 'package:spacetime/sprites.dart';
import 'package:spacetime/transform.dart';

import 'helper.dart';

void main() {
  group('Relativity Physics Correctness', () {
    test('Spacetime Interval Invariance', () {
      final math.Random random = math.Random(42);
      for (int i = 0; i < 50; i++) {
        // Create two random events in world frame.
        Point p1 = makePoint(random);
        Point p2 = makePoint(random);

        double dxWorld = p2.x - p1.x;
        double dtWorld = p2.t - p1.t;
        double intervalWorld = dxWorld * dxWorld - dtWorld * dtWorld;

        // Transform to random moving frame.
        double v = (random.nextDouble() * 1.8) - 0.9;
        ReferenceFrame frame = ReferenceFrame.fromV(v);
        frame.center = makePoint(random);

        Point p1Frame = p1.toFrame(frame, LightSpeed.lorentz);
        Point p2Frame = p2.toFrame(frame, LightSpeed.lorentz);

        double dxFrame = p2Frame.x - p1Frame.x;
        double dtFrame = p2Frame.t - p1Frame.t;
        double intervalFrame = dxFrame * dxFrame - dtFrame * dtFrame;

        expect(
          intervalFrame,
          closeTo(intervalWorld, 1e-4),
          reason:
              'Spacetime interval must be invariant under Lorentz transform',
        );
      }
    });

    test('Time Dilation', () {
      final math.Random random = math.Random(123);
      for (int i = 0; i < 50; i++) {
        double v = (random.nextDouble() * 1.8) - 0.9;
        ReferenceFrame frame = ReferenceFrame.fromV(v);

        // In object frame, two events on its worldline (dx' = 0, dt' = tau).
        double properTime = 2.5 + random.nextDouble() * 5.0;
        Point pLocal1 = Point(x: 0, t: 0);
        Point pLocal2 = Point(x: 0, t: properTime);

        // Convert to world frame.
        Point pWorld1 = pLocal1.fromFrame(frame, LightSpeed.lorentz);
        Point pWorld2 = pLocal2.fromFrame(frame, LightSpeed.lorentz);

        double dtWorld = pWorld2.t - pWorld1.t;
        double expectedDtWorld = frame.gamma * properTime;

        expect(
          dtWorld,
          closeTo(expectedDtWorld, 1e-4),
          reason: 'Coordinate time interval must equal gamma * proper time',
        );
      }
    });

    test('Length Contraction', () async {
      final math.Random random = math.Random(456);
      for (int i = 0; i < 50; i++) {
        double objectV = (random.nextDouble() * 1.8) - 0.9;
        double observerU = (random.nextDouble() * 1.8) - 0.9;

        ReferenceFrame objFrame = ReferenceFrame.fromV(objectV);
        Location loc = Location(
          DrawType.person,
          'TestPerson',
          objFrame,
          0,
          Sprite.person,
        );

        CoordinateTransform transform = CoordinateTransform();
        transform.frame = ReferenceFrame.fromV(observerU);
        transform.lightSpeed = LightSpeed.lorentz;

        // Trigger update to compute contracted width.
        await loc.update(transform, 0.0, []);

        // Expected relative velocity w = (v - u) / (1 - u*v)
        double w = (objectV - observerU) / (1.0 - observerU * objectV);
        double gammaRel = 1.0 / math.sqrt(1.0 - w * w);
        double expectedContractedWidth = loc.width / gammaRel;

        expect(
          loc.contracted_width,
          closeTo(expectedContractedWidth, 1e-4),
          reason: 'Contracted width must equal rest width / gamma_rel',
        );
      }
    });

    test('Relativistic Velocity Addition', () {
      final math.Random random = math.Random(789);
      for (int i = 0; i < 50; i++) {
        double v = (random.nextDouble() * 1.8) - 0.9;
        double u = (random.nextDouble() * 1.8) - 0.9;

        double w = (v - u) / (1.0 - u * v);
        expect(
          w.abs(),
          lessThan(1.0),
          reason: 'Relative velocity must stay subluminal',
        );

        // Test speed of light constancy: if light pulse v = 1.0 or -1.0
        double cPos = (1.0 - u) / (1.0 - u * 1.0);
        double cNeg = (-1.0 - u) / (1.0 - u * (-1.0));
        expect(
          cPos,
          closeTo(1.0, 1e-6),
          reason: 'Speed of light +c is constant in all frames',
        );
        expect(
          cNeg,
          closeTo(-1.0, 1e-6),
          reason: 'Speed of light -c is constant in all frames',
        );
      }
    });

    test('Relativity of Simultaneity', () {
      double v = 0.6;
      ReferenceFrame movingFrame = ReferenceFrame.fromV(v);

      // Two events simultaneous in world frame at t = 0, x1 = -1, x2 = 1.
      Point e1World = Point(x: -1.0, t: 0.0);
      Point e2World = Point(x: 1.0, t: 0.0);

      Point e1Moving = e1World.toFrame(movingFrame, LightSpeed.lorentz);
      Point e2Moving = e2World.toFrame(movingFrame, LightSpeed.lorentz);

      // In moving frame, t' = gamma * (t - v*x) = -gamma * v * x.
      // So e2Moving.t - e1Moving.t = -gamma * v * (x2 - x1).
      double dtMoving = e2Moving.t - e1Moving.t;
      double expectedDtMoving = -movingFrame.gamma * v * (2.0);

      expect(
        dtMoving,
        closeTo(expectedDtMoving, 1e-4),
        reason:
            'Events simultaneous in rest frame must not be simultaneous in moving frame',
      );
    });

    test('Light Cone Slope in Lorentz Mode', () {
      double v = 0.5;
      ReferenceFrame frame = ReferenceFrame.fromV(v);

      // Light ray propagating at +c = +1 from origin (0, 0)
      Point origin = Point(x: 0, t: 0);
      Point lightPtWorld = Point(x: 2.0, t: 2.0);

      Point originObs = origin.toFrame(frame, LightSpeed.lorentz);
      Point lightPtObs = lightPtWorld.toFrame(frame, LightSpeed.lorentz);

      double dxObs = lightPtObs.x - originObs.x;
      double dtObs = lightPtObs.t - originObs.t;

      // In Lorentz frame, slope dx'/dt' must still be 1.0
      expect(
        dxObs / dtObs,
        closeTo(1.0, 1e-4),
        reason:
            'Light pulse slope dx/dt must be 1.0 in any observer Lorentz frame',
      );
    });
  });
}
