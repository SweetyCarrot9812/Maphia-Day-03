import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/app_provider.dart';
import '../../shared/widgets/hanoa_button.dart';
import '../../shared/widgets/hanoa_text_field.dart';

/// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _autoLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      autoLogin: _autoLogin,
    );

    if (success && mounted) {
      // 로그인 성공 - 라우터가 자동으로 적절한 화면으로 이동
      if (!authProvider.isOnboardingCompleted) {
        context.go(AppConstants.routeOnboarding);
      } else {
        context.go(AppConstants.routeHome);
      }
    } else if (mounted) {
      // 에러 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '로그인에 실패했습니다'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // 로고 및 타이틀
                _buildHeader(),

                const SizedBox(height: AppConstants.spacingXXL),

                // 로그인 폼
                _buildLoginForm(),

                const SizedBox(height: AppConstants.spacingL),

                // 자동 로그인 체크박스
                _buildAutoLoginCheckbox(),

                const SizedBox(height: AppConstants.spacingXL),

                // 로그인 버튼
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return HanoaButton(
                      text: '로그인',
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),

                const SizedBox(height: AppConstants.spacingL),

                // 회원가입 링크
                _buildSignUpLink(),

                const Spacer(),

                // 개발용 빠른 로그인 (Beta 기간)
                if (context.read<AppProvider>().isBetaFree)
                  _buildDevQuickLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 로고
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.home,
            color: AppColors.textWhite,
            size: 40,
          ),
        ),

        const SizedBox(height: AppConstants.spacingL),

        Text(
          'HANOA',
          style: AppTextStyles.logoText.copyWith(fontSize: 28),
        ),

        const SizedBox(height: AppConstants.spacingS),

        Text(
          '로그인하여 시작하세요',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        HanoaTextField(
          controller: _emailController,
          label: '이메일',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.validationEmailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return AppConstants.validationEmailInvalid;
            }
            return null;
          },
        ),

        const SizedBox(height: AppConstants.spacingM),

        HanoaTextField(
          controller: _passwordController,
          label: '비밀번호',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.validationPasswordRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAutoLoginCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _autoLogin,
          onChanged: (value) {
            setState(() {
              _autoLogin = value ?? true;
            });
          },
          activeColor: AppColors.hanoaNavy,
        ),
        const SizedBox(width: AppConstants.spacingS),
        Text(
          '자동 로그인',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppConstants.routeRegister),
          child: const Text('회원가입'),
        ),
      ],
    );
  }

  Widget _buildDevQuickLogin() {
    return Column(
      children: [
        const Divider(color: AppColors.divider),
        const SizedBox(height: AppConstants.spacingM),
        
        Text(
          'Beta 테스트용 빠른 로그인',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textLight,
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingS),
        
        TextButton(
          onPressed: () async {
            final authProvider = context.read<AuthProvider>();
            await authProvider.devLogin();
            if (mounted) {
              context.go(AppConstants.routeHome);
            }
          },
          child: Text(
            '테스트 계정으로 로그인',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.hanoaNavy,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}