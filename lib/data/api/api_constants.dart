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
  static const String userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36';
}
