import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/scene.dart';
import 'package:spacetime/widget.dart';

import 'app_tester.dart';

// XXX This doesn't actually do anything because the text widget does
// not seem to show us the elided text. Still, the test below is still
// valuable because a layout overflow would be triggered if we didn't
// elide or wrap the text.
void checkOverflow(tester, String overflowWord) {
  var overflows = find.textContaining(overflowWord);
  var result = overflows.evaluate();
  for (var element in result) {
    var textWidget = element.widget as Text;
    // tester.widget<Text>(find.byType(Text, element));
    // XXX -------- why does this not work? It shows all of the text, not
    // just the text that is rendered.
    // XXX expect(textWidget.data!.endsWith('…'), isTrue);
  }
}

void main() {
  testWidgets('overflow', (tester) async {
    final app = AppTester(tester);
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());
    // A word that should not show up anywhere, even at the end of the long
    // title when the title has been shortened with ellipsis.
    const String overflowWord = "look_for_this_overflow_word";
    String longTitle = ("This is a very very long Title " * 10 + overflowWord);
    await app.scene.editTitle(longTitle);
    await app.saveAsLocal("open-local-3", SceneData()..title = longTitle);
    checkOverflow(tester, overflowWord);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    // Expand File menu in drawer
    await tester.tap(find.text("File"));
    await tester.pumpAndSettle();
    // The recent files in the main menu should overflow correctly.
    checkOverflow(tester, overflowWord);
    // The recent files in the recent file tab should overflow correctly.
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();
    checkOverflow(tester, overflowWord);
    // The local files tab should overflow correctly.
    await tester.tap(find.text("Local Data"));
    await tester.pumpAndSettle();
    checkOverflow(tester, overflowWord);
    await app.teardown();
  });

  testWidgets('narrow mobile viewport layout', (tester) async {
    // Set a narrow mobile screen dimension (360x640)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    final app = AppTester(tester);
    await app.setup();
    await app.initialize();
    await app.loadAndFindScene("initial", SceneData());

    // Verify layout settles without any RenderFlex overflows
    expect(find.byType(AppWidget), findsOneWidget);

    // Open drawer on narrow layout
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text("File"));
    await tester.pumpAndSettle();
    expect(find.text("Open"), findsOneWidget);

    // Close drawer
    await tester.tap(find.byKey(const ValueKey('closeDrawerButton')));
    await tester.pumpAndSettle();

    // Reset surface size
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();

    await app.teardown();
  });
}
