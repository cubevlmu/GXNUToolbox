import 'dart:io';

import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String _morningBriefingEnabledKey = 'morning_briefing_enabled';
const String _morningBriefingChannelId = 'morning_briefing';
const String _notificationPermissionRequestedKey =
    'notification_permission_requested_once';

class MorningBriefingService {
  const MorningBriefingService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static bool get isEnabled =>
      StorageUtils.settings.get(_morningBriefingEnabledKey) == true;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    );
    await _plugin.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      _morningBriefingChannelId,
      '早安课表提醒',
      description: '每日同步完成后的课程提醒',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await _requestNotificationPermissionIfNeeded();
    _initialized = true;
  }

  static Future<bool> setEnabled(bool enabled) async {
    await initialize();
    if (enabled && Platform.isAndroid) {
      final granted = await _requestNotificationPermissionIfNeeded(
        forceRequest: true,
      );
      if (!granted) {
        await StorageUtils.settings.put(_morningBriefingEnabledKey, false);
        return false;
      }
    }

    await StorageUtils.settings.put(_morningBriefingEnabledKey, enabled);
    if (!enabled) {
      await _plugin.cancel(id: 1001);
    }
    return enabled;
  }

  static Future<bool> _requestNotificationPermissionIfNeeded({
    bool forceRequest = false,
  }) async {
    if (!Platform.isAndroid) {
      return true;
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) {
      return true;
    }

    final alreadyRequested =
        StorageUtils.settings.get(_notificationPermissionRequestedKey) == true;
    if (alreadyRequested && !forceRequest) {
      return await androidPlugin.areNotificationsEnabled() ?? true;
    }

    final granted =
        await androidPlugin.requestNotificationsPermission() ?? true;
    await StorageUtils.settings.put(_notificationPermissionRequestedKey, true);
    return granted;
  }

  static Future<void> show(TodayCourseSnapshot snapshot) async {
    if (!Platform.isAndroid || !isEnabled) {
      return;
    }

    await initialize();
    final title = _buildTitle(snapshot);
    final body = _buildBody(snapshot);

    final androidDetails = AndroidNotificationDetails(
      _morningBriefingChannelId,
      '早安课表提醒',
      channelDescription: '每日同步完成后的课程提醒',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      styleInformation: BigTextStyleInformation(body),
    );

    await _plugin.show(
      id: 1001,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  static String _buildTitle(TodayCourseSnapshot snapshot) {
    final count = snapshot.items.length;
    if (count == 0) {
      return '早上好，今天没有课程安排';
    }
    return '早上好，今天有$count节课';
  }

  static String _buildBody(TodayCourseSnapshot snapshot) {
    if (snapshot.items.isEmpty) {
      return '今天可以轻松一点，祝你一切顺利。';
    }

    final first = snapshot.items.first;
    return '第一节课 ${first.timeText}\n${first.roomText} · ${first.titleText}';
  }
}
