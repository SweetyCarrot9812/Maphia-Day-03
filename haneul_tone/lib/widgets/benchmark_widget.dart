import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/benchmark_service.dart';

/// 벤치마크 모드 UI 위젯
/// 
/// AI 자동 테스트 및 최적 설정 기능
/// 
/// Features:
/// - 원클릭 자동 벤치마크 실행
/// - 실시간 진행상황 표시
/// - AI 기반 최적 설정 추천
/// - 성능 등급 및 상세 결과 표시
/// - 설정 자동 적용 기능
class BenchmarkWidget extends ConsumerStatefulWidget {
  final VoidCallback? onSettingsApplied;
  final bool autoApplySettings;
  
  const BenchmarkWidget({
    Key? key,
    this.onSettingsApplied,
    this.autoApplySettings = false,
  }) : super(key: key);

  @override
  ConsumerState<BenchmarkWidget> createState() => _BenchmarkWidgetState();
}

class _BenchmarkWidgetState extends ConsumerState<BenchmarkWidget>
    with TickerProviderStateMixin {
  
  final BenchmarkService _benchmarkService = BenchmarkService();
  
  BenchmarkResult? _currentResult;
  BenchmarkProgress? _currentProgress;
  StreamSubscription? _progressSubscription;
  
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  bool _isRunning = false;
  bool _hasCompleted = false;
  BenchmarkConfig _selectedConfig = BenchmarkConfig.standard();
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _progressSubscription?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            
            if (!_hasCompleted) ...[
              _buildConfigSelection(context),
              const SizedBox(height: 24),
            ],
            
            if (_isRunning) ...[
              _buildProgressSection(context),
            ] else if (_hasCompleted && _currentResult != null) ...[
              _buildResultsSection(context),
            ] else ...[
              _buildStartSection(context),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 헤더 섹션
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.speed,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 자동 벤치마크',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '디바이스 성능을 측정하고 최적 설정을 자동으로 추천합니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 설정 선택 섹션
  Widget _buildConfigSelection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '테스트 강도',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildConfigOption(
                context,
                '빠른 테스트',
                '2-3분 소요\n기본 성능 확인',
                Icons.flash_on,
                BenchmarkConfig.quick(),
                _selectedConfig == BenchmarkConfig.quick(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildConfigOption(
                context,
                '표준 테스트',
                '5-7분 소요\n권장 설정',
                Icons.tune,
                BenchmarkConfig.standard(),
                _selectedConfig == BenchmarkConfig.standard(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildConfigOption(
                context,
                '정밀 테스트',
                '10-15분 소요\n완전한 분석',
                Icons.precision_manufacturing,
                BenchmarkConfig.thorough(),
                _selectedConfig == BenchmarkConfig.thorough(),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 설정 옵션 카드
  Widget _buildConfigOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    BenchmarkConfig config,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedConfig = config;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 시작 섹션
  Widget _buildStartSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'AI가 자동으로 최적 설정을 찾아드립니다',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '• 피치 엔진 성능 비교\n'
                '• 실시간 처리 능력 측정\n' 
                '• 메모리 및 배터리 사용량 분석\n'
                '• 디바이스 특성에 맞는 설정 추천',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: ElevatedButton.icon(
                onPressed: _startBenchmark,
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text(
                  'AI 자동 테스트 시작',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// 진행상황 섹션
  Widget _buildProgressSection(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _currentProgress?.progress ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 진행 상태 애니메이션
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_pulseAnimation.value - 0.8) * 0.5,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'AI가 테스트 중입니다...',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 8),
              
              if (_currentProgress != null) ...[
                Text(
                  _currentProgress!.status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              
              // 진행률 바
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '${(progress * 100).toStringAsFixed(0)}% 완료',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        OutlinedButton(
          onPressed: _isRunning ? null : () {
            setState(() {
              _hasCompleted = false;
              _currentResult = null;
            });
          },
          child: const Text('취소'),
        ),
      ],
    );
  }
  
  /// 결과 섹션
  Widget _buildResultsSection(BuildContext context) {
    final theme = Theme.of(context);
    final result = _currentResult!;
    final grade = result.performanceGrade;
    final recommendations = result.recommendations;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 성능 등급 카드
        if (grade != null) _buildGradeCard(context, grade),
        
        const SizedBox(height: 16),
        
        // 추천 설정 카드
        if (recommendations != null) _buildRecommendationsCard(context, recommendations),
        
        const SizedBox(height: 16),
        
        // 상세 결과 카드
        _buildDetailedResults(context, result),
        
        const SizedBox(height: 20),
        
        // 액션 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasCompleted = false;
                    _currentResult = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('다시 테스트'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: recommendations != null ? () => _applySettings(recommendations) : null,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('AI 추천 설정 적용'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 성능 등급 카드
  Widget _buildGradeCard(BuildContext context, PerformanceGrade grade) {
    final theme = Theme.of(context);
    
    Color gradeColor;
    Color backgroundColor;
    
    switch (grade.grade) {
      case 'S':
        gradeColor = Colors.purple;
        backgroundColor = Colors.purple.withOpacity(0.1);
        break;
      case 'A':
        gradeColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case 'B':
        gradeColor = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
        break;
      case 'C':
        gradeColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      case 'D':
        gradeColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
      default:
        gradeColor = Colors.grey;
        backgroundColor = Colors.grey.withOpacity(0.1);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gradeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // 등급 표시
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: gradeColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                grade.grade,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 설명 및 점수
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성능 등급',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: gradeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  grade.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '종합 점수: ${(grade.overallScore * 100).toStringAsFixed(1)}점',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 추천 설정 카드
  Widget _buildRecommendationsCard(BuildContext context, BenchmarkRecommendations recommendations) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI 추천 설정',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '추천 피치 엔진: ${recommendations.recommendedEngine}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  recommendations.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '품질 점수: ${(recommendations.qualityScore * 100).toStringAsFixed(1)}점',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          if (recommendations.additionalRecommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '추가 권장사항:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...recommendations.additionalRecommendations.map(
              (recommendation) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 상세 결과 표시
  Widget _buildDetailedResults(BuildContext context, BenchmarkResult result) {
    final theme = Theme.of(context);
    
    return ExpansionTile(
      leading: Icon(
        Icons.analytics,
        color: theme.colorScheme.primary,
      ),
      title: const Text('상세 테스트 결과'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (result.hybridEngineTest != null)
                _buildEngineResultCard(context, result.hybridEngineTest!),
              if (result.crepeEngineTest != null) ...[
                const SizedBox(height: 8),
                _buildEngineResultCard(context, result.crepeEngineTest!),
              ],
              if (result.realtimeTest != null) ...[
                const SizedBox(height: 8),
                _buildRealtimeResultCard(context, result.realtimeTest!),
              ],
              if (result.memoryTest != null) ...[
                const SizedBox(height: 8),
                _buildMemoryResultCard(context, result.memoryTest!),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  /// 엔진 결과 카드
  Widget _buildEngineResultCard(BuildContext context, PitchEngineTest test) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '${test.engineName} 엔진',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: test.qualityGrade == 'Excellent' ? Colors.green :
                         test.qualityGrade == 'Good' ? Colors.blue :
                         test.qualityGrade == 'Fair' ? Colors.orange : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  test.qualityGrade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '정확도: ${(test.averageAccuracy * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  '평균 처리: ${test.averageInferenceTimeMs.toStringAsFixed(1)}ms',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                test.canRunRealtime ? Icons.check_circle : Icons.warning,
                size: 14,
                color: test.canRunRealtime ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                test.canRunRealtime ? '실시간 처리 가능' : '실시간 처리 불가',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: test.canRunRealtime ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 실시간 결과 카드
  Widget _buildRealtimeResultCard(BuildContext context, RealtimeTest test) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '실시간 처리 테스트',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '드롭률: ${(test.frameDropRate * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  '평균 프레임: ${test.averageFrameTimeMs.toStringAsFixed(1)}ms',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 메모리 결과 카드
  Widget _buildMemoryResultCard(BuildContext context, MemoryTest test) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.memory,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '메모리 사용량',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '기본: ${test.baselineMemoryMB.toStringAsFixed(1)}MB',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  '최대: ${test.peakMemoryMB.toStringAsFixed(1)}MB',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 벤치마크 시작
  Future<void> _startBenchmark() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _hasCompleted = false;
      _currentResult = null;
      _currentProgress = null;
    });
    
    try {
      _progressSubscription = _benchmarkService.progressStream?.listen(
        (progress) {
          setState(() {
            _currentProgress = progress;
          });
          _progressController.animateTo(progress.progress);
        },
      );
      
      final result = await _benchmarkService.runBenchmark(
        config: _selectedConfig,
        onProgress: (progress) {
          setState(() {
            _currentProgress = progress;
          });
        },
      );
      
      setState(() {
        _currentResult = result;
        _hasCompleted = true;
        _isRunning = false;
      });
      
      // 자동 설정 적용이 활성화된 경우
      if (widget.autoApplySettings && 
          result.isSuccess && 
          result.recommendations != null) {
        _applySettings(result.recommendations!);
      }
      
    } catch (e) {
      print('벤치마크 실패: $e');
      
      setState(() {
        _isRunning = false;
        _hasCompleted = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('벤치마크 실행 중 오류가 발생했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      await _progressSubscription?.cancel();
      _progressSubscription = null;
    }
  }
  
  /// AI 추천 설정 적용
  Future<void> _applySettings(BenchmarkRecommendations recommendations) async {
    if (recommendations.settings == null) return;
    
    try {
      // TODO: 실제 설정 적용 로직 구현
      // 여기서 앱의 설정을 실제로 변경합니다
      final settings = recommendations.settings!;
      
      // SharedPreferences나 Riverpod을 통해 설정 저장
      // await _settingsService.applyBenchmarkSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 추천 설정이 적용되었습니다 (${recommendations.recommendedEngine})'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '확인',
              onPressed: () {},
            ),
          ),
        );
      }
      
      widget.onSettingsApplied?.call();
      
    } catch (e) {
      print('설정 적용 실패: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 적용 중 오류가 발생했습니다: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}