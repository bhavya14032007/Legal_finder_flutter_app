import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/infinite_ribbon_motif.dart';
import '../../../../core/widgets/legal_button.dart';
import '../../../../core/widgets/legal_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );

    if (success && mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              bottom: -40,
              left: -40,
              child: InfiniteRibbonMotif(
                height: 160,
                width: 240,
                opacity: 0.2,
              ),
            ),
            SingleChildScrollView(
              padding: AppSpacing.paddingScreen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join Legal Helper',
                      style: AppTypography.displayMedium.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.verticalSpaceXxs,
                    Text(
                      'Empowering you with AI-driven legal intelligence',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    AppSpacing.verticalSpaceLg,

                    if (authState.errorMessage != null) ...[
                      Container(
                        padding: AppSpacing.paddingSm,
                        decoration: BoxDecoration(
                          color: AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          authState.errorMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                      AppSpacing.verticalSpaceMd,
                    ],

                    LegalTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'e.g. Adv. Rajesh Sharma',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      validator: (v) => Validators.requiredField(v, 'Full name'),
                    ),
                    AppSpacing.verticalSpaceMd,

                    LegalTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline, size: 20),
                      validator: Validators.email,
                    ),
                    AppSpacing.verticalSpaceMd,

                    LegalTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Minimum 8 characters',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: Validators.password,
                    ),
                    AppSpacing.verticalSpaceMd,

                    LegalTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      validator: (v) => Validators.confirmPassword(
                        v,
                        _passwordController.text,
                      ),
                    ),
                    AppSpacing.verticalSpaceLg,

                    LegalButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: authState.isLoading,
                    ),
                    AppSpacing.verticalSpaceLg,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: Text(
                            'Sign In',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.accentVioletLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

