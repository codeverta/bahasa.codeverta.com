import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/cupertino.dart' show BuildContext;
import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Language used when the device language is not one of
/// [AppLocalizations.supportedLocales].
const fallbackAppLocale = Locale('en');

/// Picks the UI language for [device] among the generated supported locales.
///
/// Only the language code is matched; the device region stays available for
/// date and number formatting through [appPresentationLocaleProvider].
Locale resolveAppLocale(Locale device) {
  for (final supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == device.languageCode) {
      return Locale(supported.languageCode);
    }
  }
  return fallbackAppLocale;
}

/// Localized strings for code that has no [BuildContext], such as
/// controllers, repositories and notifications.
AppLocalizations appL10n([Locale? device]) => lookupAppLocalizations(
  resolveAppLocale(device ?? PlatformDispatcher.instance.locale),
);

final deviceLocaleProvider = Provider<Locale>(
  (ref) => PlatformDispatcher.instance.locale,
);

/// The UI language: the device language when supported, otherwise English.
/// Adding a locale only needs a new ARB file in `lib/l10n`.
final appLanguageProvider = Provider<Locale>(
  (ref) => resolveAppLocale(ref.watch(deviceLocaleProvider)),
);

/// Localized strings for the current [appLanguageProvider], for providers and
/// controllers.
final appLocalizationsProvider = Provider<AppLocalizations>(
  (ref) => lookupAppLocalizations(ref.watch(appLanguageProvider)),
);

/// Keeps regional formatting from the device while the UI language comes from
/// [appLanguageProvider].
final appPresentationLocaleProvider = Provider<Locale>((ref) {
  final language = ref.watch(appLanguageProvider).languageCode;
  final region = ref.watch(deviceLocaleProvider).countryCode;
  return Locale(language, region);
});

final appSupportedLocalesProvider = Provider<List<Locale>>((ref) {
  final region = ref.watch(deviceLocaleProvider).countryCode;
  return [
    if (region != null && region.isNotEmpty)
      for (final locale in AppLocalizations.supportedLocales)
        Locale(locale.languageCode, region),
    ...AppLocalizations.supportedLocales,
  ];
});
