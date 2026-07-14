import 'dart:io';

import 'package:class_tool/utils/log_util.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

class ApiDiagnostics {
  ApiDiagnostics._();

  static int _seed = 0;
  static ApiTrace? _lastLoginTrace;
  static ApiTrace? _lastSyncTrace;

  static ApiTrace? get lastLoginTrace => _lastLoginTrace;
  static ApiTrace? get lastSyncTrace => _lastSyncTrace;

  static ApiTrace startLoginTrace() {
    final trace = ApiTrace._(
      traceId: _nextTraceId('login'),
      flow: 'login',
      startedAt: DateTime.now(),
    );
    _lastLoginTrace = trace;
    trace.logPhase('start');
    return trace;
  }

  static ApiTrace startSyncTrace(String flow) {
    final trace = ApiTrace._(
      traceId: _nextTraceId(flow),
      flow: flow,
      startedAt: DateTime.now(),
    );
    _lastSyncTrace = trace;
    trace.logPhase('start');
    return trace;
  }

  static String diagnosticSummary() {
    return [
      _traceSummary('最近登录 trace', _lastLoginTrace),
      _traceSummary('最近同步 trace', _lastSyncTrace),
    ].join('\n');
  }

  static String sanitizeUri(Uri uri) {
    final queryKeys = uri.queryParameters.keys.toList()..sort();
    final query = queryKeys.isEmpty ? '' : '?keys=${queryKeys.join(',')}';
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}${uri.path}$query';
  }

  static String uriHostPath(Uri uri) {
    return '${uri.host}${uri.path.isEmpty ? '/' : uri.path}';
  }

  static String fingerprintBody(Object? body) {
    final text = _bodyText(body);
    if (text.trim().isEmpty) {
      return 'empty';
    }

    final document = html_parser.parse(text);
    final title = _cleanText(document.querySelector('title')?.text ?? '');
    final visibleText = _cleanText(document.body?.text ?? text);
    final keywords = _matchedKeywords(visibleText);
    final preview = visibleText.length > 160
        ? visibleText.substring(0, 160)
        : visibleText;
    return [
      if (title.isNotEmpty) 'title=$title',
      if (keywords.isNotEmpty) 'keywords=${keywords.join(',')}',
      if (preview.isNotEmpty) 'preview=$preview',
    ].join(' ');
  }

  static String bodyKind(Object? body, Headers? headers) {
    if (body == null) {
      return 'empty';
    }
    final contentType = headers?.value(HttpHeaders.contentTypeHeader) ?? '';
    final text = _bodyText(body).trimLeft();
    if (contentType.contains('json') ||
        text.startsWith('{') ||
        text.startsWith('[')) {
      return 'json';
    }
    if (contentType.contains('html') ||
        text.startsWith('<!DOCTYPE') ||
        text.startsWith('<html') ||
        text.contains('<body') ||
        text.contains('<form')) {
      return 'html';
    }
    if (body is List<int>) {
      return 'bytes';
    }
    return text.isEmpty ? 'empty' : 'text';
  }

  static String _nextTraceId(String prefix) {
    _seed += 1;
    final now = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return '${prefix}_{$now}_${_seed.toRadixString(36)}';
  }

  static String _traceSummary(String label, ApiTrace? trace) {
    if (trace == null) {
      return '$label: -';
    }
    return [
      '$label: ${trace.traceId}',
      'flow=${trace.flow}',
      'startedAt=${trace.startedAt.toIso8601String()}',
      'lastPhase=${trace.lastPhase ?? '-'}',
    ].join(' ');
  }

  static String _bodyText(Object? body) {
    if (body == null) {
      return '';
    }
    if (body is String) {
      return body;
    }
    if (body is List<int>) {
      return String.fromCharCodes(body.take(4096));
    }
    return body.toString();
  }

  static List<String> _matchedKeywords(String text) {
    const keywords = [
      '统一身份认证',
      'CAS',
      '验证码',
      '访问频繁',
      '请求频繁',
      '访问受限',
      '安全验证',
      '风控',
      'WAF',
      'login',
      'captcha',
    ];
    final lower = text.toLowerCase();
    return keywords
        .where((keyword) => lower.contains(keyword.toLowerCase()))
        .toList(growable: false);
  }

  static String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class ApiTrace {
  ApiTrace._({
    required this.traceId,
    required this.flow,
    required this.startedAt,
  });

  final String traceId;
  final String flow;
  final DateTime startedAt;
  String? lastPhase;

  void logPhase(String phase) {
    lastPhase = phase;
    LogUtil.info('[ApiTrace] traceId=$traceId phase=$phase');
  }

  void logResponse(
    String phase,
    Response<dynamic> response, {
    String? method,
    Duration? duration,
    int redirectCount = 0,
  }) {
    lastPhase = phase;
    LogUtil.info(
      '[ApiTrace] traceId=$traceId phase=$phase '
      'method=${method ?? response.requestOptions.method} '
      'url=${ApiDiagnostics.uriHostPath(response.requestOptions.uri)} '
      'statusCode=${response.statusCode} '
      'realUri=${ApiDiagnostics.uriHostPath(response.realUri)} '
      'contentType=${response.headers.value(HttpHeaders.contentTypeHeader) ?? '-'} '
      'redirectCount=$redirectCount '
      'durationMs=${duration?.inMilliseconds ?? '-'} '
      'bodyKind=${ApiDiagnostics.bodyKind(response.data, response.headers)} '
      'bodyFingerprint="${ApiDiagnostics.fingerprintBody(response.data)}"',
    );
  }

  void logError(String phase, Object error) {
    lastPhase = phase;
    LogUtil.warn(
      '[ApiTrace] traceId=$traceId phase=$phase error=${error.runtimeType}: $error',
    );
  }
}
