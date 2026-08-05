import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.init();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env optional when using --dart-define for API key
  }

  // Pre-load locale and anonymous auth (for Storage uploads) before rendering.
  final container = ProviderContainer();
  await container.read(localeProvider.notifier).load();
  try {
    await container.read(anonymousAuthServiceProvider).ensureSignedIn();
  } catch (_) {
    // Upload flow retries sign-in if startup auth fails (e.g. provider disabled).
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AtiksizApp(),
    ),
  );
}

class AtiksizApp extends ConsumerWidget {
  const AtiksizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Atıksız Mutfak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}
