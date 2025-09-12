import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/personalized_vocal_coach.dart';
import '../services/session_replay_service.dart';
import '../models/pitch_data.dart';
import '../models/audio_reference.dart';
import '../models/vocal_types.dart';
import 'enhanced_pitch_visualizer.dart';

/// 종합 보컬 코치 대시보드
/// 실시간 분석, 개인화 가이드, 진도 추적을 통합한 메인 UI
class VocalCoachDashboard extends StatefulWidget {
  final PersonalizedVocalCoach vocalCoach;
  final SessionReplayService replayService;
  final String userId;
  
  const VocalCoachDashboard({
    super.key,
    required this.vocalCoach,
    required this.replayService,
    required this.userId,
  });

  @override
  State<VocalCoachDashboard> createState() => _VocalCoachDashboardState();
}

class _VocalCoachDashboardState extends State<VocalCoachDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  // 실시간 데이터
  StreamSubscription<RealTimeCoachingGuide>? _guidanceSubscription;
  StreamSubscription<ReplayState>? _replaySubscription;
  
  RealTimeCoachingGuide? _currentGuidance;
  ReplayState? _currentReplayState;
  ComprehensiveVocalAnalysis? _lastAnalysis;
  PersonalizedLearningPlan? _learningPlan;
  Map<String, dynamic>? _progressData;
  
  // UI 상태
  bool _isRecording = false;
  bool _isAnalyzing = false;
  int _selectedReplayIndex = -1;
  
  // 샘플 데이터 (실제로는 마이크나 오디오 서비스에서 받아옴)
  List<double> _currentPitchData = [];
  double _currentFrequency = 0.0;
  double _targetFrequency = 440.0;
  String _currentNote = '';
  double _cents = 0.0;
  double _confidence = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // 실시간 가이드 구독
    _guidanceSubscription = widget.vocalCoach.realtimeGuidanceStream.listen(
      (guidance) {
        if (mounted) {
          setState(() {
            _currentGuidance = guidance;
          });
          
          // 중요한 가이드일 때 시각적 효과
          if (guidance.priority == CoachingPriority.critical ||
              guidance.priority == CoachingPriority.high) {
            _glowController.reset();
            _glowController.forward();
          }
        }
      },
    );
    
    // 리플레이 상태 구독
    _replaySubscription = widget.replayService.replayStateStream.listen(
      (replayState) {
        if (mounted) {
          setState(() {
            _currentReplayState = replayState;
          });
        }
      },
    );
    
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    _guidanceSubscription?.cancel();
    _replaySubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _loadInitialData() async {
    try {
      // 학습 계획 로드
      final plan = await widget.vocalCoach.generatePersonalizedPlan(widget.userId);
      
      // 진도 데이터 로드
      final progress = await widget.replayService.getUserProgress(widget.userId);
      
      if (mounted) {
        setState(() {
          _learningPlan = plan;
          _progressData = progress;
        });
      }
    } catch (e) {
      print('초기 데이터 로드 오류: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단 상태 바
          _buildStatusBar(),
          
          // 실시간 가이드 (중요한 경우만 표시)
          if (_currentGuidance != null && 
              (_currentGuidance!.priority == CoachingPriority.critical ||
               _currentGuidance!.priority == CoachingPriority.high))
            _buildRealtimeGuidance(),
          
          // 탭 바
          _buildTabBar(),
          
          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRealtimePracticeTab(),
                _buildAnalysisTab(),
                _buildProgressTab(),
                _buildReplayTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // 사용자 정보
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_learningPlan != null)
                    Text(
                      '${_getVoiceTypeDisplayName(_learningPlan!.voiceType)} · 레벨 ${_getCurrentLevel()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            
            // 상태 표시
            Row(
              children: [
                if (_isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'REC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isAnalyzing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '분석중',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRealtimeGuidance() {
    if (_currentGuidance == null) return const SizedBox.shrink();
    
    final guidance = _currentGuidance!;
    Color backgroundColor;
    IconData icon;
    
    switch (guidance.priority) {
      case CoachingPriority.critical:
        backgroundColor = Colors.red;
        icon = Icons.warning;
        break;
      case CoachingPriority.high:
        backgroundColor = Colors.orange;
        icon = Icons.info;
        break;
      case CoachingPriority.medium:
        backgroundColor = Colors.blue;
        icon = Icons.tips_and_updates;
        break;
      case CoachingPriority.low:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
    }
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3 + 0.4 * _glowAnimation.value),
                blurRadius: 8 + 8 * _glowAnimation.value,
                spreadRadius: 2 + 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guidance.primaryFocus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guidance.visualGuidance,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(guidance.confidence * 100).round()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      color: Colors.grey[50],
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(icon: Icon(Icons.mic), text: '실시간 연습'),
          Tab(icon: Icon(Icons.analytics), text: '분석'),
          Tab(icon: Icon(Icons.trending_up), text: '진도'),
          Tab(icon: Icon(Icons.play_circle), text: '리플레이'),
        ],
      ),
    );
  }
  
  Widget _buildRealtimePracticeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 메인 피치 시각화
          EnhancedPitchVisualizer(
            currentFrequency: _currentFrequency,
            targetFrequency: _targetFrequency,
            currentNote: _currentNote,
            cents: _cents,
            confidence: _confidence,
            frequencyHistory: _currentPitchData,
            isRecording: _isRecording,
          ),
          
          const SizedBox(height: 24),
          
          // 현재 연습 정보
          _buildCurrentPracticeInfo(),
          
          const SizedBox(height: 24),
          
          // 즉시 피드백 액션
          if (_currentGuidance != null)
            _buildImmediateActions(),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '종합 분석 결과',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (_lastAnalysis != null)
            _buildComprehensiveAnalysis(_lastAnalysis!)
          else
            _buildNoAnalysisMessage(),
          
          const SizedBox(height: 24),
          
          // 분석 요청 버튼
          if (!_isAnalyzing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _requestAnalysis,
                icon: const Icon(Icons.analytics),
                label: const Text('새로운 분석 요청'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 진도',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // 진도 요약
          if (_progressData != null) ...[
            _buildProgressSummary(_progressData!),
            const SizedBox(height: 24),
          ],
          
          // 학습 계획
          if (_learningPlan != null) ...[
            const Text(
              '맞춤 학습 계획',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildLearningPlan(_learningPlan!),
          ],
        ],
      ),
    );
  }
  
  Widget _buildReplayTab() {
    return Column(
      children: [
        // 리플레이 컨트롤
        if (_currentReplayState != null)
          _buildReplayControls(_currentReplayState!),
        
        // 리플레이 목록
        Expanded(
          child: _buildReplayList(),
        ),
      ],
    );
  }
  
  Widget _buildCurrentPracticeInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '현재 연습',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '목표 음표',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'A4 (440 Hz)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '연습 시간',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '02:34',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 진행률 바
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '오늘의 연습 목표',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const Text(
                      '65%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImmediateActions() {
    final guidance = _currentGuidance!;
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  '즉시 개선 액션',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...guidance.immediateActions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildComprehensiveAnalysis(ComprehensiveVocalAnalysis analysis) {
    return Column(
      children: [
        // 전체 점수
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '전체 점수',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(analysis.overallScore * 100).round()}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '점 / 100점',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 차원별 점수
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '세부 분석',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                
                ...analysis.dimensionScores.entries.map((entry) {
                  final displayName = _getDimensionDisplayName(entry.key);
                  final score = entry.value;
                  final percentage = (score * 100).round();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(displayName, style: const TextStyle(fontSize: 14)),
                            Text('$percentage%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: score,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(score),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoAnalysisMessage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '아직 분석 결과가 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '연습을 시작하고 분석을 요청해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSummary(Map<String, dynamic> progress) {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            '완료한 세션',
            '${progress['sessions_completed'] ?? 0}',
            '회',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            '연습 시간',
            '${((progress['total_practice_time'] ?? 0) / 60).round()}',
            '분',
            Icons.access_time,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            '연속 일수',
            '${progress['streak_days'] ?? 0}',
            '일',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLearningPlan(PersonalizedLearningPlan plan) {
    return Column(
      children: [
        // 강점과 약점
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '강점과 개선점',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                
                if (plan.strengths.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.star, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        '강점:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(plan.strengths.join(', ')),
                  ),
                  const SizedBox(height: 12),
                ],
                
                if (plan.weaknesses.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.trending_up, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        '개선점:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(plan.weaknesses.join(', ')),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 다음 세션들
        const Text(
          '다음 추천 세션',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        
        ...plan.nextSessions.take(3).map((session) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getDifficultyColor(session.difficulty),
              child: Text(
                _getDifficultyShort(session.difficulty),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(session.title),
            subtitle: Text(
              '${session.estimatedMinutes}분 · ${session.focusAreas.join(', ')}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _startTrainingSession(session),
          ),
        )).toList(),
      ],
    );
  }
  
  Widget _buildReplayControls(ReplayState replayState) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 진행률 슬라이더
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 4,
              ),
              child: Slider(
                value: replayState.progressRatio.clamp(0.0, 1.0),
                onChanged: (value) {
                  final position = (value * replayState.totalDuration).round();
                  widget.replayService.seekReplay(position);
                },
              ),
            ),
            
            // 시간 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  replayState.formattedCurrentTime,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  replayState.formattedTotalTime,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 컨트롤 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => widget.replayService.seekReplay(0),
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: widget.replayService.toggleReplay,
                  icon: Icon(
                    replayState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                IconButton(
                  onPressed: widget.replayService.stopReplay,
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReplayList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.replayService.getUserReplays(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('오류: ${snapshot.error}'),
          );
        }
        
        final replays = snapshot.data ?? [];
        
        if (replays.isEmpty) {
          return const Center(
            child: Text('저장된 리플레이가 없습니다'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: replays.length,
          itemBuilder: (context, index) {
            final replay = replays[index];
            final recordedAt = DateTime.parse(replay['recorded_at'] as String);
            final durationMs = replay['duration_ms'] as int;
            final metadata = replay['metadata'] as Map<String, dynamic>;
            
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  '연습 세션 ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${recordedAt.month}/${recordedAt.day} ${recordedAt.hour}:${recordedAt.minute.toString().padLeft(2, '0')}',
                    ),
                    Text(
                      '${(durationMs / 60000).round()}분',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _playReplay(replay['id'] as int),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showReplayOptions(context, replay),
                    ),
                  ],
                ),
                selected: _selectedReplayIndex == index,
                onTap: () {
                  setState(() {
                    _selectedReplayIndex = index;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 녹음 버튼
        FloatingActionButton(
          heroTag: "record",
          onPressed: _toggleRecording,
          backgroundColor: _isRecording ? Colors.red : Theme.of(context).primaryColor,
          child: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  
  // Helper methods
  
  String _getVoiceTypeDisplayName(VoiceType voiceType) {
    switch (voiceType) {
      case VoiceType.soprano:
        return '소프라노';
      case VoiceType.alto:
        return '알토';
      case VoiceType.tenor:
        return '테너';
      case VoiceType.bass:
        return '베이스';
      default:
        return '분석 중';
    }
  }
  
  String _getCurrentLevel() {
    if (_learningPlan?.skillProgression.isNotEmpty == true) {
      final avgScore = _learningPlan!.skillProgression.values
          .reduce((a, b) => a + b) / _learningPlan!.skillProgression.length;
      
      if (avgScore >= 0.8) return '상급';
      if (avgScore >= 0.6) return '중급';
      if (avgScore >= 0.3) return '초급';
      return '입문';
    }
    return '입문';
  }
  
  String _getDimensionDisplayName(String dimension) {
    switch (dimension) {
      case 'pitch_accuracy':
        return '피치 정확도';
      case 'stability':
        return '발성 안정성';
      case 'vibrato_quality':
        return '비브라토 품질';
      case 'timing_alignment':
        return '타이밍 정렬';
      case 'tone_quality':
        return '음색 품질';
      case 'voice_range':
        return '음성 범위';
      default:
        return dimension;
    }
  }
  
  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.lightGreen;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }
  
  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }
  
  String _getDifficultyShort(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return '초급';
      case DifficultyLevel.intermediate:
        return '중급';
      case DifficultyLevel.advanced:
        return '상급';
      case DifficultyLevel.expert:
        return '전문';
    }
  }
  
  // Action methods
  
  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      // 녹음 시작 로직
      _startRecording();
    } else {
      // 녹음 중지 로직
      _stopRecording();
    }
  }
  
  void _startRecording() {
    // TODO: 실제 오디오 녹음 시작
    print('녹음 시작');
    
    // 샘플 데이터 생성 시뮬레이션
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // 실시간 피치 데이터 시뮬레이션
      setState(() {
        _currentFrequency = 440 + math.sin(DateTime.now().millisecondsSinceEpoch / 100) * 10;
        _targetFrequency = 440;
        _currentNote = 'A4';
        _cents = (_currentFrequency - _targetFrequency) / _targetFrequency * 1200;
        _confidence = 0.7 + math.Random().nextDouble() * 0.3;
        
        _currentPitchData.add(_currentFrequency);
        if (_currentPitchData.length > 100) {
          _currentPitchData.removeAt(0);
        }
      });
      
      // 실시간 가이드 생성
      widget.vocalCoach.generateRealtimeGuidance(
        _currentPitchData,
        AudioReference(
          id: 1,
          title: 'A4 연습',
          key: 'C',
          scaleType: 'major',
          octaves: 1,
          filePath: '',
          createdAt: DateTime.now(),
        ),
      );
    });
  }
  
  void _stopRecording() {
    print('녹음 중지');
    // TODO: 녹음 데이터 저장 및 분석
  }
  
  Future<void> _requestAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });
    
    try {
      // 샘플 데이터로 분석 수행
      final pitchData = PitchData(
        id: 1,
        audioReferenceId: 1,
        sampleRate: 44100,
        pitchCurve: _currentPitchData,
        noteSegments: [], // TODO: 실제 노트 세그먼트 생성
        timestamps: [],
        createdAt: DateTime.now(),
      );
      
      final audioReference = AudioReference(
        id: 1,
        title: 'A4 연습',
        key: 'C',
        scaleType: 'major',
        octaves: 1,
        filePath: '',
        createdAt: DateTime.now(),
      );
      
      final analysis = await widget.vocalCoach.performComprehensiveAnalysis(
        pitchData,
        audioReference,
        List.generate(1000, (i) => math.sin(i * 0.01) * 100 + 200), // 샘플 오디오
      );
      
      setState(() {
        _lastAnalysis = analysis;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 중 오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
  
  void _startTrainingSession(TrainingSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.description),
            const SizedBox(height: 12),
            Text(
              '예상 시간: ${session.estimatedMinutes}분',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '집중 영역: ${session.focusAreas.join(', ')}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 트레이닝 세션 시작
            },
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _playReplay(int replayId) async {
    try {
      final replay = await widget.replayService.loadReplay(replayId);
      if (replay != null) {
        await widget.replayService.startReplay(replay);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('리플레이 재생 오류: $e')),
      );
    }
  }
  
  void _showReplayOptions(BuildContext context, Map<String, dynamic> replay) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('재생'),
            onTap: () {
              Navigator.of(context).pop();
              _playReplay(replay['id'] as int);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('상세 정보'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: 상세 정보 표시
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('삭제'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: 삭제 확인 및 처리
            },
          ),
        ],
      ),
    );
  }
}