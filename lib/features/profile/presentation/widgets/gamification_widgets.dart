import 'package:bahasa_master/core/localization/region_formatters.dart';
import 'package:bahasa_master/features/home/domain/home_dashboard.dart';
import 'package:bahasa_master/features/profile/data/gamification_repository.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';

class GamificationStats extends StatelessWidget {
  const GamificationStats({required this.data, super.key});
  final GamificationSummary data;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 20,
            runSpacing: 12,
            children: [
              _stat('🔥', '${data.streakDays}', context.l10n.profileDayStreak),
              _stat('⚡', '${data.xp}', 'XP'),
              _stat('🏆', '${data.unlockedCount}', context.l10n.profileBadges),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.profileStatsLevel(
              data.level,
              data.levelXp,
              data.nextLevelXp,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: data.levelXp / data.nextLevelXp),
          const SizedBox(height: 12),
          Text(
            context.l10n.profileStatsCompleted(
              data.lessonsCompleted,
              data.examsCompleted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.profileStatsStreak(data.bestStreak, data.activeDays),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.profileEarn50,
            style: const TextStyle(fontSize: 12, height: 1.6),
          ),
        ],
      ),
    ),
  );

  Widget _stat(String icon, String value, String label) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      Text(
        value,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      Text(label),
    ],
  );
}

class AchievementTile extends StatelessWidget {
  const AchievementTile({required this.achievement, super.key});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final progress = a.target > 0
        ? (a.progress / a.target).clamp(0.0, 1.0)
        : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              a.isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline,
              color: a.isUnlocked
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    a.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(a.description),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 6),
                  Text(
                    a.isUnlocked
                        ? context.l10n.profileAchievementUnlocked(
                            a.progress,
                            a.target,
                          )
                        : context.l10n.profileAchievementLocked(
                            a.progress,
                            a.target,
                          ),
                  ),
                  if (a.unlockedAt != null)
                    Text(
                      context.l10n.profileAchievementEarned(
                        regionalDate(
                          a.unlockedAt!,
                          localeName: Localizations.localeOf(
                            context,
                          ).toString(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamificationError extends StatelessWidget {
  const GamificationError({required this.retry, super.key});
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(context.l10n.profileProgressCould),
          TextButton(
            onPressed: retry,
            child: Text(context.l10n.commonTryAgain),
          ),
        ],
      ),
    ),
  );
}
