import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pyago/core/constants/app_constants.dart';
import 'package:pyago/core/routing/app_router.dart';
import 'package:pyago/core/services/app_lock_gate.dart';
import 'package:pyago/core/services/crash_reporting_service.dart';
import 'package:pyago/core/services/push_notification_service.dart';
import 'package:pyago/core/storage/hive_service.dart';
import 'package:pyago/core/storage/local_storage_service.dart';
import 'package:pyago/core/theme/app_theme.dart';
import 'package:pyago/features/settings/presentation/providers/settings_provider.dart';
import 'package:pyago/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise storage before the widget tree is built.
  final prefs = await SharedPreferences.getInstance();
  await HiveService.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorageService(prefs)),
        hiveServiceProvider.overrideWithValue(HiveService()),
        // Swap the no-op implementation for a real one in staging/production:
        //
        // crashReportingServiceProvider.overrideWithValue(
        //   SentryCrashReportingService(),
        // ),
      ],
      child: const PyagoApp(),
    ),
  );
}

class PyagoApp extends ConsumerWidget {
  const PyagoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider);

    // Reading this once here is enough to initialise the plugin and
    // register the notification-tap → deep-link handler for the
    // lifetime of the app.
    ref.watch(pushNotificationServiceProvider);

    return MaterialApp.router(
      title: 'Pyago',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: settings.themeMode,
      theme: AppTheme.light(highContrast: settings.highContrast),
      darkTheme: AppTheme.dark(highContrast: settings.highContrast),
      locale: Locale(settings.locale),
      supportedLocales: AppConstants.supportedLocales.map(Locale.new),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: AppLockGate(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
