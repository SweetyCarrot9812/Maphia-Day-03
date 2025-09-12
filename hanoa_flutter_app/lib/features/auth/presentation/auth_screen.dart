import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_state_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../../../core/services/auth_service.dart' as CoreAuth;

/// 로그인/회원가입 화면
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    
    // 디버그용 - 저장된 사용자 목록 출력
    _debugPrintUsers();
  }
  
  void _debugPrintUsers() async {
    await AuthService.instance.debugPrintAllUsers();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }
  
  void _handleAuth() async {
    // 입력 검증
    if (_emailController.text.trim().isEmpty) {
      _showMessage('이메일을 입력해주세요.');
      return;
    }
    
    if (_passwordController.text.trim().isEmpty) {
      _showMessage('비밀번호를 입력해주세요.');
      return;
    }
    
    if (!_isLogin && _nameController.text.trim().isEmpty) {
      _showMessage('이름을 입력해주세요.');
      return;
    }

    try {
      AuthResult result;
      
      print('🔍 로그인 시도: ${_emailController.text.trim()}');
      
      if (_isLogin) {
        // 로그인
        result = await AuthService.instance.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // 회원가입
        result = await AuthService.instance.signUp(
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      
      print('🔍 인증 결과: ${result.success} - ${result.message}');
      
      if (result.success) {
        _showMessage(result.message);
        
        // 성공시 온보딩 화면으로 이동
        ref.read(onboardingCompletedProvider.notifier).state = false;
        ref.read(onboardingTurnProvider.notifier).state = 1;
        context.go('/onboarding');
      } else {
        _showMessage(result.message, isError: true);
        // 실패시 다시 사용자 목록 출력
        await AuthService.instance.debugPrintAllUsers();
      }
    } catch (e) {
      print('🔍 예외 발생: $e');
      _showMessage('오류가 발생했습니다: $e', isError: true);
    }
  }
  
  /// Google 로그인 처리
  void _handleGoogleSignIn() async {
    try {
      print('🔍 Google 로그인 시도');
      
      final userCredential = await CoreAuth.AuthService.signInWithGoogle();
      
      if (userCredential != null) {
        _showMessage('Google 로그인 성공: ${userCredential.user?.displayName ?? '사용자'}님!');
        
        // 성공시 온보딩 화면으로 이동
        ref.read(onboardingCompletedProvider.notifier).state = false;
        ref.read(onboardingTurnProvider.notifier).state = 1;
        context.go('/onboarding');
      } else {
        _showMessage('Google 로그인이 취소되었습니다.');
      }
    } catch (e) {
      print('🔍 Google 로그인 예외: $e');
      _showMessage('Google 로그인 오류: ${CoreAuth.AuthService.getLocalizedErrorMessage(e)}', isError: true);
    }
  }
  
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    
                    // 로고
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/hanoa_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 환영 메시지
                    Text(
                      _isLogin ? '다시 만나서 반가워요!' : '새로운 여정을 시작해보세요!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _isLogin 
                          ? 'Hanoa와 함께 계속 성장해나가요' 
                          : 'AI와 함께하는 개인 맞춤형 학습을 경험해보세요',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // 회원가입시 이름 필드
                    if (!_isLogin) ...[
                      _buildTextField(
                        controller: _nameController,
                        label: '이름',
                        hint: '이름을 입력해주세요',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 이메일 필드
                    _buildTextField(
                      controller: _emailController,
                      label: '이메일',
                      hint: '이메일을 입력해주세요',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 비밀번호 필드
                    _buildTextField(
                      controller: _passwordController,
                      label: '비밀번호',
                      hint: '비밀번호를 입력해주세요',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 로그인/회원가입 버튼
                    ElevatedButton(
                      onPressed: _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _isLogin ? '로그인' : '회원가입',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 소셜 로그인 (나중에 구현)
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '또는',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 구글/애플 로그인 버튼들 (UI만)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleSignIn,
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: const Text('Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showMessage('애플 로그인 서비스 준비중입니다.');
                            },
                            icon: const Icon(Icons.apple, size: 20),
                            label: const Text('Apple'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 모드 전환
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? '아직 계정이 없으신가요?' : '이미 계정이 있으신가요?',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _toggleMode,
                          child: Text(
                            _isLogin ? '회원가입' : '로그인',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textSecondaryColor),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}