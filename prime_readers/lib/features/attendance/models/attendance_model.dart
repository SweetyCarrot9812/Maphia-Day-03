import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 0)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String studentId;

  @HiveField(2)
  String studentName;

  @HiveField(3)
  DateTime checkInTime;

  @HiveField(4)
  DateTime? checkOutTime;

  @HiveField(5)
  AttendanceStatus status;

  @HiveField(6)
  String? teacherApproval;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? location;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.checkInTime,
    this.checkOutTime,
    this.status = AttendanceStatus.pending,
    this.teacherApproval,
    this.notes,
    this.location,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${json['status']}',
        orElse: () => AttendanceStatus.pending,
      ),
      teacherApproval: json['teacherApproval'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status.toString().split('.').last,
      'teacherApproval': teacherApproval,
      'notes': notes,
      'location': location,
    };
  }

  bool get isCompleted => checkOutTime != null;
  
  Duration? get duration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  String get formattedDuration {
    final dur = duration;
    if (dur == null) return '진행 중';
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    return '${hours}시간 ${minutes}분';
  }
}

@HiveType(typeId: 1)
enum AttendanceStatus {
  @HiveField(0)
  pending,    // 승인 대기

  @HiveField(1)
  approved,   // 승인됨

  @HiveField(2)
  rejected,   // 거부됨

  @HiveField(3)
  late,       // 지각

  @HiveField(4)
  absent,     // 결석
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.pending:
        return '승인 대기';
      case AttendanceStatus.approved:
        return '승인됨';
      case AttendanceStatus.rejected:
        return '거부됨';
      case AttendanceStatus.late:
        return '지각';
      case AttendanceStatus.absent:
        return '결석';
    }
  }

  String get emoji {
    switch (this) {
      case AttendanceStatus.pending:
        return '⏳';
      case AttendanceStatus.approved:
        return '✅';
      case AttendanceStatus.rejected:
        return '❌';
      case AttendanceStatus.late:
        return '⚠️';
      case AttendanceStatus.absent:
        return '🚫';
    }
  }
}