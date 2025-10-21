import 'package:earthquake_mapp/core/utils/logger_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettings extends StateNotifier<NotificationSettingsState> {
  NotificationSettings() : super(NotificationSettingsState());

  Future<bool> requestNotificationPermission() async {
    LoggerHelper.info(
      "NotificationSettings",
      "Requesting notification permission...",
    );
    var status = await Permission.notification.status;
    if (status.isDenied) {
      LoggerHelper.warning(
        "NotificationSettings",
        "Permission denied, requesting permission...",
      );
      status = await Permission.notification.request();
    }
    final granted = status.isGranted;
    LoggerHelper.info(
      "NotificationSettings",
      "Notification permission granted: $granted",
    );
    if (!granted) {
      LoggerHelper.warning(
        "NotificationSettings",
        "Permission not granted, disabling all notifications.",
      );
      disableAllNotifications();
    }
    return granted;
  }

  Future<void> setGeneralNotification(bool enabled) async {
    LoggerHelper.debug(
      "NotificationSettings",
      "Setting general notification to $enabled",
    );
    if (enabled) {
      final granted = await requestNotificationPermission();
      if (granted) {
        state = state.copyWith(general: true);
        LoggerHelper.info(
          "NotificationSettings",
          "General notification enabled",
        );
      } else {
        state = state.copyWith(general: false);
        LoggerHelper.warning(
          "NotificationSettings",
          "General notification denied by user",
        );
      }
    } else {
      disableAllNotifications();
      LoggerHelper.info(
        "NotificationSettings",
        "General notification disabled, all notifications off",
      );
    }
  }

  void setAppNotification(bool enabled) {
    LoggerHelper.debug(
      "NotificationSettings",
      "Setting app notification to $enabled",
    );
    state = state.copyWith(app: enabled);
  }

  void setEmailNotification(bool enabled) {
    LoggerHelper.debug(
      "NotificationSettings",
      "Setting email notification to $enabled",
    );
    state = state.copyWith(email: enabled);
  }

  void setSilentHours(bool enabled) {
    LoggerHelper.debug(
      "NotificationSettings",
      "Setting silent hours to $enabled",
    );
    state = state.copyWith(silentHours: enabled);
  }

  void disableAllNotifications() {
    LoggerHelper.info("NotificationSettings", "Disabling all notifications");
    state = state.copyWith(
      general: false,
      app: false,
      email: false,
      silentHours: false,
    );
  }
}

class NotificationSettingsState {
  final bool general;
  final bool app;
  final bool email;
  final bool silentHours;

  NotificationSettingsState({
    this.general = false,
    this.app = false,
    this.email = false,
    this.silentHours = false,
  });

  NotificationSettingsState copyWith({
    bool? general,
    bool? app,
    bool? email,
    bool? silentHours,
  }) {
    return NotificationSettingsState(
      general: general ?? this.general,
      app: app ?? this.app,
      email: email ?? this.email,
      silentHours: silentHours ?? this.silentHours,
    );
  }
}

// Riverpod provider
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettings, NotificationSettingsState>(
      (ref) => NotificationSettings(),
    );
