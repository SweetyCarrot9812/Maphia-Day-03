import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../core/theme.dart';
import '../../../models/job_queue.dart';
import '../../../services/database_service.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  List<JobQueue> _jobs = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  String _selectedStatus = 'all';
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadJobs(showLoading: false),
    );
  }

  Future<void> _loadJobs({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    
    try {
      final jobs = await DatabaseService.instance.getJobs();
      if (mounted) {
        setState(() {
          _jobs = jobs;
          if (showLoading) _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('작업 로드 실패: $e')),
        );
      }
    }
  }

  List<JobQueue> get _filteredJobs {
    return _jobs.where((job) {
      if (_selectedStatus != 'all' && job.status.name != _selectedStatus) {
        return false;
      }
      if (_selectedType != 'all' && job.type.name != _selectedType) {
        return false;
      }
      return true;
    }).toList();
  }

  Map<JobStatus, int> get _statusCounts {
    final counts = <JobStatus, int>{};
    for (final status in JobStatus.values) {
      counts[status] = _jobs.where((job) => job.status == status).length;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildStatusCards(),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildJobsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work,
                size: 32,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 12),
              Text(
                'Jobs 큐 모니터',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '5초마다 자동 새로고침',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _loadJobs(),
                    icon: const Icon(Icons.refresh),
                    tooltip: '수동 새로고침',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '백그라운드 작업 큐 상태를 실시간으로 모니터링합니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    final counts = _statusCounts;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              '전체',
              _jobs.length.toString(),
              AppTheme.primaryTeal,
              Icons.work_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              '대기중',
              counts[JobStatus.pending].toString(),
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              '실행중',
              counts[JobStatus.running].toString(),
              Colors.blue,
              Icons.play_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              '완료',
              counts[JobStatus.completed].toString(),
              AppTheme.successGreen,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              '실패',
              counts[JobStatus.failed].toString(),
              AppTheme.errorRed,
              Icons.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  label: '상태',
                  value: _selectedStatus,
                  items: [
                    {'value': 'all', 'label': '전체'},
                    ...JobStatus.values.map((status) => {
                      'value': status.name,
                      'label': _getStatusText(status),
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'all';
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  label: '작업 유형',
                  value: _selectedType,
                  items: [
                    {'value': 'all', 'label': '전체'},
                    ...JobType.values.map((type) => {
                      'value': type.name,
                      'label': _getTypeText(type),
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ?? 'all';
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedStatus = 'all';
                    _selectedType = 'all';
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('초기화'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildJobsList() {
    final filteredJobs = _filteredJobs;
    
    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedStatus != 'all' || _selectedType != 'all'
                  ? '필터 조건에 맞는 작업이 없습니다'
                  : '현재 실행중인 작업이 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '총 ${filteredJobs.length}개의 작업',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];
                return _buildJobCard(job);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobQueue job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getStatusIcon(job.status),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(job.status),
              ],
            ),
            if (job.description != null && job.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                job.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.category, job.typeDisplay),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.flag, job.priorityDisplay),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.schedule, _formatDateTime(job.createdAt)),
                if (job.isRunning && job.currentStep != null) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.play_arrow, job.currentStep!),
                ],
              ],
            ),
            if (job.isRunning || job.isCompleted) ...[
              const SizedBox(height: 12),
              _buildProgressBar(job),
            ],
            if (job.isFailed && job.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (job.canRetry) ...[
                  TextButton.icon(
                    onPressed: () => _retryJob(job),
                    icon: const Icon(Icons.replay, size: 16),
                    label: const Text('재시도'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (job.isRunning) ...[
                  TextButton.icon(
                    onPressed: () => _cancelJob(job),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('취소'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton.icon(
                  onPressed: () => _showJobDetails(job),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('상세정보'),
                ),
                const Spacer(),
                if (job.isCompleted || job.isFailed) ...[
                  IconButton(
                    onPressed: () => _deleteJob(job),
                    icon: const Icon(Icons.delete, size: 18),
                    tooltip: '삭제',
                    color: Colors.grey.shade600,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return Icon(Icons.pending, color: Colors.orange, size: 20);
      case JobStatus.running:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case JobStatus.completed:
        return Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20);
      case JobStatus.failed:
        return Icon(Icons.error, color: AppTheme.errorRed, size: 20);
      case JobStatus.cancelled:
        return Icon(Icons.cancel, color: Colors.grey.shade600, size: 20);
    }
  }

  Widget _buildStatusChip(JobStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case JobStatus.pending:
        color = Colors.orange;
        text = '대기중';
        break;
      case JobStatus.running:
        color = Colors.blue;
        text = '실행중';
        break;
      case JobStatus.completed:
        color = AppTheme.successGreen;
        text = '완료';
        break;
      case JobStatus.failed:
        color = AppTheme.errorRed;
        text = '실패';
        break;
      case JobStatus.cancelled:
        color = Colors.grey.shade600;
        text = '취소됨';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(JobQueue job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '진행률',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${job.progress}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: job.isCompleted ? AppTheme.successGreen : Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: job.progress / 100.0,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            job.isCompleted ? AppTheme.successGreen : Colors.blue,
          ),
        ),
      ],
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return '대기중';
      case JobStatus.running:
        return '실행중';
      case JobStatus.completed:
        return '완료';
      case JobStatus.failed:
        return '실패';
      case JobStatus.cancelled:
        return '취소됨';
    }
  }

  String _getTypeText(JobType type) {
    switch (type) {
      case JobType.problem_generation:
        return '문제 생성';
      case JobType.auto_tagging:
        return '자동 태깅';
      case JobType.content_analysis:
        return '콘텐츠 분석';
      case JobType.data_import:
        return '데이터 가져오기';
      case JobType.data_export:
        return '데이터 내보내기';
      case JobType.system_maintenance:
        return '시스템 유지보수';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  Future<void> _retryJob(JobQueue job) async {
    try {
      final retriedJob = job.retry();
      await DatabaseService.instance.updateJob(retriedJob);
      _loadJobs(showLoading: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('작업이 재시도되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('재시도 실패: $e')),
        );
      }
    }
  }

  Future<void> _cancelJob(JobQueue job) async {
    try {
      final cancelledJob = job.cancel();
      await DatabaseService.instance.updateJob(cancelledJob);
      _loadJobs(showLoading: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('작업이 취소되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('취소 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteJob(JobQueue job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작업 삭제'),
        content: Text('정말로 "${job.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteJob(job.id);
        _loadJobs(showLoading: false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('작업이 삭제되었습니다')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  void _showJobDetails(JobQueue job) {
    showDialog(
      context: context,
      builder: (context) => _JobDetailsDialog(job: job),
    );
  }
}

class _JobDetailsDialog extends StatelessWidget {
  final JobQueue job;

  const _JobDetailsDialog({required this.job});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info, color: AppTheme.primaryTeal),
          const SizedBox(width: 8),
          Text('작업 상세정보'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('작업 ID', job.jobId),
              _buildDetailRow('제목', job.title),
              if (job.description != null)
                _buildDetailRow('설명', job.description!),
              _buildDetailRow('유형', job.typeDisplay),
              _buildDetailRow('상태', job.statusDisplay),
              _buildDetailRow('우선순위', job.priorityDisplay),
              _buildDetailRow('진행률', '${job.progress}%'),
              if (job.currentStep != null)
                _buildDetailRow('현재 단계', job.currentStep!),
              _buildDetailRow('총 단계', '${job.totalSteps}'),
              _buildDetailRow('생성일시', _formatFullDateTime(job.createdAt)),
              if (job.startedAt != null)
                _buildDetailRow('시작일시', _formatFullDateTime(job.startedAt!)),
              if (job.completedAt != null)
                _buildDetailRow('완료일시', _formatFullDateTime(job.completedAt!)),
              if (job.executionTimeMs > 0)
                _buildDetailRow('실행시간', '${(job.executionTimeMs / 1000).toStringAsFixed(1)}초'),
              _buildDetailRow('재시도 횟수', '${job.retryCount}/${job.maxRetries}'),
              if (job.aiModel != null)
                _buildDetailRow('AI 모델', job.aiModel!),
              _buildDetailRow('생성자', job.createdBy),
              if (job.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  '오류 정보',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    job.error!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              if (job.parametersMap.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '매개변수',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    job.parametersMap.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
              if (job.resultMap.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '결과',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    job.resultMap.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}