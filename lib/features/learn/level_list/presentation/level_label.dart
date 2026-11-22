import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

/// Display label of a course level code. The data layer still uses the legacy
/// level codes (`N5` easiest .. `N1` hardest); learners see BIPA 1..5.
String levelLabel(BuildContext context, String code) {
  final n = int.tryParse(code.replaceFirst('N', ''));
  return context.l10n.learnLevelLabel(n == null ? 1 : 6 - n);
}
