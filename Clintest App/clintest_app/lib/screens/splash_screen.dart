import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'ai_chat_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // 애니메이션 시작
      _animationController.forward();
      
      // 최소 스플래시 시간 (StorageService는 main.dart에서 이미 초기화됨)
      await Future.delayed(const Duration(seconds: 2));
      
      // 네비게이션
      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      debugPrint('앱 초기화 중 오류: $e');
      // 오류 발생 시 기본 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }


  void _navigateToNextScreen() {
    try {
      Widget nextScreen;
      
      // 로그인 기능 활성화
      // 안전하게 첫 실행 여부 확인
      bool isFirstLaunch = true;
      try {
        isFirstLaunch = StorageService.isFirstLaunch;
      } catch (e) {
        debugPrint('첫 실행 확인 중 오류: $e');
        isFirstLaunch = true; // 기본값으로 설정
      }
      
      if (isFirstLaunch) {
        // 첫 실행 시 온보딩 화면
        nextScreen = const OnboardingScreen();
      } else {
        // 로그인된 사용자 확인
        try {
          final userId = StorageService.userId;
          final authToken = StorageService.authToken;
          
          if (userId != null && authToken != null) {
            // 로그인된 사용자 - AI 설정 완료 여부 확인
            final aiSetupCompleted = StorageService.getBool('ai_setup_completed', defaultValue: false);
            
            if (!aiSetupCompleted) {
              // AI 설정 미완료 - AI 채팅 설정 화면
              nextScreen = const AiChatSetupScreen();
            } else {
              // AI 설정 완료 - 홈 화면으로 이동
              nextScreen = const HomeScreen();
            }
          } else {
            // 미로그인 사용자 - 로그인 화면
            nextScreen = const LoginScreen();
          }
        } catch (e) {
          debugPrint('사용자 정보 확인 중 오류: $e');
          nextScreen = const LoginScreen(); // 기본값으로 설정
        }
      }
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      debugPrint('네비게이션 중 오류: $e');
      // 최종 fallback - 오류 발생 시 로그인 화면으로
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 아이콘
                    Container(
                      width: 120,
                      height: 120,
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
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 앱 타이틀
                    const Text(
                      'Clintest',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 서브 타이틀
                    const Text(
                      'AI 의료 학습 플랫폼',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // 로딩 인디케이터
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        strokeWidth: 3,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 로딩 텍스트
                    const Text(
                      '시스템 초기화 중...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}