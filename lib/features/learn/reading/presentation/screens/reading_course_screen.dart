import 'package:bahasa_master/core/app_review/app_review_service.dart';
import 'package:bahasa_master/core/routing/app_router.dart';
import 'package:bahasa_master/core/unlock/locked_content.dart';
import 'package:bahasa_master/core/unlock/unlock_repository.dart';
import 'package:bahasa_master/features/learn/level_list/presentation/level_label.dart';
import 'package:bahasa_master/features/learn/reading/domain/reading_models.dart';
import 'package:bahasa_master/features/learn/reading/presentation/controllers/reading_controller.dart';
import 'package:bahasa_master/features/learn/reading/presentation/widgets/reading_illustration.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingCourseScreen extends ConsumerStatefulWidget {
  const ReadingCourseScreen({super.key, this.level = 'N5'});
  final String level;
  @override
  ConsumerState<ReadingCourseScreen> createState() =>
      _ReadingCourseScreenState();
}

class _ReadingCourseScreenState extends ConsumerState<ReadingCourseScreen> {
  String query = '';
  String? chapter;
  Future<void> open(ReadingLessonSummary lesson) async {
    await context.push(AppRoutes.readingLessonPath(lesson.id));
    if (!mounted) return;
    ref.invalidate(readingCourseProvider(widget.level));
    requestAppReviewIfEligible(ref);
  }

  @override
  Widget build(BuildContext context) {
    final provider = readingCourseProvider(widget.level);
    final course = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.readingCourseTitle(levelLabel(context, widget.level)),
        ),
      ),
      body: course.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48),
                const SizedBox(height: 16),
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(provider),
                  child: Text(context.l10n.commonRefresh),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final colors = Theme.of(context).colorScheme;
          final chapters = data.lessons.map((l) => l.chapter).toSet();
          final visible = data.lessons
              .where(
                (l) =>
                    (chapter == null || chapter == l.chapter) &&
                    '${l.title} ${l.japaneseTitle} ${l.chapter} ${l.description}'
                        .toLowerCase()
                        .contains(query.trim().toLowerCase()),
              )
              .toList();
          final resume = data.lessons.where((l) => !l.completed).firstOrNull;
          return RefreshIndicator(
            onRefresh: () => ref.refresh(provider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [colors.secondary, colors.primary],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        context.l10n.readingSmallStories,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.l10n.readingCourseSummary(
                          data.lessons.length,
                          data.lessons.fold<int>(0, (n, l) => n + l.pageCount),
                          data.lessons.fold<int>(
                            0,
                            (n, l) => n + l.questionCount,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.level == 'N2'
                            ? context.l10n.readingPracticeInference
                            : widget.level == 'N1'
                            ? context.l10n.readingPracticeReading
                            : widget.level == 'N3'
                            ? context.l10n.readingUnderstandReasons
                            : context.l10n.readingFollowA,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.readingProgressSummary(
                            data.completedLessons,
                            data.lessons.length,
                            data.progress,
                          ),
                          key: const Key('reading-course-progress'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: data.progress / 100,
                          backgroundColor: colors.primary.withValues(
                            alpha: 0.1,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 16),
                        if (resume != null)
                          FilledButton.icon(
                            key: const Key('reading-resume'),
                            onPressed: () => open(resume),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(
                              data.completedLessons == 0
                                  ? context.l10n.readingOpenThe
                                  : context.l10n.readingContinueReading,
                            ),
                          )
                        else
                          Text(context.l10n.readingAllStories),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  key: const Key('reading-search'),
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: context.l10n.readingSearchFor,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final c in <String?>[null, ...chapters])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c ?? context.l10n.readingFilterAll),
                            selected: chapter == c,
                            onSelected: (_) => setState(() => chapter = c),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      context.l10n.readingNoStories,
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final lesson in visible) ...[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () => open(lesson),
                          child: ReadingIllustration(
                            asset: lesson.imageAsset,
                            url: lesson.imageUrl,
                            panel: 0,
                            description: context.l10n
                                .readingIllustrationDescription(lesson.title),
                            aspectRatio: 16 / 9,
                          ),
                        ),
                        ListTile(
                          key: Key('reading-lesson-${lesson.id}'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          onTap: () => open(lesson),
                          leading: CircleAvatar(
                            backgroundColor: colors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: lesson.completed
                                ? Icon(
                                    Icons.check_rounded,
                                    color: colors.primary,
                                  )
                                : Text(
                                    '${lesson.order}',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                          title: Text(
                            lesson.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${lesson.japaneseTitle}\n${context.l10n.readingLessonDetails(lesson.minutes, lesson.pageCount, lesson.bestScore)}',
                          ),
                          isThreeLine: true,
                          trailing: UnlockLockIcon(
                            target: UnlockTarget('reading', lesson.id),
                            lockable: isLockableLevel(widget.level),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
