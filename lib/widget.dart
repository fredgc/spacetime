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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import "printer.dart";
import "splitter.dart";
import 'animate.dart';
import 'drive.dart';
import 'edit.dart';
import 'file_manager.dart';
import 'menus.dart';
import 'navigation.dart';
import 'scene.dart';
import 'settings.dart';
import 'slider.dart';
import 'sprites.dart';

import 'js_stub.dart' if (dart.library.html) 'js_interface.dart';

// A widget used to wrap a splash screen during initialization or an app widget
// after initialization.
class SplashWidget extends StatefulWidget {
  final Settings settings;
  final FileManager file_manager;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "Splash-$debug_id";

  SplashWidget(this.settings, this.file_manager, {super.key}) {
    Log.widget.log("MAGENTA: Create new $this.");
  }

  @override
  State<SplashWidget> createState() {
    // Log.widget.log("MAGENTA: Create state for $this.");
    return SplashWidgetState();
  }
}

class SplashWidgetState extends State<SplashWidget>
    with SingleTickerProviderStateMixin {
  late StreamSubscription _settings_listener;
  late StreamSubscription _file_listener;
  late StreamSubscription _drive_listener;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "SState-$debug_id for $widget";

  SplashWidgetState() {
    // Log.widget.log("ORANGE: Create new splash widget state $debug_id.");
  }

  @override
  void initState() {
    super.initState();
    // Log.widget.log("ORANGE: $this initState.");
    removeSplashFromWeb();
    _settings_listener = widget.settings.statusStream().listen((status) {
      // Copy the version string from settings to SceneData.
      SceneData.version = widget.settings.version;
      if (mounted) setState(() {});
    });
    _file_listener = widget.file_manager.statusStream().listen((status) {
      if (mounted) setState(() {});
    });
    _drive_listener = widget.file_manager.drive_access.statusStream().listen((
      status,
    ) {
      if (mounted &&
          status == DriveAccessStatus.Authorized &&
          widget.file_manager.current.holder is DriveHolder &&
          widget.file_manager.status == LoadingStatus.Error) {
        widget.file_manager.reload();
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(SplashWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    removeSplashFromWeb();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // Log.widget.log("ORANGE: Dispose of $this.");
    _settings_listener.cancel();
    _file_listener.cancel();
    _drive_listener.cancel();
    super.dispose();
  }

  Widget splashText(BuildContext context, String s) {
    removeSplashFromWeb();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: widget.file_manager.isTesting ? 0.5 : null,
            ),
            const SizedBox(height: 20),
            Text(
              s,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int build_count = 0;
  @override
  Widget build(BuildContext context) {
    build_count++;
    Log.widget.log(
      "ORANGE: build $this, c=$build_count "
      "${widget.file_manager.current}, "
      "status=${widget.file_manager.status}"
      ", v${widget.settings.version}.${widget.settings.build_number}",
    );
    Log.widget.log(
      "ORANGE: settings=${widget.settings.status}, "
      "sprites=${Sprite.initialized}",
    );
    widget.file_manager.setContext("Widget $this, $build_count", context);
    Widget center;
    if (widget.settings.status == SettingsStatus.NotInitialized) {
      Log.widget.log("MAGENTA: splash settings.");
      widget.settings.initialize(context);
      Sprite.initialize(context, widget.settings);
      center = splashText(context, "Initializing Settings...");
    } else if (!Sprite.initialized) {
      Log.widget.log("MAGENTA: splash sprites.");
      center = splashText(context, "Initializing Sprites...");
    } else if (widget.file_manager.status == LoadingStatus.NotInitialized) {
      Log.widget.log("MAGENTA: splash file manager.");
      center = splashText(context, "Initializing file access...");
    } else if (widget.file_manager.status == LoadingStatus.Error) {
      Log.widget.log("MAGENTA: splash error.");
      // GoRouter router = GoRouter.of(context);
      // Log.widget.log("Router canpop = ${router.canPop()}, router=$router");
      center = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          splashText(
            context,
            "Error Loading "
            "${widget.file_manager.current.holder.userDescription()}",
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              child: ExpansionTile(
                key: const ValueKey("expand_load_error_details"),
                title: const Text(
                  "Expand Error Details",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      widget.file_manager.exception?.toString() ??
                          "Unknown load error",
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.file_manager.current.holder is DriveHolder &&
              widget.file_manager.drive_access.status !=
                  DriveAccessStatus.Authorized) ...[
            ElevatedButton.icon(
              key: const ValueKey("drive_sign_in_button"),
              icon: const Icon(Icons.login),
              label: const Text("Sign In to Google Drive"),
              onPressed: () async {
                bool authorized = await widget.file_manager.drive_access
                    .getAuthorization(context);
                if (authorized && mounted) {
                  setState(() {
                    widget.file_manager.reload();
                  });
                }
              },
            ),
            const SizedBox(height: 8),
          ] else ...[
            ElevatedButton(
              key: const ValueKey("edit_json_syntax_button"),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (c) =>
                      JsonSyntaxEditorDialog(fileManager: widget.file_manager),
                );
                if (result == true && mounted) {
                  setState(() {});
                }
              },
              child: const Text("Edit JSON Syntax"),
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: () => setState(() {
              widget.file_manager.popCurrentFile(context);
            }),
            child: Text("Go back to ${widget.file_manager.previous}"),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.file_manager.makeNew();
              });
            },
            child: Text("Open empty scene"),
          ),
        ],
      );
    } else if (widget.file_manager.status != LoadingStatus.Loaded) {
      Log.widget.log("MAGENTA: splash file loading.");
      center = splashText(context, "Loading...");
    } else if (widget.file_manager.current.scene == null) {
      Log.widget.log("MAGENTA: splash scene viewer is null.");
      center = splashText(context, "BUG: scene view is null");
    } else {
      center = AppWidget(
        widget.file_manager.current.scene!,
        widget.settings,
        widget.file_manager,
        key: ObjectKey(widget.file_manager.current.scene!),
      );
      Log.widget.log("MAGENTA: splash scene for $this, scene_widget = $center");
      fixAddressBar(context, widget.file_manager.current.holder.path);
    }

    if (center is! AppWidget) {
      return Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16.0), child: center),
        ),
      );
    }

    return center;
  }
}

class AppWidget extends StatefulWidget {
  final Settings settings;
  final SceneView scene_viewer;
  final FileManager file_manager;
  final MyUndoManager undo_manager;
  final MyMenu file_menu;
  final EditMenu edit_menu;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "AppWidget-$debug_id";

  AppWidget(this.scene_viewer, this.settings, this.file_manager, {super.key})
    : undo_manager = scene_viewer.undo_manager,
      file_menu = file_manager.makeMenu(),
      edit_menu = EditMenu(scene_viewer, scene_viewer.undo_manager) {
    // Log.widget.log("ORANGE: Create new $this for ${file_manager.current}.");
  }

  @override
  State<AppWidget> createState() {
    AppWidgetState state = AppWidgetState();
    // Log.widget.log("ORANGE: Create state for $this, viewer=${this.scene_viewer}.");
    return state;
  }
}

class AppWidgetState extends State<AppWidget>
    with SingleTickerProviderStateMixin {
  final MyMenu view_menu = MyMenu("View");
  final MyShortcutManager shortcut_manager = MyShortcutManager();
  late final MyAnimator animator; // Created in init state.
  BoxConstraints _constraints = BoxConstraints();
  bool _narrow = false;

  late final Timer debug_timer;
  int timer_counter = 0;
  int build_count = 0;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "WState-$debug_id for $widget";

  AppWidgetState() {
    // Log.widget.log("ORANGE: Create app widget state $debug_id.");
  }

  static SavableBool debug_logs = SavableBool(
    "debug_logs",
    "Periodic Debug Logs",
    false,
    tip: "Print some debug logs to the console.",
    debug_only: true,
  );

  late final StreamSubscription _settings_listener;

  void updateSettings() {
    widget.scene_viewer.updateSettings();
  }

  @override
  void initState() {
    // Log.widget.log("ORANGE: initState for app widget state $debug_id.");
    // Log.widget.log("this viewer = ${this.widget.scene_viewer}");
    super.initState();
    _settings_listener = widget.settings.statusStream().listen((status) {
      updateSettings();
      if (mounted) setState(() {});
    });
    animator = MyAnimator(this, widget.scene_viewer);
    _setupSceneViewer();
    // XXX shortcut_manager.dumpShortcuts();
    HardwareKeyboard.instance.addHandler(keyHandler);
  }

  void _setupSceneViewer() {
    widget.scene_viewer.startAnimation = startAnimation;
    widget.scene_viewer.time.startAnimation = startAnimation;
    debug_timer = makeTimer();
    widget.scene_viewer.light_speed.addListener(updateLayout);
    // When a new object is selected, then we need to update the name
    // text field and sidebar controls.
    widget.scene_viewer.current_name.addListener(updateLayout);
    widget.scene_viewer.current_type.addListener(updateLayout);
    widget.scene_viewer.current_color.addListener(updateLayout);
    widget.scene_viewer.current_tool.addListener(updateLayout);
    view_menu.items = [
      for (var s in widget.scene_viewer.light_speed.makeItems()) s,
      MyMenuItem(
        "Fit Scene",
        callback: () => setState(() => widget.scene_viewer.fitViewAndUpdate()),
      ),
    ];
    shortcut_manager.clear();
    shortcut_manager.add(widget.file_menu);
    shortcut_manager.add(widget.edit_menu);
    shortcut_manager.add(view_menu);
    shortcut_manager.add(widget.scene_viewer.light_speed);
    shortcut_manager.add(widget.scene_viewer.current_tool);
    shortcut_manager.add(widget.scene_viewer.current_type);
    shortcut_manager.add(widget.scene_viewer.current_color);
  }

  void _cleanupSceneViewer(SceneView oldViewer) {
    debug_timer.cancel();
    oldViewer.light_speed.removeListener(updateLayout);
    oldViewer.current_name.removeListener(updateLayout);
    oldViewer.current_type.removeListener(updateLayout);
    oldViewer.current_color.removeListener(updateLayout);
    oldViewer.current_tool.removeListener(updateLayout);
  }

  @override
  void didUpdateWidget(AppWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene_viewer != widget.scene_viewer) {
      _cleanupSceneViewer(oldWidget.scene_viewer);
      animator.dispose();
      animator = MyAnimator(this, widget.scene_viewer);
      _setupSceneViewer();
    }
  }

  void updateLayout() {
    setState(() {});
  }

  Timer makeTimer() {
    return Timer.periodic(const Duration(seconds: 5), (timer) {
      if (debug_logs.value) {
        timer_counter++;
        Log.widget.log(
          "$timer_counter, b$build_count, ${widget.scene_viewer.debugPrint()}${animator.debugPrint()}",
        );
      }
    });
  }

  void startAnimation() {
    Log.widget.log("GREEN: Widget heard startAnimation.");
    animator.play();
  }

  @override
  void dispose() {
    // Log.widget.log("ORANGE: Dispose of $this.");
    _settings_listener.cancel();
    HardwareKeyboard.instance.removeHandler(keyHandler);
    animator.dispose();
    _cleanupSceneViewer(widget.scene_viewer);
    super.dispose();
  }

  bool keyHandler(KeyEvent event) {
    if (widget.scene_viewer.keyHandle(event.character, event.logicalKey)) {
      // Log.widget.log("Key changed event: $event");
      setState(() {
        Log.widget.log("Key state changed.");
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!isTopWidget(context)) {
      // XXX This shows up when there is a pop-up.
      // Log.widget.log("ORANGE: build $this is not top.");
      // XXX return Text("Not top $this");
    }
    build_count++;
    // This happens on every state change, including slider updates.
    // Log.widget.log("ORANGE: build $this.  uri.base = ${trunc(Uri.base)}");
    // Log.widget.log("this.viewer=${this.widget.scene_viewer}, ");
    // Log.widget.log("w.viewer=${widget.scene_viewer}, ");
    Widget center = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // If the constraints have changed, then we want to try the wide layout
        // again.  If not then keep the previous state of _narrow.
        if (constraints != _constraints) {
          // Log.widget.log("Changing narrow to false.");
          _narrow = false;
          _constraints = constraints;
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: widget.settings.theme.theme_data,
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final browserFontSize = getBrowserRootFontSize();
            final scaleFactor = browserFontSize / 16.0;
            final textScaler = scaleFactor != 1.0
                ? TextScaler.linear(scaleFactor)
                : mediaQueryData.textScaler;
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaler: textScaler),
              child: child!,
            );
          },
          home: PopScope(
            canPop: !widget.file_manager.unsaved.value,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (didPop) return;
              bool saved = await widget.file_manager.checkSave(context);
              if (saved && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              appBar: makeAppBar(context),
              drawer: Builder(builder: (BuildContext c) => makeMenuDrawer(c)),
              body: Container(
                child: SafeArea(
                  child: Center(
                    child: Builder(
                      // A builder makes all the children use my theme.
                      builder: (BuildContext c) => _mainBody(c),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    return shortcut_manager.build(context, center);
  }

  AppBar makeAppBar(BuildContext context) {
    // TODO: think about adding this to the menubar.
    return AppBar(
      // XXX leading: _settingsButton(context),
      title: _sceneTitle(context),
      actions: _getButtons(context),
    );
  }

  AppBar makeAppBarXXX(BuildContext context) {
    // TODO: think about adding this to the menubar.
    return AppBar(
      leading: _settingsButton(context),
      title: Row(
        children: [
          makeMenuBar(context),
          _sceneTitle(context),
          if (!_narrow)
            for (var w in _toolButtons(context)) w,
        ],
      ),
      actions: [_helpButton(context)],
    );
  }

  // Make a text widget that might be truncated. If the text is truncated, then
  // we want to switch to the narrow layout.
  Widget _sceneTitle(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        var tp = TextPainter(
          ellipsis: null,
          maxLines: 1,
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: widget.scene_viewer.data.title,
            //Force overflow, so we can see if it exceeds.
            style: TextStyle(overflow: TextOverflow.visible),
          ),
        );
        tp.layout(maxWidth: size.maxWidth);
        var exceeded = tp.didExceedMaxLines;
        if (exceeded) {
          if (!_narrow) {
            // Wait until this build/layout is finished and then try again with
            // a narrow layout.
            SchedulerBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _narrow = true;
                // Log.widget.log("RED: Narrow is now true.");
              });
            });
          }
        }
        tp.dispose();
        return TapToEditText(
          "Title",
          key: const ValueKey('title_text_view'),
          widget.scene_viewer.data.title,
          widget.undo_manager,
          (value) {
            // Log.widget.log("Edited title to $value");
            if (widget.scene_viewer.data.title != value) {
              widget.undo_manager.add(
                Change<String>("Title", widget.scene_viewer.data.title, value, (
                  v,
                ) {
                  // Log.widget.log("Changed the widget.scene_viewer title from "+
                  //   "'${widget.scene_viewer.data.title}' to '$v'");
                  setState(() {
                    widget.scene_viewer.data.title = v;
                    widget.file_manager.current.holder.title = v;
                    widget.file_manager.unsaved.value = true;
                  });
                }),
              );
            }
          },
        );
      },
    );
  }

  Widget _settingsButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Scaffold.of(context).closeDrawer();
        // Log.widget.log("CYAN: Settings button pushed.");
        context.push(SettingsScreen.routeName);
      },
      icon: Icon(Icons.settings),
      tooltip: "Settings",
    );
  }

  Widget _helpButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.help),
      tooltip: "Help Options",
      onSelected: (String route) {
        context.push(route);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: "/about",
          child: Text("About Spacetime v6.0.1+2"),
        ),
        const PopupMenuItem<String>(
          value: "/help?page=overview.html",
          child: Text("Help & User Guides"),
        ),
        if (Settings.kDebugEnabled && Settings.debugEnabled)
          const PopupMenuItem<String>(
            value: "/help?page=dev/README.html",
            child: Text("Developer Docs"),
          ),
      ],
    );
  }

  // Need to close the drawer whenever anything is clicked.
  Drawer makeMenuDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // XXX This makes a very big thingy.
          // DrawerHeader( child:
          Row(
            children: [
              IconButton(
                key: const ValueKey('closeDrawerButton'),
                // icon: const Icon(Icons.menu),
                icon: const Icon(Icons.close),
                onPressed: () {
                  // Log.widget.log("Close the drawer.");
                  Scaffold.of(context).closeDrawer();
                },
              ),
              Expanded(
                child: Text(
                  widget.scene_viewer.data.title,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // ),
          Row(children: [_settingsButton(context), Text("Settings")]),
          widget.file_menu.buildDrawerList(context),
          widget.edit_menu.buildDrawerList(context),
          view_menu.buildDrawerList(context),
        ],
      ),
    );
  }

  Widget makeMenuBar(BuildContext context) {
    return MenuBar(
      children: <Widget>[
        widget.file_menu.build(context),
        widget.edit_menu.build(context),
        view_menu.build(context),
      ],
    );
  }

  // The buttons/tools for editing or adding an object.
  List<Widget> _toolButtons(BuildContext context) {
    // Log.widget.log("tool buttons ${widget.scene_viewer.current_name.value}");
    return [
      // list.add(Text("Lesson"));
      // list.add(_makeButton("Clear Widget.Scene_Viewer.", Icons.restart_alt, widget.scene_viewer.clearScene));
      widget.scene_viewer.current_tool.build(context),
      TapToEditText(
        "Object Name",
        key: const ValueKey('object_name'),
        widget.scene_viewer.current_name.value,
        widget.undo_manager,
        (value) => setState(() {
          // Log.widget.log("Changed name of current object to $value");
          widget.scene_viewer.current_name.value = value;
        }),
      ),
      widget.scene_viewer.current_type.build(context),
      widget.scene_viewer.current_color.build(context),

      // For debugging:
      if (Settings.kDebugEnabled && Settings.debugEnabled)
        _makeButton("DumpDebug", Icons.info, () {
          setState(() {
            Log.widget.log("-dump debug set state-");
          });
          Log.dump.log("-------------- dumpDebugInfo from $this");
          Log.include_verbose = true;
          DebugPrint.print_debug = 1;
          widget.scene_viewer.dumpDebugInfo();
          widget.file_manager.dumpDebugInfo();
          dumpNavigator(context, "DumpDebug");
        }),
      if (Settings.kDebugEnabled && Settings.debugEnabled)
        _makeButton("StopDebug", Icons.exit_to_app, () {
          setState(() {
            Log.dump.log("Turing off debug print.");
            Log.include_verbose = false;
            DebugPrint.print_debug = 0;
          });
        }),
      if (Settings.kDebugEnabled && Settings.debugEnabled)
        _makeButton("check exit", Icons.error, () {
          widget.file_manager.checkSave(context).then((bool result) {
            if (result) {
              Log.widget.log("Check Save returns true.");
            } else {
              Log.widget.log("Check Save returns false.");
            }
          });
        }),
    ];
    // XXX x,t, v.
  }

  // This creates the list of buttons in the app bar.
  // If the layout is narrow, it does not have the toolbar.
  List<Widget> _getButtons(BuildContext context) {
    // Log.widget.log("Get buttons.");
    List<Widget> list = [];
    // XXX list.add(makeMenuBar(context));
    if (!_narrow) list.addAll(_toolButtons(context));
    list.add(_helpButton(context));
    return list;
  }

  Widget _makeButton(String tip, IconData data, VoidCallback callback) {
    return IconButton(
      icon: Icon(data),
      tooltip: tip,
      onPressed: () {
        // setState(() {
        callback();
        // });
      },
    );
  }

  // All the widgets below the app bar.
  Widget _mainBody(BuildContext context) {
    return Column(
      children: [
        if (_narrow) Row(children: _toolButtons(context)),
        Expanded(
          child: SplitterWidget(
            top: (context) => widget.scene_viewer.build(context, this),
            bottom: (context) =>
                widget.scene_viewer.buildSideView(context, this),
            setter: (double x) {
              widget.scene_viewer.data.transform.sideHeight = x;
            },
            initial_size: 80,
            background: widget.settings.background_color,
            outline: widget.settings.theme.scheme.secondary,
          ),
        ),
        MySlider.buildTable(context, [
          widget.scene_viewer.time,
          widget.scene_viewer.velocity,
        ]),
      ],
    );
  }
}

class TapToEditText extends StatefulWidget {
  final String name;
  final String text;
  final Function(String value) callback;
  final MyUndoManager manager;
  const TapToEditText(
    this.name,
    this.text,
    this.manager,
    this.callback, {
    super.key,
  });

  @override
  State<TapToEditText> createState() => TapToEditTextState();
}

class TapToEditTextState extends State<TapToEditText> {
  bool _isActive = false;
  final TextEditingController _controller = TextEditingController();

  TapToEditTextState();

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "TapToEditState-$debug_id-${widget.name}, '${widget.text}' (${_controller.text})";

  @override
  void didUpdateWidget(TapToEditText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    // Log.widget.log("ORANGE: Dispose of $this.");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Log.text_edit.log("Build for $this");
    if (!_isActive) {
      return InkWell(
        child: Text(
          widget.text,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => setState(() {
          Log.text_edit.log("ORANGE: Tapped on field $this.");
          _controller.text = widget.text;
          _isActive = true;
        }),
      );
    }
    return Focus(
      onKeyEvent: _onKeyEvent,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 48),
        child: IntrinsicWidth(
          child: TextField(
            autofocus: true,
            controller: _controller,
            onSubmitted: (value) => setState(() {
              // Log.text_edit.log("GREEN: TextField $this Submitted ${widget.name} w/value = $value.");
              changeValue(value);
              _isActive = false;
            }),
          ),
        ),
      ),
      onFocusChange: (hasFocus) {
        if (!hasFocus && _isActive) {
          setState(() {
            // Log.widget.log("YELLOW: ${widget.name} lost focus. ${widget.text}");
            changeValue(_controller.text);
            _isActive = false;
          });
        } else {
          // Log.widget.log("YELLOW: ${widget.name} has gained focus.");
        }
      },
    );
  }

  void changeValue(String value) {
    // Log.widget.log("value=$value for $this");
    if (widget.text == value) {
      // Log.widget.log("Not adding undo because $this already is $value");
      return;
    }
    // XXX text = value;
    widget.callback(value);
    // widget.manager.add(TextChange(widget.name, widget.text, value, (v) {
    //       widget.text = v;
    //       widget.callback(v);
    // }));
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // XXX add unit test for this.
      // Log.widget.log("Escape was pressed. Returning text for ${widget.name}.");
      setState(() {
        // XXX _controller.text = widget.initial_text;
        // XXX widget.callback(widget.text); // Needed?
        _isActive = false;
      });
      KeyEventResult.handled;
    }
    // Don't pass this key to the shortcut handler, but do let the key
    // be used by the text field. this is used because the shortcut handler
    // accepts some plain keys, like 't' and 'b', and they should not be
    // intercepted.
    return KeyEventResult.skipRemainingHandlers;
  }
}

class JsonSyntaxEditorDialog extends StatefulWidget {
  final FileManager fileManager;
  final String? initialJson;

  const JsonSyntaxEditorDialog({
    required this.fileManager,
    this.initialJson,
    super.key,
  });

  @override
  State<JsonSyntaxEditorDialog> createState() => _JsonSyntaxEditorDialogState();
}

class _JsonSyntaxEditorDialogState extends State<JsonSyntaxEditorDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialJson ?? widget.fileManager.rawBlob,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndLoad() {
    final text = _controller.text;
    try {
      SceneData.fromJsonString(text);
      widget.fileManager.loadFromRawJson(text);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Syntax Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Edit JSON Syntax",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                "Correct syntax or structure errors below and click Validate & Load.",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade400),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter valid JSON drawing syntax...",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    key: const ValueKey("validate_and_load_button"),
                    onPressed: _validateAndLoad,
                    child: const Text("Validate & Load"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
