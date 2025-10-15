# State Management: Flux Pattern + Context Implementation

## Flux 아키텍처 개요

```
View (Component)
    ↓ 사용자 이벤트 (onClick, onSubmit)
Action Creator (Context 메서드)
    ↓ dispatch(action)
Dispatcher (useReducer)
    ↓ 상태 계산
Store (Context State)
    ↓ 상태 전파
View Re-render
```

**단방향 데이터 흐름 보장**

---

## Context 구조 설계

### 1. ConcertContext

#### State 정의
```typescript
interface ConcertState {
  concerts: Concert[];
  selectedConcert: Concert | null;
  loading: boolean;
  error: string | null;
}

const initialState: ConcertState = {
  concerts: [],
  selectedConcert: null,
  loading: false,
  error: null,
};
```

#### Actions
```typescript
type ConcertAction =
  | { type: 'LOAD_CONCERTS_REQUEST' }
  | { type: 'LOAD_CONCERTS_SUCCESS'; payload: Concert[] }
  | { type: 'LOAD_CONCERTS_FAILURE'; payload: string }
  | { type: 'SELECT_CONCERT'; payload: Concert }
  | { type: 'CLEAR_SELECTED_CONCERT' };
```

#### Reducer (Dispatcher)
```typescript
function concertReducer(state: ConcertState, action: ConcertAction): ConcertState {
  switch (action.type) {
    case 'LOAD_CONCERTS_REQUEST':
      return { ...state, loading: true, error: null };

    case 'LOAD_CONCERTS_SUCCESS':
      return { ...state, concerts: action.payload, loading: false };

    case 'LOAD_CONCERTS_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'SELECT_CONCERT':
      return { ...state, selectedConcert: action.payload };

    case 'CLEAR_SELECTED_CONCERT':
      return { ...state, selectedConcert: null };

    default:
      return state;
  }
}
```

#### Context 값 (외부 API)
```typescript
interface ConcertContextValue {
  // State
  concerts: Concert[];
  selectedConcert: Concert | null;
  loading: boolean;
  error: string | null;

  // Actions
  loadConcerts: () => Promise<void>;
  selectConcert: (concert: Concert) => void;
  clearSelectedConcert: () => void;

  // Derived Data (useMemo)
  availableConcerts: Concert[];
  upcomingConcerts: Concert[];
}
```

#### 데이터 흐름
```
초기화:
  loadConcerts() 호출
    ↓
  dispatch({ type: 'LOAD_CONCERTS_REQUEST' })
    ↓
  concertRepository.fetchAll()
    ↓
  dispatch({ type: 'LOAD_CONCERTS_SUCCESS', payload: concerts })
    ↓
  컴포넌트 리렌더링

콘서트 선택:
  selectConcert(concert) 호출
    ↓
  dispatch({ type: 'SELECT_CONCERT', payload: concert })
    ↓
  컴포넌트 리렌더링
```

---

### 2. SeatContext

#### State 정의
```typescript
interface SeatState {
  seats: Seat[];
  selectedSeatIds: string[];
  loading: boolean;
  error: string | null;
}

const initialState: SeatState = {
  seats: [],
  selectedSeatIds: [],
  loading: false,
  error: null,
};
```

#### Actions
```typescript
type SeatAction =
  | { type: 'LOAD_SEATS_REQUEST' }
  | { type: 'LOAD_SEATS_SUCCESS'; payload: Seat[] }
  | { type: 'LOAD_SEATS_FAILURE'; payload: string }
  | { type: 'TOGGLE_SEAT'; payload: string }
  | { type: 'CLEAR_SELECTED_SEATS' };
```

#### Reducer (Dispatcher)
```typescript
function seatReducer(state: SeatState, action: SeatAction): SeatState {
  switch (action.type) {
    case 'LOAD_SEATS_REQUEST':
      return { ...state, loading: true, error: null };

    case 'LOAD_SEATS_SUCCESS':
      return { ...state, seats: action.payload, loading: false, selectedSeatIds: [] };

    case 'LOAD_SEATS_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'TOGGLE_SEAT': {
      const seatId = action.payload;
      const isSelected = state.selectedSeatIds.includes(seatId);

      return {
        ...state,
        selectedSeatIds: isSelected
          ? state.selectedSeatIds.filter(id => id !== seatId)
          : [...state.selectedSeatIds, seatId],
      };
    }

    case 'CLEAR_SELECTED_SEATS':
      return { ...state, selectedSeatIds: [] };

    default:
      return state;
  }
}
```

#### Context 값 (외부 API)
```typescript
interface SeatContextValue {
  // State
  seats: Seat[];
  selectedSeatIds: string[];
  loading: boolean;
  error: string | null;

  // Actions
  loadSeats: (concertId: string) => Promise<void>;
  toggleSeat: (seatId: string) => void;
  clearSelectedSeats: () => void;

  // Derived Data (useMemo)
  selectedSeats: Seat[];
  totalAmount: number;
  availableSeats: Seat[];
  canSelectMore: boolean;
}
```

#### 비즈니스 로직
```typescript
const toggleSeat = useCallback((seatId: string) => {
  // 1. 이미 선택된 좌석인지 확인
  const isSelected = state.selectedSeatIds.includes(seatId);

  if (!isSelected) {
    // 2. 최대 4개 제한 검증
    if (state.selectedSeatIds.length >= 4) {
      throw new Error('최대 4개까지만 선택할 수 있습니다');
    }

    // 3. 해당 좌석이 예약 가능한지 확인
    const seat = state.seats.find(s => s.id === seatId);
    if (!seat || seat.isBooked) {
      throw new Error('이미 예약된 좌석입니다');
    }
  }

  // 4. Dispatch
  dispatch({ type: 'TOGGLE_SEAT', payload: seatId });
}, [state.seats, state.selectedSeatIds]);
```

#### 데이터 흐름
```
좌석 로드:
  loadSeats(concertId) 호출
    ↓
  dispatch({ type: 'LOAD_SEATS_REQUEST' })
    ↓
  seatRepository.fetchByConcertId(concertId)
    ↓
  dispatch({ type: 'LOAD_SEATS_SUCCESS', payload: seats })
    ↓
  컴포넌트 리렌더링

좌석 선택:
  toggleSeat(seatId) 호출
    ↓
  검증 (최대 4개, 예약 가능 여부)
    ↓
  dispatch({ type: 'TOGGLE_SEAT', payload: seatId })
    ↓
  selectedSeatIds 업데이트
    ↓
  파생 데이터 자동 재계산 (selectedSeats, totalAmount)
    ↓
  컴포넌트 리렌더링
```

---

### 3. BookingContext

#### State 정의
```typescript
interface BookingState {
  bookings: Booking[];
  currentBooking: Partial<BookingFormData> | null;
  loading: boolean;
  error: string | null;
}

const initialState: BookingState = {
  bookings: [],
  currentBooking: null,
  loading: false,
  error: null,
};
```

#### Actions
```typescript
type BookingAction =
  | { type: 'LOAD_BOOKINGS_REQUEST' }
  | { type: 'LOAD_BOOKINGS_SUCCESS'; payload: Booking[] }
  | { type: 'LOAD_BOOKINGS_FAILURE'; payload: string }
  | { type: 'SET_BOOKING_INFO'; payload: Partial<BookingFormData> }
  | { type: 'CREATE_BOOKING_REQUEST' }
  | { type: 'CREATE_BOOKING_SUCCESS'; payload: Booking }
  | { type: 'CREATE_BOOKING_FAILURE'; payload: string }
  | { type: 'CLEAR_CURRENT_BOOKING' };
```

#### Reducer (Dispatcher)
```typescript
function bookingReducer(state: BookingState, action: BookingAction): BookingState {
  switch (action.type) {
    case 'LOAD_BOOKINGS_REQUEST':
      return { ...state, loading: true, error: null };

    case 'LOAD_BOOKINGS_SUCCESS':
      return { ...state, bookings: action.payload, loading: false };

    case 'LOAD_BOOKINGS_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'SET_BOOKING_INFO':
      return { ...state, currentBooking: { ...state.currentBooking, ...action.payload } };

    case 'CREATE_BOOKING_REQUEST':
      return { ...state, loading: true, error: null };

    case 'CREATE_BOOKING_SUCCESS':
      return {
        ...state,
        bookings: [action.payload, ...state.bookings],
        currentBooking: null,
        loading: false,
      };

    case 'CREATE_BOOKING_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'CLEAR_CURRENT_BOOKING':
      return { ...state, currentBooking: null };

    default:
      return state;
  }
}
```

#### Context 값 (외부 API)
```typescript
interface BookingContextValue {
  // State
  bookings: Booking[];
  currentBooking: Partial<BookingFormData> | null;
  loading: boolean;
  error: string | null;

  // Actions
  loadBookings: () => Promise<void>;
  setBookingInfo: (info: Partial<BookingFormData>) => void;
  createBooking: (concertId: string, seatIds: string[]) => Promise<Booking>;
  clearCurrentBooking: () => void;

  // Derived Data (useMemo)
  upcomingBookings: Booking[];
  pastBookings: Booking[];
}
```

#### 비즈니스 로직
```typescript
const createBooking = useCallback(async (
  concertId: string,
  seatIds: string[]
) => {
  // 1. 입력값 검증
  if (!state.currentBooking) {
    throw new Error('예약 정보를 입력해주세요');
  }

  const { name, phone, email, birthdate } = state.currentBooking;

  if (!name || !phone || !email) {
    throw new Error('필수 항목을 입력해주세요');
  }

  // 2. 좌석 선택 확인
  if (seatIds.length === 0) {
    throw new Error('좌석을 선택해주세요');
  }

  // 3. 총 금액 계산 (SeatContext에서 가져오기)
  const { selectedSeats } = useSeat();
  const totalAmount = selectedSeats.reduce((sum, seat) => sum + seat.price, 0);

  // 4. 예약 데이터 생성
  const bookingData = {
    concertId,
    seatIds,
    customerName: name,
    customerPhone: phone,
    customerEmail: email,
    customerBirthdate: birthdate,
    totalAmount,
  };

  // 5. Repository를 통해 예약 생성
  dispatch({ type: 'CREATE_BOOKING_REQUEST' });

  try {
    const booking = await bookingRepository.create(bookingData);
    dispatch({ type: 'CREATE_BOOKING_SUCCESS', payload: booking });
    return booking;
  } catch (error) {
    dispatch({ type: 'CREATE_BOOKING_FAILURE', payload: error.message });
    throw error;
  }
}, [state.currentBooking]);
```

#### 데이터 흐름
```
예약 정보 입력:
  setBookingInfo({ name, phone, email }) 호출
    ↓
  dispatch({ type: 'SET_BOOKING_INFO', payload: { name, phone, email } })
    ↓
  currentBooking 업데이트
    ↓
  컴포넌트 리렌더링

예약 생성:
  createBooking(concertId, seatIds) 호출
    ↓
  입력값 검증
    ↓
  dispatch({ type: 'CREATE_BOOKING_REQUEST' })
    ↓
  bookingRepository.create(bookingData)
    ↓
  성공 시: dispatch({ type: 'CREATE_BOOKING_SUCCESS', payload: booking })
  실패 시: dispatch({ type: 'CREATE_BOOKING_FAILURE', payload: error })
    ↓
  bookings 배열 업데이트, currentBooking 초기화
    ↓
  컴포넌트 리렌더링
```

---

## Context Provider 계층 구조

```typescript
// app/layout.tsx
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <ConcertProvider>
          <SeatProvider>
            <BookingProvider>
              <Header />
              <main>{children}</main>
            </BookingProvider>
          </SeatProvider>
        </ConcertProvider>
      </body>
    </html>
  );
}
```

**계층 순서 이유**:
- ConcertProvider: 최상위 (콘서트 정보는 모든 곳에서 필요)
- SeatProvider: 콘서트 정보 의존 (선택된 콘서트의 좌석)
- BookingProvider: 좌석 정보 의존 (선택된 좌석으로 예약)

---

## 파생 데이터 계산 (Derived Data)

### ConcertContext
```typescript
const availableConcerts = useMemo(
  () => state.concerts.filter(concert => {
    // 예약 가능한 좌석이 있는 콘서트만
    return concert.availableSeats > 0;
  }),
  [state.concerts]
);

const upcomingConcerts = useMemo(
  () => state.concerts
    .filter(concert => new Date(concert.date) > new Date())
    .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()),
  [state.concerts]
);
```

### SeatContext
```typescript
const selectedSeats = useMemo(
  () => state.seats.filter(seat => state.selectedSeatIds.includes(seat.id)),
  [state.seats, state.selectedSeatIds]
);

const totalAmount = useMemo(
  () => selectedSeats.reduce((sum, seat) => sum + seat.price, 0),
  [selectedSeats]
);

const availableSeats = useMemo(
  () => state.seats.filter(seat => !seat.isBooked),
  [state.seats]
);

const canSelectMore = useMemo(
  () => state.selectedSeatIds.length < 4,
  [state.selectedSeatIds]
);
```

### BookingContext
```typescript
const upcomingBookings = useMemo(
  () => state.bookings.filter(booking => {
    // concertDate를 조인하여 비교 (실제로는 concert 정보 포함 필요)
    return new Date(booking.concert.date) > new Date();
  }),
  [state.bookings]
);

const pastBookings = useMemo(
  () => state.bookings.filter(booking => {
    return new Date(booking.concert.date) <= new Date();
  }),
  [state.bookings]
);
```

---

## 컴포넌트에서 사용 방법

### 콘서트 목록
```typescript
// app/page.tsx
'use client';

import { useConcert } from '@/contexts/ConcertContext';
import ConcertList from '@/components/concerts/ConcertList';

export default function HomePage() {
  const { concerts, loading, error, loadConcerts } = useConcert();

  useEffect(() => {
    loadConcerts();
  }, [loadConcerts]);

  if (loading) return <Loading />;
  if (error) return <ErrorMessage message={error} />;

  return <ConcertList concerts={concerts} />;
}
```

### 좌석 선택
```typescript
// app/concerts/[id]/seats/page.tsx
'use client';

import { useSeat } from '@/contexts/SeatContext';
import SeatGrid from '@/components/seats/SeatGrid';

export default function SeatsPage({ params }: { params: { id: string } }) {
  const {
    seats,
    selectedSeatIds,
    selectedSeats,
    totalAmount,
    toggleSeat,
    loadSeats,
  } = useSeat();

  useEffect(() => {
    loadSeats(params.id);
  }, [params.id, loadSeats]);

  return (
    <div>
      <SeatGrid
        seats={seats}
        selectedSeatIds={selectedSeatIds}
        onToggleSeat={toggleSeat}
      />
      <SeatSummary selectedSeats={selectedSeats} totalAmount={totalAmount} />
    </div>
  );
}
```

### 예약 생성
```typescript
// app/booking/info/page.tsx
'use client';

import { useBooking } from '@/contexts/BookingContext';
import { useSeat } from '@/contexts/SeatContext';
import { useConcert } from '@/contexts/ConcertContext';
import BookingForm from '@/components/booking/BookingForm';

export default function BookingInfoPage() {
  const { selectedConcert } = useConcert();
  const { selectedSeatIds, clearSelectedSeats } = useSeat();
  const { setBookingInfo, createBooking, loading } = useBooking();

  const handleSubmit = async (formData: BookingFormData) => {
    setBookingInfo(formData);

    try {
      const booking = await createBooking(selectedConcert!.id, selectedSeatIds);
      clearSelectedSeats();
      router.push(`/booking/confirmation?bookingId=${booking.id}`);
    } catch (error) {
      alert(error.message);
    }
  };

  return <BookingForm onSubmit={handleSubmit} loading={loading} />;
}
```

---

## 최적화 전략

### 1. 불필요한 리렌더링 방지
```typescript
// useCallback으로 액션 함수 메모이제이션
const toggleSeat = useCallback((seatId: string) => {
  // 로직
}, [/* 의존성 */]);

// useMemo로 파생 데이터 메모이제이션
const selectedSeats = useMemo(() => {
  // 계산
}, [seats, selectedSeatIds]);

// React.memo로 컴포넌트 메모이제이션
const SeatButton = React.memo(({ seat, isSelected, onClick }) => {
  // 렌더링
});
```

### 2. Context 분리
- 각 도메인별로 Context 분리 (Concert, Seat, Booking)
- 한 Context의 변경이 다른 Context의 리렌더링을 유발하지 않음

### 3. 선택적 구독
- 필요한 상태만 구독하도록 Context 값 설계
- 예: `const { loading } = useConcert()` - loading만 변경되면 리렌더링

---

## 에러 처리

### Context 레벨
```typescript
try {
  const concerts = await concertRepository.fetchAll();
  dispatch({ type: 'LOAD_CONCERTS_SUCCESS', payload: concerts });
} catch (error) {
  dispatch({ type: 'LOAD_CONCERTS_FAILURE', payload: error.message });
}
```

### 컴포넌트 레벨
```typescript
const { error } = useConcert();

if (error) {
  return <ErrorMessage message={error} />;
}
```

---

## 테스트 전략

### Reducer 테스트
```typescript
describe('concertReducer', () => {
  it('should handle LOAD_CONCERTS_SUCCESS', () => {
    const state = initialState;
    const action = { type: 'LOAD_CONCERTS_SUCCESS', payload: mockConcerts };
    const newState = concertReducer(state, action);

    expect(newState.concerts).toEqual(mockConcerts);
    expect(newState.loading).toBe(false);
  });
});
```

### Context 통합 테스트
```typescript
describe('ConcertContext', () => {
  it('should load concerts', async () => {
    const { result } = renderHook(() => useConcert(), {
      wrapper: ConcertProvider,
    });

    await act(async () => {
      await result.current.loadConcerts();
    });

    expect(result.current.concerts).toHaveLength(3);
  });
});
```

---

**문서 버전**: 1.0
**작성일**: 2025-01-16
**패턴**: Flux Architecture + Context API
**다음 단계**: Implementation Plan 도출
