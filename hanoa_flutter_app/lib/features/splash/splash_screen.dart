import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/app_provider.dart';

/// 스플래시 화면
/// - 흰 배경 + HANOA 로고
/// - 2-3초 애니메이션 (로드 완료 시 즉시 종료, 최대 3초)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _animationCompleted = false;
  bool _initializationCompleted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// 애니메이션 설정
  void _setupAnimations() {
    // 스케일 애니메이션 (로고 확대/축소)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 페이드 애니메이션 (로고 페이드인)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    _scaleController.forward().then((_) {
      setState(() {
        _animationCompleted = true;
      });
      _checkNavigationReady();
    });
  }

  /// 앱 초기화
  Future<void> _initializeApp() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final appProvider = context.read<AppProvider>();

      // 병렬 초기화
      await Future.wait([
        authProvider.initialize(),
        appProvider.initialize(),
      ]);

      setState(() {
        _initializationCompleted = true;
      });
      
      _checkNavigationReady();
    } catch (e) {
      // 초기화 실패 시에도 다음 화면으로 진행
      debugPrint('Splash initialization error: $e');
      setState(() {
        _initializationCompleted = true;
      });
      _checkNavigationReady();
    }
  }

  /// 네비게이션 준비 확인 및 이동
  void _checkNavigationReady() {
    if (!mounted) return;

    // 최소 시간 대기 후 이동 (애니메이션과 초기화 완료)
    if (_animationCompleted && _initializationCompleted) {
      _navigateToNextScreen();
    }
  }

  /// 다음 화면으로 이동
  void _navigateToNextScreen() {
    final authProvider = context.read<AuthProvider>();
    
    // 경로 결정
    String nextRoute;
    if (!authProvider.isAuthenticated) {
      nextRoute = AppConstants.routeLogin;
    } else if (!authProvider.isOnboardingCompleted) {
      nextRoute = AppConstants.routeOnboarding;
    } else {
      nextRoute = AppConstants.routeHome;
    }

    // 최소 표시 시간 보장 후 이동
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go(nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Consumer2<AuthProvider, AppProvider>(
        builder: (context, authProvider, appProvider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 영역
                AnimatedBuilder(
                  animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildLogo(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // 로딩 인디케이터
                if (authProvider.isLoading || appProvider.isLoading)
                  const _LoadingIndicator()
                else
                  // 로딩 완료 후 체크마크 (선택사항)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),

                const SizedBox(height: AppConstants.spacingL),

                // 상태 텍스트
                _buildStatusText(authProvider, appProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 로고 위젯
  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 로고 이미지
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                offset: const Offset(0, 8),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              AppConstants.logoPath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              // 로고 파일이 없는 경우 대체 위젯
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.home,
                    color: AppColors.textWhite,
                    size: 48,
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: AppConstants.spacingL),

        // HANOA 텍스트
        Text(
          'HANOA',
          style: AppTextStyles.logoText.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),

        const SizedBox(height: AppConstants.spacingS),

        // 서브 타이틀
        Text(
          '슈퍼앱',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  /// 상태 텍스트
  Widget _buildStatusText(AuthProvider authProvider, AppProvider appProvider) {
    String statusText;
    
    if (authProvider.isLoading || appProvider.isLoading) {
      statusText = '초기화 중...';
    } else if (authProvider.errorMessage != null) {
      statusText = '오류가 발생했습니다';
    } else {
      statusText = '준비 완료';
    }

    return Text(
      statusText,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textLight,
      ),
    );
  }
}

/// 로딩 인디케이터
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.hanoaNavy),
        backgroundColor: AppColors.divider,
      ),
    );
  }
}