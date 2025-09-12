import 'package:flutter/material.dart';
import '../services/formant_analysis_service.dart';
import '../core/audio/formant_analyzer.dart';

/// 포먼트 피드백 위젯
/// 
/// 모음 안정성 피드백을 실시간으로 표시하는 UI 컴포넌트
class FormantFeedbackWidget extends StatelessWidget {
  final FormantFeedback? feedback;
  final VowelStabilityStats? stats;
  final bool isAnalyzing;

  const FormantFeedbackWidget({
    Key? key,
    this.feedback,
    this.stats,
    this.isAnalyzing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            if (isAnalyzing && feedback == null)
              _buildAnalyzingIndicator()
            else if (feedback != null) ...[
              _buildCurrentFeedback(context),
              const SizedBox(height: 16),
              _buildFormantVisualization(),
            ] else
              _buildEmptyState(),
            if (stats != null) ...[
              const Divider(),
              _buildSessionStats(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.record_voice_over,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '모음 발음 분석',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (stats != null)
          _buildStabilityBadge(context, stats!.stabilityGrade),
      ],
    );
  }

  Widget _buildStabilityBadge(BuildContext context, String grade) {
    final color = _getGradeColor(grade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '등급: $grade',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S': return Colors.purple;
      case 'A': return Colors.green;
      case 'B': return Colors.blue;
      case 'C': return Colors.orange;
      default: return Colors.red;
    }
  }

  Widget _buildAnalyzingIndicator() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('음성 분석 중...'),
        ],
      ),
    );
  }

  Widget _buildCurrentFeedback(BuildContext context) {
    final feedback = this.feedback!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 현재 모음 정보
        Row(
          children: [
            _buildVowelIndicator(feedback.vowelClass),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 모음: ${_getVowelDisplayName(feedback.vowelClass)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildStabilityBar(context, feedback.stability),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 피드백 메시지들
        ...feedback.suggestions.map((suggestion) => 
          _buildSuggestionChip(context, suggestion, feedback.severity)),
      ],
    );
  }

  Widget _buildVowelIndicator(VowelClass vowelClass) {
    final vowelName = _getVowelDisplayName(vowelClass);
    final color = _getVowelColor(vowelClass);
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          vowelName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getVowelColor(VowelClass vowelClass) {
    switch (vowelClass) {
      case VowelClass.a: return Colors.red;
      case VowelClass.ae: return Colors.orange;
      case VowelClass.e: return Colors.yellow.shade700;
      case VowelClass.i: return Colors.green;
      case VowelClass.o: return Colors.blue;
      case VowelClass.u: return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _getVowelDisplayName(VowelClass vowelClass) {
    switch (vowelClass) {
      case VowelClass.a: return 'ㅏ';
      case VowelClass.ae: return 'ㅐ';
      case VowelClass.e: return 'ㅔ';
      case VowelClass.i: return 'ㅣ';
      case VowelClass.o: return 'ㅓ';
      case VowelClass.u: return 'ㅜ';
      case VowelClass.high_mid: return '고모음';
      case VowelClass.mid: return '중모음';
      default: return '?';
    }
  }

  Widget _buildStabilityBar(BuildContext context, double stability) {
    final percentage = (stability * 100).toInt();
    final color = stability >= 0.7 ? Colors.green : 
                  stability >= 0.5 ? Colors.orange : Colors.red;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('안정성', style: Theme.of(context).textTheme.bodySmall),
            Text('$percentage%', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            )),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: stability,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context, 
    String suggestion, 
    FeedbackSeverity severity,
  ) {
    final color = _getSeverityColor(severity);
    final icon = _getSeverityIcon(severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(FeedbackSeverity severity) {
    switch (severity) {
      case FeedbackSeverity.success: return Colors.green;
      case FeedbackSeverity.warning: return Colors.orange;
      case FeedbackSeverity.error: return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _getSeverityIcon(FeedbackSeverity severity) {
    switch (severity) {
      case FeedbackSeverity.success: return Icons.check_circle;
      case FeedbackSeverity.warning: return Icons.warning;
      case FeedbackSeverity.error: return Icons.error;
      default: return Icons.info;
    }
  }

  Widget _buildFormantVisualization() {
    final feedback = this.feedback!;
    final values = feedback.formantValues;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '포먼트 주파수',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildFormantInfo('F1', values.f1, Colors.red)),
              Expanded(child: _buildFormantInfo('F2', values.f2, Colors.blue)),
              Expanded(child: _buildFormantInfo('F3', values.f3, Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormantInfo(String label, double frequency, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '${frequency.toInt()}Hz',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSessionStats(BuildContext context) {
    final stats = this.stats!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '세션 통계',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                '전체 안정성',
                '${(stats.overallStability * 100).toInt()}%',
                _getGradeColor(stats.stabilityGrade),
              ),
            ),
            Expanded(
              child: _buildStatItem(
                '분석 시간',
                '${(stats.analysisTimeMs / 1000).toStringAsFixed(1)}초',
                Colors.grey,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                '분석 프레임',
                '${stats.totalFrames}개',
                Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildVowelDistributionChart(stats),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVowelDistributionChart(VowelStabilityStats stats) {
    if (stats.vowelStabilities.isEmpty) {
      return const Text(
        '분석할 모음 데이터가 없습니다',
        style: TextStyle(color: Colors.grey),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '모음별 안정성',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...stats.vowelStabilities.entries.map((entry) {
          final vowel = entry.key;
          final stability = entry.value;
          return _buildVowelStabilityBar(vowel, stability);
        }).toList(),
      ],
    );
  }

  Widget _buildVowelStabilityBar(VowelClass vowel, double stability) {
    final color = _getVowelColor(vowel);
    final vowelName = _getVowelDisplayName(vowel);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              vowelName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: stability,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              '${(stability * 100).toInt()}%',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.mic_none,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            '음성을 녹음하여 모음 분석을 시작하세요',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}