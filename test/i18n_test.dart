import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacetime/l10n/l10n_extension.dart';
import 'package:spacetime/tutorials.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Spacetime Localization & Accessibility Tests', () {
    test('Default English and British English AppLocalizations strings', () {
      final l10nEn = lookupAppLocalizations(const Locale('en'));
      expect(l10nEn.appTitle, equals('Spacetime Drawing Tool'));
      expect(l10nEn.language, equals('Language'));
      expect(l10nEn.systemDefault, equals('System Default'));
      expect(l10nEn.settings, equals('Settings'));
      expect(l10nEn.initializingSettings, contains('Initializing'));

      final l10nGb = lookupAppLocalizations(const Locale('en', 'GB'));
      expect(l10nGb.appTitle, equals('Spacetime Drawing Tool'));
      expect(l10nGb.initializingSettings, contains('Initialising'));
    });

    test(
      'German, French, Lithuanian, Chinese, Japanese, Portuguese strings',
      () {
        final de = lookupAppLocalizations(const Locale('de'));
        expect(de.appTitle, equals('Spacetime-Zeichenwerkzeug'));
        expect(de.language, equals('Sprache'));
        expect(de.settings, equals('Einstellungen'));

        final fr = lookupAppLocalizations(const Locale('fr'));
        expect(fr.appTitle, equals('Outil de dessin Spacetime'));
        expect(fr.language, equals('Langue'));
        expect(fr.settings, equals('Paramètres'));

        final lt = lookupAppLocalizations(const Locale('lt'));
        expect(lt.appTitle, equals('Erdvėlaikio braižymo įrankis'));
        expect(lt.language, equals('Kalba'));
        expect(lt.settings, equals('Nustatymai'));

        final zh = lookupAppLocalizations(const Locale('zh'));
        expect(zh.appTitle, equals('时空图绘制工具'));
        expect(zh.language, equals('语言'));
        expect(zh.settings, equals('设置'));

        final ja = lookupAppLocalizations(const Locale('ja'));
        expect(ja.appTitle, equals('時空図作図ツール'));
        expect(ja.language, equals('言語'));
        expect(ja.settings, equals('設定'));

        final pt = lookupAppLocalizations(const Locale('pt'));
        expect(pt.appTitle, equals('Ferramenta de Desenho do Espaço-Tempo'));
        expect(pt.language, equals('Idioma'));
        expect(pt.settings, equals('Configurações'));
      },
    );

    test(
      'LocaleController setLocale and SharedPreferences persistence',
      () async {
        await LocaleController.setLocale(const Locale('en', 'GB'));
        expect(
          LocaleController.currentLocale.value,
          equals(const Locale('en', 'GB')),
        );

        await LocaleController.setLocale(const Locale('de'));
        expect(
          LocaleController.currentLocale.value,
          equals(const Locale('de')),
        );

        await LocaleController.setLocale(null);
        expect(LocaleController.currentLocale.value, isNull);
      },
    );

    test(
      'All 7 tutorials have localized titles in all supported languages',
      () {
        final tutorials = getBuiltInTutorials(includeDev: false);
        expect(tutorials.length, equals(7));

        const locales = ['de', 'es', 'fr', 'ja', 'lt', 'pt', 'zh'];
        for (final t in tutorials) {
          for (final loc in locales) {
            expect(
              t.localizedTitles[loc],
              isNotNull,
              reason: 'Tutorial ${t.title} missing $loc title',
            );
            expect(t.titleForLocale(loc), isNotEmpty);
          }
        }
      },
    );

    test(
      'Tutorial 02 contains appropriate station and beverage replacements',
      () {
        final tutEn = File(
          'assets/tutorials/02_ether_vs_emitter.md',
        ).readAsStringSync();
        expect(tutEn, contains('Grand Central Station'));
        expect(tutEn, contains('coffee'));

        final tutGb = File(
          'assets/tutorials/02_ether_vs_emitter_en_gb.md',
        ).readAsStringSync();
        expect(tutGb, contains('Trafalgar Station'));
        expect(tutGb, contains('tea'));

        final tutDe = File(
          'assets/tutorials/02_ether_vs_emitter_de.md',
        ).readAsStringSync();
        expect(tutDe, contains('Berliner Hauptbahnhof'));
        expect(tutDe, contains('Bier'));

        final tutFr = File(
          'assets/tutorials/02_ether_vs_emitter_fr.md',
        ).readAsStringSync();
        expect(tutFr, contains('gare de Lyon'));
        expect(tutFr, contains('café'));

        final tutLt = File(
          'assets/tutorials/02_ether_vs_emitter_lt.md',
        ).readAsStringSync();
        expect(tutLt, contains('Vilniaus geležinkelio stoties'));
        expect(tutLt, contains('šaltibarščius'));

        final tutZh = File(
          'assets/tutorials/02_ether_vs_emitter_zh.md',
        ).readAsStringSync();
        expect(tutZh, contains('北京站'));
        expect(tutZh, contains('茶'));

        final tutJa = File(
          'assets/tutorials/02_ether_vs_emitter_ja.md',
        ).readAsStringSync();
        expect(tutJa, contains('東京駅'));
        expect(tutJa, contains('お茶'));

        final tutPt = File(
          'assets/tutorials/02_ether_vs_emitter_pt.md',
        ).readAsStringSync();
        expect(tutPt, contains('Estação Central'));
        expect(tutPt, contains('café'));
      },
    );

    test('All localized ARB files maintain key parity with app_en.arb', () {
      final enContent = File('lib/l10n/app_en.arb').readAsStringSync();
      final enJson = jsonDecode(enContent) as Map<String, dynamic>;
      final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();

      final targetArbFiles = [
        'app_de.arb',
        'app_en_gb.arb',
        'app_es.arb',
        'app_fr.arb',
        'app_ja.arb',
        'app_lt.arb',
        'app_pt.arb',
        'app_zh.arb',
      ];

      for (final file in targetArbFiles) {
        final content = File('lib/l10n/$file').readAsStringSync();
        final json = jsonDecode(content) as Map<String, dynamic>;
        for (final key in enKeys) {
          expect(
            json.containsKey(key),
            isTrue,
            reason: '$file is missing key "$key"',
          );
          expect(
            json[key]?.toString().trim().isNotEmpty,
            isTrue,
            reason: '$file has empty value for key "$key"',
          );
        }
      }
    });

    testWidgets('L10nX on BuildContext renders localized strings', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Builder(
            builder: (context) {
              return Text(context.l10n.appTitle);
            },
          ),
        ),
      );

      expect(find.text('Spacetime-Zeichenwerkzeug'), findsOneWidget);
    });

    testWidgets('Switching from German to Auto (null) switches to English', (
      WidgetTester tester,
    ) async {
      await LocaleController.setLocale(const Locale('de'));
      await tester.pumpWidget(
        ValueListenableBuilder<Locale?>(
          valueListenable: LocaleController.currentLocale,
          builder: (context, locale, _) {
            return MaterialApp(
              locale: locale,
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                if (deviceLocale != null) {
                  for (final supported in supportedLocales) {
                    if (supported.languageCode == deviceLocale.languageCode &&
                        (deviceLocale.countryCode == null ||
                            supported.countryCode == null ||
                            supported.countryCode ==
                                deviceLocale.countryCode)) {
                      return supported;
                    }
                  }
                  for (final supported in supportedLocales) {
                    if (supported.languageCode == deviceLocale.languageCode) {
                      return supported;
                    }
                  }
                }
                return const Locale('en');
              },
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(builder: (context) => Text(context.l10n.appTitle)),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Spacetime-Zeichenwerkzeug'), findsOneWidget);

      await LocaleController.setLocale(null);
      await tester.pumpAndSettle();

      expect(find.text('Spacetime Drawing Tool'), findsOneWidget);
    });
  });
}
