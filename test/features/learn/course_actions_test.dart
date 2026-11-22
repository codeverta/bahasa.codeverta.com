import 'package:bahasa_master/core/theme/app_theme.dart';
import 'package:bahasa_master/features/anki/presentation/course_anki_button.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> _pump(WidgetTester tester, List<Widget> actions) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Course'), actions: actions),
          body: const SizedBox.shrink(),
        ),
      ),
      GoRoute(
        path: '/anki/decks/:deckId',
        builder: (context, state) =>
            Scaffold(body: Text('deck ${state.pathParameters['deckId']}')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          (ref) => AuthController.test(
            const AuthenticationState.authenticated(
              AuthenticatedUser(
                id: 'learner',
                displayName: 'Learner',
                email: 'learner@example.test',
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('no built-in Anki decks ship yet, so no course maps to a deck', () {
    for (final type in ['vocabulary', 'grammar', 'reading']) {
      for (final level in ['N5', 'N3', 'JFT']) {
        expect(courseAnkiDecks(type, level), isEmpty);
      }
    }
  });

  testWidgets('the course Anki action is hidden while there are no decks', (
    tester,
  ) async {
    await _pump(tester, const [
      CourseAnkiButton(type: 'vocabulary', level: 'N4'),
    ]);
    expect(find.byKey(const ValueKey('course-anki-button')), findsNothing);
  });
}
