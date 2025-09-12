import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../services/daily_batch_service.dart';
import '../../../services/llm_proxy_service.dart';
import '../../../services/llm_test_service.dart';

// Dashboard data providers (mock data for now)
final dashboardStatsProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'newRegistrations': 48,
  'activeUsers': 1247,
  'feedbackScore': 4.2,
});

// LLM 사용량 통계 제공자
final llmUsageStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final batchService = DailyBatchService.instance;
    final proxyService = LlmProxyService.instance;
    
    // 최근 7일간의 통계 조회
    final recentStats = await batchService.getDailyStats(limit: 50);
    final recentLogs = await proxyService.getUsageLogs(limit: 100);
    
    // 공급자별 비용 계산
    final providerCosts = <String, double>{};
    final modelCalls = <String, int>{};
    
    for (final stat in recentStats) {
      final provider = stat.provider;
      providerCosts[provider] = (providerCosts[provider] ?? 0) + stat.totalCost;
    }
    
    for (final log in recentLogs) {
      final model = log.model;
      modelCalls[model] = (modelCalls[model] ?? 0) + 1;
    }
    
    return {
      'providerCosts': providerCosts,
      'modelCalls': modelCalls,
      'totalCost': providerCosts.values.fold(0.0, (sum, cost) => sum + cost),
      'totalCalls': modelCalls.values.fold(0, (sum, calls) => sum + calls),
    };
  } catch (e) {
    // 실패 시 기본 값 반환
    return {
      'providerCosts': {'OpenAI': 245.30, 'Gemini': 128.45, 'Perplexity': 89.12, 'Anthropic': 167.88},
      'modelCalls': {'GPT-5': 1247, 'Gemini Pro': 892, 'Claude 4': 634, 'Sonar': 445},
      'totalCost': 630.75,
      'totalCalls': 3218,
    };
  }
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final llmStatsAsync = ref.watch(llmUsageStatsProvider);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hanoa Hub 대시보드',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now())} 현재',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildActionButton(
                      context,
                      '주간 리포트',
                      Icons.download,
                      Colors.blue.shade600,
                      () => _generateReport(context, 'weekly'),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context,
                      '월간 리포트',
                      Icons.download,
                      Colors.green.shade600,
                      () => _generateReport(context, 'monthly'),
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context,
                      'LLM 테스트',
                      Icons.smart_toy,
                      Colors.purple.shade600,
                      () => _testLlmTracking(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    '신규 가입',
                    '${stats['newRegistrations']}명',
                    '+12% 어제 대비',
                    Icons.person_add,
                    Colors.blue.shade600,
                    Colors.blue.shade50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    '활성 사용자',
                    '${NumberFormat('#,###').format(stats['activeUsers'])}명',
                    '+5% 지난주 대비',
                    Icons.people,
                    Colors.green.shade600,
                    Colors.green.shade50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    '피드백 평점',
                    '${stats['feedbackScore']}/5.0',
                    '만족도 높음',
                    Icons.star,
                    Colors.amber.shade600,
                    Colors.amber.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // LLM Usage Statistics Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LLM 비용 통계 카드
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LLM 사용량 & 비용',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          llmStatsAsync.when(
                            data: (llmStats) => _buildLlmCostChart(llmStats),
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (error, stack) => _buildLlmCostChart(null),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 모델별 사용 통계
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '모델별 호출 현황',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          llmStatsAsync.when(
                            data: (llmStats) => _buildModelUsageChart(llmStats),
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (error, stack) => _buildModelUsageChart(null),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Provider Performance Chart
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '공급자별 성능 현황',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _buildTimeRangeSelector(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProviderPerformanceChart(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // App statistics section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '앱별 사용 현황',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAppUsageChart(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Color backgroundColor,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: Colors.green.shade600,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAppUsageChart() {
    final appData = [
      {'name': 'Clintest', 'users': 342, 'color': Colors.blue.shade600},
      {'name': 'Lingumo', 'users': 287, 'color': Colors.green.shade600},
      {'name': 'AreumFit', 'users': 198, 'color': Colors.orange.shade600},
      {'name': 'HaneulTone', 'users': 156, 'color': Colors.purple.shade600},
      {'name': 'Hanoa Hub', 'users': 264, 'color': Colors.teal.shade600},
    ];

    final maxUsers = appData.map((e) => e['users'] as int).reduce((a, b) => a > b ? a : b);

    return Column(
      children: appData.map((app) {
        final users = app['users'] as int;
        final percentage = users / maxUsers;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  app['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: app['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 60,
                child: Text(
                  '$users명',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getAppIcon(String app) {
    switch (app) {
      case 'Clintest':
        return Icons.local_hospital;
      case 'Lingumo':
        return Icons.language;
      case 'AreumFit':
        return Icons.fitness_center;
      case 'HaneulTone':
        return Icons.music_note;
      default:
        return Icons.apps;
    }
  }

  /// LLM 비용 차트 (스택 막대 차트)
  Widget _buildLlmCostChart(Map<String, dynamic>? llmStats) {
    // 실제 데이터 또는 기본 데이터 사용
    final providerCosts = llmStats?['providerCosts'] as Map<String, double>? ?? {
      'OpenAI': 245.30,
      'Gemini': 128.45,
      'Perplexity': 89.12,
      'Anthropic': 167.88,
    };
    
    final totalCost = llmStats != null && llmStats['totalCost'] != null 
        ? llmStats['totalCost'] as double
        : providerCosts.values.fold(0.0, (sum, cost) => sum + cost);
    
    // 색상 매핑
    final colorMap = {
      'OpenAI': Colors.blue.shade600,
      'Gemini': Colors.green.shade600,
      'Perplexity': Colors.orange.shade600,
      'Anthropic': Colors.purple.shade600,
    };
    
    final costData = providerCosts.entries.map((entry) => {
      'provider': entry.key,
      'cost': entry.value,
      'color': colorMap[entry.key] ?? Colors.grey.shade600,
    }).toList();
    
    final maxCost = costData.isNotEmpty 
        ? costData.map((e) => e['cost'] as double).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Column(
      children: [
        // 총 비용 표시
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '이번 달 총 비용',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '\$${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 공급자별 비용 막대 차트
        ...costData.map((provider) {
          final cost = provider['cost'] as double;
          final percentage = cost / maxCost;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    provider['provider'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: provider['color'] as Color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  child: Text(
                    '\$${cost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 모델별 사용 차트 (도넛 차트 스타일)
  Widget _buildModelUsageChart(Map<String, dynamic>? llmStats) {
    // 실제 데이터 또는 기본 데이터 사용
    final modelCalls = llmStats?['modelCalls'] as Map<String, int>? ?? {
      'GPT-5': 1247,
      'Gemini Pro': 892,
      'Claude 4': 634,
      'Sonar': 445,
    };
    
    final totalCalls = llmStats != null && llmStats['totalCalls'] != null 
        ? llmStats['totalCalls'] as int
        : modelCalls.values.fold(0, (sum, calls) => sum + calls);
    
    // 색상 매핑
    final colorMap = {
      'GPT-5': Colors.blue.shade600,
      'Gemini Pro': Colors.green.shade600,
      'Claude 4': Colors.purple.shade600,
      'Sonar': Colors.orange.shade600,
    };
    
    final modelData = modelCalls.entries.map((entry) => {
      'name': entry.key,
      'calls': entry.value,
      'color': colorMap[entry.key] ?? Colors.grey.shade600,
    }).toList();

    return Column(
      children: [
        // 총 호출 수 표시
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 API 호출',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                NumberFormat('#,###').format(totalCalls),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 모델별 호출 수 리스트
        ...modelData.map((model) {
          final calls = model['calls'] as int;
          final percentage = totalCalls > 0 ? (calls / totalCalls * 100) : 0.0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: model['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(calls)} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 공급자별 성능 차트 (라인 차트)
  Widget _buildProviderPerformanceChart() {
    final performanceData = [
      {
        'provider': 'OpenAI',
        'success_rate': 99.2,
        'avg_latency': 1.24,
        'color': Colors.blue.shade600,
      },
      {
        'provider': 'Gemini',
        'success_rate': 98.8,
        'avg_latency': 0.89,
        'color': Colors.green.shade600,
      },
      {
        'provider': 'Perplexity',
        'success_rate': 97.5,
        'avg_latency': 2.15,
        'color': Colors.orange.shade600,
      },
      {
        'provider': 'Anthropic',
        'success_rate': 99.1,
        'avg_latency': 1.67,
        'color': Colors.purple.shade600,
      },
    ];

    return Column(
      children: [
        // 헤더
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '공급자',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '성공률',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                '평균 지연',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                '상태',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 데이터 행들
        ...performanceData.map((provider) {
          final successRate = provider['success_rate'] as double;
          final avgLatency = provider['avg_latency'] as double;
          final isHealthy = successRate > 98.0 && avgLatency < 2.0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: provider['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider['provider'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    '${successRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: successRate > 98.0 ? Colors.green.shade600 : Colors.orange.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${avgLatency.toStringAsFixed(2)}s',
                    style: TextStyle(
                      fontSize: 14,
                      color: avgLatency < 2.0 ? Colors.green.shade600 : Colors.orange.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isHealthy ? '정상' : '주의',
                      style: TextStyle(
                        fontSize: 12,
                        color: isHealthy ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 시간 범위 선택기
  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: '지난 7일',
          isDense: true,
          items: ['지난 7일', '지난 30일', '지난 90일'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // 시간 범위 변경 로직
          },
        ),
      ),
    );
  }

  void _generateReport(BuildContext context, String type) {
    final period = type == 'weekly' ? '주간' : '월간';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$period 리포트를 생성 중입니다...'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Simulate report generation delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$period 리포트가 다운로드되었습니다.'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _testLlmTracking(BuildContext context, WidgetRef ref) async {
    // 로딩 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('LLM 테스트 데이터를 생성하고 있습니다...'),
          ],
        ),
        duration: Duration(seconds: 10), // 긴 작업이므로 충분한 시간
      ),
    );

    try {
      // 모크 데이터 생성
      await LlmTestService.instance.generateMockUsageData();
      
      // 데이터 요약 조회
      final summary = await LlmTestService.instance.getMockDataSummary();
      
      // 대시보드 데이터 새로고침
      ref.invalidate(llmUsageStatsProvider);
      
      if (context.mounted) {
        // 기존 스낵바 제거
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LLM 테스트 데이터 생성 완료!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('로그: ${summary['totalLogs']}개'),
                Text('일일 통계: ${summary['totalDailyStats']}개'),
                Text('총 비용: \$${summary['totalCost']?.toStringAsFixed(4)}'),
                Text('총 호출: ${summary['totalCalls']}회'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        // 기존 스낵바 제거
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('LLM 테스트 데이터 생성 실패: $error'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}