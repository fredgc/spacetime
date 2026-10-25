import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:spacetime/color.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('SavableColor and SavableColorArray unit tests', () {
    test('SavableColor loads, saves, and updates theme', () async {
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );
      await prefs.setInt('test_color', 0xFF123456);

      final color = SavableColor(
        'test_color',
        'Test Color',
        Colors.white,
        (scheme) => scheme.primary,
      );

      // Verify initial value
      expect(color.value, Colors.white);

      // Load from preferences
      color.load(prefs);
      expect(color.value.toARGB32(), 0xFF123456);

      // Save new value
      color.value = const Color(0xFFAABBCC);
      color.save(prefs);
      expect(prefs.getInt('test_color'), 0xFFAABBCC);

      // Update theme
      const scheme = ColorScheme.light(primary: Colors.red);
      color.updateTheme(scheme);
      expect(color.value, Colors.red);
    });

    test(
      'SavableColorArray loads, saves, and avoids in-place mutation on updateTheme',
      () async {
        final prefs = await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        );
        await prefs.setInt('arr 0', 0xFF111111);
        await prefs.setInt('arr 1', 0xFF222222);

        final defaultList = [Colors.black, Colors.white];
        final colorArray = SavableColorArray(
          'arr',
          'Array of colors',
          List.from(defaultList),
          (scheme) => [Colors.amber, Colors.cyan],
        );

        expect(colorArray.value.length, 2);

        // Load from preferences
        colorArray.load(prefs);
        expect(colorArray.value[0].toARGB32(), 0xFF111111);
        expect(colorArray.value[1].toARGB32(), 0xFF222222);

        // Save
        colorArray.value[0] = const Color(0xFF333333);
        colorArray.save(prefs);
        expect(prefs.getInt('arr 0'), 0xFF333333);

        // updateTheme must produce a new list
        const scheme = ColorScheme.light();
        colorArray.updateTheme(scheme);
        expect(colorArray.value, [Colors.amber, Colors.cyan]);
      },
    );

    testWidgets('SavableColor and SavableColorArray build widgets', (
      tester,
    ) async {
      final color = SavableColor(
        'test_color',
        'Test Color',
        Colors.blue,
        (scheme) => scheme.primary,
      );

      final colorArray = SavableColorArray('arr', 'Array colors', [
        Colors.red,
        Colors.green,
      ], (scheme) => []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ...color.build(context, () {}).whereType<Widget>(),
                    ...colorArray.build(context, () {}).whereType<Widget>(),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Color: '), findsOneWidget);
      expect(find.text('Array colors: '), findsOneWidget);
    });

    testWidgets('SavableTheme updates mode and builds switcher', (
      tester,
    ) async {
      final theme = SavableTheme();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              theme.initialize(() {
                callbackCalled = true;
              }, context);
              return Scaffold(
                body: ListView(
                  children: theme
                      .build(context, () {})
                      .whereType<Widget>()
                      .toList(),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Theme Brightness: '), findsOneWidget);
      expect(find.text('light'), findsOneWidget);
      expect(find.text('dark'), findsOneWidget);

      theme.themeMode = ThemeMode.dark;
      theme.updateAndCallback();
      expect(callbackCalled, true);
      expect(theme.scheme.brightness, Brightness.dark);
    });
  });
}
