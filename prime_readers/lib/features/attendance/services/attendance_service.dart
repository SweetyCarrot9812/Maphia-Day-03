import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  static const String _boxName = 'attendance_records';
  Box<AttendanceRecord>? _box;

  // Initialize Hive box
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AttendanceRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AttendanceStatusAdapter());
    }
    
    _box = await Hive.openBox<AttendanceRecord>(_boxName);
  }

  Box<AttendanceRecord> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('AttendanceService not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // Check-in a student
  Future<AttendanceRecord> checkIn(
    String studentId, 
    String studentName, {
    String? location,
  }) async {
    // Check if student already checked in today
    final today = DateTime.now();
    final existingRecord = await getTodayAttendance(studentId);
    
    if (existingRecord != null) {
      throw Exception('이미 오늘 체크인했습니다.');
    }

    final record = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: studentId,
      studentName: studentName,
      checkInTime: today,
      location: location ?? '학원',
      status: _determineInitialStatus(today),
    );

    await box.put(record.id, record);
    return record;
  }

  // Check-out a student
  Future<void> checkOut(String recordId) async {
    final record = box.get(recordId);
    if (record == null) {
      throw Exception('출석 기록을 찾을 수 없습니다.');
    }

    if (record.checkOutTime != null) {
      throw Exception('이미 체크아웃했습니다.');
    }

    record.checkOutTime = DateTime.now();
    await record.save();
  }

  // Get today's attendance for a specific student
  Future<AttendanceRecord?> getTodayAttendance(String studentId) async {
    final today = DateTime.now();
    final records = box.values.where((record) {
      return record.studentId == studentId &&
             record.checkInTime.year == today.year &&
             record.checkInTime.month == today.month &&
             record.checkInTime.day == today.day;
    }).toList();

    return records.isNotEmpty ? records.first : null;
  }

  // Get attendance records for a specific student
  Stream<List<AttendanceRecord>> getAttendanceStream(String studentId) async* {
    await initialize();
    
    yield box.values.where((record) => record.studentId == studentId).toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    await for (final _ in box.watch()) {
      yield box.values.where((record) => record.studentId == studentId).toList()
        ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    }
  }

  // Get pending approvals for teachers
  Stream<List<AttendanceRecord>> getPendingApprovalsStream() async* {
    await initialize();
    
    yield box.values.where((record) => record.status == AttendanceStatus.pending).toList()
      ..sort((a, b) => a.checkInTime.compareTo(b.checkInTime));

    await for (final _ in box.watch()) {
      yield box.values.where((record) => record.status == AttendanceStatus.pending).toList()
        ..sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
    }
  }

  // Approve attendance (teacher action)
  Future<void> approveAttendance(String recordId, String teacherId) async {
    final record = box.get(recordId);
    if (record == null) {
      throw Exception('출석 기록을 찾을 수 없습니다.');
    }

    record.status = AttendanceStatus.approved;
    record.teacherApproval = teacherId;
    await record.save();
  }

  // Reject attendance (teacher action)
  Future<void> rejectAttendance(String recordId, String teacherId, String reason) async {
    final record = box.get(recordId);
    if (record == null) {
      throw Exception('출석 기록을 찾을 수 없습니다.');
    }

    record.status = AttendanceStatus.rejected;
    record.teacherApproval = teacherId;
    record.notes = reason;
    await record.save();
  }

  // Get attendance statistics for a student
  Future<Map<String, dynamic>> getAttendanceStats(String studentId) async {
    final records = box.values.where((record) => record.studentId == studentId).toList();
    
    final now = DateTime.now();
    final thisMonthRecords = records.where((record) => 
      record.checkInTime.year == now.year && 
      record.checkInTime.month == now.month
    ).toList();

    final totalDays = thisMonthRecords.length;
    final presentDays = thisMonthRecords.where((r) => 
      r.status == AttendanceStatus.approved).length;
    final lateDays = thisMonthRecords.where((r) => 
      r.status == AttendanceStatus.late).length;
    final absentDays = thisMonthRecords.where((r) => 
      r.status == AttendanceStatus.absent).length;

    final attendanceRate = totalDays > 0 ? (presentDays + lateDays) / totalDays : 0.0;

    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'lateDays': lateDays,
      'absentDays': absentDays,
      'attendanceRate': attendanceRate,
      'thisMonth': thisMonthRecords.length,
    };
  }

  // Determine initial status based on check-in time
  AttendanceStatus _determineInitialStatus(DateTime checkInTime) {
    final hour = checkInTime.hour;
    
    // 학원 수업 시작 시간을 9시로 가정
    if (hour >= 9 && hour < 10) {
      return AttendanceStatus.pending; // 정시
    } else if (hour >= 10) {
      return AttendanceStatus.late; // 지각 (자동으로 지각 처리)
    } else {
      return AttendanceStatus.pending; // 일찍 도착
    }
  }

  // Clear all records (for testing)
  Future<void> clearAllRecords() async {
    await box.clear();
  }

  // Add sample data for testing
  Future<void> addSampleData() async {
    final now = DateTime.now();
    
    final sampleRecords = [
      AttendanceRecord(
        id: '1',
        studentId: 'student1',
        studentName: '김학생',
        checkInTime: now.subtract(const Duration(hours: 2)),
        checkOutTime: now.subtract(const Duration(hours: 1)),
        status: AttendanceStatus.approved,
        location: '학원 1층',
      ),
      AttendanceRecord(
        id: '2',
        studentId: 'student2',
        studentName: '이학생',
        checkInTime: now.subtract(const Duration(minutes: 30)),
        status: AttendanceStatus.pending,
        location: '학원 2층',
      ),
      AttendanceRecord(
        id: '3',
        studentId: 'student3',
        studentName: '박학생',
        checkInTime: now.subtract(const Duration(hours: 3)),
        checkOutTime: now.subtract(const Duration(hours: 1, minutes: 30)),
        status: AttendanceStatus.late,
        location: '학원 1층',
      ),
    ];

    for (final record in sampleRecords) {
      await box.put(record.id, record);
    }
  }
}