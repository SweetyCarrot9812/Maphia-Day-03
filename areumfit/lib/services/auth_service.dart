import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 사용자 로그인 여부 확인
  bool get isLoggedIn => _auth.currentUser != null;

  // Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final credential = await _auth.signInWithPopup(googleProvider);
        final user = credential.user;
        if (user != null && (credential.additionalUserInfo?.isNewUser ?? false)) {
          await _createUserProfile(user, user.displayName ?? (user.email ?? 'User'));
        }
        return credential;
      } else {
        // 데스크탑(Windows/macOS) 미지원 가드
        if (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS) {
          throw UnsupportedError('Google Sign-In is supported on Web/Android/iOS only.');
        }
        GoogleSignIn googleSignIn;
        if (defaultTargetPlatform == TargetPlatform.android) {
          final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
          googleSignIn = GoogleSignIn(
            scopes: const ['email'],
            serverClientId: webClientId,
          );
        } else {
          final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
          googleSignIn = GoogleSignIn(
            scopes: const ['email'],
            clientId: iosClientId,
          );
        }
        final GoogleSignInAccount? gUser = await googleSignIn.signIn();
        if (gUser == null) {
          return null; // 사용자가 취소
        }
        final GoogleSignInAuthentication gAuth = await gUser.authentication;
        if (gAuth.idToken == null) {
          throw FirebaseAuthException(
            code: 'invalid-configuration',
            message: 'Google idToken missing. Set GOOGLE_WEB_CLIENT_ID/GOOGLE_IOS_CLIENT_ID in .env or add google-services files.',
          );
        }
        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        final credential = await _auth.signInWithCredential(oauthCredential);
        final user = credential.user;
        if (user != null && (credential.additionalUserInfo?.isNewUser ?? false)) {
          await _createUserProfile(user, user.displayName ?? (user.email ?? 'User'));
        }
        return credential;
      }
    } catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 로그인
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 회원가입
  Future<UserCredential?> signUpWithEmail(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 프로필 업데이트
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        
        // Firestore에 사용자 정보 저장
        await _createUserProfile(userCredential.user!, displayName);
      }

      return userCredential;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Firestore에 사용자 프로필 생성
  Future<void> _createUserProfile(User user, String displayName) async {
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
        // AreumFit 특화 필드들
        'fitnessLevel': 'beginner', // beginner, intermediate, advanced
        'goals': [], // 운동 목표 리스트
        'preferredWorkoutTypes': [], // 선호 운동 타입
        'height': null,
        'weight': null,
        'age': null,
        'platform': 'areumfit',
      }, SetOptions(merge: true));
      
      print('✅ 사용자 프로필 생성/업데이트 완료: ${user.email} (슈퍼관리자: $isSuperAdmin)');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // Firebase 로그아웃
      await _auth.signOut();
      // Google 세션 로그아웃 (웹 제외)
      if (!kIsWeb) {
        try {
          await GoogleSignIn().signOut();
        } catch (_) {
          // 구글 세션이 없을 수 있음
        }
      }
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정 이메일 발송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  // 사용자 프로필 가져오기
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print('Error getting user profile: $e');
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
      print('Error checking permission: $e');
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
      print('Error getting user role: $e');
      return null;
    }
  }

  // Firebase Auth 에러 메시지 한국어 변환
  String getErrorMessage(String errorCode) {
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
      default:
        return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
}
