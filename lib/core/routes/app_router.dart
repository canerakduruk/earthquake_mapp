import 'package:earthquake_mapp/presentation/screens/bottombar_nav_screen.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_list_screen.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_map/earthquake_map_screen.dart';
import 'package:earthquake_mapp/presentation/screens/form/login_form.dart';
import 'package:earthquake_mapp/presentation/screens/form/register_form.dart';
import 'package:earthquake_mapp/presentation/screens/home/earthquake_assembly_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/home_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/profile/edit_profile/edit_profile_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/profile/profile_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/settings_screen.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.earthquakeList:
        return MaterialPageRoute(builder: (_) => const EarthquakeListScreen());
      case AppRoutes.earthquakeMap:
        return MaterialPageRoute(builder: (_) => const EarthquakeMapScreen());

      case AppRoutes.loginForm:
        return MaterialPageRoute(builder: (_) => const LoginForm());
      case AppRoutes.registerForm:
        return MaterialPageRoute(builder: (_) => const RegisterForm());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.earthquakeAssembly:
        return MaterialPageRoute(
          builder: (_) => const EarthquakeAssemblyScreen(),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.bottomBarNav:
        return MaterialPageRoute(builder: (_) => const BottombarNavScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Sayfa bulunamadı: ${settings.name}')),
          ),
        );
    }
  }
}
