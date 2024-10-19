import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/language_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationManager {
  static final LocalizationManager instance = LocalizationManager._();
  LocalizationManager._();

  late AppLocalizations _localization;

  AppLocalizations get appLocalization => _localization;

  void setLocalization(final BuildContext context) {
    _localization = AppLocalizations.of(context)!;
  }

  Future<void> changeLocale(final Locale newLocale, final WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);
    ref.read(localeProvider.notifier).state = newLocale;
  }

  Future<void> loadSavedLocale(final WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      ref.read(localeProvider.notifier).state = Locale(languageCode);
    } else {
      final Locale deviceLocale = PlatformDispatcher.instance.locale;
      const List<Locale> supportedLocales = AppLocalizations.supportedLocales;
      if (supportedLocales.contains(deviceLocale)) {
        ref.read(localeProvider.notifier).state = deviceLocale;
      } else {
        ref.read(localeProvider.notifier).state = const Locale('en');
      }
    }
  }

  // Add this method to get supported locales
  List<Locale> getSupportedLocales() {
    return AppLocalizations.supportedLocales;
  }

  // Add this method to get the native name of a language
  String getLanguageName(final Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
    // Add more cases for other supported languages
      default:
        return locale.languageCode;
    }
  }
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
