import 'package:class_tool/pages/login/controller.dart';
import 'package:class_tool/ui/app_button.dart';
import 'package:class_tool/ui/app_context.dart';
import 'package:class_tool/ui/app_icon_button.dart';
import 'package:class_tool/ui/app_icons.dart';
import 'package:class_tool/ui/app_surface.dart';
import 'package:class_tool/ui/app_text_field.dart';
import 'package:class_tool/ui/app_tokens.dart';
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
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: AppTokens.gap20),
                  _LoginPanel(
                    controller: controller,
                    accountTextController: accountTextController,
                    passwordTextController: passwordTextController,
                  ),
                  const SizedBox(height: AppTokens.gap16),
                  const _HelpPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            child: Image.asset('assets/images/icon.png'),
          ),
        ),
        const SizedBox(height: AppTokens.gap16),
        Text(
          'GXNU Class Tool',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppTokens.gap6),
        Text(
          '使用统一身份认证登录，同步学期、周次与课程安排。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppTokens.gap8),
        FutureBuilder<String>(
          future: AppInfoUtil.getVersionLabel(),
          builder: (context, snapshot) {
            final versionText = snapshot.data == null
                ? '版本信息获取中'
                : '版本 ${snapshot.data}';
            return Text(
              versionText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textTertiary),
            );
          },
        ),
      ],
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.controller,
    required this.accountTextController,
    required this.passwordTextController,
  });

  final LoginController controller;
  final TextEditingController accountTextController;
  final TextEditingController passwordTextController;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppSurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IconBox(icon: AppIcons.login),
              const SizedBox(width: AppTokens.gap10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '统一身份认证',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppTokens.gap4),
                    Text(
                      '请输入账户信息继续',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.gap20),
          _AccountField(
            controller: controller,
            textController: accountTextController,
          ),
          const SizedBox(height: AppTokens.gap14),
          _PasswordField(
            controller: controller,
            textController: passwordTextController,
          ),
          const SizedBox(height: AppTokens.gap12),
          _RememberLoginRow(controller: controller),
          const SizedBox(height: AppTokens.gap20),
          _LoginButton(controller: controller),
        ],
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
      () => AppTextField(
        controller: textController,
        label: '学号 / 工号',
        prefixIcon: AppIcons.person,
        onChanged: controller.setAccount,
        enabled: controller.isInputEnabled,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
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
      () => AppTextField(
        controller: textController,
        label: '密码',
        prefixIcon: AppIcons.password,
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
        suffix: AppIconButton(
          icon: controller.obscurePassword.value
              ? AppIcons.visibilityOff
              : AppIcons.visibility,
          tooltip: controller.obscurePassword.value ? '显示密码' : '隐藏密码',
          variant: AppIconButtonVariant.ghost,
          onPressed: controller.isInputEnabled
              ? controller.togglePasswordVisible
              : null,
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
    final colors = context.colors;

    return Obx(() {
      final selected = controller.rememberLogin.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          onTap: controller.isInputEnabled
              ? () => controller.setRememberLogin(!selected)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusXs),
                    border: Border.all(
                      color: selected ? colors.primary : colors.border,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          AppIcons.checkmark,
                          size: 15,
                          color: colors.textInverse,
                        )
                      : null,
                ),
                const SizedBox(width: AppTokens.gap10),
                Expanded(
                  child: Text(
                    '记住登录状态',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppButton(
        label: controller.isLoading.value ? '登录中' : '登录',
        icon: controller.isLoading.value ? null : AppIcons.login,
        fullWidth: true,
        onPressed: controller.isLoading.value ? null : controller.startLogin,
      ),
    );
  }
}

class _HelpPanel extends StatelessWidget {
  const _HelpPanel();

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _InfoSection(
            title: '登录说明',
            lines: [
              'App 需要自动完成登录，以提供基于账户的课程表相关功能。',
              '不同功能可能依赖不同系统。为正常使用 App，请关闭统一身份认证中的“单处登录”功能。',
              '当账户登录失败次数过多、触发异地登录校验或系统要求验证码时，可能需要重新人工登录。',
            ],
          ),
          SizedBox(height: AppTokens.gap20),
          _InfoSection(
            title: '隐私说明',
            lines: ['账号密码仅用于本地登录流程，不会上传到开发者服务器保存。', '退出登录会清除本地保存的登录状态与相关会话信息。'],
          ),
          SizedBox(height: AppTokens.gap20),
          _InfoSection(
            title: '风险说明',
            lines: [
              '本 App 通过模拟真实请求访问相关系统，第三方工具登录仍然存在账户风控风险。',
              '如学校系统策略变更、触发验证码或异常登录判定，可能导致登录失败或会话失效。',
            ],
          ),
        ],
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
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppTokens.gap8),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.gap6),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Icon(icon, size: AppTokens.iconMd, color: colors.primary),
    );
  }
}
