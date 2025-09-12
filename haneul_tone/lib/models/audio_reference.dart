class AudioReference {
  final int? id;
  final String title;
  final String filePath;
  final String key;
  final String scaleType;
  final int octaves;
  final double a4Freq;
  final DateTime createdAt;

  AudioReference({
    this.id,
    required this.title,
    required this.filePath,
    required this.key,
    required this.scaleType,
    required this.octaves,
    this.a4Freq = 440.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'key': key,
      'scale_type': scaleType,
      'octaves': octaves,
      'a4_freq': a4Freq,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AudioReference.fromMap(Map<String, dynamic> map) {
    return AudioReference(
      id: map['id'],
      title: map['title'],
      filePath: map['file_path'],
      key: map['key'],
      scaleType: map['scale_type'],
      octaves: map['octaves'],
      a4Freq: map['a4_freq'] ?? 440.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  AudioReference copyWith({
    int? id,
    String? title,
    String? filePath,
    String? key,
    String? scaleType,
    int? octaves,
    double? a4Freq,
    DateTime? createdAt,
  }) {
    return AudioReference(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      key: key ?? this.key,
      scaleType: scaleType ?? this.scaleType,
      octaves: octaves ?? this.octaves,
      a4Freq: a4Freq ?? this.a4Freq,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// toJson 메서드 추가
  Map<String, dynamic> toJson() => toMap();
  
  /// fromJson 메서드 추가
  factory AudioReference.fromJson(Map<String, dynamic> json) => AudioReference.fromMap(json);
  
  /// 타겟 주파수들을 생성하는 메서드 (임시 구현)
  List<double> getTargetFrequencies() {
    // TODO: 실제 오디오 파일에서 주파수를 추출하는 로직 구현 필요
    return [];
  }
}