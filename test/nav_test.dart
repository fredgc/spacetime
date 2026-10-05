import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/drive.dart';
import 'package:spacetime/file_holder.dart';
import 'package:spacetime/local_file.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/transform.dart';

import 'app_tester.dart';
import 'test_data.dart';

typedef TestPart = Future<void> Function(AppTester);
typedef LoadFunction = Future<void> Function(AppTester, String title);
typedef PostCheck =
    Future<void> Function(
      AppTester,
      String original_title,
      String edited_title,
    );

// Test the combination of open/reload with the possible user response.
// For the loading menu_item (Open/Reload), choose the response,
// If can_load is true, then the load can continue.
// handle_response is done after the response is clicked.
// doload does the load.
void testUnsavedCombined(
  String menuItem,
  String response, {
  required String name,
  required bool can_load,
  required bool changes_original,
  required TestPart start_load,
  required TestPart handle_response,
  required LoadFunction doload,
  required PostCheck post_check,
}) {
  testWidgets("$menuItem with unsaved, $name", (tester) async {
    final app = AppTester(tester);
    await app.seedRecent();
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());
    String originalTitle = TestData.train.data.title;
    String editedTitle = "This is new title";
    // Load file number 3, and edit the title.
    await app.openLocal("3", TestData.train.data);
    await app.scene.editTitle(editedTitle);
    expect(app.manager.unsaved.value, true);
    // Start to load or reload something else.
    await start_load(app);
    // Expect a warning about file being modified.
    expect(find.textContaining("Unsaved Scene"), findsOneWidget);
    expect(find.textContaining("drawing has been modified"), findsOneWidget);
    // Choose the response. (save/cancel/discard/saveas).
    await tester.tap(find.byKey(ValueKey('check-$response')));
    await tester.pumpAndSettle();
    // Handle the response (save/cancel/discard/saveas.
    await handle_response(app);
    if (can_load) {
      //If the response allows the load to continue.
      await doload(app, changes_original ? editedTitle : originalTitle);
    }
    // This might reload the original file to see if it has the right title.
    await post_check(app, originalTitle, editedTitle);
    await app.teardown();
  });
}

void testUnsavedMenuItem(
  String menuItem, {
  required LoadFunction doload,
  required TestPart start_load,
}) {
  testUnsavedCombined(
    menuItem,
    "save",
    name: "user chooses save",
    can_load: true,
    changes_original: true,
    start_load: start_load,
    doload: doload,
    handle_response: (app) async {
      await app.finish("save-local-3");
      await app.tester.pumpAndSettle();
      expect(app.manager.unsaved.value, false);
    },
    post_check: (app, originalTitle, editedTitle) async {
      expect(app.manager.unsaved.value, false);
      await app.openLocal("3", TestData.train.data..title = editedTitle);
    },
  );
  testUnsavedCombined(
    menuItem,
    "discard",
    name: "user chooses discard",
    can_load: true,
    changes_original: false,
    doload: doload,
    start_load: start_load,
    handle_response: (app) async {
      expect(app.manager.unsaved.value, false);
    },
    post_check: (app, originalTitle, editedTitle) async {
      expect(app.manager.unsaved.value, false);
      await app.openLocal("3", TestData.train.data..title = originalTitle);
    },
  );
  testUnsavedCombined(
    menuItem,
    "saveas",
    name: "user chooses saveas",
    can_load: true,
    changes_original: true,
    doload: doload,
    start_load: start_load,
    handle_response: (app) async {
      await app.tester.tap(find.text("Local Data"));
      await app.tester.pumpAndSettle();
      await app.tester.tap(find.byKey(ValueKey("open-local-5")));
      await app.tester.pumpAndSettle();
      await app.finishFile("saveas", null);
      await app.tester.pumpAndSettle();
      expect(app.manager.unsaved.value, false);
    },
    post_check: (app, originalTitle, editedTitle) async {
      expect(app.manager.unsaved.value, false);
      await app.openLocal("5", TestData.train.data..title = editedTitle);
    },
  );
  testUnsavedCombined(
    menuItem,
    "saveas",
    name: "user chooses saveas, but changes mind",
    can_load: false,
    changes_original: false,
    doload: doload,
    start_load: start_load,
    handle_response: (app) async {
      await app.tester.tap(find.byIcon(Icons.close));
      await app.tester.pumpAndSettle();
      expect(app.manager.unsaved.value, true);
    },
    post_check: (app, originalTitle, editedTitle) async {
      expect(app.manager.unsaved.value, true);
      await app.findScene(TestData.train.data..title = editedTitle);
    },
  );
  testUnsavedCombined(
    menuItem,
    "cancel",
    name: "user chooses cancel",
    can_load: false,
    changes_original: false,
    doload: doload,
    start_load: start_load,
    handle_response: (app) async {
      expect(app.manager.unsaved.value, true);
    },
    post_check: (app, originalTitle, editedTitle) async {
      expect(app.manager.unsaved.value, true);
      await app.findScene(TestData.train.data..title = editedTitle);
    },
  );
}

void testUnsaved() {
  testUnsavedMenuItem(
    "Open",
    start_load: (app) async {
      await app.tapMenu("Open");
    },
    doload: (app, title) async {
      // Open dialog is open. Go to local tab and open the new file.
      await app.tester.tap(find.text("Local Data"));
      await app.tester.pumpAndSettle();
      await app.tester.tap(find.byKey(ValueKey('open-local-4')));
      await app.tester.pumpAndSettle();
      await app.loadAndFindScene(null, TestData.clock.data);
    },
  );
  testUnsavedMenuItem(
    "Reload",
    start_load: (app) async {
      await app.tapMenu("Reload");
    },
    doload: (app, title) async {
      await app.loadAndFindScene(null, TestData.train.data..title = title);
    },
  );
  testUnsavedMenuItem(
    // Test the recent file "Third local".
    "Recent",
    start_load: (app) async {
      await app.tester.tap(find.byIcon(Icons.menu));
      await app.tester.pumpAndSettle();
      await app.tester.tap(find.text("File"));
      await app.tester.pumpAndSettle();
      await app.tester.tap(find.byType(MenuItemButton).at(1));
      await app.tester.pumpAndSettle();
    },
    doload: (app, title) async {
      await app.loadAndFindScene(null, TestData.person.data);
    },
  );
}

void main() {
  group('Some Splash Tests.', () {
    testWidgets('1st run', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
    });
    // Run the exact same test again to make sure there aren't any stale global
    // variables.
    testWidgets('2nd run', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.teardown();
    });
    testWidgets('splash alternate order 1', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      app.findOneInit(0);
      await app.finish("sprites");
      await tester.pumpAndSettle();
      app.findOneInit(0); // If sprites ends early, we still wait on settings.
      await app.finish("settings");
      await tester.pumpAndSettle();
      app.findOneInit(2);
      await app.finish("file_manager");
      await tester.pumpAndSettle();
      app.findOneInit(3);
      await app.loadAndFindScene("initial", SceneData());
      await app.teardown();
    });
    testWidgets('splash alternate order 2', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      app.findOneInit(0);
      await app.finish("file_manager");
      await tester.pumpAndSettle();
      app.findOneInit(0);
      await app.finish("sprites");
      await tester.pumpAndSettle();
      app.findOneInit(0);
      await app.finish("settings");
      await tester.pumpAndSettle();
      app.findOneInit(3);
      await app.loadAndFindScene("initial", SceneData());
      await app.teardown();
    });
    testWidgets('Splash with json', (tester) async {
      final app = AppTester(tester, url: TestData.person.url());
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", TestData.person.data);
      await app.teardown();
    });
    testWidgets('Splash with error', (tester) async {
      final app = AppTester(tester, url: TestData.error.url());
      await app.setup();
      await app.initialize();
      await app.findError("initial");
      await app.teardown();
    });
    testWidgets('After splash, load second file', (tester) async {
      final app = AppTester(tester, url: TestData.person.url());
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", TestData.person.data);
      await app.loadWithURL("2nd-file", TestData.train.url());
      await app.loadAndFindScene("2nd-file", TestData.train.data);
      await app.teardown();
    });
  });

  group('Some Errors.', () {
    testWidgets('After error, go back', (tester) async {
      final app = AppTester(tester, url: TestData.person.url());
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", TestData.person.data);
      await app.loadWithURL("error", TestData.error.url());
      await app.findError("error");
      await tester.tap(find.textContaining("Go back"));
      await tester.pumpAndSettle();
      // app.listSleeps();
      await app.findScene(TestData.person.data);
      await app.teardown();
    });

    testWidgets('After error, make new', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      await app.openLocal("3", TestData.train.data);
      await app.loadWithURL("error", TestData.error.url());
      await app.findError("error");
      app.manager.tag = "newer";
      await tester.tap(find.textContaining("empty scene"));
      await tester.pumpAndSettle();
      // app.listSleeps();
      await app.loadAndFindScene("newer", SceneData());
      await app.teardown();
    });

    testUnsaved();
  });

  group('Cick Buttons.', () {
    testWidgets('Click help', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      expect(find.textContaining("Help"), findsNothing);
      expect(find.textContaining("Overview"), findsNothing);
      expect(find.byIcon(Icons.help), findsOneWidget);
      await tester.tap(find.byIcon(Icons.help));
      await tester.pumpAndSettle();

      // Tap "Help & User Guides" from the main help options menu
      expect(find.text("Help & User Guides"), findsOneWidget);
      await tester.tap(find.text("Help & User Guides"));
      await tester.pumpAndSettle();

      // We should now be on the HelpScreen
      expect(find.textContaining("Help & Docs"), findsOneWidget);

      // Verify Overview list item is present in the docked sidebar and tap it
      expect(find.textContaining("Overview"), findsOneWidget);
      await tester.tap(find.textContaining("Overview"));
      await tester.pumpAndSettle();

      // Close the help screen
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await app.findScene(SceneData());
      await app.teardown();
    });
    testWidgets('Click settings', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      // Open the menu/drawer.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text("Initiaizing Settings..."), findsNothing);
      expect(find.textContaining("Theme Brightness:"), findsOneWidget);
      expect(find.textContaining("Sticky delay:"), findsOneWidget);
      expect(find.textContaining("Sticky radius:"), findsOneWidget);
      expect(find.textContaining("Dot Size:"), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await app.finish("settings"); // Allow settings to reload.
      await tester.pumpAndSettle();
      await app.findScene(SceneData());
      await app.teardown();
    });
    testWidgets('open and close menu', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());

      // Open the menu/drawer and tap "Ether".
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text("File"));
      await tester.pumpAndSettle();
      // There should be some menu items.
      expect(find.text("Open"), findsOneWidget);
      expect(find.text("Save"), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('closeDrawerButton')));
      await tester.pumpAndSettle();
      expect(find.textContaining("Open"), findsNothing);
      expect(find.textContaining("Save"), findsNothing);
      await app.teardown();
    });
    testWidgets('change lightspeed', (tester) async {
      final app = AppTester(tester);
      await app.setup();
      await app.initialize();
      await app.loadAndFindScene("initial", SceneData());
      expect(app.manager.current.scene, isNotNull);
      SceneView view = app.manager.current.scene!;
      expect(view.light_speed.value, LightSpeed.lorentz);

      // Open the menu/drawer and tap "Ether".
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text("View"));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining("Ether"));
      await tester.pumpAndSettle();
      // TODO: should changing the light speed close the drawer?
      await tester.tap(find.byKey(const ValueKey('closeDrawerButton')));
      await tester.pumpAndSettle();
      expect(view.light_speed.value, LightSpeed.ether);
      expect(find.text("Ether"), findsNothing); // drawer closed.

      // Open the menu/drawer and tap "Emitter".
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      if (find.textContaining("Emitter").evaluate().isEmpty) {
        await tester.tap(find.text("View"));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.textContaining("Emitter"));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('closeDrawerButton')));
      await tester.pumpAndSettle();
      expect(view.light_speed.value, LightSpeed.emitter);
      expect(find.text("Emitter"), findsNothing); // drawer closed.

      // Open the menu/drawer and tap "Lorentz".
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      if (find.textContaining("Lorentz").evaluate().isEmpty) {
        await tester.tap(find.text("View"));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.textContaining("Lorentz"));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('closeDrawerButton')));
      await tester.pumpAndSettle();
      expect(view.light_speed.value, LightSpeed.lorentz);
      expect(find.text("Lorentz"), findsNothing); // drawer closed.
    });
  });

  group('Deep Linking Tests.', () {
    testWidgets('Deep link via drive parameter', (tester) async {
      final app = AppTester(tester, url: "/scene?drive=test_drive_id_123");
      await app.setup();
      await app.initialize();
      expect(app.manager.current.holder, isA<DriveHolder>());
      expect(
        (app.manager.current.holder as DriveHolder).id,
        "test_drive_id_123",
      );
      await app.teardown();
    });

    testWidgets('Deep link via Google Drive state parameter', (tester) async {
      final stateParam = Uri.encodeComponent(
        '{"action":"open","ids":["gdrive_file_789"]}',
      );
      final app = AppTester(tester, url: "/scene?state=$stateParam");
      await app.setup();
      await app.initialize();
      expect(app.manager.current.holder, isA<DriveHolder>());
      expect((app.manager.current.holder as DriveHolder).id, "gdrive_file_789");
      await app.teardown();
    });

    testWidgets('Deep link via json parameter', (tester) async {
      final app = AppTester(tester, url: TestData.person.url());
      await app.setup();
      await app.initialize();
      expect(app.manager.current.holder, isA<JsonHolder>());
      await app.loadAndFindScene("initial", TestData.person.data);
      await app.teardown();
    });

    testWidgets('Deep link via local parameter', (tester) async {
      final app = AppTester(tester, url: "/scene?local=3");
      await app.setup();
      await app.initialize();
      expect(app.manager.current.holder, isA<LocalFileHolder>());
      await app.loadAndFindScene("initial", TestData.train.data);
      await app.teardown();
    });
  });
}
