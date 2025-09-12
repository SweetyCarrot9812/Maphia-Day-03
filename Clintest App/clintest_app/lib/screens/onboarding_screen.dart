import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../models/country.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  
  // Selected values for new onboarding steps
  CountryCode? _selectedCountry;
  LabelLocale? _selectedLocale;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      icon: Icons.waving_hand,
      title: '환영합니다!',
      description: 'Clintest에 오신 것을 환영합니다.\n의료 전문가들을 위한 AI 학습 플랫폼입니다.',
      color: AppTheme.primaryColor,
    ),
    const OnboardingPage(
      icon: Icons.medical_services,
      title: 'Clintest란?',
      description: 'AI 기반 의료 학습 시스템으로\n임상시험 관리와 의료 지식 학습을\n효과적으로 지원합니다.',
      color: AppTheme.secondaryColor,
    ),
    const OnboardingPage(
      icon: Icons.rocket_launch,
      title: '시작해볼까요?',
      description: '지금 바로 Clintest의\n다양한 기능들을 체험해보세요!',
      color: AppTheme.accentColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await StorageService.setFirstLaunchComplete();
    await StorageService.setClintestOnboardingCompleted();
    
    // 기본 설정 저장 (한국, 한국어)
    await StorageService.saveClintestSettings(
      countryOfPractice: 'KR',
      labelLocale: 'ko',
    );
    
    // 로그인 기능 비활성화 - 바로 메인 홈 화면으로 이동
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  void _restartDemo() async {
    // 데모 재시작을 위해 설정 초기화
    await StorageService.clear();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip 및 데모 재시작 버튼
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 데모 재시작 버튼
                  IconButton(
                    onPressed: _restartDemo,
                    icon: const Icon(
                      Icons.refresh,
                      color: AppTheme.primaryColor,
                    ),
                    tooltip: '데모 재시작',
                  ),
                ],
              ),
            ),
            
            // 페이지뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),
            
            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // 다음/시작 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentIndex == _pages.length - 1 ? '시작하기' : '다음',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.primaryColor.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
            ),
            child: const Icon(
              Icons.public,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // 제목
          Text(
            '어느 국가에서 의료 활동을 하시나요?',
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // 설명
          Text(
            '국가별 의료 기준과 용어에 맞는\n맞춤형 학습 콘텐츠를 제공해드립니다.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // 국가 선택 목록
          Expanded(
            child: ListView.builder(
              itemCount: CountryCode.values.length,
              itemBuilder: (context, index) {
                final country = CountryCode.values[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.code),
                    selected: _selectedCountry == country,
                    selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedCountry == country 
                          ? AppTheme.primaryColor 
                          : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCountry = country;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.secondaryColor.withOpacity(0.2), AppTheme.secondaryColor.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3), width: 2),
            ),
            child: const Icon(
              Icons.translate,
              size: 60,
              color: AppTheme.secondaryColor,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // 제목
          Text(
            '의료 용어 언어를 선택해주세요',
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // 설명
          Text(
            '선택하신 언어로 의료 용어와 표준을\n표시해드립니다.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // 언어 선택 목록
          Expanded(
            child: ListView.builder(
              itemCount: LabelLocale.values.length,
              itemBuilder: (context, index) {
                final locale = LabelLocale.values[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(locale.displayName),
                    subtitle: Text(
                      locale.description,
                      style: AppTextStyles.caption,
                    ),
                    selected: _selectedLocale == locale,
                    selectedTileColor: AppTheme.secondaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedLocale == locale 
                          ? AppTheme.secondaryColor 
                          : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLocale = locale;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              icon,
              size: 60,
              color: color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // 제목
          Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // 설명
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}