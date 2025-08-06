import 'package:earthquake_mapp/presentation/screens/earthquake_list/earthquake_list_screen.dart';
import 'package:earthquake_mapp/presentation/screens/earthquake_map/earthquake_map_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottombarNavScreen extends StatelessWidget {
  const BottombarNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PersistentTabController controller = PersistentTabController(
      initialIndex: 0,
    );

    return MaterialApp(
      title: 'Persistent Bottom Navigation Bar Demo',
      home: PersistentTabView(
        controller: controller,
        tabs: _buildScreens(),
        navBarBuilder: (navBarConfig) =>
            Style8BottomNavBar(navBarConfig: navBarConfig),
      ),
    );
  }

  List<PersistentTabConfig> _buildScreens() {
    return [
      PersistentTabConfig(
        screen: const HomeScreen(),
        item: ItemConfig(
          icon: FaIcon(FontAwesomeIcons.house),
          title: "Ana Menü",
        ),
      ),
      PersistentTabConfig(
        screen: const EarthquakeMapScreen(),
        item: ItemConfig(
          icon: FaIcon(FontAwesomeIcons.mapLocation),
          title: "Harita",
        ),
      ),
      PersistentTabConfig(
        screen: const EarthquakeListScreen(),
        item: ItemConfig(
          icon: FaIcon(FontAwesomeIcons.solidRectangleList),
          title: "Depremler",
        ),
      ),
    ];
  }
}
