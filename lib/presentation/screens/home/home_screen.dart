import 'package:earthquake_mapp/presentation/screens/home/profile_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<IconData> iconList = [
      FontAwesomeIcons.user,
      FontAwesomeIcons.peopleGroup,
      FontAwesomeIcons.gear,
      FontAwesomeIcons.bell,
    ];

    final List<String> labels = [
      'Hesabım',
      'Toplanma Yerleri',
      'Ayarlar',
      'Bildirimler',
    ];

    final List<VoidCallback> actions = [
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
      () {
        // Toplanma yerleri ekranına git (henüz yoksa boş bırak)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Toplanma Yerleri açılacak")),
        );
      },

      () {
        // Ayarlar ekranı
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
      () {
        // Bildirimler ekranı
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Bildirimler açılacak")));
      },
    ];

    final orientation = MediaQuery.of(context).orientation;
    final crossAxisCount = orientation == Orientation.landscape ? 3 : 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/icons/full_logo_horizontal.png',
                height: 80,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: List.generate(labels.length, (index) {
                    return ElevatedButton(
                      onPressed: actions[index],
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(iconList[index], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            labels[index],
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
