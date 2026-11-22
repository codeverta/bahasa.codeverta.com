import 'package:bahasa_master/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:bahasa_master/l10n/app_localizations.dart';

/// Short accessor for the generated localizations: `context.l10n.homeTitle`.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
