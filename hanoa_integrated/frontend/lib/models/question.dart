class Question {
  final String id;
  final String questionText;
  final List<String> choices;
  final int correctAnswer; // 0-4 (5지선다)
  final String subject; // 간호학 과목 (기존 category)
  final List<String> tags; // 추가 태그들
  final String difficulty;
  final String explanation;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Question({
    required this.id,
    required this.questionText,
    required this.choices,
    required this.correctAnswer,
    required this.subject,
    this.tags = const [],
    required this.difficulty,
    this.explanation = '',
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  }) : assert(choices.length == 5, '문제는 5지선다여야 합니다'),
       assert(correctAnswer >= 0 && correctAnswer < 5, '정답은 0-4 사이의 값이어야 합니다');

  // Firestore에서 읽어올 때 사용
  factory Question.fromMap(Map<String, dynamic> map, String id) {
    return Question(
      id: id,
      questionText: map['questionText'] ?? '',
      choices: List<String>.from(map['choices'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
      subject: map['subject'] ?? map['category'] ?? '', // 하위 호환성
      tags: List<String>.from(map['tags'] ?? []),
      difficulty: map['difficulty'] ?? 'medium',
      explanation: map['explanation'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt']?.millisecondsSinceEpoch ?? 0,
      ),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['updatedAt'].millisecondsSinceEpoch,
            )
          : null,
    );
  }

  // Firestore에 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'choices': choices,
      'correctAnswer': correctAnswer,
      'subject': subject,
      'tags': tags,
      'difficulty': difficulty,
      'explanation': explanation,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // 문제 중복 검사를 위한 해시 생성
  String get contentHash {
    final content = questionText + choices.join('');
    return content.hashCode.toString();
  }

  // 문제 복사 (수정 시 사용)
  Question copyWith({
    String? id,
    String? questionText,
    List<String>? choices,
    int? correctAnswer,
    String? subject,
    List<String>? tags,
    String? difficulty,
    String? explanation,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      choices: choices ?? this.choices,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      explanation: explanation ?? this.explanation,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Question{id: $id, questionText: $questionText, subject: $subject, tags: $tags}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.contentHash == contentHash;
  }

  @override
  int get hashCode => contentHash.hashCode;
}