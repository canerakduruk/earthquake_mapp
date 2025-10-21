import 'package:earthquake_mapp/features/providers/auth_provider.dart';
import 'package:earthquake_mapp/features/screens/home/profile/edit_profile/edit_profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('profile.title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: 'profile.account_info'.tr(),
              iconData: FontAwesomeIcons.userLarge,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            ProfileMenu(
              text: 'profile.my_contacts'.tr(),
              iconData: FontAwesomeIcons.usersBetweenLines,
              press: () {},
            ),
            ProfileMenu(
              text: 'profile.location_settings'.tr(),
              iconData: FontAwesomeIcons.locationCrosshairs,
              press: () {},
            ),
            ProfileMenu(
              text: 'profile.help_center'.tr(),
              iconData: FontAwesomeIcons.circleQuestion,
              press: () {},
            ),
            ProfileMenu(
              text: 'profile.sign_out'.tr(),
              iconData: FontAwesomeIcons.rightFromBracket,
              press: () async {
                await ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 100, color: Colors.white),
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {},
                child: const FaIcon(FontAwesomeIcons.camera),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.iconData,
    this.press,
  });

  final String text;
  final IconData iconData;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF7643),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.orangeAccent.withAlpha(30),
        ),
        onPressed: press,
        child: Row(
          children: [
            FaIcon(iconData, color: const Color(0xFFFF7643), size: 22),
            const SizedBox(width: 20),
            Expanded(
              child: Text(text),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.deepOrangeAccent),
          ],
        ),
      ),
    );
  }
}
