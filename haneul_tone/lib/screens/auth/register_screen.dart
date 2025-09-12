import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    
    final result = await authService.register(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (mounted) {
      if (result['success']) {
        setState(() {
          _successMessage = result['message'];
        });
        
        // 회원가입 성공 - 잠시 후 홈 화면으로 이동
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 만들기'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 타이틀
                              Text(
                                '새 계정 만들기',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'HaneulTone과 함께 보컬 실력을 향상시켜보세요',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // 이메일 입력
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: '이메일',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(),
                                  helperText: '로그인에 사용할 이메일 주소',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '이메일을 입력해주세요';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return '유효한 이메일 주소를 입력해주세요';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 사용자명 입력
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: '사용자명',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                  helperText: '영문, 숫자, 밑줄만 사용 가능 (3자 이상)',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '사용자명을 입력해주세요';
                                  }
                                  if (value.length < 3) {
                                    return '사용자명은 3자 이상이어야 합니다';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                    return '영문, 숫자, 밑줄(_)만 사용할 수 있습니다';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 표시 이름 입력
                              TextFormField(
                                controller: _displayNameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: '표시 이름',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(),
                                  helperText: '다른 사용자에게 표시될 이름',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '표시 이름을 입력해주세요';
                                  }
                                  if (value.trim().length < 2) {
                                    return '표시 이름은 2자 이상이어야 합니다';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 비밀번호 입력
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: '비밀번호',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: const OutlineInputBorder(),
                                  helperText: '8자 이상의 안전한 비밀번호',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '비밀번호를 입력해주세요';
                                  }
                                  if (value.length < 8) {
                                    return '비밀번호는 8자 이상이어야 합니다';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 비밀번호 확인 입력
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleRegister(),
                                decoration: InputDecoration(
                                  labelText: '비밀번호 확인',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  border: const OutlineInputBorder(),
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
                              const SizedBox(height: 8),

                              // 오류/성공 메시지
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: theme.colorScheme.onErrorContainer,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: theme.colorScheme.onErrorContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_successMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: theme.colorScheme.onPrimaryContainer,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _successMessage!,
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // 회원가입 버튼
                              ElevatedButton(
                                onPressed: authService.isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: authService.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('계정 만들기', style: TextStyle(fontSize: 16)),
                              ),

                              const SizedBox(height: 16),

                              // 이용약관 동의 (임시)
                              Text(
                                '계정을 만들면 HaneulTone의 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}