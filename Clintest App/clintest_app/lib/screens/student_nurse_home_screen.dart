import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../services/sample_data_service.dart';
import '../services/statistics_service.dart';
import '../theme/app_theme.dart';
import 'splash_screen.dart';
import 'settings_screen.dart';
import 'smart_questions_screen.dart';
import 'statistics_dashboard_screen.dart';

class StudentNurseHomeScreen extends StatefulWidget {
  const StudentNurseHomeScreen({super.key});

  @override
  State<StudentNurseHomeScreen> createState() => _StudentNurseHomeScreenState();
}

class _StudentNurseHomeScreenState extends State<StudentNurseHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final Set<String> _selectedSubjects = {};
  
  // 사용자 통계 데이터
  UserStatistics? _userStats;
  List<SubjectStatistics> _subjectStats = [];
  bool _isLoadingStats = true;
  String? _currentUserId;
  
  // 더미 데이터 - 과목별 정답률 (폴백용)
  final Map<String, double> _subjectScores = {
    '성인간호학': 85.5,
    '아동간호학': 78.2,
    '모성간호학': 92.1,
    '정신간호학': 76.8,
    '지역사회간호학': 88.3,
    '간호관리학': 82.7,
    '기본간호학': 91.4,
    '간호법규': 79.6,
  };

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
    _loadStatistics();
  }

  /// 통계 데이터 로드
  Future<void> _loadStatistics() async {
    try {
      setState(() => _isLoadingStats = true);
      
      // 테스트 사용자 생성 및 가져오기
      final testUser = await SampleDataService.createTestUser();
      _currentUserId = testUser.id.toString();
      
      // 테스트 데이터 확인/생성
      await SampleDataService.createTestStudyProgress(_currentUserId!);
      await SampleDataService.createTestWrongAnswers(_currentUserId!);
      
      // 통계 데이터 로드
      final userStats = await StatisticsService.getUserStatistics(_currentUserId!);
      final subjectStats = await StatisticsService.getSubjectStatistics(_currentUserId!);
      
      setState(() {
        _userStats = userStats;
        _subjectStats = subjectStats;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('통계 로드 오류: $e');
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _restartDemo() async {
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildDashboardTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 캐릭터 아바타
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.secondaryColor.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 사용자 정보
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요! 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '오늘도 열심히 공부해봅시다!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 설정 버튼
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: AppTheme.primaryColor,
            ),
            tooltip: '설정',
          ),
          
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
    );
  }

  Widget _buildDashboardTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // 문제풀기 메인 버튼
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
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
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 50),
                  const SizedBox(height: 16),
                  const Text(
                    'AI 스마트 학습',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '간호사 국가고시 대비 문제풀이',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // 스마트 학습 버튼들
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startSmartLearning,
                          icon: const Icon(Icons.psychology, size: 20),
                          label: const Text(
                            '스마트 학습',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startConceptLearning,
                          icon: const Icon(Icons.school, size: 20),
                          label: const Text(
                            '개념 학습',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: AppTheme.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: AppTheme.accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 전체 통계 카드들
            if (_isLoadingStats) ...[
              // 로딩 중일 때
              Row(
                children: [
                  Expanded(child: _buildLoadingStatCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLoadingStatCard()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildLoadingStatCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLoadingStatCard()),
                ],
              ),
            ] else ...[
              // 실제 데이터
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    '전체 정답률', 
                    '${((_userStats?.overallAccuracy ?? 0.0) * 100).toStringAsFixed(1)}%', 
                    Icons.trending_up, 
                    AppTheme.primaryColor,
                    onTap: _openDetailedStatistics,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    '완료한 문제', 
                    '${_userStats?.totalQuestions ?? 0}개', 
                    Icons.quiz, 
                    AppTheme.secondaryColor,
                    onTap: _openDetailedStatistics,
                  )),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                    '학습 시간', 
                    '${_userStats?.totalStudyTimeHours ?? 0}시간', 
                    Icons.access_time, 
                    AppTheme.accentColor,
                    onTap: _openDetailedStatistics,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    '연속 학습', 
                    '${_userStats?.streakDays ?? 0}일', 
                    Icons.local_fire_department, 
                    Colors.orange,
                    onTap: _openDetailedStatistics,
                  )),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // 과목별 성적
            const Text(
              '📊 과목별 정답률',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ..._subjectScores.entries.map((entry) => 
              _buildSubjectScoreCard(entry.key, entry.value)
            ),
          ],
        ),
      ),
    );
  }

  /// 스마트 학습 시작
  Future<void> _startSmartLearning() async {
    try {
      // 테스트 사용자 생성 또는 가져오기
      final currentUser = await SampleDataService.createTestUser();
      
      // 테스트 데이터 생성 (오답 노트, 학습 진도)
      await SampleDataService.createTestWrongAnswers(currentUser.id.toString());
      await SampleDataService.createTestStudyProgress(currentUser.id.toString());
      
      // 스마트 학습 화면으로 이동 (기본 모드)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SmartQuestionsScreen(
            userId: currentUser.id.toString(),
            subjectCode: 'NUR_FUNDAMENTAL', // 기본간호학으로 시작
            learningMode: 'smart', // 기본 스마트 모드
          ),
        ),
      );
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('스마트 학습 시작 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 개념 학습 시작 (개념 설명 위주 모드)
  Future<void> _startConceptLearning() async {
    try {
      // 테스트 사용자 생성 또는 가져오기
      final currentUser = await SampleDataService.createTestUser();
      
      // 테스트 데이터 생성 (오답 노트, 학습 진도)
      await SampleDataService.createTestWrongAnswers(currentUser.id.toString());
      await SampleDataService.createTestStudyProgress(currentUser.id.toString());
      
      // 스마트 학습 화면으로 이동 (개념 학습 모드)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SmartQuestionsScreen(
            userId: currentUser.id.toString(),
            subjectCode: 'NUR_FUNDAMENTAL', // 기본간호학으로 시작
            learningMode: 'concept', // 개념 학습 모드 - GPT-5가 개념 설명 비율을 높게 설정
          ),
        ),
      );
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('개념 학습 시작 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showQuizSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '📝 과목 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 과목별 선택 그리드
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _subjectScores.length,
                      itemBuilder: (context, index) {
                        final entry = _subjectScores.entries.elementAt(index);
                        final subject = entry.key;
                        final score = entry.value;
                        final isSelected = _selectedSubjects.contains(subject);
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSubjects.remove(subject);
                              } else {
                                _selectedSubjects.add(subject);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.book,
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subject,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${score.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.7) : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 선택된 과목으로 문제풀기 버튼
                    if (_selectedSubjects.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // 선택된 과목들로 문제 풀기 시작
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '선택한 과목 문제 풀기 (${_selectedSubjects.length}개)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    
                    // 랜덤 문제 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.accentColor, AppTheme.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.shuffle, color: Colors.white, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            '랜덤 문제 풀기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '모든 과목에서 랜덤으로 문제를 출제합니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // 랜덤 문제 시작
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text('시작하기'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 로딩 중 통계 카드
  Widget _buildLoadingStatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// 상세 통계 페이지 열기
  void _openDetailedStatistics() {
    if (_currentUserId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StatisticsDashboardScreen(
            userId: _currentUserId!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 정보를 불러오는 중입니다...'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildSubjectScoreCard(String subject, double score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: AppTheme.backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score >= 90 ? Colors.green :
                    score >= 80 ? Colors.orange :
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${score.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: score >= 90 ? Colors.green :
                     score >= 80 ? Colors.orange :
                     Colors.red,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSubjectCheckCard(String subject, double score) {
    bool isSelected = _selectedSubjects.contains(subject);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
        secondary: CircleAvatar(
          backgroundColor: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.book, 
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          subject,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          '정답률: ${score.toStringAsFixed(1)}%',
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.7) : AppTheme.textSecondary,
          ),
        ),
        value: isSelected,
        activeColor: AppTheme.primaryColor,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedSubjects.add(subject);
            } else {
              _selectedSubjects.remove(subject);
            }
          });
        },
      ),
    );
  }


}