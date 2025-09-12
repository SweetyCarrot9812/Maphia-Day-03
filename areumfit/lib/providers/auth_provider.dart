import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth 상태 관리 Provider
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  User? get currentUser => _user ?? _auth.currentUser;
  User? get user => currentUser; // 호환성을 위한 별칭
  bool get isLoggedIn => currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// 이메일로 로그인
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Login failed: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 이메일로 회원가입
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign up failed: ${e.message}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out failed: $e');
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset failed: $e');
      rethrow;
    }
  }
}