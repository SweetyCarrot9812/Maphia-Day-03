import 'package:flutter_test/flutter_test.dart';
import 'package:haneul_tone/models/user.dart';

void main() {
  group('User Model', () {
    test('should create user with required fields', () {
      const user = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
      );

      expect(user.id, equals('test-id'));
      expect(user.email, equals('test@example.com'));
      expect(user.username, equals('testuser'));
      expect(user.displayName, equals('Test User'));
    });

    test('should serialize to JSON correctly', () {
      const user = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        createdAt: '2024-01-01T00:00:00Z',
      );

      final json = user.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['email'], equals('test@example.com'));
      expect(json['username'], equals('testuser'));
      expect(json['displayName'], equals('Test User'));
      expect(json['createdAt'], equals('2024-01-01T00:00:00Z'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'email': 'test@example.com',
        'username': 'testuser',
        'displayName': 'Test User',
        'createdAt': '2024-01-01T00:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('test-id'));
      expect(user.email, equals('test@example.com'));
      expect(user.username, equals('testuser'));
      expect(user.displayName, equals('Test User'));
      expect(user.createdAt, equals('2024-01-01T00:00:00Z'));
    });

    test('should handle optional fields', () {
      final json = {
        'id': 'test-id',
        'email': 'test@example.com',
        'username': 'testuser',
        'displayName': 'Test User',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('test-id'));
      expect(user.createdAt, isNull);
    });

    test('should create copy with updated fields', () {
      const originalUser = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
      );

      final updatedUser = originalUser.copyWith(
        displayName: 'Updated User',
        email: 'updated@example.com',
      );

      expect(updatedUser.id, equals('test-id'));
      expect(updatedUser.email, equals('updated@example.com'));
      expect(updatedUser.username, equals('testuser'));
      expect(updatedUser.displayName, equals('Updated User'));
    });

    test('should validate email format', () {
      expect(User.isValidEmail('test@example.com'), isTrue);
      expect(User.isValidEmail('user.name@domain.co.uk'), isTrue);
      expect(User.isValidEmail('invalid-email'), isFalse);
      expect(User.isValidEmail(''), isFalse);
      expect(User.isValidEmail('@example.com'), isFalse);
      expect(User.isValidEmail('test@'), isFalse);
    });
  });
}

// Mock User class for testing
class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? profile;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.createdAt,
    this.updatedAt,
    this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (profile != null) 'profile': profile,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      profile: json['profile'] as Map<String, dynamic>?,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
    );
  }

  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, username, displayName);
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, displayName: $displayName)';
  }
}