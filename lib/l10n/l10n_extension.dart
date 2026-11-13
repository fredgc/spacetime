import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

class LocaleController {
  static const String _keyLocale = 'app_locale';
  static const Locale autoLocale = Locale('auto');
  static final ValueNotifier<Locale?> currentLocale = ValueNotifier<Locale?>(
    null,
  );

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('en', 'GB'),
    Locale('es'),
    Locale('de'),
    Locale('fr'),
    Locale('lt'),
    Locale('zh'),
    Locale('ja'),
    Locale('pt'),
  ];

  static String languageDisplayName(Locale? locale) {
    if (locale == null) return 'System Default';
    if (locale.languageCode == 'en' && locale.countryCode == 'GB') {
      return 'English (UK)';
    }
    switch (locale.languageCode) {
      case 'en':
        return 'English (US)';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'lt':
        return 'Lietuvių';
      case 'zh':
        return '中文 (简体)';
      case 'ja':
        return '日本語';
      case 'pt':
        return 'Português';
      default:
        return locale.toLanguageTag();
    }
  }

  static String? localeKey(Locale? locale) {
    if (locale == null) return null;
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}_${locale.countryCode!.toLowerCase()}';
    }
    return locale.languageCode;
  }

  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_keyLocale);
      if (code != null && code.isNotEmpty) {
        if (code.contains('_')) {
          final parts = code.split('_');
          currentLocale.value = Locale(parts[0], parts[1]);
        } else if (code.contains('-')) {
          final parts = code.split('-');
          currentLocale.value = Locale(parts[0], parts[1]);
        } else {
          currentLocale.value = Locale(code);
        }
      }
    } catch (_) {}
  }

  static Future<void> setLocale(Locale? locale) async {
    final effective =
        (locale == null ||
            locale == autoLocale ||
            locale.languageCode == 'auto')
        ? null
        : locale;
    currentLocale.value = effective;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (effective == null) {
        await prefs.remove(_keyLocale);
      } else {
        final key =
            effective.countryCode != null && effective.countryCode!.isNotEmpty
            ? '${effective.languageCode}_${effective.countryCode}'
            : effective.languageCode;
        await prefs.setString(_keyLocale, key);
      }
    } catch (_) {}
  }
}

extension L10nX on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('en'));
}

Future<String> loadLocalizedHtmlAsset(
  BuildContext context,
  String baseName,
) async {
  final cleanName = baseName.endsWith('.html')
      ? baseName.substring(0, baseName.length - 5)
      : baseName;
  final locale =
      Localizations.maybeLocaleOf(context) ??
      LocaleController.currentLocale.value;
  if (locale != null) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      final countryKey =
          '${locale.languageCode}_${locale.countryCode!.toLowerCase()}';
      try {
        return await rootBundle.loadString(
          'assets/${cleanName}_$countryKey.html',
        );
      } catch (_) {}
    }
    if (locale.languageCode != 'en') {
      try {
        return await rootBundle.loadString(
          'assets/${cleanName}_${locale.languageCode}.html',
        );
      } catch (_) {}
    }
  }
  return await rootBundle.loadString('assets/$cleanName.html');
}
