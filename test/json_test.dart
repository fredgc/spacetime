import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/drawable.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/printer.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/transform.dart';

import 'app_tester.dart';
import 'test_data.dart';

bool dump_json = false;

bool near(Point a, Point b) {
  final epsilon = 1e-3;
  return ((a.x - b.x).abs() < epsilon) &&
      ((a.t - b.t).abs() < epsilon) &&
      ((a.z - b.z).abs() < epsilon);
}

T roundTrip<T>(T first, Function(Map<String, dynamic>) decode) {
  var encoder = JsonEncoder.withIndent("  ");
  String json = encoder.convert(first);
  if (dump_json) print("First: ${first.runtimeType} ${zzz(first)}");
  if (dump_json) print("  json-> '$json'");
  var jsonMap = jsonDecode(json);
  if (dump_json) print("  map-> type=${jsonMap.runtimeType}, $jsonMap");
  T second = decode(jsonMap);
  if (dump_json) print("  second-> ${zzz(second)}");
  expect(first, second);
  return second;
}

// Sometimes jsonDecode gives us a list.
T listRoundTrip<T>(T first, Function(List) decode) {
  String json = jsonEncode(first);
  if (dump_json) print("First: ${first.runtimeType} ${zzz(first)}");
  if (dump_json) print("     json-> '$json'");
  var jsonMap = jsonDecode(json);
  T second = decode(jsonMap);
  if (dump_json) print("     second-> ${zzz(second)}");
  expect(first, second);
  return second;
}

void makeDebugScene(SceneData scene) {
  scene.title = 'This is the "title".';
  scene.time = 1.42;
  scene.velocity = 0.12;
  scene.transform.frame.center = Point(t: 2.123, x: 3.456);
  scene.transform.zoom = 102.1;
  ReferenceFrame obs = scene.transform.frame;
  scene.drawables.add(
    DrawType.event.make(
      "an event",
      obs..center = Point(x: 0.5, t: 1.0, z: 0.1),
      0,
    ),
  );
  scene.drawables.add(
    DrawType.instant.make(
      "Int",
      obs..center = Point(x: 0.45, t: 0.5, z: 0.2),
      1,
    ),
  );
  scene.drawables.add(
    DrawType.instant.make(
      "I2",
      obs..center = Point(x: 0.45, t: -0.5, z: 0.6),
      2,
    ),
  );
  scene.drawables.add(
    DrawType.cone.make("L1", obs..center = Point(x: -1.2, t: -1.2, z: 0.4), 3),
  );
  scene.drawables.add(
    DrawType.person.make("P", obs..center = Point(x: -1.5, t: 1.0, z: 0.1), 0),
  );
  scene.drawables.add(
    DrawType.train.make("T", obs..center = Point(x: -1.0, t: 1.0, z: 0.1), 1),
  );
  scene.drawables.add(
    DrawType.barn.make("B", obs..center = Point(x: 0.5, t: 1.0, z: 0.1), 2),
  );
  scene.drawables.add(
    DrawType.flag.make("F", obs..center = Point(x: 1.5, t: 1.0, z: 0.1), 4),
  );
  scene.drawables.add(
    DrawType.clock.make("C1", obs..center = Point(x: 0.25, t: 0.0, z: 0.1), 0),
  );
}

void main() {
  group('json', () {
    test('point', () {
      roundTrip(Point(x: 2.0, t: 3.5), (s) => Point.fromJson(s));
    });
    test('vector', () {
      roundTrip(Vector(dx: 2.0, dt: 3.5), (s) => Vector.fromJson(s));
      roundTrip(Vector(dx: 2.0, dt: -3.5), (s) => Vector.fromJson(s));
      roundTrip(Vector(), (s) => Vector.fromJson(s));
    });
    test('frame', () {
      ReferenceFrame frame = ReferenceFrame.fromV(0.1);
      frame.center = Point(x: 2.0, t: 3.0, z: 4.0);
      roundTrip(frame, (s) => ReferenceFrame.fromJson(s));
    });
    test('event', () {
      ReferenceFrame obs = ReferenceFrame()
        ..velocity = 0.5
        ..center = Point(x: 32, t: 15);
      roundTrip(
        DrawType.event.make("an event", obs..center = Point(x: 0.5, t: 1.0), 2),
        (s) => Drawable.fromJson(s),
      );
    });
    test('instant', () {
      ReferenceFrame obs = ReferenceFrame()
        ..velocity = 0.5
        ..center = Point(x: 32, t: 15);
      roundTrip(
        DrawType.instant.make("I1", obs..center = Point(x: 0.0, t: 0.5), 1),
        (s) => Drawable.fromJson(s),
      );
    });
    test('cone', () {
      ReferenceFrame obs = ReferenceFrame()
        ..velocity = 0.5
        ..center = Point(x: 32, t: 15);
      roundTrip(
        DrawType.cone.make("L1", obs..center = Point(x: -1.0, t: -1.0), 3),
        (s) => Drawable.fromJson(s),
      );
    });
    test('location', () {
      ReferenceFrame obs = ReferenceFrame()
        ..velocity = 0.5
        ..center = Point(x: 32, t: 15);
      roundTrip(
        DrawType.person.make("P1", obs..center = Point(x: -0.5, t: 1.0), 1),
        (s) => Drawable.fromJson(s),
      );
    });
    test('draw list', () {
      ReferenceFrame obs = ReferenceFrame()
        ..velocity = 0.5
        ..center = Point(x: 32, t: 15);
      List<Drawable> drawables = [
        DrawType.event.make("an event", obs..center = Point(x: 0.5, t: 1.0), 4),
        DrawType.instant.make("I1", obs..center = Point(x: 0.0, t: 0.5), 5),
        DrawType.cone.make("L1", obs..center = Point(x: -1.0, t: -1.0), 2),
        DrawType.person.make("P1", obs..center = Point(x: -0.5, t: 1.0), 1),
      ];
      listRoundTrip(drawables, (s) {
        // s is usually a map, but now it is a list of maps.
        final l = s.cast<Map<String, dynamic>>();
        final result = l
            .map<Drawable>((json) => Drawable.fromJson(json))
            .toList();
        return result;
      });
    });
    test('scene', () async {
      Settings settings = Settings();
      settings.version = "test_version";
      SceneData scene1 = SceneData();
      makeDebugScene(scene1);
      roundTrip(scene1, (s) {
        return SceneData.fromJson(s);
      });
    });
  });

  // Hand interpret the json in TestData.
  group('test data', () {
    test('person', () async {
      final epsilon = 1e-6;
      SceneData scene = TestData.person.data;
      expect(scene.title, "Person Test Data Title");
      expect(scene.time, closeTo(0.0, epsilon));
      expect(scene.velocity, closeTo(0.0, epsilon));
      expect(scene.drawables.length, 1);
      expect(scene.drawables[0].name, "P1");
      expect(scene.drawables[0].type, DrawType.person);
      expect(scene.drawables[0].color, 0);
      expect(scene.drawables[0].pt, Point(x: 0.0, t: 0.0, z: 0.0));
      expect(scene.drawables[0].frame.velocity, closeTo(0.0, epsilon));
    });
    test('train', () async {
      final epsilon = 1e-6;
      SceneData scene = TestData.train.data;
      expect(scene.title, "Train Test Data Title");
      expect(scene.time, closeTo(0.5, epsilon));
      expect(scene.velocity, closeTo(0.123, epsilon));
      expect(scene.transform.frame.center, Point(x: 0.1, t: 0.2, z: 0.3));
      expect(scene.drawables.length, 1);
      expect(scene.drawables[0].name, "P1");
      expect(scene.drawables[0].type, DrawType.train);
      expect(scene.drawables[0].color, 1);
      expect(scene.drawables[0].pt, Point(x: -0.366, t: 0.364, z: 0.01));
      expect(scene.drawables[0].frame.velocity, closeTo(0.222, epsilon));
    });
  });
  group('legacy json', () {
    test('legacy1', () async {
      final epsilon = 1e-6;
      final file = File('test/resources/legacy1.json');
      final json = await file.readAsString();
      final parsed = jsonDecode(json);
      expect(parsed['velocity'], 0.1);
      expect(parsed['gamma'], 1); // This value does not match.
      SceneData scene = SceneData.fromJsonString(json);
      expect(scene.time, closeTo(3.87, epsilon));
      expect(scene.velocity, closeTo(0.1, epsilon));
      expect(scene.drawables.length, 3);
      expect(scene.drawables.map((d) => d.type), [
        DrawType.cone,
        DrawType.cone,
        DrawType.cone,
      ]);
      expect(scene.drawables.map((d) => d.color), [0, 1, 2]);
      expect(
        scene.drawables.map((d) => d.pt),
        pairwiseCompare(
          [
            Point(x: -4.2908, t: 5.689, z: 0.0),
            Point(x: -0.9846, t: 2.509, z: 0.0),
            Point(x: 3.4056, t: 0.5221, z: 0.0),
          ],
          near,
          "drawable points",
        ),
      );
    });
    test('legacy2', () async {
      final epsilon = 1e-6;
      final file = File('test/resources/legacy2.json');
      final json = await file.readAsString();
      final parsed = jsonDecode(json);
      expect(parsed['velocity'], -0.66933);
      expect(parsed['gamma'], closeTo(1.3459579, epsilon));
      SceneData scene = SceneData.fromJsonString(json);
      expect(scene.time, closeTo(2.86, epsilon));
      expect(scene.velocity, closeTo(-0.66933, epsilon));
      expect(scene.drawables.length, 7);
      expect(scene.drawables.map((d) => d.type), [
        DrawType.person,
        DrawType.clock,
        DrawType.train,
        DrawType.barn,
        DrawType.flag,
        DrawType.cone,
        DrawType.clock,
      ]);
      expect(
        scene.drawables.map((d) => d.color),
        [
          0,
          10,
          11,
          15,
          13,
          1,
          5,
        ].map((c) => c % SceneView.color_list.value.length).toList(),
      );
    });
  });

  group('malformed json & syntax editor', () {
    test('detects syntax error on invalid json', () {
      const String invalidJson = '{"title": "Broken", "time": 1.0, }';
      expect(
        () => SceneData.fromJsonString(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('loadFromRawJson recovers file manager from error', () {
      final settings = Settings();
      final manager = FileManager(settings);
      manager.status = LoadingStatus.Error;
      manager.exception = FormatException("Invalid JSON");

      const String validJson = '{"title": "Recovered Drawing", "time": 0.5}';
      manager.loadFromRawJson(validJson);

      expect(manager.status, LoadingStatus.Loaded);
      expect(manager.current.scene?.data.title, "Recovered Drawing");
    });

    testWidgets('JsonSyntaxEditorDialog syntax error validation and recovery', (
      tester,
    ) async {
      final app = AppTester(tester, url: TestData.error.url());
      await app.setup();
      await app.initialize();
      await app.findError("initial");

      // Verify splash widget caught the JSON error
      expect(app.manager.status, LoadingStatus.Error);
      expect(
        find.byKey(const ValueKey("edit_json_syntax_button")),
        findsOneWidget,
      );

      // Open JSON Syntax Editor Dialog
      await tester.tap(find.byKey(const ValueKey("edit_json_syntax_button")));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      // Enter invalid JSON and validate
      await tester.enterText(find.byType(TextField), '{"title": "Bad", }');
      await tester.tap(find.byKey(const ValueKey("validate_and_load_button")));
      await tester.pumpAndSettle();

      // Dialog stays open and shows error banner
      expect(find.textContaining("Syntax Error:"), findsOneWidget);

      // Fix JSON and validate
      await tester.enterText(
        find.byType(TextField),
        '{"title": "Fixed Drawing", "time": 0.0, "drawables": []}',
      );
      await tester.tap(find.byKey(const ValueKey("validate_and_load_button")));
      await tester.pumpAndSettle();

      // Dialog closes and scene is loaded
      expect(app.manager.status, LoadingStatus.Loaded);
      expect(app.manager.current.scene?.data.title, "Fixed Drawing");

      await app.teardown();
    });
  });
}
