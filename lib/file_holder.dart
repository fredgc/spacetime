import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'file_manager.dart';
import 'printer.dart';
import 'scene.dart';

class FileHolder {
  String id;
  String title = "Untitled Drawing";
  SceneView? viewer;
  bool changed = false;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;

  FileHolder(this.id);

  String get type => "empty";

  // For debug and testing.
  String tag = "holder-$debug_counter";

  // Return true if save worked. If not, then the file manager will try saveAs.
  Future<bool> saveData(String data, FileManager manager) async => false;
  // Loads the scene, or throws an exception.
  Future<String> loadData(FileManager manager) async => "";
  String get path => "/scene";
  bool get skip_recent =>
      true; // Controls if this type shows up in the "recent tab"

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return id == (other as FileHolder).id;
    // Note: we do not check title because it might have changed.
  }

  // Called to pull extra information from json.
  void extraJson(Map<String, dynamic> json) {}

  Map<String, dynamic> toJson() => <String, dynamic>{
    "type": type,
    "title": title,
    "id": id,
  };

  @override
  String toString() {
    return "Holder $type-$debug_id ($tag): '$title'  (id='$id')";
  }

  String userDescription() {
    return "Empty File";
  }
}

class FileHolderRow extends StatelessWidget {
  final FileHolder holder;
  final VoidCallback? onPressed;
  final Icon? extraIcon;
  final VoidCallback? extraCallback;

  const FileHolderRow(
    this.holder, {
    super.key,
    this.onPressed,
    this.extraIcon,
    this.extraCallback,
  });

  @override
  Widget build(BuildContext context) {
    Log.files.log("BUilding row for ${holder.tag} -> $holder");
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.file_open),
          label: Expanded(
            child: Text(
              holder.userDescription(),
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          key: ValueKey('open-${holder.tag}'),
          onPressed: onPressed,
        ),
        if (extraIcon != null)
          IconButton(
            key: ValueKey('extra-${holder.tag}'),
            icon: extraIcon!,
            onPressed: extraCallback,
          ),
      ],
    );
  }
}

class JsonHolder extends FileHolder {
  String get data => id;
  static int json_count = 0; // Give each json object a unique id.
  final int counter = json_count++;
  JsonHolder(super.id);

  // XXX Is this a good idea?
  @override
  bool get skip_recent => false;

  static final String type_name = "json";
  @override
  String get type => type_name;

  // Saves to clipboard?
  @override
  Future<bool> saveData(String data, FileManager manager) async {
    Log.files.log("Json save $this. fails.");
    return false;
  }

  // Loads from clipboard? Or from text edit?
  @override
  Future<String> loadData(FileManager manager) async {
    Log.files.log("Json load $this");
    return data;
  }

  @override
  String get path {
    var uri = Uri(path: "/scene", queryParameters: {"json": data});
    return uri.toString();
  }

  @override
  String userDescription() {
    return "$title (json)";
  }

  @override
  String toString() {
    return "Holder $type-$debug_id ($tag): '$title' ${trunc(data)}";
  }
}

class ClipboardHolder extends FileHolder {
  bool make_url;
  ClipboardHolder(this.make_url) : super("");

  static final String type_name = "clipboard";
  @override
  String get type => type_name;

  @override
  String userDescription() {
    return "$title (clipboard)";
  }

  @override
  Future<bool> saveData(String data, FileManager manager) async {
    Log.files.log("Save to clipboard.");
    if (make_url) {
      Log.files.log("URI.base = ${Uri.base}");
      var uri = Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.port,
        path: "/scene",
        queryParameters: {"json": data},
      );
      Log.files.log("BLUE: Maybe do this? XXX uri = $uri"); // fix navigation.
      await Clipboard.setData(ClipboardData(text: uri.toString()));
    } else {
      await Clipboard.setData(ClipboardData(text: data));
    }
    return true;
  }

  @override
  Future<String> loadData(FileManager manager) async {
    Log.files.log("Load from clipboard.");
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null) {
      throw FormatException("Empty clipboard");
    }
    String text = data.text!;
    Log.files.log("BLUE: From clipboard $text");
    if (text.startsWith("http")) {
      Uri uri = Uri.dataFromString(text);
      if (uri.queryParameters['json'] == null) {
        Log.files.log("XXX uri in clipboard did not have any json data.");
        return ""; //XXX throw error.
      }
      text = uri.queryParameters['json']!;
      Log.files.log("Using from uri in clipboard: $text");
    }
    return text;
  }
}
