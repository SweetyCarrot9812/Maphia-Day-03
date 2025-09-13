import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_queue.g.dart';

@JsonEnum()
enum JobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

@JsonEnum()
enum JobType {
  problem_generation,
  auto_tagging,
  content_analysis,
  data_import,
  data_export,
  system_maintenance,
}

@JsonEnum()
enum Priority {
  low,
  normal,
  high,
  critical,
}

@collection
@JsonSerializable()
class JobQueue {
  Id id = Isar.autoIncrement;

  @JsonKey(name: 'job_id')
  @Index(unique: true)
  late String jobId;

  @Index()
  late String title;

  String? description;

  @Enumerated(EnumType.name)
  late JobType type;

  @Enumerated(EnumType.name)
  @Index()
  JobStatus status = JobStatus.pending;

  @Enumerated(EnumType.name)
  Priority priority = Priority.normal;

  /// Job parameters (JSON object as string)
  String? parameters;

  /// Job result data (JSON object as string)
  String? result;

  /// Error message if job failed
  String? error;

  /// Progress information (0-100)
  @JsonKey(defaultValue: 0)
  int progress = 0;

  /// Current step description
  String? currentStep;

  /// Total estimated steps
  @JsonKey(defaultValue: 1)
  int totalSteps = 1;

  /// Timestamps
  DateTime createdAt = DateTime.now();
  DateTime? startedAt;
  DateTime? completedAt;

  /// Time tracking
  @JsonKey(defaultValue: 0)
  int executionTimeMs = 0;

  /// Retry information
  @JsonKey(defaultValue: 0)
  int retryCount = 0;

  @JsonKey(defaultValue: 3)
  int maxRetries = 3;

  /// Dependencies (job IDs that must complete first)
  String? dependencies;

  /// Tags for categorization
  String? tags;

  /// AI model used (if applicable)
  String? aiModel;

  /// User who created the job
  @JsonKey(defaultValue: 'system')
  String createdBy = 'system';

  /// Job-specific metadata
  String? metadata;

  JobQueue();

  // Factory constructor for JSON deserialization
  factory JobQueue.fromJson(Map<String, dynamic> json) => _$JobQueueFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$JobQueueToJson(this);

  /// Convenience getters for JSON fields
  @ignore
  Map<String, dynamic> get parametersMap {
    if (parameters == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(parameters!) as Map);
    } catch (e) {
      return {};
    }
  }

  @ignore
  Map<String, dynamic> get resultMap {
    if (result == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(result!) as Map);
    } catch (e) {
      return {};
    }
  }

  List<String> get dependenciesList {
    if (dependencies == null) return [];
    try {
      return List<String>.from(jsonDecode(dependencies!) as List);
    } catch (e) {
      return [];
    }
  }

  List<String> get tagsList {
    if (tags == null) return [];
    try {
      return List<String>.from(jsonDecode(tags!) as List);
    } catch (e) {
      return [];
    }
  }

  @ignore
  Map<String, dynamic> get metadataMap {
    if (metadata == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(metadata!) as Map);
    } catch (e) {
      return {};
    }
  }

  /// Calculated properties
  bool get isCompleted => status == JobStatus.completed;
  bool get isFailed => status == JobStatus.failed;
  bool get isRunning => status == JobStatus.running;
  bool get isPending => status == JobStatus.pending;
  bool get isCancelled => status == JobStatus.cancelled;

  bool get canRetry => retryCount < maxRetries && (isFailed || isCancelled);

  @ignore
  Duration get executionTime => Duration(milliseconds: executionTimeMs);

  double get progressPercentage => progress.toDouble();

  String get statusDisplay {
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

  String get typeDisplay {
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

  String get priorityDisplay {
    switch (priority) {
      case Priority.low:
        return '낮음';
      case Priority.normal:
        return '보통';
      case Priority.high:
        return '높음';
      case Priority.critical:
        return '긴급';
    }
  }

  /// Start the job
  JobQueue start() {
    return copyWith(
      status: JobStatus.running,
      startedAt: DateTime.now(),
      progress: 0,
    );
  }

  /// Update progress
  JobQueue updateProgress({
    required int newProgress,
    String? step,
  }) {
    return copyWith(
      progress: newProgress.clamp(0, 100),
      currentStep: step,
    );
  }

  /// Complete the job
  JobQueue complete({
    Map<String, dynamic>? resultData,
  }) {
    final now = DateTime.now();
    final execTime = startedAt != null 
        ? now.difference(startedAt!).inMilliseconds 
        : 0;

    return copyWith(
      status: JobStatus.completed,
      completedAt: now,
      progress: 100,
      result: resultData != null ? jsonEncode(resultData) : result,
      executionTimeMs: execTime,
    );
  }

  /// Fail the job
  JobQueue fail({
    required String errorMessage,
  }) {
    final now = DateTime.now();
    final execTime = startedAt != null 
        ? now.difference(startedAt!).inMilliseconds 
        : 0;

    return copyWith(
      status: JobStatus.failed,
      completedAt: now,
      error: errorMessage,
      executionTimeMs: execTime,
    );
  }

  /// Cancel the job
  JobQueue cancel() {
    final now = DateTime.now();
    final execTime = startedAt != null 
        ? now.difference(startedAt!).inMilliseconds 
        : 0;

    return copyWith(
      status: JobStatus.cancelled,
      completedAt: now,
      executionTimeMs: execTime,
    );
  }

  /// Retry the job
  JobQueue retry() {
    if (!canRetry) return this;

    return copyWith(
      status: JobStatus.pending,
      retryCount: retryCount + 1,
      error: null,
      progress: 0,
      currentStep: null,
      startedAt: null,
      completedAt: null,
    );
  }

  /// Add dependency
  JobQueue addDependency(String jobId) {
    final deps = dependenciesList;
    if (!deps.contains(jobId)) {
      deps.add(jobId);
      return copyWith(dependencies: jsonEncode(deps));
    }
    return this;
  }

  /// Add tag
  JobQueue addTag(String tag) {
    final jobTags = tagsList;
    if (!jobTags.contains(tag)) {
      jobTags.add(tag);
      return copyWith(tags: jsonEncode(jobTags));
    }
    return this;
  }

  /// Copy with method for updating fields
  JobQueue copyWith({
    String? jobId,
    String? title,
    String? description,
    JobType? type,
    JobStatus? status,
    Priority? priority,
    String? parameters,
    String? result,
    String? error,
    int? progress,
    String? currentStep,
    int? totalSteps,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? executionTimeMs,
    int? retryCount,
    int? maxRetries,
    String? dependencies,
    String? tags,
    String? aiModel,
    String? createdBy,
    String? metadata,
  }) {
    final job = JobQueue()
      ..id = id
      ..jobId = jobId ?? this.jobId
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..type = type ?? this.type
      ..status = status ?? this.status
      ..priority = priority ?? this.priority
      ..parameters = parameters ?? this.parameters
      ..result = result ?? this.result
      ..error = error ?? this.error
      ..progress = progress ?? this.progress
      ..currentStep = currentStep ?? this.currentStep
      ..totalSteps = totalSteps ?? this.totalSteps
      ..createdAt = createdAt ?? this.createdAt
      ..startedAt = startedAt ?? this.startedAt
      ..completedAt = completedAt ?? this.completedAt
      ..executionTimeMs = executionTimeMs ?? this.executionTimeMs
      ..retryCount = retryCount ?? this.retryCount
      ..maxRetries = maxRetries ?? this.maxRetries
      ..dependencies = dependencies ?? this.dependencies
      ..tags = tags ?? this.tags
      ..aiModel = aiModel ?? this.aiModel
      ..createdBy = createdBy ?? this.createdBy
      ..metadata = metadata ?? this.metadata;
    return job;
  }

  @override
  String toString() {
    return 'JobQueue{id: $id, jobId: $jobId, title: $title, type: $type, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JobQueue && other.jobId == jobId;
  }

  @override
  int get hashCode => jobId.hashCode;
}