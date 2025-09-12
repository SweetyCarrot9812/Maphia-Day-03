// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 0;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      id: fields[0] as String,
      studentId: fields[1] as String,
      studentName: fields[2] as String,
      checkInTime: fields[3] as DateTime,
      checkOutTime: fields[4] as DateTime?,
      status: fields[5] as AttendanceStatus,
      teacherApproval: fields[6] as String?,
      notes: fields[7] as String?,
      location: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.studentName)
      ..writeByte(3)
      ..write(obj.checkInTime)
      ..writeByte(4)
      ..write(obj.checkOutTime)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.teacherApproval)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceStatusAdapter extends TypeAdapter<AttendanceStatus> {
  @override
  final int typeId = 1;

  @override
  AttendanceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceStatus.pending;
      case 1:
        return AttendanceStatus.approved;
      case 2:
        return AttendanceStatus.rejected;
      case 3:
        return AttendanceStatus.late;
      case 4:
        return AttendanceStatus.absent;
      default:
        return AttendanceStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceStatus obj) {
    switch (obj) {
      case AttendanceStatus.pending:
        writer.writeByte(0);
        break;
      case AttendanceStatus.approved:
        writer.writeByte(1);
        break;
      case AttendanceStatus.rejected:
        writer.writeByte(2);
        break;
      case AttendanceStatus.late:
        writer.writeByte(3);
        break;
      case AttendanceStatus.absent:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
