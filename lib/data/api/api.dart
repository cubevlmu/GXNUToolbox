import 'dart:convert';
import 'dart:io';

import 'package:class_tool/data/api/api_constants.dart';
import 'package:class_tool/data/model/chaoxing_login_result.dart';
import 'package:class_tool/data/model/class_meta.dart';
import 'package:class_tool/data/model/class_table.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/data/model/class_table_course.dart';
import 'package:class_tool/data/model/grade.dart';
import 'package:class_tool/utils/http_utils.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

class ApiLoginExpiredException implements Exception {
  const ApiLoginExpiredException();

  @override
  String toString() => 'ApiLoginExpiredException';
}

class _RedirectedHtmlResponse {
  const _RedirectedHtmlResponse({
    required this.response,
    required this.redirectChain,
  });

  final Response<String> response;
  final List<String> redirectChain;
}

class Api {
  Api._();

  static final HttpUtils _http = HttpUtils();
  static Future<void> _htmlRequestQueue = Future<void>.value();
  static DateTime? _lastHtmlRequestAt;
  static const Duration _htmlRequestMinInterval = Duration(milliseconds: 450);
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

    if (clearBeforeLogin) {
      await _http.clearCookies();
    }

    await _getHtml(ApiConstants.chaoxingEntryLoginUrl);
    final casPage = await _getHtmlWithRedirects(
      ApiConstants.chaoxingSsoBridgeUrl,
      referer: ApiConstants.chaoxingReferer,
    );

    final formFields = _extractFormInputs(casPage.response.data ?? '');
    final formAction =
        _extractFormAction(casPage.response.data ?? '') ?? '/cas/login';
    final postUrl = _resolveUrl(
      casPage.response.realUri.toString(),
      formAction,
    );

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

    final loginResponse = await _postFormWithRedirects(
      postUrl,
      data: formFields,
      referer: casPage.response.realUri.toString(),
    );

    final finalCheckRedirectChain = <String>[];
    if (!_isSameUrl(
      loginResponse.response.realUri.toString(),
      ApiConstants.chaoxingFinalCheckUrl,
    )) {
      final finalResponse = await _getHtmlWithRedirects(
        ApiConstants.chaoxingFinalCheckUrl,
        referer: ApiConstants.chaoxingFinalCheckUrl,
      );
      finalCheckRedirectChain.addAll(finalResponse.redirectChain);
    }

    final jwjxBootstrapResponse = await _bootstrapJwjxSession();

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
  }

  static Future<List<ClassMeta>> getWeekMeta({
    required String semester,
    required int week,
  }) async {
    await _http.init();

    final response = await _http.get<List<dynamic>>(
      ApiConstants.jwjxWeekMetaUrl,
      queryParameters: {'xnxq': semester, 'week': week.toString()},
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
          HttpHeaders.refererHeader: ApiConstants.jwjxBaseUrl,
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final rawList = response.data ?? const <dynamic>[];
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

    final response = await _http.get<Map<String, dynamic>>(
      '${ApiConstants.jwjxBaseUrl}/jw/admin/api/getXskb',
      queryParameters: {
        'xnxq': semester,
        'userId': userId,
        'week': week.toString(),
        'role': role,
      },
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
          HttpHeaders.refererHeader: ApiConstants.jwjxBaseUrl,
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final json = response.data ?? const <String, dynamic>{};
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

    final response = await _http.get<Map<String, dynamic>>(
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
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.acceptHeader:
              'application/json, text/javascript, */*; q=0.01',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader: ApiConstants.jwjxGradePageUrl,
          'X-Requested-With': 'XMLHttpRequest',
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final json = response.data ?? const <String, dynamic>{};
    final ret = _asInt(json['ret']);
    if (ret == -1 || _isCasLoginPage(response.realUri.toString(), '')) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw StateError(json['msg']?.toString() ?? 'Invalid grade response');
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

  static Future<GradeRankResponse> getGradeRank() async {
    await _http.init();

    final response = await _http.get<Map<String, dynamic>>(
      ApiConstants.jwjxGradeRankUrl,
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.acceptHeader:
              'application/json, text/javascript, */*; q=0.01',
          HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
          HttpHeaders.refererHeader:
              '${ApiConstants.jwjxGradePageUrl}?fxtype=1',
          'X-Requested-With': 'XMLHttpRequest',
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final json = response.data ?? const <String, dynamic>{};
    final ret = _asInt(json['ret']);
    if (ret == -1 || _isCasLoginPage(response.realUri.toString(), '')) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0) {
      throw StateError(
        json['msg']?.toString() ?? 'Invalid grade rank response',
      );
    }

    return GradeRankResponse.fromJson(json);
  }

  static Future<ClassTableMetaResponse> getClassTableMeta({
    required String semester,
    required String userId,
    String campusId = '',
    String role = 'xs',
  }) async {
    await _http.init();

    final response = await _http.get<Map<String, dynamic>>(
      '${ApiConstants.jwjxBaseUrl}/jw/admin/api/getZclistByXnxq',
      queryParameters: {'xnxq': semester, 'role': role, 'userId': userId},
      options: Options(
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.acceptHeader: 'application/json, text/plain, */*',
          HttpHeaders.refererHeader: ApiConstants.jwjxBaseUrl,
        },
        followRedirects: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    final json = response.data ?? const <String, dynamic>{};
    final ret = _asInt(json['ret']);
    if (ret == -1) {
      throw const ApiLoginExpiredException();
    }
    if (ret != 0 || json['data'] == null) {
      throw StateError(
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
      throw StateError('Invalid class table context response');
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
      throw StateError('Invalid class table context response');
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

    final secondResponse = await _getHtmlWithRedirects(
      targetUrl,
      referer: targetUrl,
    );
    if (_isCasLoginPage(
      secondResponse.response.realUri.toString(),
      secondResponse.response.data ?? '',
    )) {
      throw const ApiLoginExpiredException();
    }
    if (!_isValidClassTableContextHtml(secondResponse.response.data ?? '')) {
      throw StateError(
        'Invalid class table context response from ${secondResponse.response.realUri}',
      );
    }

    return secondResponse;
  }

  static Future<_RedirectedHtmlResponse> _getHtmlWithRedirects(
    String url, {
    String? referer,
  }) {
    return _sendHtmlWithRedirects(method: 'GET', url: url, referer: referer);
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

    throw StateError('Too many redirects while requesting $url');
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
