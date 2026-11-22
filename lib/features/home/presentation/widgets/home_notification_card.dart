import 'package:bahasa_master/core/notifications/notification_prompt.dart';
import 'package:bahasa_master/core/notifications/push_notifications.dart';
import 'package:bahasa_master/core/theme/app_theme.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:bahasa_master/shared/presentation/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-time card for people who never saw the onboarding page (existing
/// installs, or onboarding skipped): "Turn on notifications?". Any answer hides
/// it for good; Settings keeps the switch.
class HomeNotificationCard extends ConsumerStatefulWidget {
  const HomeNotificationCard({super.key});

  @override
  ConsumerState<HomeNotificationCard> createState() =>
      _HomeNotificationCardState();
}

class _HomeNotificationCardState extends ConsumerState<HomeNotificationCard> {
  bool _busy = false;

  Future<void> _enable() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await enableNotificationsFromPrompt(
      ref.read,
      NotificationPromptPlace.home,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final message = switch (result) {
      PushToggleResult.denied => context.l10n.homeNotificationPermissionDenied,
      PushToggleResult.failed => context.l10n.homeNotificationEnableFailed,
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(shouldAskNotificationsProvider)) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SakuraCard(
        key: const Key('home-notification-card'),
        color: SakuraColors.of(context).goldSoft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.homeTurnOn,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('home-notification-skip'),
                  onPressed: _busy
                      ? null
                      : () => skipNotificationPrompt(
                          ref.read,
                          NotificationPromptPlace.home,
                        ),
                  child: Text(context.l10n.homeMaybeLater),
                ),
                FilledButton(
                  key: const Key('home-notification-enable'),
                  onPressed: _busy ? null : _enable,
                  child: Text(context.l10n.homeTurnOn2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
