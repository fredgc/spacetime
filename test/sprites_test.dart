import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/sprites.dart';

void main() {
  group('Sprite unit tests', () {
    test('fromString parses all standard sprites correctly', () {
      expect(Sprite.fromString('clock'), Sprite.clock);
      expect(Sprite.fromString('person'), Sprite.person);
      expect(Sprite.fromString('train'), Sprite.train);
      expect(Sprite.fromString('barn'), Sprite.barn);
      expect(Sprite.fromString('flag'), Sprite.flag);
    });

    test('fromString throws FormatException for invalid sprite string', () {
      expect(() => Sprite.fromString('car'), throwsA(isA<FormatException>()));
      expect(() => Sprite.fromString(''), throwsA(isA<FormatException>()));
    });

    test('properties width, height, and isWide match physics defaults', () {
      expect(Sprite.train.isWide, true);
      expect(Sprite.barn.isWide, true);
      expect(Sprite.person.isWide, false);
      expect(Sprite.clock.isWide, false);
      expect(Sprite.flag.isWide, false);

      expect(Sprite.person.height > Sprite.person.width, true);
      expect(Sprite.train.width >= 0.5, true);
    });

    test('paint draws all sprite variants onto a canvas without throwing', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke;
      final bounds = const Rect.fromLTWH(50, 50, 100, 80);

      for (final sprite in Sprite.values) {
        sprite.paint(canvas, paint, bounds, 1.5);
      }

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
      picture.dispose();
    });
  });
}
