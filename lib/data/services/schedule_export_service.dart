import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class ScheduleImageSaveResult {
  const ScheduleImageSaveResult({
    required this.displayPath,
    required this.savedToGallery,
  });

  final String displayPath;
  final bool savedToGallery;
}

class ScheduleExportService {
  const ScheduleExportService._();

  static const MethodChannel _nativeChannel = MethodChannel(
    'me.cubevlmu.gxnutool/native',
  );

  static Future<ScheduleImageSaveResult> saveScheduleTableImage({
    required GlobalKey repaintBoundaryKey,
    required String semester,
    required String weekText,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary = repaintBoundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      throw StateError('课表截图区域尚未准备好');
    }

    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await _pngBytes(image);
    final fileName = _fileName(semester, weekText);
    if (Platform.isAndroid) {
      final uri = await _nativeChannel.invokeMethod<String>(
        'saveImageToGallery',
        <String, Object>{'bytes': bytes, 'displayName': fileName},
      );
      return ScheduleImageSaveResult(
        displayPath: uri == null || uri.isEmpty ? '系统图库' : uri,
        savedToGallery: true,
      );
    }

    final directory = await _resolveExportDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return ScheduleImageSaveResult(
      displayPath: file.path,
      savedToGallery: false,
    );
  }

  static Future<Uint8List> _pngBytes(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) {
      throw StateError('课表图片生成失败');
    }
    return data.buffer.asUint8List();
  }

  static Future<Directory> _resolveExportDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${baseDir.path}/schedule_exports');
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static String _fileName(String semester, String weekText) {
    final now = DateTime.now();
    final stamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';
    final safeSemester = _safePart(semester, fallback: '当前学期');
    final safeWeek = _safePart(weekText, fallback: '当前周');
    return 'GXNU课表_${safeSemester}_${safeWeek}_$stamp.png';
  }

  static String _safePart(String value, {required String fallback}) {
    final trimmed = value.trim().isEmpty ? fallback : value.trim();
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
