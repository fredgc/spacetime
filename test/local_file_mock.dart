import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spacetime/local_file.dart';

import 'test_data.dart';

class HolderMock {
  String title;
  String id;
  String data;
  HolderMock(this.data, this.id, this.title);
}

class LocalFileMock {
  Future<void> initialize() async {
    final files = [
      // The title used here will show up until the file is saved again.
      HolderMock(TestData.error.json, "1", "Error Unsaved Title"),
      HolderMock(TestData.person.json, "2", "Person Unsaved Title"),
      HolderMock(TestData.train.json, "3", "Train Unsaved Title"),
      HolderMock(TestData.clock.json, "4", "Clock Unsaved Title"),
      HolderMock(TestData.sample.json, "5", "Sample Unsaved Title"),
    ];
    List<String> titles = files.map((file) => file.title).toList();
    String prefix = LocalFileHolder.local_file_label;
    final prefs = SharedPreferencesAsync();
    await prefs.setStringList(prefix, titles);
    for (var file in files) {
      await prefs.setString("$prefix-${file.id}", file.data);
    }
  }

  // Check that the saved local is as expected.
  Future<void> expectLocal(List<HolderMock> expectedLocal) async {
    List<String> expectedIds = expectedLocal
        .map((holder) => holder.id)
        .toList();
    List<String> expectedTitles = expectedLocal
        .map((holder) => holder.title)
        .toList();
    String prefix = LocalFileHolder.local_file_label;
    String idLabel = LocalFileHolder.id_label;
    final prefs = SharedPreferencesAsync();
    List<String>? savedIds = await prefs.getStringList(idLabel);
    List<String>? savedTitles = await prefs.getStringList(prefix);
    expect(savedTitles, expectedTitles);
    expect(savedIds, expectedIds);
    for (var holder in expectedLocal) {
      String? data = await prefs.getString("$prefix-${holder.id}");
      expect(data, isNotNull);
      // XXX this doesn't work if we have edited the file.
      // expect(data, holder.data);
    }
  }
}
