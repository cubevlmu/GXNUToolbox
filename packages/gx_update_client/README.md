# gx_update_client

Flutter client package for `gx_update_server`.

功能：

- 调用 `/api/v1/check` 检测更新
- 自动生成 HMAC 请求签名头
- 校验服务端 Ed25519 更新清单签名
- 下载更新包
- 校验 APK / 安装包 SHA256
- Android 打开系统 APK 安装界面
- 支持旧版本封禁、强制更新、推荐更新、灰度发布

## 1. 放进主项目

推荐目录：

```text
你的Flutter项目/
  lib/
  android/
  pubspec.yaml
  packages/
    gx_update_client/
```

把本包整个复制到：

```text
packages/gx_update_client
```

主项目 `pubspec.yaml` 添加：

```yaml
dependencies:
  gx_update_client:
    path: packages/gx_update_client
```

然后执行：

```bash
flutter pub get
```

## 2. Android 权限

本包的 AndroidManifest 会自动合并：

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

Android 8.0+ 首次安装 APK 时，用户可能需要给当前 App 授权“安装未知应用”。包内提供：

```dart
await GxUpdateInstaller.canRequestPackageInstalls();
await GxUpdateInstaller.openInstallPermissionSettings();
```

## 3. 初始化客户端

```dart
import 'package:gx_update_client/gx_update_client.dart';

final updateClient = GxUpdateClient(
  config: const GxUpdateConfig(
    baseUrl: 'https://update.example.com',
    appId: 'com.example.class_tool',
    clientSecret: '服务端创建项目返回的 client_secret',
    ed25519PublicKey: '服务端创建项目返回的 ed25519_public_key',
    platform: 'android',
    arch: 'universal',
    channel: 'stable',
  ),
);
```

## 4. 检测更新

```dart
final installId = await GxUpdateIdentity.getOrCreateInstallId();
final resp = await updateClient.check(
  clientId: installId,
  installId: installId,
);

if (!resp.legal.allowed) {
  // 版本被封禁 / 版本过旧 / 维护中
  // 这里应该阻止进入主页面
  print(resp.legal.message);
  return;
}

if (!resp.update.available) {
  // 没有更新
  return;
}

if (resp.update.isForce) {
  // 强制更新：弹出不可取消弹窗
} else {
  // 推荐更新：弹出可跳过弹窗
}
```

## 5. 下载并安装 Android APK

```dart
final package = await updateClient.downloadAndVerify(
  resp.update,
  onProgress: (p) {
    final value = p.fraction;
    if (value != null) {
      print('download: ${(value * 100).toStringAsFixed(1)}%');
    }
  },
);

final allowed = await GxUpdateInstaller.canRequestPackageInstalls();
if (!allowed) {
  await GxUpdateInstaller.openInstallPermissionSettings();
  return;
}

await GxUpdateInstaller.installApk(package.filePath);
```

或者使用高层封装：

```dart
final service = GxUpdateService(updateClient);
await service.downloadAndInstallAndroid(update: resp.update);
```

## 6. 推荐接入位置

建议在启动页 / Splash / Home 初始化前检查：

```text
App 启动
  -> 读取本地 installId
  -> 请求 check
  -> legal.allowed = false：显示封禁/过旧提示，阻止进入主页面
  -> update.available = false：进入主页面
  -> recommended：显示可跳过更新弹窗
  -> force：显示不可取消更新弹窗
```

## 7. 安全边界

客户端内置的 `clientSecret` 只能防普通刷接口和低成本伪造请求，不能防逆向提取。

真正保护更新链路的是：

```text
HTTPS
+ 服务端 Ed25519 私钥签名
+ 客户端内置 Ed25519 公钥验签
+ 安装包 SHA256 校验
```

所以客户端必须保留：

```dart
await updateClient.verifyManifest(resp.update);
await updateClient.downloadAndVerify(resp.update);
```

不要直接信任 `download_url`。
