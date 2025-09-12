import 'package:isar/isar.dart';

part 'pending_change.g.dart';

@collection
class PendingChange {
  Id id = Isar.autoIncrement;
  
  late String entityType; // "concept" | "problem"
  
  late int entityId;
  
  String summary = "";
  
  String diffJson = "{}"; // 변경 요약 or 차이
  
  DateTime createdAt = DateTime.now();
  
  String status = "pending"; // "pending" | "approved" | "rejected" | "expired"

  // Helper methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'summary': summary,
      'diffJson': diffJson,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  static PendingChange fromJson(Map<String, dynamic> json) {
    final change = PendingChange()
      ..id = json['id'] ?? Isar.autoIncrement
      ..entityType = json['entityType'] ?? ''
      ..entityId = json['entityId'] ?? 0
      ..summary = json['summary'] ?? ''
      ..diffJson = json['diffJson'] ?? '{}'
      ..createdAt = json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now()
      ..status = json['status'] ?? 'pending';
    
    return change;
  }

  // Create a copy with updated fields
  PendingChange copyWith({
    String? entityType,
    int? entityId,
    String? summary,
    String? diffJson,
    DateTime? createdAt,
    String? status,
  }) {
    return PendingChange()
      ..id = id
      ..entityType = entityType ?? this.entityType
      ..entityId = entityId ?? this.entityId
      ..summary = summary ?? this.summary
      ..diffJson = diffJson ?? this.diffJson
      ..createdAt = createdAt ?? this.createdAt
      ..status = status ?? this.status;
  }

  // Check if this change is expired (7 days old)
  bool get isExpired {
    return DateTime.now().difference(createdAt).inDays >= 7;
  }

  // Check if this change is pending
  bool get isPending {
    return status == 'pending' && !isExpired;
  }

  // Check if this change is approved
  bool get isApproved {
    return status == 'approved';
  }

  // Check if this change is rejected
  bool get isRejected {
    return status == 'rejected';
  }

  @override
  String toString() {
    return 'PendingChange{id: $id, entityType: $entityType, entityId: $entityId, summary: $summary, status: $status, createdAt: $createdAt}';
  }
}