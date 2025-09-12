import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
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
        // 모바일용 Google 로그인
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          _setLoading(false);
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await _createUserProfile(userCredential.user!, userCredential.user!.displayName ?? 'User');
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
      // 기본 유효성 검사
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('이메일과 비밀번호를 입력해주세요');
      }
      
      // 이메일 형식 검사
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('올바른 이메일 형식을 입력해주세요');
      }
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // 로컬 저장소에도 데이터 저장 (기존 코드와의 호환성을 위해)
      if (userCredential.user != null) {
        await StorageService.saveUserData(
          userId: userCredential.user!.uid,
          authToken: await userCredential.user!.getIdToken(),
          userName: userCredential.user!.displayName ?? 'User',
          userEmail: userCredential.user!.email!,
        );
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 회원가입
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // 기본 유효성 검사
      if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
        throw Exception('모든 필드를 올바르게 입력해주세요');
      }
      
      // 이메일 형식 검사
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('올바른 이메일 형식을 입력해주세요');
      }
      
      // 비밀번호 길이 검사
      if (password.length < 8) {
        throw Exception('비밀번호는 최소 8자 이상이어야 합니다');
      }
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await _createUserProfile(userCredential.user!, name);
        
        // 로컬 저장소에도 데이터 저장
        await StorageService.saveUserData(
          userId: userCredential.user!.uid,
          authToken: await userCredential.user!.getIdToken(),
          userName: name,
          userEmail: email.trim(),
        );
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
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
        // Clintest 특화 필드들
        'medicalLevel': 'student', // student, intern, resident, doctor
        'specialization': null, // 전문 분야
        'institution': null, // 소속 기관
        'licenseNumber': null, // 면허 번호
        'studyPreferences': [], // 학습 선호도
        'platform': 'clintest',
      }, SetOptions(merge: true));
      
      debugPrint('✅ 사용자 프로필 생성/업데이트 완료: ${user.email} (슈퍼관리자: $isSuperAdmin)');
    } catch (e) {
      debugPrint('사용자 프로필 생성 오류: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    _setLoading(true);
    
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
      
      // 로컬 데이터도 삭제
      await StorageService.clearUserData();
      
      _setLoading(false);
      notifyListeners();
      
    } catch (e) {
      _setError('로그아웃 실패: $e');
      _setLoading(false);
    }
  }

  // 프로필 업데이트
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // Firebase Auth 프로필 업데이트
      if (name != null) {
        await user.updateDisplayName(name);
      }
      
      // Firestore 프로필 업데이트
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (name != null) {
        updates['displayName'] = name;
      }
      
      await _firestore.collection('users').doc(user.uid).update(updates);
      
      // 로컬 저장소 업데이트
      if (name != null) {
        await StorageService.setString(StorageService.keyUserName, name);
      }
      if (email != null) {
        await StorageService.setString(StorageService.keyUserEmail, email);
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('프로필 업데이트 실패: $e');
      _setLoading(false);
      return false;
    }
  }

  // 비밀번호 변경
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 기본 유효성 검사
      if (currentPassword.length < 8 || newPassword.length < 8) {
        throw Exception('비밀번호는 8자 이상이어야 합니다');
      }
      if (currentPassword == newPassword) {
        throw Exception('새 비밀번호는 현재 비밀번호와 달라야 합니다');
      }

      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 비밀번호 변경
      await user.updatePassword(newPassword);
      
      _setLoading(false);
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // 계정 삭제
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // Firestore 데이터 삭제
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Firebase Auth 계정 삭제
      await user.delete();
      
      // 로컬 데이터 삭제
      await StorageService.clear();
      
      _setLoading(false);
      notifyListeners();
      return true;
      
    } catch (e) {
      _setError('계정 삭제 실패: $e');
      _setLoading(false);
      return false;
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

  // 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      final token = await user.getIdToken(true); // 강제 갱신
      await StorageService.setString(StorageService.keyAuthToken, token);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _error = error;
  }

  void clearError() {
    _error = null;
    notifyListeners();
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