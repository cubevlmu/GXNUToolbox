/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

class ApiConstants {
  static const String baseUrl = 'https://jwxt.gxnu.edu.cn';
  static const String ssoBaseUrl = 'https://sso.gxnu.edu.cn';
  static const String chaoxingBaseUrl = 'https://gxnu.mh.chaoxing.com';
  static const String chaoxingReferer = '$chaoxingBaseUrl/';
  static const String chaoxingEntryLoginUrl = '$chaoxingBaseUrl/entry/login';
  static const String chaoxingSsoBridgeUrl =
      'https://fysso.chaoxing.com/cassso/togxnu?refer=$chaoxingReferer';
  static const String chaoxingCasServiceUrl =
      'https://fysso.chaoxing.com/cassso/gxnu';
  static const String chaoxingFinalCheckUrl = '$chaoxingBaseUrl/';
  static const String jwjxBaseUrl = 'https://jwjx.gxnu.edu.cn';
  static const String jwjxEntryUrl = '$jwjxBaseUrl/';
  static const String jwjxWeekMetaUrl =
      '$jwjxBaseUrl/jw/admin/api/getRqListByWeek';
  static const String jwjxClassTableContextUrl =
      '$jwjxBaseUrl/jw/admin/pkgl/xskb/queryKbForXsd';
  static const String jwjxGradePageUrl =
      '$jwjxBaseUrl/jw/admin/xsd/xsdzgcjcx/zgcjcx';
  static const String jwjxGradeFilterPageUrl = '$jwjxGradePageUrl?fxtype=1';
  static const String jwjxGradeListUrl =
      '$jwjxBaseUrl/jw/admin/xsd/xsdzgcjcx/xsdQueryXszgcjList';
  static const String jwjxGradeRankUrl =
      '$jwjxBaseUrl/jw/admin/xsd/xsdzgcjcx/getXxzyXspm';
  static const String jwjxExamListUrl =
      '$jwjxBaseUrl/jw/admin/xsd/kwglXsdKscx/ajaxXsksList';
  static const String jwjxExamPageUrl = '$jwjxBaseUrl/jw/admin/xsd/kwglXsdKscx';
  static const String jwjxExamBatchUrl =
      '$jwjxBaseUrl/jw/admin/xsd/kwglXsdKscx/getKspc';
  static const String jwjxStudentCardUrl =
      '$jwjxBaseUrl/jw/admin/xsd/xsjbxx/xskp';
  static const String jwjxBellScheduleUrl =
      '$jwjxBaseUrl/jw/admin/xsd/jcsj/xlgl/selectJxzxsjXq';
  static const String jwjxSchoolCalendarDataUrl =
      '$jwjxBaseUrl/jw/admin/xsd/jcsj/xlgl/getData';
  static const String jwjxSchoolCalendarPageUrl =
      '$jwjxBaseUrl/jw/admin//xsd/jcsj/xlgl/queryXlForXsd';
  static const String jwjxCoursePlanUrl =
      '$jwjxBaseUrl/jw/admin/xsd/xyjc/getkcjclist';
  static const String jwjxCreditProgressUrl =
      '$jwjxBaseUrl/jw/admin/xsd/xyjc/listXyjc';
  static const String jwjxSelectedCoursePageUrl =
      '$jwjxBaseUrl/jw/admin/xsd/yxkccx';
  static const String jwjxSelectedCourseListUrl =
      '$jwjxBaseUrl/jw/admin/xsd/yxkccx/listYxkc';
  static const String jwjxMessageListUrl =
      '$jwjxBaseUrl/jw/admin/workcenter/message/getList';
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36';
}
