import 'package:flutter/material.dart';
import '../services/progress_tracking_service.dart';
import 'dart:math' as math;

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  
  final ProgressTrackingService _progressService = ProgressTrackingService();
  
  ProgressStats? _overallStats;
  List<ProgressSession> _recentSessions = [];
  List<DailyProgress> _weeklyProgress = [];
  bool _isLoading = true;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      // 병렬로 데이터 로드
      final futures = await Future.wait([
        _progressService.getProgressStats(),
        _progressService.getRecentSessions(limit: 5),
        _progressService.getDailyProgress(startDate: weekAgo, endDate: now),
      ]);
      
      setState(() {
        _overallStats = futures[0] as ProgressStats;
        _recentSessions = futures[1] as List<ProgressSession>;
        _weeklyProgress = futures[2] as List<DailyProgress>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('진행 상황을 불러오는 중 오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연습 진행 상황'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: '통계'),
            Tab(icon: Icon(Icons.history), text: '최근 연습'),
            Tab(icon: Icon(Icons.trending_up), text: '주간 진행'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(),
                _buildRecentSessionsTab(),
                _buildWeeklyProgressTab(),
              ],
            ),
    );
  }

  Widget _buildStatsTab() {
    if (_overallStats == null) {
      return _buildEmptyState('아직 연습 데이터가 없습니다', '연습을 시작해보세요!');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주요 통계 카드들
          _buildStatsGrid(),
          
          const SizedBox(height: 24),
          
          // 상세 통계
          _buildDetailedStats(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          '총 연습 시간',
          _overallStats!.formattedTotalTime,
          Icons.timer,
          Colors.blue,
        ),
        _buildStatCard(
          '총 세션 수',
          '${_overallStats!.totalSessions}회',
          Icons.play_circle,
          Colors.green,
        ),
        _buildStatCard(
          '평균 세션 시간',
          _overallStats!.formattedAverageTime,
          Icons.av_timer,
          Colors.orange,
        ),
        _buildStatCard(
          '완료율',
          '${(_overallStats!.completionRate * 100).toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상세 통계',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildStatRow('완료한 음표 수', '${_overallStats!.totalNotesCompleted}개'),
            _buildStatRow('시도한 음표 수', '${_overallStats!.totalNotesAttempted}개'),
            
            const SizedBox(height: 16),
            
            // 완료율 진행 바
            Row(
              children: [
                const Text('전체 완료율'),
                const Spacer(),
                Text('${(_overallStats!.completionRate * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _overallStats!.completionRate,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _overallStats!.completionRate > 0.8 
                    ? Colors.green
                    : _overallStats!.completionRate > 0.6 
                        ? Colors.orange 
                        : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessionsTab() {
    if (_recentSessions.isEmpty) {
      return _buildEmptyState('최근 연습 기록이 없습니다', '첫 연습을 시작해보세요!');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentSessions.length,
      itemBuilder: (context, index) {
        final session = _recentSessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getSessionTypeColor(session.sessionType),
              child: Icon(
                _getSessionTypeIcon(session.sessionType),
                color: Colors.white,
              ),
            ),
            title: Text(
              _getSessionTypeTitle(session.sessionType),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.formattedDuration),
                if (session.targetNote != null)
                  Text('목표: ${session.targetNote}'),
                Text('완료율: ${(session.completionRate * 100).toStringAsFixed(1)}%'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${session.sessionDate.month}/${session.sessionDate.day}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (session.averageAccuracy > 0)
                  Text(
                    '${session.averageAccuracy.toStringAsFixed(1)}c',
                    style: TextStyle(
                      color: _getAccuracyColor(session.averageAccuracy),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgressTab() {
    if (_weeklyProgress.isEmpty) {
      return _buildEmptyState('주간 연습 데이터가 없습니다', '꾸준한 연습으로 진행 상황을 확인해보세요!');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 7일 연습 현황',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 주간 차트 (간단한 막대 그래프)
          _buildWeeklyChart(),
          
          const SizedBox(height: 24),
          
          // 일별 상세 정보
          ..._weeklyProgress.map((daily) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  daily.formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('${daily.sessionsCount}회 연습'),
              subtitle: Text('총 ${daily.formattedDuration}'),
              trailing: Text(
                '${daily.averageCompletionRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: daily.averageCompletionRate > 80 
                      ? Colors.green 
                      : daily.averageCompletionRate > 60 
                          ? Colors.orange 
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (_weeklyProgress.isEmpty) return const SizedBox.shrink();
    
    final maxDuration = _weeklyProgress.map((d) => d.totalDuration).reduce(math.max);
    if (maxDuration == 0) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '일별 연습 시간 (분)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _weeklyProgress.map((daily) {
                  final heightRatio = daily.totalDuration / maxDuration;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 160 * heightRatio,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            daily.formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            daily.formattedDuration,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSessionTypeColor(String sessionType) {
    switch (sessionType) {
      case 'tuner':
        return Colors.blue;
      case 'scale_practice':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSessionTypeIcon(String sessionType) {
    switch (sessionType) {
      case 'tuner':
        return Icons.tune;
      case 'scale_practice':
        return Icons.music_note;
      default:
        return Icons.play_circle;
    }
  }

  String _getSessionTypeTitle(String sessionType) {
    switch (sessionType) {
      case 'tuner':
        return '실시간 튜너';
      case 'scale_practice':
        return '스케일 연습';
      default:
        return '연습';
    }
  }

  Color _getAccuracyColor(double accuracy) {
    final absAccuracy = accuracy.abs();
    if (absAccuracy <= 15) return Colors.green;
    if (absAccuracy <= 30) return Colors.orange;
    return Colors.red;
  }
}