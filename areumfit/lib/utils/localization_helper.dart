import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

class LocalizationHelper {
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  static const List<Locale> locales = [
    Locale('en', 'US'),
    Locale('ko', 'KR'),
  ];

  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
      default:
        return locale.languageCode;
    }
  }
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}