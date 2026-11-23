import 'dart:io';

import 'package:class_tool/data/model/course_note.dart';
import 'package:class_tool/data/services/morning_briefing_service.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class CourseNoteReminderService {
  CourseNoteReminderService._();

  static const String _channelId = 'course_note_reminders';
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    MorningBriefingService.ensureTimeZoneInitialized();
    if (!Platform.isAndroid) {
      _initialized = true;
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    const channel = AndroidNotificationChannel(
      _channelId,
      '课程任务提醒',
      description: '课程作业、备注和待办提醒',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  static int notificationIdForNote(int noteId) => 200000 + noteId;

  static Future<void> schedule(CourseNoteEntry entry) async {
    final remindAt = entry.note.remindAt;
    if (remindAt == null || !remindAt.isAfter(DateTime.now())) {
      await cancel(entry.note.id);
      return;
    }
    if (!Platform.isAndroid) {
      return;
    }

    await initialize();
    final typeLabel = entry.type.label;
    final title = '$typeLabel提醒: ${entry.course.courseName}';
    final body = entry.note.title;
    final details = AndroidNotificationDetails(
      _channelId,
      '课程任务提醒',
      channelDescription: '课程作业、备注和待办提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canExact =
          await androidPlugin?.canScheduleExactNotifications() ?? false;
      await _plugin.zonedSchedule(
        id: notificationIdForNote(entry.note.id),
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(remindAt, tz.local),
        notificationDetails: NotificationDetails(android: details),
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e, s) {
      LogUtil.warnE('[CourseNoteReminder] schedule failed', e, s);
    }
  }

  static Future<void> cancel(int noteId) async {
    if (!Platform.isAndroid) {
      return;
    }
    await initialize();
    await _plugin.cancel(id: notificationIdForNote(noteId));
  }
}
