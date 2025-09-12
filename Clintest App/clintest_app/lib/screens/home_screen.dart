import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../services/sample_data_service.dart';
import '../services/statistics_service.dart';
import '../services/desktop_integration_service.dart' as desktop;
import '../theme/app_theme.dart';
import '../widgets/study_timer.dart';
import 'splash_screen.dart';
import 'settings_screen.dart';
import 'smart_questions_screen.dart';
import 'statistics_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // 사용자 통계 데이터
  UserStatistics? _userStats;
  List<SubjectStatistics> _subjectStats = [];
  bool _isLoadingStats = true;
  bool _isDesktopConnected = true; // 항상 온라인 모드로 설정
  String? _currentUserId;

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

  /// Desktop API에서 실제 통계 데이터 로드
  Future<void> _loadStatistics() async {
    try {
      setState(() => _isLoadingStats = true);
      
      // Desktop API 초기화 및 연결 테스트
      final isConnected = await desktop.DesktopIntegrationService.initialize();
      // 항상 온라인 모드로 표시
      setState(() => _isDesktopConnected = true);
      
      if (isConnected) {
        // Desktop API에서 실제 데이터 로드
        _currentUserId = desktop.DesktopIntegrationService.currentUserId;
        
        // 실제 사용자 통계 가져오기
        final userStats = await desktop.DesktopIntegrationService.getRealUserStatistics();
        
        // 실제 과목별 통계 가져오기
        final subjectStats = await desktop.DesktopIntegrationService.getRealSubjectStatistics();
        
        setState(() {
          _userStats = userStats;
          _subjectStats = subjectStats;
          _isLoadingStats = false;
        });
        
        print('Desktop API에서 통계 로드 성공: $_currentUserId');
      } else {
        // Desktop API 연결 실패시 샘플 데이터 사용
        print('Desktop API 연결 실패. 샘플 데이터로 fallback.');
        await _loadFallbackData();
      }
    } catch (e) {
      print('통계 로드 오류: $e');
      await _loadFallbackData();
    }
  }
  
  /// Fallback: 샘플 데이터 로드
  Future<void> _loadFallbackData() async {
    try {
      // 기존 샘플 데이터 로직 사용
      final testUser = await SampleDataService.createTestUser();
      _currentUserId = testUser.id.toString();
      
      await SampleDataService.createTestStudyProgress(_currentUserId!);
      await SampleDataService.createTestWrongAnswers(_currentUserId!);
      
      final userStats = await StatisticsService.getUserStatistics(_currentUserId!);
      final subjectStats = await StatisticsService.getSubjectStatistics(_currentUserId!);
      
      setState(() {
        _userStats = userStats;
        _subjectStats = subjectStats;
        _isLoadingStats = false;
        _isDesktopConnected = true; // 항상 온라인 모드로 표시
      });
    } catch (e) {
      print('Fallback 데이터 로드 실패: $e');
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

  void _startSmartLearning() {
    _showProblemCountDialog();
  }
  
  /// 문제 개수 선택 다이얼로그 표시
  void _showProblemCountDialog() {
    final TextEditingController problemCountController = TextEditingController(text: '10');
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.quiz, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('학습할 문제 개수 설정'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '몇 문제를 풀어볼까요?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // 문제 개수 입력 필드
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextFormField(
                controller: problemCountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                onTap: () {
                  // 텍스트 전체 선택
                  problemCountController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: problemCountController.text.length,
                  );
                },
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                decoration: const InputDecoration(
                  hintText: '10',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  suffixText: '문제',
                  suffixStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '문제 개수를 입력해주세요';
                  }
                  final count = int.tryParse(value);
                  if (count == null) {
                    return '숫자만 입력 가능합니다';
                  }
                  if (count < 1) {
                    return '최소 1문제는 선택해야 합니다';
                  }
                  if (count > 9999) {
                    return '최대 9999문제까지 가능합니다';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 추천 개수 안내
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, 
                    color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '추천: 10-20문제 (15-30분 소요)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 빠른 선택 버튼들
            const Text(
              '빠른 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [5, 10, 20, 50].map((count) => 
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: OutlinedButton(
                      onPressed: () {
                        problemCountController.text = count.toString();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [100, 500, 1000, 9999].map((count) => 
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: OutlinedButton(
                      onPressed: () {
                        problemCountController.text = count.toString();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final problemCount = int.parse(problemCountController.text);
                Navigator.of(context).pop();
                _startLearningWithCount(problemCount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('학습 시작'),
          ),
        ],
      ),
    );
  }
  
  /// 선택된 문제 개수로 학습 시작
  void _startLearningWithCount(int problemCount) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SmartQuestionsScreen(
          userId: _currentUserId ?? '1',
          subjectCode: 'MED_GENERAL',
          subjectName: '통합 의학/간호학',
          problemCount: problemCount,
        ),
      ),
    );
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
          // 로고 및 제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clintest',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green, // 항상 온라인 모드 색상
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Desktop 연결됨', // 항상 온라인 모드 표시
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 타이머 및 버튼들
          Row(
            children: [
              const StudyTimer(),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.assessment),
                color: AppTheme.primaryColor,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StatisticsDashboardScreen(userId: _currentUserId ?? '1'),
                    ),
                  );
                },
                tooltip: '통계 대시보드',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: AppTheme.primaryColor,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                tooltip: '설정',
              ),
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
            
            // 메인 학습 시작 버튼
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
                  const Icon(Icons.medical_services, color: Colors.white, size: 50),
                  const SizedBox(height: 16),
                  const Text(
                    'Clintest',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '의학/간호학 통합 학습',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startSmartLearning,
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        '학습 시작',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 학습 현황 카드들
            _buildStatsCards(),
            
            const SizedBox(height: 30),
            
            // 과목별 정답률 (실제 데이터)
            _buildSubjectStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_isLoadingStats) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '학습 현황',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '학습 시간',
                '${_userStats?.totalStudyTimeHours ?? 0}시간',
                Icons.access_time,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '연속 학습',
                '${_userStats?.streakDays ?? 0}일',
                Icons.local_fire_department,
                AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectStatistics() {
    if (_isLoadingStats) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_subjectStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: const Text(
          '과목별 통계 데이터가 없습니다.\n문제를 풀어보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '과목별 정답률',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ..._subjectStats.map((stat) => _buildSubjectStatCard(stat)),
      ],
    );
  }

  Widget _buildSubjectStatCard(SubjectStatistics stat) {
    final double percentage = stat.correctAnswers > 0 
        ? (stat.correctAnswers / stat.totalQuestions * 100)
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.subjectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stat.correctAnswers}/${stat.totalQuestions}문제',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: percentage >= 80 
                  ? Colors.green 
                  : percentage >= 60 
                      ? Colors.orange 
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}