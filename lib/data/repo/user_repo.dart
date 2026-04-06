/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:class_tool/data/api/api.dart';
import 'package:class_tool/data/auth/auth_storage.dart';
import 'package:class_tool/data/model/class_table_context.dart';
import 'package:class_tool/utils/http_utils.dart';
import 'package:class_tool/utils/log_util.dart';

enum UserRepoState { unknown, notLogin, checkingLogin, loggedIn, expired }

class UserRepo {
  UserRepoState _state = UserRepoState.unknown;
  ClassTablePageContext? _pageContext;
  ClassTableUserContext? _userContext;
  final AuthStorage storage = AuthStorage();
  final HttpUtils _http = HttpUtils();
  bool _offlineMode = false;

  bool _setupCalled = false;
  Future<void>? _setupTask;
  bool _isHandling = false;

  UserRepoState get state => _state;
  bool get isLogin => _state == UserRepoState.loggedIn;
  bool get isOfflineMode => _offlineMode;
  String get username => storage.username ?? '';
  String get userId => _userContext?.userId ?? storage.userId ?? '';
  String get selectedSemester =>
      _userContext?.selectedSemester ?? storage.selectedSemester ?? '';
  String get campusId => _userContext?.campusId ?? storage.campusId ?? '';
  String get selectedCampusId =>
      _userContext?.selectedCampusId ?? storage.selectedCampusId ?? '';
  ClassTableUserContext? get userContext => _userContext;
  ClassTablePageContext? get pageContext => _pageContext;

  Future<void> setup() async {
    final activeTask = _setupTask;
    if (activeTask != null) {
      await activeTask;
      return;
    }

    final task = _performSetup();
    _setupTask = task;
    try {
      await task;
    } finally {
      if (identical(_setupTask, task)) {
        _setupTask = null;
      }
    }
  }

  Future<void> _performSetup() async {
    if (_setupCalled) {
      return;
    }
    _setupCalled = true;

    if (!storage.hasLogin) {
      _setNotLogin();
      return;
    }

    _state = UserRepoState.checkingLogin;
    _offlineMode = false;
    try {
      await _http.init();
      final context = await Api.getClassTableContext(
        semester: storage.selectedSemester ?? '',
        userId: storage.userId ?? '',
        campusId: storage.campusId ?? '',
        selectedCampusId: storage.selectedCampusId ?? '',
      );
      await _applyPageContext(context);
      _state = UserRepoState.loggedIn;
    } on ApiLoginExpiredException {
      await handleLoginExpired();
    } catch (e, s) {
      LogUtil.errorE('[UserRepo] setup failed', e, s);
      await _clearLogin(forceNotLogin: true);
    }
  }

  Future<bool> login(
    String username,
    String password, {
    bool autoRelogin = true,
  }) async {
    try {
      final loginResult = await Api.login(
        username: username,
        password: password,
        rememberMe: autoRelogin,
        clearBeforeLogin: true,
      );

      final context = Api.parseClassTableContextFromHtml(loginResult.html);
      _offlineMode = false;
      await _applyPageContext(context);
      await storage.saveLogin(
        username: username,
        userId: _userContext?.userId ?? '',
        selectedSemester: _userContext?.selectedSemester ?? '',
        campusId: _userContext?.campusId ?? '',
        selectedCampusId: _userContext?.selectedCampusId ?? '',
        autoRelogin: autoRelogin,
        password: password,
      );

      _state = UserRepoState.loggedIn;
      return true;
    } on ApiLoginExpiredException {
      await handleLoginExpired();
      return false;
    } catch (e, s) {
      LogUtil.errorE('[UserRepo] login failed', e, s);
      await _clearLogin(forceNotLogin: true);
      return false;
    }
  }

  Future<bool> refreshLoginContext() async {
    if (!storage.hasLogin) {
      return false;
    }

    try {
      final context = await Api.getClassTableContext(
        semester: selectedSemester,
        userId: userId,
        campusId: campusId,
        selectedCampusId: selectedCampusId,
      );
      await _applyPageContext(context);
      _offlineMode = false;
      _state = UserRepoState.loggedIn;
      return true;
    } on ApiLoginExpiredException {
      await handleLoginExpired();
      return false;
    } catch (e, s) {
      LogUtil.errorE('[UserRepo] refresh context failed', e, s);
      return false;
    }
  }

  Future<void> logout() async {
    if (_isHandling) {
      return;
    }
    _isHandling = true;
    try {
      await storage.clearAutoLogin();
      await _clearLogin(forceNotLogin: true);
    } finally {
      _isHandling = false;
    }
  }

  Future<void> handleLoginExpired() async {
    _state = UserRepoState.expired;

    if (storage.autoRelogin) {
      final relogin = await _autoRelogin();
      if (relogin) {
        return;
      }
    }

    await _clearLogin(forceNotLogin: true);
  }

  Future<bool> recoverFromExpiredLogin() async {
    await handleLoginExpired();
    return isLogin;
  }

  Future<void> restoreOfflineSession() async {
    final storedUserId = storage.userId ?? '';
    final storedSemester = storage.selectedSemester ?? '';
    if (storedUserId.isEmpty || storedSemester.isEmpty) {
      _setNotLogin();
      return;
    }

    _userContext = ClassTableUserContext(
      selectedSemester: storedSemester,
      userId: storedUserId,
      campusId: storage.campusId ?? '',
      selectedCampusId: storage.selectedCampusId ?? '',
    );
    _pageContext = ClassTablePageContext(
      userContext: _userContext!,
      semesters: const <ClassTableSemester>[],
    );
    _offlineMode = true;
    _state = UserRepoState.loggedIn;
    LogUtil.info(
      '[UserRepo] restoreOfflineSession semester=${_userContext?.selectedSemester} userId=${_userContext?.userId}',
    );
  }

  Future<void> syncUserContext(ClassTableUserContext context) async {
    await _applyContext(context);
    _state = UserRepoState.loggedIn;
  }

  Future<void> _applyPageContext(ClassTablePageContext context) async {
    _pageContext = context;
    await _applyContext(context.userContext);
  }

  Future<bool> _autoRelogin() async {
    final last = storage.lastInputPwdTime;
    if (last == null || DateTime.now().difference(last).inDays > 7) {
      return false;
    }

    final savedPassword = await storage.password;
    final savedUsername = storage.username;
    if (savedUsername == null ||
        savedUsername.isEmpty ||
        savedPassword == null ||
        savedPassword.isEmpty) {
      return false;
    }

    return login(savedUsername, savedPassword, autoRelogin: true);
  }

  Future<void> _applyContext(ClassTableUserContext context) async {
    if (_sameContext(_userContext, context) &&
        storage.userId == context.userId &&
        storage.selectedSemester == context.selectedSemester &&
        storage.campusId == context.campusId &&
        storage.selectedCampusId == context.selectedCampusId) {
      LogUtil.debug('[UserRepo] skip applyContext because context is unchanged');
      return;
    }

    _userContext = context;
    LogUtil.info(
      '[UserRepo] applyContext semester=${context.selectedSemester} userId=${context.userId} xqid=${context.campusId} xqid1=${context.selectedCampusId}',
    );
    await storage.updateContext(
      selectedSemester: context.selectedSemester,
      userId: context.userId,
      campusId: context.campusId,
      selectedCampusId: context.selectedCampusId,
    );
  }

  Future<void> _clearLogin({required bool forceNotLogin}) async {
    await storage.clear();
    await _http.clearCookies();
    _pageContext = null;
    _userContext = null;
    _offlineMode = false;
    if (forceNotLogin) {
      _setNotLogin();
    }
  }

  void _setNotLogin() {
    _state = UserRepoState.notLogin;
  }

  bool _sameContext(
    ClassTableUserContext? a,
    ClassTableUserContext b,
  ) {
    if (a == null) {
      return false;
    }
    return a.selectedSemester == b.selectedSemester &&
        a.userId == b.userId &&
        a.campusId == b.campusId &&
        a.selectedCampusId == b.selectedCampusId;
  }
}
