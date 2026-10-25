import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/file_holder.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/local_file.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/settings.dart';

import 'app_tester.dart';
import 'test_data.dart';

void main() {
  testWidgets('SaveAs download', (tester) async {
    final app = AppTester(tester);
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());
    await app.openLocal("3", TestData.train.data);
    const String editedTitle = "Train Test Data Title";
    await app.scene.editTitle(editedTitle);
    await app.saveAsDownload(
      'test-filename.txt',
      TestData.train.data..title = editedTitle,
    );
    await app.findScene(TestData.train.data..title = editedTitle);
    await app.teardown();
  });

  testWidgets('open, edit, save', (tester) async {
    final app = AppTester(tester);
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());
    String filename = "my-filename.txt";
    const String editedTitle = "Editted Title";
    await app.openUpload(filename, TestData.train.data);
    await app.scene.editTitle(editedTitle);
    await app.saveDownload(filename, TestData.train.data..title = editedTitle);
    await app.findScene(TestData.train.data..title = editedTitle);
    app.tagCurrentFile("second-save"); // Give the sleeps a new tag.
    const String title2 = "Title Number Two";
    await app.scene.editTitle(title2);
    await app.saveDownload(filename, TestData.train.data..title = title2);
    await app.findScene(TestData.train.data..title = title2);
    await app.teardown();
  });

  group('open errors.', () {
    testWidgets('canceled', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      // Open one file.
      await app.openUpload("filename.txt", TestData.train.data);
      await app.findScene(TestData.train.data);
      await app.uploadSkipped();
      await app.findScene(TestData.train.data);
      await app.teardown();
    });

    testWidgets('go back', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      // Open one file.
      await app.openUpload("filename.txt", TestData.train.data);
      await app.findScene(TestData.train.data);
      await app.uploadError();
      await tester.tap(find.textContaining("Go back"));
      await tester.pumpAndSettle();
      // app.listSleeps();
      await app.findScene(TestData.train.data);
      await app.teardown();
    });
    testWidgets('make new', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      // Open one file.
      await app.openUpload("filename.txt", TestData.train.data);
      await app.findScene(TestData.train.data);
      await app.uploadError();
      app.manager.tag = "newer";
      await tester.tap(find.textContaining("empty scene"));
      await tester.pumpAndSettle();
      await app.loadAndFindScene("newer", SceneData());
      await app.teardown();
    });
  });

  group('Clipboard URL save and load', () {
    String? clipboardText;

    setUp(() {
      clipboardText = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboardText = (call.arguments as Map)['text'] as String?;
              return null;
            }
            if (call.method == 'Clipboard.getData') {
              return <String, dynamic>{'text': clipboardText};
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('ClipboardHolder saves JSON as URL and loads it back cleanly', () async {
      final settings = Settings();
      final manager = FileManager(settings);
      final saveHolder = ClipboardHolder(true);
      final sampleJson = jsonEncode(TestData.person.data);

      final saved = await saveHolder.saveData(sampleJson, manager);
      expect(saved, isTrue);
      expect(clipboardText, isNotNull);
      expect(clipboardText!, contains('/scene?json='));

      // Also verify loading a full http:// URL with query parameters works
      clipboardText =
          'https://spacetime.gchouse.org/scene?json=${Uri.encodeQueryComponent(sampleJson)}';
      final loadHolder = ClipboardHolder(false);
      final loadedJson = await loadHolder.loadData(manager);
      final loadedScene = SceneData.fromJsonString(loadedJson);
      expect(loadedScene.title, equals(TestData.person.data.title));
      expect(
        loadedScene.drawables.length,
        equals(TestData.person.data.drawables.length),
      );
    });

    test('ClipboardHolder loads hash-routed URL (#/scene?json=...)', () async {
      final settings = Settings();
      final manager = FileManager(settings);
      final sampleJson = jsonEncode(TestData.train.data);

      clipboardText =
          'https://spacetime.gchouse.org/#/scene?json=${Uri.encodeQueryComponent(sampleJson)}';
      final loadHolder = ClipboardHolder(false);
      final loadedJson = await loadHolder.loadData(manager);
      final loadedScene = SceneData.fromJsonString(loadedJson);
      expect(loadedScene.title, equals(TestData.train.data.title));
    });
  });

  group('Save-As counter increment', () {
    testWidgets(
      'Save As New Local File increments title counter when title already exists and lets user edit it',
      (tester) async {
        final app = AppTester(tester);
        await app.setup();
        await app.initialize();
        await app.loadAndFindScene("initial", SceneData());
        await app.openLocal("3", TestData.train.data);

        // LocalFileHolder.titles already has "Train Local File" (from seed or open).
        LocalFileHolder.titles["3"] = TestData.train.data.title;

        // Enable real Save-As confirmation dialog
        app.manager.isTesting = false;

        // Open Save As -> Local Data -> New Local File
        await app.tapMenus("Save As", "Local Data");
        await tester.tap(find.byKey(const ValueKey('new-local')));
        await tester.pumpAndSettle();

        // Confirm Properties dialog should appear with incremented title ("... 2")
        expect(find.text("Confirm Properties Before Saving"), findsOneWidget);
        expect(
          find.widgetWithText(TextField, "${TestData.train.data.title} 2"),
          findsOneWidget,
        );

        // Cancel out and restore testing flag
        await tester.tap(find.text("Cancel"));
        await tester.pumpAndSettle();
        app.manager.isTesting = true;
        await app.teardown();
      },
    );
  });
}
