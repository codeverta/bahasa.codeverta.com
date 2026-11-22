import 'package:bahasa_master/core/offline/network_status.dart';
import 'package:bahasa_master/core/theme/app_theme.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/learn/level_list/data/level_list_repository.dart';
import 'package:bahasa_master/features/learn/level_list/presentation/grammar_level_list.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeRepository extends LevelListRepository {
  _FakeRepository() : super(Dio());

  @override
  Future<List<GrammarListItem>> grammar(String level) async => const [
    GrammarListItem(
      lessonId: 'g1',
      lessonTitle: 'Dasar',
      lessonNumber: 1,
      pattern: 'は',
      meaning: 'penanda topik',
      formation: 'Nomina + は',
      explanation: 'Menandai topik kalimat.',
      commonMistake: 'Tertukar dengan が.',
      examples: [
        LevelListExample(
          japanese: '私は学生です。',
          reading: 'わたしはがくせいです。',
          meaning: 'Saya pelajar.',
        ),
      ],
    ),
    GrammarListItem(
      lessonId: 'g2',
      lessonTitle: 'Kepemilikan',
      lessonNumber: 2,
      pattern: 'の',
      meaning: 'milik',
      formation: 'Nomina + の + Nomina',
      explanation: '',
      commonMistake: '',
      examples: [],
    ),
  ];
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required _FakeRepository repository,
  bool lifetime = false,
  bool offline = false,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const Scaffold(body: Text('premium')),
      ),
      GoRoute(
        path: '/learn/grammar/lessons/:id',
        builder: (context, state) => const Scaffold(body: Text('lesson')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        levelListRepositoryProvider.overrideWithValue(repository),
        offlineProvider.overrideWithValue(offline),
        authControllerProvider.overrideWith(
          (ref) => AuthController.test(
            AuthenticationState.authenticated(
              AuthenticatedUser(
                id: 'learner',
                displayName: 'Learner',
                email: 'learner@example.test',
                isLifetime: lifetime,
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        // The real theme: its full-width button defaults once blanked the
        // list, which the default test theme could not catch.
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('grammar list renders items and search filters', (tester) async {
    await _pump(
      tester,
      const GrammarLevelList(level: 'N5'),
      repository: _FakeRepository(),
    );
    expect(find.text('2 grammar patterns • BIPA 1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('grammar-list-item-g1-は')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grammar-list-item-g2-の')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('grammar-list-search-N5')),
      'milik',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('grammar-list-item-g1-は')), findsNothing);
    expect(
      find.byKey(const ValueKey('grammar-list-item-g2-の')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('grammar-list-search-N5')),
      'zzz',
    );
    await tester.pumpAndSettle();
    expect(find.text('No results.'), findsOneWidget);
  });

  testWidgets('grammar item opens a sheet with formation and lesson button', (
    tester,
  ) async {
    await _pump(
      tester,
      const GrammarLevelList(level: 'N5'),
      repository: _FakeRepository(),
    );
    await tester.tap(find.byKey(const ValueKey('grammar-list-item-g1-は')));
    await tester.pumpAndSettle();
    expect(find.text('Formation'), findsOneWidget);
    expect(find.text('Nomina + は'), findsOneWidget);
    expect(find.text('Common mistake'), findsOneWidget);
    expect(find.text('私は学生です。'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('level-list-open-lesson')));
    await tester.pumpAndSettle();
    expect(find.text('lesson'), findsOneWidget);
  });
}
