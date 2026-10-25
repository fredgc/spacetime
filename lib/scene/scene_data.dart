import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../drawable.dart';
import '../printer.dart';
import '../transform.dart';
import '../worker.dart';

// All of the data in a scene. This is all the stuff that needs to be saved to a
// file.
class SceneData {
  static String version = "uninitialized";
  String title = "Untitled Drawing"; // or filename?
  String description = "";
  List<Drawable> drawables = [];
  double time = 0.0;
  double velocity = 0.0;
  CoordinateTransform transform = CoordinateTransform();

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;

  bool isLegacy = false;

  SceneData();

  void dispose() {}

  Future<void> updateDrawables(
    double t,
    List<double> sticky,
    Interrupter interrupter,
  ) async {
    for (var d in List<Drawable>.from(drawables)) {
      if (interrupter.stop) return;
      await d.update(transform, t, sticky);
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    SceneData s = other as SceneData;
    return s.title == title &&
        listEquals(s.drawables, drawables) &&
        time == s.time &&
        velocity == s.velocity &&
        transform.frame.center == s.transform.frame.center &&
        transform.zoom == s.transform.zoom;
  }

  @override
  int get hashCode => Object.hash(
    title,
    Object.hashAll(drawables),
    time,
    velocity,
    transform.frame.center,
    transform.zoom,
  );

  void verboseCompare(Object other) {
    if (other.runtimeType != runtimeType) {
      Log.errors.log("Wrong types ${other.runtimeType} and $runtimeType");
      return;
    }
    SceneData s = other as SceneData;

    if (s.title != title) Log.errors.log("XXX title: $title != ${s.title}");
    if (time != s.time) Log.errors.log("XXX time ");
    if (velocity != s.velocity) Log.errors.log("XXX velocity ");
    if (transform.frame.center != s.transform.frame.center) {
      Log.errors.log("XXX center ");
    }
    if (transform.zoom != s.transform.zoom) Log.errors.log("XXX zoom");

    if (s.drawables.length != drawables.length) {
      Log.errors.log(
        "XXX length unequal ${s.drawables.length} != ${drawables.length}",
      );
      return;
    }
    for (int i = 0; i < drawables.length; i++) {
      if (s.drawables[i] != drawables[i]) {
        Log.errors.log("XXX $i -> ${zzz(drawables[i])}");
        Log.errors.log("XXX s -> ${zzz(s.drawables[i])}");
        return;
      }
    }
  }

  @override
  String toString() {
    return "data-$_debugId '$title'";
  }

  void fitView() {
    Log.fit.log("GREEN: t = ${zzz(transform)}");
    Bounds bounds = Bounds(
      Point(x: -1.0, t: -1.0, z: 0.0),
      Point(x: 1.0, t: 1.0, z: 0.0),
    );
    Log.fit.log("initial bounds = ${zzz(bounds)}");
    for (var d in drawables) {
      d.addToBounds(bounds);
      Log.fit.log("world = ${zzz(d.pt)}");
      Log.fit.log("after ${d.name} bounds = ${zzz(bounds)}, ${zzz(d.ptObs)}");
    }
    transform.fit(bounds);
    Log.fit.log("BLUE: t = ${zzz(transform)}");
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "drawables": drawables,
    "time": time,
    "velocity": velocity,
    "center": transform.frame.center,
    "zoom": transform.zoom,
    "dx": transform.offset.dx / transform.size.width.toDouble(),
    "dy": transform.offset.dy / transform.size.height.toDouble(),
    "dz": transform.dz,
    "version": version,
  };

  factory SceneData.fromJsonString(String jsonString) {
    Log.json.log("json = $jsonString");
    Map<String, dynamic> json;
    try {
      json = jsonDecode(jsonString);
    } on FormatException catch (e) {
      if (e.offset != null) {
        final before = jsonString.substring(0, e.offset!);
        final lines = before.split('\n');
        final lineNumber = lines.length;
        final columnNumber = lines.last.length + 1;
        final allLines = jsonString.split('\n');
        final errorLine = allLines[lineNumber - 1];
        final pointer = ' ' * (columnNumber - 1) + '^';
        final message =
            'JSON Syntax Error at line $lineNumber, '
            'column $columnNumber:\n\n'
            '$errorLine\n'
            '$pointer\n\n'
            'Details: ${e.message}';
        Log.json.log("Format exception: $message");
        throw FormatException(message);
      }
      rethrow;
    }
    try {
      return SceneData.fromJson(json);
    } catch (ex1) {
      Log.json.log("RED: $ex1. Trying to parse as legacy save file");
      try {
        return SceneData.fromJsonLegacy(json);
      } catch (ex2) {
        Log.json.log("RED: $ex2. From the legacy file.");
        throw ex1;
      }
    }
  }

  factory SceneData.fromJson(Map<String, dynamic> json) {
    String version = json['version'] ?? "old";
    Log.json.log("Version was $version");
    SceneData scene = SceneData();
    scene.title = json["title"] ?? "Untitled Drawing";
    scene.description = json["description"] ?? "";
    scene.time = (json["time"] as num?)?.toDouble() ?? 0.0;
    scene.velocity = (json["velocity"] as num?)?.toDouble() ?? 0.0;
    if (json["center"] != null) {
      scene.transform.frame.center = Point.fromJson(json["center"]);
    }
    scene.transform.zoom = (json["zoom"] as num?)?.toDouble() ?? 1.0;
    double dx = (json["dx"] as num?)?.toDouble() ?? 0.5;
    double dy = (json["dy"] as num?)?.toDouble() ?? 0.5;
    scene.transform.offset = Offset(
      dx * scene.transform.size.width,
      dy * scene.transform.size.height,
    );
    scene.transform.dz = (json["dz"] as num?)?.toDouble() ?? 10.0;

    if (json["drawables"] != null) {
      if (json["drawables"] is List) {
        final l = (json["drawables"] as List).cast<Map<String, dynamic>>();
        scene.drawables = l
            .map<Drawable>((json) => Drawable.fromJson(json))
            .toList();
      } else {
        throw const FormatException("drawables is not a List");
      }
    }
    return scene;
  }

  factory SceneData.fromJsonLegacy(Map<String, dynamic> json) {
    SceneData scene = SceneData();
    scene.isLegacy = true;
    scene.title = "Untitled Drawing";
    scene.time = (json["time"] as num?)?.toDouble() ?? 0.0;
    scene.velocity = (json["velocity"] as num?)?.toDouble() ?? 0.0;
    scene.transform.frame.center = Point(
      x: (json["center_x"] as num?)?.toDouble() ?? 0.0,
      t: (json["center_t"] as num?)?.toDouble() ?? 0.0,
    );
    scene.transform.zoom = 1.0 / json["scale"];
    final drawables = json["drawables"]["list"];
    final list = (drawables as List).cast<Map<String, dynamic>>();
    Log.json.log("Found ${list.length} drawables.");
    scene.drawables = list
        .map<Drawable>((json) => Drawable.fromJsonLegacy(json))
        .toList();
    Log.json.log("Parsed legacy scene");
    scene.fitView();
    return scene;
  }
}
