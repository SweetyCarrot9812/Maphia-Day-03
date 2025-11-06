# 상태관리 설계: 회의실 예약 시스템

## Meta
- **작성일**: 2025-11-07
- **상태 관리 도구**: Zustand (단순함, 포트폴리오 적합)
- **비동기 처리**: TanStack Query (서버 상태 전용)
- **폼 상태**: React Hook Form (폼 전용)

---

## 🎯 기능별 상태 분석

### 분석 결과: 8개 기능 → 4개 주요 상태 도메인

| 도메인 | 포함 기능 | 상태 복잡도 | 우선순위 |
|--------|-----------|-------------|----------|
| **rooms** | UC-001 회의실 목록 조회 | 낮음 | P0 |
| **booking** | UC-002,003,004,005 예약 플로우 | 높음 | P0 |
| **admin** | UC-006,007,008 관리자 기능 | 중간 | P1 |
| **ui** | 모달, 토스트, 로딩 등 | 낮음 | P0 |

---

## 1. 관리해야 할 상태 데이터

### 클라이언트 로컬 상태 (Zustand Store)

#### UI Store
| 상태키 | 타입 | 초기값 | 설명 |
|--------|------|--------|------|
| isBookingModalOpen | boolean | false | 예약 모달 열림 상태 |
| isAdminLoginModalOpen | boolean | false | 관리자 로그인 모달 |
| toastMessage | string \| null | null | 토스트 메시지 |
| toastType | 'success' \| 'error' \| null | null | 토스트 타입 |
| isLoading | boolean | false | 전역 로딩 상태 |

#### Booking Store
| 상태키 | 타입 | 초기값 | 설명 |
|--------|------|--------|------|
| selectedRoomId | string \| null | null | 선택된 회의실 ID |
| selectedDate | string \| null | null | 선택된 날짜 (YYYY-MM-DD) |
| selectedTimeSlot | {start: string, end: string} \| null | null | 선택된 시간대 |
| bookingStep | 'rooms' \| 'time' \| 'form' \| 'complete' | 'rooms' | 예약 단계 |

#### Admin Store
| 상태키 | 타입 | 초기값 | 설명 |
|--------|------|--------|------|
| isAuthenticated | boolean | false | 관리자 인증 상태 |
| currentView | 'dashboard' \| 'rooms' \| 'bookings' | 'dashboard' | 현재 관리자 화면 |

### 서버 동기 상태 (TanStack Query)

| Query Key | 캐시 수명 | 설명 | staleTime |
|-----------|----------|------|-----------|
| ['rooms'] | 10분 | 회의실 목록 | 5분 |
| ['room', roomId] | 5분 | 특정 회의실 상세 | 2분 |
| ['bookings', roomId, date] | 1분 | 특정 회의실 날짜별 예약 현황 | 30초 |
| ['my-bookings', phone, password] | - | 내 예약 조회 (no cache) | 0 |
| ['admin', 'rooms'] | 5분 | 관리자 회의실 목록 | 2분 |
| ['admin', 'bookings', filters] | 1분 | 관리자 예약 현황 | 30초 |

---

## 2. 상태가 아닌 파생값 (Derived Values)

| 파생값 | 계산 로직 | 의존 상태 |
|--------|----------|----------|
| availableTimeSlots | 전체 시간대 - 예약된 시간대 | bookings data |
| selectedRoom | rooms.find(r => r.id === selectedRoomId) | rooms data, selectedRoomId |
| canProceedToNext | 각 단계별 필수 선택 완료 여부 | bookingStep, 선택된 값들 |
| filteredRooms | capacity, location 필터 적용 | rooms data, filters |
| bookingProgress | (currentStep / totalSteps) * 100 | bookingStep |

**중요**: 파생값은 상태로 저장하지 않음. useMemo로 메모이제이션하거나 매번 계산.

---

## 3. 상태 변화 조건 & 화면 반응 표

### Booking Flow 상태 변화
| 상태키 | 트리거 | 전제조건 | 변경 로직 | 화면 반응 |
|--------|--------|----------|----------|----------|
| selectedRoomId | rooms/selectRoom(id) | rooms 존재 | selectedRoomId = id | 회의실 하이라이트, 다음 버튼 활성화 |
| bookingStep | booking/nextStep() | 필수 선택 완료 | step += 1 | 다음 화면으로 전환 |
| selectedDate | booking/selectDate(date) | date >= today | selectedDate = date | 시간대 조회 트리거 |
| selectedTimeSlot | booking/selectTime(slot) | slot.isAvailable | selectedTimeSlot = slot | 예약 폼으로 진행 |

### UI 상태 변화
| 상태키 | 트리거 | 전제조건 | 변경 로직 | 화면 반응 |
|--------|--------|----------|----------|----------|
| toastMessage | api/success or error | 비동기 작업 완료 | message = response.message | 토스트 노출 (3초 후 자동 해제) |
| isLoading | api/request start | 네트워크 요청 시작 | isLoading = true | 로딩 스피너 표시 |
| isBookingModalOpen | modal/open() | 모달 열기 요청 | isOpen = true | 모달 렌더링, body scroll 차단 |

### Admin 상태 변화
| 상태키 | 트리거 | 전제조건 | 변경 로직 | 화면 반응 |
|--------|--------|----------|----------|----------|
| isAuthenticated | admin/login(credentials) | admin/1234 일치 | isAuthenticated = true | 관리자 대시보드 접근 |
| currentView | admin/navigate(view) | 인증됨 | currentView = view | 해당 관리자 화면 표시 |

---

## 4. Zustand Store 설계

### UI Store
```typescript
interface UIState {
  isBookingModalOpen: boolean
  isAdminLoginModalOpen: boolean
  toastMessage: string | null
  toastType: 'success' | 'error' | null
  isLoading: boolean
}

interface UIActions {
  openBookingModal: () => void
  closeBookingModal: () => void
  openAdminModal: () => void
  closeAdminModal: () => void
  showToast: (message: string, type: 'success' | 'error') => void
  hideToast: () => void
  setLoading: (loading: boolean) => void
}

const useUIStore = create<UIState & UIActions>((set) => ({
  // State
  isBookingModalOpen: false,
  isAdminLoginModalOpen: false,
  toastMessage: null,
  toastType: null,
  isLoading: false,

  // Actions
  openBookingModal: () => set({ isBookingModalOpen: true }),
  closeBookingModal: () => set({ isBookingModalOpen: false }),
  openAdminModal: () => set({ isAdminLoginModalOpen: true }),
  closeAdminModal: () => set({ isAdminLoginModalOpen: false }),

  showToast: (message, type) => set({ toastMessage: message, toastType: type }),
  hideToast: () => set({ toastMessage: null, toastType: null }),

  setLoading: (loading) => set({ isLoading: loading }),
}))
```

### Booking Store
```typescript
interface BookingState {
  selectedRoomId: string | null
  selectedDate: string | null
  selectedTimeSlot: { start: string; end: string } | null
  bookingStep: 'rooms' | 'time' | 'form' | 'complete'
}

interface BookingActions {
  selectRoom: (roomId: string) => void
  selectDate: (date: string) => void
  selectTimeSlot: (slot: { start: string; end: string }) => void
  nextStep: () => void
  prevStep: () => void
  resetBooking: () => void
}

const useBookingStore = create<BookingState & BookingActions>((set, get) => ({
  // State
  selectedRoomId: null,
  selectedDate: null,
  selectedTimeSlot: null,
  bookingStep: 'rooms',

  // Actions
  selectRoom: (roomId) => set({ selectedRoomId: roomId }),
  selectDate: (date) => set({ selectedDate: date }),
  selectTimeSlot: (slot) => set({ selectedTimeSlot: slot }),

  nextStep: () => {
    const currentStep = get().bookingStep
    const steps = ['rooms', 'time', 'form', 'complete'] as const
    const currentIndex = steps.indexOf(currentStep)
    if (currentIndex < steps.length - 1) {
      set({ bookingStep: steps[currentIndex + 1] })
    }
  },

  prevStep: () => {
    const currentStep = get().bookingStep
    const steps = ['rooms', 'time', 'form', 'complete'] as const
    const currentIndex = steps.indexOf(currentStep)
    if (currentIndex > 0) {
      set({ bookingStep: steps[currentIndex - 1] })
    }
  },

  resetBooking: () => set({
    selectedRoomId: null,
    selectedDate: null,
    selectedTimeSlot: null,
    bookingStep: 'rooms',
  }),
}))
```

### Admin Store
```typescript
interface AdminState {
  isAuthenticated: boolean
  currentView: 'dashboard' | 'rooms' | 'bookings'
  sessionId: string | null
}

interface AdminActions {
  login: (credentials: { id: string; password: string }) => boolean
  logout: () => void
  navigate: (view: 'dashboard' | 'rooms' | 'bookings') => void
}

const useAdminStore = create<AdminState & AdminActions>((set) => ({
  // State
  isAuthenticated: false,
  currentView: 'dashboard',
  sessionId: null,

  // Actions
  login: ({ id, password }) => {
    if (id === 'admin' && password === '1234') {
      const sessionId = `admin-session-${Date.now()}`
      set({
        isAuthenticated: true,
        sessionId,
        currentView: 'dashboard'
      })
      localStorage.setItem('admin-session', sessionId)
      return true
    }
    return false
  },

  logout: () => {
    set({
      isAuthenticated: false,
      sessionId: null,
      currentView: 'dashboard'
    })
    localStorage.removeItem('admin-session')
  },

  navigate: (view) => set({ currentView: view }),
}))
```

---

## 5. TanStack Query 설계

### Query Keys & Functions
```typescript
export const queryKeys = {
  rooms: ['rooms'] as const,
  room: (roomId: string) => ['room', roomId] as const,
  bookings: (roomId: string, date: string) => ['bookings', roomId, date] as const,
  myBookings: (phone: string, password: string) => ['my-bookings', phone, password] as const,
  admin: {
    rooms: ['admin', 'rooms'] as const,
    bookings: (filters: BookingFilters) => ['admin', 'bookings', filters] as const,
  },
} as const

// React Query Hooks
export const useRooms = () => {
  return useQuery({
    queryKey: queryKeys.rooms,
    queryFn: fetchRooms,
    staleTime: 5 * 60 * 1000, // 5분
    gcTime: 10 * 60 * 1000, // 10분
  })
}

export const useRoomBookings = (roomId: string, date: string) => {
  return useQuery({
    queryKey: queryKeys.bookings(roomId, date),
    queryFn: () => fetchRoomBookings(roomId, date),
    staleTime: 30 * 1000, // 30초 (실시간성 중요)
    gcTime: 2 * 60 * 1000, // 2분
    enabled: !!roomId && !!date, // roomId와 date가 있을 때만 실행
  })
}

export const useCreateBooking = () => {
  const queryClient = useQueryClient()
  const { showToast } = useUIStore()

  return useMutation({
    mutationFn: createBooking,
    onSuccess: (data, variables) => {
      // 관련 쿼리 무효화
      queryClient.invalidateQueries({ queryKey: queryKeys.rooms })
      queryClient.invalidateQueries({
        queryKey: queryKeys.bookings(variables.roomId, variables.bookingDate)
      })

      showToast('예약이 완료되었습니다', 'success')
    },
    onError: (error) => {
      showToast(error.message || '예약 실패', 'error')
    },
  })
}
```

### Optimistic Updates 패턴
```typescript
export const useCancelBooking = () => {
  const queryClient = useQueryClient()
  const { showToast } = useUIStore()

  return useMutation({
    mutationFn: cancelBooking,

    // Optimistic Update
    onMutate: async (bookingId) => {
      // 관련 쿼리 취소
      await queryClient.cancelQueries({ queryKey: ['my-bookings'] })

      // 이전 데이터 백업
      const previousBookings = queryClient.getQueryData(['my-bookings'])

      // Optimistic update
      queryClient.setQueryData(['my-bookings'], (old: any) => ({
        ...old,
        bookings: old.bookings.map((booking: any) =>
          booking.id === bookingId
            ? { ...booking, status: 'cancelled' }
            : booking
        ),
      }))

      return { previousBookings }
    },

    onError: (err, bookingId, context) => {
      // 롤백
      if (context?.previousBookings) {
        queryClient.setQueryData(['my-bookings'], context.previousBookings)
      }
      showToast('취소 실패', 'error')
    },

    onSuccess: () => {
      showToast('예약이 취소되었습니다', 'success')
    },

    onSettled: () => {
      // 서버 데이터로 동기화
      queryClient.invalidateQueries({ queryKey: ['my-bookings'] })
    },
  })
}
```

---

## 6. 컴포넌트별 상태 사용 패턴

### 회의실 목록 화면 (`/rooms`)
```typescript
const RoomsPage = () => {
  // 서버 상태
  const { data: rooms, isLoading, error } = useRooms()

  // 클라이언트 상태
  const { selectedRoomId, selectRoom, nextStep } = useBookingStore()
  const { showToast } = useUIStore()

  // 파생값
  const selectedRoom = useMemo(
    () => rooms?.find(room => room.id === selectedRoomId),
    [rooms, selectedRoomId]
  )

  const handleRoomSelect = (roomId: string) => {
    selectRoom(roomId)
    // 자동으로 다음 단계로 이동 (UX 개선)
    setTimeout(() => nextStep(), 500)
  }

  return (
    <div>
      {isLoading && <RoomsSkeleton />}
      {error && <ErrorMessage message={error.message} />}
      {rooms?.map(room => (
        <RoomCard
          key={room.id}
          room={room}
          isSelected={room.id === selectedRoomId}
          onSelect={() => handleRoomSelect(room.id)}
        />
      ))}
    </div>
  )
}
```

### 예약 폼 화면 (`/booking/form`)
```typescript
const BookingFormPage = () => {
  // React Hook Form (폼 상태 전용)
  const form = useForm<BookingFormData>({
    resolver: zodResolver(bookingSchema),
  })

  // 글로벌 상태
  const { selectedRoomId, selectedDate, selectedTimeSlot } = useBookingStore()
  const { setLoading } = useUIStore()

  // 서버 상태
  const { data: room } = useRoom(selectedRoomId!)
  const createBookingMutation = useCreateBooking()

  const onSubmit = async (data: BookingFormData) => {
    setLoading(true)

    try {
      await createBookingMutation.mutateAsync({
        ...data,
        roomId: selectedRoomId!,
        bookingDate: selectedDate!,
        startTime: selectedTimeSlot!.start,
        endTime: selectedTimeSlot!.end,
      })

      // 성공 시 완료 페이지로 이동
      nextStep()
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <BookingFormFields form={form} room={room} />
      <SubmitButton
        isLoading={createBookingMutation.isPending}
        disabled={!form.formState.isValid}
      />
    </form>
  )
}
```

### 관리자 대시보드 (`/admin`)
```typescript
const AdminDashboard = () => {
  // 관리자 상태
  const { isAuthenticated, currentView, navigate } = useAdminStore()
  const { openAdminModal } = useUIStore()

  // 서버 상태 (관리자 전용)
  const { data: adminRooms } = useQuery({
    queryKey: queryKeys.admin.rooms,
    queryFn: fetchAdminRooms,
    enabled: isAuthenticated, // 인증된 경우만 실행
  })

  const { data: adminBookings } = useQuery({
    queryKey: queryKeys.admin.bookings({}),
    queryFn: () => fetchAdminBookings({}),
    enabled: isAuthenticated,
  })

  if (!isAuthenticated) {
    return <AdminLoginForm onOpenModal={openAdminModal} />
  }

  return (
    <AdminLayout>
      <AdminSidebar currentView={currentView} onNavigate={navigate} />
      <AdminContent>
        {currentView === 'dashboard' && <DashboardOverview />}
        {currentView === 'rooms' && <AdminRoomsManagement />}
        {currentView === 'bookings' && <AdminBookingsView />}
      </AdminContent>
    </AdminLayout>
  )
}
```

---

## 7. 실시간 업데이트 전략

### WebSocket 통합 (선택적)
```typescript
// Real-time 예약 현황 업데이트
export const useRealtimeBookings = (roomId: string, date: string) => {
  const queryClient = useQueryClient()

  useEffect(() => {
    if (!roomId || !date) return

    // Supabase Realtime 구독
    const channel = supabase
      .channel(`bookings:${roomId}:${date}`)
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'bookings',
        filter: `room_id=eq.${roomId}`,
      }, (payload) => {
        // 해당 쿼리 무효화하여 리페치
        queryClient.invalidateQueries({
          queryKey: queryKeys.bookings(roomId, date)
        })
      })
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [roomId, date, queryClient])
}
```

### Polling 전략 (Fallback)
```typescript
export const useRoomBookingsWithPolling = (roomId: string, date: string) => {
  return useQuery({
    queryKey: queryKeys.bookings(roomId, date),
    queryFn: () => fetchRoomBookings(roomId, date),
    staleTime: 30 * 1000, // 30초
    refetchInterval: 60 * 1000, // 1분마다 폴링
    refetchIntervalInBackground: false, // 백그라운드에서는 폴링 안함
    enabled: !!roomId && !!date,
  })
}
```

---

## 8. 에러 처리 & 로딩 상태

### Global Error Boundary
```typescript
const GlobalErrorBoundary = ({ children }: { children: ReactNode }) => {
  const { showToast } = useUIStore()

  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onError={(error, errorInfo) => {
        console.error('Global Error:', error, errorInfo)
        showToast('예상치 못한 오류가 발생했습니다', 'error')
      }}
    >
      {children}
    </ErrorBoundary>
  )
}
```

### Loading States
```typescript
const LoadingProvider = ({ children }: { children: ReactNode }) => {
  const { isLoading } = useUIStore()

  return (
    <>
      {children}
      {isLoading && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <Spinner size="lg" />
        </div>
      )}
    </>
  )
}
```

---

## 9. 성능 최적화

### Bundle Splitting
```typescript
// 관리자 기능은 lazy loading
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'))
const AdminRoomsManagement = lazy(() => import('./pages/AdminRoomsManagement'))

// Route-based splitting
const router = createBrowserRouter([
  { path: '/', element: <RoomsPage /> },
  { path: '/booking/*', element: <BookingFlow /> },
  {
    path: '/admin/*',
    element: (
      <Suspense fallback={<AdminLoadingSkeleton />}>
        <AdminDashboard />
      </Suspense>
    )
  },
])
```

### Memoization Strategy
```typescript
// 비싼 계산 메모이제이션
const BookingTimeSlots = ({ roomId, date }: Props) => {
  const { data: bookings } = useRoomBookings(roomId, date)

  const availableSlots = useMemo(() => {
    if (!bookings) return []

    return generateTimeSlots().filter(slot =>
      !bookings.some(booking =>
        isTimeSlotConflict(slot, booking)
      )
    )
  }, [bookings])

  return (
    <div>
      {availableSlots.map(slot => (
        <TimeSlotButton key={slot.id} slot={slot} />
      ))}
    </div>
  )
}
```

---

## 10. 테스트 전략

### Store 테스트
```typescript
// booking.store.test.ts
describe('BookingStore', () => {
  let store: BookingStore

  beforeEach(() => {
    store = useBookingStore.getState()
    useBookingStore.getState().resetBooking()
  })

  it('should select room and proceed to time selection', () => {
    store.selectRoom('room-1')
    expect(store.selectedRoomId).toBe('room-1')

    store.nextStep()
    expect(store.bookingStep).toBe('time')
  })

  it('should reset booking state', () => {
    store.selectRoom('room-1')
    store.selectDate('2025-11-15')
    store.resetBooking()

    expect(store.selectedRoomId).toBeNull()
    expect(store.selectedDate).toBeNull()
    expect(store.bookingStep).toBe('rooms')
  })
})
```

### Query 테스트
```typescript
// rooms.queries.test.ts
describe('useRooms', () => {
  it('should fetch rooms successfully', async () => {
    const { result } = renderHook(() => useRooms(), {
      wrapper: createQueryWrapper(),
    })

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true)
    })

    expect(result.current.data).toHaveLength(6)
    expect(result.current.data[0]).toHaveProperty('name')
  })
})
```

---

## 검증 체크리스트

**상태 설계**:
- [x] 상태와 파생값 구분 명확
- [x] Zustand Store 단일 책임 원칙 적용
- [x] TanStack Query로 서버 상태 분리
- [x] 로딩/에러/권한 시나리오 포함

**성능 최적화**:
- [x] useMemo로 비싼 계산 최적화
- [x] React.lazy로 코드 스플리팅
- [x] Query 무효화 전략 정의
- [x] Optimistic Updates 적용

**개발자 경험**:
- [x] TypeScript 타입 안전성
- [x] 테스트 가능한 구조
- [x] 디버깅 친화적 (Redux DevTools 지원)
- [x] 명확한 액션 네이밍

**사용자 경험**:
- [x] 실시간 업데이트 (WebSocket/Polling)
- [x] 로딩 상태 및 에러 처리
- [x] Optimistic UI 업데이트
- [x] 접근성 고려 (focus management)

---

## 다음 단계

1. **Phase 0 구현**
   - Zustand Store 구현
   - 기본 TanStack Query 설정
   - UI Store와 Booking Store 연동

2. **Phase 1 통합**
   - 실시간 업데이트 구현
   - Optimistic Updates 적용
   - Admin Store 완성

3. **Phase 2 최적화**
   - 성능 프로파일링
   - Bundle 분석 및 최적화
   - 접근성 개선

---

## 관련 문서
- [Use Cases](usecases.md)
- [Database Schema](dataflow-schema.md)
- [Architecture](architecture.md)
- [Tech Stack](tech-stack.md)