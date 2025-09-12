import 'package:flutter/material.dart';
import '../services/coaching_service.dart';

/// 코칭 카드 위젯
/// 
/// 1분 요약 리포트와 개인화된 학습 목표를 표시하는 카드
class CoachingCardWidget extends StatelessWidget {
  final CoachingCard? coachingCard;
  final QuickSummaryReport? quickSummary;
  final VoidCallback? onStartPractice;
  final VoidCallback? onViewDetails;

  const CoachingCardWidget({
    Key? key,
    this.coachingCard,
    this.quickSummary,
    this.onStartPractice,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (quickSummary != null) {
      return _buildQuickSummaryCard(context);
    } else if (coachingCard != null) {
      return _buildFullCoachingCard(context);
    } else {
      return _buildEmptyCard(context);
    }
  }

  /// 1분 요약 카드
  Widget _buildQuickSummaryCard(BuildContext context) {
    final summary = quickSummary!;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryHeader(context, summary),
            const SizedBox(height: 16),
            _buildScoreSection(context, summary),
            const SizedBox(height: 16),
            _buildStrengthsWeaknesses(context, summary),
            const SizedBox(height: 16),
            _buildKeyInsight(context, summary),
            const SizedBox(height: 20),
            _buildActionButtons(context, isQuickSummary: true),
          ],
        ),
      ),
    );
  }

  /// 전체 코칭 카드
  Widget _buildFullCoachingCard(BuildContext context) {
    final card = coachingCard!;
    
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoachingHeader(context, card),
            const SizedBox(height: 20),
            _buildAnalysisOverview(context, card),
            const SizedBox(height: 20),
            _buildGoalsSection(context, card),
            const SizedBox(height: 20),
            _buildPracticeTimeEstimate(context, card),
            const SizedBox(height: 24),
            _buildActionButtons(context, isQuickSummary: false),
          ],
        ),
      ),
    );
  }

  /// 빈 카드
  Widget _buildEmptyCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 분석 데이터가 없습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 연습을 시작하여 개인화된 코칭을 받아보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onStartPractice,
              icon: const Icon(Icons.mic),
              label: const Text('연습 시작'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 요약 헤더
  Widget _buildSummaryHeader(BuildContext context, QuickSummaryReport summary) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getGradeColor(summary.overallGrade).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.assessment,
            color: _getGradeColor(summary.overallGrade),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1분 요약 리포트',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildGradeBadge(summary.overallGrade),
                  const SizedBox(width: 8),
                  Text(
                    '${summary.overallScore.toInt()}점',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${_formatDuration(summary.duration)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 코칭 헤더
  Widget _buildCoachingHeader(BuildContext context, CoachingCard card) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getPriorityColor(card.priority),
                _getPriorityColor(card.priority).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 코칭 카드',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildPriorityBadge(card.priority),
                  const SizedBox(width: 8),
                  Text(
                    '${card.goals.length}개 목표',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 점수 섹션
  Widget _buildScoreSection(BuildContext context, QuickSummaryReport summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildScoreItem(
              context,
              '종합 점수',
              summary.overallScore.toInt().toString(),
              _getGradeColor(summary.overallGrade),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildScoreItem(
              context,
              '예상 연습시간',
              '${summary.practiceTime}분',
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 강점/약점 섹션
  Widget _buildStrengthsWeaknesses(BuildContext context, QuickSummaryReport summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.strengths.isNotEmpty) ...[
          _buildSectionTitle(context, '강점', Icons.thumb_up, Colors.green),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: summary.strengths.map((strength) =>
              _buildTag(strength, Colors.green, Colors.green.shade50),
            ).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (summary.weaknesses.isNotEmpty) ...[
          _buildSectionTitle(context, '개선 포인트', Icons.trending_up, Colors.orange),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: summary.weaknesses.map((weakness) =>
              _buildTag(weakness, Colors.orange, Colors.orange.shade50),
            ).toList(),
          ),
        ],
      ],
    );
  }

  /// 핵심 인사이트
  Widget _buildKeyInsight(BuildContext context, QuickSummaryReport summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '핵심 인사이트',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.keyInsight,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.play_arrow, color: Colors.green.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.nextAction,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
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

  /// 분석 개요
  Widget _buildAnalysisOverview(BuildContext context, CoachingCard card) {
    final analysis = card.analysisResult;
    final items = [
      analysis.pitchAccuracy,
      analysis.stability,
      analysis.vibrato,
      analysis.vowelStability,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '분석 결과', Icons.analytics, Colors.blue),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildAnalysisItem(context, item),
        )),
      ],
    );
  }

  Widget _buildAnalysisItem(BuildContext context, AnalysisItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor(item.priority).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(item.priority),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.category,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _buildGradeBadge(item.grade),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.feedback,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 목표 섹션
  Widget _buildGoalsSection(BuildContext context, CoachingCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '학습 목표', Icons.flag, Colors.purple),
        const SizedBox(height: 12),
        ...card.goals.map((goal) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildGoalItem(context, goal),
        )),
      ],
    );
  }

  Widget _buildGoalItem(BuildContext context, LearningGoal goal) {
    final progress = (goal.currentScore / goal.targetScore).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                  goal.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildDifficultyBadge(goal.difficulty),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getDifficultyColor(goal.difficulty),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${goal.estimatedDays}일 예상',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 연습 시간 추정
  Widget _buildPracticeTimeEstimate(BuildContext context, CoachingCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timer,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 권장 연습시간',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.estimatedPracticeTime}분 집중 연습',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 액션 버튼
  Widget _buildActionButtons(BuildContext context, {required bool isQuickSummary}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewDetails,
            icon: const Icon(Icons.info_outline),
            label: Text(isQuickSummary ? '자세히 보기' : '상세 분석'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onStartPractice,
            icon: const Icon(Icons.play_arrow),
            label: const Text('연습 시작'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// 헬퍼 위젯들
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeBadge(String grade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getGradeColor(grade),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        grade,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(CoachingPriority priority) {
    final color = _getPriorityColor(priority);
    final text = _getPriorityText(priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(GoalDifficulty difficulty) {
    final color = _getDifficultyColor(difficulty);
    final text = _getDifficultyText(difficulty);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 색상 헬퍼들
  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S': return Colors.purple;
      case 'A': return Colors.green;
      case 'B': return Colors.blue;
      case 'C': return Colors.orange;
      case 'D': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(CoachingPriority priority) {
    switch (priority) {
      case CoachingPriority.critical: return Colors.red;
      case CoachingPriority.high: return Colors.orange;
      case CoachingPriority.medium: return Colors.blue;
      case CoachingPriority.low: return Colors.green;
      case CoachingPriority.maintain: return Colors.purple;
    }
  }

  String _getPriorityText(CoachingPriority priority) {
    switch (priority) {
      case CoachingPriority.critical: return '긴급';
      case CoachingPriority.high: return '높음';
      case CoachingPriority.medium: return '보통';
      case CoachingPriority.low: return '낮음';
      case CoachingPriority.maintain: return '유지';
    }
  }

  Color _getDifficultyColor(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy: return Colors.green;
      case GoalDifficulty.medium: return Colors.blue;
      case GoalDifficulty.hard: return Colors.orange;
      case GoalDifficulty.expert: return Colors.red;
    }
  }

  String _getDifficultyText(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy: return '쉬움';
      case GoalDifficulty.medium: return '보통';
      case GoalDifficulty.hard: return '어려움';
      case GoalDifficulty.expert: return '전문가';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '${duration.inSeconds}초';
    }
  }
}