import 'package:earthquake_mapp/core/routes/app_routes.dart';
import 'package:earthquake_mapp/features/providers/auth_provider.dart';
import 'package:earthquake_mapp/features/screens/auth/login_form.dart';
import 'package:earthquake_mapp/shared/widgets/button/grid_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    final List<IconData> iconList = [
      FontAwesomeIcons.user,
      FontAwesomeIcons.peopleGroup,
      FontAwesomeIcons.gear,
      FontAwesomeIcons.bell,
    ];

    final List<String> labels = [
      'account'.tr(),
      'assembly_points'.tr(),
      'settings'.tr(),
      'notifications'.tr(),
    ];

    final List<VoidCallback> actions = [
      () {
        if (user != null) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(AppRoutes.profile);
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
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(AppRoutes.earthquakeAssembly);
      },
      () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(AppRoutes.settings);
      },
      () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('notifications_coming').tr()));
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
                    return GridButton(
                      iconData: iconList[index],
                      label: labels[index],
                      onPressed: actions[index],
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
