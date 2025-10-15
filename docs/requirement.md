# 콘서트 예약 플랫폼 - 상태 관리 요구사항

## 상태 관리 요구사항

### 필수 조건
1. **Context API 사용**: React Context + useReducer로 전역 상태 관리
2. **Flux 패턴 적용**: Action → Dispatcher(Reducer) → Store(Context) → View 단방향 흐름
3. **비즈니스 로직 중앙화**: 모든 비즈니스 로직은 Context에서 관리
4. **최소 상태 원칙**: 파생 가능한 데이터는 상태로 관리하지 않음 (계산으로 처리)

---

## 관리해야 할 상태 도메인

### 1. 콘서트 상태 (ConcertContext)
**핵심 상태**:
- `concerts: Concert[]` - 전체 콘서트 목록
- `selectedConcert: Concert | null` - 현재 선택된 콘서트
- `loading: boolean` - 로딩 상태
- `error: string | null` - 에러 메시지

**파생 데이터** (계산으로 처리):
- `availableConcerts` - 예약 가능한 콘서트 (필터링)
- `upcomingConcerts` - 다가오는 콘서트 (정렬)
- `concertById(id)` - ID로 콘서트 조회 (find)

---

### 2. 좌석 상태 (SeatContext)
**핵심 상태**:
- `seats: Seat[]` - 현재 콘서트의 전체 좌석
- `selectedSeatIds: string[]` - 선택된 좌석 ID 배열
- `loading: boolean` - 로딩 상태
- `error: string | null` - 에러 메시지

**파생 데이터** (계산으로 처리):
- `selectedSeats: Seat[]` - 선택된 좌석 객체 배열 (seats.filter)
- `totalAmount: number` - 총 금액 (selectedSeats.reduce)
- `availableSeats: Seat[]` - 예약 가능한 좌석 (seats.filter)
- `seatsByGrade: Record<SeatGrade, Seat[]>` - 등급별 좌석 (groupBy)

---

### 3. 예약 상태 (BookingContext)
**핵심 상태**:
- `bookings: Booking[]` - 사용자의 예약 내역
- `currentBooking: Partial<BookingFormData> | null` - 현재 진행 중인 예약 데이터
- `loading: boolean` - 로딩 상태
- `error: string | null` - 에러 메시지

**파생 데이터** (계산으로 처리):
- `upcomingBookings: Booking[]` - 예정된 예약 (filter)
- `pastBookings: Booking[]` - 지난 예약 (filter)
- `bookingById(id)` - ID로 예약 조회 (find)

---

## 상태 전이 (State Transitions)

### 콘서트 조회 플로우
```
초기 상태: { concerts: [], loading: false, error: null }
    ↓ loadConcerts() 호출
상태 1: { concerts: [], loading: true, error: null }
    ↓ 데이터 로드 성공
상태 2: { concerts: [...], loading: false, error: null }
```

### 좌석 선택 플로우
```
초기 상태: { selectedSeatIds: [] }
    ↓ toggleSeat(seatId) 호출
상태 1: { selectedSeatIds: [seatId] }
    ↓ toggleSeat(seatId) 다시 호출 (선택 취소)
상태 2: { selectedSeatIds: [] }
    ↓ toggleSeat(anotherSeatId) 호출 (다른 좌석 선택)
상태 3: { selectedSeatIds: [anotherSeatId] }
```

### 예약 생성 플로우
```
초기 상태: { currentBooking: null, loading: false }
    ↓ setBookingInfo(formData) 호출
상태 1: { currentBooking: { name, phone, email, ... }, loading: false }
    ↓ createBooking() 호출
상태 2: { currentBooking: {...}, loading: true }
    ↓ 예약 생성 성공
상태 3: { currentBooking: null, loading: false, bookings: [..., newBooking] }
```

---

## 액션 정의 (Actions)

### ConcertContext Actions
```typescript
type ConcertAction =
  | { type: 'LOAD_CONCERTS_REQUEST' }
  | { type: 'LOAD_CONCERTS_SUCCESS'; payload: Concert[] }
  | { type: 'LOAD_CONCERTS_FAILURE'; payload: string }
  | { type: 'SELECT_CONCERT'; payload: Concert }
  | { type: 'CLEAR_SELECTED_CONCERT' };
```

### SeatContext Actions
```typescript
type SeatAction =
  | { type: 'LOAD_SEATS_REQUEST' }
  | { type: 'LOAD_SEATS_SUCCESS'; payload: Seat[] }
  | { type: 'LOAD_SEATS_FAILURE'; payload: string }
  | { type: 'TOGGLE_SEAT'; payload: string } // seatId
  | { type: 'CLEAR_SELECTED_SEATS' };
```

### BookingContext Actions
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

---

## 비즈니스 로직 (Business Logic)

### 좌석 선택 로직
```typescript
function toggleSeat(seatId: string) {
  // 1. 이미 선택된 좌석인지 확인
  const isSelected = selectedSeatIds.includes(seatId);

  if (isSelected) {
    // 선택 취소
    dispatch({ type: 'TOGGLE_SEAT', payload: seatId });
  } else {
    // 2. 최대 4개 제한 검증
    if (selectedSeatIds.length >= 4) {
      throw new Error('최대 4개까지만 선택할 수 있습니다');
    }

    // 3. 해당 좌석이 예약 가능한지 확인
    const seat = seats.find(s => s.id === seatId);
    if (!seat || seat.isBooked) {
      throw new Error('이미 예약된 좌석입니다');
    }

    // 선택 추가
    dispatch({ type: 'TOGGLE_SEAT', payload: seatId });
  }
}
```

### 예약 생성 로직
```typescript
async function createBooking(formData: BookingFormData) {
  // 1. 입력값 검증
  validateBookingForm(formData);

  // 2. 선택된 좌석 확인
  if (selectedSeatIds.length === 0) {
    throw new Error('좌석을 선택해주세요');
  }

  // 3. 총 금액 계산
  const totalAmount = selectedSeats.reduce((sum, seat) => sum + seat.price, 0);

  // 4. 예약 데이터 생성
  const bookingData = {
    concertId: selectedConcert.id,
    seatIds: selectedSeatIds,
    customerName: formData.name,
    customerPhone: formData.phone,
    customerEmail: formData.email,
    customerBirthdate: formData.birthdate,
    totalAmount,
  };

  // 5. Repository를 통해 예약 생성
  dispatch({ type: 'CREATE_BOOKING_REQUEST' });
  try {
    const booking = await bookingRepository.create(bookingData);
    dispatch({ type: 'CREATE_BOOKING_SUCCESS', payload: booking });

    // 6. 좌석 선택 초기화
    dispatch({ type: 'CLEAR_SELECTED_SEATS' });

    return booking;
  } catch (error) {
    dispatch({ type: 'CREATE_BOOKING_FAILURE', payload: error.message });
    throw error;
  }
}
```

---

## 컴포넌트와 상태 연결

### Presentation Layer (컴포넌트)
컴포넌트는 **상태를 읽고**, **액션을 호출**하기만 함:

```typescript
// components/concerts/ConcertList.tsx
function ConcertList() {
  const { concerts, loading, error } = useConcert();

  if (loading) return <Loading />;
  if (error) return <ErrorMessage message={error} />;

  return (
    <div>
      {concerts.map(concert => (
        <ConcertCard key={concert.id} concert={concert} />
      ))}
    </div>
  );
}

// components/seats/SeatGrid.tsx
function SeatGrid() {
  const { seats, selectedSeatIds, toggleSeat } = useSeat();

  return (
    <div>
      {seats.map(seat => (
        <SeatButton
          key={seat.id}
          seat={seat}
          isSelected={selectedSeatIds.includes(seat.id)}
          onClick={() => toggleSeat(seat.id)}
        />
      ))}
    </div>
  );
}
```

---

## 성능 최적화 전략

### 1. Memoization (useMemo)
파생 데이터는 useMemo로 계산:

```typescript
const selectedSeats = useMemo(
  () => seats.filter(seat => selectedSeatIds.includes(seat.id)),
  [seats, selectedSeatIds]
);

const totalAmount = useMemo(
  () => selectedSeats.reduce((sum, seat) => sum + seat.price, 0),
  [selectedSeats]
);
```

### 2. Callback Memoization (useCallback)
액션 함수는 useCallback으로 메모이제이션:

```typescript
const toggleSeat = useCallback((seatId: string) => {
  // 로직
  dispatch({ type: 'TOGGLE_SEAT', payload: seatId });
}, []);
```

### 3. Component Memoization (React.memo)
순수 컴포넌트는 React.memo로 최적화:

```typescript
const SeatButton = React.memo(({ seat, isSelected, onClick }) => {
  // 렌더링 로직
});
```

---

## 전역 상태 vs 로컬 상태

### 전역 상태 (Context)
- 콘서트 목록, 선택된 콘서트
- 좌석 목록, 선택된 좌석
- 예약 내역
- 로딩/에러 상태

### 로컬 상태 (useState)
- 폼 입력값 (임시 상태)
- UI 상태 (모달 열림/닫힘, 탭 선택)
- 검증 에러 메시지 (필드별)

---

## 상태 초기화 시점

### App 초기화 시
```typescript
// app/layout.tsx
<ConcertProvider>
  <SeatProvider>
    <BookingProvider>
      {children}
    </BookingProvider>
  </SeatProvider>
</ConcertProvider>
```

### 각 Context 초기화
```typescript
// ConcertContext
useEffect(() => {
  loadConcerts(); // 앱 로드 시 콘서트 목록 자동 로드
}, []);

// SeatContext
// 콘서트 선택 시에만 좌석 로드 (수동)

// BookingContext
useEffect(() => {
  loadBookings(); // 앱 로드 시 예약 내역 자동 로드
}, []);
```

---

## 테스트 전략

### Unit Test (비즈니스 로직)
- Reducer 함수 테스트
- 액션 생성 함수 테스트
- 파생 데이터 계산 로직 테스트

### Integration Test (Context + Component)
- Context Provider와 Consumer 통합 테스트
- 전체 플로우 테스트 (콘서트 선택 → 좌석 선택 → 예약 생성)

---

**문서 버전**: 1.0
**작성일**: 2025-01-16
**다음 단계**: Flux Pattern 적용 및 Context 구현 설계
