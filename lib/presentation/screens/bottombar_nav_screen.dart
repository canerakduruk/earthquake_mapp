import 'package:earthquake_mapp/presentation/providers/auth_provider.dart';
import 'package:earthquake_mapp/presentation/providers/locale_provider.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_list_screen.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_map/earthquake_map_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/home_screen.dart';
import 'package:earthquake_mapp/presentation/viewmodels/auth_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
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

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.user == null && previous?.user != null) {
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
        navBarDecoration: NavBarDecoration(
          color: theme
              .colorScheme
              .surface, // Burada koyu tema için surface renk kullandık
        ),
      ),
    );
  }

  List<PersistentTabConfig> _buildScreens() {
    return [
      PersistentTabConfig(
        screen: const HomeScreen(),
        item: ItemConfig(
          icon: FaIcon(FontAwesomeIcons.house),
          title: "home_menu".tr(), // burayı çeviri anahtarına göre değiştir
        ),
      ),
      PersistentTabConfig(
        screen: const EarthquakeMapScreen(),
        item: ItemConfig(
          icon: FaIcon(FontAwesomeIcons.mapLocation),
          title: "map".tr(),
        ),
      ),
      PersistentTabConfig(
        screen: const EarthquakeListScreen(),
        item: ItemConfig(
          icon: FaIcon(FontAwesomeIcons.solidRectangleList),
          title: "earthquakes".tr(),
        ),
      ),
    ];
  }
}
