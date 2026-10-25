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
  static final String recentListLabel = "recent_files";
  static final int maxRecentCount = 5;

  // Can call     notifyListeners();

  Future<void> initialize() async {
    recent = await fetchRecent();
  }

  Future<void> save(List<FileHolder> files) async {
    var encoder = const JsonEncoder.withIndent("  "); // indent for debugging.
    List<String> json = files.map((r) => encoder.convert(r)).toList();
    final prefs = SharedPreferencesAsync();
    await prefs.setStringList(recentListLabel, json);
  }

  // Or maybe load?
  Future<List<FileHolder>> fetchRecent() async {
    final prefs = SharedPreferencesAsync();
    List<String>? json = await prefs.getStringList(recentListLabel);
    if (json == null) {
      // Log.files.log("No recent files in preferences.");
      return [];
    }
    return json
        .map((text) => extractRecent(text))
        .where((x) => !x.skipRecent)
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
      if (type == ClipboardHolder.typeName) {
        file = ClipboardHolder(true);
      } else if (type == JsonHolder.typeName) {
        file = JsonHolder(id);
      } else if (type == DriveHolder.typeName) {
        file = DriveHolder(id);
      } else if (type == UploadHolder.typeName) {
        file = UploadHolder(id);
      } else if (type == LocalFileHolder.typeName) {
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
    if (holder.skipRecent) return;
    // If holder was already in the list, remove it from that position so we can
    // add it toe front.
    recent.remove(holder);
    recent.insert(0, holder);
    recent.length = math.min(recent.length, maxRecentCount);
    await save(recent);
    // Log.files.log("Recent added $holder");
    notifyListeners();
  }

  Future<void> remove(FileHolder holder) async {
    recent.remove(holder);
    recent.length = math.min(recent.length, maxRecentCount);
    await save(recent);
    // Log.files.log("Recent removed $holder");
    notifyListeners();
  }

  List<FileHolder> toList() => recent;
}
