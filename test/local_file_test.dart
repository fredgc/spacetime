import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/drawable.dart';
import 'package:spacetime/drive.dart';
import 'package:spacetime/file_holder.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/local_file.dart';
import 'package:spacetime/printer.dart';
import 'package:spacetime/settings.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';
import 'package:spacetime/upload.dart';

import 'app_tester.dart';
import 'local_file_mock.dart';
import 'test_data.dart';

// TODO: Move to local_file_mock.dart
Future<void> reorderLocal(var tester, String id1, String id2, double dy) async {
  expect(find.byKey(ValueKey('open-local-$id1')), findsOneWidget);
  var tile = find.byKey(ValueKey('open-local-$id1'));
  // print("tile = $tile");
  // print("center = ${tester.getCenter(tile)}");
  final TestGesture drag = await tester.startGesture(tester.getCenter(tile));
  await tester.pump(kLongPressTimeout + kPressTimeout);
  var center = tester.getCenter(find.byKey(ValueKey('open-local-$id2')));
  var dest = Offset(center.dx, center.dy + dy);
  await drag.moveTo(dest);
  await drag.up();
  await tester.pumpAndSettle();
}

void main() {
  group('On URL.', () {
    testWidgets('Load local 2', (tester) async {
      final app = AppTester(tester, url: "/scene?local=2");
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", TestData.person.data);
      await app.teardown();
    });

    testWidgets('Load local 1 error', (tester) async {
      final app = AppTester(tester, url: "/scene?local=1");
      await app.setup();
      await app.initialize();
      await app.findError("initial");
      await app.teardown();
    });
  });

  group('Open.', () {
    testWidgets('Load local 3', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("3", TestData.train.data);
      var train = app.scene.view!.data.drawables[0];
      final epsilon = 1e-6;
      expect(train.name, "P1");
      expect(train.type, DrawType.train);
      expect(train.color, 1);
      expect(train.pt, Point(x: -0.366, t: 0.364, z: 0.01));
      expect(train.frame.velocity, closeTo(0.222, epsilon));
      await app.expectRecent([LocalFileHolder("3")]);
      await app.teardown();
    });

    testWidgets('Load local 4, 3, 5', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("4", TestData.clock.data);
      await app.openLocal("3", TestData.train.data);
      await app.openLocal("5", TestData.sample.data);
      await app.expectRecent([
        LocalFileHolder("5"),
        LocalFileHolder("3"),
        LocalFileHolder("4"),
      ]);
      await app.teardown();
    });
    testWidgets('Load local 4, error, go back', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("4", TestData.clock.data);
      await app.tapMenus("Open", "Local Data");
      await tester.tap(find.byKey(const ValueKey('open-local-1')));
      await tester.pumpAndSettle();
      await app.findError(app.manager.current.holder.tag);
      await tester.tap(find.textContaining("Go back"));
      await tester.pumpAndSettle();
      await app.findScene(TestData.clock.data);
      await app.teardown();
    });
    testWidgets('Load local 4, error, make new', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("4", TestData.clock.data);
      await app.tapMenus("Open", "Local Data");
      await tester.tap(find.byKey(const ValueKey('open-local-1')));
      await tester.pumpAndSettle();
      await app.findError(app.manager.current.holder.tag);
      app.manager.tag = "newer";
      await tester.tap(find.textContaining("empty scene"));
      await tester.pumpAndSettle();
      await app.loadAndFindScene("newer", SceneData());
      await app.teardown();
    });
  });
  group('Save.', () {
    testWidgets('Load, Edit, Save', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("3", TestData.train.data);

      const String editedTitle = "This is the new Title";
      await app.scene.editTitle(editedTitle);
      app.tagCurrentFile("l-train");
      await app.tapMenu("Save");
      await app.finish("save-l-train");
      await tester.pumpAndSettle();
      await app.findScene(TestData.train.data..title = editedTitle);
      await app.expectRecent([LocalFileHolder("3")]);
      await app.teardown();
    });
    testWidgets('saveAs', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("3", TestData.train.data);
      // SaveAs to write new file.
      const String editedTitle = "This is the new Title";
      await app.scene.editTitle(editedTitle);
      SceneData scene5 = TestData.train.data..title = editedTitle;
      await app.saveAsLocal("new-local", scene5);
      // SaveAs to overwrite existing file.
      String title3 = "Title two";
      SceneData scene3 = TestData.train.data..title = title3;
      await app.scene.editTitle(title3);
      await app.saveAsLocal("open-local-4", scene3);

      // Now load them again and make sure they kept the titles.
      await app.openLocal("3", TestData.train.data);
      await app.openLocal("6", scene5);
      await app.openLocal("4", scene3);
      await app.openLocal("3", TestData.train.data);
      await app.expectRecent([
        LocalFileHolder("3"),
        LocalFileHolder("4"),
        LocalFileHolder("6"),
      ]);
      await app.teardown();
    });
  });
  group('Recent.', () {
    testWidgets('load recent.', (tester) async {
      final app = AppTester(tester);
      await app.seedRecent();
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      // ClipboardHolder is not saved in recent list, so we don't expect
      // to find it at the end.
      // Titles should match those in seedRecent.
      await app.expectRecent([
        JsonHolder(TestData.person.json)..title = "Json person",
        LocalFileHolder("4")..title = "Third local",
        LocalFileHolder("2")..title = "First local",
        DriveHolder("drive_id")..title = "Drive File",
        UploadHolder("uploadfile")..title = "Upload File",
      ]);
      await app.teardown();
    });

    testWidgets('reorder', (tester) async {
      final app = AppTester(tester);
      await app.seedRecent();
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("4", TestData.clock.data);
      await app.expectRecent([
        LocalFileHolder("4"),
        JsonHolder(TestData.person.json)..title = "Json person",
        LocalFileHolder("2")..title = "First local",
        DriveHolder("drive_id")..title = "Drive File",
        UploadHolder("uploadfile")..title = "Upload File",
      ]);
      await app.teardown();
    });

    testWidgets('open menu', (tester) async {
      final app = AppTester(tester);
      await app.seedRecent();
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openRecent(1, TestData.clock.data);
      await app.expectRecent([
        LocalFileHolder("4"),
        JsonHolder(TestData.person.json)..title = "Json person",
        LocalFileHolder("2")..title = "First local",
        DriveHolder("drive_id")..title = "Drive File",
        UploadHolder("uploadfile")..title = "Upload File",
      ]);
      await app.teardown();
    });

    testWidgets('open dialog', (tester) async {
      final app = AppTester(tester);
      await app.seedRecent();
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openRecentDialog(1, TestData.clock.data);
      await app.expectRecent([
        LocalFileHolder("4"),
        JsonHolder(TestData.person.json)..title = "Json person",
        LocalFileHolder("2")..title = "First local",
        DriveHolder("drive_id")..title = "Drive File",
        UploadHolder("uploadfile")..title = "Upload File",
      ]);
      await app.teardown();
    });

    // This test has a lot of churn so that to make sure that
    // recreating widgets and listeners get disposed of correctly.
    testWidgets('delete and forget', (tester) async {
      final app = AppTester(tester);
      await app.seedRecent();
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openRecentDialog(1, TestData.clock.data);
      await app.openLocal("2", TestData.person.data);
      await app.openLocal("3", TestData.train.data);
      await app.expectRecent([
        LocalFileHolder("3"),
        LocalFileHolder("2"),
        LocalFileHolder("4"),
        JsonHolder(TestData.person.json)..title = "Json person",
        DriveHolder("drive_id")..title = "Drive File",
      ]);
      await app.tapMenu("Open");
      expect(find.textContaining(TestData.person.data.title), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('forget-recent-1')));
      await tester.pumpAndSettle();
      expect(find.textContaining(TestData.person.data.title), findsNothing);
      await app.expectRecent([
        LocalFileHolder("3")..title = "Train Local File",
        LocalFileHolder("4")..title = "Clock Local File",
        JsonHolder(TestData.person.json)..title = "Json person",
        // Gone: LocalFileHolder("1")..title = "First local",
        DriveHolder("drive_id")..title = "Drive File",
      ]);
      await tester.tap(find.byKey(ValueKey('open-recent-1')));
      await tester.pumpAndSettle();
      await app.loadAndFindScene(null, TestData.clock.data);
      // Re-open a few files to check that there weren't any dispose problems.
      await app.openLocal("2", TestData.person.data);
      await app.openLocal("3", TestData.train.data);
      await app.expectRecent([
        LocalFileHolder("3"),
        LocalFileHolder("2"),
        LocalFileHolder("4"),
        JsonHolder(TestData.person.json)..title = "Json person",
        // Gone: LocalFileHolder("1")..title = "First local",
        DriveHolder("drive_id")..title = "Drive File",
      ]);
      // Open the recent json data.  Notice that the title was wrong above, but
      // should be correct after the file has been loaded.
      await app.openRecentDialog(3, TestData.person.data);
      await app.expectRecent([
        JsonHolder(TestData.person.json),
        LocalFileHolder("3"),
        LocalFileHolder("2"),
        LocalFileHolder("4"),
        DriveHolder("drive_id")..title = "Drive File",
      ]);
      // Change the title.
      const String editedTitle = "This is the new Title";
      await app.scene.editTitle(editedTitle);
      await app.saveAsLocal(
        "new-local",
        TestData.person.data..title = editedTitle,
      );
      await app.expectRecent([
        LocalFileHolder("6")..title = editedTitle,
        JsonHolder(TestData.person.json),
        LocalFileHolder("3"),
        LocalFileHolder("2"),
        LocalFileHolder("4"),
      ]);
      // Now delete a local file. It should no longer be in list of files.
      await app.tapMenus("Open", "Local Data");
      await tester.tap(find.byKey(ValueKey('delete-local-3')));
      await tester.pumpAndSettle();
      expect(find.textContaining("Train Local File"), findsNothing);
      await app.expectRecent([
        LocalFileHolder("6")..title = editedTitle,
        JsonHolder(TestData.person.json),
        // DELETED: LocalFileHolder("3")..title = "Train Local File",
        LocalFileHolder("2"),
        LocalFileHolder("4"),
      ]);
      // Open dialog is still visible, delete another one.
      await tester.tap(find.byKey(ValueKey('delete-local-1')));
      await tester.pumpAndSettle();
      expect(find.textContaining("Error Title"), findsNothing);
      // Open dialog is still visible, select the clock file.
      await tester.tap(find.byKey(ValueKey('open-local-4')));
      await tester.pumpAndSettle();
      await app.loadAndFindScene(null, TestData.clock.data);
      await app.expectRecent([
        LocalFileHolder("4"),
        LocalFileHolder("6"),
        JsonHolder(TestData.person.json),
        LocalFileHolder("2"),
      ]);
      // Open a few more to see what happens.
      await app.openRecent(1, TestData.person.data..title = editedTitle);
      await app.openRecentDialog(3, TestData.person.data);
      await app.expectRecent([
        LocalFileHolder("2"),
        LocalFileHolder("6"),
        LocalFileHolder("4"),
        JsonHolder(TestData.person.json),
      ]);
      await app.expectLocal([
        // The first two do not get the correct title because we have never
        // saved this file. That's OK -- it's only a test artifact.
        HolderMock(TestData.person.json, "2", "Person Unsaved Title"),
        HolderMock(TestData.clock.json, "4", "Clock Unsaved Title"),
        HolderMock(TestData.person.json, "5", "Sample Unsaved Title"),
        HolderMock(TestData.person.json, "6", editedTitle),
      ]);
      await app.teardown();
    });
  });
  testWidgets('Reorder.', (tester) async {
    final app = AppTester(tester, url: "/scene?local=2");
    await app.seedRecent();
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", TestData.person.data);
    const String title2 = "Person 2";
    await app.scene.editTitle(title2);
    await app.saveAsLocal("new-local", TestData.person.data..title = title2);
    const String title3 = "Person 3";
    await app.scene.editTitle(title3);
    await app.saveAsLocal("new-local", TestData.person.data..title = title3);
    await app.expectLocal([
      // The first two do not get the correct title because we have never
      // saved this file. That's OK -- it's only a test artifact.
      HolderMock(TestData.error.json, "1", "Error Unsaved Title"),
      HolderMock(TestData.person.json, "2", "Person Unsaved Title"),
      HolderMock(TestData.train.json, "3", "Train Unsaved Title"),
      HolderMock(TestData.clock.json, "4", "Clock Unsaved Title"),
      HolderMock(TestData.person.json, "5", "Sample Unsaved Title"),
      HolderMock(TestData.person.json, "6", title2),
      HolderMock(TestData.person.json, "7", title3),
    ]);

    // Re-order the files and then check again.
    await app.tapMenus("Open", "Local Data");
    await reorderLocal(tester, "3", "5", 0);
    await reorderLocal(tester, "4", "1", 0);
    // Drag to before the beginning, it should go at the begining.
    await reorderLocal(tester, "6", "4", -300);
    await app.expectLocal([
      // The first two do not get the correct title because we have never
      // saved this file. That's OK -- it's only a test artifact.
      HolderMock(TestData.person.json, "6", title2),
      HolderMock(TestData.clock.json, "4", "Clock Unsaved Title"),
      HolderMock(TestData.error.json, "1", "Error Unsaved Title"),
      HolderMock(TestData.person.json, "2", "Person Unsaved Title"),
      HolderMock(TestData.train.json, "3", "Train Unsaved Title"),
      HolderMock(TestData.person.json, "5", "Sample Unsaved Title"),
      HolderMock(TestData.person.json, "7", title3),
    ]);
    // Drag to after the end.
    await reorderLocal(tester, "2", "6", 400);
    await app.expectLocal([
      // The first two do not get the correct title because we have never
      // saved this file. That's OK -- it's only a test artifact.
      HolderMock(TestData.person.json, "6", title2),
      HolderMock(TestData.clock.json, "4", "Clock Unsaved Title"),
      HolderMock(TestData.error.json, "1", "Error Unsaved Title"),
      HolderMock(TestData.train.json, "3", "Train Unsaved Title"),
      HolderMock(TestData.person.json, "5", "Sample Unsaved Title"),
      HolderMock(TestData.person.json, "7", title3),
      HolderMock(TestData.person.json, "2", "Person Unsaved Title"),
    ]);
    // Open dialog is still visible, select the clock file.
    await tester.tap(find.byKey(ValueKey('open-local-4')));
    await tester.pumpAndSettle();
    await app.loadAndFindScene(null, TestData.clock.data);
    await app.teardown();
  });

  testWidgets('Unsaved state clears on save and restores on undo', (
    tester,
  ) async {
    final app = AppTester(tester, url: "/scene?local=2");
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", TestData.person.data);
    expect(app.manager.unsaved.value, false);

    await app.scene.editTitle("Edited Scene Title");
    expect(app.manager.unsaved.value, true);

    app.manager.current.scene!.undo_manager.undo();
    await tester.pumpAndSettle();
    expect(app.manager.unsaved.value, false);

    app.manager.current.scene!.undo_manager.redo();
    await tester.pumpAndSettle();
    expect(app.manager.unsaved.value, true);

    app.manager.clearUnsaved();
    expect(app.manager.unsaved.value, false);

    await tester.pump(const Duration(milliseconds: 200));
    await app.teardown();
  });

  group('Save/Load Error Details Expansion Verification', () {
    testWidgets('SplashWidget expands load error details', (tester) async {
      final app = AppTester(tester, url: "/scene?local=1");
      await app.setup();
      await app.initialize();
      await app.findError("initial");

      expect(
        find.byKey(const ValueKey('expand_load_error_details')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('expand_load_error_details')));
      await tester.pumpAndSettle();

      expect(find.textContaining("FormatException"), findsWidgets);
      await app.teardown();
    });

    testWidgets(
      'FileManager save dialog expands error details on save failure',
      (tester) async {
        final app = AppTester(tester, url: "/scene?local=2");
        await app.setup();
        await app.initialize();
        await app.loadAndFindScene("initial", TestData.person.data);

        // Use the same id as the loaded file so that the holder's path
        // matches and checkNavigation does not trigger loadFile during
        // a GoRouter rebuild.
        final failingHolder = FailingSaveFileHolder("2");
        app.manager.current.holder = failingHolder;
        app.manager.isTesting = true;
        app.manager.unsaved.value = true;

        final saveResultFuture = app.manager.save();
        await tester.pump(Duration.zero);
        await app.finishFile("save", failingHolder.tag);
        await tester.pumpAndSettle();

        expect(find.text("Save Failed"), findsOneWidget);
        expect(
          find.byKey(const ValueKey("expand_save_error_details")),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey("expand_save_error_details")),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining("403 Insufficient Permission"),
          findsOneWidget,
        );

        await tester.tap(find.text("OK"));
        await tester.pumpAndSettle();

        final result = await saveResultFuture;
        expect(result, false);

        // Clear unsaved state so that teardown's pump does not trigger
        // checkSave (which shows a dialog) during a GoRouter rebuild.
        app.manager.unsaved.value = false;
        await tester.pumpAndSettle();

        await app.teardown();
      },
    );
  });
}

class FailingSaveFileHolder extends LocalFileHolder {
  FailingSaveFileHolder(super.id);

  @override
  Future<bool> saveData(String data, FileManager manager) async {
    throw Exception("Google Drive I/O Error: 403 Insufficient Permission");
  }
}
