import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/mongodb_service.dart';
import '../services/social_login_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'student_nurse_home_screen.dart';
import 'linguamigo_home_screen.dart';

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

  bool _isLoading = false;
  final bool _isEmailMode = false; // 이메일 로그인 모드
  bool _isRegisterMode = false;
  String? _selectedRole;
  
  final List<String> _roles = ['학생간호사', '간호사', '의사'];
  final SocialLoginService _socialLoginService = SocialLoginService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mongoService = MongoDBService();
      
      final result = await mongoService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result != null) {
        _navigateToHome(result['user']['role']);
      } else {
        _showErrorDialog('로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.');
      }
    } catch (e) {
      _showErrorDialog('로그인 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      if (_selectedRole == null) {
        _showErrorDialog('역할을 선택해주세요.');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final mongoService = MongoDBService();
      
      final result = await mongoService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole!,
      );

      if (result != null) {
        _navigateToHome(result['user']['role']);
      } else {
        _showErrorDialog('회원가입에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      _showErrorDialog('회원가입 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 구글 로그인
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _socialLoginService.signInWithGoogle();

      if (result != null) {
        _navigateToHome(result['user']['role']);
      } else {
        _showErrorDialog('구글 로그인에 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('구글 로그인 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 애플 로그인
  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _socialLoginService.signInWithApple();

      if (result != null) {
        _navigateToHome(result['user']['role']);
      } else {
        _showErrorDialog('애플 로그인에 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('애플 로그인 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHome(String role) {
    Widget homeScreen;
    if (role == '학생간호사') {
      homeScreen = const StudentNurseHomeScreen();
    } else {
      homeScreen = const LinguamigoHomeScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isRegisterMode ? '회원가입' : '로그인',
          style: AppTextStyles.heading2.copyWith(
            color: AppTheme.primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 아이콘
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                // 이름 입력 (회원가입 모드)
                if (_isRegisterMode) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이름을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@')) {
                      return '올바른 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: Icon(Icons.lock),
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
                
                const SizedBox(height: 16),

                // 역할 선택 (회원가입 모드)
                if (_isRegisterMode) ...[
                  const Text(
                    '역할',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(_roles.map((role) => RadioListTile<String>(
                    title: Text(role),
                    value: role,
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ))),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 32),

                // 로그인/회원가입 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : (_isRegisterMode ? _handleRegister : _handleLogin),
                  child: _isLoading
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
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                            _selectedRole = null;
                            _formKey.currentState?.reset();
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

                const Spacer(),

                // 데모 모드 버튼
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // 데모용 학생간호사로 로그인
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const StudentNurseHomeScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    '데모 모드로 체험하기',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
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