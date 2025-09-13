---
title: "CLAUDE.md"
date: "2025-09-14"
version: "5.2"
description: "Hanoa 패키지형 슈퍼앱 개발 가이드 - MongoDB 제거 완료 및 개발환경 최신화"
---

# CLAUDE.md

Hanoa 패키지형 슈퍼앱 개발을 위한 Claude Code 핵심 설정입니다.

## 프로젝트 개요

**Hanoa**: Firebase Auth + 로컬 우선 아키텍처 기반의 패키지형 교육 슈퍼앱

### 핵심 구성 요소
- **areumfit**: 피트니스 앱 (Firebase Auth + APK 배포 완료 ✅, GitHub 연동 ✅)
- **haneul_tone**: 성악 패키지 (Firebase Auth 통합 완료 ✅)
- **clintest_app**: 의학/간호학 패키지 (Firebase Auth 통합 완료 ✅)
- **hanoa_flutter_app**: 메인 모바일 앱
- **prime_readers**: 학원 앱 MVP (별도 문서: PRIME_READERS.md)
- **lingumo_desktop_flutter**: 언어 학습 (완성)
- **clintest_flutter_desktop**: 의료 교육 (완성)

## 🔥 핵심 아키텍처

### Firebase Auth 통합 완료 (2025-09-11)
- **프로젝트**: `hanoa-97393`
- **슈퍼 어드민**: `tkandpf26@gmail.com` (모든 앱에서 super_admin 권한)
- **통합 완료**: areumfit, haneul_tone, clintest_app, hanoa_flutter_app
- **구글 로그인**: 모든 앱에서 지원
- **Firestore**: 사용자 프로필 + 권한 관리

### 데이터 저장 전략
```
메모리 → Isar DB(로컬) → Firebase 동기화
```

## 기술 스택

### Flutter
- Flutter 3.35.2, Riverpod, Isar DB
- Firebase Auth 4.20.0, Cloud Firestore 4.17.5
- google_sign_in 6.3.0

### Firebase 설정
```env
# 필수 환경 변수
GEMINI_API_KEY=your_key
OPENAI_API_KEY=your_key
PERPLEXITY_API_KEY=your_key
```

**Firebase Project**: hanoa-97393
- **Auth Domain**: hanoa-97393.firebaseapp.com
- **설정 파일**: lib/firebase_options.dart
- **SHA-1**: 95:DA:9B:D6:DC:70:B9:93:D8:40:5A:20:19:E5:52:B4:29:DF:34:BF

## 🔧 개발 환경 상태 (2025-09-14 검증)

### 설치 완료 도구들
- ✅ **Flutter**: 3.35.2 (최신, 완전 기능)
- ✅ **Dart**: 3.9.0
- ✅ **Node.js**: 22.18.0
- ✅ **Git**: 2.50.1.windows.1
- ✅ **Firebase CLI**: 14.15.2
- ✅ **Vercel CLI**: 47.1.3
- ✅ **Python**: 3.12.10 (Microsoft Store 설치)
- ✅ **Docker Desktop**: 설치됨 (프로세스 실행 중)

### 설치 필요 도구들
- ❌ **Android Studio**: ADB 포함 (Flutter 모바일 개발용)

### 알려진 이슈
- **Docker CLI**: PATH 미반영 상태 (터미널 재시작으로 해결)
- **Python 경로**: `/c/Users/tkand/AppData/Local/Programs/Python/Python312/`

## 🚀 Flutter 개발 환경 최적화

### 개발 모드별 Hot Reload 성능
- **Desktop (Windows)**: 0.5~1초 ⚡⚡⚡ (최고 성능)
- **Android Emulator**: 1~2초 ⚡⚡
- **실제 디바이스**: 1~3초 ⚡⚡

### 권장 개발 워크플로우 (Firebase+Isar 기반)
1. **초기 개발**: Desktop 모드 (`flutter run -d windows`) - 가장 빠른 Hot Reload
2. **데이터 작업**: Isar DB(로컬) → Firebase 자동 동기화
3. **인증**: Firebase Auth (Google Sign-In 지원)
4. **모바일 최적화**: Emulator 모드 (`flutter run -d emulator-5554`)
5. **최종 테스트**: 실제 디바이스

## 개발 명령어

### 기본 Flutter 작업
```bash
flutter clean && flutter pub get
flutter run -d windows            # Desktop (개발용 - 가장 빠름)
flutter run -d emulator-5554      # Android
flutter run -d chrome             # Web
```

### Android 빌드 & 배포
```bash
flutter build apk --debug
flutter analyze                              # 코드 분석
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Firebase Auth 구현 패턴

### 표준 AuthService 구조
```dart
// 모든 앱에서 공통 사용하는 패턴
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 슈퍼 어드민 확인
  bool isSuperAdmin = user.email == 'tkandpf26@gmail.com';
  
  // Firestore 프로필 생성
  await _firestore.collection('users').doc(user.uid).set({
    'email': user.email,
    'role': isSuperAdmin ? 'super_admin' : 'user',
    'platform': 'areumfit', // 각 앱별로 다름
    'permissions': isSuperAdmin ? ['user_management', 'system_admin'] : ['basic_access'],
  }, SetOptions(merge: true));
}
```

### Google Sign-In 설정
- **모든 앱**: google-services.json 필수
- **패키지명 매칭**: applicationId와 package_name 일치 확인
- **SHA 인증서**: 디버그 키스토어 등록

## AI 문제 해결 우선순위

1. **Claude Code Native**: 기본 도구 + SuperClaude Framework
2. **Direct Perplexity**: `python perplexity_direct.py "query"`
3. **Direct Gemini**: 대규모 코드분석용
4. **Direct OpenAI**: 신뢰성 필요시

## 필수 기술 스택
- **테이블**: TanStack Table
- **폼**: TanStack Form  
- **UI**: Magic UI 라이브러리
- **DB**: Isar DB

## 빠른 도구 설치 가이드

### Python 3.12
```bash
# Microsoft Store 방법 (권장)
start ms-windows-store://pdp/?ProductId=9NCVDN91XZQP
```

### Docker Desktop
```bash
# 공식 사이트
start https://docs.docker.com/desktop/setup/install/windows-install/
```

### Android Studio
```bash
# 공식 다운로드
start https://developer.android.com/studio
```

**설치 후 확인**:
```bash
flutter doctor  # 전체 환경 점검
```

## 트러블슈팅 가이드

### Docker CLI 접근 안됨
**증상**: `docker: command not found`
**해결**: 터미널 재시작 또는 시스템 재부팅

### Python 명령어 안됨
**증상**: `python: command not found`
**해결**: 전체 경로 사용
```bash
"/c/Users/tkand/AppData/Local/Programs/Python/Python312/python.exe" --version
```

### PATH 환경변수 문제
**해결**: Claude Code 완전 재시작 후 재시도

### Firebase Auth 오류
```bash
# Firebase 중복 초기화 오류
try {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
} catch (e) {
  print('[INFO] Firebase already initialized: $e');
}
```

### Windows Desktop 호환성
```yaml
# 안전한 의존성 (Firebase 제외)
dependencies:
  flutter_riverpod: ^2.4.9
  hive: ^2.2.3
  go_router: ^12.0.0
  shared_preferences: ^2.2.2
```

### Build 오류 해결
```bash
flutter clean && flutter pub get
# MCP 문제시: Claude Code 재시작
# Python: py -3.12 -m pip install [package]
```

## 프로젝트별 상세 정보

- **HaneulTone**: HANEUL_TONE.md 참조
- **Prime Readers**: PRIME_READERS.md 참조
- **Lingumo**: lingumo_desktop_flutter/ (완성)
- **Clintest**: clintest_flutter_desktop/ (완성)

## 마이그레이션 완료 기록

### Electron → Flutter Desktop
- ✅ Clintest: `Clintest Desktop/` → `clintest_flutter_desktop/`
- ✅ Lingumo: `english-learning-platform/` → `lingumo_desktop_flutter/`

### Firebase Auth 통합
- ✅ 2025-09-11: areumfit, haneul_tone, clintest_app
- ✅ 슈퍼 어드민 시스템: tkandpf26@gmail.com
- ✅ 구글 로그인: 모든 통합 앱에서 작동

### 🔄 MongoDB → Firebase+Isar 전환 완료 (2025-09-14)

#### 제거된 구성요소
- **서비스 파일**: `mongodb_service.dart` (모든 앱에서 제거)
- **백엔드 설정**: `mongodb_setup.js`, `database.py`, `database.js`
- **모델 파일**: `mongodb.js`, `User.js`, `Session.js`
- **의존성**: mongoose, motor, beanie, pymongo

#### 수정된 설정 파일들
- `package.json` - MongoDB 의존성 제거
- `requirements.txt` - Python MongoDB 라이브러리 제거
- `config.py` - MongoDB 환경변수 제거
- `.env.template` - MongoDB 설정 제거

#### 새로운 데이터 전략
- **주 저장소**: Isar DB (로컬 우선)
- **동기화**: Firebase Auth + Firestore
- **백업**: Firebase 자동 동기화

## 주의사항
- Firebase Auth는 동기화용, 주요 데이터는 로컬 우선
- MCP 설정 변경 후 Claude Code 재시작 필수
- Windows Desktop 개발시 Firebase 플러그인 호환성 확인
- 각 앱별 google-services.json 개별 등록 필요

---

*상세 내용은 각 프로젝트별 전용 문서 참조*

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md
