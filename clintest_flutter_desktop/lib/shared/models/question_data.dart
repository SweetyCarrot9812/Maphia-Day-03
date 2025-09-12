/// v3.1: 문제 유형 확장 + 품질 게이트 + 임베딩 지원
class QuestionData {
  final String id;
  final String subject;
  final String stem; // 문제 줄기 (기존 question에서 변경)
  final List<String> choices; // 선택지 (MCQ용, 5지선다)
  final String correctAnswer; // 정답 (A, B, C, D, E)
  final String? explanation;
  final QuestionType type; // MCQ, Simulation, Image-based, Essay
  final String difficulty; // HIGH, MID, LOW
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final QuestionStatus status;
  final String source; // manual, generated, reference
  
  // v3.1 품질 게이트 필드
  final String? hash; // SHA-256 해시 (중복 검출용)
  final List<double> embedding; // text-embedding-004 벡터
  final double? qualityScore;
  final List<String>? tags;
  
  // 확장 메타데이터
  final Map<String, dynamic>? metadata;

  QuestionData({
    required this.id,
    required this.subject,
    required this.stem,
    required this.choices,
    required this.correctAnswer,
    this.explanation,
    this.type = QuestionType.mcq,
    this.difficulty = 'MID',
    required this.imagePaths,
    required this.createdAt,
    this.updatedAt,
    this.status = QuestionStatus.pending,
    this.source = 'manual',
    this.hash,
    this.embedding = const [],
    this.qualityScore,
    this.tags,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'stem': stem,
      'choices': choices,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'type': type.id,
      'difficulty': difficulty,
      'imagePaths': imagePaths,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.toString(),
      'source': source,
      'hash': hash,
      'embedding': embedding,
      'qualityScore': qualityScore,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      id: json['id'],
      subject: json['subject'],
      stem: json['stem'] ?? json['question'] ?? '', // 하위 호환성
      choices: List<String>.from(json['choices'] ?? []),
      correctAnswer: json['correctAnswer'] ?? json['answer'] ?? 'A',
      explanation: json['explanation'],
      type: QuestionType.values.firstWhere(
        (e) => e.id == json['type'],
        orElse: () => QuestionType.mcq,
      ),
      difficulty: json['difficulty'] ?? 'MID',
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: QuestionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => QuestionStatus.pending,
      ),
      source: json['source'] ?? 'manual',
      hash: json['hash'],
      embedding: json['embedding'] != null ? List<double>.from(json['embedding']) : [],
      qualityScore: json['qualityScore']?.toDouble(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  QuestionData copyWith({
    String? id,
    String? subject,
    String? stem,
    List<String>? choices,
    String? correctAnswer,
    String? explanation,
    QuestionType? type,
    String? difficulty,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    QuestionStatus? status,
    String? source,
    String? hash,
    List<double>? embedding,
    double? qualityScore,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionData(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      stem: stem ?? this.stem,
      choices: choices ?? this.choices,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      source: source ?? this.source,
      hash: hash ?? this.hash,
      embedding: embedding ?? this.embedding,
      qualityScore: qualityScore ?? this.qualityScore,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 답안 검증
  bool isCorrect(String userAnswer) {
    return userAnswer.toUpperCase() == correctAnswer.toUpperCase();
  }

  /// 문제 전체 텍스트 (정규화용)
  String get fullText => '$stem ${choices.join(' ')}';

  /// 난이도 점수 (0.0-1.0)
  double get difficultyScore {
    switch (difficulty) {
      case 'LOW': return 0.3;
      case 'MID': return 0.5;
      case 'HIGH': return 0.8;
      default: return 0.5;
    }
  }

  /// 이미지 포함 여부
  bool get hasImages => imagePaths.isNotEmpty;

  /// 임베딩 벡터 포함 여부
  bool get hasEmbedding => embedding.isNotEmpty;

  /// 품질 점수 등급
  String get qualityGrade {
    if (qualityScore == null) return 'N/A';
    if (qualityScore! >= 0.8) return 'A';
    if (qualityScore! >= 0.6) return 'B';
    if (qualityScore! >= 0.4) return 'C';
    return 'D';
  }
}

/// 문제 유형 (v3.1)
enum QuestionType {
  mcq('MCQ', '객관식 5지선다'),
  simulation('Simulation', '시뮬레이션 단계별'),
  imageBased('Image-based', '이미지 기반 MCQ'),
  essay('Essay', '서술형 (옵션)');

  const QuestionType(this.id, this.displayName);
  final String id;
  final String displayName;
}

/// 문제 상태 (v3.1 확장)
enum QuestionStatus {
  pending,      // 로컬 저장됨, 처리 대기 중
  gateIn,       // Gate-IN 처리 중 (수동 입력)
  gateOut,      // Gate-OUT 처리 중 (AI 생성)
  gatePass,     // 품질 게이트 통과
  gateBlock,    // 품질 게이트 차단
  reviewed,     // AI 검토 완료
  synced,       // Firebase 동기화 완료
  reference,    // Reference 저장소로 이동
  active,       // 시험용 활성 문항
  failed,       // 처리 실패
}