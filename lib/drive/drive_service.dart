import 'dart:convert';

import 'package:googleapis/drive/v3.dart';

import '../file_holder.dart';
import '../file_manager.dart';
import '../printer.dart';
import 'drive_auth.dart';

/// Builds a Google Drive file search query from user-entered search terms.
String buildDriveQuery(String rawQuery) {
  String query = rawQuery.trim();
  if (query.isEmpty) return '';

  List<String> clauses = [];
  final ownerRegex = RegExp(r'\bowner:(\S+)\b', caseSensitive: false);
  final matches = ownerRegex.allMatches(query);

  for (final match in matches) {
    final target = match.group(1)!;
    if (target.toLowerCase() == 'me') {
      clauses.add("'me' in owners");
    } else {
      final escapedTarget = target.replaceAll("'", "\\'");
      clauses.add("'$escapedTarget' in owners");
    }
  }

  String nonOwner = query.replaceAll(ownerRegex, '').trim();
  if (nonOwner.isNotEmpty) {
    final hasOperator = RegExp(
      r'\b(contains|in|=|!=|>|<|has)\b',
      caseSensitive: false,
    ).hasMatch(nonOwner);
    if (hasOperator) {
      clauses.add(nonOwner);
    } else {
      final escaped = nonOwner.replaceAll("'", "\\'");
      clauses.add("name contains '$escaped'");
    }
  }

  return clauses.join(' and ');
}

String formatFileModifiedTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

class DriveHolder extends FileHolder {
  DriveHolder(super.id);

  static final String typeName = 'drive';
  @override
  String get type => typeName;
  @override
  String get path => '/scene?drive=$id';
  @override
  bool get skipRecent => false;
  static final String createString = '_new_';

  File? file;

  factory DriveHolder.create() {
    return DriveHolder(createString);
  }

  @override
  String userDescription() {
    return '$title (drive)';
  }

  @override
  Future<bool> saveData(String data, FileManager manager) async {
    Log.drive.log('PURPLE: Drive save $id');
    if (file == null && id != createString) {
      Log.drive.log('saveData: getting file by id.');
      file = await manager.driveAccess.getFileById(manager.context, id);
      if (file == null) return false;
    }
    String desc = '';
    try {
      Map<String, dynamic> json = jsonDecode(data);
      if (json.containsKey('description') && json['description'] is String) {
        desc = (json['description'] as String).trim();
      }
      if (json.containsKey('title') && json['title'] is String) {
        String jsonTitle = (json['title'] as String).trim();
        if (jsonTitle.isNotEmpty) {
          title = jsonTitle;
        }
      }
    } catch (_) {}

    String fullDesc = desc.isNotEmpty
        ? desc
        : 'A spacetime diagram created with the Spacetime Drawing Tool.\nhttps://spacetime.gchouse.org';

    List<int> bytes = utf8.encode(data);
    Stream<List<int>> stream = Stream.value(bytes);
    Media media = Media(
      stream,
      data.length,
      contentType: MyDriveAccess.mimeType,
    );
    if (id == createString) {
      file = await manager.driveAccess.newFile(
        manager.context,
        title,
        fullDesc,
        media,
      );
      if (file != null && file!.id != null) {
        id = file!.id!;
      }
    } else {
      file = await manager.driveAccess.saveData(
        manager.context,
        file!,
        title,
        fullDesc,
        media,
      );
    }
    if (file != null && file!.name != null) {
      title = file!.name!;
    }
    manager.driveAccess.logFile('After saving', file);
    return (file != null);
  }

  @override
  Future<String> loadData(FileManager manager) async {
    Log.drive.log('PURPLE: Drive load $id');
    if (file == null) {
      file = await manager.driveAccess.getFileById(manager.context, id);
      manager.driveAccess.logFile('After get file by id', file);
      if (file == null) {
        if (manager.driveAccess.status != DriveAccessStatus.authorized) {
          throw Exception(
            'Not logged in or permissions not granted for Google Drive.',
          );
        }
        throw Exception('Could not find file with id $id');
      }
    }
    title = file!.name ?? '-unknown-';
    Media? media = await manager.driveAccess.loadData(manager.context, file!);
    if (media == null) {
      Log.drive.log('PURPLE: null media.');
      if (manager.driveAccess.status != DriveAccessStatus.authorized) {
        throw Exception(
          'Not logged in or permissions not granted for Google Drive.',
        );
      }
      throw Exception('Could not load media from file with id $id');
    }
    List<List<int>> lists = await media.stream.toList();
    List<int> list = lists.expand((l) => l).toList();
    return utf8.decode(list);
  }
}
