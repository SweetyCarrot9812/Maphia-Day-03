# Maphia Day 03 - 리팩토링 계획서

> 분석 기준일: 2025-10-16
> 프로젝트: 콘서트 예약 플랫폼
> 기술 스택: Next.js 15.5.5, React 18.3.1, TypeScript, Context API + Flux, Supabase

---

## 목차
1. [프로젝트 개요](#프로젝트-개요)
2. [코드 스멜 분류 체계](#코드-스멜-분류-체계)
3. [발견된 코드 스멜](#발견된-코드-스멜)
4. [우선순위 매트릭스](#우선순위-매트릭스)
5. [즉시 실행 권장 작업](#즉시-실행-권장-작업)
6. [중기 개선 계획](#중기-개선-계획)
7. [장기 개선 계획](#장기-개선-계획)

---

## 프로젝트 개요

### 현재 아키텍처
- **패턴**: Repository Pattern + Context API (Flux-like)
- **상태 관리**: 3개 Context (Concert, Seat, Booking)
- **데이터 레이어**: Supabase (PostgreSQL)
- **파일 수**: 53개 TypeScript/React 파일

### 주요 기능
- 콘서트 목록 조회 및 상세
- 좌석 선택 (최대 4개)
- 예약 생성 및 취소
- QR 코드 생성
- 필터링 및 정렬

---

## 코드 스멜 분류 체계

### 긴급도 (Urgency)
- **1-3**: 낮음 (최적화, 스타일)
- **4-6**: 보통 (유지보수성, 가독성)
- **7-8**: 높음 (버그 가능성, 성능)
- **9-10**: 긴급 (보안, 치명적 버그)

### 복잡도 (Complexity)
- **1-3**: 낮음 (1-2시간)
- **4-6**: 보통 (반나절-1일)
- **7-8**: 높음 (2-3일)
- **9-10**: 매우 높음 (1주 이상)

---

## 발견된 코드 스멜

### 1. 🔴 긴급 (Urgency: 9-10)

#### CS-001: 하드코딩된 비즈니스 로직 상수
**위치**: `SeatContext.tsx:103`, `SeatGrid.tsx:11-12`

```typescript
// 현재 코드
if (state.selectedSeatIds.length >= 4) // Context에서
const ROWS = 15; // Component에서
const COLS = 10;
```

**문제점**:
- 좌석 선택 제한(4개), 그리드 크기(15x10)가 하드코딩
- 콘서트마다 다른 좌석 구성 불가능
- 비즈니스 요구사항 변경 시 코드 수정 필요

**영향**:
- 긴급도: **9** (비즈니스 유연성 제한)
- 복잡도: **5** (DB 스키마 + Context 수정)
- 테스트 가능: ✅ (단위 테스트 가능)

**리팩토링 방향**:
```typescript
// Concert 타입에 메타데이터 추가
interface Concert {
  // ... 기존 필드
  max_seats_per_booking: number; // 예약당 최대 좌석
  seat_layout: {
    rows: number;
    columns: number;
  };
}

// Context에서 동적 검증
const maxSeats = selectedConcert?.max_seats_per_booking || 4;
if (state.selectedSeatIds.length >= maxSeats) { ... }
```

---

#### CS-002: 에러 처리의 일관성 부재
**위치**: 전역 (Repositories, Contexts, Components)

```typescript
// 패턴 1: throw Error
throw new Error('이미 예약된 좌석입니다');

// 패턴 2: alert
alert(err instanceof Error ? err.message : '오류');

// 패턴 3: 무시
catch (error) { /* 로깅 없음 */ }
```

**문제점**:
- 에러 처리 방식 3가지 혼재
- 사용자 경험 일관성 부족
- 에러 로깅/모니터링 불가능
- 국제화(i18n) 불가능

**영향**:
- 긴급도: **9** (사용자 경험 + 운영 이슈)
- 복잡도: **6** (전역 에러 핸들러 구축)
- 테스트 가능: ✅ (E2E 테스트 가능)

**리팩토링 방향**:
```typescript
// 1. 에러 타입 정의
class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public severity: 'info' | 'warning' | 'error'
  ) {
    super(message);
  }
}

// 2. Toast 시스템 구축
const { showToast } = useToast();
showToast({ type: 'error', message: error.message });

// 3. Error Boundary 추가
<ErrorBoundary fallback={<ErrorFallback />}>
  {children}
</ErrorBoundary>

// 4. 중앙 에러 핸들러
function handleError(error: unknown, context?: string) {
  const appError = normalizeError(error);
  logger.error(appError, { context });
  showToast({ type: appError.severity, message: appError.message });
}
```

---

#### CS-003: N+1 쿼리 문제
**위치**: `bookingRepository.ts:62-76`

```typescript
// 현재: 각 예약마다 개별 쿼리
const bookingsWithSeats = await Promise.all(
  (data || []).map(async (item) => {
    const { data: seats } = await supabase
      .from('seats')
      .select('row, number, grade')
      .in('id', item.seat_ids); // N번 실행
    return { ...item, seats };
  })
);
```

**문제점**:
- 100개 예약 → 101개 쿼리 실행
- 페이지 로드 시간 선형 증가
- 데이터베이스 부하

**영향**:
- 긴급도: **8** (성능 저하)
- 복잡도: **4** (쿼리 최적화)
- 테스트 가능: ✅ (성능 테스트 가능)

**리팩토링 방향**:
```typescript
// 개선 1: 단일 쿼리로 통합
async fetchAll(): Promise<BookingWithConcert[]> {
  // 1. 모든 예약 조회
  const { data: bookings } = await supabase
    .from('bookings')
    .select('*, concert:concerts(title, date, venue, image_url)')
    .order('created_at', { ascending: false });

  // 2. 모든 seat_ids 추출
  const allSeatIds = bookings.flatMap(b => b.seat_ids);

  // 3. 단일 쿼리로 모든 좌석 조회
  const { data: allSeats } = await supabase
    .from('seats')
    .select('id, row, number, grade')
    .in('id', allSeatIds);

  // 4. 메모리에서 매핑
  const seatMap = new Map(allSeats.map(s => [s.id, s]));
  return bookings.map(booking => ({
    ...booking,
    seats: booking.seat_ids.map(id => seatMap.get(id)).filter(Boolean)
  }));
}
```

---

### 2. 🟡 높음 (Urgency: 7-8)

#### CS-004: Context 간 의존성 결합
**위치**: `BookingContext.tsx:130-167`

```typescript
// BookingContext가 SeatContext 상태에 암묵적 의존
const createBooking = useCallback(async (
  concertId: string,
  seatIds: string[], // 외부에서 주입받지만 검증 로직 중복
  totalAmount: number
) => {
  if (seatIds.length === 0) { // SeatContext에도 동일 검증 존재
    throw new Error('좌석을 선택해주세요');
  }
  // ...
}, [state.currentBooking]);
```

**문제점**:
- Context 간 책임 경계 모호
- 검증 로직 중복
- 리팩토링 시 영향 범위 예측 어려움

**영향**:
- 긴급도: **7** (유지보수성)
- 복잡도: **7** (아키텍처 재설계)
- 테스트 가능: ✅ (통합 테스트 필요)

**리팩토링 방향**:
```typescript
// 옵션 1: Facade 패턴
function useBookingFlow() {
  const concert = useConcert();
  const seat = useSeat();
  const booking = useBooking();

  return {
    selectConcert: concert.selectConcert,
    toggleSeat: seat.toggleSeat,
    createBooking: async () => {
      // 통합 검증 로직
      validateBookingFlow(concert, seat, booking);
      return booking.createBooking(
        concert.selectedConcert!.id,
        seat.selectedSeatIds,
        seat.totalAmount
      );
    }
  };
}

// 옵션 2: Redux/Zustand로 마이그레이션 (장기)
```

---

#### CS-005: 비동기 상태 경쟁 조건
**위치**: `SeatsPage.tsx:25-34`, `ConcertContext.tsx:109-111`

```typescript
// useEffect 의존성 배열에 함수 포함
useEffect(() => {
  loadConcerts(); // 재생성 시마다 실행
}, [loadConcerts]);

// useCallback 의존성 없음
const loadConcerts = useCallback(async () => {
  // ...
}, []); // 빈 배열
```

**문제점**:
- useCallback의 빈 의존성 배열 → stale closure
- 페이지 전환 시 경쟁 조건 가능
- 메모리 누수 위험 (컴포넌트 언마운트 후 상태 업데이트)

**영향**:
- 긴급도: **8** (런타임 버그 가능성)
- 복잡도: **3** (cleanup 함수 추가)
- 테스트 가능: ⚠️ (E2E로만 재현 가능)

**리팩토링 방향**:
```typescript
useEffect(() => {
  let cancelled = false;

  const loadData = async () => {
    try {
      const data = await loadSeats(concertId);
      if (!cancelled) {
        // 상태 업데이트
      }
    } catch (error) {
      if (!cancelled) {
        setError(error);
      }
    }
  };

  loadData();

  return () => {
    cancelled = true; // cleanup
  };
}, [concertId]); // 함수가 아닌 값 의존
```

---

#### CS-006: 타입 안정성 부족
**위치**: `BookingWithConcert` 타입, Repository 반환 타입

```typescript
// 선택적 필드로 인한 런타임 체크 필요
export interface BookingWithConcert extends Booking {
  concert?: { // optional
    title: string;
    date: string;
    venue: string;
    image_url: string | null;
  };
  seats?: Array<{ ... }>; // optional
}

// 사용처에서 매번 체크
if (booking.concert && new Date(booking.concert.date) > new Date())
```

**문제점**:
- 타입이 실제 런타임 구조를 보장하지 못함
- null/undefined 체크 반복
- 타입스크립트 이점 상실

**영향**:
- 긴급도: **7** (타입 안정성)
- 복잡도: **5** (타입 재설계)
- 테스트 가능: ✅ (컴파일 타임 체크)

**리팩토링 방향**:
```typescript
// Result 타입 도입
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

// Repository 반환 타입 명확화
async fetchAll(): Promise<Result<BookingWithConcert[]>> {
  try {
    const data = await /* query */;

    // 런타임 검증
    const validated = data.map(item => {
      if (!item.concert) {
        throw new Error(`Booking ${item.id} missing concert`);
      }
      return item as RequiredBookingWithConcert;
    });

    return { success: true, data: validated };
  } catch (error) {
    return { success: false, error };
  }
}

// 타입 가드 추가
type RequiredBookingWithConcert = Booking & {
  concert: NonNullable<BookingWithConcert['concert']>;
  seats: NonNullable<BookingWithConcert['seats']>;
};

function hasRequiredData(b: BookingWithConcert): b is RequiredBookingWithConcert {
  return !!b.concert && !!b.seats;
}
```

---

### 3. 🟢 보통 (Urgency: 4-6)

#### CS-007: 매직 넘버 산재
**위치**: 여러 파일

```typescript
// SeatGrid.tsx
<div className="w-10 h-10" /> // 좌석 크기
<div className="w-8 text-center" /> // 행 번호 너비

// BookingCard.tsx (추정)
// 날짜 포맷, 색상 코드 등
```

**영향**:
- 긴급도: **4** (가독성)
- 복잡도: **2** (상수 추출)
- 테스트 가능: ✅

**리팩토링 방향**:
```typescript
// constants/ui.ts
export const SEAT_SIZE = {
  WIDTH: 'w-10',
  HEIGHT: 'h-10',
} as const;

export const LAYOUT = {
  ROW_NUMBER_WIDTH: 'w-8',
  SEAT_GAP: 'gap-1',
} as const;
```

---

#### CS-008: 중복된 날짜 비교 로직
**위치**: `ConcertContext.tsx:97`, `BookingContext.tsx:192,200`

```typescript
// 3곳에서 동일 로직 반복
new Date(concert.date) > new Date()
new Date(booking.concert.date) > new Date()
```

**영향**:
- 긁급도: **5** (DRY 원칙)
- 복잡도: **2** (유틸 함수 추출)
- 테스트 가능: ✅

**리팩토링 방향**:
```typescript
// utils/date.ts
export function isFutureConcert(dateString: string): boolean {
  return new Date(dateString) > new Date();
}

export function isPastConcert(dateString: string): boolean {
  return !isFutureConcert(dateString);
}

// 사용
const upcomingConcerts = concerts.filter(c => isFutureConcert(c.date));
```

---

#### CS-009: 컴포넌트 책임 과다
**위치**: `SeatsPage.tsx`

```typescript
export default function SeatsPage({ params }: SeatsPageProps) {
  // 1. URL 파라미터 처리
  const unwrappedParams = use(params);

  // 2. 데이터 로딩
  useEffect(() => { loadSeats(...) }, [...]);

  // 3. 에러 핸들링
  const [loadError, setLoadError] = useState<string | null>(null);

  // 4. 이벤트 핸들러
  const handleToggleSeat = (seat: Seat) => { ... };
  const handleBooking = () => { ... };

  // 5. 조건부 렌더링
  if (loading) return <Loading />;
  if (error || loadError) return <ErrorMessage ... />;

  // 6. UI 레이아웃
  return ( ... );
}
```

**문제점**:
- 단일 책임 원칙 위반
- 테스트 어려움
- 재사용성 낮음

**영향**:
- 긴급도: **6** (유지보수성)
- 복잡도: **5** (컴포넌트 분리)
- 테스트 가능: ✅

**리팩토링 방향**:
```typescript
// hooks/useSeatsPage.ts
function useSeatsPage(concertId: string) {
  const { seats, selectedSeats, loadSeats, toggleSeat } = useSeat();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadSeats(concertId).catch(setError);
  }, [concertId, loadSeats]);

  const handleToggle = useCallback((seat: Seat) => {
    try {
      toggleSeat(seat.id);
    } catch (err) {
      setError(err.message);
    }
  }, [toggleSeat]);

  return { seats, selectedSeats, error, handleToggle };
}

// components/seats/SeatsPageView.tsx
function SeatsPageView({ seats, selectedSeats, onToggle }: Props) {
  return ( ... ); // Presentational Component
}

// pages/concerts/[id]/seats/page.tsx
export default function SeatsPage({ params }: SeatsPageProps) {
  const concertId = use(params).id;
  const logic = useSeatsPage(concertId);

  if (logic.error) return <ErrorMessage message={logic.error} />;
  return <SeatsPageView {...logic} />;
}
```

---

#### CS-010: 환경 변수 검증 부재
**위치**: `client.ts:4-5`

```typescript
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://placeholder.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'placeholder';
```

**문제점**:
- 빌드 시 플레이스홀더 사용 가능 (운영 환경에서 에러)
- 환경 변수 누락 조기 감지 불가
- 디버깅 어려움

**영향**:
- 긴급도: **6** (운영 리스크)
- 복잡도: **3** (검증 로직 추가)
- 테스트 가능: ✅

**리팩토링 방향**:
```typescript
// lib/config.ts
function getRequiredEnv(key: string): string {
  const value = process.env[key];
  if (!value || value.includes('placeholder')) {
    throw new Error(
      `Missing required environment variable: ${key}\n` +
      `Please set it in .env.local file.`
    );
  }
  return value;
}

export const config = {
  supabase: {
    url: getRequiredEnv('NEXT_PUBLIC_SUPABASE_URL'),
    anonKey: getRequiredEnv('NEXT_PUBLIC_SUPABASE_ANON_KEY'),
  },
} as const;

// client.ts
import { config } from './config';
export const supabase = createClient(
  config.supabase.url,
  config.supabase.anonKey
);
```

---

### 4. 🔵 낮음 (Urgency: 1-3)

#### CS-011: 테스트 코드 부재
**위치**: 프로젝트 전체

**문제점**:
- 테스트 파일 0개
- 리팩토링 안정성 보장 불가
- 회귀 버그 위험

**영향**:
- 긴급도: **3** (장기 품질)
- 복잡도: **8** (테스트 인프라 구축)
- 테스트 가능: N/A

**리팩토링 방향**:
```typescript
// __tests__/lib/repositories/seatRepository.test.ts
import { describe, it, expect, vi } from 'vitest';
import { seatRepository } from '@/lib/repositories/seatRepository';
import { supabase } from '@/lib/supabase/client';

vi.mock('@/lib/supabase/client');

describe('seatRepository', () => {
  it('should fetch seats by concert ID', async () => {
    const mockSeats = [{ id: '1', row: 1, number: 1 }];
    vi.mocked(supabase.from).mockReturnValue({
      select: vi.fn().mockReturnThis(),
      eq: vi.fn().mockReturnThis(),
      order: vi.fn().mockResolvedValue({ data: mockSeats, error: null }),
    });

    const result = await seatRepository.fetchByConcertId('concert-1');
    expect(result).toEqual(mockSeats);
  });
});

// 테스트 커버리지 목표
// - 유틸 함수: 100%
// - Repository: 90%
// - Context: 80%
// - Component: 70%
```

---

#### CS-012: 일관성 없는 명명 규칙
**위치**: 여러 파일

```typescript
// 혼재된 네이밍
interface BookingFormData { ... }     // PascalCase
interface CreateBookingData { ... }   // PascalCase
const concertRepository = { ... };    // camelCase object
export function useSeat() { ... }     // camelCase function
```

**영향**:
- 긴급도: **2** (코드 스타일)
- 복잡도: **3** (Lint 규칙 추가)
- 테스트 가능: ✅

**리팩토링 방향**:
```typescript
// eslint 규칙 추가
{
  "@typescript-eslint/naming-convention": [
    "error",
    { "selector": "interface", "format": ["PascalCase"] },
    { "selector": "typeAlias", "format": ["PascalCase"] },
    { "selector": "variable", "format": ["camelCase", "UPPER_CASE"] },
    { "selector": "function", "format": ["camelCase"] }
  ]
}
```

---

#### CS-013: 주석 부재
**위치**: 복잡한 비즈니스 로직

```typescript
// BookingContext.tsx:130-167
// createBooking 함수의 복잡한 검증 로직에 주석 없음
```

**영향**:
- 긴급도: **2** (문서화)
- 복잡도: **2** (JSDoc 추가)
- 테스트 가능: N/A

**리팩토링 방향**:
```typescript
/**
 * 예약을 생성하고 좌석 상태를 업데이트합니다.
 *
 * @param concertId - 예약할 콘서트 ID
 * @param seatIds - 선택한 좌석 ID 배열 (최대 4개)
 * @param totalAmount - 총 결제 금액
 * @returns 생성된 예약 정보
 * @throws {Error} 필수 정보 누락 시
 * @throws {Error} 좌석 미선택 시
 */
async function createBooking(
  concertId: string,
  seatIds: string[],
  totalAmount: number
): Promise<Booking> {
  // ...
}
```

---

## 우선순위 매트릭스

| ID | 코드 스멜 | 긴급도 | 복잡도 | 우선순위 | 예상 시간 |
|----|-----------|--------|--------|----------|-----------|
| CS-002 | 에러 처리 일관성 | 9 | 6 | **P0** | 1-2일 |
| CS-003 | N+1 쿼리 | 8 | 4 | **P0** | 반나절 |
| CS-005 | 비동기 경쟁 조건 | 8 | 3 | **P0** | 4시간 |
| CS-001 | 하드코딩된 상수 | 9 | 5 | **P1** | 1일 |
| CS-006 | 타입 안정성 | 7 | 5 | **P1** | 1일 |
| CS-004 | Context 결합도 | 7 | 7 | **P2** | 2-3일 |
| CS-010 | 환경 변수 검증 | 6 | 3 | **P2** | 2시간 |
| CS-009 | 컴포넌트 책임 과다 | 6 | 5 | **P2** | 1일 |
| CS-008 | 중복 날짜 로직 | 5 | 2 | **P3** | 1시간 |
| CS-007 | 매직 넘버 | 4 | 2 | **P3** | 1시간 |
| CS-011 | 테스트 코드 부재 | 3 | 8 | **P4** | 1주 |
| CS-012 | 명명 규칙 | 2 | 3 | **P4** | 2시간 |
| CS-013 | 주석 부재 | 2 | 2 | **P4** | 2시간 |

**우선순위 계산식**: `Priority = (Urgency × 1.5 + (10 - Complexity)) / 2`

---

## 즉시 실행 권장 작업

### Week 1: 긴급 버그 수정 (P0)

#### Day 1-2: CS-002 에러 처리 통합
```bash
# 작업 단계
1. Toast 컴포넌트 개선 (이미 존재)
2. useToast 훅 생성
3. ErrorBoundary 추가
4. Repository 에러 핸들링 통일
5. Context에서 alert 제거
6. E2E 테스트 작성

# 성공 지표
- alert 호출 0개
- 모든 에러가 Toast로 표시
- ErrorBoundary로 예외 캐치
```

#### Day 3: CS-003 N+1 쿼리 최적화
```bash
# 작업 단계
1. bookingRepository.fetchAll() 리팩토링
2. 성능 벤치마크 (before/after)
3. 프로파일링으로 검증

# 성공 지표
- 쿼리 수: O(N) → O(1)
- 페이지 로드 시간 50% 단축 (100개 예약 기준)
```

#### Day 4: CS-005 비동기 경쟁 조건 수정
```bash
# 작업 단계
1. useEffect cleanup 함수 추가
2. AbortController 도입 (fetch 취소)
3. React 18 useTransition 활용 검토

# 성공 지표
- Memory Leak 경고 0개
- 빠른 페이지 전환 시 에러 없음
```

**Week 1 예상 결과**:
- 사용자 체감 성능 개선
- 버그 리포트 감소
- 운영 안정성 확보

---

### Week 2: 아키텍처 개선 (P1)

#### Day 5-6: CS-001 비즈니스 로직 동적화
```bash
# 작업 단계
1. Concert 타입 확장 (DB 마이그레이션)
2. SeatContext 로직 수정
3. SeatGrid 동적 크기 지원
4. 기존 데이터 마이그레이션 스크립트

# DB 마이그레이션
ALTER TABLE concerts ADD COLUMN max_seats_per_booking INTEGER DEFAULT 4;
ALTER TABLE concerts ADD COLUMN seat_layout JSONB DEFAULT '{"rows": 15, "columns": 10}';
```

#### Day 7-8: CS-006 타입 안정성 강화
```bash
# 작업 단계
1. Result<T, E> 타입 정의
2. Repository 반환 타입 수정
3. 타입 가드 함수 추가
4. 컴포넌트에서 null 체크 제거

# 성공 지표
- TypeScript strict mode 통과
- 런타임 타입 에러 0개
```

---

### Week 3-4: 리팩토링 마무리 (P2-P3)

#### CS-004, CS-009, CS-010 병렬 진행
- **CS-010 환경 변수 검증**: 즉시 적용 가능 (2시간)
- **CS-008 날짜 유틸**: 간단한 작업 (1시간)
- **CS-007 매직 넘버**: 점진적 개선 (1시간)
- **CS-004 Context 재설계**: 스파이크 작업 필요 (2-3일)
- **CS-009 컴포넌트 분리**: 페이지별 점진적 적용 (1일)

---

## 중기 개선 계획 (1-2개월)

### Phase 1: 테스트 인프라 구축 (CS-011)
```bash
# 기술 스택
- Vitest (단위 테스트)
- Testing Library (React 컴포넌트)
- Playwright (E2E)
- MSW (API 모킹)

# 목표
- 유틸 함수 100% 커버리지
- Repository 90% 커버리지
- CI/CD 파이프라인 연동
```

### Phase 2: 성능 최적화
```typescript
// 1. React.memo 적용
const SeatButton = memo(function SeatButton({ seat, isSelected, onToggle }: Props) {
  // ...
}, (prev, next) => {
  return prev.seat.id === next.seat.id && prev.isSelected === next.isSelected;
});

// 2. Virtual Scrolling (예약 목록)
import { useVirtualizer } from '@tanstack/react-virtual';

// 3. 이미지 최적화
import Image from 'next/image'; // <img> → Next.js Image

// 4. Code Splitting
const BookingListPage = dynamic(() => import('./BookingList'), {
  loading: () => <Loading />,
  ssr: false
});
```

### Phase 3: 접근성 개선
```typescript
// WCAG 2.1 AA 준수
- 키보드 네비게이션 (좌석 선택)
- 스크린 리더 지원 (aria-label)
- 색상 대비 개선 (APCA 기준)
- Focus 관리 (모달, 드롭다운)
```

---

## 장기 개선 계획 (3-6개월)

### 1. 상태 관리 마이그레이션
```typescript
// Context API → Zustand/Jotai
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface ConcertStore {
  concerts: Concert[];
  selectedConcert: Concert | null;
  loadConcerts: () => Promise<void>;
  selectConcert: (concert: Concert) => void;
}

export const useConcertStore = create<ConcertStore>()(
  devtools(
    persist(
      (set, get) => ({
        concerts: [],
        selectedConcert: null,
        loadConcerts: async () => {
          const concerts = await concertRepository.fetchAll();
          set({ concerts });
        },
        selectConcert: (concert) => set({ selectedConcert: concert }),
      }),
      { name: 'concert-store' }
    )
  )
);

// 장점
// - DevTools 지원
// - 성능 최적화 (선택적 리렌더링)
// - 보일러플레이트 감소
// - 로컬 스토리지 영속화
```

### 2. Micro-Frontend 전환
```typescript
// 모놀리식 → 독립 모듈
/apps
  /concert-catalog    # 콘서트 목록/상세
  /booking-engine     # 좌석 선택/예약
  /user-dashboard     # 내 예약 관리
  /admin-panel        # 관리자 페이지

// 공유 라이브러리
/packages
  /ui-components      # 공통 컴포넌트
  /types             # 공유 타입
  /utils             # 유틸 함수
```

### 3. 실시간 기능 추가
```typescript
// Supabase Realtime 구독
useEffect(() => {
  const subscription = supabase
    .channel('seats')
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'seats',
        filter: `concert_id=eq.${concertId}`
      },
      (payload) => {
        // 다른 사용자가 좌석 선택 시 실시간 업데이트
        updateSeatStatus(payload.new);
      }
    )
    .subscribe();

  return () => {
    subscription.unsubscribe();
  };
}, [concertId]);
```

### 4. 국제화 (i18n)
```typescript
// next-intl 도입
import { useTranslations } from 'next-intl';

function BookingForm() {
  const t = useTranslations('BookingForm');

  return (
    <form>
      <label>{t('name')}</label>
      <input placeholder={t('namePlaceholder')} />
      <button>{t('submit')}</button>
    </form>
  );
}

// messages/ko.json
{
  "BookingForm": {
    "name": "이름",
    "namePlaceholder": "홍길동",
    "submit": "예약하기"
  }
}

// messages/en.json
{
  "BookingForm": {
    "name": "Name",
    "namePlaceholder": "John Doe",
    "submit": "Book Now"
  }
}
```

---

## 리팩토링 원칙

### 1. 안전성 우선
```bash
✅ DO
- 기능 추가 전 테스트 작성
- 작은 단위로 리팩토링
- 각 단계마다 커밋
- PR 단위: 300줄 이하

❌ DON'T
- Big Bang 리팩토링
- 테스트 없이 코드 수정
- 여러 이슈를 한 PR에
```

### 2. 점진적 개선 (Strangler Fig Pattern)
```typescript
// 기존 코드 유지하며 새 코드 도입
// v1: 기존 함수
export function fetchBookings() {
  // 기존 로직
}

// v2: 새 함수 (병렬 실행)
export function fetchBookingsV2() {
  // 개선된 로직
}

// v3: 기존 함수를 새 함수로 위임 (Feature Flag)
export function fetchBookings() {
  if (config.useNewBookingFetch) {
    return fetchBookingsV2();
  }
  return /* 기존 로직 */;
}

// v4: 기존 로직 제거
export const fetchBookings = fetchBookingsV2;
```

### 3. 측정 가능한 목표
```typescript
// 리팩토링 전후 메트릭
interface RefactoringMetrics {
  performance: {
    pageLoadTime: number;      // 목표: 2초 → 1초
    timeToInteractive: number;  // 목표: 3초 → 1.5초
    queriesPerPage: number;     // 목표: 101 → 2
  };

  quality: {
    testCoverage: number;       // 목표: 0% → 80%
    typeErrors: number;         // 목표: 50 → 0
    lintWarnings: number;       // 목표: 30 → 0
  };

  maintainability: {
    cyclomaticComplexity: number; // 목표: 15 → 5
    linesPerFile: number;         // 목표: 300 → 150
    coupling: number;             // 목표: 0.8 → 0.3
  };
}
```

---

## 체크리스트

### 즉시 실행 (Week 1)
- [ ] CS-002: Toast 시스템 + ErrorBoundary 구축
- [ ] CS-003: N+1 쿼리 최적화
- [ ] CS-005: useEffect cleanup 추가
- [ ] CS-010: 환경 변수 검증

### 단기 (Week 2-4)
- [ ] CS-001: 비즈니스 상수 동적화 (DB 마이그레이션 포함)
- [ ] CS-006: Result 타입 + 타입 가드
- [ ] CS-008: 날짜 유틸 함수 추출
- [ ] CS-007: UI 상수 파일 생성
- [ ] CS-009: 2개 페이지 컴포넌트 분리

### 중기 (1-2개월)
- [ ] CS-011: Vitest + Testing Library 설정
- [ ] CS-011: 핵심 로직 테스트 커버리지 80%
- [ ] CS-004: Context 재설계 스파이크
- [ ] 성능 최적화 (memo, 이미지, 코드 스플리팅)
- [ ] 접근성 개선 (WCAG AA)

### 장기 (3-6개월)
- [ ] CS-004: Zustand 마이그레이션
- [ ] 실시간 좌석 업데이트
- [ ] i18n 지원 (한/영)
- [ ] Micro-Frontend 전환 검토
- [ ] CS-012, CS-013: 코드 품질 개선

---

## 참고 자료

### 도구
- **Linting**: ESLint + TypeScript ESLint
- **Testing**: Vitest + Testing Library + Playwright
- **Performance**: Lighthouse + React DevTools Profiler
- **Type Safety**: TypeScript strict mode

### 패턴
- Repository Pattern (현재 사용 중)
- Result/Either Pattern (에러 처리)
- Facade Pattern (Context 통합)
- Strangler Fig Pattern (점진적 마이그레이션)

### 메트릭
- Cyclomatic Complexity: < 10
- Test Coverage: > 80%
- Type Coverage: 100%
- Bundle Size: < 200KB (initial)

---

## 마무리

### 핵심 요약
1. **긴급 (P0)**: 에러 처리, N+1 쿼리, 비동기 버그 → **1주**
2. **중요 (P1)**: 하드코딩, 타입 안정성 → **1주**
3. **개선 (P2-P3)**: 리팩토링, 유틸화 → **2주**
4. **장기**: 테스트, 성능, 접근성 → **1-2개월**

### 예상 효과
- **성능**: 페이지 로드 50% 단축
- **안정성**: 런타임 에러 80% 감소
- **생산성**: 새 기능 개발 속도 30% 향상
- **유지보수**: 버그 수정 시간 50% 단축

### 위험 요소
- DB 마이그레이션 실패 (CS-001)
- Context 재설계 시 호환성 (CS-004)
- 테스트 인프라 구축 시간 과소평가 (CS-011)

### 완화 전략
- 마이그레이션 롤백 계획 수립
- Feature Flag로 점진적 적용
- 테스트 우선순위: 핵심 로직 → UI

---

**작성일**: 2025-10-16
**작성자**: Claude (Anthropic)
**검토 필요**: 개발팀 리뷰 + 우선순위 조정
