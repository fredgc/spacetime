import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'file_holder.dart';
import 'file_manager.dart';
import "printer.dart";
import 'recent_file.dart';

class LocalFileHolder extends FileHolder {
  LocalFileHolder(super.id) {
    tag = "local-$id";
  }

  static final String type_name = "local";
  @override
  String get type => type_name;
  @override
  bool get skip_recent => false;
  @override
  String get path => "/scene?local=$id";

  static final String local_file_label = "local_file";
  static final String id_label = "local_file_id";
  static Map<String, String> titles = {};
  static List<String> ids = [];

  static Future<void> initialize() async {
    final prefs = SharedPreferencesAsync();
    List<String>? savedTitles = await prefs.getStringList(local_file_label);
    if (savedTitles == null) {
      titles = {};
      ids = [];
      // Log.local.log("BLUE: There were no local files.");
      return;
    }
    // Log.local.log("BLUE: saved titles = $saved_titles.");
    List<String>? savedIds = await prefs.getStringList(id_label);
    savedIds ??= List<String>.generate(savedTitles.length, (i) => "${i + 1}");
    ids = savedIds;
    titles = Map.fromIterables(savedIds, savedTitles);
    // Log.local.log("BLUE: There are ${titles.length} local files.  $titles");
    // Log.local.log("BLUE: ids = $ids");
  }

  @override
  String userDescription() {
    return "$title (local ${id})";
  }

  static LocalFileHolder makeNew() {
    // Pick a new id that is both unique, and also easy to predict in unit
    // tests.
    int index = ids.length;
    String id;
    do {
      index++;
      id = index.toRadixString(36);
    } while (titles.keys.contains(id));
    ids.add(id);
    titles[id] = "new local file";
    return LocalFileHolder(id);
  }

  Future<void> setTitle(String title) async {
    // Log.local.log("YELLOW: Setting title for $id from ${this.title} to $title");
    titles[id] = title;
    await saveTitles();
  }

  static Future<void> deleteFile(String id) async {
    // Log.local.log("XXX -- delete local file.");
    ids.remove(id);
    titles.remove(id);
    await saveTitles();
    final prefs = SharedPreferencesAsync();
    await prefs.remove("$local_file_label-$id");
    // XXX also remove from recent list.
  }

  static Future<void> reorder(int oldIndex, int newIndex) {
    // Log.local.log("Reorder $oldIndex -> $newIndex");
    if (oldIndex >= ids.length) {
      return Future.value(null); // Only use valid index.
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    String id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);
    return saveTitles();
  }

  static Future<void> saveTitles() async {
    // TODO: technically, there is a possible race condition here. But it's not
    // very likely.
    List<String> values = ids
        .map((id) => titles[id] ?? "Local file $id")
        .toList();
    if (values.length != ids.length || values.length != titles.length) {
      Log.local.log("XXX warning. Lengths do not match.");
      Log.local.log("Saving map: $titles");
      Log.local.log("Saving ids: $ids");
      Log.local.log("Saving titles: $values");
    }
    final prefs = SharedPreferencesAsync();
    await prefs.setStringList(id_label, ids);
    await prefs.setStringList(local_file_label, values);

    Log.local.log("Saving map: $titles");
    Log.local.log("Saving ids: $ids");
    Log.local.log("Saving titles: $values");
  }

  @override
  Future<bool> saveData(String data, FileManager manager) async {
    // Log.local.log("save local file $id, title='$title'.");
    await setTitle(title);
    final prefs = SharedPreferencesAsync();
    await prefs.setString("$local_file_label-$id", data);
    return true;
  }

  @override
  Future<String> loadData(FileManager manager) async {
    // Log.local.log("load local file: id=$id, title='$title'.");
    // XXX await setTitle(title);      //XXX --- nope. wrong.
    final prefs = SharedPreferencesAsync();
    // XXX if null ,then throw exception. Write test for that, too.
    String data =
        await prefs.getString("$local_file_label-$id") ??
        "local-data-not-found";
    return data;
  }
}

class LocalFileTab extends OneTab {
  const LocalFileTab(bool load, RecentFiles recent, {super.key})
    : super("Local Data", load, recent);
  @override
  State<OneTab> createState() => LocalFileTabState();
}

class LocalFileTabState extends State<LocalFileTab> {
  @override
  void initState() {
    super.initState();
    // Log.local.log("Init State for local file tabs..");
  }

  @override
  Widget build(BuildContext context) {
    // Log.local.log("Building local tab with ${LocalFileHolder.titles.indexed} files.");
    final Map<String, String> titles = LocalFileHolder.titles;
    Widget? footer = widget.load
        ? null
        : ListTile(
            key: ValueKey('new-local'),
            title: Text("New Local File"),
            leading: const Icon(
              Icons.file_open,
            ), // XXX is there a "new file" icon?
            onTap: () {
              Navigator.of(context).pop(LocalFileHolder.makeNew());
            },
          );
    return ReorderableListView(
      footer: footer,
      primary: true, // This is primary scroll view for this dialog.
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          // Log.local.log("Reorder $oldIndex to $newIndex");
          LocalFileHolder.reorder(oldIndex, newIndex);
        });
      },
      children: [
        for (final id in LocalFileHolder.ids)
          ListTile(
            key: ValueKey('open-local-$id'),
            title: Text(
              "${id}) ${titles[id]}",
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(Icons.file_open),
            onTap: () {
              // Log.local.log("Tapped $id - ${titles[id]}");
              Navigator.of(context).pop(LocalFileHolder(id));
            },
            trailing: IconButton(
              key: ValueKey('delete-local-$id'),
              icon: const Icon(Icons.delete),
              tooltip: "Delete local file",
              onPressed: () {
                setState(() {
                  LocalFileHolder.deleteFile(id);
                  widget.recent.remove(LocalFileHolder(id));
                });
              },
            ),
          ),
      ],
    );
  }
}
