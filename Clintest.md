# Clintest - Hanoa 패키지형 슈퍼앱 의학교육 모듈

> **📄 통합 문서**: Hanoa 프로젝트 내 모든 Clintest 관련 정보 통합

## 1. 프로젝트 개요

**이름**: Clintest  
**목표**: 의사와 간호사를 위한 종합 의학 학습 플랫폼  
**현 상태**: 학습 루프 v1 구현 완료 (2025-09-12)  
**과금 철학**: 단일 앱 구독 모델

## 🔥 Clintest 학습 루프 v1 - Obsidian + GPT-5 통합 학습 시스템 (2025-09-12)

### 핵심 아키텍처
**개념은 Obsidian 기록 전용, 문제는 GPT-5 생성/태깅/중복검사, 오답 기반 재출제**

#### 데이터 플로우
```
Obsidian 개념 노트 (로컬) → concept_notes (메타만) 
                     ↓
GPT-5 문제 생성 → 이중 중복검사 → problems 컬렉션
                     ↓  
사용자 학습 → 오답 분석 → 취약 개념 기반 재출제 큐
```

#### 핵심 원칙
- **개념 = Obsidian 전용**: 의학/간호학 개념은 Obsidian에서만 작성하고 정리
- **문제 = AI 전용**: GPT-5가 생성/태깅/품질관리를 완전 자동화
- **학습 = 최소화**: Again/Good 2버튼만으로 SRS 진행
- **재출제 = 지능화**: 오답 기반 취약 개념 자동 감지 및 맞춤형 문제 생성

### 기술 스택 (v1)
- **언어**: TypeScript (백엔드/데스크톱), Node 20+
- **인증**: Firebase Auth (이메일/구글) + 서버 측 verifyIdToken
- **DB**: MongoDB (컬렉션 스키마/인덱스 필수)
- **AI 모델**: 
  - text-embedding-004 (임베딩)
  - gpt-5-standard (문제 생성/태깅)
  - gpt-5-mini (경량 태깅·해설)
- **SRS**: Again/Good 2버튼만
- **보안**: 서버 전용 비밀키, 클라이언트 노출 금지

### 핵심 철학
> "나는 의학/간호학 태그 지도만 깔아주면 된다. AI는 그 위에서 길을 잇고,
> 쉬운 건 nano/mini, 어려운 건 thinking/standard가 맡는다.
> 같은 문제는 하나로, 비슷한 건 그룹으로, 애매한 건 14일 후 자동 정리.
> 점점 더 똑똑해지면서 나는 단순히 문제와 개념만 던져주면 된다."

**AI 우선 설계**: 사람은 콘텐츠 제공, AI가 분류·태깅·품질관리 자동화
**로컬 우선 정책**: 사용자 데이터 완전 소유권, 100% 오프라인 지원

### ✅ 구현 완료 현황 (2025-09-12)
**전체 시스템 구현 완료**: MongoDB 스키마 + API 엔드포인트 + GPT-5 파이프라인 + 중복 검사 시스템
- **MongoDB 스키마**: `backend/scripts/init_clintest_schema.js` (7개 컬렉션, 인덱스 포함)
- **API 라우트**: concepts, problems, learning, obsidian, pipeline (Firebase Auth 지원)
- **Obsidian 브리지**: 파일 감시 + 메타데이터만 동기화
- **GPT-5 파이프라인**: 자동 문제 생성 + 태깅 (30초 주기 처리)
- **중복 검사**: 키해시 + 임베딩 유사도 (코사인 거리 0.08 임계값)
- **SRS 시스템**: Again/Good 2버튼 + 자동 재출제 큐

## 2. 플랫폼 구성

### 2.1 Clintest Flutter App — "손안의 의학 학습"

**역할**: 의사와 간호사를 위한 종합 의학 학습 앱

#### 로컬 우선 아키텍처 (Isar)
**핵심 철학**: "모든 원본 데이터는 클라이언트 로컬에 먼저 저장한다. 서버는 메타데이터/백업/동기화용 2차 저장소로만 사용한다."

- **Core Models**: User, MedicalSubject, MedicalExam, NursingSubject, NursingExam, StudyProgress
- **로컬 우선**: 모든 의학/간호학 콘텐츠 로컬 저장 후 선택적 클라우드 동기화
- **오프라인 완전 지원**: 인터넷 없이도 모든 핵심 기능 사용 가능 (100% 목표)
- **동기화 정책**: 학습 통계와 진도만 서버 저장, 문제/개념 데이터는 로컬 보관

#### 의학/간호학 통합 학습 시스템
```
의학 분야:
├── 의학 기초 (BASIC_MEDICINE) - 해부학, 생리학, 병리학
├── 내과 (INTERNAL_MEDICINE) - 내과 전반
├── 외과 (SURGERY) - 외과 전반
├── 산부인과 (OBSTETRICS) - 산부인과학
├── 소아청소년과 (PEDIATRICS) - 소아과학
├── 정신건강의학과 (PSYCHIATRY) - 정신의학
├── 응급의학 (EMERGENCY) - 응급처치
└── 임상 실습 (CLINICAL) - 실전 케이스

간호학 분야:
├── 성인간호학 (ADULT_NURSING) - 성인 환자 간호
├── 아동간호학 (PEDIATRIC_NURSING) - 아동 간호
├── 모성간호학 (MATERNITY_NURSING) - 모성 간호  
├── 정신간호학 (MENTAL_NURSING) - 정신건강 간호
├── 지역사회간호학 (COMMUNITY_NURSING) - 공중보건 간호
├── 간호관리학 (NURSING_MANAGEMENT) - 간호 관리
├── 기본간호학 (FUNDAMENTAL_NURSING) - 간호 기초
└── 간호법규 (NURSING_LAW) - 간호 관련 법규
```

### 2.2 Clintest Flutter Desktop — "관리실/문제 제작실"

**역할**: 의학(의사용) + 간호학(간호사용) 문제 관리 및 통계 분석

#### 핵심 기능
- **문제 관리**: 의학 분야 8개 + 간호학 분야 8개 문제 입력·편집·분류
- **사용자 관리**: 의사/간호사 학습자 진도 및 통계 추적
- **AI 기능**: 의학/간호학 문제 자동 생성 및 태깅 시스템
- **통계 분석**: 과목별/문제별 정답률 분석 (의사용/간호사용 분리)

## 3. 기술 스택

### 3.1 Flutter App
- **Framework**: Flutter 3.9.0+
- **State Management**: Provider 6.0.0 (ChangeNotifier 패턴)
- **Local Database**: Isar 3.1.0+1 (오프라인 우선)
- **Navigation**: Navigator 2.0 (기본 Flutter 라우팅)
- **HTTP**: http 1.2.2 (서버 통신용)

### 3.2 Clintest Flutter Desktop
- **Runtime**: Flutter Desktop (Windows Native)
- **Database**: MongoDB Atlas (hanoa_hub) via API
- **Backend**: Express.js Server (separate process)
- **AI**: OpenAI GPT-5, Google Gemini
- **Authentication**: Firebase Auth + JWT

### 3.3 AI 시스템

#### 멀티 모델 오케스트레이션
**사용 모델 계층**:
- **GPT-5-nano**: 간단한 텍스트 처리, 기본 분류
- **GPT-5-mini**: 표준 작업, 일반 개념 설명  
- **GPT-5**: 복잡한 추론, 임상 케이스 분석
- **Google Gemini**: 이미지 문제 분석, 다중 모달 처리

#### AI 핵심 기능
- **문제 분석**: AI 기반 의학/간호학 개념 태깅, 난이도 자동 판정
- **학습 추천**: 개인화 학습, 망각 곡선 기반 SRS
- **품질 관리**: 자동 중복 검출, 의학 정보 정확성 검증

## 4. 🔥 Hanoa 통합 아키텍처 (2025-09-11 최신)

### Firebase Auth + MongoDB 통합 현황

#### ✅ Firebase 인증 통합 완료
- **프로젝트**: `hanoa-97393` 
- **앱 패키지**: `com.hanoa.clintest`
- **슈퍼 어드민**: `tkandpf26@gmail.com` (모든 앱 공통)
- **Google 로그인**: 완전 작동
- **SHA-1 인증서**: 등록 완료 (95:DA:9B:D6:DC:70:B9:93:D8:40:5A:20:19:E5:52:B4:29:DF:34:BF)

#### 🔄 MongoDB 중앙 동기화 (설계 완료, 구현 대기)

##### 데이터 흐름 전략
```
사용자 퀴즈 풀이 → Isar DB (로컬) → Firebase (실시간) → MongoDB (중앙 저장)
```

##### MongoDB 스키마 (clintest_learning_data)
```javascript
{
  _id: ObjectId,
  firebase_uid: "string", // Firebase UID (기본키)
  
  // 퀴즈 결과
  quiz_sessions: [{
    session_id: "uuid",
    subject: "anatomy", // 해부학, 생리학 등
    questions_total: 20,
    questions_correct: 18,
    score_percentage: 90,
    time_spent_minutes: 25,
    completed_at: ISODate,
    difficulty_level: "intermediate"
  }],
  
  // 학습 진도 (의학 8개 + 간호학 8개 과목)
  study_progress: {
    subjects: {
      "anatomy": { completion: 85, last_studied: ISODate },
      "physiology": { completion: 60, last_studied: ISODate },
      "adult_nursing": { completion: 75, last_studied: ISODate }
    },
    total_hours: 120,
    streak_days: 15,
    current_level: "advanced"
  },
  
  // 성능 분석
  performance_analytics: {
    strengths: ["cardiovascular", "respiratory"],
    weaknesses: ["endocrine", "nervous"], 
    improvement_rate: 2.3, // % per week
    predicted_pass_rate: 0.89
  }
}
```

## 5. 통합 체크리스트

### ✅ ClintestApp Firebase 통합 (완료)
- [x] Firebase Auth 통합 (hanoa-97393)
- [x] Google 로그인 구현
- [x] Firestore 사용자 프로필 관리
- [x] 슈퍼 어드민 권한 시스템

### 🔄 ClintestApp MongoDB 통합 (구현 대기)  
- [ ] `hanoa_core` 패키지 의존성 추가
- [ ] `ClintestAuthService` 구현
- [ ] `QuizResult` 모델 변환
- [ ] 기존 Isar 데이터 → Hanoa 형식 마이그레이션
- [ ] MongoDB 동기화 테스트
- [ ] 의료 데이터 암호화 확인

### 🎯 통합 효과 (예상)
- **단일 로그인**: Hanoa 계정으로 모든 앱 접근
- **크로스 플랫폼 학습**: AreumFit(건강) + ClintestApp(의학) 연계 분석
- **통합 대시보드**: 의학 학습 + 피트니스 + 성악 + 언어학습 종합 인사이트
- **중앙 데이터**: MongoDB 기반 백업 및 복구 시스템

## 6. 다음 단계

### 🔥 학습 루프 v1 테스트 (준비 완료)
1. **MongoDB 초기화**: `node backend/scripts/init_clintest_schema.js`
2. **서버 실행**: `npm start` (backend 디렉토리에서)
3. **Obsidian 연결**: POST `/api/obsidian/setup-vault`
4. **테스트 문제 생성**: POST `/api/pipeline/test-generation`

### 🔄 Hanoa 통합 (다음 우선순위)
- Firebase Auth + MongoDB 중앙 동기화 구현
- hanoa_core 패키지 통합
- 크로스 플랫폼 학습 인사이트 활성화
- 통합 관리자 대시보드 확장

---

## 결론

Clintest는 **Hanoa 패키지형 슈퍼앱**의 핵심 의학교육 모듈로서 다음 단계가 준비되었습니다:

**✅ 현재 완성**:
- 🎯 의사 + 간호사 통합 학습 플랫폼 (16개 과목 완전 구현)
- 🧠 GPT-5 기반 멀티모델 의학/간호학 개인화 학습 시스템  
- 📱 완전한 로컬 우선 아키텍처 + Firebase Auth 통합
- 🔥 **학습 루프 v1 백엔드 시스템 구현 완료 (2025-09-12)**

**🔄 다음 단계 (Hanoa 통합)**:
- Firebase Auth + MongoDB 중앙 동기화 구현
- hanoa_core 패키지 통합
- 크로스 플랫폼 학습 인사이트 활성화
- 통합 관리자 대시보드 확장

**📈 통합 가치**: 
개별 의학 앱 → **Hanoa 생태계 핵심 모듈**로 진화하여 사용자 경험 통합 + 데이터 중앙화 + 크로스 도메인 학습 분석 제공