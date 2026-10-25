import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/printer.dart';
import 'package:spacetime/slider.dart';
import 'package:spacetime/transform.dart';

void main() {
  setUp(() {
    DebugPrint.padZzz = 0;
  });

  tearDown(() {
    DebugPrint.padZzz = 7;
  });

  group('Printer utility functions', () {
    test('trunc collapses whitespace and truncates at cutoff', () {
      expect(trunc('hello  world'), 'hello world');
      expect(trunc('line 1\n  line 2\n\nline 3'), 'line 1 line 2 line 3');
      expect(trunc('short', cutoff: 10), 'short');
      expect(trunc('abcdefghij extra', cutoff: 10), 'abcdefghij...');
    });

    test('zzz and zzz2 format various primitives and geometric objects', () {
      // Double formatting
      expect(zzz2(double.nan), 'NaN');
      expect(zzz2(double.infinity), 'inf');
      expect(zzz2(123.456), '123');
      expect(zzz2(-75.2), '-75');
      expect(zzz2(3.14159), '3.14');

      // Offset
      expect(zzz2(const Offset(1.0, 2.0)), 'o(1.00, 2.00)');

      // Point and Vector
      expect(zzz2(Point(x: 1.0, t: 2.0, z: 3.0)), 'p(x:1.00, t:2.00, z:3.00)');
      expect(zzz2(Vector(dx: 1.0, dt: 2.0)), 'v(dx:1.00, dt:2.00)');

      // Bounds
      final bounds = Bounds(Point(x: 0, t: 0), Point(x: 10, t: 10));
      expect(zzz2(bounds), contains('b[min:'));

      // ReferenceFrame
      final frame = ReferenceFrame();
      frame.velocity = 0.6;
      expect(zzz2(frame), contains('rf('));
      expect(zzz2(frame), contains('v=0.600'));

      // Slider
      final slider = MySlider('speed', -1.0, 1.0, 0.5);
      expect(zzz2(slider), 's(0.500)');

      // List
      expect(zzz2([1.0, 2.0]), '[1.00, 2.00]');

      // Padding with DebugPrint.padZzz
      DebugPrint.padZzz = 10;
      expect(zzz(1.0).length >= 10, true);
    });

    test('Log enum values have descriptions', () {
      for (final log in Log.values) {
        expect(log.description.isNotEmpty, true);
      }
      expect(Log.errors.description, contains('errors'));
    });
  });
}
