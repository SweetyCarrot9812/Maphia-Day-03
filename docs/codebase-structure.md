# Codebase Structure: 콘서트 예약 플랫폼

## 아키텍처 원칙 (4 Core Principles)

### 1. Presentation ↔ Business Logic 분리
**원칙**: UI 컴포넌트는 비즈니스 로직을 직접 포함하지 않음

❌ **잘못된 예**:
```typescript
// app/concerts/page.tsx
export default function ConcertsPage() {
  const [concerts, setConcerts] = useState([]);

  useEffect(() => {
    // ❌ 컴포넌트에서 직접 데이터 로드
    const data = localStorage.getItem('concerts');
    setConcerts(JSON.parse(data));
  }, []);

  return <div>{/* ... */}</div>;
}
```

✅ **올바른 예**:
```typescript
// app/concerts/page.tsx
export default function ConcertsPage() {
  // ✅ Context에서 비즈니스 로직 가져오기
  const { concerts } = useConcert();
  return <div>{/* ... */}</div>;
}

// contexts/ConcertContext.tsx
export function useConcert() {
  // 비즈니스 로직: 데이터 로드, 상태 관리
  const [state, dispatch] = useReducer(concertReducer, initialState);
  // ...
}
```

---

### 2. Business Logic ↔ Persistence 분리
**원칙**: 비즈니스 로직은 데이터 저장 방식에 독립적

❌ **잘못된 예**:
```typescript
// contexts/BookingContext.tsx
function createBooking(data) {
  // ❌ Context에서 직접 localStorage 접근
  localStorage.setItem('bookings', JSON.stringify(data));
}
```

✅ **올바른 예**:
```typescript
// contexts/BookingContext.tsx
function createBooking(data) {
  // ✅ Repository 레이어 사용
  bookingRepository.save(data);
}

// lib/repositories/bookingRepository.ts
export const bookingRepository = {
  save: (data) => localStorage.setItem('bookings', JSON.stringify(data)),
  // 나중에 API로 쉽게 교체 가능
  // save: (data) => fetch('/api/bookings', { method: 'POST', body: JSON.stringify(data) })
};
```

---

### 3. Internal Logic ↔ External Contract 분리
**원칙**: 내부 구현과 외부 인터페이스 분리

❌ **잘못된 예**:
```typescript
// 내부 구현이 외부에 노출됨
export function BookingContext() {
  const [rawState, dispatch] = useReducer(reducer, init);
  // ❌ 내부 상태 구조 직접 노출
  return <Context.Provider value={{ rawState, dispatch }} />
}
```

✅ **올바른 예**:
```typescript
// 명확한 인터페이스 제공
export function BookingContext() {
  const [state, dispatch] = useReducer(reducer, init);

  // ✅ 외부에는 명확한 API만 노출
  const value = {
    bookings: state.bookings,
    createBooking: (data) => dispatch({ type: 'CREATE', payload: data }),
    cancelBooking: (id) => dispatch({ type: 'CANCEL', payload: id }),
  };

  return <Context.Provider value={value} />
}
```

---

### 4. Single Responsibility
**원칙**: 각 모듈은 하나의 책임만 가짐

❌ **잘못된 예**:
```typescript
// contexts/AppContext.tsx
// ❌ 하나의 Context에서 모든 것 관리
export function AppContext() {
  const [concerts, setConcerts] = useState([]);
  const [seats, setSeats] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [user, setUser] = useState(null);
  // ...
}
```

✅ **올바른 예**:
```typescript
// contexts/ConcertContext.tsx - 콘서트 관리만
export function ConcertContext() {
  // 콘서트 관련 상태 및 로직만
}

// contexts/BookingContext.tsx - 예약 관리만
export function BookingContext() {
  // 예약 관련 상태 및 로직만
}
```

---

## 디렉토리 구조 (Next.js App Router)

```
concert-booking/
├── src/
│   ├── app/                          # Next.js App Router (Presentation Layer)
│   │   ├── layout.tsx                # 루트 레이아웃 (Context Providers)
│   │   ├── page.tsx                  # 홈페이지 (콘서트 목록)
│   │   ├── concerts/
│   │   │   └── [id]/
│   │   │       ├── page.tsx          # 콘서트 상세
│   │   │       └── seats/
│   │   │           └── page.tsx      # 좌석 선택
│   │   ├── booking/
│   │   │   ├── info/
│   │   │   │   └── page.tsx          # 예약 정보 입력
│   │   │   └── confirmation/
│   │   │       └── page.tsx          # 예약 완료
│   │   └── bookings/
│   │       └── page.tsx              # 예약 조회
│   │
│   ├── components/                   # Presentation Layer
│   │   ├── concerts/
│   │   │   ├── ConcertCard.tsx       # 콘서트 카드 컴포넌트
│   │   │   ├── ConcertList.tsx       # 콘서트 리스트
│   │   │   └── ConcertDetail.tsx     # 콘서트 상세 정보
│   │   ├── seats/
│   │   │   ├── SeatGrid.tsx          # 좌석 배치도
│   │   │   ├── SeatLegend.tsx        # 좌석 범례
│   │   │   └── SeatSummary.tsx       # 선택된 좌석 요약
│   │   ├── booking/
│   │   │   ├── BookingForm.tsx       # 예약 정보 폼
│   │   │   ├── BookingCard.tsx       # 예약 카드
│   │   │   └── BookingList.tsx       # 예약 리스트
│   │   └── common/
│   │       ├── Header.tsx            # 헤더 (네비게이션)
│   │       ├── Button.tsx            # 재사용 버튼
│   │       ├── Input.tsx             # 재사용 입력 필드
│   │       ├── Loading.tsx           # 로딩 스피너
│   │       └── ErrorMessage.tsx      # 에러 메시지
│   │
│   ├── contexts/                     # Application Layer (Business Logic)
│   │   ├── ConcertContext.tsx        # 콘서트 상태 관리 (Flux)
│   │   ├── SeatContext.tsx           # 좌석 상태 관리 (Flux)
│   │   └── BookingContext.tsx        # 예약 상태 관리 (Flux)
│   │
│   ├── types/                        # Domain Layer (Type Definitions)
│   │   ├── concert.ts                # Concert 타입
│   │   ├── seat.ts                   # Seat 타입
│   │   ├── booking.ts                # Booking 타입
│   │   └── index.ts                  # 타입 export
│   │
│   ├── lib/                          # Infrastructure Layer
│   │   ├── repositories/
│   │   │   ├── concertRepository.ts  # 콘서트 데이터 접근
│   │   │   ├── seatRepository.ts     # 좌석 데이터 접근
│   │   │   └── bookingRepository.ts  # 예약 데이터 접근
│   │   ├── utils/
│   │   │   ├── validation.ts         # 입력 검증 유틸
│   │   │   ├── format.ts             # 포맷팅 유틸
│   │   │   └── storage.ts            # localStorage 래퍼
│   │   └── constants/
│   │       ├── seatGrades.ts         # 좌석 등급 상수
│   │       └── validationRules.ts    # 검증 규칙 상수
│   │
│   └── styles/
│       └── globals.css               # 전역 스타일 (Tailwind)
│
├── public/                           # 정적 파일
│   └── images/
│       └── concerts/                 # 콘서트 이미지
│
├── .env.local                        # 환경 변수
├── tailwind.config.ts                # Tailwind 설정
├── tsconfig.json                     # TypeScript 설정
├── next.config.js                    # Next.js 설정
├── package.json                      # 의존성
└── README.md                         # 프로젝트 문서
```

---

## 레이어별 상세 설명

### 1. Presentation Layer (`app/`, `components/`)

**역할**: UI 렌더링, 사용자 인터랙션 처리

**규칙**:
- Context에서 상태와 액션 가져오기만 함
- 비즈니스 로직 포함 금지
- 순수한 UI 컴포넌트

**예시 구조**:
```typescript
// app/page.tsx
import { useConcert } from '@/contexts/ConcertContext';
import ConcertList from '@/components/concerts/ConcertList';

export default function HomePage() {
  const { concerts, loading, error } = useConcert();

  if (loading) return <Loading />;
  if (error) return <ErrorMessage message={error} />;

  return <ConcertList concerts={concerts} />;
}

// components/concerts/ConcertCard.tsx
interface ConcertCardProps {
  concert: Concert;
  onClick: (id: string) => void;
}

export default function ConcertCard({ concert, onClick }: ConcertCardProps) {
  return (
    <div onClick={() => onClick(concert.id)}>
      {/* UI 렌더링만 */}
    </div>
  );
}
```

---

### 2. Application Layer (`contexts/`)

**역할**: 비즈니스 로직, 상태 관리 (Flux 패턴)

**규칙**:
- useReducer로 상태 관리
- Repository를 통해 데이터 접근
- 외부에 명확한 API 제공

**Flux 패턴 구조**:
```typescript
// contexts/BookingContext.tsx

// 1. Action Types
type BookingAction =
  | { type: 'CREATE_BOOKING'; payload: BookingData }
  | { type: 'LOAD_BOOKINGS'; payload: Booking[] }
  | { type: 'SET_ERROR'; payload: string };

// 2. Reducer (Dispatcher 역할)
function bookingReducer(state: BookingState, action: BookingAction): BookingState {
  switch (action.type) {
    case 'CREATE_BOOKING':
      return { ...state, bookings: [...state.bookings, action.payload] };
    case 'LOAD_BOOKINGS':
      return { ...state, bookings: action.payload, loading: false };
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    default:
      return state;
  }
}

// 3. Context (Store 역할)
const BookingContext = createContext<BookingContextValue | null>(null);

// 4. Provider
export function BookingProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(bookingReducer, initialState);

  // 비즈니스 로직
  const createBooking = useCallback(async (data: BookingData) => {
    try {
      const booking = await bookingRepository.create(data);
      dispatch({ type: 'CREATE_BOOKING', payload: booking });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message });
    }
  }, []);

  // 외부 API
  const value = {
    bookings: state.bookings,
    loading: state.loading,
    error: state.error,
    createBooking,
  };

  return (
    <BookingContext.Provider value={value}>
      {children}
    </BookingContext.Provider>
  );
}

// 5. Hook
export function useBooking() {
  const context = useContext(BookingContext);
  if (!context) throw new Error('useBooking must be used within BookingProvider');
  return context;
}
```

---

### 3. Domain Layer (`types/`)

**역할**: 타입 정의, 인터페이스

**규칙**:
- 비즈니스 도메인 모델 정의
- 다른 레이어에 독립적
- 불변성 보장

**예시**:
```typescript
// types/concert.ts
export interface Concert {
  id: string;
  title: string;
  artist: string;
  date: Date;
  venue: string;
  description: string;
  imageUrl: string;
  runningTime: number;
}

// types/seat.ts
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

// types/booking.ts
export interface Booking {
  id: string;
  concertId: string;
  seatIds: string[];
  customerName: string;
  customerPhone: string;
  customerEmail: string;
  customerBirthdate?: string;
  totalAmount: number;
  createdAt: Date;
  status: 'confirmed';
}

// types/index.ts
export * from './concert';
export * from './seat';
export * from './booking';
```

---

### 4. Infrastructure Layer (`lib/`)

**역할**: 외부 시스템 연동, 유틸리티

**규칙**:
- 데이터 저장/조회 추상화
- 교체 가능한 구조
- 외부 의존성 캡슐화

**Repository 패턴**:
```typescript
// lib/repositories/bookingRepository.ts
import { Booking } from '@/types';
import { storage } from '@/lib/utils/storage';

const STORAGE_KEY = 'bookings';

export const bookingRepository = {
  // Create
  create: async (booking: Booking): Promise<Booking> => {
    const bookings = await bookingRepository.findAll();
    const newBooking = {
      ...booking,
      id: `BK-${Date.now()}`,
      createdAt: new Date(),
    };
    storage.set(STORAGE_KEY, [...bookings, newBooking]);
    return newBooking;
  },

  // Read
  findAll: async (): Promise<Booking[]> => {
    return storage.get(STORAGE_KEY) || [];
  },

  findById: async (id: string): Promise<Booking | null> => {
    const bookings = await bookingRepository.findAll();
    return bookings.find(b => b.id === id) || null;
  },

  // Update
  update: async (id: string, data: Partial<Booking>): Promise<Booking> => {
    const bookings = await bookingRepository.findAll();
    const index = bookings.findIndex(b => b.id === id);
    if (index === -1) throw new Error('Booking not found');

    bookings[index] = { ...bookings[index], ...data };
    storage.set(STORAGE_KEY, bookings);
    return bookings[index];
  },

  // Delete
  delete: async (id: string): Promise<void> => {
    const bookings = await bookingRepository.findAll();
    storage.set(STORAGE_KEY, bookings.filter(b => b.id !== id));
  },
};

// lib/utils/storage.ts
export const storage = {
  get: <T>(key: string): T | null => {
    if (typeof window === 'undefined') return null;
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : null;
  },

  set: <T>(key: string, value: T): void => {
    if (typeof window === 'undefined') return;
    localStorage.setItem(key, JSON.stringify(value));
  },

  remove: (key: string): void => {
    if (typeof window === 'undefined') return;
    localStorage.removeItem(key);
  },
};
```

---

## 데이터 흐름 (Data Flow)

```
View (Component)
    ↓ 이벤트 발생 (onClick, onSubmit)
Action Creator (Context)
    ↓ dispatch(action)
Reducer (Dispatcher)
    ↓ 상태 변경
Store (Context State)
    ↓ 상태 전달
Repository (Data Layer)
    ↓ 데이터 저장/조회
localStorage
    ↓ 상태 업데이트
View Re-render
```

**단방향 데이터 흐름 (Flux 패턴)**

---

## Context Providers 구조

```typescript
// app/layout.tsx
import { ConcertProvider } from '@/contexts/ConcertContext';
import { SeatProvider } from '@/contexts/SeatContext';
import { BookingProvider } from '@/contexts/BookingContext';

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <ConcertProvider>
          <SeatProvider>
            <BookingProvider>
              <Header />
              {children}
            </BookingProvider>
          </SeatProvider>
        </ConcertProvider>
      </body>
    </html>
  );
}
```

---

## 파일 명명 규칙

### 컴포넌트
- **PascalCase**: `ConcertCard.tsx`, `SeatGrid.tsx`
- **한 파일 하나의 컴포넌트**

### Contexts
- **PascalCase + Context**: `BookingContext.tsx`
- **Named Export**: `export function BookingProvider()`, `export function useBooking()`

### Types
- **camelCase 파일명**: `concert.ts`, `seat.ts`
- **PascalCase 타입명**: `interface Concert`, `type SeatGrade`

### Utils/Repositories
- **camelCase**: `validation.ts`, `bookingRepository.ts`
- **Named Export**: `export const bookingRepository = { ... }`

---

## 컴포넌트 작성 가이드

### 컴포넌트 템플릿
```typescript
// components/example/ExampleComponent.tsx
import { FC } from 'react';

interface ExampleComponentProps {
  title: string;
  onClick: () => void;
}

const ExampleComponent: FC<ExampleComponentProps> = ({ title, onClick }) => {
  return (
    <div className="p-4">
      <h2 className="text-xl font-bold">{title}</h2>
      <button onClick={onClick} className="mt-2 px-4 py-2 bg-blue-500 text-white">
        Click Me
      </button>
    </div>
  );
};

export default ExampleComponent;
```

### Context 템플릿
```typescript
// contexts/ExampleContext.tsx
import { createContext, useContext, useReducer, useCallback, ReactNode } from 'react';

// 1. Types
interface ExampleState {
  data: any[];
  loading: boolean;
  error: string | null;
}

type ExampleAction =
  | { type: 'SET_DATA'; payload: any[] }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string };

interface ExampleContextValue {
  data: any[];
  loading: boolean;
  error: string | null;
  fetchData: () => Promise<void>;
}

// 2. Reducer
function exampleReducer(state: ExampleState, action: ExampleAction): ExampleState {
  switch (action.type) {
    case 'SET_DATA':
      return { ...state, data: action.payload, loading: false };
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    default:
      return state;
  }
}

// 3. Context
const ExampleContext = createContext<ExampleContextValue | null>(null);

// 4. Provider
export function ExampleProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(exampleReducer, {
    data: [],
    loading: false,
    error: null,
  });

  const fetchData = useCallback(async () => {
    dispatch({ type: 'SET_LOADING', payload: true });
    try {
      // Fetch logic
      const data = []; // from repository
      dispatch({ type: 'SET_DATA', payload: data });
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message });
    }
  }, []);

  const value = {
    data: state.data,
    loading: state.loading,
    error: state.error,
    fetchData,
  };

  return <ExampleContext.Provider value={value}>{children}</ExampleContext.Provider>;
}

// 5. Hook
export function useExample() {
  const context = useContext(ExampleContext);
  if (!context) throw new Error('useExample must be used within ExampleProvider');
  return context;
}
```

---

## 환경 설정 파일

### tailwind.config.ts
```typescript
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          700: '#1d4ed8',
        },
        success: '#10b981',
        error: '#ef4444',
        warning: '#f59e0b',
      },
    },
  },
  plugins: [],
};

export default config;
```

### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

---

## 다음 단계 체크리스트

프로젝트 생성 시:
```bash
☑️ Next.js 프로젝트 생성 (with TypeScript, Tailwind)
☑️ 디렉토리 구조 생성 (app/, components/, contexts/, lib/, types/)
☑️ 환경 변수 설정 (.env.local)
☑️ 전역 스타일 설정 (globals.css)
☑️ 타입 정의 파일 생성 (types/)
☑️ Repository 파일 생성 (lib/repositories/)
☑️ Context Provider 구조 생성 (contexts/)
```

---

**문서 버전**: 1.0
**작성일**: 2025-01-16
**다음 단계**: Database Schema 설계
