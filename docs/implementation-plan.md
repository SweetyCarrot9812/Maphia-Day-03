# Implementation Plan: 콘서트 예약 플랫폼

## 구현 개요

| 항목 | 내용 |
|------|------|
| 프로젝트명 | Concert Booking Platform |
| 기술 스택 | Next.js 15, TypeScript, Tailwind CSS, Supabase |
| 상태 관리 | Context API + useReducer (Flux 패턴) |
| 예상 파일 수 | ~40개 |
| 예상 소요 시간 | 4-6시간 |

---

## 구현 단계 (Phase)

### Phase 1: 프로젝트 초기화 및 설정
1. Next.js 프로젝트 생성
2. 디렉토리 구조 생성
3. Supabase 연동
4. 타입 정의

### Phase 2: Infrastructure Layer
1. Repository 구현 (concertRepository, seatRepository, bookingRepository)
2. Utils 구현 (validation, format)
3. Constants 정의

### Phase 3: Application Layer (Context)
1. ConcertContext 구현
2. SeatContext 구현
3. BookingContext 구현

### Phase 4: Presentation Layer (Components)
1. Common 컴포넌트 (Header, Button, Input, Loading, ErrorMessage)
2. Concert 컴포넌트 (ConcertCard, ConcertList, ConcertDetail)
3. Seat 컴포넌트 (SeatGrid, SeatButton, SeatLegend, SeatSummary)
4. Booking 컴포넌트 (BookingForm, BookingCard, BookingList)

### Phase 5: Pages (App Router)
1. 홈페이지 (콘서트 목록)
2. 콘서트 상세
3. 좌석 선택
4. 예약 정보 입력
5. 예약 완료
6. 예약 조회

### Phase 6: 테스트 및 배포
1. 기능 테스트
2. 빌드 테스트
3. Vercel 배포

---

## 상세 구현 계획

### Phase 1: 프로젝트 초기화 (30분)

#### 1.1 Next.js 프로젝트 생성
```bash
npx create-next-app@latest concert-booking \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*"

cd concert-booking
```

#### 1.2 패키지 설치
```bash
npm install @supabase/supabase-js
npm install react-hook-form
npm install date-fns
npm install lucide-react
```

#### 1.3 디렉토리 구조 생성
```bash
mkdir -p src/{app,components,contexts,types,lib}
mkdir -p src/components/{common,concerts,seats,booking}
mkdir -p src/lib/{repositories,utils,constants}
mkdir -p src/app/{concerts/[id]/{page,seats},booking/{info,confirmation},bookings}
```

#### 1.4 환경 변수 설정 (.env.local)
```env
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

---

### Phase 2: Infrastructure Layer (1시간)

#### 2.1 타입 정의 (src/types/)

**src/types/concert.ts**
```typescript
export interface Concert {
  id: string;
  title: string;
  artist: string;
  date: string;
  venue: string;
  description: string | null;
  imageUrl: string | null;
  runningTime: number;
  createdAt: string;
  updatedAt: string;
}
```

**src/types/seat.ts**
```typescript
export type SeatGrade = 'VIP' | 'R' | 'S' | 'A';

export interface Seat {
  id: string;
  concertId: string;
  row: number;
  number: number;
  grade: SeatGrade;
  price: number;
  isBooked: boolean;
}
```

**src/types/booking.ts**
```typescript
export interface Booking {
  id: string;
  bookingNumber: string;
  concertId: string;
  seatIds: string[];
  customerName: string;
  customerPhone: string;
  customerEmail: string;
  customerBirthdate: string | null;
  totalAmount: number;
  status: 'confirmed' | 'cancelled';
  createdAt: string;
}

export interface BookingFormData {
  name: string;
  phone: string;
  email: string;
  birthdate?: string;
}
```

#### 2.2 Supabase 클라이언트 (src/lib/supabase/client.ts)
```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
```

#### 2.3 Repository 구현 (src/lib/repositories/)

**concertRepository.ts**
- `fetchAll()`: 모든 콘서트 조회
- `fetchById(id)`: ID로 콘서트 조회

**seatRepository.ts**
- `fetchByConcertId(concertId)`: 콘서트별 좌석 조회
- `updateBooked(seatIds, isBooked)`: 좌석 예약 상태 업데이트

**bookingRepository.ts**
- `create(bookingData)`: 예약 생성
- `fetchAll()`: 모든 예약 조회
- `fetchById(id)`: ID로 예약 조회

#### 2.4 Utils (src/lib/utils/)

**validation.ts**
- `validateName(name)`: 이름 검증
- `validatePhone(phone)`: 전화번호 검증
- `validateEmail(email)`: 이메일 검증
- `validateBirthdate(birthdate)`: 생년월일 검증

**format.ts**
- `formatDate(date)`: 날짜 포맷팅
- `formatCurrency(amount)`: 금액 포맷팅
- `formatPhone(phone)`: 전화번호 포맷팅

#### 2.5 Constants (src/lib/constants/)

**seatGrades.ts**
```typescript
export const SEAT_GRADE_PRICES = {
  VIP: 150000,
  R: 100000,
  S: 70000,
  A: 50000,
} as const;

export const SEAT_GRADE_ROWS = {
  VIP: [1, 2],
  R: [3, 4, 5],
  S: [6, 7, 8, 9, 10],
  A: [11, 12, 13, 14, 15],
} as const;
```

---

### Phase 3: Application Layer - Context (1.5시간)

#### 3.1 ConcertContext (src/contexts/ConcertContext.tsx)

**구현 내용**:
- State: `concerts`, `selectedConcert`, `loading`, `error`
- Actions: `loadConcerts`, `selectConcert`, `clearSelectedConcert`
- Reducer: `concertReducer`
- Provider: `ConcertProvider`
- Hook: `useConcert`

#### 3.2 SeatContext (src/contexts/SeatContext.tsx)

**구현 내용**:
- State: `seats`, `selectedSeatIds`, `loading`, `error`
- Actions: `loadSeats`, `toggleSeat`, `clearSelectedSeats`
- Reducer: `seatReducer`
- Provider: `SeatProvider`
- Hook: `useSeat`
- Derived Data: `selectedSeats`, `totalAmount`, `availableSeats`, `canSelectMore`

#### 3.3 BookingContext (src/contexts/BookingContext.tsx)

**구현 내용**:
- State: `bookings`, `currentBooking`, `loading`, `error`
- Actions: `loadBookings`, `setBookingInfo`, `createBooking`, `clearCurrentBooking`
- Reducer: `bookingReducer`
- Provider: `BookingProvider`
- Hook: `useBooking`
- Derived Data: `upcomingBookings`, `pastBookings`

---

### Phase 4: Presentation Layer - Components (2시간)

#### 4.1 Common Components (src/components/common/)

**Header.tsx**
- 로고, 네비게이션 (콘서트 목록, 예약 조회)

**Button.tsx**
- 재사용 가능한 버튼 컴포넌트
- Props: `children`, `onClick`, `disabled`, `variant`, `size`

**Input.tsx**
- 재사용 가능한 입력 필드
- Props: `label`, `type`, `value`, `onChange`, `error`, `placeholder`

**Loading.tsx**
- 로딩 스피너

**ErrorMessage.tsx**
- 에러 메시지 표시

#### 4.2 Concert Components (src/components/concerts/)

**ConcertCard.tsx**
- Props: `concert: Concert`, `onClick: () => void`
- 콘서트 썸네일, 제목, 아티스트, 날짜, 장소, 가격 표시

**ConcertList.tsx**
- Props: `concerts: Concert[]`
- 콘서트 카드 그리드 레이아웃

**ConcertDetail.tsx**
- Props: `concert: Concert`
- 상세 정보 표시, "좌석 선택하기" 버튼

#### 4.3 Seat Components (src/components/seats/)

**SeatButton.tsx**
- Props: `seat: Seat`, `isSelected: boolean`, `onClick: () => void`
- 좌석 상태별 색상 표시 (예약 가능/완료/선택됨)

**SeatGrid.tsx**
- Props: `seats: Seat[]`, `selectedSeatIds: string[]`, `onToggleSeat: (id) => void`
- 15행 x 10열 좌석 배치도

**SeatLegend.tsx**
- 좌석 상태 범례 (🟢 선택 가능, 🔴 예약 완료, 🟡 선택됨)

**SeatSummary.tsx**
- Props: `selectedSeats: Seat[]`, `totalAmount: number`
- 선택된 좌석 정보 및 총 금액 표시

#### 4.4 Booking Components (src/components/booking/)

**BookingForm.tsx**
- Props: `onSubmit: (data) => void`, `loading: boolean`
- React Hook Form 사용
- 필드: 이름, 전화번호, 이메일, 생년월일

**BookingCard.tsx**
- Props: `booking: Booking`
- 예약 카드 (예약 번호, 콘서트 정보, 좌석, 금액)

**BookingList.tsx**
- Props: `bookings: Booking[]`
- 예약 카드 리스트

---

### Phase 5: Pages (App Router) (1.5시간)

#### 5.1 Root Layout (src/app/layout.tsx)
```typescript
import { ConcertProvider } from '@/contexts/ConcertContext';
import { SeatProvider } from '@/contexts/SeatContext';
import { BookingProvider } from '@/contexts/BookingContext';
import Header from '@/components/common/Header';

export default function RootLayout({ children }) {
  return (
    <html lang="ko">
      <body>
        <ConcertProvider>
          <SeatProvider>
            <BookingProvider>
              <Header />
              <main className="container mx-auto px-4 py-8">
                {children}
              </main>
            </BookingProvider>
          </SeatProvider>
        </ConcertProvider>
      </body>
    </html>
  );
}
```

#### 5.2 홈페이지 (src/app/page.tsx)
- `useConcert()`로 콘서트 목록 가져오기
- `<ConcertList />` 렌더링

#### 5.3 콘서트 상세 (src/app/concerts/[id]/page.tsx)
- `useConcert()`로 선택된 콘서트 가져오기
- `<ConcertDetail />` 렌더링
- "좌석 선택하기" 버튼 클릭 → `/concerts/[id]/seats`로 이동

#### 5.4 좌석 선택 (src/app/concerts/[id]/seats/page.tsx)
- `useSeat()`로 좌석 목록 및 선택 상태 가져오기
- `<SeatGrid />`, `<SeatSummary />` 렌더링
- "예약하기" 버튼 클릭 → `/booking/info`로 이동

#### 5.5 예약 정보 입력 (src/app/booking/info/page.tsx)
- `useBooking()`로 예약 정보 관리
- `<BookingForm />` 렌더링
- "결제하기" 버튼 클릭 → `createBooking()` 호출 → `/booking/confirmation`으로 이동

#### 5.6 예약 완료 (src/app/booking/confirmation/page.tsx)
- `useBooking()`로 생성된 예약 정보 가져오기
- 예약 번호, 콘서트 정보, 좌석 정보, 총 금액 표시
- "예약 조회" 버튼 → `/bookings`
- "홈으로" 버튼 → `/`

#### 5.7 예약 조회 (src/app/bookings/page.tsx)
- `useBooking()`로 모든 예약 내역 가져오기
- `<BookingList />` 렌더링

---

### Phase 6: 스타일링 (Tailwind CSS) (30분)

#### Tailwind 설정 (tailwind.config.ts)
```typescript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6',
        success: '#10b981',
        error: '#ef4444',
        warning: '#f59e0b',
      },
    },
  },
};
```

#### 공통 스타일 패턴
- 카드: `rounded-lg shadow-md p-4 bg-white`
- 버튼: `px-4 py-2 rounded-md font-medium transition`
- 입력 필드: `w-full border border-gray-300 rounded-md px-3 py-2`

---

## 파일 생성 순서

### 1단계: Infrastructure (기반)
```
1. src/types/concert.ts
2. src/types/seat.ts
3. src/types/booking.ts
4. src/types/index.ts
5. src/lib/supabase/client.ts
6. src/lib/repositories/concertRepository.ts
7. src/lib/repositories/seatRepository.ts
8. src/lib/repositories/bookingRepository.ts
9. src/lib/utils/validation.ts
10. src/lib/utils/format.ts
11. src/lib/constants/seatGrades.ts
```

### 2단계: Application (비즈니스 로직)
```
12. src/contexts/ConcertContext.tsx
13. src/contexts/SeatContext.tsx
14. src/contexts/BookingContext.tsx
```

### 3단계: Presentation (UI 컴포넌트)
```
15. src/components/common/Header.tsx
16. src/components/common/Button.tsx
17. src/components/common/Input.tsx
18. src/components/common/Loading.tsx
19. src/components/common/ErrorMessage.tsx
20. src/components/concerts/ConcertCard.tsx
21. src/components/concerts/ConcertList.tsx
22. src/components/concerts/ConcertDetail.tsx
23. src/components/seats/SeatButton.tsx
24. src/components/seats/SeatGrid.tsx
25. src/components/seats/SeatLegend.tsx
26. src/components/seats/SeatSummary.tsx
27. src/components/booking/BookingForm.tsx
28. src/components/booking/BookingCard.tsx
29. src/components/booking/BookingList.tsx
```

### 4단계: Pages (라우트)
```
30. src/app/layout.tsx
31. src/app/page.tsx
32. src/app/concerts/[id]/page.tsx
33. src/app/concerts/[id]/seats/page.tsx
34. src/app/booking/info/page.tsx
35. src/app/booking/confirmation/page.tsx
36. src/app/bookings/page.tsx
```

**총 파일 수**: 36개 (코어 기능)

---

## 품질 보장 체크리스트

### 코드 품질
- [ ] TypeScript 타입 에러 0개
- [ ] ESLint 에러 0개
- [ ] 모든 함수에 타입 정의
- [ ] 하드코딩된 값 없음 (환경변수/constants 사용)

### 기능 완성도
- [ ] 콘서트 목록 조회
- [ ] 콘서트 상세 조회
- [ ] 좌석 선택 (1-4개 제한)
- [ ] 예약 정보 입력 및 검증
- [ ] 예약 생성
- [ ] 예약 조회

### 상태 관리
- [ ] Context API 사용
- [ ] Flux 패턴 구현 (Action → Dispatcher → Store → View)
- [ ] 비즈니스 로직 중앙화
- [ ] 파생 데이터는 계산으로 처리 (useMemo)

### 사용자 경험
- [ ] 로딩 상태 표시
- [ ] 에러 메시지 표시
- [ ] 입력 검증 실시간 피드백
- [ ] 반응형 디자인 (모바일 지원)

### 배포
- [ ] 빌드 성공 (`npm run build`)
- [ ] Vercel 배포 완료
- [ ] 실제 URL에서 모든 기능 정상 작동

---

## 예상 일정

| Phase | 작업 내용 | 예상 시간 |
|-------|----------|-----------|
| 1 | 프로젝트 초기화 | 30분 |
| 2 | Infrastructure Layer | 1시간 |
| 3 | Application Layer (Context) | 1.5시간 |
| 4 | Presentation Layer (Components) | 2시간 |
| 5 | Pages (App Router) | 1.5시간 |
| 6 | 스타일링 및 최적화 | 30분 |
| 7 | 테스트 및 디버깅 | 1시간 |
| 8 | 배포 | 30분 |
| **합계** | | **8-9시간** |

---

## 다음 단계: 구현 시작

모든 설계 문서가 완료되었으므로, 이제 **08. 실행 (Implementation Executor)** 단계로 진행합니다.

```bash
# 구현 명령어 (Agent 08 사용)
@prd.md 참조
@userflow.md 참조
@database.md 참조
@usecases/001-concert-booking.md 참조
@requirement.md 참조
@state-management.md 참조
@implementation-plan.md 참조

---

참조된 문서들을 기반으로 콘서트 예약 플랫폼을 완전히 구현하세요.
- 모두 구현할때까지 멈추지말고 진행하세요.
- type, lint, build 에러가 없음을 보장하세요.
- 절대 하드코딩된 값을 사용하지마세요.
```

---

**문서 버전**: 1.0
**작성일**: 2025-01-16
**다음 단계**: 전체 기능 구현
