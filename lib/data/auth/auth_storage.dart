/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:class_tool/data/auth/storage_keys.dart';
import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/utils/storage_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class AuthStorage {
  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Box<dynamic> get _box => StorageUtils.settings;

  String? get username => _box.get(AuthStorageKeys.username)?.toString();
  String? get userId => _box.get(AuthStorageKeys.userId)?.toString();
  String? get selectedSemester =>
      _box.get(AuthStorageKeys.selectedSemester)?.toString();
  String? get campusId => _box.get(AuthStorageKeys.campusId)?.toString();
  String? get selectedCampusId =>
      _box.get(AuthStorageKeys.selectedCampusId)?.toString();
  bool get hasLogin => _box.get(AuthStorageKeys.hasLogin) == true;
  bool get autoRelogin => _box.get(AuthStorageKeys.autoRelogin) == true;
  DateTime? get lastInputPwdTime => _box.get(AuthStorageKeys.lastInputPwd);

  Future<String?> get password async {
    final encrypted = await _secure.read(key: AuthStorageKeys.password);
    if (encrypted == null || encrypted.isEmpty) {
      return null;
    }
    return Api.decryptPasswordForLocalStorage(encrypted);
  }

  Future<void> saveLogin({
    required String username,
    required String userId,
    required String selectedSemester,
    required String campusId,
    required String selectedCampusId,
    required bool autoRelogin,
    String? password,
  }) async {
    await _box.put(AuthStorageKeys.hasLogin, true);
    await _box.put(AuthStorageKeys.username, username);
    await _box.put(AuthStorageKeys.userId, userId);
    await _box.put(AuthStorageKeys.selectedSemester, selectedSemester);
    await _box.put(AuthStorageKeys.campusId, campusId);
    await _box.put(AuthStorageKeys.selectedCampusId, selectedCampusId);
    await _box.put(AuthStorageKeys.autoRelogin, autoRelogin);

    if (autoRelogin && password != null && password.isNotEmpty) {
      await _secure.write(
        key: AuthStorageKeys.password,
        value: Api.encryptPasswordForLocalStorage(password),
      );
      await _box.put(AuthStorageKeys.lastInputPwd, DateTime.now());
    } else {
      await _secure.delete(key: AuthStorageKeys.password);
      await _box.delete(AuthStorageKeys.lastInputPwd);
    }
  }

  Future<void> updateContext({
    required String selectedSemester,
    required String userId,
    required String campusId,
    required String selectedCampusId,
  }) async {
    await _box.put(AuthStorageKeys.selectedSemester, selectedSemester);
    await _box.put(AuthStorageKeys.userId, userId);
    await _box.put(AuthStorageKeys.campusId, campusId);
    await _box.put(AuthStorageKeys.selectedCampusId, selectedCampusId);
  }

  Future<void> clear() async {
    await _box.put(AuthStorageKeys.hasLogin, false);
    await _box.delete(AuthStorageKeys.userId);
    await _box.delete(AuthStorageKeys.selectedSemester);
    await _box.delete(AuthStorageKeys.campusId);
    await _box.delete(AuthStorageKeys.selectedCampusId);
    await _box.delete(AuthStorageKeys.autoRelogin);
    await _box.delete(AuthStorageKeys.username);
    await _box.delete(AuthStorageKeys.lastInputPwd);
    await _secure.delete(key: AuthStorageKeys.password);
  }

  Future<void> clearAutoLogin() async {
    await _box.put(AuthStorageKeys.autoRelogin, false);
    await _box.delete(AuthStorageKeys.lastInputPwd);
    await _secure.delete(key: AuthStorageKeys.password);
  }
}
