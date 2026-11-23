import 'package:class_tool/data/services/github_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isNewerVersion compares semantic versions accurately', () {
    expect(GithubUpdateService.isNewerVersion('v0.8.9', '0.8.8'), isTrue);
    expect(GithubUpdateService.isNewerVersion('0.9.0', '0.8.8'), isTrue);
    expect(GithubUpdateService.isNewerVersion('1.0.0', '0.9.9'), isTrue);
    expect(GithubUpdateService.isNewerVersion('v0.8.8', '0.8.8'), isFalse);
    expect(GithubUpdateService.isNewerVersion('0.8.8+2', '0.8.8'), isFalse);
    expect(GithubUpdateService.isNewerVersion('0.8.7', '0.8.8'), isFalse);
  });

  test('parseReleaseJson selects preferred apk asset from GitHub release', () {
    final release = GithubUpdateService.parseReleaseJson(<String, dynamic>{
      'tag_name': 'v0.8.9',
      'name': 'v0.8.9',
      'body': '修复若干问题',
      'html_url': 'https://github.com/cubevlmu/GXNUToolbox/releases/tag/v0.8.9',
      'assets': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'checksums.txt',
          'browser_download_url': 'https://example.com/checksums.txt',
          'size': 128,
        },
        <String, dynamic>{
          'name': 'gxnu-universal.apk',
          'browser_download_url': 'https://example.com/gxnu-universal.apk',
          'size': 1024,
        },
        <String, dynamic>{
          'name': 'gxnu-arm64-v8a-release.apk',
          'browser_download_url':
              'https://example.com/gxnu-arm64-v8a-release.apk',
          'size': 2048,
        },
      ],
    });

    expect(release.version, '0.8.9');
    expect(release.apkAsset, isNotNull);
    expect(release.apkAsset!.name, 'gxnu-arm64-v8a-release.apk');
    expect(release.apkAsset!.size, 2048);
  });
}
