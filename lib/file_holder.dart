import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'file_manager.dart';
import 'printer.dart';
import 'scene.dart';

enum FileKind { scene, tutorial }

class FileHolder {
  String id;
  String title = "Untitled Drawing";
  SceneView? viewer;
  bool changed = false;
  FileKind kind;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;

  FileHolder(this.id, {this.kind = FileKind.scene});

  String get type => "empty";

  // For debug and testing.
  String tag = "holder-$_debugCounter";

  // Return true if save worked. If not, then the file manager will try saveAs.
  Future<bool> saveData(String data, FileManager manager) async => false;
  // Loads the scene, or throws an exception.
  Future<String> loadData(FileManager manager) async => "";
  String get path => "/scene";
  bool get skipRecent =>
      true; // Controls if this type shows up in the "recent tab"

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return id == (other as FileHolder).id;
    // Note: we do not check title because it might have changed.
  }

  @override
  int get hashCode => id.hashCode;

  // Called to pull extra information from json.
  void extraJson(Map<String, dynamic> json) {}

  Map<String, dynamic> toJson() => <String, dynamic>{
    "type": type,
    "title": title,
    "id": id,
  };

  @override
  String toString() {
    return "Holder $type-$_debugId ($tag): '$title'  (id='$id')";
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
  static int _jsonCount = 0; // Give each json object a unique id.
  final int counter = _jsonCount++;
  JsonHolder(super.id);

  // XXX Is this a good idea?
  @override
  bool get skipRecent => false;

  static final String typeName = "json";
  @override
  String get type => typeName;

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
    return "Holder $type-$_debugId ($tag): '$title' ${trunc(data)}";
  }
}

class ClipboardHolder extends FileHolder {
  bool makeUrl;
  ClipboardHolder(this.makeUrl) : super("");

  static final String typeName = "clipboard";
  @override
  String get type => typeName;

  @override
  String userDescription() {
    return "$title (clipboard)";
  }

  @override
  Future<bool> saveData(String data, FileManager manager) async {
    Log.files.log("Save to clipboard.");
    if (makeUrl) {
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
      throw const FormatException("Empty clipboard");
    }
    String text = data.text!.trim();
    Log.files.log("BLUE: From clipboard $text");
    if (text.startsWith("http://") ||
        text.startsWith("https://") ||
        text.startsWith("/scene?")) {
      Uri uri = Uri.parse(text);
      String? jsonParam = uri.queryParameters['json'];
      if (jsonParam == null && uri.fragment.isNotEmpty) {
        final fragUri = Uri.parse(
          uri.fragment.startsWith('/') ? uri.fragment : '/${uri.fragment}',
        );
        jsonParam = fragUri.queryParameters['json'];
      }
      if (jsonParam == null) {
        Log.files.log("XXX uri in clipboard did not have any json data.");
        throw const FormatException(
          "URL in clipboard does not contain JSON data",
        );
      }
      text = jsonParam;
      Log.files.log("Using from uri in clipboard: $text");
    }
    return text;
  }
}

class AssetHolder extends FileHolder {
  final String assetPath;

  AssetHolder(this.assetPath, {String? title, super.kind = FileKind.tutorial})
    : super(assetPath) {
    this.title = title ?? assetPath.split('/').last.replaceAll('.md', '');
    tag = "asset-${assetPath.split('/').last}";
  }

  static const String typeName = "asset";
  @override
  String get type => typeName;

  @override
  bool get skipRecent => true;

  @override
  Future<String> loadData(FileManager manager) async {
    Log.files.log("Loading asset: $assetPath");
    return await rootBundle.loadString(assetPath);
  }

  @override
  Future<bool> saveData(String data, FileManager manager) async {
    return false;
  }

  @override
  String userDescription() {
    return "$title (tutorial)";
  }
}
