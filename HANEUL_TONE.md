---
title: "HANEUL_TONE.md"
date: "2025-09-08"
version: "1.0"
description: "HaneulTone 성악 패키지 전용 개발 가이드"
---

# HaneulTone 프로젝트 가이드

## 현재 상태 (2025-09-08 기준)

```yaml
프로젝트_현황:
  완성도: "기능적으로 완성, 코드 품질 개선 필요"
  코드_분석: "498개 이슈 (에러 54개, 경고 120개, 정보 324개)"
  심각_문제: 
    - "추상 클래스 PitchEngine 구현 누락"
    - "CREPE 엔진 컴파일 에러"
    - "FFT 추정기 구현 미완성"
  품질_이슈:
    - "대량의 debug print문 (324개)"
    - "deprecated withOpacity() 메소드 사용"
    - "미사용 import 및 변수"
  
기술_스택_현황:
  flutter_version: "3.9.0+"
  핵심_엔진: "CREPE-Tiny TensorFlow Lite + 하이브리드 FFT+YIN"
  서비스_레이어: "25개 서비스 완성 (벤치마크, 코칭, 접근성, 내보내기)"
  데이터베이스: "Hive + SQLite 크로스플랫폼"
  의존성: "17개 업데이트 가능 패키지"
```

## v1 고도화 완료 현황 (2025-01-23)

✅ **v1 고도화 완료** (Must/Should/Could 100%)

### 주요 성취
- **하이브리드 피치 엔진**: FFT(40%) + YIN(60%) 융합 시스템
- **AI 자동 벤치마크**: 디바이스 성능 테스트 및 최적 설정 자동 추천  
- **스마트 코칭 카드**: 1분 요약 리포트 + 개인화된 학습 목표
- **완전한 접근성**: 색맹 지원, 진동 피드백, 고대비 모드
- **다중 포맷 내보내기**: CSV/JSON/PNG/HTML 완벽 지원
- **CREPE-Tiny TensorFlow Lite**: 온디바이스 고정밀 피치 감지

### 핵심 구현 파일
- `lib/services/benchmark_service.dart` (1000줄) - AI 성능 테스트
- `lib/services/coaching_service.dart` (944줄) - 스마트 코칭 시스템  
- `lib/services/accessibility_service.dart` (900줄) - 접근성 지원
- `lib/screens/settings_screen.dart` (900줄) - 통합 설정 화면
- `lib/services/export_service.dart` (700줄) - 다중 포맷 내보내기


## 기술 설계 원칙

### 성능 최적화
- **하이브리드 접근**: 단일 알고리즘 한계 극복 (FFT + YIN 융합)
- **온디바이스 AI**: CREPE-Tiny로 실시간 고정밀 피치 감지  
- **적응형 설정**: AI 벤치마크로 디바이스별 최적화

### 사용자 중심 설계  
- **완전한 접근성**: 색맹, 청각장애 등 모든 사용자 고려
- **즉시 피드백**: 1분 요약 코칭 카드로 빠른 개선점 제시
- **데이터 주권**: 완전한 내보내기로 사용자 데이터 통제권 보장

### 확장 가능한 아키텍처
```dart
// 서비스 레이어 분리
- benchmark_service.dart    // 성능 측정
- coaching_service.dart     // AI 코칭  
- accessibility_service.dart // 접근성
- export_service.dart       // 데이터 처리

// 설정 통합 관리
- settings_service.dart     // 통합 설정
- 프로필별 최적화: AI/성능/배터리/품질/커스텀
```

## 문제 해결 및 최적화

### 코드 품질 개선 자동화
```bash
# SuperClaude + test-fixer-coverage-optimizer 협업 패턴
"test agent 가지고 한번 돌려줘"
→ 자동으로 테스트 실행, 실패 수정, 커버리지 80% 달성

# 주요 해결 대상
- 추상 클래스 구현: PitchEngine.estimate, frameSize, hopSize 등
- Deprecated 메소드: withOpacity() → withValues()
- Debug 코드 정리: avoid_print 경고 대량 제거
```

### 개발 환경 최적화 명령어
```bash
# HaneulTone 전용 개발 워크플로우
cd "C:\Users\tkand\Desktop\development\Hanoa\haneul_tone"

# 의존성 및 분석
flutter pub get
flutter analyze  # 498개 이슈 → 목표: 50개 이하

# 테스트 및 커버리지
flutter test --coverage
# 목표: 80% 이상 커버리지 달성

# 빌드 최적화
flutter build apk --debug  # 첫 빌드 ~100초, 후속 ~12초
```

## 문제 해결 우선순위

```yaml
P0_즉시수정:
  - "추상 클래스 PitchEngine 구현 누락 → 컴파일 불가"
  - "핵심 오디오 엔진 에러 → 앱 크래시"
  
P1_당일수정:
  - "Deprecated 메소드 사용 → 향후 호환성 문제"
  - "미사용 import → 빌드 성능 저하"

P2_주간수정:  
  - "Print문 대량 사용 → 프로덕션 부적합"
  - "테스트 커버리지 부족 → 품질 보증 문제"

P3_월간개선:
  - "의존성 업데이트 → 보안 및 성능 향상"
  - "코드 리팩토링 → 유지보수성 개선"
```

## 향후 개발 계획

### v2 고도화 후보 기능  
1. **실시간 협업 모드**: 선생님-학생 실시간 피드백
2. **음성 인식 통합**: 가사-멜로디 동시 분석
3. **클라우드 AI 모델**: 더 정교한 온라인 분석  
4. **소셜 기능**: 연습 기록 공유 및 경쟁
5. **VR/AR 통합**: 몰입형 성악 연습 환경

### 기술 발전 방향
- **더 많은 언어 지원**: 다국어 음성학적 분석
- **장르별 특화**: 클래식, 팝, 오페라 등 맞춤 분석  
- **실시간 스트리밍**: 원격 레슨 지원
- **고급 음향학**: 음색, 비브라토, 포르마멘토 세부 분석