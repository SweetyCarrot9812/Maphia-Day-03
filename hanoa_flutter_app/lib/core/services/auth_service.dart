import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'admin_service.dart';

/// 인증 서비스
/// 
/// Firebase Auth와 Google Sign-In을 통합한 인증 시스템
/// Hanoa SSO 시스템과 연동하여 통합 로그인 제공
class AuthService {
  static final _logger = Loggers.auth;
  
  // Firebase Auth 인스턴스
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Google Sign-In 인스턴스 (웹용 설정)
  static final GoogleSignIn _googleSignIn = kIsWeb 
    ? GoogleSignIn(
        clientId: '681902870139-your-client-id.apps.googleusercontent.com', // 실제 웹 클라이언트 ID 필요
        scopes: ['email', 'profile'],
      )
    : GoogleSignIn(
        scopes: ['email', 'profile'],
      );

  /// 현재 로그인된 사용자
  static User? get currentUser => _auth.currentUser;
  
  /// 로그인 상태 스트림
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google 로그인
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      _logger.info('Google 로그인 시작');
      
      // Google 로그인 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _logger.info('Google 로그인 취소됨');
        return null;
      }

      _logger.info('Google 사용자 선택됨: ${googleUser.email}');

      // Google 인증 토큰 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      _logger.info('Firebase 로그인 성공: ${userCredential.user?.email}');

      // 사용자 프로필 생성/업데이트
      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!, userCredential.user!.displayName ?? 'User');
      }

      // Hanoa Hub에 사용자 정보 동기화
      await _syncWithHanoaHub(userCredential.user!);

      // 슈퍼 관리자 자동 초기화 체크
      await AdminService.initializeSuperAdminIfNeeded();

      return userCredential;
    } catch (e) {
      _logger.error('Google 로그인 오류', e);
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    try {
      _logger.info('로그아웃 시작');
      
      // Google Sign-In 로그아웃
      await _googleSignIn.signOut();
      
      // Firebase 로그아웃
      await _auth.signOut();
      
      _logger.info('로그아웃 완료');
    } catch (e) {
      _logger.error('로그아웃 오류', e);
      rethrow;
    }
  }

  /// 익명 로그인 (게스트 모드)
  static Future<UserCredential> signInAnonymously() async {
    try {
      _logger.info('익명 로그인 시작');
      
      final UserCredential userCredential = await _auth.signInAnonymously();
      
      _logger.info('익명 로그인 성공: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      _logger.error('익명 로그인 오류', e);
      rethrow;
    }
  }

  /// 현재 사용자의 ID 토큰 가져오기 (Hanoa Hub 통신용)
  static Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final idToken = await user.getIdToken(forceRefresh);
      _logger.info('ID 토큰 생성됨');
      return idToken;
    } catch (e) {
      _logger.error('ID 토큰 오류', e);
      return null;
    }
  }

  /// Hanoa Hub와 사용자 정보 동기화
  static Future<void> _syncWithHanoaHub(User user) async {
    try {
      _logger.info('Hanoa Hub 동기화 시작');
      
      // ID 토큰 가져오기
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('ID 토큰을 가져올 수 없습니다');
      }

      // 사용자 정보 준비
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'provider': 'google',
        'createdAt': user.metadata.creationTime?.toIso8601String(),
        'lastSignIn': user.metadata.lastSignInTime?.toIso8601String(),
      };

      _logger.debug('사용자 데이터: ${userData['email']}');

      // TODO: Hanoa Hub API 호출하여 사용자 정보 동기화
      // 현재는 로그만 출력, 실제 구현 시 HTTP 요청 필요
      _logger.info('Hanoa Hub 동기화 완료 (구현 예정)');

      // Hanoa Hub URL: http://localhost:4001
      // Endpoint: POST /api/auth/sync-user
      // Headers: Authorization: Bearer {idToken}
      // Body: userData
      
    } catch (e) {
      _logger.error('Hanoa Hub 동기화 오류', e);
      // 동기화 실패해도 로그인은 유지
    }
  }

  /// 사용자 프로필 정보 가져오기
  static Map<String, dynamic>? getUserProfile() {
    final user = currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'creationTime': user.metadata.creationTime?.toIso8601String(),
      'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
    };
  }

  /// 계정 삭제
  static Future<void> deleteAccount() async {
    try {
      _logger.warning('계정 삭제 시작');
      
      final user = currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다');
      }

      // Google Sign-In 연결 해제
      await _googleSignIn.disconnect();
      
      // Firebase 계정 삭제
      await user.delete();
      
      _logger.warning('계정 삭제 완료');
    } catch (e) {
      _logger.error('계정 삭제 오류', e);
      rethrow;
    }
  }

  /// Firestore에 사용자 프로필 생성
  static Future<void> _createUserProfile(User user, String displayName) async {
    try {
      // 슈퍼관리자 권한 확인
      bool isSuperAdmin = user.email == 'tkandpf26@gmail.com';
      
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        // 권한 관리
        'role': isSuperAdmin ? 'super_admin' : 'user',
        'permissions': isSuperAdmin ? [
          'user_management',
          'system_admin',
          'data_export',
          'analytics_view',
          'settings_manage'
        ] : ['basic_access'],
        // Hanoa 특화 필드들
        'platform': 'hanoa_flutter_app',
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _logger.info('사용자 프로필 생성/업데이트 완료: ${user.email} (슈퍼관리자: $isSuperAdmin)');
    } catch (e) {
      _logger.error('사용자 프로필 생성 오류', e);
      rethrow;
    }
  }

  /// 사용자 프로필 가져오기
  static Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      _logger.error('사용자 프로필 조회 오류', e);
      return null;
    }
  }

  /// 현재 사용자의 권한 확인
  static Future<bool> hasPermission(String permission) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final doc = await getUserProfile(user.uid);
      if (doc == null || !doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      final permissions = data?['permissions'] as List<dynamic>?;
      
      return permissions?.contains(permission) ?? false;
    } catch (e) {
      _logger.error('권한 확인 오류', e);
      return false;
    }
  }

  /// 슈퍼관리자 권한 확인
  static Future<bool> isSuperAdmin() async {
    return await hasPermission('system_admin');
  }

  /// 사용자 역할 확인
  static Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await getUserProfile(user.uid);
      if (doc == null || !doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      return data?['role'] as String?;
    } catch (e) {
      _logger.error('사용자 역할 조회 오류', e);
      return null;
    }
  }

  /// 에러 메시지 한글화
  static String getLocalizedErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return '사용자를 찾을 수 없습니다.';
        case 'wrong-password':
          return '비밀번호가 틀렸습니다.';
        case 'user-disabled':
          return '비활성화된 계정입니다.';
        case 'too-many-requests':
          return '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.';
        case 'network-request-failed':
          return '네트워크 연결을 확인해주세요.';
        case 'email-already-in-use':
          return '이미 사용 중인 이메일입니다.';
        case 'weak-password':
          return '비밀번호가 너무 약합니다.';
        case 'invalid-email':
          return '유효하지 않은 이메일 주소입니다.';
        default:
          return error.message ?? '인증 오류가 발생했습니다.';
      }
    }
    return error.toString();
  }
}