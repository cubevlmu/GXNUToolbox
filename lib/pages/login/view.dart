import 'package:class_tool/pages/login/controller.dart';
import 'package:class_tool/utils/app_info_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller;
  late final TextEditingController accountTextController;
  final TextEditingController passwordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(LoginController(), permanent: false);
    accountTextController = TextEditingController(text: controller.account);
  }

  @override
  void dispose() {
    accountTextController.dispose();
    passwordTextController.dispose();
    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '统一身份认证',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '使用学号或工号登录后，可同步学期、周次与课程安排。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<String>(
                    future: AppInfoUtil.getVersionLabel(),
                    builder: (context, snapshot) {
                      final versionText = snapshot.data == null
                          ? '版本信息获取中'
                          : '版本 ${snapshot.data}';
                      return Text(
                        versionText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '登录',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '请输入统一身份认证账户信息',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 20),
                          _AccountField(
                            controller: controller,
                            textController: accountTextController,
                          ),
                          const SizedBox(height: 14),
                          _PasswordField(
                            controller: controller,
                            textController: passwordTextController,
                          ),
                          const SizedBox(height: 10),
                          _RememberLoginRow(controller: controller),
                          const SizedBox(height: 18),
                          _LoginButton(controller: controller),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoSection(
                            title: '登录说明',
                            lines: const [
                              'App 需要自动完成登录，以提供基于账户的课程表相关功能。',
                              '1. App 的不同功能可能依赖不同系统，需要同时保持多处登录。为正常使用 App，请关闭统一身份认证中的“单处登录”功能。',
                              '2. 当账户登录失败次数过多、触发异地登录校验或系统要求验证码时，App 可能无法自动登录，此时需要重新进行人工登录。',
                            ],
                          ),
                          const SizedBox(height: 18),
                          _InfoSection(
                            title: '隐私说明',
                            lines: const [
                              '本 App 会尽量遵守隐私最小化原则。账号密码仅用于本地登录流程，不会上传到开发者服务器保存。',
                              '登录后你可以随时使用“退出登录”清除本地保存的登录状态与相关会话信息。',
                            ],
                          ),
                          const SizedBox(height: 18),
                          _InfoSection(
                            title: '风险说明',
                            lines: const [
                              '本 App 通过模拟真实请求访问相关系统，但第三方工具登录仍然存在一定账户风险。',
                              '如学校系统策略变更、触发风控、验证码校验或异常登录判定，可能导致登录失败、会话失效，或需要你重新人工验证。',
                              '请确认你了解并接受相关风险后再继续使用。',
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField({required this.controller, required this.textController});

  final LoginController controller;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        controller: textController,
        onChanged: controller.setAccount,
        enabled: controller.isInputEnabled,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
        decoration: _buildInputDecoration(
          context,
          labelText: '学号 / 工号',
          prefixIcon: const Icon(Icons.person_outline_rounded),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.textController,
  });

  final LoginController controller;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        controller: textController,
        onChanged: controller.setPassword,
        enabled: controller.isInputEnabled,
        obscureText: controller.obscurePassword.value,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          if (!controller.isLoading.value) {
            controller.startLogin();
          }
        },
        autofillHints: const [AutofillHints.password],
        decoration: _buildInputDecoration(
          context,
          labelText: '密码',
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: controller.isInputEnabled
                  ? controller.togglePasswordVisible
                  : null,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
                maximumSize: const Size(40, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              splashRadius: 18,
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RememberLoginRow extends StatelessWidget {
  const _RememberLoginRow({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: controller.rememberLogin.value,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: controller.isInputEnabled
                ? (value) {
                    controller.setRememberLogin(value ?? true);
                  }
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('记住登录状态', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FilledButton(
        onPressed: controller.isLoading.value ? null : controller.startLogin,
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : const Text('登录'),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _buildInputDecoration(
  BuildContext context, {
  required String labelText,
  required Widget prefixIcon,
  Widget? suffixIcon,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    labelText: labelText,
    filled: true,
    fillColor: colorScheme.surface,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
    ),
  );
}
