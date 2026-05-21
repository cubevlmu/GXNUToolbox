import 'dart:io';

import 'package:class_tool/data/api/api_constants.dart';
import 'package:class_tool/utils/log_util.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class HttpUtils {
  HttpUtils._internal();

  static final HttpUtils _instance = HttpUtils._internal();

  factory HttpUtils() => _instance;

  static late final Dio dio;
  static late final PersistCookieJar cookieJar;
  final Connectivity _connectivity = Connectivity();
  CancelToken _cancelToken = CancelToken();
  bool _initialized = false;
  Future<void>? _initTask;

  Future<void> init() {
    if (_initialized) {
      return Future<void>.value();
    }

    final activeTask = _initTask;
    if (activeTask != null) {
      return activeTask;
    }

    final task = _doInit();
    _initTask = task;
    return task.whenComplete(() {
      if (identical(_initTask, task)) {
        _initTask = null;
      }
    });
  }

  Future<void> _doInit() async {
    if (_initialized) {
      return;
    }

    await StorageUtils.ensureInitialized();

    final cookieDirectory = Directory(
      '${StorageUtils.appSupportDirectory.path}/cookies',
    );
    if (!cookieDirectory.existsSync()) {
      cookieDirectory.createSync(recursive: true);
    }

    final options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        HttpHeaders.userAgentHeader: ApiConstants.userAgent,
        HttpHeaders.acceptEncodingHeader: 'gzip',
        HttpHeaders.connectionHeader: 'keep-alive',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      persistentConnection: true,
    );

    final nextDio = Dio(options)..transformer = BackgroundTransformer();
    final nextCookieJar = PersistCookieJar(
      ignoreExpires: false,
      storage: FileStorage(cookieDirectory.path),
    );

    nextDio.interceptors.addAll([
      CookieManager(nextCookieJar),
      _ApiLogInterceptor(),
      _NetworkGuardInterceptor(_connectivity),
    ]);

    dio = nextDio;
    cookieJar = nextCookieJar;
    _initialized = true;
  }

  Uri resolveUri(String url) {
    final uri = Uri.parse(url);
    if (uri.hasScheme) {
      return uri;
    }
    return Uri.parse('${ApiConstants.baseUrl}$url');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await init();
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await init();
    return dio.post<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await init();
    return dio.patch<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await init();
    return dio.delete<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
  }

  Future<List<Cookie>> loadCookies(String url) async {
    await init();
    return cookieJar.loadForRequest(resolveUri(url));
  }

  Future<void> saveCookies(String url, List<Cookie> cookies) async {
    await init();
    return cookieJar.saveFromResponse(resolveUri(url), cookies);
  }

  Future<List<Cookie>> getCookies(String url) async {
    final cookies = await loadCookies(url);
    return cookies.map((cookie) => _cloneCookie(cookie)).toList(growable: false);
  }

  Future<Cookie?> getCookie(String url, String name) async {
    final cookies = await loadCookies(url);
    for (final cookie in cookies) {
      if (cookie.name == name) {
        return _cloneCookie(cookie);
      }
    }
    return null;
  }

  Future<Map<String, String>> getCookieMap(String url) async {
    final cookies = await loadCookies(url);
    return {
      for (final cookie in cookies) cookie.name: cookie.value,
    };
  }

  Future<void> setCookie(
    String url,
    Cookie cookie, {
    bool removeExpired = true,
  }) async {
    await init();
    final uri = resolveUri(url);
    final cookies = await loadCookies(url);
    final nextCookies = cookies
        .where((item) => item.name != cookie.name)
        .map(_cloneCookie)
        .toList(growable: true);
    nextCookies.add(_cloneCookie(cookie));
    final normalized = _filterCookies(
      nextCookies,
      removeExpired: removeExpired,
    );
    await cookieJar.delete(uri, false);
    if (normalized.isNotEmpty) {
      await cookieJar.saveFromResponse(uri, normalized);
    }
  }

  Future<void> setCookieValue(
    String url, {
    required String name,
    required String value,
    String? domain,
    String? path,
    DateTime? expires,
    bool httpOnly = false,
    bool secure = false,
  }) {
    final cookie = Cookie(name, value)
      ..httpOnly = httpOnly
      ..secure = secure;
    if (domain != null && domain.isNotEmpty) {
      cookie.domain = domain;
    }
    if (path != null && path.isNotEmpty) {
      cookie.path = path;
    }
    if (expires != null) {
      cookie.expires = expires;
    }
    return setCookie(url, cookie);
  }

  Future<void> setCookies(
    String url,
    List<Cookie> cookies, {
    bool merge = true,
    bool removeExpired = true,
  }) async {
    await init();
    final uri = resolveUri(url);
    final nextCookies = <Cookie>[];
    if (merge) {
      nextCookies.addAll(await loadCookies(url));
    }
    for (final cookie in cookies) {
      nextCookies.removeWhere((item) => item.name == cookie.name);
      nextCookies.add(_cloneCookie(cookie));
    }
    final normalized = _filterCookies(
      nextCookies,
      removeExpired: removeExpired,
    );
    await cookieJar.delete(uri, false);
    if (normalized.isNotEmpty) {
      await cookieJar.saveFromResponse(uri, normalized);
    }
  }

  Future<bool> deleteCookie(
    String url,
    String name,
  ) async {
    await init();
    final uri = resolveUri(url);
    final cookies = await loadCookies(url);
    final nextCookies = cookies.where((item) => item.name != name).toList();
    final removed = nextCookies.length != cookies.length;
    await cookieJar.delete(uri, false);
    if (nextCookies.isNotEmpty) {
      await cookieJar.saveFromResponse(
        uri,
        nextCookies.map(_cloneCookie).toList(),
      );
    }
    return removed;
  }

  Future<void> deleteCookies(String url, {bool withSubDomains = false}) async {
    await init();
    return cookieJar.delete(resolveUri(url), withSubDomains);
  }

  Future<int> deleteExpiredCookies(String url) async {
    await init();
    final uri = resolveUri(url);
    final cookies = await loadCookies(url);
    final validCookies = _filterCookies(cookies, removeExpired: true);
    final removedCount = cookies.length - validCookies.length;
    await cookieJar.delete(uri, false);
    if (validCookies.isNotEmpty) {
      await cookieJar.saveFromResponse(uri, validCookies);
    }
    return removedCount;
  }

  Future<void> moveCookies(
    String fromUrl,
    String toUrl, {
    bool deleteSource = false,
    bool removeExpired = true,
  }) async {
    await init();
    final sourceUri = resolveUri(fromUrl);
    final targetUri = resolveUri(toUrl);
    final sourceCookies = await loadCookies(fromUrl);
    final targetCookies = await loadCookies(toUrl);

    final merged = targetCookies.map(_cloneCookie).toList(growable: true);
    for (final cookie in sourceCookies) {
      merged.removeWhere((item) => item.name == cookie.name);
      final moved = _cloneCookie(cookie);
      final currentPath = moved.path;
      moved.domain = targetUri.host;
      moved.path = (currentPath == null || currentPath.isEmpty)
          ? '/'
          : currentPath;
      merged.add(moved);
    }

    final normalized = _filterCookies(merged, removeExpired: removeExpired);
    await cookieJar.delete(targetUri, false);
    if (normalized.isNotEmpty) {
      await cookieJar.saveFromResponse(targetUri, normalized);
    }
    if (deleteSource) {
      await cookieJar.delete(sourceUri, false);
    }
  }

  Future<void> reloadCookies() async {
    await init();
  }

  Future<void> clearCookies() async {
    await init();
    return cookieJar.deleteAll();
  }

  void cancelRequests({CancelToken? token}) {
    _cancelToken.cancel('cancelled');
    _cancelToken = token ?? CancelToken();
  }
}

Cookie _cloneCookie(Cookie cookie) {
  final cloned = Cookie(cookie.name, cookie.value)
    ..domain = cookie.domain
    ..path = cookie.path
    ..expires = cookie.expires
    ..httpOnly = cookie.httpOnly
    ..maxAge = cookie.maxAge
    ..secure = cookie.secure;
  return cloned;
}

List<Cookie> _filterCookies(
  List<Cookie> cookies, {
  required bool removeExpired,
}) {
  if (!removeExpired) {
    return cookies.map(_cloneCookie).toList(growable: false);
  }

  final now = DateTime.now();
  return cookies
      .where((cookie) => cookie.expires == null || cookie.expires!.isAfter(now))
      .map(_cloneCookie)
      .toList(growable: false);
}

class _ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    LogUtil.info('[HTTP] ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LogUtil.error('[HTTP] ${err.requestOptions.method} ${err.requestOptions.uri}');
    LogUtil.error(err.message ?? '未知网络异常');
    super.onError(err, handler);
  }
}

class _NetworkGuardInterceptor extends Interceptor {
  const _NetworkGuardInterceptor(this.connectivity);

  final Connectivity connectivity;

  Future<bool> _isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.type == DioExceptionType.unknown && !await _isConnected()) {
      LogUtil.warn('当前网络不可用，请检查网络连接。');
    }
    super.onError(err, handler);
  }
}
