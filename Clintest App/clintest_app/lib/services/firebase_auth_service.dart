import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'storage_service.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String? get userId => currentUser?.uid;
  String? get userName => currentUser?.displayName;
  String? get userEmail => currentUser?.email;
  String? get userPhotoURL => currentUser?.photoURL;

  // 초기화 및 인증 상태 리스너 설정
  void initialize() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // Firebase 사용자 정보를 로컬 저장소에 동기화
        _syncUserDataToLocalStorage();
      } else {
        // 로그아웃 시 로컬 저장소 클리어
        StorageService.clearUserData();
      }
      notifyListeners();
    });
  }

  // Firebase 사용자 정보를 로컬 저장소에 동기화
  Future<void> _syncUserDataToLocalStorage() async {
    final user = currentUser;
    if (user != null) {
      await StorageService.saveUserData(
        userId: user.uid,
        authToken: await user.getIdToken(),
        userName: user.displayName ?? 'Firebase 사용자',
        userEmail: user.email ?? '',
        userPhotoURL: user.photoURL,
      );
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 이메일/비밀번호 로그인
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // 기본 유효성 검사
      if (email.trim().isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: '이메일과 비밀번호를 입력해주세요',
        );
      }
      
      // Firebase 로그인
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        await _syncUserDataToLocalStorage();
        _setLoading(false);
        return true;
      }
      
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
    } catch (e) {
      _setError('로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
    
    _setLoading(false);
    return false;
  }

  // 이메일/비밀번호 회원가입
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // 기본 유효성 검사
      if (email.trim().isEmpty || password.isEmpty || displayName.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-input',
          message: '모든 필드를 입력해주세요',
        );
      }
      
      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: '비밀번호는 6자 이상이어야 합니다',
        );
      }
      
      // Firebase 회원가입
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // 사용자 프로필 업데이트
      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.reload();
      
      if (credential.user != null) {
        await _syncUserDataToLocalStorage();
        _setLoading(false);
        return true;
      }
      
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
    } catch (e) {
      _setError('회원가입 중 오류가 발생했습니다: ${e.toString()}');
    }
    
    _setLoading(false);
    return false;
  }

  // Google 로그인
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Google 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _setLoading(false);
        return false; // 사용자가 로그인을 취소함
      }
      
      // Google 인증 세부정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Firebase 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase로 로그인
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _syncUserDataToLocalStorage();
        _setLoading(false);
        return true;
      }
      
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
    } catch (e) {
      _setError('Google 로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
    
    _setLoading(false);
    return false;
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      // 로컬 저장소 클리어
      await StorageService.clearUserData();
      
    } catch (e) {
      _setError('로그아웃 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 비밀번호 재설정 이메일 보내기
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
    } catch (e) {
      _setError('비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: ${e.toString()}');
    }
    
    _setLoading(false);
    return false;
  }

  // Firebase 에러 메시지를 한국어로 변환
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      case 'invalid-email':
        return '올바른 이메일 형식을 입력해주세요.';
      case 'user-disabled':
        return '비활성화된 사용자 계정입니다.';
      case 'too-many-requests':
        return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '현재 지원하지 않는 로그인 방식입니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      default:
        return e.message ?? '알 수 없는 오류가 발생했습니다.';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}