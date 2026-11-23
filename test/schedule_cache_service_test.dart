import 'dart:io';

import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/services/schedule_cache_service.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gxnu_schedule_cache_test');
    Hive.init(tempDir.path);
    StorageUtils.cache = await Hive.openBox<dynamic>('cache');
  });

  tearDownAll(() async {
    await StorageUtils.cache.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'saves and restores schedule context, meta, weekMeta, courses, and pointer',
    () async {
      const userId = 'u_test_1';
      const semester = '2026-2027-1';
      const week = 5;

      final context = ClassTablePageContext(
        userContext: const ClassTableUserContext(
          selectedSemester: semester,
          userId: userId,
          campusId: '3',
          selectedCampusId: '3',
        ),
        semesters: const [
          ClassTableSemester(value: semester, label: semester, isActive: true),
        ],
      );

      final metaResponse = ClassTableMetaResponse.fromJson(<String, dynamic>{
        'ret': 0,
        'msg': 'ok',
        'data': <String, dynamic>{
          'dqzc': '5',
          'jcsjszList': <Map<String, dynamic>>[
            <String, dynamic>{
              'kssj': '08:30',
              'jssj': '09:15',
              'jc': '1',
              'jcbm': '第一节',
            },
          ],
          'zclist': <Map<String, dynamic>>[
            <String, dynamic>{'zc': '5', 'sjfw': '09.28-10.04'},
          ],
          'jsxq': <String, dynamic>{},
        },
      });

      final weekMeta = <ClassMeta>[
        ClassMeta.fromJson(<String, dynamic>{
          'zc': 5,
          'rq': '2026-09-28',
          'xqbh': 1,
          'xqmc': '星期一',
          'day': '28',
          'lunarCalendar': '八月十八',
        }),
      ];

      final courseResponse = ClassTableCourseResponse.fromJson(
        <String, dynamic>{
          'ret': 0,
          'msg': 'ok',
          'data': <String, dynamic>{
            'kckbData': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'c1',
                'jxbid': 'tc1',
                'pkid': 'pk1',
                'kcmc': '高等数学',
                'jsxm': '张老师',
                'jsmc': 'A101',
                'xq': 1,
                'jc': 1,
              },
            ],
          },
        },
      );

      await ScheduleCacheService.savePageContext(context);
      await ScheduleCacheService.saveMeta(
        userId: userId,
        semester: semester,
        response: metaResponse,
      );
      await ScheduleCacheService.saveWeekMeta(
        userId: userId,
        semester: semester,
        week: week,
        items: weekMeta,
      );
      await ScheduleCacheService.saveCourses(
        userId: userId,
        semester: semester,
        week: week,
        response: courseResponse,
      );
      await ScheduleCacheService.saveLatestPointer(
        userId: userId,
        semester: semester,
        week: week,
        isHoliday: false,
      );

      final loadedCtx = ScheduleCacheService.loadPageContext(
        userId: userId,
        semester: semester,
      );
      final loadedMeta = ScheduleCacheService.loadMeta(
        userId: userId,
        semester: semester,
      );
      final loadedWeekMeta = ScheduleCacheService.loadWeekMeta(
        userId: userId,
        semester: semester,
        week: week,
      );
      final loadedCourses = ScheduleCacheService.loadCourses(
        userId: userId,
        semester: semester,
        week: week,
      );
      final loadedPointer = ScheduleCacheService.loadLatestPointer(userId);

      expect(loadedCtx, isNotNull);
      expect(loadedCtx!.userContext.userId, userId);
      expect(loadedCtx.semesters.length, 1);

      expect(loadedMeta, isNotNull);
      expect(loadedMeta!.data.currentWeek, 5);

      expect(loadedWeekMeta, isNotNull);
      expect(loadedWeekMeta!.single.dateTimeText, '2026-09-28');

      expect(loadedCourses, isNotNull);
      expect(loadedCourses!.data.courses.single.courseName, '高等数学');

      expect(loadedPointer, isNotNull);
      expect(loadedPointer!.semester, semester);
      expect(loadedPointer.week, week);
      expect(loadedPointer.isHoliday, isFalse);
    },
  );

  test('returns null safely when cached JSON is corrupted', () async {
    await StorageUtils.cache.put(
      'schedule_meta_v1|bad|2026-1',
      '{invalid-json',
    );
    expect(
      ScheduleCacheService.loadMeta(userId: 'bad', semester: '2026-1'),
      isNull,
    );
  });
}
