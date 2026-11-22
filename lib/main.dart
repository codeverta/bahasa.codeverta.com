import 'dart:async';
import 'dart:ui';

import 'package:bahasa_master/core/analytics/analytics_service.dart';
import 'package:bahasa_master/core/app_review/app_review_service.dart';
import 'package:bahasa_master/core/app_update/app_update_controller.dart';
import 'package:bahasa_master/core/app_update/app_update_gate.dart';
import 'package:bahasa_master/core/branding/app_branding.dart';
import 'package:bahasa_master/core/diagnostics/error_reporter.dart';
import 'package:bahasa_master/core/localization/app_language.dart';
import 'package:bahasa_master/core/localization/app_localizations.dart';
import 'package:bahasa_master/core/notifications/notification_lifecycle.dart';
import 'package:bahasa_master/core/offline/offline_lifecycle.dart';
import 'package:bahasa_master/core/routing/app_router.dart';
import 'package:bahasa_master/core/settings/theme_mode_preference.dart';
import 'package:bahasa_master/core/storage/shared_preferences_provider.dart';
import 'package:bahasa_master/core/theme/app_theme.dart';
import 'package:bahasa_master/core/widgets/system_navigation_inset.dart';
import 'package:bahasa_master/features/billing/presentation/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        unawaited(
          ErrorReporter.capture(
            details.exception,
            details.stack ?? StackTrace.current,
          ),
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        unawaited(ErrorReporter.capture(error, stackTrace, severity: 'fatal'));
        return false;
      };

      await initializeDateFormatting();
      final preferences = await SharedPreferences.getInstance();
      ErrorReporter.initialize(preferences);
      unawaited(
        AppReviewService(
          preferences,
          const InAppReviewClient(),
        ).recordActiveDay(),
      );
      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
          child: const BahasaMasterApp(),
        ),
      );
    },
    (error, stackTrace) {
      unawaited(ErrorReporter.capture(error, stackTrace, severity: 'fatal'));
    },
  );
}

class BahasaMasterApp extends ConsumerWidget {
  const BahasaMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appPresentationLocaleProvider);
    final supportedLocales = ref.watch(appSupportedLocalesProvider);
    ref
      ..watch(billingControllerProvider)
      ..watch(analyticsBootstrapProvider);

    return MaterialApp.router(
      title:
          ref.watch(appBrandingProvider).valueOrNull?.appName ??
          'Bahasa Master',
      builder: (context, child) => SystemNavigationInset(
        child: OfflineLifecycle(
          child: NotificationLifecycle(
            child: AppUpdateGate(child: BrandStartup(child: child!)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      backButtonDispatcher: ref.watch(appUpdateBackDispatcherProvider),
    );
  }
}
