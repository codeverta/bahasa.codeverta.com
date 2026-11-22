import 'package:bahasa_master/features/home/domain/home_banner_content.dart';
import 'package:bahasa_master/features/home/domain/home_dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English home offer does not present the Indonesian-only price', () {
    final banner = homeBannersFor(
      _dashboard(),
      lifetime: false,
      english: true,
    ).first;

    expect(banner.id, 'lifetime-offer');
    expect(
      banner.description,
      'Your app store shows the local price at checkout.',
    );
    expect(banner.description, isNot(contains('Rp')));
  });

  test('Indonesian home offer keeps its configured price', () {
    final banner = homeBannersFor(_dashboard(), lifetime: false).first;

    expect(banner.description, 'All lessons • Rp1.499.000');
  });

  test('banners only point at destinations that still exist', () {
    const destinations = {'premium', 'learn', 'anki'};
    for (final lifetime in [true, false]) {
      final banners = homeBannersFor(_dashboard(), lifetime: lifetime);
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
