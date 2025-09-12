import 'country.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  
  // Clintest-specific settings with prefix
  final CountryCode clintestCountryOfPractice;
  final LabelLocale clintestLabelLocale;
  final String clintestRole; // "sn"|"rn"|"np"|"physician"
  final List<String> clintestDepartments;
  final List<String> clintestInterests;
  final bool clintestEnableAIParsing;
  final bool clintestEnableAutoTagging;
  final double clintestAutoTaggingThreshold;
  
  // Settings metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, DateTime> clintestSettingsHistory;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.clintestCountryOfPractice,
    required this.clintestLabelLocale,
    required this.clintestRole,
    this.clintestDepartments = const [],
    this.clintestInterests = const [],
    this.clintestEnableAIParsing = true,
    this.clintestEnableAutoTagging = true,
    this.clintestAutoTaggingThreshold = 0.85,
    required this.createdAt,
    required this.updatedAt,
    this.clintestSettingsHistory = const {},
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    CountryCode? clintestCountryOfPractice,
    LabelLocale? clintestLabelLocale,
    String? clintestRole,
    List<String>? clintestDepartments,
    List<String>? clintestInterests,
    bool? clintestEnableAIParsing,
    bool? clintestEnableAutoTagging,
    double? clintestAutoTaggingThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, DateTime>? clintestSettingsHistory,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      clintestCountryOfPractice: clintestCountryOfPractice ?? this.clintestCountryOfPractice,
      clintestLabelLocale: clintestLabelLocale ?? this.clintestLabelLocale,
      clintestRole: clintestRole ?? this.clintestRole,
      clintestDepartments: clintestDepartments ?? this.clintestDepartments,
      clintestInterests: clintestInterests ?? this.clintestInterests,
      clintestEnableAIParsing: clintestEnableAIParsing ?? this.clintestEnableAIParsing,
      clintestEnableAutoTagging: clintestEnableAutoTagging ?? this.clintestEnableAutoTagging,
      clintestAutoTaggingThreshold: clintestAutoTaggingThreshold ?? this.clintestAutoTaggingThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clintestSettingsHistory: clintestSettingsHistory ?? this.clintestSettingsHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'clintest_country_of_practice': clintestCountryOfPractice.code,
      'clintest_label_locale': clintestLabelLocale.code,
      'clintest_role': clintestRole,
      'clintest_departments': clintestDepartments,
      'clintest_interests': clintestInterests,
      'clintest_enable_ai_parsing': clintestEnableAIParsing,
      'clintest_enable_auto_tagging': clintestEnableAutoTagging,
      'clintest_auto_tagging_threshold': clintestAutoTaggingThreshold,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'clintest_settings_history': clintestSettingsHistory.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      clintestCountryOfPractice: CountryCode.fromCode(json['clintest_country_of_practice'] ?? 'KR'),
      clintestLabelLocale: LabelLocale.fromCode(json['clintest_label_locale'] ?? 'ko'),
      clintestRole: json['clintest_role'] ?? 'sn',
      clintestDepartments: List<String>.from(json['clintest_departments'] ?? []),
      clintestInterests: List<String>.from(json['clintest_interests'] ?? []),
      clintestEnableAIParsing: json['clintest_enable_ai_parsing'] ?? true,
      clintestEnableAutoTagging: json['clintest_enable_auto_tagging'] ?? true,
      clintestAutoTaggingThreshold: (json['clintest_auto_tagging_threshold'] ?? 0.85).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      clintestSettingsHistory: (json['clintest_settings_history'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, DateTime.parse(value)),
      ) ?? {},
    );
  }

  // Default profile for new users
  static UserProfile defaultProfile({
    required String id,
    required String name,
    required String email,
    String role = '학생간호사',
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: id,
      name: name,
      email: email,
      role: role,
      clintestCountryOfPractice: CountryCode.KR, // Default to Korea
      clintestLabelLocale: LabelLocale.ko, // Default to Korean
      clintestRole: 'sn', // Default to student nurse
      createdAt: now,
      updatedAt: now,
    );
  }
}