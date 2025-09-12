import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String email;
  
  late String name;
  
  late String password; // 실제 프로덕션에서는 해시화 필요
  
  DateTime createdAt = DateTime.now();
  
  DateTime updatedAt = DateTime.now();
  
  // 현재 로그인 중인 사용자인지
  bool isCurrentUser = false;

  // Helper methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCurrentUser': isCurrentUser,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    final user = User()
      ..id = json['id'] ?? Isar.autoIncrement
      ..email = json['email'] ?? ''
      ..name = json['name'] ?? ''
      ..password = json['password'] ?? ''
      ..createdAt = json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now()
      ..updatedAt = json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now()
      ..isCurrentUser = json['isCurrentUser'] ?? false;
    
    return user;
  }

  // Create a copy with updated fields
  User copyWith({
    String? email,
    String? name,
    String? password,
    DateTime? updatedAt,
    bool? isCurrentUser,
  }) {
    return User()
      ..id = id
      ..email = email ?? this.email
      ..name = name ?? this.name
      ..password = password ?? this.password
      ..createdAt = createdAt
      ..updatedAt = updatedAt ?? DateTime.now()
      ..isCurrentUser = isCurrentUser ?? this.isCurrentUser;
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, createdAt: $createdAt, isCurrentUser: $isCurrentUser}';
  }
}