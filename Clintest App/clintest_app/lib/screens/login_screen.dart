import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'student_nurse_home_screen.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart';
// import '../../../../../../common/hanoa_brand_assets.dart'; // TODO: 브랜드 에셋 경로 수정 필요

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isEmailMode = true; // 이메일 로그인 모드 - 시작시 바로 활성화
  bool _isRegisterMode = false;
  bool _isCheckingEmail = false;
  bool _emailExists = false;
  String? _emailCheckMessage;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 이메일 중복 확인 (로컬 저장소 기반 + 관리자 계정 체크)
  Future<void> _checkEmailExists(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailCheckMessage = null;
        _emailExists = false;
      });
      return;
    }

    setState(() => _isCheckingEmail = true);

    try {
      // 관리자 계정 체크
      if (email.trim() == 'hanoa01@gmail.com') {
        setState(() {
          _emailExists = true;
          _emailCheckMessage = '관리자 계정입니다';
        });
        setState(() => _isCheckingEmail = false);
        return;
      }
      
      // 로컬 저장소에서 기존 이메일 확인
      final existingEmail = StorageService.getString('user_email');
      final exists = existingEmail == email.trim();
      
      setState(() {
        _emailExists = exists;
        _emailCheckMessage = exists ? '이미 가입된 이메일입니다' : '사용 가능한 이메일입니다';
      });
    } catch (e) {
      print('이메일 중복 확인 오류: $e');
      setState(() {
        _emailExists = false;
        _emailCheckMessage = null;
      });
    } finally {
      setState(() => _isCheckingEmail = false);
    }
  }

  // 이메일 로그인 (AtlasAuthService 사용)
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    _authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      // 사용자 역할에 따라 적절한 홈 화면으로 이동
      final role = await SecureStorageService.getUserRole() ?? 'student';
      if (role == 'admin') {
        _navigateToHome('admin');
      } else {
        _navigateToHome('학생간호사'); // 기본 역할
      }
    } else {
      _showErrorDialog(_authService.error ?? '로그인에 실패했습니다');
    }
  }

  // 회원가입 (AtlasAuthService 사용)
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _authService = Provider.of<AuthService>(context, listen: false);

    final success = await _authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      _navigateToHome('학생간호사'); // 기본 역할
    } else {
      _showErrorDialog(_authService.error ?? '회원가입에 실패했습니다');
    }
  }

  // Google 로그인
  Future<void> _handleGoogleLogin(AuthService authService) async {
    try {
      final credential = await authService.signInWithGoogle();

      if (credential != null && credential.user != null) {
        _navigateToHome('학생간호사'); // 기본 역할
      } else {
        // 사용자가 취소한 경우는 에러 메시지 표시하지 않음
      }
    } catch (e) {
      _showErrorDialog(authService.error ?? 'Google 로그인에 실패했습니다');
    }
  }

  void _navigateToHome(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (role == 'admin') {
            return const AdminHomeScreen();
          } else if (role == 'AI-기반-회화-학습자') {
            return const HomeScreen();
          } else {
            return StudentNurseHomeScreen();
          }
        },
      ),
    );
  }

  // 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                const SizedBox(height: 40),
                
                // Clintest 로고 개선
                Column(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Clintest',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AI 의료 학습 플랫폼',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                if (!_isEmailMode) ...[
                  // 메인 로그인 옵션들
                  const Text(
                    '시작하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Google 로그인 버튼
                  _SocialLoginButton(
                    icon: Icons.g_mobiledata,
                    text: 'Google로 계속하기',
                    onPressed: authService.isLoading ? null : () => _handleGoogleLogin(authService),
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    borderColor: Colors.grey[300],
                  ),

                  const SizedBox(height: 16),

                  // 이메일로 계속하기 버튼
                  _SocialLoginButton(
                    icon: Icons.email,
                    text: '이메일로 계속하기',
                    onPressed: authService.isLoading ? null : () {
                      setState(() {
                        _isEmailMode = true;
                        _isRegisterMode = false;
                      });
                    },
                    backgroundColor: AppTheme.primaryColor,
                    textColor: Colors.white,
                  ),

                  const SizedBox(height: 16),

                  // 뒤로가기 버튼
                  _SocialLoginButton(
                    icon: Icons.arrow_back,
                    text: '뒤로',
                    onPressed: authService.isLoading ? null : () => Navigator.pop(context),
                    backgroundColor: Colors.grey[100]!,
                    textColor: Colors.grey[700]!,
                  ),
                ] else ...[
                  // 이메일 로그인 폼
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // 이전 화면으로 돌아가기
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            Text(
                              _isRegisterMode ? '회원가입' : '로그인',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        if (_isRegisterMode) ...[
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: '이름',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이름을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  labelText: '이메일',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '이메일을 입력해주세요';
                                  }
                                  if (!value.contains('@')) {
                                    return '올바른 이메일 형식을 입력해주세요';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_isRegisterMode) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isCheckingEmail ? null : () {
                                    if (_emailController.text.isNotEmpty && _emailController.text.contains('@')) {
                                      _checkEmailExists(_emailController.text);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: _isCheckingEmail
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('중복확인'),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (_emailCheckMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _emailCheckMessage!,
                            style: TextStyle(
                              color: _emailExists ? Colors.red : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: '비밀번호',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            if (value.length < 6) {
                              return '비밀번호는 6자 이상이어야 합니다';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: (authService.isLoading || (_isRegisterMode && _emailExists))
                              ? null
                              : (_isRegisterMode ? _handleRegister : _handleLogin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authService.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(_isRegisterMode ? '회원가입' : '로그인'),
                        ),

                        const SizedBox(height: 16),

                        // 모드 전환 버튼
                        TextButton(
                          onPressed: authService.isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isRegisterMode = !_isRegisterMode;
                                    _emailExists = false;
                                    _emailCheckMessage = null;
                                    _formKey.currentState?.reset();
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _nameController.clear();
                                  });
                                },
                          child: Text(
                            _isRegisterMode ? '이미 계정이 있으신가요? 로그인' : '계정이 없으신가요? 회원가입',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialLoginButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}