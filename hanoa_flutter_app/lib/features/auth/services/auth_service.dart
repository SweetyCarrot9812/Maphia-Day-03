import 'package:isar/isar.dart';
import '../../../core/database/database.dart';
import '../../../core/database/models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  /// 슈퍼관리자 계정 정보
  static const String _superAdminEmail = 'tkand@hanoa.com';
  static const String _superAdminPassword = 'hanoa_tkand_2024!';
  static const String _superAdminName = 'TK Admin';

  /// 초기화 - 슈퍼관리자 계정 생성
  Future<void> initialize() async {
    await _createSuperAdminIfNotExists();
  }

  /// 슈퍼관리자 계정이 없으면 생성
  Future<void> _createSuperAdminIfNotExists() async {
    try {
      final existingSuperAdmin = await Database.isar.users
          .filter()
          .emailEqualTo(_superAdminEmail)
          .findFirst();

      if (existingSuperAdmin == null) {
        final superAdmin = User()
          ..email = _superAdminEmail
          ..name = _superAdminName
          ..password = _superAdminPassword
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isCurrentUser = false;

        await Database.isar.writeTxn(() async {
          await Database.isar.users.put(superAdmin);
        });

        print('✅ 슈퍼관리자 계정이 생성되었습니다: $_superAdminEmail');
      } else {
        print('ℹ️ 슈퍼관리자 계정이 이미 존재합니다: $_superAdminEmail');
      }
    } catch (e) {
      print('❌ 슈퍼관리자 계정 생성 오류: $e');
    }
  }

  /// 회원가입 (Flutter 앱 전용, 로컬 저장)
  Future<AuthResult> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      // 1. 로컬 이메일 중복 확인
      final existingUser = await Database.isar.users
          .filter()
          .emailEqualTo(email)
          .findFirst();

      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: '이미 존재하는 이메일입니다.',
        );
      }

      // 2. 로컬에 사용자 저장
      final user = User()
        ..email = email
        ..name = name
        ..password = password // 실제 프로덕션에서는 해시화 필요
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isCurrentUser = true;

      // 기존 사용자들의 isCurrentUser를 false로 설정
      await _clearCurrentUser();

      // 새 사용자 저장
      await Database.isar.writeTxn(() async {
        await Database.isar.users.put(user);
      });

      return AuthResult(
        success: true,
        message: '회원가입이 완료되었습니다!',
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '회원가입 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 로그인 (Flutter 앱 전용, 로컬 검증)
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. 로컬에서 사용자 찾기
      final user = await Database.isar.users
          .filter()
          .emailEqualTo(email)
          .findFirst();

      if (user == null) {
        return AuthResult(
          success: false,
          message: '존재하지 않는 계정입니다.',
        );
      }

      // 2. 비밀번호 확인 (실제 프로덕션에서는 해시 비교)
      if (user.password != password) {
        return AuthResult(
          success: false,
          message: '비밀번호가 올바르지 않습니다.',
        );
      }

      // 3. 기존 로그인 사용자 해제
      await _clearCurrentUser();

      // 4. 현재 사용자로 설정
      user.isCurrentUser = true;
      user.updatedAt = DateTime.now();

      await Database.isar.writeTxn(() async {
        await Database.isar.users.put(user);
      });

      return AuthResult(
        success: true,
        message: '로그인되었습니다!',
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '로그인 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _clearCurrentUser();
  }

  /// 현재 로그인된 사용자 가져오기
  Future<User?> getCurrentUser() async {
    return await Database.isar.users
        .filter()
        .isCurrentUserEqualTo(true)
        .findFirst();
  }

  /// 모든 사용자의 isCurrentUser를 false로 설정
  Future<void> _clearCurrentUser() async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      currentUser.isCurrentUser = false;
      await Database.isar.writeTxn(() async {
        await Database.isar.users.put(currentUser);
      });
    }
  }

  /// 사용자가 로그인되어 있는지 확인
  Future<bool> isSignedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// 디버그용 - 모든 사용자 목록 출력
  Future<void> debugPrintAllUsers() async {
    try {
      final users = await Database.isar.users.where().findAll();
      print('🔍 데이터베이스에 저장된 모든 사용자:');
      for (final user in users) {
        print('- 이메일: ${user.email}, 이름: ${user.name}, 현재 사용자: ${user.isCurrentUser}');
      }
      print('총 ${users.length}명의 사용자가 있습니다.');
    } catch (e) {
      print('❌ 사용자 목록 조회 오류: $e');
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}