import 'package:bahasa_master/core/settings/display_preferences.dart';
import 'package:bahasa_master/core/settings/theme_mode_preference.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsDisplaySettings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.settingsAdjustReading,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Card(
            key: const Key('display-theme-mode-setting'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settingsTheme,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.settingsChooseLight,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto_rounded),
                          label: Text(context.l10n.settingsSystem),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode_rounded),
                          label: Text(context.l10n.settingsLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode_rounded),
                          label: Text(context.l10n.settingsDark),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (selection) => ref
                          .read(themeModeProvider.notifier)
                          .select(selection.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule_rounded),
              title: Text(context.l10n.settingsStudyTime),
              subtitle: Text(context.l10n.settingsThisTime),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/settings/timezone'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  key: const Key('display-translation-setting'),
                  title: Text(context.l10n.commonTranslation),
                  subtitle: Text(context.l10n.settingsShowMeanings),
                  value: preferences.translation,
                  onChanged: (enabled) =>
                      controller.setTranslation(enabled: enabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
