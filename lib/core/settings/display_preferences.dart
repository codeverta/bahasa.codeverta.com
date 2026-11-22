import 'dart:async';

import 'package:bahasa_master/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const translationPreferenceKey = 'display_translation_enabled';

final displayPreferencesProvider =
    StateNotifierProvider<DisplayPreferencesController, DisplayPreferences>((
      ref,
    ) {
      SharedPreferences? preferences;
      try {
        preferences = ref.watch(sharedPreferencesProvider);
        // ignore: avoid_catching_errors
      } on StateError {
        // Keep isolated previews usable; the app root supplies persistent storage.
      }
      return DisplayPreferencesController(preferences);
    });

class DisplayPreferences {
  const DisplayPreferences({required this.translation});

  final bool translation;
}

class DisplayPreferencesController extends StateNotifier<DisplayPreferences> {
  DisplayPreferencesController(this._preferences)
    : super(_loadPreferences(_preferences));

  final SharedPreferences? _preferences;

  static DisplayPreferences _loadPreferences(SharedPreferences? preferences) {
    return DisplayPreferences(
      translation: preferences?.getBool(translationPreferenceKey) ?? true,
    );
  }

  void setTranslation({required bool enabled}) {
    if (state.translation == enabled) return;
    state = DisplayPreferences(translation: enabled);
    _persist(translationPreferenceKey, enabled);
  }

  void _persist(String key, bool value) {
    if (_preferences == null) return;
    unawaited(_writePreference(key, value));
  }

  Future<void> _writePreference(String key, bool value) async {
    await _preferences!.setBool(key, value);
  }
}
