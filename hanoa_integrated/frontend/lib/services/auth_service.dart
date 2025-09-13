import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  // 사용자 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 웹에서는 GoogleAuthProvider.credential()을 직접 사용
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // 웹에서 팝업을 통한 로그인
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        if (userCredential.user != null) {
          // Firestore에 사용자 정보 저장
          await _saveUserToFirestore(userCredential.user!);
          notifyListeners();
          return userCredential;
        }
        return null;
      } else {
        // 모바일/데스크톱에서는 기존 방식 사용
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        await _saveUserToFirestore(userCredential.user!);
        notifyListeners();
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 로그인
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Email Sign-In Error: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 회원가입
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore에 사용자 정보 저장
      await _saveUserToFirestore(userCredential.user!);

      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Email Sign-Up Error: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      if (kIsWeb) {
        // 웹에서는 Firebase Auth만 로그아웃
        await _auth.signOut();
      } else {
        // 모바일/데스크톱에서는 구글 로그인도 함께 로그아웃
        await Future.wait([
          _auth.signOut(),
          _googleSignIn.signOut(),
        ]);
      }
      notifyListeners();
    } catch (e) {
      print('Sign-Out Error: $e');
      rethrow;
    }
  }

  // Firestore에 사용자 정보 저장
  Future<void> _saveUserToFirestore(User user) async {
    try {
      // 슈퍼 어드민 확인
      final bool isSuperAdmin = user.email == 'tkandpf26@gmail.com';

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'role': isSuperAdmin ? 'super_admin' : 'user',
        'platform': 'hanoa_integrated',
        'permissions': isSuperAdmin
            ? ['user_management', 'system_admin', 'content_admin']
            : ['basic_access'],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('사용자 정보 Firestore 저장 완료: ${user.email}');
    } catch (e) {
      print('Firestore 저장 오류: $e');
    }
  }

  // 사용자 프로필 업데이트
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        // Firestore도 업데이트
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        notifyListeners();
      }
    } catch (e) {
      print('Profile Update Error: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password Reset Error: $e');
      rethrow;
    }
  }

  // 사용자 권한 확인
  Future<bool> hasPermission(String permission) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final permissions = List<String>.from(doc.data()?['permissions'] ?? []);
      return permissions.contains(permission) ||
             permissions.contains('system_admin');
    } catch (e) {
      print('Permission Check Error: $e');
      return false;
    }
  }

  // 슈퍼 어드민 확인
  bool get isSuperAdmin => currentUser?.email == 'tkandpf26@gmail.com';
}