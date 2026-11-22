import 'dart:ui';

import 'package:bahasa_master/core/localization/app_language.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer _container(Locale device) {
  final container = ProviderContainer(
    overrides: [deviceLocaleProvider.overrideWithValue(device)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('unsupported device languages fall back to English', () {
    for (final device in const [
      Locale('id', 'ID'),
      Locale('ja', 'JP'),
      Locale('fr'),
    ]) {
      expect(_container(device).read(appLanguageProvider), const Locale('en'));
    }
  });

  test('English devices keep their region for formatting only', () {
    final container = _container(const Locale('en', 'GB'));
    expect(container.read(appLanguageProvider), const Locale('en'));
    expect(
      container.read(appPresentationLocaleProvider),
      const Locale('en', 'GB'),
    );
    expect(
      container.read(appSupportedLocalesProvider),
      contains(const Locale('en', 'GB')),
    );
  });

  test('appL10n resolves without a BuildContext', () {
    expect(appL10n(const Locale('id')).localeName, 'en');
    expect(appL10n(const Locale('en', 'US')).localeName, 'en');
  });

  test('supported locales come from the generated class', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
  });
}
