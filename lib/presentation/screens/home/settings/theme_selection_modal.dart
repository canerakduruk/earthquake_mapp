import 'package:earthquake_mapp/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class ThemeSelectionModal extends ConsumerWidget {
  const ThemeSelectionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedTheme = _themeModeToString(themeMode, context);

    final themes = ['theme_light'.tr(), 'theme_dark'.tr(), 'theme_system'.tr()];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tutamaç çizgisi
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Text(
            'theme_selection'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...themes.map((theme) {
            final isSelected = theme == selectedTheme;
            return ListTile(
              title: Text(theme),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                ref
                    .read(themeModeProvider.notifier)
                    .setTheme(_stringToThemeMode(theme, context));
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _themeModeToString(ThemeMode mode, BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return 'theme_light'.tr();
      case ThemeMode.dark:
        return 'theme_dark'.tr();
      case ThemeMode.system:
      default:
        return 'theme_system'.tr();
    }
  }

  ThemeMode _stringToThemeMode(String str, BuildContext context) {
    if (str == 'theme_light'.tr()) return ThemeMode.light;
    if (str == 'theme_dark'.tr()) return ThemeMode.dark;
    return ThemeMode.system;
  }
}
