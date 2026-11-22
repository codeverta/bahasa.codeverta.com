import 'package:bahasa_master/core/notifications/push_notifications.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pushNotificationsProvider);
    final controller = ref.read(pushNotificationsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.notificationsNotifications)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.notifications_outlined, size: 52),
          const SizedBox(height: 16),
          Text(
            context.l10n.notificationsBahasaMaster,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(context.l10n.notificationsReceiveApp),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.notificationsReceiveAnnouncements),
            subtitle: Text(
              state.enabled && state.granted && !state.pendingSync
                  ? context.l10n.notificationsEnabledOn
                  : state.enabled
                  ? context.l10n.notificationsTurnedOn
                  : context.l10n.notificationsOff,
            ),
            value: state.enabled,
            onChanged: state.available && !state.busy
                ? (enabled) => controller.setEnabled(enabled: enabled)
                : null,
          ),
          if (state.busy) const LinearProgressIndicator(),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(state.message!),
            ),
          if (state.available) ...[
            TextButton.icon(
              onPressed: controller.openSystemSettings,
              icon: const Icon(Icons.settings_outlined),
              label: Text(context.l10n.notificationsAndroidNotification),
            ),
            if (state.pendingSync)
              OutlinedButton(
                onPressed: state.busy ? null : controller.refresh,
                child: Text(context.l10n.notificationsTryConnecting),
              ),
          ],
        ],
      ),
    );
  }
}
