import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> {
  // 임시 사용자 ID (실제로는 인증 시스템에서 가져올 예정)
  static const String currentUserId = 'student1';
  static const String currentUserName = '김학생';

  @override
  Widget build(BuildContext context) {
    final todayAttendance = ref.watch(todayAttendanceProvider(currentUserId));
    final attendanceStats = ref.watch(attendanceStatsProvider(currentUserId));
    final attendanceController = ref.watch(attendanceControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('출석 체크'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade50,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentUserAttendanceProvider(currentUserId));
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘 출석 상태 카드
              _buildTodayAttendanceCard(todayAttendance, attendanceController),
              SizedBox(height: 24.h),
              
              // 이번 달 통계
              _buildMonthlyStats(attendanceStats),
              SizedBox(height: 24.h),
              
              // 출석 기록 리스트
              _buildAttendanceHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayAttendanceCard(AttendanceRecord? todayRecord, AsyncValue<void> controllerState) {
    final isLoading = controllerState.isLoading;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: Colors.blue, size: 24.w),
                SizedBox(width: 8.w),
                Text(
                  '오늘 출석 현황',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            if (todayRecord == null) 
              _buildCheckInSection(isLoading)
            else 
              _buildAttendanceInfo(todayRecord, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInSection(bool isLoading) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Icon(
                Icons.login,
                size: 48.w,
                color: Colors.blue,
              ),
              SizedBox(height: 12.h),
              Text(
                '아직 체크인하지 않았습니다',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '학원에 도착하면 체크인 버튼을 눌러주세요',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _handleCheckIn,
            icon: isLoading 
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.login),
            label: Text(isLoading ? '체크인 중...' : '체크인'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceInfo(AttendanceRecord record, bool isLoading) {
    return Column(
      children: [
        // 출석 상태 표시
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _getStatusColor(record.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _getStatusColor(record.status),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                record.status.emoji,
                style: TextStyle(fontSize: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.status.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(record.status),
                      ),
                    ),
                    Text(
                      '체크인: ${_formatTime(record.checkInTime)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (record.checkOutTime != null)
                      Text(
                        '체크아웃: ${_formatTime(record.checkOutTime!)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // 학습 시간 표시
        if (record.isCompleted)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.green, size: 20.w),
                SizedBox(width: 8.w),
                Text(
                  '학습 시간: ${record.formattedDuration}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          // 체크아웃 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _handleCheckOut(record.id),
              icon: isLoading 
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
              label: Text(isLoading ? '체크아웃 중...' : '체크아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthlyStats(AttendanceStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 출석 통계',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('총 출석일', '${stats.totalDays}일', Colors.blue),
                ),
                Expanded(
                  child: _buildStatItem('출석률', '${(stats.attendanceRate * 100).toStringAsFixed(1)}%', Colors.green),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('지각', '${stats.lateDays}회', Colors.orange),
                ),
                Expanded(
                  child: _buildStatItem('결석', '${stats.absentDays}회', Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return Consumer(
      builder: (context, ref, child) {
        final attendanceAsync = ref.watch(currentUserAttendanceProvider(currentUserId));
        
        return attendanceAsync.when(
          data: (records) {
            if (records.isEmpty) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(40.w),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48.w, color: Colors.grey),
                      SizedBox(height: 12.h),
                      Text(
                        '출석 기록이 없습니다',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '출석 기록',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildAttendanceHistoryItem(record);
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('오류가 발생했습니다: $error'),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceHistoryItem(AttendanceRecord record) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(record.status).withOpacity(0.2),
          child: Text(
            record.status.emoji,
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
        title: Text(
          _formatDate(record.checkInTime),
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('체크인: ${_formatTime(record.checkInTime)}'),
            if (record.checkOutTime != null)
              Text('체크아웃: ${_formatTime(record.checkOutTime!)}'),
            if (record.formattedDuration != '진행 중')
              Text('학습시간: ${record.formattedDuration}'),
          ],
        ),
        trailing: Container(
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
      ),
    );
  }

  Future<void> _handleCheckIn() async {
    try {
      // 위치 권한 확인 (옵션)
      String? location;
      try {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.always || 
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition();
          location = '위도: ${position.latitude.toStringAsFixed(4)}, 경도: ${position.longitude.toStringAsFixed(4)}';
        }
      } catch (e) {
        // 위치 정보 없이 진행
        location = '학원';
      }

      await ref.read(attendanceControllerProvider.notifier)
        .checkIn(currentUserId, currentUserName, location: location);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체크인이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('체크인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOut(String recordId) async {
    try {
      await ref.read(attendanceControllerProvider.notifier).checkOut(recordId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체크아웃이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('체크아웃 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}