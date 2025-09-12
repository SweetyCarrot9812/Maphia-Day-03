import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_state_provider.dart';
import '../../../core/theme/app_theme.dart';

/// 온보딩 7턴 대화 화면 - 멀티 서비스 허브
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // 초기 애니메이션 시작
    _startInitialAnimation();
  }
  
  void _startInitialAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTurn = ref.watch(onboardingTurnProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildOnboardingContent(currentTurn),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildOnboardingContent(int turn) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // 진행률 표시
          _buildProgressIndicator(turn),
          const SizedBox(height: 40),
          
          // 대화 내용
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildTurnContent(index + 1);
              },
            ),
          ),
          
          // 하단 버튼
          _buildBottomButtons(turn),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(int currentTurn) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hanoa와 함께하는 여정',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$currentTurn / 2',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: currentTurn / 2,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 4,
        ),
      ],
    );
  }
  
  Widget _buildTurnContent(int turn) {
    final content = _getOnboardingContent(turn);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hanoa 메시지 (챗봇 스타일)
          _buildChatBubble(
            content['hanoa'] as String,
            isHanoa: true,
          ),
          
          const SizedBox(height: 24),
          
          // 사용자 응답 옵션들
          if (content['options'] != null) ...[
            const Text(
              '선택하세요:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...(content['options'] as List<String>).map((option) => 
              _buildOptionButton(option, turn)
            ).toList(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChatBubble(String message, {required bool isHanoa}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isHanoa) ...[
          // Hanoa 아바타
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHanoa 
                  ? Colors.white.withOpacity(0.1)
                  : AppTheme.accentColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
                fontWeight: isHanoa ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
        ),
        
        if (!isHanoa) ...[
          const SizedBox(width: 12),
          // 사용자 아바타 (필요시)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildOptionButton(String option, int turn) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => _selectOption(option, turn),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Text(
          option,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomButtons(int turn) {
    return Row(
      children: [
        if (turn > 1) ...[
          TextButton(
            onPressed: _goToPreviousTurn,
            child: Text(
              '이전',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ),
        ],
        
        // 마지막 턴에서만 시작하기 버튼 표시
        if (turn == 2) ...[
          const Spacer(),
          ElevatedButton(
            onPressed: _completeOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '시작하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  void _selectOption(String option, int turn) {
    // 옵션 선택 처리 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('선택됨: $option'),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Colors.white.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // 자동으로 다음 턴으로 이동 또는 완료
    Future.delayed(const Duration(milliseconds: 800), () {
      if (turn < 2) {
        _goToNextTurn();
      } else {
        // 마지막 턴이면 홈으로 바로 이동
        _completeOnboarding();
      }
    });
  }
  
  void _goToNextTurn() {
    final currentTurn = ref.read(onboardingTurnProvider);
    if (currentTurn < 2) {
      ref.read(onboardingTurnProvider.notifier).state = currentTurn + 1;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _goToPreviousTurn() {
    final currentTurn = ref.read(onboardingTurnProvider);
    if (currentTurn > 1) {
      ref.read(onboardingTurnProvider.notifier).state = currentTurn - 1;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _completeOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).state = true;
    ref.read(currentScreenProvider.notifier).state = AppScreen.home;
    
    // 홈 화면으로 이동
    context.go('/home');
  }
  
  Map<String, dynamic> _getOnboardingContent(int turn) {
    final contents = {
      1: {
        'hanoa': '안녕하세요! 저는 Hanoa입니다. 🏠\n\nAI가 여러분을 위한 맞춤형 학습 경험을 제공해드립니다. 대화를 통해 개인 최적화된 서비스를 만나보세요! ✨',
        'options': [
          '네, 시작해보겠습니다!',
          'Hanoa에 대해 더 알고 싶어요',
          '나중에 시작할게요',
        ],
      },
      2: {
        'hanoa': '완벽합니다! 🎉\n\nHanoa는 다양한 학습 서비스를 제공합니다. AI와 대화하며 여러분에게 딱 맞는 개인화된 경험을 찾아보세요!\n\n지금 바로 시작하시겠어요?',
        'options': [
          '네, 지금 바로 시작할게요!',
          '설정을 더 확인하고 싶어요',
        ],
      },
    };
    
    return contents[turn] ?? contents[1]!;
  }
}