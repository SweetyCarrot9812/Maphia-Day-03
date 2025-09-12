import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/vocal_types.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialization state for UI gating
  bool _isInitialized = false;
  bool get isInitialized => true;

  // Simple loading state for auth flows
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 사용자 로그인 여부 확인
  bool get isLoggedIn => _auth.currentUser != null;

  // 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    // Firebase Auth는 자동으로 상태를 복원하므로 별도 초기화 불필요
    debugPrint('✅ HaneulTone Firebase Auth 초기화 완료');
  }

  // Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final credential = await _auth.signInWithPopup(googleProvider);
        final user = credential.user;
        if (user != null) {
          await _createUserProfile(user, user.displayName ?? (user.email ?? 'User'));
        }
        return credential;
      } else {
        // 모바일용 Google 로그인
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await _createUserProfile(userCredential.user!, userCredential.user!.displayName ?? 'User');
        }
        return userCredential;
      }
    } catch (e) {
      debugPrint('Google 로그인 오류: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
    String? confirmPassword,
  }) async {
    try {
      // 비밀번호 확인
      if (confirmPassword != null && password != confirmPassword) {
        return {'success': false, 'error': '비밀번호가 일치하지 않습니다.'};
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await _createUserProfile(userCredential.user!, displayName, username: username);
      }

      return {
        'success': true,
        'message': '회원가입이 완료되었습니다!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': '회원가입 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 이메일/비밀번호 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'message': '로그인되었습니다!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': '로그인 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Google 세션도 로그아웃
      if (!kIsWeb) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {
          // 구글 세션이 없을 수 있음
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('로그아웃 오류: $e');
      rethrow;
    }
  }

  // Firestore에 사용자 프로필 생성
  Future<void> _createUserProfile(User user, String displayName, {String? username}) async {
    try {
      // 슈퍼관리자 권한 확인
      bool isSuperAdmin = user.email == 'tkandpf26@gmail.com';
      
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': username ?? user.email?.split('@')[0] ?? 'user',
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
        // HaneulTone 특화 필드들
        'voiceType': VoiceType.unknown.name,
        'skillLevel': DifficultyLevel.beginner.name,
        'isEmailVerified': user.emailVerified,
        'preferences': {},
        'profileImage': user.photoURL,
        'platform': 'haneul_tone',
      }, SetOptions(merge: true));
      
      debugPrint('✅ 사용자 프로필 생성/업데이트 완료: ${user.email} (슈퍼관리자: $isSuperAdmin)');
    } catch (e) {
      debugPrint('사용자 프로필 생성 오류: $e');
      rethrow;
    }
  }

  // 사용자 프로필 업데이트
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'error': '로그인이 필요합니다.'};
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': '프로필이 업데이트되었습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': '프로필 업데이트 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 비밀번호 변경
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'error': '로그인이 필요합니다.'};
    }

    if (newPassword != confirmPassword) {
      return {'success': false, 'error': '새 비밀번호가 일치하지 않습니다.'};
    }

    try {
      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 비밀번호 변경
      await user.updatePassword(newPassword);

      return {'success': true, 'message': '비밀번호가 변경되었습니다.'};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': '비밀번호 변경 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 사용자 프로필 가져오기
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      debugPrint('사용자 프로필 조회 오류: $e');
      return null;
    }
  }

  // 현재 사용자의 권한 확인
  Future<bool> hasPermission(String permission) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final doc = await getUserProfile(user.uid);
      if (doc == null || !doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>?;
      final permissions = data?['permissions'] as List<dynamic>?;
      
      return permissions?.contains(permission) ?? false;
    } catch (e) {
      debugPrint('권한 확인 오류: $e');
      return false;
    }
  }

  // 슈퍼관리자 권한 확인
  Future<bool> isSuperAdmin() async {
    return await hasPermission('system_admin');
  }

  // 사용자 역할 확인
  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await getUserProfile(user.uid);
      if (doc == null || !doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      return data?['role'] as String?;
    } catch (e) {
      debugPrint('사용자 역할 조회 오류: $e');
      return null;
    }
  }

  // Firebase Auth 에러 메시지 한국어 변환
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'email-already-in-use':
        return '이미 사용중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'requires-recent-login':
        return '보안을 위해 다시 로그인해주세요.';
      default:
        return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
}
