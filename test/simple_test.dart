// import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/drawable.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/transform.dart';

bool debug_lists = false;
bool debug_settings = false;

List<String> short() {
  return ["alpha", "beta"];
}

String short2() {
  return "gamma";
}

class MyIterator extends Iterable<List<String>>
    implements Iterator<List<String>> {
  List<String> input;
  List<String> _current = [];
  @override
  List<String> get current => _current;
  @override
  Iterator<List<String>> get iterator => this;

  MyIterator(this.input);

  @override
  bool moveNext() {
    if (input.isEmpty) return false;
    int i = input.indexWhere((s) => s == "");
    if (debug_lists) print("Next is at $i.");
    if (i < 0) {
      _current = input;
      input = [];
      return true;
    }
    _current = input.sublist(0, i);
    input = input.sublist(i + 1);
    return true;
  }
}

void main() {
  group('Make sure tests run', () {
    test('simple test', () {
      expect(1 + 1, 2);
    });
    test('check lists', () {
      var one = ["aaaa", "b-nope", "c", "d"];
      List<String> two = [
        "first",
        for (var s in short()) s,
        "second",
        short2(),
        "thid",
        for (var s in one)
          if (!s.contains("nope")) "one-$s",
        "last",
      ];
      if (debug_lists) print("GREEN: one = $one");
      if (debug_lists) print("GREEN: two = $two");
    });
    test('check lists 2', () {
      var one = ["a", "b", "", "c", "d", "e", "", "f"];
      List<List<String>> two = [for (var s in MyIterator(one)) s];
      if (debug_lists) print("GREEN: one = $one");
      if (debug_lists) print("GREEN: two = $two");
    });
    test('settings', () {
      Settings settings = Settings();
      if (debug_settings) {
        print("Settings instance = $settings. status = ${settings.status}.");
      }
    });
  });
  group('equal', () {
    for (var type in DrawType.values) {
      test('drawable $type', () {
        Point p1 = Point(x: 0.5, t: 1.0, z: 0.1);
        Point p2 = Point(x: 0.5, t: 1.0, z: 0.1);
        ReferenceFrame obs1 = ReferenceFrame()
          ..velocity = 0.5
          ..center = p1;
        // Obs 2 should be the same as obs1.
        ReferenceFrame obs2 = ReferenceFrame()
          ..velocity = 0.5
          ..center = p2;
        Drawable d1 = type.make("One", obs1, 1);
        Drawable d2 = type.make("One", obs2, 1);
        expect(d1, d2);
        // This has a different velocity.
        Point p3 = Point(x: 1.0, t: 0.5, z: 0.1);
        ReferenceFrame obs3 = // Has a different center.
        ReferenceFrame()
          ..velocity = 0.5
          ..center = p3;
        ReferenceFrame obs4 = // Has a different velocity.
        ReferenceFrame()
          ..velocity = -0.25
          ..center = p2;
        expect(d1, isNot(type.make("Two", obs1, 1))); // different name.
        expect(d1, isNot(type.make("One", obs3, 1))); // diff center.
        expect(d1, isNot(type.make("One", obs4, 1))); // diff velocity.
        expect(d1, isNot(type.make("One", obs1, 2))); // diff color.
        for (var type2 in DrawType.values) {
          if (type != type2) {
            expect(d1, isNot(type2.make("One", obs1, 1))); // diff type.
          }
        }
      });
    }
  });
}
