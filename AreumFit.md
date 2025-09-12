# 🏃‍♂️ AreumFit - AI Personal Training Assistant

## 📱 프로젝트 개요
- **앱 이름**: AreumFit (Personal Health+CrossFit Logger & Coach)
- **목적**: AI 기반 개인 헬스/크로스핏 운동 기록 및 코칭 시스템
- **대상자**: Hanoa 사용자 (개인용)
- **플랫폼**: Flutter 앱 + Node.js/Express 백엔드
- **특징**: GPT-5 Standard AI 코치 추천, 점진적 과부하, SRS 기반 운동량 관리
- **개발 완료일**: 2025-09-04

---

## 🏗️ 프로젝트 구조

```
areumfit/                          # Flutter 앱
├── lib/
│   ├── main_simple.dart          # 웹용 간단 버전 (DB 의존성 제거)
│   ├── db/schema.dart            # Drift 데이터베이스 스키마
│   ├── services/
│   │   └── ai_coach_service.dart # GPT-5 Standard 통합 서비스
│   ├── models/                   # 데이터 모델
│   └── utils/                    # 유틸리티 함수
└── pubspec.yaml                  # Flutter 의존성

areumfit-backend/                 # Node.js 백엔드
├── src/
│   ├── server.js                # Express 서버 (포트 3004)
│   ├── auth/auth.js             # JWT 인증
│   ├── models/mongodb.js        # MongoDB 스키마
│   └── routes/                  # API 엔드포인트
│       ├── ai.js               # AI 제안 처리
│       └── sync.js             # 데이터 동기화
├── mongodb_setup.js             # MongoDB 초기 설정
└── package.json                 # Node 의존성
```

---

## 🧠 AI 코치 시스템

### 핵심 AI 모델
- **GPT-5 Standard** (`gpt-5-standard`)
- **API 엔드포인트**: `/ai/generate`
- **예비 모델**: GPT-4o (fallback)

### AI 코치 기능
1. **오늘의 운동 계획**: 개인 기록 분석 후 자동 근육군 선택
2. **운동별 세부 추천**: 
   - 중량(kg), 반복(회), 세트, 휴식(초)
   - RPE (Rate of Perceived Exertion) 예측
   - 점진적 과부하 적용
3. **실시간 대화**: 자연어로 운동 상담 및 조언
4. **개인화 추천**: 최근 2주 운동 기록 기반 분석

### AI 서비스 구조
```dart
class AICoachService {
  // 오늘의 운동 계획 생성
  Future<TodaysWorkoutPlan> generateTodaysWorkout({
    required String userId,
    Map<String, dynamic>? currentCondition,
  });

  // 근육군 자동 추천
  Future<List<String>> recommendMuscleGroups({
    required String userId,
    required List<Map<String, dynamic>> recentWorkouts,
  });

  // 개별 운동 세트 추천
  Future<ExerciseRecommendation> recommendExercise({
    required String exerciseId,
    required String userId,
    required List<Map<String, dynamic>> recentSets,
  });

  // AI 코치와 자연어 대화
  Future<String> chatWithCoach({
    required String userId,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
  });
}
```

---

## 📊 핵심 기능

### 1. 5탭 네비게이션 시스템
- **홈 (추천)**: AI 기반 운동 추천 및 근육군 선택
- **운동 기록**: 세트별 상세 기록 및 1RM 추적
- **캘린더**: 운동 기록 달력 뷰
- **AI 대화**: GPT-5와 실시간 코칭 대화
- **프로필**: 사용자 설정 및 통계

### 2. 스마트 추천 시스템
#### AI 모드
- GPT-5가 자동 근육군 선택
- 개인 기록 분석 기반 운동 추천
- "오늘은 상체 위주로 운동하세요!" 같은 설명 제공
- 추천 이유 표시 (볼륨, 성공률 등)

#### 수동 모드
- 6개 근육군 토글: 가슴, 등, 어깨, 팔, 복근, 다리
- 사용자 직접 선택
- 선택된 근육군에 따른 운동 필터링

### 3. 운동 기록 시스템
- **세트 추적**: 중량(kg), 반복(회), 휴식(초), RPE(1-10)
- **1RM 계산**: Epley, Brzycki, Lombardi 공식 지원
- **볼륨 관리**: MEV/MAV/MRV 기반 주간 볼륨 추적
- **진도 추적**: 점진적 과부하 그래프

### 4. 데이터베이스 시스템
#### Flutter (로컬)
- **Drift ORM**: SQLite 기반
- **6개 테이블**: Exercises, Rules, Sessions, Sets, WodTemplates, Changelog
- **오프라인 지원**: 네트워크 없이도 기록 가능

#### Backend (서버)
- **MongoDB**: 7개 컬렉션
  - `af_users`: 사용자 정보
  - `af_exercises`: 운동 라이브러리
  - `af_rules`: 개인화 규칙
  - `af_sessions`: 운동 세션
  - `af_sets`: 세트별 기록
  - `af_wod_templates`: WOD 템플릿
  - `af_changelog`: 변경 이력

---

## 🔧 기술 스택

### Frontend (Flutter)
```yaml
dependencies:
  flutter_localizations: sdk: flutter
  provider: ^6.1.2              # 상태 관리
  dio: ^5.6.0                   # HTTP 클라이언트
  drift: ^2.18.0                # SQLite ORM
  intl: ^0.20.2                 # 국제화
  flutter_dotenv: ^5.1.0        # 환경 변수
  path_provider: ^2.1.4         # 파일 시스템
  flutter_local_notifications: ^17.2.1  # 알림
```

### Backend (Node.js)
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "jsonwebtoken": "^9.0.2",
    "bcrypt": "^5.1.1",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  }
}
```

### AI 통합
- **OpenAI API**: GPT-5 Standard, GPT-4o
- **환경 변수**: `OPENAI_MODEL=gpt-5-standard`
- **API Base URL**: `http://localhost:3004`

---

## 🚀 현재 상태 (2025-09-04)

### ✅ 구현 완료
- **Flutter 앱**: Chrome에서 완전 동작
- **AI 코치 UI**: 버튼 클릭으로 GPT-5 시뮬레이션
- **근육군 토글**: 수동/AI 모드 전환
- **운동 추천 카드**: 중량/반복/휴식/RPE 표시
- **Backend 서버**: 포트 3004에서 실행 중
- **JWT 인증**: 회원가입/로그인 시스템
- **MongoDB 스키마**: 7개 컬렉션 설계
- **Git 백업**: commit `14b7f7b`

### ⚠️ 연결 필요
- **MongoDB 연결**: 로컬 MongoDB 실행 필요 (현재 ECONNREFUSED)
- **GPT-5 API**: 환경변수에 실제 OPENAI_API_KEY 필요
- **데이터 동기화**: Flutter ↔ Backend 실시간 연동

### 🎯 실행 방법
```bash
# Backend 실행 (포트 3004)
cd areumfit-backend
npm run dev

# Flutter 앱 실행 (Chrome)
cd areumfit
flutter run -t lib/main_simple.dart -d chrome
```

---

## 📋 다음 개발 단계

### 1단계: 인프라 연결
- [ ] MongoDB 로컬 설치 및 실행
- [ ] OpenAI API 키 설정
- [ ] 실제 GPT-5 API 호출 테스트

### 2단계: 데이터 연동
- [ ] Flutter ↔ Backend 실시간 동기화
- [ ] 운동 기록 저장/불러오기
- [ ] 사용자 인증 플로우

### 3단계: 기능 확장
- [ ] 운동 라이브러리 구축 (100+ 운동)
- [ ] 통계 대시보드 (진도 차트)
- [ ] 알림 시스템 (운동 리마인더)

### 4단계: UX 개선
- [ ] 다크 모드 지원
- [ ] 헬스/크로스핏 모드 전환
- [ ] 운동 타이머 기능

### 5단계: 고급 기능
- [ ] 운동 플래너 (주간 계획)
- [ ] 친구 시스템 및 경쟁
- [ ] 영상 가이드 연동

---

## 🎯 운동 과학 기반 설계

### SRS (Spaced Repetition System) 적용
- **개념**: 언어학습의 SRS를 운동에 적용
- **적응**: 성공률 높은 운동은 간격 증가, 실패 운동은 빈도 증가
- **목표**: 최적의 운동 빈도로 효율적 근성장

### 점진적 과부하 (Progressive Overload)
- **1RM 기반**: Epley, Brzycki, Lombardi 공식으로 1RM 추정
- **자동 중량 증가**: 성공률 80% 이상 시 +2.5kg 제안
- **RPE 관리**: 목표 RPE 7-8.5 범위 유지

### 볼륨 관리 시스템
- **MEV** (Minimum Effective Volume): 최소 효과적 볼륨
- **MAV** (Maximum Adaptive Volume): 최대 적응 볼륨  
- **MRV** (Maximum Recoverable Volume): 최대 회복 가능 볼륨
- **AI 추천**: 개인별 볼륨 최적화

---

## 📈 성과 측정 지표

### 운동 성과
- **1RM 증가율**: 월별 주요 운동 1RM 변화
- **볼륨 증가**: 주간 총 볼륨(kg × reps) 추이
- **성공률**: 목표 반복수 달성 비율
- **일관성**: 주간 운동 빈도 유지율

### AI 코치 성과
- **추천 정확도**: 사용자 수용률 및 완료율
- **개인화 수준**: 기록 기반 맞춤화 정도
- **학습 효율**: AI 모델의 개인 적응 속도

---

## 🔮 향후 비전

### 단기 목표 (3개월)
- 개인용 완성도 높은 피트니스 앱
- GPT-5 기반 개인화 코칭 시스템
- 과학적 운동 진도 관리

### 중기 목표 (6개월)
- 다중 사용자 지원
- 운동 영상 가이드 통합
- 영양 관리 기능 추가

### 장기 목표 (1년+)
- 헬스장 관리 시스템 확장
- 트레이너-고객 매칭 플랫폼
- 운동 데이터 분석 서비스

---

## 👥 팀 & 기여자

- **개발**: Claude Code + GPT 협업
- **설계**: AI 기반 운동 과학 적용
- **아키텍처**: Flutter + Node.js + MongoDB
- **AI 통합**: OpenAI GPT-5 Standard

---

---

## 📋 PRD (Product Requirement Document)

### 1. 제품 개요
**한 줄 요약**: AI가 운동과 끼니별 식단(매크로)을 추천·관리해주는 개인 코치 앱

**핵심 가치**: 초보자도 헬스·크로스핏 훈련과 식단을 과학적으로 동시에 관리할 수 있음

**주요 사용자**: 20~40대 헬스/크로스핏 사용자, 다이어트·벌크업 목표를 가진 일반인

### 2. 문제 정의
**사용자 문제**:
- 운동은 해도 어떤 식단을 먹어야 하는지 감이 없음
- 기록은 복잡해서 며칠 지나면 포기함
- 끼니별 영양 균형을 맞추기 힘듦

**비즈니스 문제**:
- 기존 앱은 운동/식단이 따로 존재해 종합 관리 불가
- 사용자 리텐션이 떨어짐 → 구독 수익화 어려움

### 3. 목표
- 앱 설치 후 4주 내 운동 기록 유지율 ≥ 60%
- 월간 운동 추천 수용률 ≥ 70%
- 식단 추천 사용자의 끼니별 매크로 입력 완료율 ≥ 50%

### 4. 핵심 지표 (KPI)
**선행 지표**: AI 추천 수용률, 주간 운동 기록 빈도, 끼니별 매크로 입력률

**결과 지표**: 1RM 증가율, 4주차 운동 지속률, 체중/체지방률 변화

### 5. 기능 목록 (MoSCoW)

#### 🟢 Must
**AI 운동 추천**
- GPT-5가 최근 기록 분석 → 오늘의 운동 카드(근육군+세트/반복/휴식) 제공
- AC: 앱 실행 시 홈 탭에서 오늘 운동 카드 자동 표시
- 연관 KPI: AI 추천 수용률

**운동 기록 시스템**
- 세트별 중량(kg), 반복(회), 휴식(초), RPE 기록 가능
- 1RM 자동 계산(Epley, Brzycki, Lombardi)
- AC: 세트 저장 → DB 반영 → 캘린더에서 조회 가능
- 연관 KPI: 주간 운동 기록 빈도

**캘린더 뷰**
- 월별 달력에서 운동 기록 조회 가능
- 특정 날짜 클릭 시 세션 상세 정보 표시
- AC: 날짜 클릭 → 세트별 상세 기록 확인 가능
- 연관 KPI: 운동 지속률

#### 🟡 Should
**통계 대시보드**
- 주별 총 볼륨(kg × reps), 1RM 추이, 성공률(목표 반복 달성률) 시각화

**운동 알림**
- 지정한 시간에 푸시 알림으로 "오늘 운동하세요" 안내

#### 🔵 Could
**식단 추천 (끼니별 매크로)**
- 목표(벌크업/다이어트)에 따른 하루 권장 칼로리 및 매크로 비율 산출
- 끼니별(아침/점심/저녁/간식) 분배 제안 (기본값: 25/35/30/10 비율)
- AC: 하루 목표와 끼니별 분배표 확인 가능, 각 끼니별 입력 가능
- 연관 KPI: 끼니별 매크로 입력 완료율

**친구 기능**
- 운동 기록 공유 및 경쟁 랭킹

**영상 가이드**
- 운동 방법 시청 가능 (외부 DB 또는 자체 제작)

### 6. 마일스톤
- **M1 (MVP, 2주차)**: AI 운동 추천 + 기록 저장 + 캘린더 조회
- **M2 (Beta, 6주차)**: 통계 대시보드 + 운동 알림
- **M3 (Launch, 10주차)**: 다국어 지원 + 앱 스토어 배포
- **M4 (Nutrition, 14주차)**: 끼니별 매크로 추천 + 입력 UI + 하루 총량 확인

---

**마지막 업데이트**: 2025-09-11  
**프로젝트 상태**: M1 MVP 90% 완료 (Firebase Auth 통합, 캘린더 기능 강화 완료)  
**Firebase 프로젝트**: hanoa-97393