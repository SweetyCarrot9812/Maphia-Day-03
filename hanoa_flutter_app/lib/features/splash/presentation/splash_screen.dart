import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// 스플래시 스크린 - 로고 표시 및 초기 로딩
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    
    // 로고 애니메이션
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // 텍스트 애니메이션
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));
    
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimationSequence();
  }
  
  void _startAnimationSequence() async {
    // 로고 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // 텍스트 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    
    // 총 3초 후 로그인/회원가입 화면으로 이동
    await Future.delayed(const Duration(milliseconds: 2100));
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value.clamp(0.0, 1.0),
                    child: Opacity(
                      opacity: _logoAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 8),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ],
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
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // 브랜드명
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textAnimation.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - _textAnimation.value)),
                      child: const Text(
                        'HANOA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              // 슬로건
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: (_textAnimation.value * 0.8).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _textAnimation.value)),
                      child: Text(
                        'AI와 함께하는 개인 맞춤형 성장 여정',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // 로딩 인디케이터
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: (_textAnimation.value * 0.6).clamp(0.0, 1.0),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}