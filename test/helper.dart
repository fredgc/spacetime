import 'package:flutter/material.dart';

import 'package:test/test.dart';
import 'dart:math' as math;

import 'package:spacetime/drawable.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';
import 'package:spacetime/printer.dart';

Point makePoint(math.Random random) {
  return Point(
    x: random.nextDouble() * 4.0 - 2.0,
    t: random.nextDouble() * 4.0 - 2.0,
    z: random.nextDouble() * 4.0 - 2.0,
  );
}

Vector makeVector(math.Random random) {
  return Vector(
    dx: random.nextDouble() * 4.0 - 2.0,
    dt: random.nextDouble() * 4.0 - 2.0,
    dz: random.nextDouble() * 4.0 - 2.0,
  );
}

Offset makeOffset(math.Random random) {
  return Offset(200 * random.nextDouble(), 200 * random.nextDouble());
}

double distance(Offset o1, Offset o2) {
  Offset v = o2 - o1;
  double length = math.sqrt(v.dx * v.dx + v.dy * v.dy);
  return length;
}

CoordinateTransform makeTransform(math.Random random) {
  CoordinateTransform transform = CoordinateTransform();
  // Random velocity from -1.1 to 1.1, but we expect that the ReferenceFrame
  // code will clamp the velocity to |v| < 0.999, with gamma < 22.4.
  transform.frame = ReferenceFrame.fromV(random.nextDouble() * 2.2 - 1.1);
  Size size = Size(
    100 + 100 * random.nextDouble(),
    100 + 100 * random.nextDouble(),
  );
  transform.resize(size);
  transform.offset = Offset(
    size.width * random.nextDouble(),
    size.height * random.nextDouble(),
  );
  return transform;
}

class PointMatch extends Matcher {
  final double epsilon;
  final Point expected;

  PointMatch(this.expected, {this.epsilon = 1e-4});

  @override
  bool matches(dynamic actual, Map matchState) {
    if (actual is! Point) return false;
    return epsilon >
        ((expected.x - actual.x).abs() +
            (expected.t - actual.t).abs() +
            (expected.z - actual.z).abs());
  }

  @override
  Description describe(Description description) {
    return description.add("matches point ${zzz(expected)}");
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description description,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Point) {
      return description.add("$item is not a point");
    }
    description.add("actual is ${zzz(item)}\n");
    description.add("expected  ${zzz(expected)}\n");
    return description;
  }
}

class VectorMatch extends Matcher {
  final double epsilon;
  final Vector expected;

  VectorMatch(this.expected, {this.epsilon = 1e-4});

  @override
  bool matches(dynamic actual, Map matchState) {
    if (actual is! Vector) return false;
    return epsilon >
        ((expected.dx - actual.dx).abs() +
            (expected.dt - actual.dt).abs() +
            (expected.dz - actual.dz).abs());
  }

  @override
  Description describe(Description description) {
    return description.add("matches vector ${zzz(expected)}");
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description description,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Vector) {
      return description.add("$item is not a vector");
    }
    description.add("actual is ${zzz(item)}\n");
    description.add("expected  ${zzz(expected)}\n");
    return description;
  }
}

class OffsetMatch extends Matcher {
  final double epsilon;
  final Offset expected;

  OffsetMatch(this.expected, {this.epsilon = 1e-4});

  @override
  bool matches(dynamic actual, Map matchState) {
    if (actual is! Offset) return false;
    return epsilon >
        ((expected.dx - actual.dx).abs() + (expected.dy - actual.dy).abs());
  }

  @override
  Description describe(Description description) {
    return description.add("matches vector ${zzz(expected)}");
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description description,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Offset) {
      return description.add("$item is not a vector");
    }
    description.add("actual is ${zzz(item)}\n");
    description.add("expected  ${zzz(expected)}\n");
    return description;
  }
}

class CoordinateTransformMatcher extends Matcher {
  CoordinateTransform expected;
  final epsilon = 1e-3;

  CoordinateTransformMatcher(this.expected);

  @override
  bool matches(dynamic item, Map matchState) {
    CoordinateTransform actual;
    if (item is CoordinateTransform) {
      actual = item;
    } else {
      matchState["reason"] = "Wrong type for $item.";
      return false;
    }
    bool result = true;
    if (actual.size != expected.size) {
      matchState["size"] =
          "size is '${zzz(actual.size)}' and not '${zzz(expected.size)}'.";
      result = false;
    }
    if (actual.offset != expected.offset) {
      matchState["offset"] =
          "offset is '${zzz(actual.offset)}' and not '${zzz(expected.offset)}'.";
      result = false;
    }
    if (actual.lightSpeed != expected.lightSpeed) {
      matchState["lightSpeed"] =
          "lightSpeed is '${zzz(actual.lightSpeed)}' and not '${zzz(expected.lightSpeed)}'.";
      result = false;
    }
    PointMatch center = PointMatch(expected.frame.center);
    if (!center.matches(actual.frame.center, matchState)) {
      matchState["center"] =
          "center is ${actual.frame.center} and "
          "not ${expected.frame.center}.";
      result = false;
    }
    PointMatch min = PointMatch(expected.min);
    if (!min.matches(actual.min, matchState)) {
      matchState["min"] = "min is ${actual.min} and not ${expected.min}.";
      result = false;
    }
    PointMatch max = PointMatch(expected.max);
    if (!max.matches(actual.max, matchState)) {
      matchState["max"] = "max is ${actual.max} and not ${expected.max}.";
      result = false;
    }
    if ((actual.frame.velocity - expected.frame.velocity).abs() > epsilon) {
      matchState["velocity"] =
          "velocity is ${actual.frame.velocity} and "
          "not ${expected.frame.velocity}.";
      result = false;
    }
    if ((actual.dz - expected.dz).abs() > epsilon) {
      matchState["dz"] = "dz is ${actual.dz} and not ${expected.dz}.";
      result = false;
    }
    if ((actual.zoom - expected.zoom).abs() > epsilon) {
      matchState["zoom"] = "zoom is ${actual.zoom} and not ${expected.zoom}.";
      result = false;
    }
    return result;
  }

  @override
  Description describe(Description description) {
    // This shows up as the first line of a failure as "Expected: $describe".
    // then Actual is printed with like "Actual: $actual".
    // And  describeMismatch is printed like "Which: $describeMismatch".
    return description.add('Transform matches $expected.');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    for (String reasons in matchState.values) {
      mismatchDescription.add('\n  $reasons');
    }
    return mismatchDescription;
  }
}

class DrawableMatcher extends Matcher {
  final Drawable expected;
  final double epsilon;

  DrawableMatcher(this.expected, {this.epsilon = 1e-4});

  @override
  bool matches(dynamic actual, Map matchState) {
    if (actual is! Drawable) return false;
    Drawable d = actual;
    PointMatch pt = PointMatch(expected.pt, epsilon: epsilon);
    return ((d.color == expected.color) &&
        (d.name == expected.name) &&
        (pt.matches(d.pt, matchState)) &&
        (epsilon > (d.frame.velocity - expected.frame.velocity).abs()));
  }

  @override
  Description describe(Description description) {
    return description.add("matches ${zzz(expected)}");
  }
}

class SceneDataMatcher extends Matcher {
  SceneData expected;
  final epsilon = 1e-2;

  SceneDataMatcher(this.expected);

  factory SceneDataMatcher.fromJson(String json) {
    return SceneDataMatcher(SceneData.fromJsonString(json));
  }

  @override
  bool matches(dynamic item, Map matchState) {
    SceneData actual;
    if (item is SceneData) {
      actual = item;
    } else if (item is String) {
      actual = SceneData.fromJsonString(item);
    } else {
      matchState["reason"] = "Wrong type for $item.";
      return false;
    }
    bool result = true;
    if (actual.title != expected.title) {
      matchState["title"] =
          "title is '${actual.title}' and not '${expected.title}'.";
      result = false;
    }
    if ((actual.time - expected.time).abs() > epsilon) {
      var err = (actual.time - expected.time).abs();
      matchState["time"] =
          "time is ${actual.time} and not ${expected.time}, err=$err.";
      result = false;
    }
    if ((actual.velocity - expected.velocity).abs() > epsilon) {
      matchState["velocity"] =
          "velocity is ${actual.velocity} and not ${expected.velocity}.";
      result = false;
    }
    if (actual.drawables.length != expected.drawables.length) {
      matchState["count"] =
          "item count is ${actual.drawables.length} and not ${expected.drawables.length}.";
      result = false;
    }
    int length = math.min(actual.drawables.length, expected.drawables.length);
    for (int i = 0; i < length; i++) {
      DrawableMatcher m = DrawableMatcher(expected.drawables[i]);
      if (!m.matches(actual.drawables[i], matchState)) {
        matchState["drawables[$i]"] =
            "$i) is ${actual.drawables[i]} \n not    ${expected.drawables[i]}.";
        result = false;
      }
    }
    return result;
  }

  @override
  Description describe(Description description) {
    // This shows up as the first line of a failure as "Expected: $describe".
    // then Actual is printed with like "Actual: $actual".
    // And  describeMismatch is printed like "Which: $describeMismatch".
    return description.add('Scene Data matches $expected.');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    for (String reasons in matchState.values) {
      mismatchDescription.add('\n  $reasons');
    }
    return mismatchDescription;
  }
}
