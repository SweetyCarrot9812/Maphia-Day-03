import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/pending_change_provider.dart';
import '../../../core/database/models/pending_change.dart';
import '../../../core/theme/app_theme.dart';

/// 변경 알림 화면 - PendingChange 관리
class PendingChangesScreen extends ConsumerStatefulWidget {
  const PendingChangesScreen({super.key});

  @override
  ConsumerState<PendingChangesScreen> createState() => _PendingChangesScreenState();
}

class _PendingChangesScreenState extends ConsumerState<PendingChangesScreen> {
  String _selectedFilter = 'pending'; // 'pending', 'all', 'approved', 'rejected', 'expired'

  @override
  Widget build(BuildContext context) {
    final pendingChangesAsync = _selectedFilter == 'pending'
        ? ref.watch(activePendingChangesProvider)
        : ref.watch(pendingChangesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('변경 알림'),
        backgroundColor: AppTheme.warningColor,
        foregroundColor: Colors.white,
        actions: [
          // 필터 버튼
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
              if (value != 'pending') {
                // 전체 목록을 다시 불러오고 필터링
                ref.read(pendingChangesProvider.notifier).getPendingChangesByStatus(value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Text('대기 중만'),
              ),
              const PopupMenuItem(
                value: 'all',
                child: Text('전체 보기'),
              ),
              const PopupMenuItem(
                value: 'approved',
                child: Text('승인됨'),
              ),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('거부됨'),
              ),
              const PopupMenuItem(
                value: 'expired',
                child: Text('만료됨'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getFilterLabel(_selectedFilter),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 정보 카드
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outlined,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '변경 알림이란?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '학습 내용을 수정할 때 중요한 변경사항이 감지되면 자동으로 알림을 생성합니다. 승인하면 변경사항이 적용되고, 거부하면 무시됩니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 변경 알림 목록
          Expanded(
            child: pendingChangesAsync.when(
              data: (changes) {
                if (changes.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: changes.length,
                  itemBuilder: (context, index) {
                    final change = changes[index];
                    return _buildChangeCard(change);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.warningColor,
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '변경 알림을 불러오는데 실패했습니다',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(pendingChangesProvider),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedFilter == 'pending'
          ? FloatingActionButton(
              onPressed: _cleanupExpiredChanges,
              backgroundColor: AppTheme.textSecondaryColor,
              tooltip: '만료된 알림 정리',
              child: const Icon(Icons.cleaning_services, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildChangeCard(PendingChange change) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: _buildStatusIcon(change.status),
        title: Text(
          change.summary,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${change.entityType == 'concept' ? '개념' : '문제'} ID: ${change.entityId}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(change.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (change.isExpired && change.status == 'pending') ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '만료됨',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 변경 내용 상세
                _buildChangeDetails(change),
                
                const SizedBox(height: 16),
                
                // 액션 버튼들
                if (change.isPending && !change.isExpired) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectChange(change.id),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('거부'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(color: AppTheme.errorColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveChange(change.id),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('승인'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // 상태 표시
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(change.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(change.status),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _getStatusColor(change.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pending_outlined,
            color: AppTheme.warningColor,
          ),
        );
      case 'approved':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: AppTheme.successColor,
          ),
        );
      case 'rejected':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cancel_outlined,
            color: AppTheme.errorColor,
          ),
        );
      case 'expired':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.textSecondaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.schedule_outlined,
            color: AppTheme.textSecondaryColor,
          ),
        );
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.textSecondaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.help_outline,
            color: AppTheme.textSecondaryColor,
          ),
        );
    }
  }

  Widget _buildChangeDetails(PendingChange change) {
    try {
      final diff = jsonDecode(change.diffJson) as Map<String, dynamic>;
      final original = diff['original'] as Map<String, dynamic>?;
      final updated = diff['updated'] as Map<String, dynamic>?;
      final changes = diff['changes'] as Map<String, dynamic>?;

      if (original == null || updated == null || changes == null) {
        return const Text('변경 내용을 표시할 수 없습니다');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '변경 내용:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // 변경된 필드들 표시
          ...changes.entries.where((entry) => entry.value == true).map((entry) {
            final field = entry.key.replaceAll('Changed', '');
            return _buildFieldComparison(field, original, updated);
          }).toList(),
        ],
      );
    } catch (e) {
      return Text('변경 내용 파싱 오류: $e');
    }
  }

  Widget _buildFieldComparison(String field, Map<String, dynamic> original, Map<String, dynamic> updated) {
    final fieldName = _getFieldDisplayName(field);
    final originalValue = _getFieldValue(field, original);
    final updatedValue = _getFieldValue(field, updated);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          
          // 기존 값
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이전:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  originalValue,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 새 값
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '변경 후:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  updatedValue,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppTheme.warningColor,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'pending'
                ? '대기 중인 변경 알림이 없습니다'
                : '변경 알림이 없습니다',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'pending'
                ? '학습 내용을 수정하면 중요한 변경사항에 대한 알림이 여기에 나타납니다'
                : '선택한 필터에 해당하는 알림이 없습니다',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home),
            label: const Text('홈으로 돌아가기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'pending': return '대기 중';
      case 'all': return '전체';
      case 'approved': return '승인됨';
      case 'rejected': return '거부됨';
      case 'expired': return '만료됨';
      default: return '전체';
    }
  }

  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'title': return '제목';
      case 'body': return '내용';
      case 'stem': return '문제 문항';
      case 'choices': return '선택지';
      case 'answer': return '정답';
      case 'tags': return '태그';
      default: return field;
    }
  }

  String _getFieldValue(String field, Map<String, dynamic> data) {
    final value = data[field];
    if (value is List) {
      return value.join(', ');
    }
    return value?.toString() ?? '없음';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppTheme.warningColor;
      case 'approved': return AppTheme.successColor;
      case 'rejected': return AppTheme.errorColor;
      case 'expired': return AppTheme.textSecondaryColor;
      default: return AppTheme.textSecondaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return '승인 대기 중';
      case 'approved': return '승인되어 적용됨';
      case 'rejected': return '거부됨';
      case 'expired': return '만료됨';
      default: return '알 수 없음';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return '방금 전';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _approveChange(int changeId) async {
    try {
      final success = await ref
          .read(pendingChangesProvider.notifier)
          .approvePendingChange(changeId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('변경사항이 승인되어 적용되었습니다'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('승인 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _rejectChange(int changeId) async {
    try {
      final success = await ref
          .read(pendingChangesProvider.notifier)
          .rejectPendingChange(changeId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('변경사항이 거부되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('거부 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _cleanupExpiredChanges() async {
    try {
      final expiredCount = await ref
          .read(pendingChangesProvider.notifier)
          .cleanupExpiredChanges();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('만료된 알림 ${expiredCount}개가 정리되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('정리 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}