import 'package:earthquake_mapp/features/providers/notifications_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsModal extends ConsumerWidget {
  const NotificationSettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifSettings = ref.watch(notificationSettingsProvider);
    final notifController = ref.read(notificationSettingsProvider.notifier);

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
            'notification_settings_title'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: Text('enable_notifications'.tr()),
            value: notifSettings.general,
            onChanged: (val) async {
              await notifController.setGeneralNotification(val);
              if (!val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('notifications_disabled'.tr())),
                );
              } else {
                final granted = await notifController
                    .requestNotificationPermission();
                if (!granted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('notification_permission_denied'.tr()),
                    ),
                  );
                }
              }
            },
          ),

          if (notifSettings.general) ...[
            SwitchListTile(
              title: Text('app_notifications'.tr()),
              value: notifSettings.app,
              onChanged: notifController.setAppNotification,
            ),
            SwitchListTile(
              title: Text('email_notifications'.tr()),
              value: notifSettings.email,
              onChanged: notifController.setEmailNotification,
            ),
            SwitchListTile(
              title: Text('silent_hours'.tr()),
              value: notifSettings.silentHours,
              onChanged: notifController.setSilentHours,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
