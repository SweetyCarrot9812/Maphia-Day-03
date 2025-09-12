import 'package:isar/isar.dart';

// Local Isar models for offline-first architecture
part 'isar_models.g.dart';

@collection
class LocalSession {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String sessionId;
  
  @Index()
  late String userId;
  
  late DateTime date;
  late String status; // 'planned', 'in_progress', 'done'
  late String planId;
  late String exercisesJson; // JSON string of exercises
  
  DateTime? startedAt;
  DateTime? completedAt;
  int? durationMinutes;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  late String deviceId;
  
  @Index()
  bool conflicted = false;
}

@collection
class LocalLog {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String logId;
  
  @Index()
  late String userId;
  
  @Index(composite: [CompositeIndex('userId')])
  late String sessionId;
  
  late String exerciseKey;
  late int setIndex;
  late double weight;
  late int reps;
  late int rpe;
  late DateTime completedAt;
  
  String? note;
  bool isPR = false;
  double? estimated1RM;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  late String deviceId;
  
  @Index()
  bool conflicted = false;
}

@collection
class LocalPlanCacheIsar {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String cacheKey;
  
  late String payload; // JSON string
  late int ttlEpoch;
  late DateTime createdAt;
}

@collection
class PendingOperationIsar {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String operationId;
  
  late String op; // 'UPSERT' or 'DELETE'
  late String collection;
  late String payload; // JSON string
  late DateTime createdAt;
  
  int retryCount = 0;
  DateTime? lastAttemptAt;
  String? errorMessage;
  
  @Index()
  bool processed = false;
}

@collection
class LocalUserProfile {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;
  
  late String name;
  late String sex; // 'male', 'female', 'other'
  late int heightCm;
  late double weightKg;
  late String unit; // 'kg' or 'lbs'
  
  late String injuriesJson; // JSON array of strings
  late String preferredDaysJson; // JSON array of strings  
  late String equipmentJson; // JSON array of strings
  
  int rpeMin = 6;
  int rpeMax = 9;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  late String deviceId;
  
  @Index()
  bool conflicted = false;
}

@collection
class LocalUserMetrics {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String userId;
  
  late String oneRMJson; // JSON map of movement:weight
  int fatigueScore = 5; // 0-10
  double sleepHours = 8.0;
  DateTime? lastPRAt;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  late String deviceId;
  
  @Index()
  bool conflicted = false;
}

@collection
class LocalWorkoutSchedule {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;
  
  @Index()
  late String planId;
  
  late String scheduleId;
  late String title;
  late DateTime startDate;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String deviceId;
  late bool conflicted;
  late bool isActive;
  
  String? rruleString;
  List<String> completedDates = [];
}