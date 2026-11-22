import 'dart:async';

import 'package:bahasa_master/core/ads/ads_controller.dart';
import 'package:bahasa_master/core/analytics/analytics_service.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/leaderboard/data/leaderboard_repository.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pusat pengaturan. Aksi akun yang berisiko (logout dan hapus akun) sengaja
/// ditaruh di sini, terpisah dari menu profil, agar tidak tertekan tanpa sengaja.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final error = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsSettings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.text_fields_rounded,
                  title: context.l10n.settingsDisplaySettings,
                  onTap: () => context.push('/settings/display'),
                ),
                const Divider(height: 1, indent: 68),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: context.l10n.settingsNotificationSettings,
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 12),
            const Card(child: _LeaderboardVisibilitySwitch()),
          ],
          const SizedBox(height: 12),
          const Card(child: _AnalyticsSwitch()),
          const _AdPrivacyTile(),
          if (user != null) ...[
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                context.l10n.settingsAccount,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    key: const Key('settings-logout'),
                    icon: Icons.logout_rounded,
                    iconColor: error,
                    title: context.l10n.settingsSignOut,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                  const Divider(height: 1, indent: 68),
                  _SettingsTile(
                    key: const Key('settings-delete-account'),
                    icon: Icons.delete_forever_outlined,
                    iconColor: error,
                    title: context.l10n.settingsDeleteAccount,
                    onTap: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsSignOutOf),
        content: Text(context.l10n.settingsPersonalData),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.settingsSignOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go('/home');
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsPermanentlyDelete),
        content: Text(context.l10n.settingsYourProfile),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.settingsDeleteAccount),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (context.mounted) context.go('/home');
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsYourAccount)),
        );
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _AnalyticsSwitch extends ConsumerStatefulWidget {
  const _AnalyticsSwitch();

  @override
  ConsumerState<_AnalyticsSwitch> createState() => _AnalyticsSwitchState();
}

class _AnalyticsSwitchState extends ConsumerState<_AnalyticsSwitch> {
  late bool _enabled = ref.read(analyticsServiceProvider).enabled;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      key: const Key('settings-analytics'),
      secondary: Icon(
        Icons.insights_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        context.l10n.settingsHelpImprove,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(context.l10n.settingsShareAnonymous),
      value: _enabled,
      onChanged: (value) {
        setState(() => _enabled = value);
        unawaited(ref.read(analyticsServiceProvider).setEnabled(value: value));
      },
    );
  }
}

/// "Sembunyikan saya dari leaderboard". Default is shown; the value comes
/// from `/me/leaderboard` and is saved on the server.
class _LeaderboardVisibilitySwitch extends ConsumerStatefulWidget {
  const _LeaderboardVisibilitySwitch();

  @override
  ConsumerState<_LeaderboardVisibilitySwitch> createState() =>
      _LeaderboardVisibilitySwitchState();
}

class _LeaderboardVisibilitySwitchState
    extends ConsumerState<_LeaderboardVisibilitySwitch> {
  bool? _pending;
  bool _saving = false;

  Future<void> _save(bool hidden) async {
    setState(() {
      _pending = hidden;
      _saving = true;
    });
    try {
      await ref.read(leaderboardRepositoryProvider).setHidden(hidden: hidden);
      ref.invalidate(myLeaderboardProvider);
    } on Object {
      if (!mounted) return;
      setState(() => _pending = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsYourLeaderboard)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mine = ref.watch(myLeaderboardProvider);
    final hidden = _pending ?? mine.valueOrNull?.data.hidden ?? false;
    final ready = mine.hasValue && mine.valueOrNull != null && !_saving;
    return SwitchListTile.adaptive(
      key: const Key('settings-leaderboard-hidden'),
      secondary: Icon(
        Icons.emoji_events_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        context.l10n.settingsHideMe,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(context.l10n.settingsYourName),
      value: hidden,
      onChanged: ready ? _save : null,
    );
  }
}

/// Lets people reopen the Google consent form (required in some regions).
/// Hidden unless ads are active and the consent form says it must be offered.
class _AdPrivacyTile extends ConsumerWidget {
  const _AdPrivacyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(adsReadyProvider).valueOrNull != null;
    if (!active) return const SizedBox.shrink();
    final runtime = ref.read(adsRuntimeProvider);
    return FutureBuilder<bool>(
      future: runtime.privacyOptionsRequired(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Card(
            child: _SettingsTile(
              key: const Key('settings-ad-privacy'),
              icon: Icons.privacy_tip_outlined,
              title: context.l10n.settingsAdPrivacy,
              onTap: () => unawaited(runtime.showPrivacyOptions()),
            ),
          ),
        );
      },
    );
  }
}
