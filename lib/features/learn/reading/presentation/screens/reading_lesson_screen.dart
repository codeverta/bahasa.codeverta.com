import 'package:bahasa_master/core/ads/ad_widgets.dart';
import 'package:bahasa_master/core/ads/ads_config.dart';
import 'package:bahasa_master/core/ads/completion_ads.dart';
import 'package:bahasa_master/core/gamification/xp_gain.dart';
import 'package:bahasa_master/core/settings/display_preferences.dart';
import 'package:bahasa_master/core/unlock/locked_content.dart';
import 'package:bahasa_master/features/ai_chat/data/ai_chat_repository.dart';
import 'package:bahasa_master/features/ai_chat/presentation/ai_chat_sheet.dart';
import 'package:bahasa_master/features/learn/reading/domain/reading_models.dart';
import 'package:bahasa_master/features/learn/reading/presentation/controllers/reading_controller.dart';
import 'package:bahasa_master/features/learn/reading/presentation/widgets/reading_illustration.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingLessonScreen extends ConsumerWidget {
  const ReadingLessonScreen({required this.lessonId, super.key});
  final String lessonId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = readingLessonProvider(lessonId);
    final lesson = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lesson.valueOrNull?.lesson.summary.title ??
              context.l10n.readingReadingStory,
        ),
        actions: [
          AskAiButton(lessonType: AiLessonType.reading, lessonId: lessonId),
        ],
      ),
      body: lesson.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            lockedContentView(e, controller.load) ??
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: controller.load,
                      child: Text(context.l10n.commonRefresh),
                    ),
                  ],
                ),
              ),
            ),
        data: (s) => switch (s.stage) {
          ReadingStage.study => _Study(state: s, controller: controller),
          ReadingStage.quiz => _Quiz(state: s, controller: controller),
          ReadingStage.result => CompletionAdBoundary(
            kind: CompletionKind.lessons,
            completionKey: 'reading:$lessonId',
            child: _Result(
              result: s.result!,
              retry: controller.startQuiz,
              study: controller.studyAgain,
              finish: () => context.pop(),
              busy: s.busy,
              error: s.error,
            ),
          ),
        },
      ),
    );
  }
}

class _Study extends ConsumerStatefulWidget {
  const _Study({required this.state, required this.controller});
  final ReadingState state;
  final ReadingController controller;
  @override
  ConsumerState<_Study> createState() => _StudyState();
}

class _StudyState extends ConsumerState<_Study> {
  @override
  Widget build(BuildContext context) {
    final displayPreferences = ref.watch(displayPreferencesProvider);
    final translation = displayPreferences.translation;
    final state = widget.state;
    final controller = widget.controller;
    final page = state.lesson.pages[state.pageIndex];
    final last = state.pageIndex == state.lesson.pages.length - 1;
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        LinearProgressIndicator(
          value: (state.pageIndex + 1) / state.lesson.pages.length,
          minHeight: 5,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
        ),
        Expanded(
          child: ListView(
            key: ValueKey('reading-page-${state.pageIndex}'),
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                context.l10n.readingSceneCounter(
                  state.lesson.summary.chapter,
                  state.pageIndex + 1,
                  state.lesson.pages.length,
                ),
                key: const Key('reading-page-counter'),
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ReadingIllustration(
                  asset: page.imageAsset,
                  url: page.imageUrl,
                  panel: page.imagePanel,
                  description: page.imageDescription,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  FilterChip(
                    label: Text(context.l10n.commonTranslation),
                    selected: translation,
                    showCheckmark: false,
                    selectedColor: colors.secondary,
                    labelStyle: TextStyle(
                      color: translation
                          ? colors.onSecondary
                          : colors.onSurface,
                    ),
                    onSelected: (enabled) => ref
                        .read(displayPreferencesProvider.notifier)
                        .setTranslation(enabled: enabled),
                    avatar: Icon(
                      Icons.language_rounded,
                      size: 18,
                      color: translation ? colors.onSecondary : colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      page.japanese,
                      key: const Key('reading-passage'),
                      style: const TextStyle(
                        fontSize: 23,
                        height: 1.9,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (translation) ...[
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.readingStoryMeaning,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        page.meaning,
                        key: const Key('reading-translation'),
                        style: const TextStyle(fontSize: 16, height: 1.7),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                context.l10n.readingWordsTo,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              for (final word in page.vocabulary) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          word.japanese,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(word.meaning),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        _Footer(
          error: state.error,
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: OutlinedButton(
                  key: const Key('reading-previous'),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: state.busy || state.pageIndex == 0
                      ? null
                      : () => controller.movePage(-1),
                  child: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: Key(last ? 'reading-start-quiz' : 'reading-next-page'),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: state.busy
                      ? null
                      : last
                      ? controller.startQuiz
                      : () => controller.movePage(1),
                  icon: state.busy
                      ? const _Spinner()
                      : Icon(
                          last
                              ? Icons.quiz_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                  label: Text(
                    last
                        ? context.l10n.readingCheckUnderstanding
                        : context.l10n.readingContinueStory,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Quiz extends StatelessWidget {
  const _Quiz({required this.state, required this.controller});
  final ReadingState state;
  final ReadingController controller;
  @override
  Widget build(BuildContext context) {
    final attempt = state.attempt!;
    final q = attempt.questions[state.questionIndex];
    final feedback = state.feedback;
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        LinearProgressIndicator(
          value: (state.questionIndex + 1) / attempt.questions.length,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          minHeight: 6,
        ),
        Expanded(
          child: ListView(
            key: ValueKey(q.id),
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                context.l10n.readingQuestionCounter(
                  state.questionIndex + 1,
                  attempt.questions.length,
                ),
                key: const Key('reading-question-counter'),
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                q.prompt,
                key: const Key('reading-question'),
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(context.l10n.readingReadThe),
                leading: const Icon(Icons.menu_book_rounded),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  Text(
                    state.lesson.pages.map((p) => p.japanese).join('\n\n'),
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              for (final option in q.options) ...[
                Builder(
                  builder: (context) {
                    final selected = state.selection == option.id;
                    final correct = feedback?.correctOptionId == option.id;
                    final color = correct
                        ? Colors.green
                        : selected && feedback != null
                        ? colors.error
                        : selected
                        ? colors.primary
                        : colors.outlineVariant;
                    return Material(
                      color: color.withValues(
                        alpha: selected || correct ? 0.1 : 0.03,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        key: Key('reading-option-${option.id}'),
                        borderRadius: BorderRadius.circular(16),
                        onTap: state.busy || feedback != null
                            ? null
                            : () => controller.select(option.id),
                        child: Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color,
                              width: selected || correct ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                correct
                                    ? Icons.check_circle_rounded
                                    : selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              if (feedback != null)
                Semantics(
                  liveRegion: true,
                  child: Container(
                    key: const Key('reading-feedback'),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: (feedback.correct ? Colors.green : colors.error)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.correct
                              ? context.l10n.commonCorrect
                              : context.l10n.commonNotQuite,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                            color: feedback.correct
                                ? Colors.green
                                : colors.error,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          feedback.explanation,
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        _Footer(
          error: state.error,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('reading-submit'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: state.busy
                  ? null
                  : feedback != null
                  ? controller.nextQuestion
                  : state.selection == null
                  ? null
                  : controller.submit,
              child: state.busy
                  ? const _Spinner()
                  : Text(
                      feedback == null
                          ? context.l10n.commonCheckAnswer
                          : state.questionIndex == attempt.questions.length - 1
                          ? context.l10n.commonViewResults
                          : context.l10n.commonNextQuestion,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.result,
    required this.retry,
    required this.study,
    required this.finish,
    required this.busy,
    this.error,
  });
  final ReadingResult result;
  final VoidCallback retry;
  final VoidCallback study;
  final VoidCallback finish;
  final bool busy;
  final String? error;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          result.passed ? Icons.emoji_events_rounded : Icons.school_rounded,
          size: 80,
          color: result.passed ? const Color(0xFFE59E24) : colors.primary,
        ),
        const SizedBox(height: 20),
        Text(
          result.pendingSync
              ? context.l10n.commonProvisionalResult
              : result.passed
              ? context.l10n.commonLessonMastered
              : context.l10n.readingKeepPracticing,
          key: const Key('reading-result'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          result.pendingSync
              ? context.l10n.commonAnswersAre
              : result.passed
              ? context.l10n.readingStoryProgress
              : context.l10n.readingThePassing,
          textAlign: TextAlign.center,
        ),
        if (result.xp != null) ...[
          const SizedBox(height: 16),
          XpResultBadge(gain: result.xp),
        ],
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '${result.score}%',
                  key: const Key('reading-score'),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
                Text(
                  context.l10n.readingResultCorrectCount(
                    result.correct,
                    result.total,
                  ),
                ),
                const SizedBox(height: 12),
                if (!result.pendingSync) ...[
                  Text(context.l10n.readingResultBestScore(result.bestScore)),
                  Text(
                    context.l10n.readingResultCourseProgress(result.progress),
                  ),
                ] else
                  Text(context.l10n.commonWaitingTo),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (error != null) ...[
          Text(error!, style: TextStyle(color: colors.error)),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          key: const Key('reading-retry'),
          onPressed: busy ? null : retry,
          icon: busy ? const _Spinner() : const Icon(Icons.refresh_rounded),
          label: Text(context.l10n.readingRetryQuiz),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: busy ? null : study,
          child: Text(context.l10n.readingReadThe),
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const Key('reading-finish'),
          onPressed: busy ? null : finish,
          child: Text(context.l10n.readingBackTo),
        ),
        const SizedBox(height: 16),
        const Center(
          child: AdBannerSlot(placement: BannerAdPlacement.quizResult),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.child, this.error});
  final Widget child;
  final String? error;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) ...[
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    ),
  );
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
