import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'menus.dart';
import 'printer.dart';
import 'scene.dart';

/// Menu for edit actions (Undo, Redo, Cut, Copy, Paste, Delete).
class EditMenu extends MyMenu {
  MyUndoManager manager;
  SceneView sceneViewer;

  EditMenu(this.sceneViewer, this.manager) : super("Edit") {
    // Log.menus.log("ORANGE: Creating new edit menu object.");
    manager.addListener(rebuild);
    items = [
      MyMenuItem(
        "Undo",
        callback: manager.undo,
        key: LogicalKeyboardKey.keyZ,
        isEnabledCallback: () => manager.undoList.isNotEmpty,
      ),
      MyMenuItem(
        "Redo",
        callback: manager.redo,
        key: LogicalKeyboardKey.keyY,
        isEnabledCallback: () => manager.redoList.isNotEmpty,
      ),
      MyMenuSpacer(),
      MyMenuItem(
        "Cut",
        callback: sceneViewer.cut,
        key: LogicalKeyboardKey.keyX,
        isEnabledCallback: () => sceneViewer.selected != null,
      ),
      MyMenuItem(
        "Copy",
        callback: sceneViewer.copy,
        key: LogicalKeyboardKey.keyC,
        isEnabledCallback: () => sceneViewer.selected != null,
      ),
      MyMenuItem(
        "Paste",
        callback: sceneViewer.paste,
        key: LogicalKeyboardKey.keyV,
        isEnabledCallback: () => false,
      ),
      MyMenuItem.logical(
        "Delete",
        callback: sceneViewer.delete,
        shortcut: SingleActivator(LogicalKeyboardKey.delete, control: false),
        isEnabledCallback: () => sceneViewer.selected != null,
      ),
    ];
  }
}

/// Abstract contract for actions that can be undone and redone.
abstract class Redoable {
  void redo();
  void undo();
}

/// A redoable action defined by generic undo/redo callbacks.
class UndoCallback implements Redoable {
  final String name;
  final VoidCallback undoCallback;
  final VoidCallback redoCallback;
  UndoCallback(
    this.name, {
    required this.undoCallback,
    required this.redoCallback,
  });
  @override
  void redo() => redoCallback();
  @override
  void undo() => undoCallback();
  @override
  String toString() => name;
}

/// Represents a state modification of type [T] with old and new values.
class Change<T> implements Redoable {
  final String name;
  final T oldValue;
  final T value;
  Function(T value) callback;

  Change(this.name, this.oldValue, this.value, this.callback);

  @override
  void undo() {
    Log.undo.log("undo to $oldValue");
    callback(oldValue);
  }

  @override
  void redo() {
    Log.undo.log("redo to $value");
    callback(value);
  }

  @override
  String toString() => "change $name from $oldValue to $value";
}

/// Manages undo and redo stacks and tracks unsaved document state.
class MyUndoManager with ChangeNotifier {
  final List<Redoable> undoList = [];
  final List<Redoable> redoList = [];
  int _savedIndex = 0;

  bool get isUnsaved {
    if (_savedIndex < 0) return true;
    return undoList.length != _savedIndex;
  }

  void markSaved() {
    _savedIndex = undoList.length;
  }

  /// Rebuilds menu when selection or state changes.
  void rebuildMenu() {
    notifyListeners();
  }

  void undo() {
    if (undoList.isEmpty) {
      Log.undo.log("Cannot undo because list is empty.");
      return;
    }
    Redoable action = undoList.removeLast();
    redoList.add(action);
    Log.undo.log("Undo $action.");
    action.undo();
    notifyListeners();
  }

  void redo() {
    if (redoList.isEmpty) {
      Log.undo.log("Cannot redo because list is empty.");
      return;
    }
    Redoable action = redoList.removeLast();
    undoList.add(action);
    Log.undo.log("Redo $action.");
    action.redo();
    notifyListeners();
  }

  void add(Redoable action) {
    Log.undo.log("Add redoable $action");
    action.redo();
    undoList.add(action);
    if (_savedIndex > undoList.length) {
      _savedIndex = -1;
    }
    redoList.clear();
    notifyListeners();
  }

  void clear() {
    undoList.clear();
    redoList.clear();
    _savedIndex = 0;
    notifyListeners();
  }

  void dumpList() {
    Log.dump.log("ORANGE: Undo (${undoList.length})");
    for (var u in undoList) {
      Log.dump.log("   $u");
    }
    Log.dump.log("ORANGE: Redo (${redoList.length})");
    for (var u in redoList) {
      Log.dump.log("   $u");
    }
  }
}
