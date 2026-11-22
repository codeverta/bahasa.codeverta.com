import 'package:bahasa_master/core/analytics/analytics_service.dart';
import 'package:bahasa_master/core/storage/shared_preferences_provider.dart';
import 'package:bahasa_master/core/theme/app_theme.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/home/domain/home_dashboard.dart';
import 'package:bahasa_master/features/home/presentation/controllers/home_controller.dart';
import 'package:bahasa_master/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:bahasa_master/features/profile/data/gamification_repository.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:bahasa_master/main.dart';
import 'package:bahasa_master/shared/presentation/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _l10n = lookupAppLocalizations(const Locale('en'));

void main() {
  testWidgets('first launch redirects to onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          analyticsBootstrapProvider.overrideWith((ref) {}),
        ],
        child: const BahasaMasterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_l10n.onboardingJourneyTitle), findsOneWidget);
  });

  testWidgets('main navigation changes the active tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          authControllerProvider.overrideWith(
            (ref) => AuthController.test(
              const AuthenticationState.authenticated(
                AuthenticatedUser(
                  id: 'test-user',
                  displayName: 'Test User',
                  email: 'test@example.com',
                ),
              ),
            ),
          ),
          homeDashboardProvider.overrideWith((ref) async => _dashboard),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: const MainScaffold(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lifetime dari API'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Lifetime dari API'),
        matching: find.byType(HomeBannerCarousel),
      ),
      findsOneWidget,
    );
    expect(find.text('Target harian'), findsNothing);
    final homeScroll = find
        .descendant(
          of: find.byKey(const PageStorageKey('dashboard-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    // Beranda opens features from the quick menu.
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-quick-anki')),
      150,
      scrollable: homeScroll,
    );
    expect(find.byKey(const Key('home-quick-anki')), findsOneWidget);
    expect(find.byKey(const Key('home-quick-jobs')), findsNothing);

    await tester.tap(find.text(_l10n.navLearn));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.learnChooseA), findsOneWidget);
    expect(find.text('Anki · Flashcards'), findsNothing);

    await tester.tap(find.text(_l10n.navProfile));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.profileGamification), findsOneWidget);
  });

  testWidgets('home premium offer is hidden for lifetime subscribers', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          authControllerProvider.overrideWith(
            (ref) => AuthController.test(
              const AuthenticationState.authenticated(
                AuthenticatedUser(
                  id: 'lifetime-user',
                  displayName: 'Lifetime User',
                  email: 'lifetime@example.com',
                  isLifetime: true,
                ),
              ),
            ),
          ),
          homeDashboardProvider.overrideWith((ref) async => _dashboard),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: const MainScaffold(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BAHASA PREMIUM'), findsNothing);
    expect(find.text(_l10n.learnViewPlans), findsNothing);
  });

  testWidgets(
    'verified purchase hides home and profile offers without restart',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final auth = _PurchaseAuthController();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            authControllerProvider.overrideWith((ref) => auth),
            homeDashboardProvider.overrideWith((ref) async => _dashboard),
            gamificationProvider.overrideWith((ref) async => _gamification),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            home: const MainScaffold(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      var carousel = tester.widget<HomeBannerCarousel>(
        find.byType(HomeBannerCarousel),
      );
      expect(
        carousel.banners.where((banner) => banner.action == 'premium'),
        hasLength(1),
      );
      expect(
        carousel.banners.first.description,
        _l10n.homeBannerOfferDescription,
      );
      await tester.tap(find.text(_l10n.navProfile));
      await tester.pumpAndSettle();
      final profileScroll = find
          .descendant(
            of: find.byKey(const PageStorageKey('profile-scroll')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text(_l10n.commonLifetimeAccess),
        150,
        scrollable: profileScroll,
      );
      expect(find.text(_l10n.commonLifetimeAccess), findsOneWidget);

      auth.subscribe();
      await tester.pumpAndSettle();
      expect(find.text(_l10n.commonLifetimeAccess), findsNothing);
      await tester.tap(find.text(_l10n.navHome));
      await tester.pumpAndSettle();
      carousel = tester.widget<HomeBannerCarousel>(
        find.byType(HomeBannerCarousel),
      );
      expect(
        carousel.banners.where((banner) => banner.action == 'premium'),
        isEmpty,
      );
      expect(carousel.banners.map((banner) => banner.id), ['learn', 'anki']);
      expect(find.text('Lifetime dari API'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('guest is redirected to login after tapping a feature', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'is_first_time': false});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          analyticsBootstrapProvider.overrideWith((ref) {}),
          homeDashboardProvider.overrideWith((ref) async => _dashboard),
        ],
        child: const BahasaMasterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-greeting')), findsOneWidget);
    await tester.tap(find.text(_l10n.navLearn));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.authSignIn), findsOneWidget);
  });
}

const _dashboard = HomeDashboard(
  isAuthenticated: true,
  profile: HomeProfile(
    id: 'test-user',
    displayName: 'Test User',
    email: 'test@example.com',
    target: 'JLPT N3',
    level: 3,
    xp: 1200,
    streakDays: 7,
    tier: 'free',
    isLifetime: false,
  ),
  dailyGoal: HomeDailyGoal(
    minutesLearned: 12,
    targetMinutes: 20,
    streakDays: 7,
  ),
  banners: [
    HomeBanner(
      id: 'learn',
      title: 'Materi belajar',
      description: 'Pelajari bahasa Jepang.',
      imageUrl: '',
      action: 'learn',
      buttonLabel: 'Buka materi',
    ),
  ],
  categories: [
    LearningCategory(
      id: 'vocabulary',
      name: 'Vocabulary API',
      description: 'Kosakata',
      lessonCount: 240,
      requiredTier: 'free',
    ),
  ],
  tracks: [
    LearningTrack(
      id: 'jlpt-n5',
      system: 'JLPT',
      level: 'N5',
      title: 'JLPT N5 Foundation',
      description: 'Fondasi',
      progress: 40,
      requiredTier: 'free',
    ),
  ],
  plans: [
    SubscriptionPlan(
      id: 'lifetime',
      name: 'Lifetime dari API',
      billingType: 'lifetime',
      priceIdr: 1499000,
      features: ['Semua materi'],
      recommended: true,
    ),
  ],
  achievements: [
    Achievement(
      id: 'first',
      name: 'First Step API',
      description: 'Selesaikan pelajaran',
      icon: 'footprints',
      progress: 0,
      target: 1,
    ),
  ],
);

class _PurchaseAuthController extends AuthController {
  _PurchaseAuthController()
    : super.test(
        const AuthenticationState.authenticated(
          AuthenticatedUser(
            id: 'test-user',
            displayName: 'Test User',
            email: 'test@example.com',
          ),
        ),
      );
  void subscribe() {
    state = const AuthenticationState.authenticated(
      AuthenticatedUser(
        id: 'test-user',
        displayName: 'Test User',
        email: 'test@example.com',
        isLifetime: true,
      ),
    );
  }
}

const _gamification = GamificationSummary(
  xp: 0,
  level: 1,
  levelXp: 0,
  nextLevelXp: 100,
  streakDays: 0,
  bestStreak: 0,
  lessonsCompleted: 0,
  examsCompleted: 0,
  activeDays: 0,
  minutesToday: 0,
  achievements: [],
);
