import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/statistics_service.dart';
import '../theme/app_theme.dart';

/// 상세 통계 대시보드 화면
class StatisticsDashboardScreen extends StatefulWidget {
  final String userId;
  
  const StatisticsDashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<StatisticsDashboardScreen> createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  UserStatistics? _userStats;
  List<SubjectStatistics> _subjectStats = [];
  List<DailyStudyData> _weeklyData = [];
  List<WeaknessAnalysis> _weaknesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      final userStats = await StatisticsService.getUserStatistics(widget.userId);
      final subjectStats = await StatisticsService.getSubjectStatistics(widget.userId);
      final weeklyData = await StatisticsService.getWeeklyStudyPattern(widget.userId);
      final weaknesses = await StatisticsService.getWeaknessAnalysis(widget.userId);
      
      setState(() {
        _userStats = userStats;
        _subjectStats = subjectStats;
        _weeklyData = weeklyData;
        _weaknesses = weaknesses;
        _isLoading = false;
      });
    } catch (e) {
      print('통계 로드 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '학습 통계',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: '종합',
            ),
            Tab(
              icon: Icon(Icons.school),
              text: '과목별',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: '진도',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSubjectsTab(),
                _buildProgressTab(),
              ],
            ),
    );
  }

  /// 종합 탭
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 통계 카드들
          Row(
            children: [
              Expanded(
                child: _buildOverviewStatCard(
                  '전체 정답률',
                  '${((_userStats?.overallAccuracy ?? 0.0) * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewStatCard(
                  '완료한 문제',
                  '${_userStats?.totalQuestions ?? 0}개',
                  Icons.quiz,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewStatCard(
                  '학습 시간',
                  '${_userStats?.totalStudyTimeHours ?? 0}시간',
                  Icons.access_time,
                  AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewStatCard(
                  '연속 학습',
                  '${_userStats?.streakDays ?? 0}일',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 주간 학습 패턴 섹션
          _buildSectionHeader('주간 학습 패턴', Icons.show_chart),
          const SizedBox(height: 12),
          _buildWeeklyChart(),
          
          const SizedBox(height: 24),
          
          // 약점 분석 섹션
          _buildSectionHeader('약점 분석', Icons.warning),
          const SizedBox(height: 12),
          _buildWeaknessAnalysis(),
          
          const SizedBox(height: 24),
          
          // 학습 요약 섹션
          _buildSectionHeader('학습 요약', Icons.summarize),
          const SizedBox(height: 12),
          _buildLearningSummary(),
        ],
      ),
    );
  }

  /// 과목별 탭
  Widget _buildSubjectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('과목별 성과', Icons.school),
          const SizedBox(height: 16),
          
          if (_subjectStats.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '아직 학습한 과목이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // 과목별 성과 분포 원형 차트
            _buildSubjectDistributionChart(),
            const SizedBox(height: 24),
            
            // 과목별 상세 카드들
            ...(_subjectStats.map((subject) => _buildSubjectCard(subject)).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectDistributionChart() {
    return Container(
      height: 300,
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
          const Text(
            '과목별 정답률 분포',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '각 과목의 성과를 한눈에 비교해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                // 원형 차트
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events if needed
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _buildPieChartSections(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 범례
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _subjectStats.map((subject) => _buildLegendItem(
                      subject.subjectName,
                      _getSubjectColor(_subjectStats.indexOf(subject)),
                      '${(subject.accuracyRate * 100).toInt()}%',
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return _subjectStats.asMap().entries.map((entry) {
      final index = entry.key;
      final subject = entry.value;
      
      return PieChartSectionData(
        color: _getSubjectColor(index),
        value: subject.accuracyRate * 100,
        title: '${(subject.accuracyRate * 100).toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }


  Widget _buildProgressLineChart() {
    return Container(
      height: 250,
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
          const Text(
            '정답률 변화 추세',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '지난 7일간 정답률 변화를 확인해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _weeklyData.isEmpty 
                ? const Center(
                    child: Text(
                      '학습 데이터가 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _buildAccuracyLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < _weeklyData.length) {
                  final data = _weeklyData[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${data.date.day}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.2,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: _weeklyData.length.toDouble() - 1,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: _weeklyData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.accuracyRate,
              );
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.accentColor.withOpacity(0.8),
                AppTheme.accentColor,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.accentColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withOpacity(0.1),
                  AppTheme.accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppTheme.accentColor.withOpacity(0.8),
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final data = _weeklyData[touchedSpot.x.toInt()];
                return LineTooltipItem(
                  '${data.date.month}/${data.date.day}\n정답률: ${(data.accuracyRate * 100).toInt()}%',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// 진도 탭  
  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('학습 진도 현황', Icons.trending_up),
          const SizedBox(height: 16),
          
          // 전체 진도 요약
          Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '전체 학습 진도',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_subjectStats.length}개 과목 학습 중',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 진도율 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProgressIndicator(
                      '평균 정답률',
                      (_userStats?.overallAccuracy ?? 0.0),
                      AppTheme.primaryColor,
                    ),
                    _buildProgressIndicator(
                      '목표 달성률',
                      _calculateGoalAchievement(),
                      AppTheme.accentColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 학습 추세 라인 차트
          _buildSectionHeader('학습 추세', Icons.show_chart),
          const SizedBox(height: 12),
          _buildProgressLineChart(),
          
          const SizedBox(height: 24),
          
          // 과목별 진도
          _buildSectionHeader('과목별 진도', Icons.list),
          const SizedBox(height: 12),
          
          ...(_subjectStats.map((subject) => _buildProgressCard(subject)).toList()),
        ],
      ),
    );
  }

  Widget _buildOverviewStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 280,
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
          const Text(
            '주간 학습 패턴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '최근 7일간 학습 시간 및 정답률',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _weeklyData.isEmpty 
                ? const Center(
                    child: Text(
                      '학습 데이터가 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _buildWeeklyBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    final maxMinutes = _weeklyData.isNotEmpty 
        ? _weeklyData.map((d) => d.studyMinutes).reduce((a, b) => a > b ? a : b) 
        : 100;
    final maxY = (maxMinutes / 10).ceil() * 10.0; // Round up to nearest 10

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppTheme.primaryColor.withOpacity(0.8),
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final data = _weeklyData[groupIndex];
              return BarTooltipItem(
                '${data.date.month}/${data.date.day}\n'
                '${data.studyMinutes}분\n'
                '정답률: ${(data.accuracyRate * 100).toInt()}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < _weeklyData.length) {
                  final data = _weeklyData[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${data.date.day}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 4,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.studyMinutes.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.primaryColor,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.grey[100],
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeaknessAnalysis() {
    if (_weaknesses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
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
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '훌륭합니다!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '현재 모든 과목에서 목표 수준을 달성하고 있습니다.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _weaknesses.take(3).map((weakness) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getPriorityColor(weakness.priority).withOpacity(0.3),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(weakness.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(weakness.priority),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    weakness.subjectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${(weakness.currentAccuracy * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(weakness.priority),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            ...weakness.improvementSuggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      )).toList(),
    );
  }

  /// 학습 요약 위젯
  Widget _buildLearningSummary() {
    final totalProblems = _userStats?.totalQuestions ?? 0;
    final streak = _userStats?.streakDays ?? 0;
    final accuracy = (_userStats?.overallAccuracy ?? 0.0) * 100;
    final studyTime = _userStats?.totalStudyTimeHours ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '오늘의 학습 현황',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 간단한 학습 상태 정보
          Row(
            children: [
              Expanded(
                child: _buildSimpleStat(
                  '문제 수',
                  '$totalProblems개',
                  Icons.quiz_outlined,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSimpleStat(
                  '정답률',
                  '${accuracy.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  accuracy >= 80 ? Colors.green : accuracy >= 60 ? Colors.orange : Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSimpleStat(
                  '연속 학습',
                  '$streak일',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSimpleStat(
                  '누적 시간',
                  '$studyTime시간',
                  Icons.access_time,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 학습 상태에 따른 간단한 메시지
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusMessage(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 간단한 통계 위젯
  Widget _buildSimpleStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 학습 상태 색상
  Color _getStatusColor() {
    final accuracy = (_userStats?.overallAccuracy ?? 0.0) * 100;
    final streak = _userStats?.streakDays ?? 0;
    
    if (accuracy >= 85 && streak >= 7) return Colors.green;
    if (accuracy >= 70 && streak >= 3) return Colors.blue;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  /// 학습 상태 아이콘
  IconData _getStatusIcon() {
    final accuracy = (_userStats?.overallAccuracy ?? 0.0) * 100;
    final streak = _userStats?.streakDays ?? 0;
    
    if (accuracy >= 85 && streak >= 7) return Icons.stars;
    if (accuracy >= 70 && streak >= 3) return Icons.trending_up;
    if (accuracy >= 60) return Icons.thumb_up;
    return Icons.psychology;
  }

  /// 학습 상태 메시지
  String _getStatusMessage() {
    final accuracy = (_userStats?.overallAccuracy ?? 0.0) * 100;
    final streak = _userStats?.streakDays ?? 0;
    final totalProblems = _userStats?.totalQuestions ?? 0;
    
    if (accuracy >= 85 && streak >= 7) {
      return '훌륭한 학습 습관을 유지하고 있습니다!';
    } else if (accuracy >= 70 && streak >= 3) {
      return '꾸준히 실력이 향상되고 있습니다.';
    } else if (accuracy >= 60) {
      return '좋은 시작입니다. 꾸준히 학습해보세요.';
    } else if (totalProblems < 10) {
      return '더 많은 문제를 풀어보며 실력을 쌓아보세요.';
    } else {
      return '복습을 통해 약점을 보완해보세요.';
    }
  }

  Widget _buildSubjectCard(SubjectStatistics subject) {
    final accuracyColor = _getAccuracyColor(subject.accuracyRate);
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accuracyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accuracyColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${(subject.accuracyRate * 100).toInt()}%',
                  style: TextStyle(
                    color: accuracyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildSubjectStatItem(
                Icons.quiz,
                '${subject.totalQuestions}개',
                '총 문제',
              ),
              const SizedBox(width: 20),
              _buildSubjectStatItem(
                Icons.access_time,
                '${subject.studyTimeHours.toStringAsFixed(1)}h',
                '학습시간',
              ),
              const SizedBox(width: 20),
              _buildSubjectStatItem(
                Icons.error_outline,
                '${subject.pendingReviewCount}개',
                '복습대기',
              ),
            ],
          ),
          
          if (subject.lastStudyDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '최근 학습: ${_formatDate(subject.lastStudyDate!)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(SubjectStatistics subject) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.subjectName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 정답률 프로그레스 바
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                '정답률',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '${(subject.accuracyRate * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: subject.accuracyRate,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getAccuracyColor(subject.accuracyRate)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 6,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getPriorityColor(double priority) {
    if (priority > 0.7) return Colors.red;
    if (priority > 0.4) return Colors.orange;
    return Colors.yellow[700]!;
  }

  String _getPriorityText(double priority) {
    if (priority > 0.7) return '긴급';
    if (priority > 0.4) return '중요';
    return '보통';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }

  double _calculateGoalAchievement() {
    if (_subjectStats.isEmpty) return 0.0;
    final targetAccuracy = 0.8; // 목표: 80%
    final achievedSubjects = _subjectStats.where((s) => s.accuracyRate >= targetAccuracy).length;
    return achievedSubjects / _subjectStats.length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return '오늘';
    if (difference == 1) return '어제';
    if (difference < 7) return '$difference일 전';
    return '${date.month}/${date.day}';
  }
}

