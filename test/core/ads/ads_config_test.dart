import 'package:bahasa_master/core/ads/ads_config.dart';
import 'package:bahasa_master/core/ads/ads_controller.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

AuthenticatedUser _user({bool premium = false, bool lifetime = false}) =>
    AuthenticatedUser(
      id: 'u1',
      displayName: 'A',
      email: 'a@example.com',
      isPremium: premium,
      isLifetime: lifetime,
    );

void main() {
  test('missing or malformed config keeps every ad off', () {
    expect(AdsConfig.fromJson(null).enabled, isFalse);
    expect(AdsConfig.fromJson('x').banner.usable, isFalse);
    expect(
      AdsConfig.fromJson(<String, dynamic>{}).quizResultBanner.usable,
      isFalse,
    );
  });

  test('parses server payload', () {
    final config = AdsConfig.fromJson({
      'enabled': true,
      'banner': {'enabled': true, 'unitId': testBannerAdUnitId},
      'quizResultBanner': {'enabled': false, 'unitId': testBannerAdUnitId},
    });
    expect(config.enabled, isTrue);
    expect(config.banner.usable, isTrue);
    expect(config.quizResultBanner.usable, isFalse);
  });

  test('debug builds swap real units for Google test units', () {
    final config = AdsConfig.fromJson({
      'enabled': true,
      'banner': {
        'enabled': true,
        'unitId': 'ca-app-pub-1234567890123456/1234567890',
      },
    }).withTestUnits();
    expect(config.banner.unitId, testBannerAdUnitId);
    expect(config.banner.usable, isTrue);
  });

  test('premium and lifetime users never get ads', () {
    expect(
      adsAllowedFor(auth: AuthenticationState.authenticated(_user())),
      isTrue,
    );
    expect(
      adsAllowedFor(
        auth: AuthenticationState.authenticated(_user(premium: true)),
      ),
      isFalse,
    );
    expect(
      adsAllowedFor(
        auth: AuthenticationState.authenticated(_user(lifetime: true)),
      ),
      isFalse,
    );
    expect(adsAllowedFor(auth: const AuthenticationState.guest()), isTrue);
    expect(adsAllowedFor(auth: const AuthenticationState.checking()), isFalse);
  });
}
