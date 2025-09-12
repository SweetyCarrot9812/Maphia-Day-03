import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이용약관에 동의해주세요'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authService = context.read<AuthService>();
    
    final success = await authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? '회원가입에 실패했습니다'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // 타이틀
                const Text(
                  '새 계정 만들기',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // 이름 입력
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    labelText: '이름',
                    hintText: '홍길동',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '최소 8자 이상',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 8) {
                      return '비밀번호는 최소 8자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 비밀번호 확인 입력
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    hintText: '비밀번호를 다시 입력하세요',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // 이용약관 동의
                CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                  title: const Text(
                    '이용약관 및 개인정보처리방침에 동의합니다',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryColor,
                ),
                
                const SizedBox(height: 32),
                
                // 회원가입 버튼
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return ElevatedButton(
                      onPressed: authService.isLoading ? null : _register,
                      child: authService.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('회원가입'),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // 데모 안내
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 데모 버전 안내',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '현재 개발 중인 데모 버전입니다.\n실제 계정이 생성되지 않으며, 데이터는 앱 재시작 시 초기화됩니다.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}