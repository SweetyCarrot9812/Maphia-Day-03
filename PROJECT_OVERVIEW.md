---
title: "Hanoa 프로젝트 개요"
date: "2025-09-12"
version: "2.0"
description: "Hanoa 교육 슈퍼앱 생태계 핵심 정보"
---

# Hanoa 교육 슈퍼앱 생태계

## 🏗️ 핵심 패키지

### 현재 활성 프로젝트
- **haneul_tone**: AI 기반 성악 훈련 앱 (Firebase Auth 통합 완료)
- **areumfit**: 피트니스 트레이닝 앱 (Firebase Auth 통합 완료)  
- **clintest_app**: 의료 교육 패키지 (간호사 국시/NCLEX-RN)
- **prime_readers**: 학원 관리 앱 MVP
- **hanoa_flutter_app**: 메인 통합 모바일 앱

### 완성된 데스크톱 앱
- **clintest_flutter_desktop**: 의료 교육 완성 버전
- **lingumo_desktop_flutter**: 언어 학습 완성 버전

## 🔥 Firebase 통합 아키텍처

**프로젝트**: hanoa-97393
**Auth Domain**: hanoa-97393.firebaseapp.com
**슈퍼 어드민**: tkandpf26@gmail.com

### 데이터 플로우
```
메모리 → Isar DB(로컬) → Firebase 동기화
```

### 통합된 AuthService 패턴
```dart
// 모든 패키지 공통
class AuthService extends ChangeNotifier {
  bool isSuperAdmin = user.email == 'tkandpf26@gmail.com';
  // Firestore 프로필 자동 생성
  // 구글 로그인 지원
}
```

## 🎯 개발 철학

> "로컬 우선, Firebase 동기화"
> "각 패키지는 독립적, 통합 인증"
> "AI는 길을 잇고, 전문가가 감독"

## 📋 기술 스택

- **Flutter**: 3.9.0+, Riverpod, Isar DB
- **Firebase**: Auth 4.20.0, Firestore 4.17.5
- **AI**: Gemini, OpenAI, Perplexity direct API
- **Build**: TanStack Table/Form, Magic UI

## 🚀 현재 상태 (2025-09-12)

**✅ 완료:**
- Firebase Auth 통합 (4개 앱)
- 데스크톱 앱 2개 완성
- 슈퍼 어드민 시스템

**🔄 진행 중:**
- Prime Readers MVP 개발
- Hanoa 메인 앱 통합
- 패키지 간 데이터 동기화