import 'package:bahasa_master/core/app_review/app_review_service.dart';
import 'package:bahasa_master/core/routing/app_router.dart';
import 'package:bahasa_master/core/unlock/locked_content.dart';
import 'package:bahasa_master/core/unlock/unlock_repository.dart';
import 'package:bahasa_master/features/learn/grammar/domain/grammar_models.dart';
import 'package:bahasa_master/features/learn/grammar/presentation/controllers/grammar_controller.dart';
import 'package:bahasa_master/features/learn/level_list/presentation/grammar_level_list.dart';
import 'package:bahasa_master/features/learn/level_list/presentation/level_label.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GrammarCourseScreen extends ConsumerStatefulWidget {
  const GrammarCourseScreen({this.initialLevel = 'N5', super.key});
  final String initialLevel;
  @override
  ConsumerState<GrammarCourseScreen> createState() =>
      _GrammarCourseScreenState();
}

class _GrammarCourseScreenState extends ConsumerState<GrammarCourseScreen> {
  String query = '';
  String? chapter;
  late String level =
      ['N5', 'N4', 'N3', 'N2', 'N1'].contains(widget.initialLevel)
      ? widget.initialLevel
      : 'N5';
  void invalidateCourse() {
    if (level == 'N5') ref.invalidate(grammarCourseProvider);
    ref.invalidate(grammarCourseLevelProvider(level));
  }

  Future<void> open(GrammarLessonSummary lesson) async {
    await context.push(AppRoutes.grammarLessonPath(lesson.id));
    if (!mounted) return;
    invalidateCourse();
    requestAppReviewIfEligible(ref);
  }

  @override
  Widget build(BuildContext context) {
    final provider = grammarCourseLevelProvider(level);
    final course = ref.watch(provider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.grammarCourseTitle(levelLabel(context, level)),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.grammarLesson),
              Tab(
                key: const ValueKey('grammar-tab-list'),
                text: context.l10n.grammarPatternList,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            course.when(
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
                        onPressed: invalidateCourse,
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
                          '${l.title} ${l.chapter} ${l.patterns.join(' ')}'
                              .toLowerCase()
                              .contains(query.trim().toLowerCase()),
                    )
                    .toList();
                final resume = data.lessons
                    .where((l) => !l.completed)
                    .firstOrNull;
                return RefreshIndicator(
                  onRefresh: () async {
                    invalidateCourse();
                    await ref.read(provider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      Wrap(
                        runSpacing: 4,
                        children: [
                          for (final item in ['N5', 'N4', 'N3', 'N2', 'N1'])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(levelLabel(context, item)),
                                selected: item == level,
                                onSelected: (_) {
                                  setState(() {
                                    level = item;
                                    query = '';
                                    chapter = null;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                              level == 'N1'
                                  ? context.l10n.grammarMasterAdvanced
                                  : level == 'N2'
                                  ? context.l10n.grammarMasterNuance
                                  : level == 'N3'
                                  ? context.l10n.grammarUnderstandNuance
                                  : level == 'N4'
                                  ? context.l10n.grammarExpressPlans
                                  : context.l10n.grammarBuildIndonesian,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.l10n.grammarCourseSummary(
                                data.lessons.length,
                                data.lessons.fold<int>(
                                  0,
                                  (n, l) => n + l.pointCount,
                                ),
                                data.lessons.fold<int>(
                                  0,
                                  (n, l) => n + l.questionCount,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.grammarStudyThe,
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
                                context.l10n.grammarProgressSummary(
                                  data.completedLessons,
                                  data.lessons.length,
                                  data.progress,
                                ),
                                key: const Key('grammar-course-progress'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
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
                                  key: const Key('grammar-resume'),
                                  onPressed: () => open(resume),
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: Text(
                                    data.completedLessons == 0
                                        ? context.l10n.commonStartLearning
                                        : context.l10n.commonContinueLearning,
                                  ),
                                )
                              else
                                Text(context.l10n.grammarAllLessons),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        key: ValueKey('grammar-search-$level'),
                        onChanged: (v) => setState(() => query = v),
                        decoration: InputDecoration(
                          hintText: context.l10n.grammarSearchFor,
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
                                  label: Text(
                                    c ?? context.l10n.grammarFilterAll,
                                  ),
                                  selected: chapter == c,
                                  onSelected: (_) =>
                                      setState(() => chapter = c),
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
                            context.l10n.grammarNoMatching,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      for (final lesson in visible) ...[
                        Card(
                          child: ListTile(
                            key: Key('grammar-lesson-${lesson.id}'),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${lesson.chapter}\n${context.l10n.grammarLessonDetails(lesson.pointCount, lesson.questionCount, lesson.bestScore)}',
                            ),
                            isThreeLine: true,
                            trailing: UnlockLockIcon(
                              target: UnlockTarget('grammar', lesson.id),
                              lockable: isLockableLevel(lesson.level),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                );
              },
            ),
            GrammarLevelList(
              level: level,
              onLevelChanged: (value) => setState(() {
                level = value;
                query = '';
                chapter = null;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
