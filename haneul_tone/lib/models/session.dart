class Session {
  final int? id;
  final int referenceId;
  final double accuracyMean;
  final double stabilitySd;
  final String weakSteps;
  final String? aiFeedback;
  final DateTime createdAt;

  Session({
    this.id,
    required this.referenceId,
    required this.accuracyMean,
    required this.stabilitySd,
    required this.weakSteps,
    this.aiFeedback,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference_id': referenceId,
      'accuracy_mean': accuracyMean,
      'stability_sd': stabilitySd,
      'weak_steps': weakSteps,
      'ai_feedback': aiFeedback,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      referenceId: map['reference_id'],
      accuracyMean: map['accuracy_mean'],
      stabilitySd: map['stability_sd'],
      weakSteps: map['weak_steps'],
      aiFeedback: map['ai_feedback'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Session copyWith({
    int? id,
    int? referenceId,
    double? accuracyMean,
    double? stabilitySd,
    String? weakSteps,
    String? aiFeedback,
    DateTime? createdAt,
  }) {
    return Session(
      id: id ?? this.id,
      referenceId: referenceId ?? this.referenceId,
      accuracyMean: accuracyMean ?? this.accuracyMean,
      stabilitySd: stabilitySd ?? this.stabilitySd,
      weakSteps: weakSteps ?? this.weakSteps,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}