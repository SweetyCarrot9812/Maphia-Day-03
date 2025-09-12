import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class AttendanceApprovalScreen extends ConsumerStatefulWidget {
  const AttendanceApprovalScreen({super.key});

  @override
  ConsumerState<AttendanceApprovalScreen> createState() => _AttendanceApprovalScreenState();
}

class _AttendanceApprovalScreenState extends ConsumerState<AttendanceApprovalScreen> 
    with SingleTickerProviderStateMixin {
  // 임시 교사 ID
  static const String currentTeacherId = 'teacher1';
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석 승인 관리'),
        centerTitle: true,
        backgroundColor: Colors.green.shade50,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: '승인 대기',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: '처리 완료',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return Consumer(
      builder: (context, ref, child) {
        final pendingAsync = ref.watch(pendingApprovalsProvider);
        
        return pendingAsync.when(
          data: (pendingRecords) {
            if (pendingRecords.isEmpty) {
              return _buildEmptyState(
                icon: Icons.check_circle_outline,
                title: '승인 대기 중인 출석이 없습니다',
                subtitle: '모든 출석이 처리되었습니다',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(pendingApprovalsProvider);
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: pendingRecords.length,
                itemBuilder: (context, index) {
                  final record = pendingRecords[index];
                  return _buildPendingAttendanceCard(record);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer(
      builder: (context, ref, child) {
        // 모든 출석 기록 중 처리된 것들만 표시하는 provider가 필요함
        // 임시로 빈 리스트 반환
        return _buildEmptyState(
          icon: Icons.history,
          title: '처리 기록이 없습니다',
          subtitle: '승인하거나 거부한 출석 기록이 여기에 표시됩니다',
        );
      },
    );
  }

  Widget _buildPendingAttendanceCard(AttendanceRecord record) {
    final attendanceController = ref.watch(attendanceControllerProvider);
    final isLoading = attendanceController.isLoading;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 학생 정보 헤더
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    record.studentName[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.studentName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '학생 ID: ${record.studentId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(record.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    record.status.displayName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _getStatusColor(record.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // 출석 정보
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.login, '체크인', _formatDateTime(record.checkInTime)),
                  if (record.checkOutTime != null) ...[
                    SizedBox(height: 8.h),
                    _buildInfoRow(Icons.logout, '체크아웃', _formatDateTime(record.checkOutTime!)),
                    SizedBox(height: 8.h),
                    _buildInfoRow(Icons.timer, '학습시간', record.formattedDuration),
                  ],
                  if (record.location != null) ...[
                    SizedBox(height: 8.h),
                    _buildInfoRow(Icons.location_on, '위치', record.location!),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 승인/거부 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : () => _showRejectDialog(record),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('거부'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _approveAttendance(record),
                    icon: isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                    label: Text(isLoading ? '처리중...' : '승인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(pendingApprovalsProvider);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveAttendance(AttendanceRecord record) async {
    try {
      await ref.read(attendanceControllerProvider.notifier)
        .approveAttendance(record.id, currentTeacherId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${record.studentName}의 출석을 승인했습니다'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '확인',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('승인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRejectDialog(AttendanceRecord record) async {
    final reasonController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${record.studentName} 출석 거부'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('출석을 거부하는 이유를 입력해주세요:'),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: '거부 사유를 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('거부'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        await ref.read(attendanceControllerProvider.notifier)
          .rejectAttendance(record.id, currentTeacherId, reasonController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${record.studentName}의 출석을 거부했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('거부 처리 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.approved:
        return Colors.green;
      case AttendanceStatus.pending:
        return Colors.orange;
      case AttendanceStatus.rejected:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (recordDate == today) {
      dateStr = '오늘';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      dateStr = '어제';
    } else {
      dateStr = '${dateTime.month}/${dateTime.day}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr $timeStr';
  }
}