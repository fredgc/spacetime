import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/axis.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';

void main() {
  group('PlotAxis unit tests', () {
    test('setupBounds computes appropriate step size and rounded range', () {
      final transform = CoordinateTransform();
      transform.zoom = 100.0;
      transform.min = Point(x: -3.2, t: -1.7);
      transform.max = Point(x: 4.8, t: 5.3);

      final xAxis = PlotAxis(vertical: false);
      xAxis.resize(transform);

      expect(xAxis.vertical, false);
      expect(xAxis.min <= -3.2, true);
      expect(xAxis.max >= 4.8, true);
      expect(xAxis.dt > 0, true);
      expect(xAxis.dt2 > 0, true);
      expect(xAxis.labels.isNotEmpty, true);
    });

    test('vertical axis handles t coordinates', () {
      final transform = CoordinateTransform();
      transform.zoom = 150.0;
      transform.min = Point(x: -2.0, t: -4.0);
      transform.max = Point(x: 2.0, t: 8.0);

      final tAxis = PlotAxis(vertical: true);
      tAxis.resize(transform);

      expect(tAxis.vertical, true);
      expect(tAxis.min <= -4.0, true);
      expect(tAxis.max >= 8.0, true);
      expect(tAxis.labels.isNotEmpty, true);
    });

    test('paint and paintSide execute without errors', () {
      final transform = CoordinateTransform();
      transform.resize(const Size(800, 600));

      final xAxis = PlotAxis(vertical: false);
      final tAxis = PlotAxis(vertical: true);
      xAxis.resize(transform);
      tAxis.resize(transform);

      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5;

      // Test with gridlines disabled
      SceneView.showGridlines.value = false;
      xAxis.paint(canvas, transform, paint);
      tAxis.paint(canvas, transform, paint);
      xAxis.paintSide(canvas, transform, paint, 80.0);

      // Test with gridlines enabled
      SceneView.showGridlines.value = true;
      xAxis.paint(canvas, transform, paint);
      tAxis.paint(canvas, transform, paint);
      xAxis.paintSide(canvas, transform, paint, 80.0);

      final picture = pictureRecorder.endRecording();
      expect(picture, isNotNull);
      picture.dispose();
    });

    test('handles degenerate/collapsed bounds gracefully', () {
      final transform = CoordinateTransform();
      final axis = PlotAxis(vertical: false);
      axis.min = 0.0;
      axis.max = 0.0; // collapsed
      axis.setupBounds(transform);

      expect(axis.min, -2.0);
      expect(axis.max, 2.0);
    });
  });
}
