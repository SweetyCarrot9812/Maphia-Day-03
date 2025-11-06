# 아키텍처 설계 문서 - 회의실 예약 시스템

## Meta
- 작성일: 2025-11-07
- 작성자: Portfolio Project
- 버전: 1.0
- 아키텍처 스타일: Simple Layered + DDD Lite

---

## 아키텍처 스타일 선정

### 자동 분석 결과
```yaml
architecture_style: Simple Layered + DDD Lite (포트폴리오 최적화)
rationale:
  - 도메인 엔티티: 4개 (회의실, 예약, 사용자, 관리자)
  - Bounded Context: 2개 (일반 사용자, 관리자)
  - 개발 환경: 1인 개발 + 포트폴리오
  - 기술 스택: Next.js 14 + Supabase
  - 개발 기간: 3주 MVP
  - 복잡도: 단순 CRUD → Full DDD 오버엔지니어링
```

### 선정 근거
- **Simple Layered**: 포트폴리오 프로젝트에 적합한 명확한 계층 분리
- **DDD Lite**: Value Object + Entity 기본만 적용 (학습 곡선 최소화)
- **Next.js 친화**: App Router + API Routes 구조에 최적화
- **1인 개발 최적화**: 과도한 추상화 제거, 실용성 우선

---

## 디렉토리 구조

### 전체 프로젝트 구조
```
conference-room-booking/
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── (auth)/                   # 라우트 그룹
│   │   │   ├── admin/
│   │   │   │   ├── login/page.tsx
│   │   │   │   ├── dashboard/page.tsx
│   │   │   │   └── rooms/page.tsx
│   │   │   └── my-bookings/page.tsx
│   │   ├── api/                      # API Routes
│   │   │   ├── rooms/route.ts
│   │   │   ├── bookings/route.ts
│   │   │   └── admin/route.ts
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   ├── page.tsx                  # 메인 페이지
│   │   └── not-found.tsx
│   │
│   ├── features/                     # Bounded Contexts (DDD Lite)
│   │   ├── booking/                  # 예약 컨텍스트
│   │   │   ├── domain/               # 도메인 로직
│   │   │   │   ├── entities/
│   │   │   │   │   ├── booking.entity.ts
│   │   │   │   │   └── room.entity.ts
│   │   │   │   ├── value-objects/
│   │   │   │   │   ├── phone-number.vo.ts
│   │   │   │   │   ├── booking-time.vo.ts
│   │   │   │   │   └── password.vo.ts
│   │   │   │   └── repositories/
│   │   │   │       ├── booking.repository.ts
│   │   │   │       └── room.repository.ts
│   │   │   ├── application/          # Use Cases
│   │   │   │   ├── use-cases/
│   │   │   │   │   ├── create-booking.use-case.ts
│   │   │   │   │   ├── get-bookings.use-case.ts
│   │   │   │   │   ├── cancel-booking.use-case.ts
│   │   │   │   │   └── get-available-times.use-case.ts
│   │   │   │   └── dto/
│   │   │   │       ├── create-booking.dto.ts
│   │   │   │       └── booking-query.dto.ts
│   │   │   ├── infrastructure/       # 구현체
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── supabase-booking.repository.ts
│   │   │   │   │   └── supabase-room.repository.ts
│   │   │   │   └── mappers/
│   │   │   │       ├── booking.mapper.ts
│   │   │   │       └── room.mapper.ts
│   │   │   └── presentation/         # API/UI 계층
│   │   │       ├── api/
│   │   │       │   └── booking.controller.ts
│   │   │       ├── components/
│   │   │       │   ├── booking-form.tsx
│   │   │       │   ├── room-list.tsx
│   │   │       │   └── time-selector.tsx
│   │   │       └── validators/
│   │   │           └── booking.validator.ts
│   │   │
│   │   └── admin/                    # 관리자 컨텍스트
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── admin.entity.ts
│   │       │   └── repositories/
│   │       │       └── admin.repository.ts
│   │       ├── application/
│   │       │   ├── use-cases/
│   │       │   │   ├── authenticate-admin.use-case.ts
│   │       │   │   ├── manage-rooms.use-case.ts
│   │       │   │   └── get-booking-stats.use-case.ts
│   │       │   └── dto/
│   │       │       └── admin-stats.dto.ts
│   │       ├── infrastructure/
│   │       │   └── repositories/
│   │       │       └── supabase-admin.repository.ts
│   │       └── presentation/
│   │           ├── api/
│   │           │   └── admin.controller.ts
│   │           └── components/
│   │               ├── admin-dashboard.tsx
│   │               ├── room-manager.tsx
│   │               └── booking-stats.tsx
│   │
│   ├── shared/                       # 공유 커널
│   │   ├── domain/                   # 공통 도메인 타입
│   │   │   ├── entity.base.ts
│   │   │   ├── value-object.base.ts
│   │   │   └── result.ts             # Result<T> 패턴
│   │   ├── infrastructure/           # 공통 인프라
│   │   │   ├── supabase.client.ts
│   │   │   ├── config.ts
│   │   │   └── errors.ts
│   │   └── ui/                       # 공통 UI 컴포넌트
│   │       ├── button.tsx
│   │       ├── input.tsx
│   │       ├── modal.tsx
│   │       └── toast.tsx
│   │
│   └── lib/                          # 유틸리티
│       ├── utils.ts
│       ├── validations.ts
│       └── constants.ts
│
├── public/
├── .env.local
├── .env.example
├── next.config.js
├── tailwind.config.js
├── tsconfig.json
└── package.json
```

---

## 핵심 아키텍처 패턴

### 1. Result 패턴 (Railway-oriented Programming)

**목적**: 예외 대신 명시적 에러 처리로 안정성 향상

```typescript
// src/shared/domain/result.ts
export class Result<T> {
  private constructor(
    private readonly _isSuccess: boolean,
    private readonly _value?: T,
    private readonly _error?: AppError
  ) {}

  static ok<U>(value: U): Result<U> {
    return new Result<U>(true, value, undefined)
  }

  static fail<U>(error: AppError): Result<U> {
    return new Result<U>(false, undefined, error)
  }

  get isSuccess(): boolean {
    return this._isSuccess
  }

  get isFailure(): boolean {
    return !this._isSuccess
  }

  get value(): T {
    if (!this._isSuccess || this._value === undefined) {
      throw new Error('Cannot get value from failed result')
    }
    return this._value
  }

  get error(): AppError {
    if (this._isSuccess || this._error === undefined) {
      throw new Error('Cannot get error from successful result')
    }
    return this._error
  }

  map<U>(fn: (value: T) => U): Result<U> {
    if (this._isSuccess && this._value !== undefined) {
      return Result.ok(fn(this._value))
    }
    return Result.fail(this._error!)
  }

  flatMap<U>(fn: (value: T) => Result<U>): Result<U> {
    if (this._isSuccess && this._value !== undefined) {
      return fn(this._value)
    }
    return Result.fail(this._error!)
  }
}

// 에러 타입 정의
export interface AppError {
  code: string
  message: string
  details?: unknown
}
```

**사용 예시**:
```typescript
// Use Case에서 Result 사용
async execute(dto: CreateBookingDto): Promise<Result<BookingEntity>> {
  // 1. 입력 검증
  const phoneResult = PhoneNumber.create(dto.phoneNumber)
  if (phoneResult.isFailure) {
    return Result.fail(phoneResult.error)
  }

  // 2. 비즈니스 로직
  const booking = await this.bookingRepository.save(/* ... */)
  return Result.ok(booking)
}
```

---

### 2. Value Object 패턴

**목적**: 도메인 규칙을 캡슐화하고 타입 안전성 보장

```typescript
// src/features/booking/domain/value-objects/phone-number.vo.ts
export class PhoneNumber {
  private constructor(private readonly value: string) {}

  static create(phone: string): Result<PhoneNumber> {
    if (!phone || phone.trim().length === 0) {
      return Result.fail({
        code: 'INVALID_PHONE',
        message: '휴대폰번호는 필수입니다'
      })
    }

    // 한국 휴대폰번호 형식 검증
    const phoneRegex = /^010-\d{4}-\d{4}$/
    if (!phoneRegex.test(phone)) {
      return Result.fail({
        code: 'INVALID_PHONE_FORMAT',
        message: '휴대폰번호 형식이 올바르지 않습니다 (010-XXXX-XXXX)'
      })
    }

    return Result.ok(new PhoneNumber(phone))
  }

  getValue(): string {
    return this.value
  }

  equals(other: PhoneNumber): boolean {
    return this.value === other.value
  }

  // 마스킹 기능 (개인정보 보호)
  getMasked(): string {
    return this.value.replace(/(\d{3})-(\d{2})\d{2}-(\d{2})\d{2}/, '$1-$2**-$3**')
  }
}
```

```typescript
// src/features/booking/domain/value-objects/booking-time.vo.ts
export class BookingTime {
  private constructor(
    private readonly date: Date,
    private readonly startHour: number
  ) {}

  static create(date: string, startHour: number): Result<BookingTime> {
    const bookingDate = new Date(date)

    // 과거 날짜 검증
    if (bookingDate < new Date()) {
      return Result.fail({
        code: 'PAST_DATE',
        message: '과거 날짜는 예약할 수 없습니다'
      })
    }

    // 운영시간 검증 (9시-18시)
    if (startHour < 9 || startHour >= 18) {
      return Result.fail({
        code: 'INVALID_TIME',
        message: '예약 가능 시간은 09:00-17:00입니다'
      })
    }

    return Result.ok(new BookingTime(bookingDate, startHour))
  }

  getDate(): Date { return this.date }
  getStartHour(): number { return this.startHour }
  getEndHour(): number { return this.startHour + 1 }

  // 시간 표시 형식
  getTimeRange(): string {
    const start = `${this.startHour.toString().padStart(2, '0')}:00`
    const end = `${this.getEndHour().toString().padStart(2, '0')}:00`
    return `${start} - ${end}`
  }

  // 취소 가능 여부 (1시간 전까지)
  isCancellable(): boolean {
    const now = new Date()
    const bookingDateTime = new Date(this.date)
    bookingDateTime.setHours(this.startHour)

    const diffHours = (bookingDateTime.getTime() - now.getTime()) / (1000 * 60 * 60)
    return diffHours >= 1
  }
}
```

---

### 3. Repository 패턴

**목적**: 데이터 액세스 로직 추상화 및 테스트 가능성 향상

```typescript
// src/features/booking/domain/repositories/booking.repository.ts
export interface BookingRepository {
  save(booking: BookingEntity): Promise<Result<BookingEntity>>
  findById(id: string): Promise<Result<BookingEntity | null>>
  findByPhoneAndPassword(phone: string, password: string): Promise<Result<BookingEntity[]>>
  findByRoomAndDate(roomId: string, date: Date): Promise<Result<BookingEntity[]>>
  cancel(id: string): Promise<Result<void>>
}
```

```typescript
// src/features/booking/infrastructure/repositories/supabase-booking.repository.ts
export class SupabaseBookingRepository implements BookingRepository {
  constructor(private readonly supabase: SupabaseClient) {}

  async save(booking: BookingEntity): Promise<Result<BookingEntity>> {
    try {
      const data = BookingMapper.toDatabase(booking)

      const { data: result, error } = await this.supabase
        .from('bookings')
        .insert(data)
        .select()
        .single()

      if (error) {
        return Result.fail({
          code: 'DB_ERROR',
          message: '예약 저장 중 오류가 발생했습니다',
          details: error
        })
      }

      const entity = BookingMapper.toDomain(result)
      return Result.ok(entity)
    } catch (error) {
      return Result.fail({
        code: 'UNEXPECTED_ERROR',
        message: '예상치 못한 오류가 발생했습니다',
        details: error
      })
    }
  }

  async findByPhoneAndPassword(phone: string, password: string): Promise<Result<BookingEntity[]>> {
    try {
      const { data, error } = await this.supabase
        .from('bookings')
        .select(`
          *,
          rooms (
            id,
            name,
            location,
            capacity
          )
        `)
        .eq('phone_number', phone)
        .eq('password_hash', password) // 실제로는 해시 비교 필요

      if (error) {
        return Result.fail({
          code: 'DB_ERROR',
          message: '예약 조회 중 오류가 발생했습니다',
          details: error
        })
      }

      const entities = data.map(BookingMapper.toDomain)
      return Result.ok(entities)
    } catch (error) {
      return Result.fail({
        code: 'UNEXPECTED_ERROR',
        message: '예상치 못한 오류가 발생했습니다',
        details: error
      })
    }
  }
}
```

---

### 4. Use Case 패턴

**목적**: 비즈니스 로직 캡슐화 및 단일 책임 원칙

```typescript
// src/features/booking/application/use-cases/create-booking.use-case.ts
export class CreateBookingUseCase {
  constructor(
    private readonly bookingRepository: BookingRepository,
    private readonly roomRepository: RoomRepository
  ) {}

  async execute(dto: CreateBookingDto): Promise<Result<BookingEntity>> {
    // 1. 입력 검증
    const phoneResult = PhoneNumber.create(dto.phoneNumber)
    if (phoneResult.isFailure) {
      return Result.fail(phoneResult.error)
    }

    const timeResult = BookingTime.create(dto.date, dto.startHour)
    if (timeResult.isFailure) {
      return Result.fail(timeResult.error)
    }

    const passwordResult = Password.create(dto.password)
    if (passwordResult.isFailure) {
      return Result.fail(passwordResult.error)
    }

    // 2. 회의실 존재 여부 확인
    const roomResult = await this.roomRepository.findById(dto.roomId)
    if (roomResult.isFailure) {
      return Result.fail(roomResult.error)
    }

    if (!roomResult.value) {
      return Result.fail({
        code: 'ROOM_NOT_FOUND',
        message: '존재하지 않는 회의실입니다'
      })
    }

    // 3. 시간대 중복 검증
    const existingBookingsResult = await this.bookingRepository
      .findByRoomAndDate(dto.roomId, new Date(dto.date))

    if (existingBookingsResult.isFailure) {
      return Result.fail(existingBookingsResult.error)
    }

    const hasConflict = existingBookingsResult.value.some(booking =>
      booking.getStartHour() === dto.startHour &&
      booking.getStatus() === 'CONFIRMED'
    )

    if (hasConflict) {
      return Result.fail({
        code: 'TIME_CONFLICT',
        message: '해당 시간대는 이미 예약되었습니다'
      })
    }

    // 4. 예약 생성
    const booking = BookingEntity.create({
      roomId: dto.roomId,
      userName: dto.userName,
      phoneNumber: phoneResult.value,
      purpose: dto.purpose,
      bookingTime: timeResult.value,
      password: passwordResult.value
    })

    // 5. 저장
    return await this.bookingRepository.save(booking)
  }
}
```

---

### 5. Entity 패턴

**목적**: 도메인 객체의 정체성과 라이프사이클 관리

```typescript
// src/features/booking/domain/entities/booking.entity.ts
export class BookingEntity {
  private constructor(
    private readonly id: string,
    private readonly roomId: string,
    private readonly userName: string,
    private readonly phoneNumber: PhoneNumber,
    private readonly purpose: string,
    private readonly bookingTime: BookingTime,
    private readonly password: Password,
    private status: BookingStatus = 'CONFIRMED',
    private readonly createdAt: Date = new Date(),
    private cancelledAt?: Date
  ) {}

  static create(props: {
    roomId: string
    userName: string
    phoneNumber: PhoneNumber
    purpose: string
    bookingTime: BookingTime
    password: Password
  }): BookingEntity {
    const id = crypto.randomUUID()
    return new BookingEntity(
      id,
      props.roomId,
      props.userName,
      props.phoneNumber,
      props.purpose,
      props.bookingTime,
      props.password
    )
  }

  // Getters
  getId(): string { return this.id }
  getRoomId(): string { return this.roomId }
  getUserName(): string { return this.userName }
  getPhoneNumber(): PhoneNumber { return this.phoneNumber }
  getPurpose(): string { return this.purpose }
  getBookingTime(): BookingTime { return this.bookingTime }
  getStatus(): BookingStatus { return this.status }
  getCreatedAt(): Date { return this.createdAt }
  getCancelledAt(): Date | undefined { return this.cancelledAt }

  // 비즈니스 메서드
  cancel(): Result<void> {
    if (this.status === 'CANCELLED') {
      return Result.fail({
        code: 'ALREADY_CANCELLED',
        message: '이미 취소된 예약입니다'
      })
    }

    if (!this.bookingTime.isCancellable()) {
      return Result.fail({
        code: 'CANCELLATION_DEADLINE_PASSED',
        message: '예약 시작 1시간 전까지만 취소 가능합니다'
      })
    }

    this.status = 'CANCELLED'
    this.cancelledAt = new Date()

    return Result.ok(undefined)
  }

  // 비밀번호 검증
  verifyPassword(inputPassword: string): boolean {
    return this.password.verify(inputPassword)
  }

  // 예약 확인번호 생성
  getConfirmationNumber(): string {
    const date = this.bookingTime.getDate()
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '')
    const shortId = this.id.slice(-4).toUpperCase()
    return `BOOK-${dateStr}-${shortId}`
  }
}

export type BookingStatus = 'CONFIRMED' | 'CANCELLED' | 'COMPLETED'
```

---

## Next.js 통합 패턴

### Server Component에서 Use Case 호출

```typescript
// src/app/page.tsx (Server Component)
import { RoomRepository } from '@/features/booking/infrastructure/repositories/supabase-room.repository'
import { GetRoomsUseCase } from '@/features/booking/application/use-cases/get-rooms.use-case'

export default async function HomePage() {
  // 의존성 주입 (간단한 방식)
  const roomRepository = new RoomRepository(supabaseClient)
  const getRoomsUseCase = new GetRoomsUseCase(roomRepository)

  const result = await getRoomsUseCase.execute()

  if (result.isFailure) {
    return <div>회의실 정보를 불러올 수 없습니다</div>
  }

  return <RoomList rooms={result.value} />
}
```

### API Route에서 Use Case 호출

```typescript
// src/app/api/bookings/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { CreateBookingUseCase } from '@/features/booking/application/use-cases/create-booking.use-case'
import { BookingValidator } from '@/features/booking/presentation/validators/booking.validator'

export async function POST(request: NextRequest) {
  try {
    // 1. 입력 검증
    const body = await request.json()
    const validationResult = BookingValidator.validate(body)

    if (validationResult.isFailure) {
      return NextResponse.json(
        { error: validationResult.error },
        { status: 400 }
      )
    }

    // 2. Use Case 실행
    const useCase = new CreateBookingUseCase(
      new BookingRepository(supabaseClient),
      new RoomRepository(supabaseClient)
    )

    const result = await useCase.execute(validationResult.value)

    if (result.isFailure) {
      return NextResponse.json(
        { error: result.error },
        { status: 400 }
      )
    }

    return NextResponse.json(result.value, { status: 201 })
  } catch (error) {
    return NextResponse.json(
      { error: '서버 오류가 발생했습니다' },
      { status: 500 }
    )
  }
}
```

### Client Component에서 API 호출

```typescript
// src/features/booking/presentation/components/booking-form.tsx
'use client'

import { useState } from 'react'
import { CreateBookingDto } from '@/features/booking/application/dto/create-booking.dto'

export function BookingForm() {
  const [formData, setFormData] = useState<CreateBookingDto>({
    roomId: '',
    userName: '',
    phoneNumber: '',
    purpose: '',
    date: '',
    startHour: 9,
    password: ''
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    const response = await fetch('/api/bookings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData)
    })

    if (response.ok) {
      const booking = await response.json()
      // 성공 처리
    } else {
      const error = await response.json()
      // 에러 처리
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      {/* 폼 필드들 */}
    </form>
  )
}
```

---

## 폴더별 역할 정의

### `/features` - Bounded Context별 기능 모듈
- **목적**: 도메인별 응집도 높은 모듈화
- **규칙**: 다른 feature 폴더 직접 import 금지
- **통신**: 도메인 이벤트 또는 API 호출로만 소통

### `/shared` - 공유 커널
- **목적**: 모든 feature에서 공통으로 사용하는 코드
- **포함**: Result 타입, 기본 Entity/ValueObject, 공통 에러
- **규칙**: 비즈니스 로직 포함 금지 (순수 유틸리티만)

### `/app` - Next.js App Router
- **목적**: 라우팅 및 페이지 구성
- **규칙**: 비즈니스 로직 포함 금지, Use Case 호출만
- **구조**: (auth), api, 기본 페이지들

---

## 개발 가이드라인

### 1. 계층 간 의존성 규칙
```
Presentation → Application → Domain ← Infrastructure
     ↑                                        ↓
     └────────── DI Container ←──────────────┘
```

### 2. Import 규칙
- ✅ `domain` → `domain` only
- ✅ `application` → `domain`, `application`
- ✅ `infrastructure` → all layers
- ✅ `presentation` → `application`, `infrastructure`
- ❌ Cross-feature imports 금지

### 3. 에러 처리 규칙
- Use Case는 항상 `Result<T>` 반환
- Repository는 항상 `Result<T>` 반환
- API Route는 Result를 HTTP 상태코드로 변환
- Client는 HTTP 응답을 UI 상태로 변환

### 4. 테스트 전략
- **Unit Test**: Domain 로직 (Value Object, Entity)
- **Integration Test**: Use Case (Repository Mock)
- **E2E Test**: API Route (실제 DB 사용)

---

## 품질 체크리스트

### ✅ Clean Architecture 준수
- [x] Domain 레이어에 infrastructure import 없음
- [x] Application이 Domain만 의존
- [x] Infrastructure가 Repository 인터페이스 구현
- [x] Presentation이 Use Case만 호출

### ✅ DDD Lite 패턴 적용
- [x] Value Object (PhoneNumber, BookingTime, Password)
- [x] Entity (BookingEntity, RoomEntity)
- [x] Repository Interface (Port 정의)
- [x] Use Case (비즈니스 로직 캡슐화)

### ✅ Next.js 통합
- [x] Server Component에서 Use Case 직접 호출
- [x] API Route에서 Use Case 호출
- [x] Client Component에서 API 호출
- [x] 타입 안전성 보장

### ✅ 포트폴리오 최적화
- [x] 과도한 추상화 제거
- [x] 명확한 계층 분리
- [x] 실용적인 패턴 적용
- [x] 빠른 개발 가능

---

## 예상 개발 순서 (3주)

### Week 1: 기반 구조
1. 디렉토리 구조 생성
2. Result, Entity, ValueObject 기본 구현
3. Supabase 연동 및 Repository 구현

### Week 2: 핵심 기능
1. 예약 관련 Use Case 구현
2. API Routes 구현
3. 기본 UI 컴포넌트 구현

### Week 3: 완성도
1. 관리자 기능 구현
2. 에러 처리 및 검증 강화
3. UI/UX 완성도 향상

---

## 학습 리소스

### 필수 개념
- **Result Pattern**: 함수형 에러 처리
- **Value Object**: 도메인 규칙 캡슐화
- **Repository Pattern**: 데이터 액세스 추상화
- **Use Case Pattern**: 비즈니스 로직 캡슐화

### 참고 자료
- Clean Architecture (Robert C. Martin)
- Domain-Driven Design Lite
- Next.js App Router Best Practices
- TypeScript Advanced Patterns

---

**최종 결론**: 포트폴리오 프로젝트에 최적화된 Simple Layered + DDD Lite 아키텍처로 명확한 계층 분리와 빠른 개발 속도를 모두 확보할 수 있습니다.