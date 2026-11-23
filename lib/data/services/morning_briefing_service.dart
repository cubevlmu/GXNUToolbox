import 'dart:io';

import 'package:class_tool/data/model/today_course_snapshot.dart';
import 'package:class_tool/data/services/today_snapshot_cache.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const String _morningBriefingEnabledKey = 'morning_briefing_enabled';
const String _morningBriefingChannelId = 'morning_briefing';
const String _notificationPermissionRequestedKey =
    'notification_permission_requested_once';
const String _lastMorningBriefingDateKey = 'morning_briefing_last_shown_date';
const int _morningBriefingNotificationId = 1001;

class MorningBriefingService {
  const MorningBriefingService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _timeZoneInitialized = false;

  static bool get isEnabled =>
      StorageUtils.settings.get(_morningBriefingEnabledKey) == true;

  static bool hasShownToday() {
    final lastDate =
        StorageUtils.settings.get(_lastMorningBriefingDateKey)?.toString() ??
        '';
    return lastDate == _dateText(DateTime.now());
  }

  static void ensureTimeZoneInitialized() {
    if (_timeZoneInitialized) {
      return;
    }
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (_) {}
    _timeZoneInitialized = true;
  }

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    ensureTimeZoneInitialized();
    if (!Platform.isAndroid) {
      _initialized = true;
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      _morningBriefingChannelId,
      '早安课表提醒',
      description: '每日早间课程提醒',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await _requestNotificationPermissionIfNeeded();
    _initialized = true;

    if (isEnabled) {
      await scheduleDaily();
    }
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
    try {
      if (enabled) {
        await scheduleDaily();
      } else {
        await _plugin.cancel(id: _morningBriefingNotificationId);
      }
    } catch (e, s) {
      LogUtil.warnE('Failed to set morning briefing enabled.', e, s);
    }
    return enabled;
  }

  static Future<void> scheduleDaily({TodayCourseSnapshot? snapshot}) async {
    if (!Platform.isAndroid || !isEnabled) {
      return;
    }

    await initialize();
    final effectiveSnapshot = snapshot ?? TodaySnapshotCache.load();
    final title = effectiveSnapshot != null
        ? _buildTitle(effectiveSnapshot)
        : '早上好，点击查看今日课表';
    final body = effectiveSnapshot != null
        ? _buildBody(effectiveSnapshot)
        : '记得查看今天的课程与教室安排。';

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final scheduleMode = await _resolveScheduleMode();
    final androidDetails = AndroidNotificationDetails(
      _morningBriefingChannelId,
      '早安课表提醒',
      channelDescription: '每日早间课程提醒',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    try {
      await _plugin.zonedSchedule(
        id: _morningBriefingNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      LogUtil.info(
        '[MorningBriefing] scheduled daily at $scheduledDate mode=$scheduleMode',
      );
    } catch (e, s) {
      LogUtil.warnE('[MorningBriefing] scheduleDaily failed', e, s);
    }
  }

  static Future<AndroidScheduleMode> _resolveScheduleMode() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    try {
      final canExact = await androidPlugin.canScheduleExactNotifications();
      if (canExact == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    } catch (_) {}
    return AndroidScheduleMode.inexactAllowWhileIdle;
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
      channelDescription: '每日早间课程提醒',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    await _plugin.show(
      id: _morningBriefingNotificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
    await StorageUtils.settings.put(
      _lastMorningBriefingDateKey,
      _dateText(DateTime.now()),
    );
  }

  static String _dateText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
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
