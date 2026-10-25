// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx
// XXX Use this if android and web are different.
// export 'upload_stub.dart'
//     if (dart.library.js_util) 'upload_web.dart'
//     if (dart.library.io) 'upload_android.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import 'file_holder.dart';
import 'file_manager.dart';
import 'name.dart';
import "printer.dart";
import 'recent_file.dart';

/*
This is very different on web and android.
Split this into two files. Copy stub idea from sign_in_button.
On Android, maybe we can look at the downloads directory and write files to it.

probably web choices works too.

Future<void> uploadInitialize() async {
  return DownloadManager.initialize();
}



On Web:
Load:
Can pick a file to upload. We get the filename and the data. FilePicker.
Save As:
Can create a new file in the downloads directory. uses FileSaver.
Have user enter the filename with a default of spacetime_drawing.st.json
Save:
just use the same filename that was loaded from the load.

*/

// Make a mockable wrapper for the FileSaver and FilePicker instance. Just for
// testing.
class DownloadManager {
  static Future<void> initialize() async {
    // Log.local.log("XXX ==============================================================");
    // Log.local.log("XXX ==============================================================");
    // Log.local.log("XXX --- UploadHolder initialize.");
    // Log.local.log("XXX ==============================================================");
    // Log.local.log("XXX ==============================================================");
  }

  Future<String> saveFile({
    required String name,
    required String data,
    File? file,
    String? filePath,
  }) async {
    return await FileSaver.instance.saveFile(
      name: name,
      bytes: utf8.encoder.convert(data),
      file: file,
      filePath: filePath,
      mimeType: MimeType.other,
    );
  }

  // Returns filename, data.
  Future<(String, String)> loadFile() async {
    PlatformFile? file = await FilePicker.pickFile(
      dialogTitle: 'Load a file from desired location',
      type: FileType.any,
    );
    if (file == null) {
      Log.local.log("RED: no file result.");
      return ("", "");
    }

    Log.local.log("File name = ${file.name}");
    Log.local.log("CYAN: download path = ${file.path}");
    var bytes = await file.readAsBytes();
    String data = utf8.decode(bytes, allowMalformed: true);
    return (file.name, data);
  }
}

class UploadHolder extends FileHolder {
  UploadHolder(super.id) : filename = id;

  static final String typeName = "download";
  @override
  String get type => typeName;
  @override
  bool get skipRecent => false;
  String filename;
  String data = "";

  // XXX make instance varaible in DownloadManager class.
  static DownloadManager downloadManager = DownloadManager();

  @override
  void extraJson(Map<String, dynamic> json) {}

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    return json;
  }

  @override
  String userDescription() {
    return "$title ($filename)";
  }

  // Called from save() and saveAs.
  @override
  Future<bool> saveData(String data, FileManager manager) async {
    // Log.local.log("Download file to $filename.");
    // Log.local.log("data = $data");
    try {
      await downloadManager.saveFile(name: filename, data: data);
      return true;
    } catch (e) {
      Log.local.log("Download file error: $e");
      return false;
    }
  }

  // Called from load, reload, and open.
  @override
  Future<String> loadData(FileManager manager) async {
    // Log.local.log("Upload file: filename=$filename.");
    String result;
    if (data.isEmpty) {
      // This happens on a reload. Try to load a new file.
      var (name, contents) = await downloadManager.loadFile();
      filename = name;
      result = contents;
    } else {
      result = data;
      // XXX This is hacky.
      data = ""; // Only use data once.
    }
    return result;
  }
}

class UploadRow extends StatefulWidget {
  final bool load;
  final FileHolder current;
  final RecentFiles? recent;
  const UploadRow(this.load, this.current, {this.recent, super.key});

  @override
  State<UploadRow> createState() => UploadRowState();
}

class UploadRowState extends State<UploadRow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    String filename = "spacetime_drawing.st.json";
    if (widget.current is UploadHolder) {
      filename = (widget.current as UploadHolder).filename;
    }
    if (!widget.load) {
      final existingFilenames = <String>{
        if (widget.current is UploadHolder)
          (widget.current as UploadHolder).filename,
        if (widget.recent != null)
          for (final r in widget.recent!.toList())
            if (r is UploadHolder) r.filename,
      };
      filename = NameGuess.nextAvailableFilename(filename, existingFilenames);
    }
    _controller.text = filename;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.load) {
      return Row(
        children: [
          ElevatedButton(
            key: const ValueKey('upload-button'),
            child: const Text("Upload from file"),
            onPressed: () async {
              var (name, data) = await UploadHolder.downloadManager.loadFile();
              if (name.isEmpty) {
                // Log.local.log("CYAN: download holder pop empty");
                Navigator.of(context).pop(null);
              } else {
                // Log.local.log("CYAN: download holder pop empty");
                Navigator.of(context).pop(UploadHolder(name)..data = data);
              }
              // XXX Read the file now.
              // XXX -- change this.

              // Log.local.log("CYAN: After pop - download.");
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              key: const ValueKey('download-filename'),
            ),
          ),
          ElevatedButton(
            key: const ValueKey('download-button'),
            child: const Text("Download to file"),
            onPressed: () async {
              // Log.local.log("CYAN: upload holder pop");
              Navigator.of(context).pop(UploadHolder(_controller.text));
              // Log.local.log("CYAN: After pop - download.");
            },
          ),
        ],
      );
    }
  }
}
