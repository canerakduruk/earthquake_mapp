// Yeni provider'ı import ediyoruz (dosya yolunu doğrulayın)
import 'package:earthquake_mapp/features/providers/auth_provider.dart';
import 'package:earthquake_mapp/features/screens/earthquake_list_screen.dart';
import 'package:earthquake_mapp/features/screens/earthquake_map_screen.dart';
import 'package:earthquake_mapp/features/screens/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottombarNavScreen extends ConsumerStatefulWidget {
  const BottombarNavScreen({super.key});

  @override
  ConsumerState<BottombarNavScreen> createState() => _BottombarNavScreenState();
}

class _BottombarNavScreenState extends ConsumerState<BottombarNavScreen> {
  late PersistentTabController controller;

  @override
  void initState() {
    super.initState();
    controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      final bool wasLoggedIn = previous?.valueOrNull != null;
      final bool isLoggedOut = next.valueOrNull == null;

      if (isLoggedOut && wasLoggedIn) {
        controller.jumpToTab(0);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BottombarNavScreen()),
          (route) => false,
        );
      }
    });

    return PersistentTabView(
      controller: controller,
      tabs: _buildScreens(),
      navBarBuilder: (navBarConfig) => Style8BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(color: theme.scaffoldBackgroundColor),
      ),
    );
  }

  List<PersistentTabConfig> _buildScreens() {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primaryContainer;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return [
      PersistentTabConfig(
        screen: const HomeScreen(),
        item: ItemConfig(
          icon: const FaIcon(FontAwesomeIcons.house),
          title: "home_menu".tr(),
          // Renkleri ata
          activeForegroundColor: activeColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
      PersistentTabConfig(
        screen: const EarthquakeMapScreen(),
        item: ItemConfig(
          icon: const FaIcon(FontAwesomeIcons.mapLocation),
          title: "map".tr(),
          activeForegroundColor: activeColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
      PersistentTabConfig(
        screen: const EarthquakeListScreen(),
        item: ItemConfig(
          icon: const FaIcon(FontAwesomeIcons.solidRectangleList),
          title: "earthquakes".tr(),
          activeForegroundColor: activeColor,
          inactiveForegroundColor: inactiveColor,
        ),
      ),
    ];
  }
}
