import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/scene.dart';

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
  /*
   Test saveas with user doesn't choose anything.
  test save error (write permission?)
  verify recent files.
  test load recent download/upload file. Make sure path makes sense.
  test reload a downloaded file.
  */
}
