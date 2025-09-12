---
title: "Firebase Auth 통합 가이드"
date: "2025-09-12" 
version: "2.0"
description: "Hanoa 생태계 Firebase 인증 시스템"
---

# Firebase Auth 통합 가이드

## 🔥 Firebase 프로젝트 설정

**프로젝트 ID**: hanoa-97393
**Auth Domain**: hanoa-97393.firebaseapp.com
**슈퍼 어드민**: tkandpf26@gmail.com

## 👑 슈퍼 어드민 시스템

### 권한 레벨
- **100**: 슈퍼 어드민 (모든 앱 관리)
- **50**: 프로젝트 관리자 (특정 앱)
- **10**: 일반 사용자

### 자동 권한 부여
```dart
bool isSuperAdmin = user.email == 'tkandpf26@gmail.com';
String role = isSuperAdmin ? 'super_admin' : 'user';
List permissions = isSuperAdmin ? 
  ['user_management', 'system_admin'] : 
  ['basic_access'];
```

## 📱 통합된 앱들

### ✅ Firebase Auth 완료
- **haneul_tone**: 성악 훈련 앱
- **areumfit**: 피트니스 앱  
- **clintest_app**: 의료 교육 앱
- **hanoa_flutter_app**: 메인 통합 앱

### 🏗️ AuthService 패턴
```dart
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 구글 로그인
  // Firestore 프로필 생성
  // 권한 관리
}
```

## 🔧 설정 파일

### 필수 파일
- `lib/firebase_options.dart` (각 앱)
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

### SHA-1 인증서
```
95:DA:9B:D6:DC:70:B9:93:D8:40:5A:20:19:E5:52:B4:29:DF:34:BF
```

## 🚀 Quick Start

```bash
# Firebase 초기화 (각 앱에서)
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
);

# 구글 로그인
GoogleSignIn googleSignIn = GoogleSignIn();
GoogleSignInAccount? googleUser = await googleSignIn.signIn();
```