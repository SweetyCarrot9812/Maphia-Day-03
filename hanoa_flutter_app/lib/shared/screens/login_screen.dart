import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

/// 로그인 화면
/// 
/// Google 로그인을 통한 Hanoa 계정 인증
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  /// Google 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await AuthService.signInWithGoogle();
      
      if (userCredential != null) {
        // 로그인 성공
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('환영합니다, ${userCredential.user?.displayName ?? '사용자'}님!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 메인 화면으로 이동 (현재는 뒤로가기)
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthService.getLocalizedErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 게스트 로그인 처리
  Future<void> _handleGuestSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInAnonymously();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게스트로 로그인되었습니다'),
            backgroundColor: Colors.blue,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AuthService.getLocalizedErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF7B68EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 영역
                const Icon(
                  Icons.school,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                
                // 앱 이름
                const Text(
                  'Hanoa',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // 부제목
                const Text(
                  '하나의 앱에서 모든 학습을',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),

                // 에러 메시지
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Google 로그인 버튼
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      )
                    : Image.asset(
                        'assets/icons/google_icon.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.login,
                            size: 20,
                            color: Colors.grey,
                          );
                        },
                      ),
                  label: Text(
                    _isLoading ? '로그인 중...' : 'Google로 로그인',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // 게스트 로그인 버튼
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGuestSignIn,
                  icon: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    '게스트로 체험하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 서비스 정보
                const Text(
                  '• 간호사 국가고시 준비\n• 의학 용어 학습\n• 언어 학습 (영어, 일본어, 중국어)\n• 오프라인 학습 지원',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}