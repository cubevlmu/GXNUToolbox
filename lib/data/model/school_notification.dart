import 'package:flutter/foundation.dart';

@immutable
class SchoolNotificationQueryResponse {
  const SchoolNotificationQueryResponse({
    required this.ret,
    required this.msg,
    required this.page,
    required this.rows,
    required this.total,
    required this.totalPages,
    required this.results,
  });

  final int ret;
  final String msg;
  final int page;
  final int rows;
  final int total;
  final int totalPages;
  final List<SchoolNotificationItem> results;

  factory SchoolNotificationQueryResponse.fromJson(Map<String, dynamic> json) {
    return SchoolNotificationQueryResponse(
      ret: _asInt(json['ret']),
      msg: json['msg']?.toString() ?? '',
      page: _asInt(json['page']),
      rows: _asInt(json['rows']),
      total: _asInt(json['total']),
      totalPages: _asInt(json['totalPages']),
      results: _asList(json['results'])
          .map((item) => SchoolNotificationItem.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ret': ret,
      'msg': msg,
      'page': page,
      'rows': rows,
      'total': total,
      'totalPages': totalPages,
      'results': results.map((item) => item.toJson()).toList(),
    };
  }
}

@immutable
class SchoolNotificationItem {
  const SchoolNotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.releaseDate,
    required this.noticeType,
    required this.readStatus,
    required this.collectStatus,
    required this.pinnedStatus,
    required this.isNew,
  });

  final String id;
  final String title;
  final String content;
  final String releaseDate;
  final String noticeType;
  final String readStatus;
  final String collectStatus;
  final String pinnedStatus;
  final bool isNew;

  bool get isRead => readStatus == '1';
  bool get isCollected => collectStatus == '1';
  bool get isPinned => pinnedStatus == '1';
  String get readStatusLabel => isRead ? '已读' : '未读';

  factory SchoolNotificationItem.fromJson(Map<String, dynamic> json) {
    return SchoolNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      releaseDate: json['releaseDate']?.toString() ?? '',
      noticeType: json['noticeType']?.toString() ?? '',
      readStatus: json['dqstatus']?.toString() ?? '',
      collectStatus: json['collectstatus']?.toString() ?? '',
      pinnedStatus: json['sfzd']?.toString() ?? '',
      isNew: json['new'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'releaseDate': releaseDate,
      'noticeType': noticeType,
      'dqstatus': readStatus,
      'collectstatus': collectStatus,
      'sfzd': pinnedStatus,
      'new': isNew,
    };
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const [];
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
