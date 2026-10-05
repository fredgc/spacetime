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

String zzz(var vec) {
  return DebugPrint.pad_zzz > 0
      ? zzz2(vec).padLeft(DebugPrint.pad_zzz)
      : zzz2(vec);
}

String zzz2(var vec) {
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
  mouse_scale("Mouse drag/scaling", verbose: true),
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
  text_edit("Tap to Edit text"),
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

  static SavableBool remote_logging = SavableBool(
    "remote_logging",
    "Send Logs to Server",
    false,
    tip: "Send console logs to a local server at port 5001.",
    debug_only: true,
  );

  static List<SavableBool> group_active = [];
  static bool include_verbose = false;
  static RemoteLogger remote_logger = RemoteLogger();
  static bool running_tests = true;

  static void initSettings(Settings settings) {
    if (kIsWeb) settings.add(remote_logging);
    for (var group in values) {
      var savableBool = SavableBool(
        group.name,
        "Log ${group.name}",
        false,
        tip: "Log ${group.description}",
        debug_only: true,
      );
      group_active.add(savableBool);
      assert(group.name == group_active[group.index].name);
      settings.add(group_active[group.index]);
    }
    settings.add(EndOfGroup());
    settings.add(
      SavableBoolGroup("log_controls", "Log Settings", group_active)
        ..debug_only = true,
    );
  }

  static void fullApp() {
    running_tests = false;
  }

  void log(Object message) {
    // If debug disabled at compile time.
    if (!Settings.kDebugEnabled) return;
    // If debug disabled in settings.
    if (!Settings.debugEnabled) return;
    internal_log(
      () => "($name) ${message is Function ? (message as dynamic)() : message}",
    );
  }

  void make_active(bool on) {
    if (group_active.isEmpty) {
      // Always log messages locally if we have not yet initialized.
      print("Logging not initialized");
      return;
    }
    group_active[index].value = on;
  }

  void internal_log(String Function() message) {
    // If debug disabled at compile time.
    if (!Settings.kDebugEnabled) return;
    // If debug disabled in settings.
    if (!Settings.debugEnabled) return;
    // If we have not initialized logging, and we are running tests then we
    // don't need the extra logging.
    if (group_active.isEmpty && running_tests) {
      return;
    }
    if (group_active.isEmpty) {
      // Always log messages locally if we have not yet initialized.
      print("(pre-init) ${message()}");
      return;
    }
    if (index >= group_active.length) return;
    if (!group_active[index].value) return;
    if (verbose && !include_verbose) return;
    String evaluated = message();
    print(evaluated);
    if (!remote_logging.value) return;
    remote_logger.log(evaluated);
  }
}

class RemoteLogger {
  String total_message = "";
  bool _isSending = false;
  DateTime last_error = DateTime.utc(1990, 1, 2);

  void log(String message) async {
    // if recent error, wait 1 minute before trying again.
    DateTime now = DateTime.timestamp();
    final cutoff = now.subtract(const Duration(minutes: 1));
    if (last_error.isAfter(cutoff)) return;
    // If currently active, then append current message to next, return.
    total_message = "$total_message$message\n";
    if (_isSending) {
      return;
    }
    _isSending = true;
    while (total_message.isNotEmpty) {
      String current = total_message;
      total_message = "";
      try {
        // final url = Uri.parse('http://localhost:5001/log');
        final url = Uri.parse('http://localhost:5001/log');
        await http.post(
          url,
          headers: {'Content-Type': 'text/plain'},
          body: current,
        );
      } catch (err) {
        last_error = DateTime.timestamp();
        total_message = "";
        print("RED: HTTP Error: $err");
      }
    }
    _isSending = false;
  }
}

class DebugPrint {
  static String indent = "- ";
  static int print_debug = 0;
  static int pad_zzz = 7;

  static void dprint(String s, {int depth = 0}) {
    if (print_debug > 0) {
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
  static bool add_delay = false;

  Future<void> sleep(String text, Duration duration) async {
    if (add_delay) {
      Log.sleep.log("RED: Debug time $text.");
      await Future.delayed(duration);
      Log.sleep.log("RED: After debug time $text.");
    }
  }
}

Future<void> dsleep(String text, int duration) {
  return DebugSleep.instance.sleep(text, Duration(seconds: duration));
}
