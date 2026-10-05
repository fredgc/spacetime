// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Code reused from polytope project.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'color.dart';
import 'navigation.dart';
import 'printer.dart';
import 'js_stub.dart' if (dart.library.html) 'js_interface.dart';

enum SettingsStatus {
  NotInitialized, // Before Settings intiialized.
  Initialized,
}

abstract class Savable<T> {
  final String name; // Must be unique to be a key.
  final String description;
  final String tip;
  T value;

  bool visible = true; // If true, include this on the settings page.
  bool debug_only =
      false; // If true, only visible when Settings.enable_debug.value is true.

  Savable(
    this.name,
    this.description,
    this.value, {
    this.tip = "",
    this.debug_only = false,
  });

  void load(SharedPreferencesWithCache prefs);
  void save(SharedPreferencesWithCache prefs);

  // This is called when the theme changes.
  void updateTheme(ColorScheme scheme) {}

  // For building a UI.
  List<Widget?> build(BuildContext context, VoidCallback rebuild);
  void dispose() {}

  @override
  String toString() {
    return "Savable $name ($description) value=$value";
  }
}

class SavableBool extends Savable<bool> {
  SavableBool(
    super.name,
    super.description,
    super.value, {
    super.tip = "",
    super.debug_only,
  });
  @override
  void load(SharedPreferencesWithCache prefs) {
    value = prefs.getBool(name) ?? value;
    // Log.settings.log("Loaded $name -> $value");
  }

  @override
  void save(SharedPreferencesWithCache prefs) {
    // Log.settings.log("Saving $name -> $value");
    prefs.setBool(name, value);
  }

  @override
  List<Widget?> build(BuildContext context, VoidCallback rebuild) {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$description: "),
          Checkbox(
            value: value,
            onChanged: (bool? value) {
              this.value = value!;
              rebuild();
            },
          ),
        ],
      ),
    ];
  }
}

class SavableDouble extends Savable<double> {
  TextEditingController? _controller;

  SavableDouble(super.name, super.description, super.value, {super.tip = ""});
  @override
  void load(SharedPreferencesWithCache prefs) {
    value = prefs.getDouble(name) ?? value;
    // Log.settings.log("Loaded $name -> $value");
  }

  @override
  void save(SharedPreferencesWithCache prefs) {
    try {
      if (_controller != null) {
        value = double.parse(_controller!.text);
      }
    } catch (ex) {
      Log.settings.log("Parse error in ${_controller!.text} for $name");
    }
    // Log.settings.log("Saving $name -> $value");
    prefs.setDouble(name, value);
  }

  @override
  List<Widget?> build(BuildContext context, VoidCallback rebuild) {
    // Log.settings.log("Building widget for $name");
    _controller = TextEditingController();
    _controller!.text = value.toString();
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$description: "),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _controller,
              // style: TextStyle(fontSize: 10),
              decoration: InputDecoration(hintText: tip),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    // Log.settings.log("Disposing of widget for $name");
    _controller?.dispose();
    _controller = null;
  }
}

class SavableInt extends Savable<int> {
  TextEditingController? _controller;

  SavableInt(super.name, super.description, super.value, {super.tip = ""});

  @override
  void load(SharedPreferencesWithCache prefs) {
    value = prefs.getInt(name) ?? value;
  }

  @override
  void save(SharedPreferencesWithCache prefs) {
    try {
      if (_controller != null) {
        value = int.parse(_controller!.text);
      }
    } catch (ex) {
      Log.settings.log("Parse error in ${_controller!.text} for $name");
    }
    prefs.setInt(name, value);
  }

  @override
  List<Widget?> build(BuildContext context, VoidCallback rebuild) {
    _controller = TextEditingController();
    _controller!.text = value.toString();
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$description: "),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: tip),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}

// Add an EndOfGroup to the settings to
class EndOfGroup extends Savable<int> {
  static int count = 0;
  EndOfGroup() : super("row $count", "UI Feature", count++);

  @override
  void load(SharedPreferencesWithCache prefs) {}
  @override
  void save(SharedPreferencesWithCache prefs) {}

  // For building a UI.
  @override
  List<Widget?> build(BuildContext context, VoidCallback rebuild) {
    return [null];
  }
}

class SavableBoolGroup extends Savable<int> {
  final List<SavableBool> items;

  SavableBoolGroup(String name, String description, this.items)
    : super(name, description, 0);

  @override
  void load(SharedPreferencesWithCache prefs) {}

  @override
  void save(SharedPreferencesWithCache prefs) {}

  void turnAllOn(VoidCallback rebuild) {
    for (var item in items) {
      item.value = true;
    }
    rebuild();
  }

  void turnAllOff(VoidCallback rebuild) {
    for (var item in items) {
      item.value = false;
    }
    rebuild();
  }

  @override
  List<Widget?> build(BuildContext context, VoidCallback rebuild) {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$description: "),
          ElevatedButton(
            onPressed: () => turnAllOn(rebuild),
            child: const Text("Turn All On"),
          ),
        ],
      ),
      ElevatedButton(
        onPressed: () => turnAllOff(rebuild),
        child: const Text("Turn All Off"),
      ),
    ];
  }
}

class Settings {
  static SavableBool enable_debug = SavableBool(
    "enable_debug",
    "Enable Debug Mode",
    false,
    tip: "Enable debug settings and controls.",
  );

  // This is a compile time constant, so anything gated by this will removed by
  // the compiler (tree shaking).
  static const bool kDebugEnabled =
      foundation.kDebugMode ||
      bool.fromEnvironment('DEBUG_ENABLED', defaultValue: false);

  static bool get debugEnabled => kDebugEnabled && enable_debug.value;

  SettingsStatus _status = SettingsStatus.NotInitialized;
  final StreamController<SettingsStatus> _statusStream =
      StreamController<SettingsStatus>.broadcast();

  String app_name = "uninitialized";
  String version = "uninitialized";
  String build_number = "-";
  bool no_keyboard = false;
  Future<void>? _loading_future;

  List<Savable> savables = []; //All settings.
  Map<String, Savable> savables_map = {};

  SavableTheme theme = SavableTheme();
  Color get background_color => theme.background_color.value;

  Settings();

  void initDebug() {
    if (kDebugEnabled) {
      add(EndOfGroup());
      add(enable_debug);
    }
  }

  // This might be called several times, but load() uses a singleton to prevent
  // simultaneous calls.
  Future<void> initialize(BuildContext context) {
    _checkKeyboard();
    theme.initialize(resetColorsAndNotify, context);
    resetColors();
    return load();
  }

  void _checkKeyboard() {
    if (foundation.kIsWeb) {
      // Log.settings.log('Running on the web!');
    } else {
      // Log.settings.log('Not running on the web!');
    }
    // Maybe assume there is no keyboard if
    no_keyboard =
        (foundation.defaultTargetPlatform == TargetPlatform.iOS ||
        foundation.defaultTargetPlatform == TargetPlatform.android);
    // Log.settings.log("noKeboard = $no_keyboard");
  }

  SettingsStatus get status {
    return _status;
  }

  set status(SettingsStatus newStatus) {
    _status = newStatus;
    if (_statusStream.hasListener) _statusStream.add(_status);
  }

  // These stream is notified whenever the settings have been initialized or updated.
  Stream<SettingsStatus> statusStream() async* {
    yield _status;
    yield* _statusStream.stream;
  }

  // This must be called before adding any other color settings if you want
  // them to be able to adjust based on the current theme.
  void addTheme() {
    add(theme);
  }

  void add(Savable savable) {
    if (savables_map.containsKey(savable.name)) {
      throw (StateError(
        "Setting name collision: $savable with ${savables_map[savable.name]}",
      ));
    }
    savables.add(savable);
  }

  Future<void> load() {
    _loading_future ??= _load_future();
    return _loading_future!;
  }

  Future<SharedPreferencesWithCache> getPrefs() {
    // XXX This does not work because SavableTheme don't use name.
    // XXX Set<String> name_list = savables_map.keys.toSet();
    // XXX var options = SharedPreferencesWithCacheOptions(allowList: name_list);
    var options = SharedPreferencesWithCacheOptions();
    return SharedPreferencesWithCache.create(cacheOptions: options);
  }

  Future<void> _load_future() async {
    Log.settings.log("In _load_future.");
    await dsleep("settings", 3);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    app_name = packageInfo.appName;
    version = packageInfo.version;
    build_number = packageInfo.buildNumber;
    Log.settings.log("Package info: $app_name, $build_number, $version");
    var prefs = await getPrefs();
    Log.settings.log("prefs = $prefs");
    // theme.load(prefs);
    for (var s in savables) {
      s.load(prefs);
    }
    Log.settings.log("Settings done initialized.");
    status = SettingsStatus.Initialized;
    _loading_future = null;
    Log.settings.log("Finished loading settings.");

    if (foundation.kIsWeb) {
      unawaited(checkServerVersionAndReload());
    }
  }

  Future<void> checkServerVersionAndReload() async {
    try {
      final uri = Uri.parse(
        "version.json?nocache=${DateTime.now().millisecondsSinceEpoch}",
      );
      final response = await http.get(
        uri,
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? serverVersion = data['version'];
        final String clientVersion = "$version+$build_number";
        Log.settings.log(
          "Server version check: client=$clientVersion, server=$serverVersion",
        );
        if (serverVersion != null &&
            serverVersion.isNotEmpty &&
            serverVersion != clientVersion &&
            serverVersion != version) {
          Log.settings.log(
            "PURPLE: Server version ($serverVersion) differs from client ($clientVersion). Auto reloading...",
          );
          await reloadAndFlushCache();
        }
      }
    } catch (e) {
      Log.settings.log("Error checking server version: $e");
    }
  }

  Future<void> save() async {
    // Log.settings.log("saving settings.");
    final prefs = await getPrefs();
    for (var s in savables) {
      s.save(prefs);
    }
  }

  void notify() {
    // Notify all the other widgets, so that they redraw with latest settings.
    if (_statusStream.hasListener) _statusStream.add(_status);
  }

  // This is called when the theme has been updated.
  void resetColorsAndNotify() {
    Log.settings.log("reset colors and notify");
    resetColors();
    notify();
  }

  // Set colors based on light/dark theme mode. Previously chosen colors will
  // be erased.
  void resetColors() {
    Log.settings.log(
      "--- reset colors using brightnss = ${theme.scheme.brightness}",
    );
    for (var s in savables) {
      s.updateTheme(theme.scheme);
    }
  }
}

class SettingsScreen extends StatefulWidget {
  final Settings settings;
  static const routeName = "/settings";
  const SettingsScreen(this.settings, {super.key});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late StreamSubscription _statusListener;

  @override
  void initState() {
    // Log.settings.log("Settings.initState.");
    super.initState();
    _statusListener = widget.settings.statusStream().listen((status) {
      // Log.settings.log("Settings listener: heard status = $status");
      setState(() {
        // Log.settings.log("Settings own listener heard status changed. set state.");
      });
    });
  }

  @override
  void dispose() {
    // Log.settings.log("dispose of settings widget.");
    _statusListener.cancel();
    for (var s in widget.settings.savables) {
      s.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.settings.status == SettingsStatus.NotInitialized) {
      widget.settings.initialize(context).then((_) {
        setState(() {});
      });
      return Text("Initiaizing Settings...");
    }
    // Log.settings.log("Building SettingsScreen.");
    List<Widget?> children = _pickChildren(context);
    List<List<Widget>> rows = [for (var s in MyIterator(children)) s];
    final list = ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: rows.length,
      itemBuilder: (buildContext, int index) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: rows[index],
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
    return MaterialApp(
      // XXX debugShowCheckedModeBanner: false,
      theme: widget.settings.theme.theme_data,
      home: Scaffold(appBar: appBar(context), body: list),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text("Settings"),
      actions: <Widget>[
        ElevatedButton(
          child: const Icon(Icons.close),
          onPressed: () {
            // Log.settings.log("Cancel.");
            quit(context);
          },
        ),
        ElevatedButton(
          child: const Icon(Icons.done),
          onPressed: () {
            // Log.settings.log("Done.");
            done(context);
          },
        ),
      ],
    );
  }

  // Get the list of widgets from all the savable objects.
  // Then flatten this list of lists so we get one big list.
  List<Widget?> _pickChildren(BuildContext context) {
    if (widget.settings.status == SettingsStatus.NotInitialized) {
      return [Text("Initializing App...")];
    }
    List<List<Widget?>> list1 = [
      [
        SelectableText(
          "Application ${widget.settings.app_name} "
          "version ${widget.settings.version}.${widget.settings.build_number}",
        ),
        if (foundation.kIsWeb) ...[
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Clear Cache & Reload App"),
            onPressed: () => reloadAndFlushCache(),
          ),
        ],
        null,
      ],
      for (var s in widget.settings.savables)
        if (s.visible && (!s.debug_only || Settings.debugEnabled))
          (s.build(context, () {
            setState(() {});
          })),
      [
        null,
        ElevatedButton(onPressed: () => done(context), child: Text("Done")),
        ElevatedButton(onPressed: () => quit(context), child: Text("Cancel")),
      ],
    ];
    // Flatten the list.
    return [
      for (var sublist in list1)
        for (var w in sublist) w,
    ];
  }

  void done(BuildContext context) async {
    Log.settings.log("CYAN: Done with settings.");
    await widget.settings.save();
    widget.settings.notify();
    popOrHome(context);
  }

  void quit(BuildContext context) async {
    Log.settings.log("CYAN: Done with settings. Don't save.");
    await widget.settings.load();
    widget.settings.notify();
    popOrHome(context);
  }
}

// Unflatten a list of widgets into a list of lists, breaking at nulls.
// [a, b, null, c, d, e, null, f] => [[a,b], [c,d,e], [f]]
class MyIterator extends Iterable<List<Widget>>
    implements Iterator<List<Widget>> {
  List<Widget?> input;
  List<Widget> _current = [];
  @override
  List<Widget> get current => _current;
  @override
  Iterator<List<Widget>> get iterator => this;

  MyIterator(this.input);

  @override
  bool moveNext() {
    while (input.isNotEmpty) {
      int i = input.indexWhere((s) => s == null);
      if (i < 0) {
        _current = input.nonNulls.toList();
        input = [];
      } else {
        _current = input.sublist(0, i).nonNulls.toList();
        input = input.sublist(i + 1);
      }
      if (_current.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
