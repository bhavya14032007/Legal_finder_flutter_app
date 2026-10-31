import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(_emailController.text);

    if (success && mounted) {
      setState(() {
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: _submitted
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.verticalSpaceXl,
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 64,
                      color: AppColors.success,
                    ),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      'Check Your Inbox',
                      style: AppTypography.titleLarge.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalSpaceSm,
                    Text(
                      'We have sent a secure password reset link to ${_emailController.text}. Follow the instructions to recover your account.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalSpaceXxl,
                    LegalButton(
                      text: 'Return to Sign In',
                      onPressed: () => context.pop(),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Password Recovery',
                        style: AppTypography.displayMedium.copyWith(
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.verticalSpaceXxs,
                      Text(
                        'Enter the email address registered with your Legal Helper account.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      AppSpacing.verticalSpaceLg,

                      LegalTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.mail_outline, size: 20),
                        validator: Validators.email,
                      ),
                      AppSpacing.verticalSpaceLg,

                      LegalButton(
                        text: 'Send Reset Link',
                        onPressed: _handleSubmit,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
