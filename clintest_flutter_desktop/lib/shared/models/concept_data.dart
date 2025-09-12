class ConceptData {
  final String id;
  final String title;
  final String content;
  final List<String> keywords;
  final List<String> imagePaths;
  final DateTime createdAt;
  final ConceptStatus status;

  ConceptData({
    required this.id,
    required this.title,
    required this.content,
    required this.keywords,
    required this.imagePaths,
    required this.createdAt,
    this.status = ConceptStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'keywords': keywords,
      'imagePaths': imagePaths,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory ConceptData.fromJson(Map<String, dynamic> json) {
    return ConceptData(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      keywords: List<String>.from(json['keywords'] ?? []),
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      status: ConceptStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ConceptStatus.pending,
      ),
    );
  }

  ConceptData copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? keywords,
    List<String>? imagePaths,
    DateTime? createdAt,
    ConceptStatus? status,
  }) {
    return ConceptData(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      keywords: keywords ?? this.keywords,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

enum ConceptStatus {
  pending,    // 로컬에 저장됨, AI 검토 대기 중
  reviewed,   // AI 검토 완료, Firebase 동기화 대기
  synced,     // Firebase에 동기화 완료
  failed,     // 동기화 실패
}