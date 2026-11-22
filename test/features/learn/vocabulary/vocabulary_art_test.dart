import 'package:bahasa_master/core/offline/learning_asset.dart';
import 'package:bahasa_master/features/learn/vocabulary/presentation/widgets/vocabulary_art.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('failed vocabulary image keeps the cropped panel visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningAssetProvider.overrideWith((ref, url) async => null),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 88,
                height: 88,
                child: VocabularyArt(
                  asset: 'assets/images/vocabulary/missing.webp',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byIcon(Icons.image_not_supported_outlined).hitTestable(),
      findsOneWidget,
    );
  });
}
