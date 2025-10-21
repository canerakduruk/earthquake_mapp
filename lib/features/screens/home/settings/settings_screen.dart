import 'package:earthquake_mapp/features/providers/theme_provider.dart';
import 'package:earthquake_mapp/features/screens/home/settings/language_selection_modal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme_selection_modal.dart';
import 'notification_settings_modal.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedTheme = _themeModeToString(themeMode, context);

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('general'.tr()),
          _buildTile(
            FontAwesomeIcons.moon,
            'theme'.tr(),
            subtitle: selectedTheme,
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const ThemeSelectionModal(),
              );
            },
          ),
          _buildTile(
            FontAwesomeIcons.language,
            'language'.tr(),
            subtitle: context.locale.languageCode == 'tr'
                ? 'Türkçe'
                : 'English',
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const LanguageSelectionModal(),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('notifications'.tr()),
          _buildTile(
            FontAwesomeIcons.bell,
            'notification_settings'.tr(),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const NotificationSettingsModal(),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('help_support'.tr()),
          _buildTile(FontAwesomeIcons.commentDots, 'send_feedback'.tr()),
          _buildTile(FontAwesomeIcons.circleQuestion, 'faq'.tr()),
          _buildTile(FontAwesomeIcons.headset, 'contact_support'.tr()),
          const SizedBox(height: 24),
          _buildSectionTitle('about'.tr()),
          _buildTile(
            FontAwesomeIcons.circleInfo,
            'app_version'.tr(),
            subtitle: 'v1.0.0',
          ),
          _buildTile(FontAwesomeIcons.userShield, 'privacy_policy'.tr()),
          _buildTile(FontAwesomeIcons.fileContract, 'terms_of_use'.tr()),
          _buildTile(FontAwesomeIcons.codeBranch, 'open_source_licenses'.tr()),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    String? subtitle,
  }) {
    return ListTile(
      leading: FaIcon(icon, size: 20),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      return 'theme_system'.tr();
    }
  }
}
