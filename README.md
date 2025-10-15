# 🎵 콘서트 예약 플랫폼

Next.js 15 + TypeScript + Supabase로 구축된 콘서트 예약 시스템

## ✨ 주요 기능

- ✅ 콘서트 목록 조회
- ✅ 콘서트 상세 정보 확인
- ✅ 좌석 선택 (최소 1개, 최대 4개)
- ✅ 예약 정보 입력 및 검증
- ✅ 예약 완료 및 예약 번호 발급
- ✅ 예약 내역 조회

## 🏗️ 기술 스택

- **Frontend**: Next.js 15 (App Router), React 18, TypeScript
- **Styling**: Tailwind CSS
- **State Management**: Context API + useReducer (Flux Pattern)
- **Database**: Supabase (PostgreSQL)
- **Form**: React Hook Form
- **Date**: date-fns
- **Icons**: Lucide React

## 📐 아키텍처

### Flux 패턴 (단방향 데이터 흐름)
```
View (Component) → Action → Dispatcher (useReducer) → Store (Context) → View
```

### 레이어 구조
```
src/
├── app/                 # Pages (App Router)
├── components/          # Presentation Layer
│   ├── common/         # 공통 컴포넌트
│   ├── concerts/       # 콘서트 컴포넌트
│   ├── seats/          # 좌석 컴포넌트
│   └── booking/        # 예약 컴포넌트
├── contexts/            # Application Layer (비즈니스 로직)
│   ├── ConcertContext.tsx
│   ├── SeatContext.tsx
│   └── BookingContext.tsx
├── types/               # Domain Layer (타입 정의)
└── lib/                 # Infrastructure Layer
    ├── repositories/   # 데이터 접근
    ├── utils/          # 유틸리티
    └── constants/      # 상수
```

## 🚀 시작하기

### 1. 패키지 설치
```bash
npm install
```

### 2. Supabase 설정

#### 2.1 Supabase 프로젝트 생성
1. [Supabase](https://supabase.com)에 접속하여 새 프로젝트 생성
2. 프로젝트 URL과 Anon Key를 복사

#### 2.2 데이터베이스 마이그레이션
1. Supabase SQL Editor에서 `supabase/migrations/20250116_initial_schema.sql` 파일 내용 실행
2. 샘플 데이터 자동 생성 확인

#### 2.3 환경 변수 설정
`.env.local` 파일을 수정하여 Supabase 정보 입력:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

### 3. 개발 서버 실행
```bash
npm run dev
```

http://localhost:3000 에서 확인

### 4. 프로덕션 빌드
```bash
npm run build
npm start
```

## 📊 데이터베이스 스키마

### concerts (콘서트)
- 콘서트 기본 정보 (제목, 아티스트, 날짜, 장소)

### seats (좌석)
- 좌석 정보 (15행 x 10열 = 150석/콘서트)
- 좌석 등급: VIP(150,000원), R(100,000원), S(70,000원), A(50,000원)

### bookings (예약)
- 예약 정보 (예약번호, 고객정보, 좌석 배열)

## 🎯 상태 관리 원칙

1. **Context API + useReducer 사용** (Flux 패턴)
2. **비즈니스 로직 중앙화** (Context에서 관리)
3. **최소 상태 원칙** (파생 데이터는 계산)
4. **불변성 유지** (Reducer에서 새 객체 반환)

## 🧪 테스트

```bash
npm run lint        # ESLint 검사
npm run type-check  # TypeScript 타입 검사
npm run build       # 빌드 테스트
```

## 📝 프로젝트 문서

- [PRD](docs/prd.md) - 제품 요구사항 정의서
- [Userflow](docs/userflow.md) - 사용자 플로우
- [Tech Stack](docs/tech-stack.md) - 기술 스택 선정 이유
- [Codebase Structure](docs/codebase-structure.md) - 코드베이스 구조
- [Database](docs/database.md) - 데이터베이스 스키마
- [Usecase](docs/usecases/001-concert-booking.md) - 유스케이스 명세
- [Requirement](docs/requirement.md) - 상태 관리 요구사항
- [State Management](docs/state-management.md) - Flux + Context 상세 설계
- [Implementation Plan](docs/implementation-plan.md) - 구현 계획

## 🔒 보안

- Supabase Row Level Security (RLS) 활성화
- 환경 변수로 민감 정보 관리
- 클라이언트 사이드 입력 검증

## 📄 라이선스

MIT

## 👤 Author

SuperNext Team
