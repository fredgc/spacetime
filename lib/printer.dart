// ignore_for_file: avoid_print
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import "transform.dart";
import "settings.dart";
import "slider.dart";

String trunc(Object? obj, {int cutoff = 50}) {
  String s = "$obj";
  final whitespace = RegExp(r"[\n\s]+");
  s = s.replaceAll(whitespace, " ");
  return (s.length <= cutoff) ? s : '${s.substring(0, cutoff)}...';
}

String zzz(Object? vec) {
  return DebugPrint.padZzz > 0
      ? zzz2(vec).padLeft(DebugPrint.padZzz)
      : zzz2(vec);
}

String zzz2(Object? vec) {
  if (vec is Offset) {
    return "o(${zzz(vec.dx)}, ${zzz(vec.dy)})";
  }
  if (vec is List) {
    return "[${vec.map((v) => zzz(v)).join(", ")}]";
  }
  if (vec is Point) {
    return "p(x:${zzz(vec.x)}, t:${zzz(vec.t)}, z:${zzz(vec.z)})";
  }
  if (vec is Vector) {
    return "v(dx:${zzz(vec.dx)}, dt:${zzz(vec.dt)})";
  }
  if (vec is Bounds) {
    return "b[min:${zzz(vec.min)}, max:${zzz(vec.max)}]";
  }
  if (vec is ReferenceFrame) {
    return "rf(${zzz(vec.center)}, v=${zzz(vec.velocity)}, g=${zzz(vec.gamma)})";
  }
  if (vec is MySlider) {
    return "s(${zzz(vec.value)})";
  }
  if (vec is double) {
    if (vec.isNaN) {
      return "NaN";
    }
    if (vec.isInfinite) {
      return "inf";
    }
    if (vec > 50 || vec < -50) {
      return "${vec.round()}";
    }
    return vec.toStringAsPrecision(3);
  }
  return "$vec";
}

enum Log {
  errors("errors and exceptions"),
  mouseScale("Mouse drag/scaling", verbose: true),
  update("Scene and Object update", verbose: true),
  fit("Fitting scene to viewport"),
  dump("Dump debug information"),
  menus("Menu shortcuts"),
  widget("Creating widgets, splash, and scenes"),
  animate("Animation state changes"),
  files("File manager and file holders"),
  drive("drive and authorization"),
  local("local files and upload/download"),
  navigation("Navigation and deep links"),
  textEdit("Tap to Edit text"),
  undo("Undo/Redo manager"),
  settings("Settings, colors, and themes load/save"),
  help("Help and HTML rendering"),
  json("Parsing json"),
  keys("Keyboard handle"),
  objects("Object edit and create"),
  select("Object selection"),
  sleep("Debug Sleep"),
  init("program initialization");

  final String description;
  final bool verbose;
  const Log(this.description, {this.verbose = false});

  static SavableBool remoteLogging = SavableBool(
    "remote_logging",
    "Send Logs to Server",
    false,
    tip: "Send console logs to a local server at port 5001.",
    debugOnly: true,
  );

  static List<SavableBool> groupActive = [];
  static bool includeVerbose = false;
  static RemoteLogger remoteLogger = RemoteLogger();
  static bool runningTests = true;

  static void initSettings(Settings settings) {
    if (kIsWeb) settings.add(remoteLogging);
    for (var group in values) {
      var savableBool = SavableBool(
        group.name,
        "Log ${group.name}",
        false,
        tip: "Log ${group.description}",
        debugOnly: true,
      );
      groupActive.add(savableBool);
      assert(group.name == groupActive[group.index].name);
      settings.add(groupActive[group.index]);
    }
    settings.add(EndOfGroup());
    settings.add(
      SavableBoolGroup("log_controls", "Log Settings", groupActive)
        ..debugOnly = true,
    );
  }

  static void fullApp() {
    runningTests = false;
  }

  void log(Object message) {
    // If debug disabled at compile time.
    if (!Settings.kDebugEnabled) return;
    // If debug disabled in settings.
    if (!Settings.debugEnabled) return;
    _internalLog(
      () => "($name) ${message is Function ? (message as dynamic)() : message}",
    );
  }

  void makeActive(bool on) {
    if (groupActive.isEmpty) {
      // Always log messages locally if we have not yet initialized.
      print("Logging not initialized");
      return;
    }
    groupActive[index].value = on;
  }

  void _internalLog(String Function() message) {
    // If debug disabled at compile time.
    if (!Settings.kDebugEnabled) return;
    // If debug disabled in settings.
    if (!Settings.debugEnabled) return;
    // If we have not initialized logging, and we are running tests then we
    // don't need the extra logging.
    if (groupActive.isEmpty && runningTests) {
      return;
    }
    if (groupActive.isEmpty) {
      // Always log messages locally if we have not yet initialized.
      print("(pre-init) ${message()}");
      return;
    }
    if (index >= groupActive.length) return;
    if (!groupActive[index].value) return;
    if (verbose && !includeVerbose) return;
    String evaluated = message();
    print(evaluated);
    if (!remoteLogging.value) return;
    remoteLogger.log(evaluated);
  }
}

class RemoteLogger {
  String _totalMessage = "";
  bool _isSending = false;
  DateTime _lastError = DateTime.utc(1990, 1, 2);

  void log(String message) async {
    // if recent error, wait 1 minute before trying again.
    DateTime now = DateTime.timestamp();
    final cutoff = now.subtract(const Duration(minutes: 1));
    if (_lastError.isAfter(cutoff)) return;
    // If currently active, then append current message to next, return.
    _totalMessage = "$_totalMessage$message\n";
    if (_isSending) {
      return;
    }
    _isSending = true;
    while (_totalMessage.isNotEmpty) {
      String current = _totalMessage;
      _totalMessage = "";
      try {
        // final url = Uri.parse('http://localhost:5001/log');
        final url = Uri.parse('http://localhost:5001/log');
        await http.post(
          url,
          headers: {'Content-Type': 'text/plain'},
          body: current,
        );
      } catch (err) {
        _lastError = DateTime.timestamp();
        _totalMessage = "";
        print("RED: HTTP Error: $err");
      }
    }
    _isSending = false;
  }
}

class DebugPrint {
  static String indent = "- ";
  static int printDebug = 0;
  static int padZzz = 7;

  static void dprint(String s, {int depth = 0}) {
    if (printDebug > 0) {
      String extraIndent = indent;
      for (int i = 0; i < depth; i++) {
        extraIndent = "$extraIndent  ";
      }
      print("$extraIndent$s");
    }
  }

  static String incIndent(String s) {
    String old = indent;
    indent = indent + s;
    return old;
  }

  static void decIndent(String old) {
    indent = old;
  }
}

// add DebugClass.
void dprint(String s, {int depth = 0}) {
  DebugPrint.dprint(s, depth: depth);
}

// This class is used to test and debug long initialization times.  It is useful
// when testing splash screens and other events that are usually short lived.
class DebugSleep {
  static DebugSleep instance = DebugSleep();
  // Set this to true in order to add extra delays.
  static bool addDelay = false;

  Future<void> sleep(String text, Duration duration) async {
    if (addDelay) {
      Log.sleep.log("RED: Debug time $text.");
      await Future.delayed(duration);
      Log.sleep.log("RED: After debug time $text.");
    }
  }
}

Future<void> dsleep(String text, int duration) {
  return DebugSleep.instance.sleep(text, Duration(seconds: duration));
}
