import 'dart:ui' show Locale;

import 'package:bahasa_master/features/home/domain/home_banner_content.dart';
import 'package:bahasa_master/features/home/domain/home_dashboard.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('home offer does not present a fixed price', () {
    final banner = homeBannersFor(
      _dashboard(),
      lifetime: false,
      l10n: l10n,
    ).first;

    expect(banner.id, 'lifetime-offer');
    expect(
      banner.description,
      'Your app store shows the local price at checkout.',
    );
    expect(banner.description, isNot(contains('Rp')));
  });

  test('banners only point at destinations that still exist', () {
    const destinations = {'premium', 'learn', 'anki'};
    for (final lifetime in [true, false]) {
      final banners = homeBannersFor(
        _dashboard(),
        lifetime: lifetime,
        l10n: l10n,
      );
      expect(banners, isNotEmpty);
      for (final banner in banners) {
        expect(destinations, contains(banner.action));
      }
    }
  });
}

HomeDashboard _dashboard() => const HomeDashboard(
  isAuthenticated: false,
  dailyGoal: HomeDailyGoal(minutesLearned: 0, targetMinutes: 20, streakDays: 0),
  categories: [],
  tracks: [],
  plans: [
    SubscriptionPlan(
      id: 'lifetime',
      name: 'Lifetime Access',
      billingType: 'lifetime',
      priceIdr: 1499000,
      features: ['All lessons'],
      recommended: true,
    ),
  ],
  achievements: [],
);
