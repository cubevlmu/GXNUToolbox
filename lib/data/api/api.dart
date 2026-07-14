import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:class_tool/data/api/api_diagnostics.dart';
import 'package:class_tool/data/api/api_exception.dart';
import 'package:class_tool/data/api/api_constants.dart';
import 'package:class_tool/data/model/bell_schedule.dart';
import 'package:class_tool/data/model/chaoxing_login_result.dart';
import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/model/course_plan.dart';
import 'package:class_tool/data/model/credit_progress.dart';
import 'package:class_tool/data/model/exam.dart';
import 'package:class_tool/data/model/grade.dart';
import 'package:class_tool/data/model/school_calendar.dart';
import 'package:class_tool/data/model/school_notification.dart';
import 'package:class_tool/data/model/selected_course.dart';
import 'package:class_tool/data/model/student_info.dart';
import 'package:class_tool/utils/http_utils.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;

export 'package:class_tool/data/api/api_exception.dart';

class _RedirectedHtmlResponse {
  const _RedirectedHtmlResponse({
    required this.response,
    required this.redirectChain,
  });

  final Response<String> response;
  final List<String> redirectChain;
}

enum _UnexpectedHtmlPageKind {
  casLogin,
  captcha,
  rateLimited,
  accessRestricted,
  securityVerification,
  waf,
  blank,
  unknown,
}

class Api {
  Api._();

  static final HttpUtils _http = HttpUtils();
  static Future<void> _htmlRequestQueue = Future<void>.value();
  static DateTime? _lastHtmlRequestAt;
  static const Duration _htmlRequestMinInterval = Duration(milliseconds: 250);
  static const List<Duration> _tooManyRequestsBackoff = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];
  static const String _gradeQueryFields =
      'id,xnxq,kcmc,kclx,bkbz,xf,kcxz,ksxs,xdxz,zhcj,tscjzwmc,cjfxms,hdxf,jd,glcj,cxzkcj,bkcj,cxcj,fxcj,kkyxmc,';

  static Future<ChaoxingLoginResult> login({
    required String username,
    required String password,
    String authCode = '',
    bool rememberMe = false,
    bool clearBeforeLogin = true,
  }) async {
    await _http.init();
    final trace = ApiDiagnostics.startLoginTrace();

    try {
      if (clearBeforeLogin) {
        await _http.clearCookies();
      }

      trace.logPhase('cas_bridge');
      var casPage = await _requestCasBridge();
      trace.logResponse(
        'cas_bridge',
        casPage.response,
        redirectCount: casPage.redirectChain.length,
      );

      trace.logPhase('cas_form_parse');
      var formFields = _extractFormInputs(casPage.response.data ?? '');
      var formAction =
          _extractFormAction(casPage.response.data ?? '') ?? '/cas/login';
      if (!_hasCasLoginForm(formFields, casPage.response.data ?? '')) {
        trace.logPhase('chaoxing_entry_login');
        final entryResponse = await _getHtml(
          ApiConstants.chaoxingEntryLoginUrl,
        );
        trace.logResponse('chaoxing_entry_login', entryResponse);

        trace.logPhase('cas_bridge_retry');
        casPage = await _requestCasBridge();
        trace.logResponse(
          'cas_bridge_retry',
          casPage.response,
          redirectCount: casPage.redirectChain.length,
        );

        trace.logPhase('cas_form_parse');
        formFields = _extractFormInputs(casPage.response.data ?? '');
        formAction =
            _extractFormAction(casPage.response.data ?? '') ?? '/cas/login';
      }
      if (!_hasCasLoginForm(formFields, casPage.response.data ?? '')) {
        throw const ApiUnexpectedHtmlException('未能识别统一身份认证登录表单，学校页面结构可能变化');
      }
      final postUrl = _resolveUrl(
        casPage.response.realUri.toString(),
        formAction,
      );

      trace.logPhase('rsa_pubkey_fetch');
      final rsaKey = await _fetchPubKey(casPage.response.realUri.toString());
      final encryptedPassword = _encryptPasswordJsCompatible(password, rsaKey);

      formFields['username'] = username;
      formFields['password'] = encryptedPassword;
      formFields['mobileCode'] = formFields['mobileCode'] ?? '';
      formFields['authcode'] = authCode;
      if (rememberMe) {
        formFields['rememberMe'] = 'true';
      } else {
        formFields.remove('rememberMe');
      }
      formFields['_eventId'] = formFields['_eventId'] ?? 'submit';

      trace.logPhase('cas_login_post');
      final loginResponse = await _postFormWithRedirects(
        postUrl,
        data: formFields,
        referer: casPage.response.realUri.toString(),
      );
      trace.logResponse(
        'cas_login_post',
        loginResponse.response,
        redirectCount: loginResponse.redirectChain.length,
      );
      _throwIfCasLoginFailed(loginResponse);

      final finalCheckRedirectChain = <String>[];
      if (!_isSameUrl(
        loginResponse.response.realUri.toString(),
        ApiConstants.chaoxingFinalCheckUrl,
      )) {
        trace.logPhase('cas_final_check');
        final finalResponse = await _getHtmlWithRedirects(
          ApiConstants.chaoxingFinalCheckUrl,
          referer: ApiConstants.chaoxingFinalCheckUrl,
        );
        trace.logResponse(
          'cas_final_check',
          finalResponse.response,
          redirectCount: finalResponse.redirectChain.length,
        );
        _throwIfCasLoginFailed(finalResponse);
        finalCheckRedirectChain.addAll(finalResponse.redirectChain);
      }

      trace.logPhase('jwjx_bootstrap');
      final jwjxBootstrapResponse = await _bootstrapJwjxSession();
      trace.logResponse(
        'jwjx_bootstrap',
        jwjxBootstrapResponse.response,
        redirectCount: jwjxBootstrapResponse.redirectChain.length,
      );

      trace.logPhase('jwjx_context_parse');
      return ChaoxingLoginResult(
        html: jwjxBootstrapResponse.response.data ?? '',
        finalUrl: jwjxBootstrapResponse.response.realUri.toString(),
        statusCode: jwjxBootstrapResponse.response.statusCode ?? 0,
        cookies: await _http.getCookieMap(ApiConstants.jwjxBaseUrl),
        redirectChain: [
          ...casPage.redirectChain,
          ...loginResponse.redirectChain,
          ...finalCheckRedirectChain,
          ...jwjxBootstrapResponse.redirectChain,
        ],
      );
    } catch (e) {
      trace.logError(trace.lastPhase ?? 'login', e);
      rethrow;
    }
  }

  static Future<List<ClassMeta>> getWeekMeta({
    required String semester,
    required int week,
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxWeekMetaUrl,
      queryParameters: {'xnxq': semester, 'week': week.toString()},
      headers: {
        HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
        HttpHeaders.refererHeader: ApiConstants.jwjxBaseUrl,
      },
    );

    final rawList = _decodeJsonListResponse(response, 'class week meta');
    return rawList
        .whereType<Map>()
        .map(
          (item) => ClassMeta.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList(growable: false);
  }

  static Future<ClassTableCourseResponse> getClassTableCourses({
    required String semester,
    required String userId,
    required int week,
    String campusId = '',
    String role = 'xs',
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      '${ApiConstants.jwjxBaseUrl}/jw/admin/api/getXskb',
      queryParameters: {
        'xnxq': semester,
        'userId': userId,
        'week': week.toString(),
        'role': role,
      },
      headers: {
        HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
        HttpHeaders.refererHeader: ApiConstants.jwjxBaseUrl,
      },
    );

    final json = _decodeJsonMapResponse(response, 'class table courses');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }

    return ClassTableCourseResponse.fromJson(json);
  }

  static Future<GradeQueryResponse> getGradeList({
    String startSemester = '001',
    String endSemester = '001',
    int page = 1,
    int pageSize = 20,
    String passStatus = '',
    String courseNature = '',
    String courseType = '',
    String retakeFlag = '',
    String showFollowed = '1',
    String courseAttribution = '',
    String sort = 'kcmc asc,id',
    String order = 'asc',
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxGradeListUrl,
      queryParameters: {
        'fxbz': '0',
        'gridtype': 'jqgrid',
        'queryFields': _gradeQueryFields,
        '_search': 'false',
        'nd': DateTime.now().millisecondsSinceEpoch.toString(),
        'page.size': pageSize.toString(),
        'page.pn': page.toString(),
        'sort': sort,
        'order': order,
        'startXnxq': startSemester,
        'endXnxq': endSemester,
        'sfjg': passStatus,
        'kcxz': courseNature,
        'kclx': courseType,
        'bkbz': retakeFlag,
        'sfxsgz': showFollowed,
        'kcgs': courseAttribution,
        'query.startXnxq||': startSemester,
        'query.endXnxq||': endSemester,
        'query.sfjg||': passStatus,
        'query.kcxz||': courseNature,
        'query.kclx||': courseType,
        'query.bkbz||': retakeFlag,
        'query.sfxsgz||': showFollowed,
        'query.kcgs||': courseAttribution,
      },
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader: ApiConstants.jwjxGradePageUrl,
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    final json = _decodeJsonMapResponse(response, 'grade list');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid grade response',
      );
    }

    return GradeQueryResponse.fromJson(json);
  }

  static Future<GradeFilterOptions> getGradeFilterOptions() async {
    await _http.init();

    final response = await _http.get<String>(
      ApiConstants.jwjxGradeFilterPageUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          HttpHeaders.acceptHeader:
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader: ApiConstants.jwjxGradePageUrl,
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final html = response.data ?? '';
    if (_isCasLoginPage(response.realUri.toString(), html)) {
      throw const ApiLoginExpiredException();
    }

    return GradeFilterOptions.fromHtml(html);
  }

  static Future<GradeRankResponse> getGradeSummary() async {
    await _http.init();

    final rankTask = _getGradeSummaryJson(
      ApiConstants.jwjxGradeRankUrl,
      operation: 'grade rank',
    );
    final gradePointAverageTask = _getGradeSummaryJson(
      ApiConstants.jwjxGradePointAverageUrl,
      operation: 'grade point average',
    );
    final averageGradeTask = _getGradeSummaryJson(
      ApiConstants.jwjxGradeAverageScoreUrl,
      operation: 'average grade',
    );
    final responses = await Future.wait(<Future<Map<String, dynamic>>>[
      rankTask,
      gradePointAverageTask,
      averageGradeTask,
    ]);

    return GradeRankResponse.fromSummaryJson(
      rank: responses[0],
      gradePointAverage: responses[1],
      averageGrade: responses[2],
    );
  }

  static Future<Map<String, dynamic>> _getGradeSummaryJson(
    String url, {
    required String operation,
  }) async {
    final response = await _getSchoolJsonPlain(
      url,
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader: '${ApiConstants.jwjxGradePageUrl}?fxtype=9',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );
    final json = _decodeJsonMapResponse(response, operation);
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid $operation response',
      );
    }
    return json;
  }

  static Future<ExamFilterOptions> getExamFilterOptions() async {
    await _http.init();

    final response = await _http.get<String>(
      ApiConstants.jwjxExamPageUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          HttpHeaders.acceptHeader:
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    if (_isCasLoginPage(response.realUri.toString(), response.data ?? '')) {
      throw const ApiLoginExpiredException();
    }

    return ExamFilterOptions.fromHtml(response.data ?? '');
  }

  static Future<List<ExamBatchOption>> getExamBatches({
    required String semester,
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxExamBatchUrl,
      queryParameters: {'xnxq': semester},
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader: ApiConstants.jwjxExamPageUrl,
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    final jsonList = _decodeJsonListResponse(response, 'exam batches');
    final batchOptions = <ExamBatchOption>[];
    for (final item in jsonList) {
      if (item is Map) {
        final pcid = item['id']?.toString() ?? '';
        final label = item['kspcmc']?.toString() ?? '';
        if (pcid.isNotEmpty && label.isNotEmpty) {
          batchOptions.add(
            ExamBatchOption(
              pcid: pcid,
              label: label,
              category: batchCategoryFromLabel(label),
            ),
          );
        }
      }
    }

    return batchOptions;
  }

  static Future<ExamQueryResponse> getExamList({
    required String semester,
    required String pcid,
    int page = 1,
    String sort = 'zwh asc,id',
    String order = 'asc',
  }) async {
    await _http.init();

    const queryFields =
        'id,kspcmc,xh,xm,kcmc,kssj,jsmc,ksfs,ksxs,zwh,bkcs,bz,rwbz,ksrq,qssj,sznj,skyx,zydm,bjdm';
    const pageSize = 50;

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxExamListUrl,
      queryParameters: {
        'gridtype': 'jqgrid',
        'queryFields': queryFields,
        '_search': 'false',
        'nd': DateTime.now().millisecondsSinceEpoch.toString(),
        'page.size': pageSize.toString(),
        'page.pn': page.toString(),
        'sort': sort,
        'order': order,
        'xnxq': semester,
        'pcid': pcid,
      },
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader: ApiConstants.jwjxExamPageUrl,
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    final json = _decodeJsonMapResponse(response, 'exam list');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid exam response',
      );
    }

    return ExamQueryResponse.fromJson(json);
  }

  static Future<StudentInfo> getStudentInfo() async {
    await _http.init();

    final response = await _getStudentCardHtml();
    return StudentInfo.fromHtml(response.data ?? '');
  }

  static Future<StudentPhoto?> getStudentAdmissionPhoto() async {
    await _http.init();

    final response = await _getStudentCardHtml();
    final html = response.data ?? '';
    final src = _extractAdmissionPhotoSrc(html);
    if (src == null || src.isEmpty) {
      return null;
    }

    final dataUriMatch = RegExp(
      r'^data:([^;,]+)?;base64,(.+)$',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(src.trim());
    if (dataUriMatch != null) {
      final bytes = base64Decode(dataUriMatch.group(2)!.replaceAll('\n', ''));
      return StudentPhoto(
        bytes: Uint8List.fromList(bytes),
        mimeType: dataUriMatch.group(1),
      );
    }

    final photoUrl = _resolveUrl(response.realUri.toString(), src);
    final imageResponse = await _http.get<List<int>>(
      photoUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          HttpHeaders.acceptHeader:
              'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader: response.realUri.toString(),
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final contentType = imageResponse.headers.value(
      HttpHeaders.contentTypeHeader,
    );
    final data = imageResponse.data;
    if (data == null || data.isEmpty) {
      return null;
    }
    if (contentType?.contains('html') == true) {
      final body = utf8.decode(data, allowMalformed: true);
      if (_isCasLoginPage(imageResponse.realUri.toString(), body)) {
        throw const ApiLoginExpiredException();
      }
      return null;
    }
    return StudentPhoto(bytes: Uint8List.fromList(data), mimeType: contentType);
  }

  static Future<Response<String>> _getStudentCardHtml() async {
    final response = await _http.get<String>(
      ApiConstants.jwjxStudentCardUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          HttpHeaders.acceptHeader:
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader:
              '${ApiConstants.jwjxBaseUrl}/jw/admin?sfjrxk=1',
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    if (_isCasLoginPage(response.realUri.toString(), response.data ?? '')) {
      throw const ApiLoginExpiredException();
    }
    return response;
  }

  static String? _extractAdmissionPhotoSrc(String html) {
    final document = html_parser.parse(html);
    for (final title in document.querySelectorAll('.photo-title')) {
      if (!title.text.contains('入学后照片')) {
        continue;
      }
      final photoItem = _closestByClass(title, 'photo-item');
      final img =
          photoItem?.querySelector('img') ?? title.parent?.querySelector('img');
      final src = img?.attributes['src']?.trim();
      if (src != null && src.isNotEmpty && !_isDefaultStudentPhoto(src)) {
        return src;
      }
    }

    for (final img in document.querySelectorAll('.photo-item img, img')) {
      final src = img.attributes['src']?.trim();
      if (src == null || src.isEmpty || _isDefaultStudentPhoto(src)) {
        continue;
      }
      final surroundingText = img.parent?.text ?? '';
      if (surroundingText.contains('入学后照片') ||
          src.contains('/attachment/showImage/')) {
        return src;
      }
    }
    return null;
  }

  static html_dom.Element? _closestByClass(
    html_dom.Element node,
    String className,
  ) {
    html_dom.Element? current = node;
    while (current != null) {
      if (current.classes.contains(className)) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  static bool _isDefaultStudentPhoto(String src) {
    final lower = src.toLowerCase();
    return lower.contains('default_avatar') || lower.contains('defaultphoto');
  }

  static Future<BellScheduleResponse> getBellSchedule({
    required String semester,
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      '${ApiConstants.jwjxBellScheduleUrl}/$semester',
      headers: {
        HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
        HttpHeaders.refererHeader: ApiConstants.jwjxBaseUrl,
      },
    );

    return BellScheduleResponse.fromJson(
      _decodeJsonMapResponse(response, 'bell schedule'),
    );
  }

  static Future<SchoolCalendarResponse> getSchoolCalendar({
    required String semester,
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      '${ApiConstants.jwjxSchoolCalendarDataUrl}/$semester',
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader: ApiConstants.jwjxSchoolCalendarPageUrl,
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    final decoded = _decodeSchoolJsonResponse(response, 'school calendar');
    if (decoded is List) {
      return SchoolCalendarResponse.fromList(decoded, semester: semester);
    }
    if (decoded is Map) {
      final json = decoded.map((key, value) => MapEntry(key.toString(), value));
      final ret = _asInt(json['ret']);
      if (ret == -1) {
        throw const ApiLoginExpiredException();
      }
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid school calendar response',
      );
    }
    throw const ApiInvalidResponseException('Invalid school calendar response');
  }

  static Future<CoursePlanResponse> getCoursePlanList({
    String semester = '',
  }) async {
    await _http.init();

    const queryFields =
        'kcbh,kcmc,xf,xdxz,sfhdxf,cjxx,kclbmc,xnxq,jd,kcxzmc,kcsxmc,'
        'kkyxmc,ksxsmc,tscjbz,sfbxmc';

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxCoursePlanUrl,
      queryParameters: {
        'gridtype': 'jqgrid',
        'queryFields': queryFields,
        '_search': 'false',
        'nd': DateTime.now().millisecondsSinceEpoch.toString(),
        'sort': 'asc',
        'order': 'asc',
        if (semester.isNotEmpty) 'xnxqh': semester,
        'kcxz': '',
        'kcgs': '',
        'kclb': '',
        'kcsx': '',
        'id': '',
        'xh': '',
        'xm': '',
      },
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader:
            '${ApiConstants.jwjxBaseUrl}/jw/admin/xsd/xyjc',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    final json = _decodeJsonMapResponse(response, 'course plan');
    final ret = _asInt(json['ret']) ?? 0;
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid course plan response',
      );
    }

    return CoursePlanResponse.fromJson(json);
  }

  static Future<CreditProgressResponse> getCreditProgress({
    String semester = '',
  }) async {
    await _http.init();

    const queryFields =
        'wdmc,kcxzname,kclbname,kcgsname,kcsxname,yxxf,yixxf,wxxf,xqhdxf,xdxf,qbyxxf';

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxCreditProgressUrl,
      queryParameters: {
        'gridtype': 'jqgrid',
        'queryFields': queryFields,
        '_search': 'false',
        'nd': DateTime.now().millisecondsSinceEpoch.toString(),
        'sort': 'asc',
        'order': 'asc',
        if (semester.isNotEmpty) 'xnxq': semester,
        'id': '',
        'xh': '',
        'xm': '',
        'xhid': '',
      },
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader:
            '${ApiConstants.jwjxBaseUrl}/jw/admin/xsd/xyjc',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    final json = _decodeJsonMapResponse(response, 'credit progress');
    final ret = _asInt(json['ret']) ?? 0;
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid credit progress response',
      );
    }

    return CreditProgressResponse.fromJson(json);
  }

  static Future<SelectedCourseQueryResponse> getSelectedCourseList({
    int page = 1,
    int pageSize = 20,
    String semester = '',
  }) async {
    await _http.init();

    const queryFields =
        'id,kcid,xnxq,xdxz,xdfs,kcbh,kcmc,kcjj,kcbz,jxbmc,jxbbh,zxs,llxs,syxs,'
        'shangjxs,shijianxs,qtxs,jxbzc,kclb,kcxz,type,kclx,kcgs,rkjs,jxms,'
        'sksjdd,xf,skfs,xkfs,xklx,';

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxSelectedCourseListUrl,
      queryParameters: {
        'gridtype': 'jqgrid',
        'async': '1',
        'queryFields': queryFields,
        '_search': 'false',
        'nd': DateTime.now().millisecondsSinceEpoch.toString(),
        'page.size': pageSize.toString(),
        'page.pn': page.toString(),
        'sort': 'id',
        'order': 'asc',
        if (semester.isNotEmpty) 'xnxq': semester,
      },
      headers: {
        HttpHeaders.acceptHeader:
            'application/json, text/javascript, */*; q=0.01',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader: ApiConstants.jwjxSelectedCoursePageUrl,
        'X-Requested-With': 'XMLHttpRequest',
      },
    );

    final json = _decodeJsonMapResponse(response, 'selected course list');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid selected course response',
      );
    }

    return SelectedCourseQueryResponse.fromJson(json);
  }

  static Future<SchoolNotificationQueryResponse> getNotificationList({
    int page = 1,
    int pageSize = 50,
    String title = '',
    String type = '',
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      ApiConstants.jwjxMessageListUrl,
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'title': title,
        'type': type,
      },
      headers: {
        HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
        HttpHeaders.refererHeader:
            '${ApiConstants.jwjxBaseUrl}/jw/frontend/views/workCenter/message/index.html',
      },
    );

    final json = _decodeJsonMapResponse(response, 'notification list');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid notification response',
      );
    }

    return SchoolNotificationQueryResponse.fromJson(json);
  }

  static Future<void> markNotificationsRead({required List<String> ids}) async {
    final normalizedIds = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedIds.isEmpty) {
      return;
    }

    await _http.init();

    final response = await _http.post<String>(
      ApiConstants.jwjxMessageUpdateStateUrl,
      data: {'ids': normalizedIds.join(',')},
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader:
              '${ApiConstants.jwjxBaseUrl}/jw/frontend/views/workCenter/message/index.html',
          'X-Requested-With': 'XMLHttpRequest',
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final json = _decodeJsonMapResponse(response, 'notification read state');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid notification read response',
      );
    }
  }

  static Future<void> deleteNotifications({required List<String> ids}) async {
    final normalizedIds = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedIds.isEmpty) {
      return;
    }

    await _http.init();

    final response = await _http.post<String>(
      ApiConstants.jwjxMessageDeleteUrl,
      data: {'ids': normalizedIds.join(',')},
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader:
              '${ApiConstants.jwjxBaseUrl}/jw/frontend/views/workCenter/message/index.html',
          'X-Requested-With': 'XMLHttpRequest',
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final json = _decodeJsonMapResponse(response, 'notification delete');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid notification delete response',
      );
    }
  }

  static Future<ClassTableMetaResponse> getClassTableMeta({
    required String semester,
    required String userId,
    String campusId = '',
    String role = 'xs',
  }) async {
    await _http.init();

    final response = await _getSchoolJsonPlain(
      '${ApiConstants.jwjxBaseUrl}/jw/admin/api/getZclistByXnxq',
      queryParameters: {'xnxq': semester, 'role': role, 'userId': userId},
      headers: {
        HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
        HttpHeaders.refererHeader: ApiConstants.jwjxBaseUrl,
      },
    );

    final json = _decodeJsonMapResponse(response, 'class table meta');
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0 || json['data'] == null) {
      throw ApiInvalidResponseException(
        json['msg']?.toString() ?? 'Invalid class table meta response',
      );
    }

    return ClassTableMetaResponse.fromJson(json);
  }

  static Future<ClassTablePageContext> getClassTableContext({
    String semester = '',
    String userId = '',
    String campusId = '',
    String selectedCampusId = '',
    String role = 'xs',
  }) async {
    await _http.init();

    final response = await _http.get<String>(
      ApiConstants.jwjxClassTableContextUrl,
      queryParameters: {
        if (semester.isNotEmpty) 'xnxq': semester,
        if (userId.isNotEmpty) 'userId': userId,
        if (campusId.isNotEmpty) 'xqid': campusId,
        if (selectedCampusId.isNotEmpty) 'xqid1': selectedCampusId,
        if (role.isNotEmpty) 'role': role,
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: {
          HttpHeaders.acceptHeader:
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader: ApiConstants.jwjxClassTableContextUrl,
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final html = response.data ?? '';
    if (_isCasLoginPage(response.realUri.toString(), html)) {
      throw const ApiLoginExpiredException();
    }

    final context = ClassTablePageContext.fromHtml(html);
    final isInvalidContext =
        context.userContext.userId.isEmpty &&
        context.userContext.selectedSemester.isEmpty &&
        context.semesters.isEmpty;
    if (isInvalidContext) {
      throw const ApiInvalidResponseException(
        'Invalid class table context response',
      );
    }

    return context;
  }

  static ClassTablePageContext parseClassTableContextFromHtml(String html) {
    final context = ClassTablePageContext.fromHtml(html);
    final isInvalidContext =
        context.userContext.userId.isEmpty &&
        context.userContext.selectedSemester.isEmpty &&
        context.semesters.isEmpty;
    if (isInvalidContext) {
      throw const ApiInvalidResponseException(
        'Invalid class table context response',
      );
    }
    return context;
  }

  static Future<Response<String>> _getHtml(String url, {String? referer}) {
    final headers = <String, Object>{
      HttpHeaders.acceptHeader:
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
    };
    if (referer != null) {
      headers[HttpHeaders.refererHeader] = referer;
    }

    return _http.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        headers: headers,
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
  }

  static Future<_RedirectedHtmlResponse> _bootstrapJwjxSession() async {
    const targetUrl = ApiConstants.jwjxClassTableContextUrl;
    final firstResponse = await _getHtmlWithRedirects(
      targetUrl,
      referer: targetUrl,
    );
    if (_isCasLoginPage(
      firstResponse.response.realUri.toString(),
      firstResponse.response.data ?? '',
    )) {
      throw const ApiLoginExpiredException();
    }

    if (_isValidClassTableContextHtml(firstResponse.response.data ?? '')) {
      return firstResponse;
    }

    final html = await _getHtml(targetUrl, referer: targetUrl);
    if (_isCasLoginPage(html.realUri.toString(), html.data ?? '')) {
      throw const ApiLoginExpiredException();
    }
    if (!_isValidClassTableContextHtml(html.data ?? '')) {
      throw ApiInvalidResponseException(
        'Invalid class table context response from ${html.realUri}',
      );
    }

    return _RedirectedHtmlResponse(
      response: html,
      redirectChain: [...firstResponse.redirectChain, html.realUri.toString()],
    );
  }

  static Future<_RedirectedHtmlResponse> _getHtmlWithRedirects(
    String url, {
    String? referer,
  }) {
    return _sendHtmlWithRedirects(method: 'GET', url: url, referer: referer);
  }

  static Future<_RedirectedHtmlResponse> _requestCasBridge() {
    return _getHtmlWithRedirects(
      ApiConstants.chaoxingSsoBridgeUrl,
      referer: ApiConstants.chaoxingReferer,
    );
  }

  static Future<_RedirectedHtmlResponse> _postFormWithRedirects(
    String url, {
    required Map<String, String> data,
    String? referer,
  }) {
    return _sendHtmlWithRedirects(
      method: 'POST',
      url: url,
      referer: referer,
      data: data,
    );
  }

  static Future<_RedirectedHtmlResponse> _sendHtmlWithRedirects({
    required String method,
    required String url,
    String? referer,
    Map<String, String>? data,
    int maxRedirects = 20,
  }) async {
    String currentMethod = method;
    String currentUrl = url;
    String? currentReferer = referer;
    Map<String, String>? currentData = data;
    final redirectChain = <String>[];

    for (int step = 0; step <= maxRedirects; step++) {
      int retryCount = 0;
      final headers = <String, Object>{
        HttpHeaders.acceptHeader:
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
      };
      if (currentReferer != null) {
        headers[HttpHeaders.refererHeader] = currentReferer;
      }

      late final Response<String> response;
      while (true) {
        await _waitBeforeHtmlRequest();
        if (currentMethod == 'POST') {
          response = await _http.post<String>(
            currentUrl,
            data: currentData,
            options: Options(
              responseType: ResponseType.plain,
              contentType: Headers.formUrlEncodedContentType,
              headers: headers,
              followRedirects: false,
              validateStatus: _isExpectedHtmlStatus,
            ),
          );
        } else {
          response = await _http.get<String>(
            currentUrl,
            options: Options(
              responseType: ResponseType.plain,
              headers: headers,
              followRedirects: false,
              validateStatus: _isExpectedHtmlStatus,
            ),
          );
        }

        if (response.statusCode != HttpStatus.tooManyRequests ||
            retryCount >= _tooManyRequestsBackoff.length) {
          break;
        }

        final delay =
            _retryAfterDelay(response) ?? _tooManyRequestsBackoff[retryCount];
        retryCount += 1;
        LogUtil.warn(
          '[Api] $currentMethod $currentUrl got 429, retrying after ${delay.inMilliseconds}ms',
        );
        await Future<void>.delayed(delay);
      }

      final statusCode = response.statusCode ?? 0;
      final location = response.headers.value(HttpHeaders.locationHeader);
      final isRedirect =
          statusCode == 301 ||
          statusCode == 302 ||
          statusCode == 303 ||
          statusCode == 307 ||
          statusCode == 308;

      if (!isRedirect || location == null || location.isEmpty) {
        redirectChain.add(response.realUri.toString());
        return _RedirectedHtmlResponse(
          response: response,
          redirectChain: redirectChain,
        );
      }

      final nextUrl = Uri.parse(currentUrl).resolve(location).toString();
      redirectChain.add(nextUrl);
      currentReferer = currentUrl;
      currentUrl = nextUrl;

      if (statusCode == 307 || statusCode == 308) {
        continue;
      }

      currentMethod = 'GET';
      currentData = null;
    }

    throw ApiRedirectException('Too many redirects while requesting $url');
  }

  static bool _isExpectedHtmlStatus(int? status) {
    return status != null &&
        ((status >= 200 && status < 400) ||
            status == HttpStatus.tooManyRequests);
  }

  static Future<void> _waitBeforeHtmlRequest() {
    final waitTask = _htmlRequestQueue.then((_) async {
      final last = _lastHtmlRequestAt;
      if (last != null) {
        final elapsed = DateTime.now().difference(last);
        if (elapsed < _htmlRequestMinInterval) {
          await Future<void>.delayed(_htmlRequestMinInterval - elapsed);
        }
      }
      _lastHtmlRequestAt = DateTime.now();
    });
    _htmlRequestQueue = waitTask.catchError((_) {});
    return waitTask;
  }

  static Duration? _retryAfterDelay(Response<dynamic> response) {
    final raw = response.headers.value(HttpHeaders.retryAfterHeader);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final seconds = int.tryParse(raw);
    if (seconds != null) {
      return Duration(seconds: seconds.clamp(1, 10));
    }

    late final DateTime retryAt;
    try {
      retryAt = HttpDate.parse(raw);
    } catch (_) {
      return null;
    }

    final delay = retryAt.difference(DateTime.now());
    if (delay.isNegative) {
      return null;
    }
    return delay > const Duration(seconds: 10)
        ? const Duration(seconds: 10)
        : delay;
  }

  static Future<Response<String>> _getSchoolJsonPlain(
    String url, {
    Map<String, dynamic>? queryParameters,
    required Map<String, Object> headers,
  }) {
    return _http.get<String>(
      url,
      queryParameters: queryParameters,
      options: Options(
        responseType: ResponseType.plain,
        headers: headers,
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
  }

  static Map<String, dynamic> _decodeJsonMapResponse(
    Response<String> response,
    String description,
  ) {
    _throwIfSchoolLoginPage(response, description);
    if ((response.data ?? '').trim().isEmpty) {
      return const <String, dynamic>{};
    }
    final decoded = _decodeSchoolJsonResponse(response, description);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    throw ApiInvalidResponseException('Invalid $description response');
  }

  static List<dynamic> _decodeJsonListResponse(
    Response<String> response,
    String description,
  ) {
    _throwIfSchoolLoginPage(response, description);
    if ((response.data ?? '').trim().isEmpty) {
      return const <dynamic>[];
    }
    final decoded = _decodeSchoolJsonResponse(response, description);
    if (decoded is List) {
      return decoded;
    }
    throw ApiInvalidResponseException('Invalid $description response');
  }

  static dynamic _decodeSchoolJsonResponse(
    Response<String> response,
    String description,
  ) {
    final body = response.data ?? '';
    _detectUnexpectedHtmlPage(response, description);
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      throw ApiInvalidResponseException(
        'Invalid $description JSON from ${response.realUri}: ${e.message}',
      );
    }
  }

  static void _throwIfSchoolLoginPage(
    Response<String> response,
    String description,
  ) {
    _detectUnexpectedHtmlPage(response, description);
  }

  static void _detectUnexpectedHtmlPage(
    Response<String> response,
    String description,
  ) {
    final html = response.data ?? '';
    final url = response.realUri.toString();
    final contentType = response.headers.value(HttpHeaders.contentTypeHeader);
    final looksHtml = _looksLikeHtml(html, contentType);
    if (!looksHtml && !_isCasLoginPage(url, html)) {
      return;
    }

    final pageKind = _classifyUnexpectedHtmlPage(url, html);
    final fingerprint = ApiDiagnostics.fingerprintBody(html);
    LogUtil.warn(
      '[Api] $description returned unexpected HTML '
      'kind=$pageKind finalUrl=${ApiDiagnostics.sanitizeUri(response.realUri)} '
      'statusCode=${response.statusCode} fingerprint="$fingerprint"',
    );

    switch (pageKind) {
      case _UnexpectedHtmlPageKind.casLogin:
        throw const ApiLoginExpiredException();
      case _UnexpectedHtmlPageKind.captcha:
      case _UnexpectedHtmlPageKind.securityVerification:
      case _UnexpectedHtmlPageKind.accessRestricted:
      case _UnexpectedHtmlPageKind.waf:
        throw ApiProtectionRequiredException(
          '学校认证要求验证，请先用浏览器打开教务平台完成一次验证，再回到 App 重试',
        );
      case _UnexpectedHtmlPageKind.rateLimited:
        throw const ApiRateLimitedException('请求过于频繁，请稍后再试');
      case _UnexpectedHtmlPageKind.blank:
        throw ApiUnexpectedHtmlException('$description 返回空白 HTML，可能是学校接口临时异常');
      case _UnexpectedHtmlPageKind.unknown:
        throw ApiUnexpectedHtmlException(
          '$description 返回了无法识别的 HTML 页面，学校页面结构可能变化',
        );
    }
  }

  static Future<Response<Map<String, dynamic>>> _getJson(
    String url, {
    String? referer,
  }) {
    final headers = <String, Object>{
      HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
    };
    if (referer != null) {
      headers[HttpHeaders.refererHeader] = referer;
    }

    return _http.get<Map<String, dynamic>>(
      url,
      options: Options(
        responseType: ResponseType.json,
        headers: headers,
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
  }

  static Future<RsaKey> _fetchPubKey(String casPageUrl) async {
    final pubKeyUrl = _resolveUrl(casPageUrl, 'v2/getPubKey');
    final response = await _getJson(pubKeyUrl, referer: casPageUrl);
    final data = response.data ?? <String, dynamic>{};
    return RsaKey(
      modulusHex: data['modulus']?.toString() ?? '',
      exponentHex: data['exponent']?.toString() ?? '',
    );
  }

  static Map<String, String> _extractFormInputs(String html) {
    final document = html_parser.parse(html);
    final fields = <String, String>{};
    for (final input in document.querySelectorAll('input[name]')) {
      final name = input.attributes['name'];
      if (name == null || name.isEmpty) {
        continue;
      }
      fields[name] = input.attributes['value'] ?? '';
    }
    return fields;
  }

  static String? _extractFormAction(String html) {
    final document = html_parser.parse(html);
    return document.querySelector('form#fm1')?.attributes['action'];
  }

  static bool _hasCasLoginForm(Map<String, String> fields, String html) {
    return fields.containsKey('username') ||
        fields.containsKey('password') ||
        _isCasLoginPage('', html);
  }

  static String _resolveUrl(String baseUrl, String path) {
    return Uri.parse(baseUrl).resolve(path).toString();
  }

  static bool _isSameUrl(String left, String right) {
    final leftUri = Uri.parse(left);
    final rightUri = Uri.parse(right);
    return leftUri.scheme == rightUri.scheme &&
        leftUri.host == rightUri.host &&
        leftUri.port == rightUri.port &&
        _normalizePath(leftUri.path) == _normalizePath(rightUri.path) &&
        leftUri.query == rightUri.query;
  }

  static String _normalizePath(String path) {
    if (path.isEmpty) {
      return '/';
    }
    return path.endsWith('/') && path.length > 1
        ? path.substring(0, path.length - 1)
        : path;
  }

  static String encryptPasswordForLocalStorage(String password) {
    final reversed = password.split('').reversed.join();
    return base64UrlEncode(utf8.encode(reversed));
  }

  static String decryptPasswordForLocalStorage(String value) {
    final decoded = utf8.decode(base64Url.decode(value));
    return decoded.split('').reversed.join();
  }

  static bool _isCasLoginPage(String url, String html) {
    if (url.contains('/cas/login')) {
      return true;
    }

    final document = html_parser.parse(html);
    return document.querySelector('form#fm1') != null &&
        document.querySelector('input[name="username"]') != null;
  }

  static bool _looksLikeHtml(String body, String? contentType) {
    final trimmed = body.trimLeft();
    if (trimmed.isEmpty) {
      return contentType?.contains('html') == true;
    }
    return contentType?.contains('html') == true ||
        trimmed.startsWith('<!DOCTYPE') ||
        trimmed.startsWith('<html') ||
        trimmed.contains('<body') ||
        trimmed.contains('<form');
  }

  static _UnexpectedHtmlPageKind _classifyUnexpectedHtmlPage(
    String url,
    String html,
  ) {
    final text = html_parser.parse(html).body?.text ?? html;
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final lowerUrl = url.toLowerCase();

    if (html.trim().isEmpty || normalized.trim().isEmpty) {
      return _UnexpectedHtmlPageKind.blank;
    }
    if (_isCasLoginPage(url, html)) {
      return _UnexpectedHtmlPageKind.casLogin;
    }
    if (_containsAny(normalized, const ['验证码', 'captcha', 'authcode'])) {
      return _UnexpectedHtmlPageKind.captcha;
    }
    if (_containsAny(normalized, const ['访问频繁', '请求频繁', 'too many requests']) ||
        lowerUrl.contains('429')) {
      return _UnexpectedHtmlPageKind.rateLimited;
    }
    if (_containsAny(normalized, const ['访问受限', '禁止访问', 'forbidden'])) {
      return _UnexpectedHtmlPageKind.accessRestricted;
    }
    if (_containsAny(normalized, const ['安全验证', '身份验证', '风险', '风控'])) {
      return _UnexpectedHtmlPageKind.securityVerification;
    }
    if (_containsAny(normalized, const ['waf', 'web application firewall'])) {
      return _UnexpectedHtmlPageKind.waf;
    }
    return _UnexpectedHtmlPageKind.unknown;
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }

  static void _throwIfCasLoginFailed(_RedirectedHtmlResponse loginResponse) {
    final response = loginResponse.response;
    final html = response.data ?? '';
    final url = response.realUri.toString();
    if (response.statusCode == HttpStatus.tooManyRequests) {
      LogUtil.warn(
        '[Api] CAS login got 429 finalUrl=$url '
        'redirects=${loginResponse.redirectChain.length}',
      );
      throw const ApiRateLimitedException('请求过于频繁，请稍后再试');
    }
    if (!_isCasLoginPage(url, html)) {
      return;
    }

    final reason = _extractCasLoginError(html);
    final pageKind = _classifyUnexpectedHtmlPage(url, html);
    LogUtil.warn(
      '[Api] CAS login stayed on login page '
      'finalUrl=$url statusCode=${response.statusCode} '
      'redirects=${loginResponse.redirectChain.length} kind=$pageKind',
    );
    if (reason.contains('验证码') ||
        reason.contains('验证') ||
        reason.contains('风控') ||
        pageKind == _UnexpectedHtmlPageKind.captcha ||
        pageKind == _UnexpectedHtmlPageKind.securityVerification ||
        pageKind == _UnexpectedHtmlPageKind.accessRestricted ||
        pageKind == _UnexpectedHtmlPageKind.waf) {
      throw ApiProtectionRequiredException(
        reason.isEmpty ? '学校认证要求验证，请先用浏览器打开教务平台完成一次验证，再回到 App 重试' : reason,
      );
    }
    throw ApiInvalidResponseException(
      reason.isEmpty ? '统一身份认证登录失败，请检查账号密码或验证码状态' : reason,
    );
  }

  static String _extractCasLoginError(String html) {
    final document = html_parser.parse(html);
    const selectors = [
      '#msg',
      '.msg',
      '.error',
      '.errors',
      '.alert',
      '.alert-danger',
    ];

    for (final selector in selectors) {
      final text = document.querySelector(selector)?.text.trim();
      if (text != null && text.isNotEmpty) {
        return text.replaceAll(RegExp(r'\s+'), ' ');
      }
    }

    if (document.querySelector('input[name="authcode"]') != null ||
        document.body?.text.contains('验证码') == true) {
      return '学校认证要求验证码，请稍后重试或在浏览器完成验证';
    }

    return '';
  }

  static bool _isValidClassTableContextHtml(String html) {
    final context = ClassTablePageContext.fromHtml(html);
    return context.userContext.userId.isNotEmpty ||
        context.userContext.selectedSemester.isNotEmpty ||
        context.semesters.isNotEmpty;
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static String _encryptPasswordJsCompatible(String password, RsaKey key) {
    final reversedPassword = password.split('').reversed.join();
    final data = reversedPassword.codeUnits.toList(growable: true);
    final chunkSize = key.chunkSize;
    if (chunkSize <= 0) {
      throw const FormatException('invalid RSA key chunk size');
    }

    while (data.length % chunkSize != 0) {
      data.add(0);
    }

    final blocks = <String>[];
    for (int offset = 0; offset < data.length; offset += chunkSize) {
      final chunk = data.sublist(offset, offset + chunkSize);
      BigInt block = BigInt.zero;
      int digitIndex = 0;
      for (int index = 0; index < chunk.length; index += 2) {
        final low = chunk[index];
        final high = index + 1 < chunk.length ? chunk[index + 1] : 0;
        final digit = low + (high << 8);
        block += BigInt.from(digit) << (16 * digitIndex);
        digitIndex += 1;
      }
      final encrypted = block.modPow(key.exponent, key.modulus);
      blocks.add(encrypted.toRadixString(16));
    }

    return blocks.join(' ');
  }
}
