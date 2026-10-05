import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'drive.dart';
import 'file_holder.dart';
import 'local_file.dart';
import 'menus.dart';
import 'printer.dart';
import 'recent_file.dart';
import 'scene.dart';
import 'settings.dart';
import 'upload.dart';
import 'js_stub.dart' if (dart.library.html) 'js_interface.dart';

enum LoadingStatus { NotInitialized, Initialized, Loading, Loaded, Error }

class ContextHolder {
  String source;
  BuildContext? context;
  ContextHolder(this.source, this.context);
}

class FileAndScene {
  FileHolder holder = FileHolder("");
  SceneView? scene;
  @override
  String toString() => "$holder ($scene)";
  void dispose() {
    scene?.dispose();
  }
}

class FileManager {
  final Settings settings;
  ValueNotifier<bool> unsaved = ValueNotifier(false);
  FileAndScene current = FileAndScene();
  FileAndScene previous = FileAndScene();
  Object? exception;
  Object? lastError;
  String rawBlob = "";
  bool isTesting = false;

  // XXX This seems hacky.
  ContextHolder _context = ContextHolder("empty", null);
  void setContext(String source, BuildContext context) {
    // Log.files.log("ORANGE: set context = $source for $this");
    _context = ContextHolder(source, context);
  }

  BuildContext? get context {
    return _context.context;
  }

  LoadingStatus _status = LoadingStatus.NotInitialized;
  final StreamController<LoadingStatus> _statusStream =
      StreamController<LoadingStatus>.broadcast();

  RecentFiles recent = RecentFiles();
  MyDriveAccess drive_access = MyDriveAccess();

  FileManager(this.settings);

  LoadingStatus get status {
    return _status;
  }

  void notify() {
    // Log.files.log("BLUE: file manager notify this=$this.");
    if (_statusStream.hasListener) _statusStream.add(_status);
  }

  set status(LoadingStatus newStatus) {
    _status = newStatus;
    if (_statusStream.hasListener) {
      _statusStream.add(_status);
    } else {
      Log.files.log("RED: No status listeners.");
    }
  }

  // These stream is notified whenever the settings have been initialized or updated.
  Stream<LoadingStatus> statusStream() async* {
    yield _status;
    yield* _statusStream.stream;
  }

  Future<void> initialize() async {
    // Log.files.log("BLUE: Initialize file manager.");
    await dsleep("file_manager", 5);

    await LocalFileHolder.initialize();
    await DownloadManager.initialize();
    await drive_access.initialize();
    await recent.initialize();

    // XXX add this here? Instead of for menus?
    unsaved.addListener(notify);
    recent.addListener(notify);
    initUnsavedCallback(this);

    current.scene = SceneView(this, settings, SceneData());
    previous.scene = SceneView(this, settings, SceneData());

    status = LoadingStatus.Initialized;
    await reload();
    // Log.files.log("Done with reload in initialization.");
  }

  // XXX What about when current has an error. Don't do this.
  void setCurrent(FileHolder holder) {
    // Log.files.log("Push holder (prev): $previous");
    // Log.files.log("            (cur)-> $current");
    // Log.files.log("            (new)-> $holder");
    if (current.scene == null) {
      // Log.files.log("Not moving cur to previous because current.scene == null");
      // Log.files.log("exception = $exception");
    } else {
      previous.dispose();
      previous = current;
    }
    current = FileAndScene();
    current.holder = holder;
    exception = null;
    unsaved.value = false;
  }

  void navigateCurrent() {
    // Log.files.log("CYAN: file navigate to '${trunc(current.holder.path)}'");
    context?.go(current.holder.path);
  }

  // When there was an error, we might want to pop back to the preivous valid scene.
  void popCurrentFile(BuildContext? context) {
    // Log.files.log("RED: maybe therew as an error?");
    // Log.files.log("CYAN: Popping from ${current} to $previous");
    exception = null;
    status = LoadingStatus.Loaded;
    unsaved.value = false; //XXX -- is this true? -- make it current?
    current = previous;
    previous = FileAndScene();
    previous.scene = SceneView(this, settings, SceneData());
    context?.go(current.holder.path);
  }

  // Set the file based on navigation query parameters.
  void checkNavigation(Map<String, String> parameters) {
    FileHolder holder;
    if (parameters['drive'] != null) {
      holder = DriveHolder(parameters['drive']!);
    } else if (parameters['state'] != null) {
      try {
        final stateJson = jsonDecode(parameters['state']!);
        if (stateJson is Map &&
            stateJson['ids'] is List &&
            (stateJson['ids'] as List).isNotEmpty) {
          final fileId = (stateJson['ids'] as List).first.toString();
          holder = DriveHolder(fileId);
        } else {
          holder = FileHolder("");
        }
      } catch (_) {
        holder = FileHolder("");
      }
    } else if (parameters['json'] != null) {
      holder = JsonHolder(parameters['json']!);
    } else if (parameters['local'] != null) {
      holder = LocalFileHolder(parameters['local']!);
    } else {
      holder = FileHolder("");
    }
    if (holder.path == current.holder.path) {
      // Log.files.log("CYAN: checkNavigation already at ${current}, holder=$holder");
      return;
    }
    // Log.files.log("CYAN: checkNavigation moving from ${current} to $holder.");
    loadFile(holder, navigate: false);
  }

  Future<void> loadFile(FileHolder holder, {bool navigate = true}) async {
    // Log.files.log("BLUE: loadFile $holder, status = $status");
    if (status == LoadingStatus.Loaded) {
      bool saved = await checkSave(_context.context);
      if (!saved) return;
    }
    if (navigate && holder is DriveHolder) {
      bool authorized = await drive_access.checkAuthorization();
      if (!authorized) {
        if (_context.context != null && _context.context!.mounted) {
          authorized = await drive_access.getAuthorization(_context.context);
        }
        if (!authorized) {
          Log.files.log("User cancelled drive authorization or is logged out.");
          return;
        }
      }
    }
    setCurrent(holder);
    if (navigate) navigateCurrent();
    // Log.files.log("Waiting on reload ${current}");
    await reload();
    // Log.files.log("Done with reload ${current}");
    // Log.files.log("check holder = $holder");
  }

  Future<void> reload() async {
    bool saved = await checkSave(_context.context);
    if (!saved) return;
    //Cache the holder to prevent a race condition.
    FileHolder holder = current.holder;
    if (status == LoadingStatus.NotInitialized) {
      // This happens if the app is loaded from a deep link and
      // we know what file to load before initialization is complete.
      // After initialization is complete, LoadFile is called again.
      // Log.files.log("CYAN: Not loading ${holder} because manager not initialized.");
      return;
    }
    // Log.files.log("BLUE: Start reload of $holder");
    status = LoadingStatus.Loading;
    String blob = "not loaded";
    try {
      if (holder is DriveHolder) {
        bool authorized = await drive_access.checkAuthorization();
        if (!authorized) {
          if (_context.context != null && _context.context!.mounted) {
            authorized = await drive_access.getAuthorization(_context.context);
          }
          if (!authorized) {
            throw Exception(
              "Not logged in or permissions not granted for Google Drive.",
            );
          }
        }
      }
      // Log.files.log("reload $holder");
      await dsleep("reload-${holder.tag}", 5);
      blob = await holder.loadData(this);
      rawBlob = blob;
      SceneData scene;
      if (blob == "") {
        scene = SceneData();
      } else {
        scene = SceneData.fromJsonString(blob);
        // Log.files.log("scene time is ${zzz(scene.time)}");
      }
      if (!identical(holder, current.holder)) {
        // loadFile must have been called on top of this instance. Give up.
        // Log.files.log("XXX: done loading $holder, but it is not same as ${current}");
        return;
      }
      if (holder is DriveHolder &&
          holder.title.isNotEmpty &&
          holder.title != "-unknown-") {
        scene.title = holder.title;
      } else {
        holder.title = scene.title;
      }
      if (holder is DriveHolder && holder.file?.description != null) {
        String driveDesc = holder.file!.description!.trim();
        if (driveDesc.isNotEmpty &&
            (scene.description.isEmpty ||
                driveDesc !=
                    "A spacetime diagram created with the Spacetime Drawing Tool.\nhttps://spacetime.gchouse.org")) {
          scene.description = driveDesc;
        }
      }
      unsaved.value = false;
      recent.add(holder);
      current.scene = SceneView(this, settings, scene);
      status = LoadingStatus.Loaded;
      Log.files.log("CYAN: Loaded scene for $holder");
      if (scene.isLegacy &&
          _context.context != null &&
          _context.context!.mounted) {
        showDialog<void>(
          context: _context.context!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Legacy File Format"),
              content: const Text(
                "This file was saved by an older version of the "
                "Spacetime Drawing Tool. It has been loaded "
                "successfully.\n\n"
                "If you save the file, it will be converted to "
                "the new file format.",
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    } catch (ex) {
      if (ex is Error) {
        Log.files.log("(file_manager says) Stack Trace: ${ex.stackTrace}");
      }
      // Log.files.log("Reload error $ex");
      // Log.files.log("Data = $blob");
      if (!identical(holder, current.holder)) {
        // loadFile must have been called on top of this instance. Give up.
        // Log.files.log("XXX: exception when loading $holder, but not curent ${current}");
        return;
      }
      exception = ex;
      unsaved.value = false;
      status = LoadingStatus.Error;
    }
  }

  void loadFromRawJson(String rawJson) {
    try {
      rawBlob = rawJson;
      SceneData scene = SceneData.fromJsonString(rawJson);
      unsaved.value = true;
      current.scene = SceneView(this, settings, scene);
      exception = null;
      status = LoadingStatus.Loaded;
    } catch (ex) {
      exception = ex;
      status = LoadingStatus.Error;
    }
  }

  void makeNew() {
    // Log.files.log("XXX makeNew. unsaved=${unsaved.value}");
    loadFile(FileHolder(""));
  }

  void change() {
    unsaved.value = true;
  }

  // Only mark the file as changed if there are objects. This is called when
  // time or velocity change.
  void maybeChange() {
    // Log.files.log("BLUE: maybeChange. unsaved was ${unsaved.value}");
    if (current.scene != null && current.scene!.data.drawables.isNotEmpty) {
      // Log.files.log("RED: now unsaved = true. this=$this, scene=${current.scene}");
      unsaved.value = true;
    }
  }

  void clearUnsaved() {
    current.scene?.undo_manager.markSaved();
    unsaved.value = false;
    // Log.files.log("Cleared unsaved.");
  }

  Future<bool> open() async {
    // Log.files.log("action Open.. unsaved=${unsaved.value}");
    bool saved = await checkSave(_context.context);
    if (!saved) {
      // Log.files.log("Skipping open because checkSave returned false.");
      return false;
    }
    // Log.files.log("Open file for $this, context from ${_context.source}");
    if (_context.context == null) {
      Log.files.log("XXX --- open with null context.");
      return false;
    }
    FileChooser chooser = FileChooser(_context.context!, this, load: true);
    FileHolder? file = await chooser.choose();
    if (file == null) {
      return false;
    }
    // Log.files.log("BLUE: from open, calling loadFile $file");
    await loadFile(file);
    // Log.files.log("BLUE: after open $file");
    // XXX deal with errors.
    return true;
  }

  Future<bool> save() async {
    if (status != LoadingStatus.Loaded) {
      Log.files.log("RED: trying to save while not loaded.");
      return false;
    }
    if (current.scene == null) {
      Log.files.log("RED: trying to save while viewer is null.");
      return false;
    }
    SceneView viewer = current.scene!;
    Log.files.log("action save. current = $current.. unsaved=${unsaved.value}");
    if (viewer.data.title == "Untitled Drawing" &&
        _context.context != null &&
        !isTesting) {
      Log.files.log("untitled, prompting for new title.");
      final titleController = TextEditingController(text: viewer.data.title);
      bool? confirmed = await showDialog<bool>(
        context: _context.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Name Your Drawing"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Give your drawing a title before saving:"),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: "Drawing Title"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    viewer.data.title = titleController.text.trim();
                  }
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (confirmed != true) return false;
    }
    Log.files.log(
      "Trying to save '${viewer.data.title}', type = ${current.holder.type}.",
    );
    current.holder.title = viewer.data.title;
    var encoder = JsonEncoder.withIndent("  ");
    String data = encoder.convert(viewer.data);
    bool saved = false;
    if ("empty" == current.holder.type) {
      return saveAs();
    }
    try {
      saved = await current.holder.saveData(data, this);
    } catch (e) {
      Log.files.log("Save Error: '${e}.");
      lastError = e;
      saved = false;
    }
    await dsleep("save-${current.holder.tag}", 5);
    if (saved) {
      clearUnsaved();
      recent.add(current.holder);
      // Log.files.log("Done with save ${current}.");
      return true;
    }
    if (lastError != null) {
      final errorMsg = lastError?.toString() ?? "Save failed";
      if (_context.context != null && _context.context!.mounted) {
        await showDialog<void>(
          context: _context.context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Save Failed"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('The attempt to save failed.'),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      key: const ValueKey("expand_save_error_details"),
                      title: const Text(
                        "Expand Error Details",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SelectableText(
                            errorMsg,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      return false;
    }
    Log.files.log("Not saved, but no error. Trying to use saveAs.");
    return saveAs(current.holder);
  }

  Future<bool> saveAs([FileHolder? targetHolder]) async {
    Log.files.log("action save As.. unsaved=${unsaved.value}");
    if (_context.context == null) {
      Log.files.log("XXX --- saveAs with null context.");
      return false;
    }
    if (status != LoadingStatus.Loaded) {
      Log.files.log("RED: trying to save while not loaded.");
      return false;
    }
    if (current.scene == null) {
      Log.files.log("RED: trying to save while viewer is null.");
      return false;
    }
    SceneView viewer = current.scene!;
    FileHolder? file = targetHolder;
    if (file == null) {
      FileChooser chooser = FileChooser(_context.context!, this, load: false);
      file = await chooser.choose();
    }
    if (file == null) {
      return false;
    }

    if (!isTesting) {
      final titleController = TextEditingController(
        text: viewer.data.title.isNotEmpty ? viewer.data.title : file.title,
      );
      final descController = TextEditingController(
        text: viewer.data.description,
      );

      bool? confirmed = await showDialog<bool>(
        context: _context.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Properties Before Saving"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  viewer.data.title = titleController.text;
                  file!.title = titleController.text;
                  viewer.data.description = descController.text;
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirmed != true) return false;
    } else {
      file.title = viewer.data.title;
    }

    var encoder = JsonEncoder.withIndent("  ");
    String data = encoder.convert(viewer.data);
    bool saved = false;
    try {
      saved = await file.saveData(data, this);
    } catch (e) {
      lastError = e;
      saved = false;
    }
    await dsleep("saveas-${current.holder.tag}", 5);
    // Log.files.log("Done with saving $file.");
    if (!saved) {
      Log.files.log("XXX figure out why and share error with user?");
      final errorMsg =
          lastError?.toString() ??
          "Save failed for file ${file.userDescription()}";
      if (_context.context != null && _context.context!.mounted) {
        await showDialog<void>(
          context: _context.context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Save Failed"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('The attempt to save failed.'),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      key: const ValueKey("expand_save_error_details"),
                      title: const Text(
                        "Expand Error Details",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SelectableText(
                            errorMsg,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      return false;
    }
    // Don't move current to previous, just change the file holder.
    // Log.files.log("Current changes $current to holder $file");
    current.holder = file;
    // Log.files.log("Doing the navigation:");
    navigateCurrent();
    recent.add(file);
    clearUnsaved();
    // Log.files.log("Done with saveAs ${current}.");
    return true;
  }

  Future<void> editDescription(BuildContext context) async {
    if (status != LoadingStatus.Loaded || current.scene == null) return;
    SceneView viewer = current.scene!;
    FileHolder holder = current.holder;

    final titleController = TextEditingController(
      text: viewer.data.title.isNotEmpty ? viewer.data.title : holder.title,
    );
    final descController = TextEditingController(text: viewer.data.description);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Properties"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                viewer.data.title = titleController.text;
                holder.title = titleController.text;
                viewer.data.description = descController.text;
                unsaved.value = true;
                Navigator.of(context).pop();
                notify();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> share() async {
    Log.files.log("Share.. unsaved=${unsaved.value}");
    return false;
  }

  Future<void> logout() async {
    Log.files.log("Logout.. unsaved=${unsaved.value}");
    await drive_access.logout();
  }

  MyMenu makeMenu() {
    MyMenu menu = MyMenu("File");
    menu.items = [
      for (var r in recent.toList())
        MyMenuItem(
          r.userDescription(),
          callback: () {
            // Log.files.log("CYAN: recent choosen $r");
            loadFile(r);
          },
        ),
      MyMenuItem("New", callback: makeNew, key: LogicalKeyboardKey.keyN),
      MyMenuItem("Open", callback: open, key: LogicalKeyboardKey.keyO),
      MyMenuItem("Reload", callback: reload),
      MyMenuItem(
        "Save",
        callback: save,
        // TODO: add test that save is disabled.
        isEnabledCallback: () => unsaved.value,
        key: LogicalKeyboardKey.keyS,
      ),
      MyMenuItem("Save As", callback: saveAs),
      MyMenuItem(
        "Edit Description",
        callback: () {
          if (_context.context != null) {
            editDescription(_context.context!);
          }
        },
      ),
      if (Settings.kDebugEnabled && Settings.debugEnabled)
        MyMenuItem("Share", callback: share),
      MyMenuItem("Log Out", callback: logout),
    ];
    return menu;
  }

  // Returns true if the user has saved or wants to abandon. Returns false
  // if the user wants to cancel the current action.
  Future<bool> checkSave(BuildContext? parentContext) async {
    // Log.files.log("checkSave. unsaved=${unsaved.value}, context = ${_context.source}");
    if (!unsaved.value) return true;
    // XXX Can this ever be null?
    if (parentContext == null) return false;
    bool? result =
        await showDialog<bool>(
          context: parentContext,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Unsaved Scene'),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('The drawing has been modified.'),
                    Text('Would you like to save it?'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  key: ValueKey('check-discard'),
                  child: const Text('Discard'),
                  onPressed: () {
                    // Log.files.log("CYAN: checksave discard.");
                    Navigator.of(context).pop(true);
                    // Log.files.log("CYAN: After pop - checksave discard.");
                  },
                ),
                TextButton(
                  key: ValueKey('check-save'),
                  child: const Text('Save'),
                  onPressed: () async {
                    bool result = await save();
                    // Log.files.log("CYAN: checksave save $result.");
                    Navigator.of(context).pop(result);
                    // Log.files.log("CYAN: After pop - check save $result.");
                  },
                ),
                TextButton(
                  key: ValueKey('check-saveas'),
                  child: const Text('Save As...'),
                  onPressed: () async {
                    // XXX handle error.
                    bool result = await saveAs();
                    // Log.files.log("CYAN: checksave save as $result.");
                    Navigator.of(context).pop(result);
                    // Log.files.log("CYAN: After pop - checksave saveas $result.");
                  },
                ),
                TextButton(
                  key: ValueKey('check-cancel'),
                  child: const Text('Cancel'),
                  onPressed: () {
                    // Log.files.log("CYAN: checksave cancel.");
                    Navigator.of(context).pop(false);
                    // Log.files.log("CYAN: After pop - checksave cancel.");
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Assume false if null return value.
    if (result) {
      unsaved.value = false;
    }
    return result;
  }

  void dumpDebugInfo() {
    Log.dump.log("Current file holder = $current, viewer=${current.scene}");
    Log.dump.log("Previous file = $previous, viewer=${previous.scene}");
    // List<FileHolder> r = recent.toList();
    // for (int i = 0; i < r.length; i++) {
    //   Log.files.log(" Recent $i: ${r[i]}");
    // }
  }
}

abstract class OneTab extends StatefulWidget {
  final String title;
  final bool load;
  final RecentFiles recent;

  const OneTab(this.title, this.load, this.recent, {super.key});
}

class ClipboardRow extends StatefulWidget {
  final bool load;
  const ClipboardRow(this.load, {super.key});

  @override
  State<ClipboardRow> createState() {
    return ClipboardRowState();
  }
}

class ClipboardRowState extends State<ClipboardRow> {
  bool make_url = false;

  @override
  Widget build(BuildContext context) {
    // XXX Turn into a ListTile.  (how to do checkbox?)
    return Row(
      children: [
        ElevatedButton(
          child: Text(
            widget.load ? "Load from Clipboard" : "Copy to Clipboard",
          ),
          onPressed: () {
            // XXX Does not work on web.
            // Log.files.log("CYAN: clipboard holder pop");
            Navigator.of(context).pop(ClipboardHolder(make_url));
            // Log.files.log("CYAN: After pop - clipboard.");
          },
        ),
        if (!widget.load) Text("Copy as URL"),
        if (!widget.load)
          Checkbox(
            value: make_url,
            onChanged: (bool? value) => setState(() {
              // Log.files.log("Checkbox changed to $value");
              if (value != null) make_url = value;
            }),
          ),
      ],
    );
  }
}

class RecentTab extends OneTab {
  final FileHolder current;
  const RecentTab(bool load, RecentFiles recent, this.current, {super.key})
    : super("Recent", load, recent);
  @override
  State<OneTab> createState() => RecentTabState();
}

class RecentTabState extends State<RecentTab> {
  @override
  void initState() {
    super.initState();
    // Log.files.log("Init State for Recent tabs.");
    // Add listener to rebuild if list changes.
  }

  @override
  Widget build(BuildContext context) {
    // Log.files.log("Building recent tab with ${widget.recent.length} recent files.");
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        UploadRow(widget.load, widget.current),
        ClipboardRow(widget.load),
        for (var (index, r) in widget.recent.toList().indexed)
          ListTile(
            key: ValueKey('open-recent-$index'),
            leading: const Icon(Icons.file_open),
            onTap: () {
              // Log.files.log("BLUE: recent choosen $r");
              Navigator.of(context).pop(r);
              // Log.files.log("BLUE: After pop - recent $r.");
            },
            title: Text(
              r.userDescription(),
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              key: ValueKey('forget-recent-$index'),
              icon: const Icon(Icons.playlist_remove),
              // Other possible icons:
              // Icons.bookmark_remove, highlight_remove, playlist_remove,
              // remove_circle,
              tooltip: "Remove from list of recent files",
              onPressed: () {
                setState(() {
                  // Log.files.log("BLUE: button remove recent $r");
                  widget.recent.remove(r);
                });
              },
            ),
          ),
      ],
    );
  }
}

class FileChooser {
  BuildContext context;
  FileManager file_manager;
  bool load;

  FileChooser(this.context, this.file_manager, {required this.load});

  Future<FileHolder?> choose() {
    final tabs = <OneTab>[
      RecentTab(load, file_manager.recent, file_manager.current.holder),
      LocalFileTab(load, file_manager.recent), // Combine with recent?
      DriveTab(load, file_manager, file_manager.recent),
    ];

    return showDialog<FileHolder?>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: DefaultTabController(
          initialIndex: 0,
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text("Choose a File"),
              actions: <Widget>[
                ElevatedButton(
                  child: const Icon(Icons.close),
                  onPressed: () {
                    // Log.files.log("BLUE: Choose a file. Cancel.");
                    Navigator.of(context).pop(null);
                    // Log.files.log("BLUE: After pop - cancel / close tab.");
                  },
                ),
              ],
              bottom: TabBar(
                tabs: tabs.map((t) => Tab(text: t.title)).toList(),
              ),
            ),
            body: TabBarView(children: tabs),
          ),
        ),
      ),
    );
  }
}
