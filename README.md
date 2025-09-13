# Hanoa 패키지형 슈퍼앱

Firebase Auth + Flutter 통합 교육 플랫폼

## 📱 프로젝트 개요

Hanoa는 Firebase Authentication과 로컬 우선 아키텍처를 기반으로 한 패키지형 교육 슈퍼앱입니다.

### 핵심 구성 요소

- **Clintest App**: 의학/간호학 교육 패키지 (Firebase Auth 통합 완료 ✅)
- **Areumfit**: 피트니스 앱 (APK 배포 완료 ✅)
- **Haneul Tone**: 성악 교육 패키지 (Firebase Auth 통합 완료 ✅)
- **Hanoa Flutter App**: 메인 모바일 앱
- **Lingumo Desktop**: 언어 학습 데스크톱 앱 (완성)
- **Clintest Desktop**: 의료 교육 데스크톱 앱 (완성)

## 🔥 핵심 기능

### Firebase Auth 통합
- **프로젝트**: `hanoa-97393`
- **슈퍼 어드민**: `tkandpf26@gmail.com` (모든 앱에서 super_admin 권한)
- **구글 로그인**: Google Sign-In API 7.1.1 호환
- **Firestore**: 사용자 프로필 + 권한 관리

### 데이터 저장 전략
```
메모리 → Isar DB(로컬) → Firebase 동기화
```

## 🛠 기술 스택

### Flutter
- Flutter 3.35.2
- Riverpod (상태 관리)
- Isar DB (로컬 데이터베이스)
- Firebase Auth 4.20.0
- Cloud Firestore 4.17.5
- Google Sign-In 7.1.1

### 최신 업데이트 (2025-01-15)
- ✅ Google Sign-In API 7.1.1 호환성 수정 완료
- ✅ Firebase Auth 통합 (areumfit, haneul_tone, clintest_app)
- ✅ MongoDB → Firebase+Isar 전환 완료
- ✅ APK 빌드 및 배포 성공

## 🚀 개발 환경

### 설치된 도구들
- Flutter 3.35.2 ✅
- Node.js 22.18.0 ✅
- Firebase CLI 14.15.2 ✅
- Vercel CLI 47.1.3 ✅
- Python 3.12.10 ✅
- Git 2.50.1 ✅

### 개발 명령어

```bash
# Flutter 개발
flutter clean && flutter pub get
flutter run -d windows            # Desktop (가장 빠른 Hot Reload)
flutter run -d emulator-5554      # Android Emulator
flutter build apk --debug         # APK 빌드

# 배포
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## 📁 프로젝트 구조

```
Hanoa/
├── Clintest App/clintest_app/     # 의학 교육 앱
├── areumfit/                      # 피트니스 앱
├── haneul_tone/                   # 성악 교육 앱
├── hanoa_flutter_app/             # 메인 모바일 앱
├── lingumo_desktop_flutter/       # 언어 학습 데스크톱
├── clintest_flutter_desktop/      # 의료 교육 데스크톱
└── areumfit-backend/              # FastAPI 백엔드
```

## 🔐 Firebase 설정

```env
# 환경 변수 (.env)
GEMINI_API_KEY=your_key
OPENAI_API_KEY=your_key
PERPLEXITY_API_KEY=your_key
```

### Firebase Project 정보
- **Project ID**: hanoa-97393
- **Auth Domain**: hanoa-97393.firebaseapp.com
- **SHA-1**: 95:DA:9B:D6:DC:70:B9:93:D8:40:5A:20:19:E5:52:B4:29:DF:34:BF

## 📱 앱별 상태

| 앱 | Firebase Auth | Google 로그인 | 배포 상태 | 플랫폼 |
|---|---|---|---|---|
| Clintest App | ✅ | ✅ | APK 배포됨 | Android |
| Areumfit | ✅ | ✅ | APK 배포됨 | Android |
| Haneul Tone | ✅ | ✅ | 개발 중 | Android |
| Lingumo Desktop | - | - | 완성 | Windows/macOS |
| Clintest Desktop | - | - | 완성 | Windows/macOS |

## 🎯 최근 성과

### Google Sign-In API 7.1.1 호환성 수정 (2025-01-15)
- **문제**: Google Sign-In 7.x API 변경으로 기존 코드 호환성 문제
- **해결**:
  - `GoogleSignIn()` 생성자 → `GoogleSignIn.instance` 싱글톤 패턴
  - `signIn()` → `initialize()` + `authenticate()` 플로우
  - 로그아웃 메서드 업데이트
- **결과**: 성공적인 APK 빌드 및 배포

### MongoDB → Firebase+Isar 전환 완료
- MongoDB Atlas 완전 제거
- Firebase Auth + Firestore로 사용자 관리
- Isar DB로 로컬 데이터 처리
- 성능 및 안정성 개선

## 🔧 문제 해결

### 자주 발생하는 이슈
1. **Google Sign-In 오류**: Firebase 설정 확인 (google-services.json)
2. **빌드 오류**: `flutter clean && flutter pub get`
3. **Hot Reload 느림**: Desktop 모드 사용 권장

### 개발 팁
- Desktop 모드에서 가장 빠른 Hot Reload (0.5초)
- Firebase Auth는 동기화용, 주요 데이터는 로컬 우선
- 각 앱별 google-services.json 개별 등록 필요

## 🤝 기여 방법

1. Fork 프로젝트
2. Feature 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 Push (`git push origin feature/amazing-feature`)
5. Pull Request 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 연락처

- **개발자**: SweetyCarrot9812 & Claude
- **이메일**: tkandpf26@gmail.com
- **GitHub**: https://github.com/SweetyCarrot9812/Clintest-

---

*마지막 업데이트: 2025년 1월 15일*