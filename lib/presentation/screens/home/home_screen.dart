import 'package:earthquake_mapp/presentation/providers/auth_provider.dart';
import 'package:earthquake_mapp/presentation/screens/form/login_form.dart';
import 'package:earthquake_mapp/presentation/screens/home/earthquake_assembly_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/profile/profile_screen.dart';
import 'package:earthquake_mapp/presentation/screens/home/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).user;

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
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const LoginForm(),
          );
        }
      },
      () {
        // Toplanma yerleri ekranına git (henüz yoksa boş bırak)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EarthquakeAssemblyScreen(),
          ),
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
