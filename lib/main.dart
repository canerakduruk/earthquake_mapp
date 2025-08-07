import 'package:earthquake_mapp/core/routes/app_router.dart';
import 'package:earthquake_mapp/core/routes/app_routes.dart';
import 'package:earthquake_mapp/core/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (error) {
    LoggerHelper.err("Main:", "Firebase Error -> $error");
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Earthquake App',
      initialRoute: AppRoutes.bottomBarNav,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
