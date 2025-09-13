import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
  String? get userId => _auth.currentUser?.uid;
  String? get userName => _auth.currentUser?.displayName;
  String? get userEmail => _auth.currentUser?.email;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      if (kIsWeb) {
        // 웹용 Google 로그인
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final credential = await _auth.signInWithPopup(googleProvider);
        final user = credential.user;
        if (user != null) {
          await _createUserProfile(user, user.displayName ?? (user.email ?? 'User'));
        }
        _setLoading(false);
        notifyListeners();
        return credential;
      } else {
        // 데스크탑(Windows/macOS) 미지원 가드
        if (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS) {
          throw UnsupportedError('Google Sign-In is supported on Android/iOS only.');
        }

        // Google Sign-In 7.1.1 올바른 API 사용
        final googleSignIn = GoogleSignIn();

        final GoogleSignInAccount? gUser = await googleSignIn.signIn();
        if (gUser == null) {
          // 사용자가 로그인을 취소한 경우
          _setLoading(false);
          return null;
        }

        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        if (gAuth.idToken == null) {
          throw FirebaseAuthException(
            code: 'invalid-configuration',
            message: 'Google idToken missing. Check Firebase configuration.',
          );
        }

        final oauthCredential = GoogleAuthProvider.credential(
          idToken: gAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(oauthCredential);
        final user = userCredential.user;
        if (user != null) {
          await _createUserProfile(user, user.displayName ?? (user.email ?? 'User'));
        }
        _setLoading(false);
        notifyListeners();
        return userCredential;
      }
    } catch (e) {
      _setError('Google 로그인 실패: $e');
      _setLoading(false);
      debugPrint('Google 로그인 오류: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 로그인
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('이메일과 비밀번호를 입력해주세요');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('올바른 이메일 형식을 입력해주세요');
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        final idToken = await userCredential.user!.getIdToken();
        await StorageService.setString(StorageService.keyUserId, userCredential.user!.uid);
        await StorageService.setString(StorageService.keyUserEmail, userCredential.user!.email ?? '');
        await StorageService.setString(StorageService.keyUserName, userCredential.user!.displayName ?? '');
        if (idToken != null) {
          await StorageService.setString(StorageService.keyAuthToken, idToken);
        }

        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError('로그인 실패: $e');
      _setLoading(false);
      debugPrint('로그인 오류: $e');
      return false;
    }
  }

  // 이메일/비밀번호 회원가입
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        throw Exception('모든 필드를 입력해주세요');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('올바른 이메일 형식을 입력해주세요');
      }

      if (password.length < 6) {
        throw Exception('비밀번호는 최소 6자 이상이어야 합니다');
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // 사용자 프로필 업데이트
        await userCredential.user!.updateDisplayName(name.trim());
        await _createUserProfile(userCredential.user!, name.trim());

        final idToken = await userCredential.user!.getIdToken();
        await StorageService.setString(StorageService.keyUserId, userCredential.user!.uid);
        await StorageService.setString(StorageService.keyUserEmail, userCredential.user!.email ?? '');
        await StorageService.setString(StorageService.keyUserName, name.trim());
        if (idToken != null) {
          await StorageService.setString(StorageService.keyAuthToken, idToken);
        }

        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError('회원가입 실패: $e');
      _setLoading(false);
      debugPrint('회원가입 오류: $e');
      return false;
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    try {
      _setLoading(true);

      await _auth.signOut();

      // Google Sign-Out
      if (!kIsWeb) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (e) {
          debugPrint('Google 로그아웃 오류 (무시 가능): $e');
        }
      }

      // 로컬 저장소 정리
      await StorageService.remove(StorageService.keyUserId);
      await StorageService.remove(StorageService.keyUserEmail);
      await StorageService.remove(StorageService.keyUserName);
      await StorageService.remove(StorageService.keyAuthToken);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('로그아웃 실패: $e');
      _setLoading(false);
      debugPrint('로그아웃 오류: $e');
      return false;
    }
  }

  // 사용자 프로필 생성
  Future<void> _createUserProfile(User user, String displayName) async {
    try {
      final isSuperAdmin = user.email == 'tkandpf26@gmail.com';

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName,
        'photoURL': user.photoURL,
        'role': isSuperAdmin ? 'super_admin' : 'user',
        'platform': 'clintest',
        'permissions': isSuperAdmin ? ['user_management', 'system_admin'] : ['basic_access'],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('사용자 프로필 생성 오류: $e');
    }
  }

  // 비밀번호 재설정
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      if (email.trim().isEmpty) {
        throw Exception('이메일을 입력해주세요');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('올바른 이메일 형식을 입력해주세요');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('비밀번호 재설정 실패: $e');
      _setLoading(false);
      debugPrint('비밀번호 재설정 오류: $e');
      return false;
    }
  }

  // Auth Token 갱신
  Future<void> refreshAuthToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        if (token != null) {
          await StorageService.setString(StorageService.keyAuthToken, token);
        }
      }
    } catch (e) {
      debugPrint('토큰 갱신 오류: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}