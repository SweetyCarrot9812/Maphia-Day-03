/// v3.1: 수동 입력 문제와 AI 생성 문제 통합 Firebase 동기화 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/sync_management_service.dart';
import '../../../shared/models/question_data.dart';

class SyncManagementScreen extends ConsumerStatefulWidget {
  const SyncManagementScreen({super.key});

  @override
  ConsumerState<SyncManagementScreen> createState() => _SyncManagementScreenState();
}

class _SyncManagementScreenState extends ConsumerState<SyncManagementScreen> {
  final SyncManagementService _syncService = SyncManagementService();
  
  List<QuestionData> _pendingQuestions = [];
  Set<String> _selectedQuestions = {};
  SyncStats? _stats;
  bool _isLoading = false;
  bool _isFirebaseConnected = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final questions = await _syncService.getPendingSyncQuestions();
      final stats = await _syncService.getSyncStats();
      final connected = await _syncService.checkFirebaseConnection();
      
      setState(() {
        _pendingQuestions = questions;
        _stats = stats;
        _isFirebaseConnected = connected;
      });
    } catch (e) {
      _showError('데이터 로드 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _syncSelected() async {
    if (_selectedQuestions.isEmpty) {
      _showError('동기화할 문제를 선택해주세요.');
      return;
    }
    
    if (!_isFirebaseConnected) {
      _showError('Firebase 연결을 확인해주세요.');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final result = await _syncService.syncToFirebase(
        _selectedQuestions.toList(),
        'temp_user_id', // TODO: 실제 사용자 ID
      );
      
      if (result.success) {
        _showSuccess(result.message);
        
        // Codex 인사이트가 있으면 표시
        if (result.codexInsights != null) {
          _showCodexInsights(result.codexInsights!);
        }
        
        _selectedQuestions.clear();
        await _loadData(); // 데이터 새로고침
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('동기화 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _toggleSelection(String questionId) {
    setState(() {
      if (_selectedQuestions.contains(questionId)) {
        _selectedQuestions.remove(questionId);
      } else {
        _selectedQuestions.add(questionId);
      }
    });
  }
  
  void _selectAll() {
    setState(() {
      if (_selectedQuestions.length == _pendingQuestions.length) {
        _selectedQuestions.clear();
      } else {
        _selectedQuestions = _pendingQuestions.map((q) => q.id).toSet();
      }
    });
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _showCodexInsights(Map<String, dynamic> insights) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.purple),
            const SizedBox(width: 8),
            const Text('🤖 Codex MCP 분석 결과'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (insights['avg_quality_score'] != null) ...[
                  _buildInsightCard(
                    '평균 품질 점수',
                    '${(insights['avg_quality_score'] * 100).toStringAsFixed(1)}%',
                    Icons.score,
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                ],
                
                if (insights['subject_distribution'] != null) ...[
                  _buildInsightCard(
                    '주제별 분포',
                    insights['subject_distribution'].toString(),
                    Icons.pie_chart,
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                ],
                
                if (insights['codex_insights'] != null && 
                    insights['codex_insights']['feedback'] != null) ...[
                  _buildInsightCard(
                    'AI 피드백',
                    insights['codex_insights']['feedback'],
                    Icons.psychology,
                    Colors.purple,
                  ),
                  const SizedBox(height: 8),
                ],
                
                Text(
                  '분석 시간: ${insights['analysis_timestamp'] ?? DateTime.now().toIso8601String()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase 동기화 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '새로고침',
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              avatar: Icon(
                _isFirebaseConnected ? Icons.cloud_done : Icons.cloud_off,
                size: 16,
                color: _isFirebaseConnected ? Colors.green : Colors.red,
              ),
              label: Text(
                _isFirebaseConnected ? '연결됨' : '연결 안됨',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 통계 카드
                if (_stats != null) _buildStatsCard(),
                
                // 제어 버튼들
                _buildControlBar(),
                
                // 문제 목록
                Expanded(
                  child: _pendingQuestions.isEmpty
                      ? _buildEmptyState()
                      : _buildQuestionList(),
                ),
              ],
            ),
      floatingActionButton: _selectedQuestions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _syncSelected,
              icon: const Icon(Icons.cloud_upload),
              label: Text('선택된 ${_selectedQuestions.length}개 동기화'),
            )
          : null,
    );
  }
  
  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '동기화 현황',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('대기 중', '${_stats!.pendingTotal}개', Icons.pending_actions),
              _buildStatItem('수동 입력', '${_stats!.pendingManual}개', Icons.edit),
              _buildStatItem('AI 생성', '${_stats!.pendingAi}개', Icons.auto_awesome),
              _buildStatItem('총 동기화', '${_stats!.totalSynced}개', Icons.cloud_done),
            ],
          ),
          if (_stats!.lastSyncAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '마지막 동기화: ${_formatDateTime(_stats!.lastSyncAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _selectAll,
            icon: Icon(
              _selectedQuestions.length == _pendingQuestions.length
                  ? Icons.deselect
                  : Icons.select_all,
            ),
            label: Text(
              _selectedQuestions.length == _pendingQuestions.length
                  ? '전체 해제'
                  : '전체 선택',
            ),
          ),
          const SizedBox(width: 8),
          Text('${_selectedQuestions.length}/${_pendingQuestions.length}개 선택됨'),
          const Spacer(),
          FilledButton.icon(
            onPressed: _pendingQuestions.isEmpty ? null : _syncSelected,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('선택된 문제 동기화'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_done,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '동기화 대기 중인 문제가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '수동 입력하거나 AI로 생성한 문제가 여기에 표시됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingQuestions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final question = _pendingQuestions[index];
        final isSelected = _selectedQuestions.contains(question.id);
        
        return Card(
          elevation: isSelected ? 4 : 1,
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (value) => _toggleSelection(question.id),
            title: Text(
              question.stem,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildChip(question.subject, Colors.blue),
                    const SizedBox(width: 4),
                    _buildChip(question.difficulty, _getDifficultyColor(question.difficulty)),
                    const SizedBox(width: 4),
                    _buildChip(question.source == 'manual' ? '수동' : 'AI', 
                             question.source == 'manual' ? Colors.orange : Colors.purple),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '생성일: ${_formatDateTime(question.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (question.qualityScore != null)
                  Text(
                    '품질 점수: ${(question.qualityScore! * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            secondary: question.hasImages
                ? const Icon(Icons.image, color: Colors.green)
                : null,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
        );
      },
    );
  }
  
  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'HIGH':
        return Colors.red;
      case 'MID':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}