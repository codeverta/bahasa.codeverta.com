import 'package:bahasa_master/core/analytics/analytics_service.dart';
import 'package:bahasa_master/core/storage/shared_preferences_provider.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/home/domain/home_dashboard.dart';
import 'package:bahasa_master/features/home/presentation/controllers/home_controller.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:bahasa_master/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _l10n = lookupAppLocalizations(const Locale('en'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('email login redirects to Home after success', (tester) async {
    final harness = await _createContainer();
    final container = harness.container;
    final repository = harness.repository;
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BahasaMasterApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.navLearn));
    await tester.pumpAndSettle();
    expect(find.text(_l10n.authSignIn), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, _l10n.commonSignIn),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, _l10n.commonSignIn));
    await tester.pumpAndSettle();

    expect(repository.email, 'user@example.com');
    expect(repository.password, 'password123');
    expect(container.read(authControllerProvider).isAuthenticated, isTrue);
    // A free account sees the skippable Lifetime offer first.
    expect(find.byKey(const Key('lifetime-offer-close')), findsOneWidget);
    await tester.tap(find.byKey(const Key('lifetime-offer-close')));
    await tester.pumpAndSettle();
    expect(find.text(_l10n.authSignIn), findsNothing);
    expect(find.byKey(const Key('home-greeting')), findsOneWidget);
  });

  testWidgets('failed email login stays on login and shows the error', (
    tester,
  ) async {
    final harness = await _createContainer(
      failure: const AuthException('Incorrect email or password.'),
    );
    final container = harness.container;
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BahasaMasterApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n.navLearn));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, _l10n.commonSignIn),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, _l10n.commonSignIn));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.authSignIn), findsOneWidget);
    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(container.read(authControllerProvider).isAuthenticated, isFalse);
  });
}

Future<({ProviderContainer container, _FakeAuthRepository repository})>
_createContainer({AuthException? failure}) async {
  SharedPreferences.setMockInitialValues({'is_first_time': false});
  final preferences = await SharedPreferences.getInstance();
  final repository = _FakeAuthRepository(preferences, failure: failure);
  final authController = AuthController(repository, null);
  await authController.restoreSession();

  return (
    container: ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        analyticsBootstrapProvider.overrideWith((ref) {}),
        authControllerProvider.overrideWith((ref) => authController),
        homeDashboardProvider.overrideWith((ref) async => _dashboard),
      ],
    ),
    repository: repository,
  );
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(SharedPreferences preferences, {this.failure})
    : super(Dio(), preferences);

  final AuthException? failure;
  String? email;
  String? password;

  @override
  bool get hasStoredSession => false;

  @override
  Future<AuthenticatedUser> loginWithEmail(
    String email,
    String password,
  ) async {
    this.email = email;
    this.password = password;
    final error = failure;
    if (error != null) throw error;
    return const AuthenticatedUser(
      id: 'test-user',
      displayName: 'Test User',
      email: 'user@example.com',
    );
  }
}

const _dashboard = HomeDashboard(
  isAuthenticated: true,
  profile: HomeProfile(
    id: 'test-user',
    displayName: 'Test User',
    email: 'user@example.com',
    target: 'JLPT N3',
    level: 3,
    xp: 0,
    streakDays: 0,
    tier: 'free',
    isLifetime: false,
  ),
  dailyGoal: HomeDailyGoal(minutesLearned: 0, targetMinutes: 20, streakDays: 0),
  categories: [],
  tracks: [],
  plans: [],
  achievements: [],
);
