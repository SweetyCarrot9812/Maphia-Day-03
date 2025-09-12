import 'dart:convert';
import 'vocal_types.dart';

/// 사용자 모델
class User {
  final String? id;
  final String email;
  final String username;
  final String displayName;
  final String? profileImage;
  final VoiceType voiceType;
  final DifficultyLevel skillLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final Map<String, dynamic> preferences;
  final String role;
  final List<String> permissions;
  
  User({
    this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.profileImage,
    this.voiceType = VoiceType.unknown,
    this.skillLevel = DifficultyLevel.beginner,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isEmailVerified = false,
    this.preferences = const {},
    this.role = 'user',
    this.permissions = const <String>[],
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'profileImage': profileImage,
      'voiceType': voiceType.name,
      'skillLevel': skillLevel.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
      'role': role,
      'permissions': permissions,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString(),
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      profileImage: json['profileImage'],
      voiceType: VoiceType.values.firstWhere(
        (e) => e.name == json['voiceType'],
        orElse: () => VoiceType.unknown,
      ),
      skillLevel: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['skillLevel'],
        orElse: () => DifficultyLevel.beginner,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isEmailVerified: json['isEmailVerified'] ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      role: (json['role'] as String?) ?? 'user',
      permissions: (json['permissions'] is List)
          ? List<String>.from(json['permissions'] as List)
          : const <String>[],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? profileImage,
    VoiceType? voiceType,
    DifficultyLevel? skillLevel,
    DateTime? updatedAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
    String? role,
    List<String>? permissions,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      voiceType: voiceType ?? this.voiceType,
      skillLevel: skillLevel ?? this.skillLevel,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username)';
  }
}

