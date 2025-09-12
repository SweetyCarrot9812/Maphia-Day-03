import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_analysis_models.dart';
import '../services/advanced_coach_service.dart';
import '../widgets/performance_chart.dart';
import '../widgets/coaching_chat_widget.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/injury_risk_indicator.dart';

/// AI 코치 메인 화면
/// 성과 분석, 개인화 추천, 실시간 코칭, 부상 위험도 등을 통합 표시
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 데이터 상태
  List<PersonalizedRecommendation>? _recommendations;
  InjuryRiskAssessment? _riskAssessment;
  CoachingSession? _activeSession;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCoachingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCoachingData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final coachService = context.read<AdvancedCoachService>();
      
      // 병렬로 데이터 로드
      final results = await Future.wait([
        coachService.generatePersonalizedRecommendations(userId: 'current_user'),
        coachService.assessInjuryRisk(userId: 'current_user'),
      ]);

      setState(() {
        _recommendations = results[0] as List<PersonalizedRecommendation>;
        _riskAssessment = results[1] as InjuryRiskAssessment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 코치'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: '분석'),
            Tab(icon: Icon(Icons.recommend), text: '추천'),
            Tab(icon: Icon(Icons.chat), text: '코칭'),
            Tab(icon: Icon(Icons.health_and_safety), text: '안전'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCoachingData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('오류: $_error'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAnalysisTab(),
                    _buildRecommendationsTab(),
                    _buildCoachingTab(),
                    _buildSafetyTab(),
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
          // 성과 요약 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '이번 달 성과',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('운동일수', '16일', Icons.calendar_today),
                      _buildStatItem('평균 RPE', '7.8', Icons.fitness_center),
                      _buildStatItem('1RM 향상', '+5.2%', Icons.trending_up),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 성과 차트
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '최근 4주 진행상황',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PerformanceChart(
                      data: _generateSampleChartData(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 최근 인사이트
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '최근 인사이트',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    '스쿼트 폼 개선',
                    '지난 2주간 RPE가 안정화되었습니다. 좋은 진전입니다!',
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildInsightItem(
                    '벤치프레스 정체기',
                    '3주간 중량 변화가 없습니다. 새로운 자극이 필요해 보입니다.',
                    Colors.orange,
                    Icons.warning,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    if (_recommendations == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recommendations!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('현재 모든 것이 완벽합니다!'),
            Text('계속해서 좋은 운동 패턴을 유지하세요.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recommendations!.length,
      itemBuilder: (context, index) {
        final recommendation = _recommendations![index];
        return RecommendationCard(
          recommendation: recommendation,
          onImplement: (rec) => _implementRecommendation(rec),
        );
      },
    );
  }

  Widget _buildCoachingTab() {
    return Column(
      children: [
        // 코칭 세션 상태
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              Icon(
                _activeSession != null ? Icons.chat : Icons.chat_bubble_outline,
                color: _activeSession != null ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _activeSession != null
                      ? '코칭 세션 진행 중'
                      : '새로운 코칭 세션 시작하기',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (_activeSession == null)
                ElevatedButton(
                  onPressed: _startCoachingSession,
                  child: const Text('시작'),
                ),
            ],
          ),
        ),
        
        // 채팅 인터페이스
        Expanded(
          child: _activeSession != null
              ? CoachingChatWidget(
                  session: _activeSession!,
                  onSendMessage: _handleCoachingMessage,
                  onEndSession: _endCoachingSession,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI 코치와 대화해보세요',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '운동 계획, 폼 교정, 영양 조언 등\n궁금한 것을 물어보세요!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildQuickStartButton('오늘 운동 계획', CoachingType.planning_session),
                          _buildQuickStartButton('운동 후 리뷰', CoachingType.post_workout_review),
                          _buildQuickStartButton('동기부여', CoachingType.motivation_boost),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSafetyTab() {
    if (_riskAssessment == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 위험도
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InjuryRiskIndicator(
                    riskScore: _riskAssessment!.overallRiskScore,
                    size: 60,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '전체 부상 위험도',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _getRiskLevelText(_riskAssessment!.overallRiskScore),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getRiskColor(_riskAssessment!.overallRiskScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 신체 부위별 위험도
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '신체 부위별 위험도',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ..._riskAssessment!.bodyPartRisks.entries.map(
                    (entry) => _buildBodyPartRisk(entry.key, entry.value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 위험 요소들
          if (_riskAssessment!.riskFactors.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주의할 위험 요소',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...(_riskAssessment!.riskFactors.take(3).map(
                      (factor) => _buildRiskFactor(factor),
                    )),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 예방 권장사항
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예방 권장사항',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...(_riskAssessment!.preventions.take(3).map(
                    (prevention) => _buildPreventionItem(prevention),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInsightItem(String title, String description, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartButton(String text, CoachingType type) {
    return ElevatedButton(
      onPressed: () => _startCoachingSession(type),
      child: Text(text),
    );
  }

  Widget _buildBodyPartRisk(String bodyPart, double risk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(bodyPart),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: risk / 100,
              backgroundColor: Colors.grey[300],
              color: _getRiskColor(risk),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${risk.toInt()}%',
            style: TextStyle(
              color: _getRiskColor(risk),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactor(RiskFactor factor) {
    return ListTile(
      leading: Icon(
        Icons.warning,
        color: _getRiskColor(factor.score * 10),
      ),
      title: Text(factor.factor),
      subtitle: Text(factor.description),
      trailing: Text(
        '${(factor.score * 10).toInt()}%',
        style: TextStyle(
          color: _getRiskColor(factor.score * 10),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPreventionItem(PreventionRecommendation prevention) {
    return ListTile(
      leading: Icon(
        Icons.shield,
        color: Colors.green[600],
      ),
      title: Text(prevention.title),
      subtitle: Text(prevention.description),
      trailing: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.blue,
        child: Text(
          '${prevention.priorityLevel}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Color _getRiskColor(double risk) {
    if (risk < 20) return Colors.green;
    if (risk < 40) return Colors.yellow[700]!;
    if (risk < 70) return Colors.orange;
    return Colors.red;
  }

  String _getRiskLevelText(double risk) {
    if (risk < 20) return '낮음';
    if (risk < 40) return '보통';
    if (risk < 70) return '주의';
    return '위험';
  }

  List<Map<String, dynamic>> _generateSampleChartData() {
    return [
      {'week': '1주', 'progress': 85},
      {'week': '2주', 'progress': 88},
      {'week': '3주', 'progress': 90},
      {'week': '4주', 'progress': 92},
    ];
  }

  Future<void> _implementRecommendation(PersonalizedRecommendation recommendation) async {
    // 추천사항 구현 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recommendation.title} 적용 중...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _startCoachingSession([CoachingType? type]) async {
    try {
      final coachService = context.read<AdvancedCoachService>();
      final session = await coachService.startCoachingSession(
        userId: 'current_user',
        type: type ?? CoachingType.planning_session,
      );
      
      setState(() {
        _activeSession = session;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세션 시작 실패: $e')),
      );
    }
  }

  Future<void> _handleCoachingMessage(String message) async {
    if (_activeSession == null) return;

    try {
      final coachService = context.read<AdvancedCoachService>();
      await coachService.processCoachingMessage(
        sessionId: _activeSession!.id,
        userMessage: message,
      );
      
      // UI 업데이트는 CoachingChatWidget에서 처리
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 실패: $e')),
      );
    }
  }

  Future<void> _endCoachingSession(double satisfaction) async {
    if (_activeSession == null) return;

    try {
      final coachService = context.read<AdvancedCoachService>();
      await coachService.completeCoachingSession(
        sessionId: _activeSession!.id,
        satisfactionScore: satisfaction,
      );
      
      setState(() {
        _activeSession = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('코칭 세션이 완료되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세션 종료 실패: $e')),
      );
    }
  }
}