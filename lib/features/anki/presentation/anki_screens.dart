import 'dart:async';

import 'package:bahasa_master/core/ads/ad_widgets.dart';
import 'package:bahasa_master/core/ads/ads_config.dart';
import 'package:bahasa_master/core/ads/ads_controller.dart';
import 'package:bahasa_master/core/ads/completion_ads.dart';
import 'package:bahasa_master/core/gamification/xp_gain.dart';
import 'package:bahasa_master/core/localization/region_formatters.dart';
import 'package:bahasa_master/core/storage/recent_access.dart';
import 'package:bahasa_master/core/unlock/unlock_repository.dart';
import 'package:bahasa_master/core/unlock/unlock_sheet.dart';
import 'package:bahasa_master/features/anki/data/anki_repository.dart';
import 'package:bahasa_master/features/anki/domain/anki_models.dart';
import 'package:bahasa_master/features/anki/presentation/anki_controller.dart';
import 'package:bahasa_master/features/anki/presentation/anki_deck_media.dart';
import 'package:bahasa_master/features/anki/presentation/anki_swipe_card.dart';
import 'package:bahasa_master/features/anki/presentation/anki_transfer_actions.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:bahasa_master/shared/presentation/widgets/explore_feature_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

String ankiDeckPath(String id) => '/anki/decks/${Uri.encodeComponent(id)}';
String ankiStudyPath(String id) => '${ankiDeckPath(id)}/study';
String ankiCount(int value) => NumberFormat.decimalPattern().format(value);

class AnkiEntryCard extends StatelessWidget {
  const AnkiEntryCard({super.key});
  @override
  Widget build(BuildContext context) => ExploreFeatureCard(
    title: 'Anki · Flashcards',
    eyebrow: context.l10n.ankiReviewA,
    description: context.l10n.ankiChooseA,
    asset: 'assets/images/explore/anki-flashcards.webp',
    color: const Color(0xFF145B60),
    icon: Icons.style_rounded,
    onTap: () => context.push('/anki'),
  );
}

class AnkiDeckListScreen extends ConsumerStatefulWidget {
  const AnkiDeckListScreen({super.key});
  @override
  ConsumerState<AnkiDeckListScreen> createState() => _DeckListState();
}

class _DeckListState extends ConsumerState<AnkiDeckListScreen> {
  String query = '';
  String? category;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anki'),
        actions: [
          IconButton(
            key: const Key('anki-import'),
            tooltip: context.l10n.ankiImportDeck,
            onPressed: () async {
              if (!ref.read(authControllerProvider).isAuthenticated) {
                await context.push('/login');
                return;
              }
              final id = await context.push<String>('/anki/import');
              if (id != null && context.mounted) {
                ref.invalidate(ankiDecksProvider);
                ref.read(recentAccessProvider('anki').notifier).record(id);
                await context.push(ankiDeckPath(id));
              }
            },
            icon: const Icon(Icons.file_upload_outlined),
          ),
          IconButton(
            tooltip: context.l10n.ankiDataSources,
            onPressed: () => _credits(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: ref
          .watch(ankiDecksProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AnkiErrorView(
              error: error,
              onRetry: () => ref.invalidate(ankiDecksProvider),
            ),
            data: (decks) {
              final categories = decks.map((d) => d.category).toSet().toList()
                ..sort();
              final filtered = decks
                  .where(
                    (d) =>
                        (category == null || d.category == category) &&
                        '${d.title} ${d.id} ${d.description} ${d.originalName}'
                            .toLowerCase()
                            .contains(query.trim().toLowerCase()),
                  )
                  .toList();
              final recent = ref.watch(recentAccessProvider('anki'));
              filtered.sort((a, b) {
                final byRecent = compareRecent(recent, a.id, b.id);
                if (byRecent != 0) return byRecent;
                return a.title.compareTo(b.title);
              });
              final premium = ref.watch(
                authControllerProvider.select((s) => s.isAuthenticated),
              );
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverList.list(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: colors.secondary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.style_rounded,
                                color: colors.secondary,
                                size: 38,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.ankiALittle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                context.l10n.ankiChooseADeck,
                                style: const TextStyle(height: 1.6),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _Tag(
                                    context.l10n.ankiDeckCount(decks.length),
                                  ),
                                  _Tag(
                                    context.l10n.ankiCardCount(
                                      decks.fold<int>(
                                        0,
                                        (n, d) => n + d.cardCount,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          key: const Key('anki-search'),
                          onChanged: (value) => setState(() => query = value),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            labelText: context.l10n.ankiSearchDecks,
                            hintText: context.l10n.ankiGreetingsFood,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final value in <String?>[
                                null,
                                ...categories,
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    selected: category == value,
                                    label: Text(
                                      value ?? context.l10n.ankiCategoryAll,
                                    ),
                                    onSelected: (_) =>
                                        setState(() => category = value),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.l10n.ankiDeckCount(filtered.length),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(context.l10n.ankiNoDecks),
                          ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final deck = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              key: Key('anki-deck-${deck.id}'),
                              contentPadding: const EdgeInsets.all(16),
                              leading: const _DeckIcon(),
                              title: Text(
                                deck.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.ankiDeckListMeta(
                                        deck.category,
                                        deck.available
                                            ? deck.cardCount
                                            : deck.sourceCount,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (!deck.available)
                                      _Tag(context.l10n.ankiSavedData)
                                    else if (deck.premium && !premium)
                                      _Tag(context.l10n.commonLifetimeAccess)
                                    else
                                      _Tag(context.l10n.ankiReadyTo),
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                ref
                                    .read(recentAccessProvider('anki').notifier)
                                    .record(deck.id);
                                unawaited(context.push(ankiDeckPath(deck.id)));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class AnkiDeckDetailScreen extends ConsumerWidget {
  const AnkiDeckDetailScreen({required this.deckId, super.key});
  final String deckId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.ankiAboutThis)),
    body: ref
        .watch(ankiDeckProvider(deckId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AnkiErrorView(
            error: error,
            onRetry: () => ref.invalidate(ankiDeckProvider(deckId)),
          ),
          data: (deck) {
            final signedIn = ref.watch(
              authControllerProvider.select((s) => s.isAuthenticated),
            );
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: _DeckIcon(size: 72),
                ),
                const SizedBox(height: 20),
                Text(
                  deck.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(deck.category),
                    if (deck.personal) _Tag(context.l10n.ankiPersonalDeck),
                    _Tag(context.l10n.ankiCardsReady(deck.cardCount)),
                    if (deck.premium) _Tag(context.l10n.commonLifetimeAccess),
                  ],
                ),
                const SizedBox(height: 24),
                if (deck.available && !deck.locked)
                  AnkiExportButton(deckId: deck.id),
                if (deck.personal)
                  TextButton.icon(
                    onPressed: () => deleteAnkiDeck(context, ref, deck.id),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(context.l10n.ankiDeletePersonal),
                  ),
                const SizedBox(height: 16),
                _Section(
                  title: context.l10n.ankiAboutThis,
                  children: [
                    Text(deck.description, style: const TextStyle(height: 1.7)),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: context.l10n.ankiHowTo,
                  children: [
                    Text(
                      deck.instructions,
                      style: const TextStyle(height: 1.7),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.ankiEachSession,
                      style: const TextStyle(height: 1.7),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (deck.available)
                  _Section(
                    title: context.l10n.ankiYourStudy,
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        children: [
                          _Stat(ankiCount(deck.seen), context.l10n.ankiStudied),
                          _Stat(ankiCount(deck.due), context.l10n.ankiDueFor),
                          _Stat(
                            ankiCount(deck.newCards),
                            context.l10n.ankiNewCards,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .1),
                        color: Theme.of(context).colorScheme.primary,
                        value: deck.cardCount == 0
                            ? 0
                            : deck.seen / deck.cardCount,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        signedIn
                            ? context.l10n.ankiYourSchedule
                            : context.l10n.ankiSignIn,
                      ),
                      if (deck.nextDue != null && deck.due == 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.ankiNextReview(
                            _date(context, deck.nextDue!),
                          ),
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 20),
                if (!deck.available)
                  _Section(
                    title: context.l10n.ankiDeckAvailability,
                    children: [
                      Text(
                        deck.unavailableReason,
                        style: const TextStyle(height: 1.7),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    key: const Key('anki-start'),
                    onPressed: () async {
                      if (!signedIn) {
                        await context.push<bool>('/login');
                        return;
                      }
                      if (deck.locked) {
                        // A locked built-in deck opens with one ad or
                        // Lifetime Access; imported decks need Lifetime.
                        if (deck.personal) {
                          await context.push('/premium');
                          return;
                        }
                        final opened = await showUnlockSheet(
                          context,
                          UnlockTarget('anki', deck.id),
                        );
                        if (!opened) return;
                        ref.invalidate(ankiDeckProvider(deckId));
                        if (!context.mounted) return;
                      }
                      ref
                          .read(recentAccessProvider('anki').notifier)
                          .record(deck.id);
                      await context.push(ankiStudyPath(deck.id));
                      if (context.mounted) {
                        ref.invalidate(ankiDeckProvider(deckId));
                      }
                    },
                    icon: Icon(
                      !signedIn
                          ? Icons.login_rounded
                          : deck.locked
                          ? Icons.lock_outline_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      !signedIn
                          ? context.l10n.ankiSignInTo
                          : deck.locked
                          ? context.l10n.ankiUnlockWith
                          : deck.due > 0
                          ? context.l10n.ankiStartReview
                          : context.l10n.commonStartLearning,
                    ),
                  ),
                if (deck.preview.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  Text(
                    context.l10n.ankiDeckPreview,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(context.l10n.ankiThePreview),
                  const SizedBox(height: 12),
                  for (final card in deck.preview)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _Section(
                        title: card.front,
                        children: [
                          if (card.imageUrl.isNotEmpty)
                            AnkiDeckImage(card.imageUrl),
                          if (card.audioUrl.isNotEmpty)
                            AnkiDeckAudio(card.audioUrl),
                          _Answers(answers: card.answers),
                          if (card.meaning.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              card.meaning,
                              style: const TextStyle(height: 1.6),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 18),
                _Section(
                  title: context.l10n.ankiDataSource,
                  children: [
                    Text(
                      context.l10n.ankiOriginalDeck(deck.originalName),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      deck.meaningLanguage,
                      style: const TextStyle(height: 1.6),
                    ),
                    if (deck.originalDescription.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        deck.originalDescription,
                        style: const TextStyle(height: 1.6),
                      ),
                    ],
                    if (deck.skippedCount > 0) ...[
                      const SizedBox(height: 10),
                      Text(
                        context.l10n.ankiSourceEntries(
                          ankiCount(deck.sourceCount),
                          ankiCount(deck.skippedCount),
                        ),
                        style: const TextStyle(height: 1.6),
                      ),
                    ],
                    if (const [
                      'http',
                      'https',
                    ].contains(Uri.tryParse(deck.sourceUrl)?.scheme))
                      TextButton.icon(
                        onPressed: () async {
                          var opened = false;
                          try {
                            opened = await launchUrl(
                              Uri.parse(deck.sourceUrl),
                              mode: LaunchMode.externalApplication,
                            );
                          } on Object {
                            opened = false;
                          }
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.ankiCouldNotOpen),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(context.l10n.ankiViewDeck),
                      ),
                    TextButton.icon(
                      onPressed: () => _credits(context),
                      icon: const Icon(Icons.info_outline_rounded),
                      label: Text(context.l10n.ankiDataSources),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
  );
}

class AnkiStudyScreen extends ConsumerWidget {
  const AnkiStudyScreen({required this.deckId, super.key});
  final String deckId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ankiStudyProvider(deckId));
    final controller = ref.read(ankiStudyProvider(deckId).notifier);
    final pendingSync = ref.watch(ankiRepositoryProvider).hasPendingReviews;
    final card = state.current;
    final colors = Theme.of(context).colorScheme;
    final minCards =
        ref.watch(adsReadyProvider).valueOrNull?.ankiSessionMinCards ??
        defaultAnkiSessionMinCards;
    final sessionCounts =
        state.session != null &&
        (state.position >= minCards || (card == null && state.position > 0));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.session?.title ?? context.l10n.ankiFlashcardStudy,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (sessionCounts)
            CompletionAdBoundary(
              kind: CompletionKind.anki,
              completionKey: 'anki:$deckId',
            ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.session == null
          ? AnkiErrorView(
              error: state.error ?? context.l10n.ankiStudySession,
              onRetry: controller.load,
            )
          : card == null
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(Icons.task_alt_rounded, size: 72, color: colors.primary),
                const SizedBox(height: 24),
                Text(
                  state.position == 0
                      ? context.l10n.ankiNoCards
                      : context.l10n.ankiSessionComplete,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pendingSync
                      ? context.l10n.ankiSessionRatedPending(state.position)
                      : context.l10n.ankiSessionRatedSaved(state.position),
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.7),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: controller.load,
                  child: Text(context.l10n.ankiCheckThe),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.go(ankiDeckPath(deckId)),
                  child: Text(context.l10n.ankiBackTo),
                ),
                if (state.xpEarned > 0) ...[
                  const SizedBox(height: 16),
                  XpResultBadge(
                    gain: XpGain(awarded: state.xpEarned, total: 0, streak: 0),
                  ),
                ],
                if (state.position > 0) ...[
                  const SizedBox(height: 16),
                  const AdBannerSlot(
                    placement: BannerAdPlacement.practiceResult,
                  ),
                ],
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (pendingSync) ...[
                  Text(context.l10n.ankiRatingsSaved),
                  const SizedBox(height: 12),
                ],
                Text(
                  context.l10n.ankiCardPosition(
                    state.position + 1,
                    state.session!.cards.length,
                  ),
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  backgroundColor: colors.primary.withValues(alpha: .1),
                  color: colors.primary,
                  value: state.position / state.session!.cards.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(8),
                ),
                if (state.session!.instructions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.session!.instructions,
                    style: const TextStyle(height: 1.6),
                  ),
                ],
                const SizedBox(height: 24),
                _AnimatedHeight(
                  child: AnkiSwipeCardStack(
                    // A fresh stack per card resets the drag offset to centre.
                    key: ValueKey('anki-stack-${state.position}'),
                    // Swipe rates the card, so it only works once the answer
                    // is visible, the same rule as the rating buttons. During
                    // an error the retry button keeps the original rating.
                    swipeEnabled:
                        state.revealed && !state.saving && state.error == null,
                    onTap: state.saving || state.pendingRating != null
                        ? null
                        : state.revealed
                        ? controller.conceal
                        : controller.reveal,
                    rightLabel: context.l10n.ankiGood,
                    leftLabel: context.l10n.ankiAgain,
                    onSwiped: (direction) => controller.rate(
                      direction == AnkiSwipeDirection.right ? 'good' : 'again',
                    ),
                    next: state.position + 1 < state.session!.cards.length
                        ? _NextCardPreview(
                            card: state.session!.cards[state.position + 1],
                            key: ValueKey('anki-next-${state.position + 1}'),
                          )
                        : null,
                    child: _StudyCardFace(card: card, revealed: state.revealed),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.revealed
                      ? context.l10n.ankiSwipeRight
                      : context.l10n.ankiTapThe,
                  key: const Key('anki-swipe-hint'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (!state.revealed)
                  FilledButton.icon(
                    key: const Key('anki-reveal'),
                    onPressed: controller.reveal,
                    icon: const Icon(Icons.flip_rounded),
                    label: Text(context.l10n.ankiShowAnswer),
                  ),
                if (state.revealed) ...[
                  Text(
                    context.l10n.ankiHowEasily,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (state.error != null) ...[
                    Text(
                      state.error!.message,
                      style: TextStyle(color: colors.error, height: 1.6),
                    ),
                    const SizedBox(height: 12),
                    if (state.error!.status == 409 ||
                        state.error!.status == 401 ||
                        state.error!.status == 402)
                      AnkiErrorView(
                        error: state.error!,
                        onRetry: controller.load,
                      )
                    else
                      FilledButton(
                        onPressed: state.saving
                            ? null
                            : () => controller.rate(state.pendingRating!),
                        child: Text(context.l10n.ankiTrySaving),
                      ),
                  ] else
                    LayoutBuilder(
                      builder: (context, constraints) => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final grade in [
                            ('again', context.l10n.ankiAgain),
                            ('hard', context.l10n.ankiHard),
                            ('good', context.l10n.ankiGood),
                            ('easy', context.l10n.ankiEasy),
                          ])
                            SizedBox(
                              width: (constraints.maxWidth - 10) / 2,
                              child: OutlinedButton(
                                key: Key('anki-rate-${grade.$1}'),
                                onPressed: state.saving
                                    ? null
                                    : () => controller.rate(grade.$1),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 16,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      grade.$2,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      card.intervals[grade.$1] ?? '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (state.saving)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
                const SizedBox(height: 24),
                Text(
                  context.l10n.ankiRateEach,
                  style: TextStyle(
                    height: 1.6,
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class AnkiErrorView extends StatelessWidget {
  const AnkiErrorView({required this.error, required this.onRetry, super.key});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final status = error is AnkiFailure ? (error as AnkiFailure).status : null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 36),
            const SizedBox(height: 14),
            Text(
              error is AnkiFailure
                  ? error.toString()
                  : context.l10n.ankiCouldNotLoad,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.6),
            ),
            const SizedBox(height: 16),
            if (status == 401)
              FilledButton(
                onPressed: () async {
                  await context.push<bool>('/login');
                  if (context.mounted) onRetry();
                },
                child: Text(context.l10n.commonSignIn),
              )
            else if (status == 402)
              FilledButton(
                onPressed: () async {
                  await context.push('/premium');
                  if (context.mounted) onRetry();
                },
                child: Text(context.l10n.commonLifetimeAccess),
              )
            else
              OutlinedButton(
                onPressed: onRetry,
                child: Text(
                  status == 409
                      ? context.l10n.ankiReloadSession
                      : context.l10n.commonRefresh,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

class _DeckIcon extends StatelessWidget {
  const _DeckIcon({this.size = 48});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Icon(
      Icons.style_rounded,
      color: Theme.of(context).colorScheme.secondary,
      size: size * .48,
    ),
  );
}

/// Smoothly resizes when the card flips or the next card moves up. Skipped
/// entirely with reduced motion (AnimatedSize asserts on a zero duration).
class _AnimatedHeight extends StatelessWidget {
  const _AnimatedHeight({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          // The dragged card may lean past the stack's bounds.
          clipBehavior: Clip.none,
          child: child,
        );
}

/// The face of the study card. Text is plain (not selectable) here because
/// selection gestures would swallow the taps that flip the card and the
/// drags that swipe it.
class _StudyCardFace extends StatelessWidget {
  const _StudyCardFace({required this.card, required this.revealed});
  final AnkiCard card;
  final bool revealed;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              revealed
                  ? context.l10n.ankiQuestionAnswer
                  : context.l10n.ankiTryTo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 24),
            if (card.imageUrl.isNotEmpty) AnkiDeckImage(card.imageUrl),
            if (card.audioUrl.isNotEmpty) AnkiDeckAudio(card.audioUrl),
            Text(
              card.front,
              key: const Key('anki-card-front'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: card.front.runes.length > 40 ? 22 : 36,
                fontWeight: FontWeight.w800,
                height: 1.6,
              ),
            ),
            if (revealed) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(),
              ),
              _Answers(
                answers: card.answers,
                selectable: false,
                key: const Key('anki-card-back'),
              ),
              if (card.meaning.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  card.meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.7, fontSize: 16),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// The following card peeking out behind the top card (front only).
class _NextCardPreview extends StatelessWidget {
  const _NextCardPreview({required this.card, super.key});
  final AnkiCard card;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
        child: Column(
          children: [
            Text(
              context.l10n.ankiTryTo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: Text(
                  card.front,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: card.front.runes.length > 40 ? 22 : 36,
                    fontWeight: FontWeight.w800,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Answers extends StatelessWidget {
  const _Answers({required this.answers, this.selectable = true, super.key});
  final List<String> answers;
  final bool selectable;
  @override
  Widget build(BuildContext context) {
    Widget text(String value, TextStyle style, TextAlign align) => selectable
        ? SelectableText(
            value,
            textAlign: align,
            scrollPhysics: const NeverScrollableScrollPhysics(),
            style: style,
          )
        : Text(value, textAlign: align, style: style);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        text(
          answers.take(8).join(' · '),
          TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.7,
            color: Theme.of(context).colorScheme.secondary,
          ),
          TextAlign.center,
        ),
        if (answers.length > 8)
          ExpansionTile(
            title: Text(context.l10n.ankiMoreAnswers(answers.length - 8)),
            children: [
              text(
                answers.skip(8).join(' · '),
                const TextStyle(fontSize: 18, height: 1.7),
                TextAlign.start,
              ),
            ],
          ),
      ],
    );
  }
}

String _date(BuildContext context, DateTime value) =>
    regionalDateTime(value, localeName: appRegionLocaleName(context));

void _credits(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => FractionallySizedBox(
    heightFactor: .8,
    child: Consumer(
      builder: (context, ref, _) => ref
          .watch(ankiCreditsProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AnkiErrorView(
              error: error,
              onRetry: () => ref.invalidate(ankiCreditsProvider),
            ),
            data: (data) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  context.l10n.ankiDataSources,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(data['repository'] as String),
                const SizedBox(height: 12),
                Text(
                  data['notice'] as String,
                  style: const TextStyle(height: 1.6),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.ankiContentLicense,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  data['license'] as String,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  style: const TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
    ),
  ),
);
