import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

// Attendance Service Provider
final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});

// Current User's Attendance Records Provider
final currentUserAttendanceProvider = StreamProvider.family<List<AttendanceRecord>, String>((ref, userId) async* {
  final service = ref.read(attendanceServiceProvider);
  
  await for (final records in service.getAttendanceStream(userId)) {
    yield records;
  }
});

// Today's Attendance for Current User
final todayAttendanceProvider = Provider.family<AttendanceRecord?, String>((ref, userId) {
  final attendanceAsync = ref.watch(currentUserAttendanceProvider(userId));
  
  return attendanceAsync.when(
    data: (records) {
      final today = DateTime.now();
      return records.where((record) {
        return record.checkInTime.year == today.year &&
               record.checkInTime.month == today.month &&
               record.checkInTime.day == today.day;
      }).firstOrNull;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Pending Attendance Approvals (for Teachers)
final pendingApprovalsProvider = StreamProvider<List<AttendanceRecord>>((ref) async* {
  final service = ref.read(attendanceServiceProvider);
  
  await for (final records in service.getPendingApprovalsStream()) {
    yield records;
  }
});

// Attendance Statistics Provider
final attendanceStatsProvider = Provider.family<AttendanceStats, String>((ref, userId) {
  final attendanceAsync = ref.watch(currentUserAttendanceProvider(userId));
  
  return attendanceAsync.when(
    data: (records) => AttendanceStats.fromRecords(records),
    loading: () => AttendanceStats.empty(),
    error: (_, __) => AttendanceStats.empty(),
  );
});

// Check-in/Check-out Controller
final attendanceControllerProvider = StateNotifierProvider<AttendanceController, AsyncValue<void>>((ref) {
  final service = ref.read(attendanceServiceProvider);
  return AttendanceController(service);
});

class AttendanceController extends StateNotifier<AsyncValue<void>> {
  final AttendanceService _service;
  
  AttendanceController(this._service) : super(const AsyncValue.data(null));
  
  Future<void> checkIn(String studentId, String studentName, {String? location}) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.checkIn(studentId, studentName, location: location);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> checkOut(String recordId) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.checkOut(recordId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> approveAttendance(String recordId, String teacherId) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.approveAttendance(recordId, teacherId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> rejectAttendance(String recordId, String teacherId, String reason) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.rejectAttendance(recordId, teacherId, reason);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Attendance Statistics Model
class AttendanceStats {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final double attendanceRate;
  final Duration totalLearningTime;
  
  AttendanceStats({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.attendanceRate,
    required this.totalLearningTime,
  });
  
  factory AttendanceStats.fromRecords(List<AttendanceRecord> records) {
    final now = DateTime.now();
    final thisMonth = records.where((r) => 
      r.checkInTime.year == now.year && r.checkInTime.month == now.month
    ).toList();
    
    final presentDays = thisMonth.where((r) => 
      r.status == AttendanceStatus.approved
    ).length;
    
    final lateDays = thisMonth.where((r) => 
      r.status == AttendanceStatus.late
    ).length;
    
    final absentDays = thisMonth.where((r) => 
      r.status == AttendanceStatus.absent
    ).length;
    
    final totalDays = thisMonth.length;
    final attendanceRate = totalDays > 0 ? (presentDays + lateDays) / totalDays : 0.0;
    
    final totalLearningTime = thisMonth
      .where((r) => r.duration != null)
      .fold<Duration>(Duration.zero, (sum, r) => sum + r.duration!);
    
    return AttendanceStats(
      totalDays: totalDays,
      presentDays: presentDays,
      lateDays: lateDays,
      absentDays: absentDays,
      attendanceRate: attendanceRate,
      totalLearningTime: totalLearningTime,
    );
  }
  
  factory AttendanceStats.empty() {
    return AttendanceStats(
      totalDays: 0,
      presentDays: 0,
      lateDays: 0,
      absentDays: 0,
      attendanceRate: 0.0,
      totalLearningTime: Duration.zero,
    );
  }
}