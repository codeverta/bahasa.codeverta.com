import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:bahasa_master/core/localization/app_language.dart';
import 'package:bahasa_master/core/storage/shared_preferences_provider.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const announcementTopic = 'bahasa_announcements';
const announcementTopicEnglish = 'bahasa_announcements_en';

/// English is the default announcement language. The original topic is kept
/// for Indonesian so existing installs keep working; every other language
/// falls back to English.
String announcementTopicFor(String languageCode) =>
    languageCode == 'id' ? announcementTopic : announcementTopicEnglish;

const notificationRoutes = <String>{
  '/home',
  '/anki',
  '/premium',
  '/learn/vocabulary',
  '/learn/grammar',
  '/learn/reading',
};
String safeNotificationRoute(Object? value) =>
    value is String && notificationRoutes.contains(value) ? value : '/home';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Notification payloads are displayed by Android; do not post a duplicate.
  await Firebase.initializeApp();
}

class PushNotificationState {
  const PushNotificationState({
    this.available = false,
    this.enabled = false,
    this.granted = false,
    this.busy = true,
    this.pendingSync = false,
    this.message,
    this.navigation,
  });
  final bool available;
  final bool enabled;
  final bool granted;
  final bool busy;
  final bool pendingSync;
  final String? message;
  final String? navigation;
}

final pushNotificationsProvider =
    StateNotifierProvider<PushNotificationController, PushNotificationState>((
      ref,
    ) {
      final controller = PushNotificationController(
        ref.watch(sharedPreferencesProvider),
        languageCode: ref.read(appLanguageProvider).languageCode,
      );
      ref.listen<Locale>(appLanguageProvider, (previous, next) {
        if (previous?.languageCode != next.languageCode) {
          unawaited(controller.languageChanged(next.languageCode));
        }
      });
      return controller;
    });

/// Outcome of [PushNotificationController.setEnabled].
enum PushToggleResult { on, off, denied, failed }

class PushNotificationController extends StateNotifier<PushNotificationState> {
  PushNotificationController(this._preferences, {String languageCode = 'en'})
    : _languageCode = languageCode,
      super(
        PushNotificationState(
          available: supported,
          enabled: _preferences.getBool(_preferenceKey) ?? false,
          busy: false,
        ),
      ) {
    // Keep Dart messaging startup and FCM registration behind explicit opt-in.
    if (state.enabled ||
        (_preferences.getBool('announcement_sync_pending') ?? false)) {
      unawaited(initialize());
    } else if (!supported) {
      _set(message: _strings.notificationsPushAndroidOnly);
    }
  }
  static const _preferenceKey = 'announcement_notifications_enabled';
  final SharedPreferences _preferences;
  String _languageCode;
  String get _topic => announcementTopicFor(_languageCode);
  String get _otherTopic =>
      _languageCode == 'id' ? announcementTopicEnglish : announcementTopic;

  AppLocalizations get _strings => appL10n(Locale(_languageCode));

  AndroidNotificationChannel get _channel => AndroidNotificationChannel(
    announcementTopic,
    _strings.notificationsBahasaMaster,
    description: _strings.notificationsChannelDescription,
  );

  /// Moves the device to the topic for the new language and renames the
  /// Android channel so system settings match the app language.
  Future<void> languageChanged(String languageCode) async {
    if (languageCode == _languageCode) return;
    _languageCode = languageCode;
    if (!mounted || !_initialized) return;
    try {
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
      if (state.enabled && state.granted) {
        await _applyTopics();
      }
    } on Object {
      _set(pendingSync: true);
    }
  }

  Future<void> _applyTopics() async {
    await _messaging
        .subscribeToTopic(_topic)
        .timeout(const Duration(seconds: 15));
    try {
      await _messaging
          .unsubscribeFromTopic(_otherTopic)
          .timeout(const Duration(seconds: 15));
    } on Object {
      // Retried on the next refresh; the active topic is already subscribed.
    }
  }

  late final _local = FlutterLocalNotificationsPlugin();
  late final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<String> _foregroundIDs = {};
  late bool _initialized = false;
  Future<void>? _initializing;
  late FirebaseMessaging _messaging;
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void _set({
    bool? available,
    bool? enabled,
    bool? granted,
    bool? busy,
    bool? pendingSync,
    String? message,
    String? navigation,
  }) {
    if (!mounted) return;
    state = PushNotificationState(
      available: available ?? state.available,
      enabled: enabled ?? state.enabled,
      granted: granted ?? state.granted,
      busy: busy ?? state.busy,
      pendingSync: pendingSync ?? state.pendingSync,
      message: message,
      navigation: navigation ?? state.navigation,
    );
  }

  Future<void> initialize() => _initializing ??= _initialize();
  Future<void> _initialize() async {
    _set(busy: true);
    if (!supported) {
      _set(busy: false, message: _strings.notificationsPushAndroidOnly);
      return;
    }
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 15));
      if (!mounted) return;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _messaging = FirebaseMessaging.instance;
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _openLocal(response.payload),
      );
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
      if (!mounted) return;
      _subscriptions
        ..add(
          FirebaseMessaging.onMessage.listen((m) {
            unawaited(_showForeground(m));
          }),
        )
        ..add(
          FirebaseMessaging.onMessageOpenedApp.listen((m) {
            _set(navigation: safeNotificationRoute(m.data['route']));
          }),
        )
        ..add(
          _messaging.onTokenRefresh.listen((_) {
            // Reapply the public topic after registration/token renewal.
            if (mounted && state.enabled && !state.busy) {
              unawaited(_subscribeAfterRegistration());
            }
          }),
        );
      if (!mounted) return;
      _initialized = true;
      _set(available: true, busy: false);
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        _set(navigation: safeNotificationRoute(initial.data['route']));
      }
      final localInitial = await _local.getNotificationAppLaunchDetails();
      if (localInitial?.didNotificationLaunchApp ?? false) {
        _openLocal(localInitial?.notificationResponse?.payload);
      }
      if (mounted) {
        await refresh();
      }
    } on Object {
      _set(
        available: false,
        busy: false,
        message: _strings.notificationsConnectFailed,
      );
    }
  }

  Future<void> _subscribeAfterRegistration() async {
    if (!mounted || state.busy || !state.enabled) return;
    _set(busy: true);
    try {
      await _applyTopics();
      _set(pendingSync: false);
    } on Object {
      _set(pendingSync: true, message: _strings.notificationsSubscribeRetry);
    } finally {
      if (mounted) {
        _set(
          busy: false,
          pendingSync: state.pendingSync,
          message: state.message,
        );
      }
    }
  }

  Future<void> refresh() async {
    if (!mounted || !_initialized || state.busy) return;
    _set(busy: true);
    try {
      final settings = await _messaging.getNotificationSettings();
      if (!mounted) return;
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      _set(granted: granted);
      if (state.enabled && granted) {
        await _messaging.setAutoInitEnabled(true);
        await _messaging.getToken().timeout(const Duration(seconds: 15));
        await _applyTopics();
      } else if (!state.enabled &&
          (_preferences.getBool('announcement_sync_pending') ?? false)) {
        await _messaging.setAutoInitEnabled(false);
        for (final topic in const [
          announcementTopic,
          announcementTopicEnglish,
        ]) {
          await _messaging
              .unsubscribeFromTopic(topic)
              .timeout(const Duration(seconds: 15));
        }
        await _messaging.deleteToken().timeout(const Duration(seconds: 15));
        await _messaging.setAutoInitEnabled(false);
        await _preferences.setBool('announcement_sync_pending', false);
      }
      if (!mounted) return;
      _set(
        busy: false,
        pendingSync: false,
        message: state.enabled && !granted
            ? _strings.notificationsPermissionOff
            : null,
      );
    } on Object {
      if (!mounted) return;
      _set(
        busy: false,
        pendingSync: true,
        message: state.enabled
            ? _strings.notificationsWaitingToSubscribe
            : _strings.notificationsWaitingToUnsubscribe,
      );
    }
  }

  Future<PushToggleResult> setEnabled({required bool enabled}) async {
    await initialize();
    if (!mounted || !state.available || state.busy) {
      return PushToggleResult.failed;
    }
    _set(busy: true);
    try {
      if (enabled) {
        final settings = await _messaging.requestPermission();
        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          _set(
            busy: false,
            granted: false,
            message: _strings.notificationsPermissionDenied,
          );
          return PushToggleResult.denied;
        }
      }
      await _preferences.setBool(_preferenceKey, enabled);
      await _preferences.setBool('announcement_sync_pending', true);
      _set(enabled: enabled);
      if (!enabled) {
        try {
          await _local.cancelAll();
        } on Object {
          /* Retry subscription cleanup independently. */
        }
      }
      _set(busy: false);
      await refresh();
      return enabled ? PushToggleResult.on : PushToggleResult.off;
    } on Object {
      _set(busy: false, message: _strings.notificationsUpdateFailed);
      return PushToggleResult.failed;
    }
  }

  Future<void> _showForeground(RemoteMessage m) async {
    if (!mounted ||
        !state.enabled ||
        !state.granted ||
        m.notification == null) {
      return;
    }
    final id = m.messageId ?? m.data['announcementId']?.toString();
    if (id != null && !_foregroundIDs.add(id)) return;
    if (_foregroundIDs.length > 100) {
      _foregroundIDs.remove(_foregroundIDs.first);
    }
    try {
      await _local.show(
        id: (id ?? DateTime.now().toIso8601String()).hashCode & 0x7fffffff,
        title: m.notification!.title,
        body: m.notification!.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            announcementTopic,
            _strings.notificationsBahasaMaster,
            icon: 'ic_notification',
          ),
        ),
        payload: jsonEncode({'route': safeNotificationRoute(m.data['route'])}),
      );
    } on Object {
      /* Notification failures must not interrupt learning. */
    }
  }

  void _openLocal(String? payload) {
    try {
      final data = jsonDecode(payload ?? '{}');
      _set(
        navigation: safeNotificationRoute(data is Map ? data['route'] : null),
      );
    } on Object {
      _set(navigation: '/home');
    }
  }

  void consumeNavigation() {
    if (!mounted) return;
    state = PushNotificationState(
      available: state.available,
      enabled: state.enabled,
      granted: state.granted,
      busy: state.busy,
      pendingSync: state.pendingSync,
      message: state.message,
    );
  }

  Future<void> openSystemSettings() async {
    if (!supported) return;
    try {
      await const MethodChannel(
        'com.codeverta.bahasa/app_info',
      ).invokeMethod<void>('openNotificationSettings');
    } on Object {
      _set(message: _strings.notificationsOpenSettingsHint);
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
