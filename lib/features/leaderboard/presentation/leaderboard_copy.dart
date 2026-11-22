import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

/// Thin helpers over the leaderboard ARB strings: they only pick which
/// message applies (for example the countdown unit) and format numbers.
class LeaderboardCopy {
  const LeaderboardCopy(this.l10n);

  LeaderboardCopy.of(BuildContext context) : l10n = context.l10n;

  final AppLocalizations l10n;

  /// "Learner #1234" when a person has no usable display name.
  String name(String displayName, String tag) {
    final trimmed = displayName.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return l10n.leaderboardLearnerName(tag);
  }

  String rankOf(int rank, int participants) =>
      l10n.leaderboardRankOf(rank, participants);

  String xp(int value) => l10n.leaderboardXpValue(value);

  /// "Ends in 2 days 5 hours".
  String endsIn(Duration remaining) {
    final left = remaining.isNegative ? Duration.zero : remaining;
    final days = left.inDays;
    final hours = left.inHours % 24;
    final minutes = left.inMinutes % 60;
    if (days > 0) return l10n.leaderboardEndsInDaysHours(days, hours);
    if (hours > 0) return l10n.leaderboardEndsInHoursMinutes(hours, minutes);
    return l10n.leaderboardEndsInMinutes(minutes);
  }

  /// "Last updated 14:05".
  String lastUpdated(DateTime at) {
    final local = at.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return l10n.leaderboardLastUpdated('$h:$m');
  }

  /// Home row: "#12 this week · 20 XP more to reach #11".
  String homeRank(int rank, int gap) {
    if (rank <= 1) return l10n.leaderboardHomeLead;
    return l10n.leaderboardHomeRank(rank, gap, rank - 1);
  }

  String hiddenRank(int rank) => l10n.leaderboardHiddenRank(rank);

  String lastWeek(int rank, int xp) => l10n.leaderboardLastWeek(rank, xp);

  String showingTop(int shown, int total) =>
      l10n.leaderboardShowingTop(shown, total);
}
