import 'package:earthquake_mapp/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSelectionModal extends ConsumerWidget {
  const ThemeSelectionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedTheme = _themeModeToString(themeMode);

    final themes = ["Açık", "Koyu", "Sistem Varsayılanı"];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Buraya tutamaç çizgisi ekle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Text(
            "Tema Seçimi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    .setTheme(_stringToThemeMode(theme));

                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Açık";
      case ThemeMode.dark:
        return "Koyu";
      case ThemeMode.system:
        return "Sistem Varsayılanı";
    }
  }

  ThemeMode _stringToThemeMode(String str) {
    switch (str) {
      case "Açık":
        return ThemeMode.light;
      case "Koyu":
        return ThemeMode.dark;
      case "Sistem Varsayılanı":
      default:
        return ThemeMode.system;
    }
  }
}
