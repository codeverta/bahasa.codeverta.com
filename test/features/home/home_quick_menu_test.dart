import 'package:bahasa_master/features/home/presentation/widgets/home_quick_menu.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<void> pumpMenu(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Padding(padding: EdgeInsets.all(20), child: HomeQuickMenu()),
          ),
        ),
        GoRoute(
          path: '/anki',
          builder: (context, state) =>
              const Scaffold(body: Text('destination /anki')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the Anki item and nothing for removed features', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpMenu(tester);
    expect(find.byKey(const Key('home-quick-anki')), findsOneWidget);
    for (final id in ['jft', 'nat', 'manga', 'ssw', 'jobs', 'map', 'news']) {
      expect(find.byKey(Key('home-quick-$id')), findsNothing);
    }
    expect(find.byKey(const Key('home-quick-premium')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('anki opens /anki', (tester) async {
    await pumpMenu(tester);
    await tester.tap(find.byKey(const Key('home-quick-anki')));
    await tester.pumpAndSettle();
    expect(find.text('destination /anki'), findsOneWidget);
  });

  test('icons use theme colors and contain no unresolved placeholders', () {
    final svg = homeQuickMenuSvg(
      'anki',
      color: const Color(0xFF112233),
      accent: const Color(0xFFD7263D),
      surface: const Color(0xFFFFFFFF),
    );
    expect(svg, contains('#112233'));
    expect(svg, isNot(contains('{')));
    expect(svg.length, greaterThan(200));
  });
}
