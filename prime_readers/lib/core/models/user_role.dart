enum UserRole {
  student('학생', 'student'),
  parent('학부모', 'parent'),
  teacher('교사', 'teacher'),
  admin('관리자', 'admin');

  const UserRole(this.displayName, this.value);
  
  final String displayName;
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}