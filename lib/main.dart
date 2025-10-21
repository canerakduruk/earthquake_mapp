import 'package:earthquake_mapp/core/routes/app_router.dart';
import 'package:earthquake_mapp/core/theme/dark_theme.dart';
import 'package:earthquake_mapp/core/theme/light_theme.dart';
import 'package:earthquake_mapp/core/utils/logger_helper.dart';
import 'package:earthquake_mapp/features/providers/locale_provider.dart';
import 'package:earthquake_mapp/features/providers/theme_provider.dart';
import 'package:earthquake_mapp/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    LoggerHelper.info("Main:", "Firebase başlatıldı.");
  } catch (error) {
    LoggerHelper.err("Main:", "Firebase Error -> $error");
  }

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr', 'TR'),
        child: MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    LoggerHelper.info(
      'MainApp',
      'Build çağrıldı, locale: $locale, themeMode: $themeMode',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Earthquake App',
      theme: LightTheme.themeData,
      darkTheme: DarkTheme.themeData,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
