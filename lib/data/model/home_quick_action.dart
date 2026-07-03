enum HomeQuickActionPreference {
  grades,
  exams,
  tasks,
  attendance,
  selectedCourses,
  credit,
  progress,
  studentInfo,
  time,
  schoolCalendar,
  classroom,
  notifications;

  String get label {
    switch (this) {
      case HomeQuickActionPreference.grades:
        return '成绩查询';
      case HomeQuickActionPreference.exams:
        return '考试安排';
      case HomeQuickActionPreference.tasks:
        return '待办任务';
      case HomeQuickActionPreference.attendance:
        return '统计';
      case HomeQuickActionPreference.selectedCourses:
        return '已选课程';
      case HomeQuickActionPreference.credit:
        return '学分进程';
      case HomeQuickActionPreference.progress:
        return '培养进度';
      case HomeQuickActionPreference.studentInfo:
        return '学生信息';
      case HomeQuickActionPreference.time:
        return '作息时间';
      case HomeQuickActionPreference.schoolCalendar:
        return '校历';
      case HomeQuickActionPreference.classroom:
        return '教室查询';
      case HomeQuickActionPreference.notifications:
        return '通知公告';
    }
  }
}

HomeQuickActionPreference? homeQuickActionPreferenceFromName(String value) {
  for (final item in HomeQuickActionPreference.values) {
    if (item.name == value) {
      return item;
    }
  }
  return null;
}
