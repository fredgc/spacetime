import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/splitter.dart';

void main() {
  group('SplitterWidget unit tests', () {
    testWidgets('renders top and bottom children with handle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: SplitterWidget(
                top: (context) => const Text('Top View Content'),
                bottom: (context) => const Text('Bottom View Content'),
                setter: (val) {},
                initialSize: 120,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Top View Content'), findsOneWidget);
      expect(find.text('Bottom View Content'), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    });

    testWidgets('dragging handle updates bottom size via setter', (
      tester,
    ) async {
      double updatedBottom = 100.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 500,
              child: SplitterWidget(
                top: (context) => const Text('Top View'),
                bottom: (context) => const Text('Bottom View'),
                setter: (val) => updatedBottom = val,
                initialSize: 100,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final handle = find.byIcon(Icons.drag_handle);
      expect(handle, findsOneWidget);

      // Drag handle upwards (negative dy) to increase bottom size
      await tester.drag(handle, const Offset(0, -60));
      await tester.pumpAndSettle();

      expect(updatedBottom > 100.0, true);
    });
  });
}
