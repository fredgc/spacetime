import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drive.dart';
import 'local_file.dart';
import 'file_holder.dart';
import "printer.dart";
import 'upload.dart';

class RecentFiles with ChangeNotifier {
  List<FileHolder> recent = [];
  static final String recent_list_label = "recent_files";
  static final int max_recent_count = 5;

  // Can call     notifyListeners();

  Future<void> initialize() async {
    recent = await fetchRecent();
    for (var r in recent) {
      //BLUE: debug only.
      // XXX Log.files.log("  Recent $r");
    }
  }

  Future<void> save(List<FileHolder> files) async {
    var encoder = JsonEncoder.withIndent("  "); // indent for debugging.
    List<String> json = files.map((r) => encoder.convert(r)).toList();
    final prefs = SharedPreferencesAsync();
    await prefs.setStringList(recent_list_label, json);
  }

  // Or maybe load?
  Future<List<FileHolder>> fetchRecent() async {
    final prefs = SharedPreferencesAsync();
    List<String>? json = await prefs.getStringList(recent_list_label);
    if (json == null) {
      // Log.files.log("No recent files in preferences.");
      return [];
    }
    for (var r in json) {
      // XXX Log.files.log("BLUE: Recent json = $r");
    }
    return json
        .map((text) => extractRecent(text))
        .where((x) => !x.skip_recent)
        .toList();
  }

  FileHolder extractRecent(String text) {
    try {
      var json = jsonDecode(text);
      String type = json['type'].toLowerCase();
      String id = json['id'];
      String title = json['title'];
      FileHolder file;
      // XXX skip some of these. They cannot be saved as recent.
      if (type == ClipboardHolder.type_name) {
        file = ClipboardHolder(true);
      } else if (type == JsonHolder.type_name) {
        file = JsonHolder(id);
      } else if (type == DriveHolder.type_name) {
        file = DriveHolder(id);
      } else if (type == UploadHolder.type_name) {
        file = UploadHolder(id);
      } else if (type == LocalFileHolder.type_name) {
        file = LocalFileHolder(id);
      } else {
        file = FileHolder(id);
      }
      file.title = title;
      file.extraJson(json);
      return file;
    } catch (ex) {
      Log.files.log("bad file '$text': $ex");
      return FileHolder("");
    }
  }

  Future<void> add(FileHolder holder) async {
    // Log.files.log("Add recent: $holder");
    if (holder.skip_recent) return;
    // If holder was already in the list, remove it from that position so we can
    // add it toe front.
    recent.remove(holder);
    recent.insert(0, holder);
    recent.length = math.min(recent.length, max_recent_count);
    await save(recent);
    // Log.files.log("Recent added $holder");
    notifyListeners();
    //for (int i = 0; i < recent.length; i++) {
    //  FileHolder r = recent[i];
    //  String text = json[i];
    //  Log.files.log("Recent $i $r");
    //}
  }

  Future<void> remove(FileHolder holder) async {
    recent.remove(holder);
    recent.length = math.min(recent.length, max_recent_count);
    await save(recent);
    // Log.files.log("Recent removed $holder");
    notifyListeners();
  }

  List<FileHolder> toList() => recent;
}
