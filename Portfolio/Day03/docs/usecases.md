# Use Cases: 회의실 예약 시스템

## Meta
- 작성일: 2025-11-07
- 작성자: Portfolio Project - Agent 6 (usecase-generator)
- 버전: 1.0
- Flow 매핑: userflow.md 8개 기능

---

## 🔍 전제 검증 완료

- **Userflow 기능**: 8개 (회의실 목록 조회 ~ 어드민 예약 현황 조회)
- **관련 테이블**: conference_rooms, bookings, admin_sessions
- **용어 충돌**: 없음
- **최종 수정**: 2025-11-07

✅ 유스케이스 작성 완료

---

## 목차

1. [UC-001: 회의실 목록 조회](#uc-001-회의실-목록-조회)
2. [UC-002: 날짜/시간대 선택](#uc-002-날짜시간대-선택)
3. [UC-003: 예약 정보 입력 및 등록](#uc-003-예약-정보-입력-및-등록)
4. [UC-004: 예약 조회](#uc-004-예약-조회)
5. [UC-005: 예약 취소](#uc-005-예약-취소)
6. [UC-006: 테스트 관리자 접근](#uc-006-테스트-관리자-접근)
7. [UC-007: 어드민 회의실 관리](#uc-007-어드민-회의실-관리)
8. [UC-008: 어드민 예약 현황 조회](#uc-008-어드민-예약-현황-조회)

---

# UC-001: 회의실 목록 조회

## Meta
- **UC ID**: UC-001
- **Flow ID**: UF-001 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0
- **Related**: [PRD](prd/conference_room_booking_prd_v1.md), [Userflow](userflow.md), [Database](dataflow-schema.md)

---

## Primary Actor
메인 페이지 방문자 (로그인 불필요)

---

## Precondition (사용자 관점)
- 사용자가 웹 애플리케이션에 접속한다
- 네트워크 연결이 정상이다

---

## Trigger
사용자가 메인 페이지에 접속하거나 "회의실 예약" 버튼 클릭

---

## Data Contract

### Request
- 없음 (조회만 수행)

### Response (Success)
```json
{
  "rooms": [
    {
      "id": "01HP9X...",
      "name": "아이디어룸",
      "location": "2층 서쪽",
      "capacity": 4,
      "operatingHours": {"start": "09:00", "end": "18:00"},
      "isAvailableNow": true,
      "todayBookings": ["10:00-11:00", "14:00-15:00"]
    }
  ]
}
```

### Error Shape
```json
{
  "code": "SYS-001",
  "message": "서비스 일시 중단. 잠시 후 다시 시도해주세요"
}
```

---

## Main Scenario

1. **페이지 접속** (Actor: User)
   - 메인 페이지 접속 또는 "회의실 예약" 버튼 클릭

2. **데이터 조회** (Actor: System)
   - 활성 회의실 목록 조회 (conference_rooms WHERE is_active = TRUE)
   - 오늘 예약 현황 조회 (실시간 상태 표시)

3. **UI 렌더링** (Actor: Presentation)
   - 회의실 카드 목록 표시 (이름, 위치, 수용인원)
   - 즉시 예약 가능 상태 표시
   - 수용인원별 필터링 옵션 제공

4. **사이드이펙트** (Actor: System)
   - 페이지 방문 로그 기록 (@SPEC:UC001-LOG-001)

---

## Edge Cases

### EC-001: DB 연결 실패
- **조건**: 데이터베이스 연결 오류
- **처리**: 500 Internal Server Error
- **결과**: "서비스 일시 중단" 메시지 + 새로고침 버튼
- **보장**: 로딩 상태 표시, 재시도 옵션 제공

### EC-002: 회의실 데이터 없음
- **조건**: conference_rooms 테이블이 비어있음
- **처리**: 200 OK with empty array
- **결과**: "등록된 회의실이 없습니다" 안내
- **보장**: UI 깨짐 없음

---

## Business Rules (EARS 기반)

### Ubiquitous (항상)
- **BR-001**: 시스템은 활성 회의실만 표시해야 한다
  - @SPEC:UC001-UBI-001
  - Validation: SQL WHERE is_active = TRUE

### Event-driven (이벤트 발생 시)
- **BR-002**: WHEN 사용자가 페이지에 접속하면 실시간 예약 현황을 조회해야 한다
  - @SPEC:UC001-EVT-001
  - Validation: API Response에 todayBookings 포함

### State-driven (상태 기반)
- **BR-003**: WHILE 회의실이 비활성 상태일 때 목록에서 제외해야 한다
  - @SPEC:UC001-STA-001
  - Validation: Repository Layer

---

## Guarantees

### Success
- ✅ 활성 회의실 목록 반환
- ✅ 실시간 예약 현황 표시
- ✅ 페이지 방문 로그 완료

### Failure
- ✅ 에러 메시지 표시
- ✅ 재시도 옵션 제공
- ✅ 로딩 상태 관리

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 정상 목록 조회
```gherkin
Given 활성 회의실이 6개 존재한다
When 메인 페이지에 접속한다
Then 200 OK 응답을 받는다
  And 6개 회의실 카드가 표시된다
  And 각 카드에 이름, 위치, 수용인원이 보인다
  And 실시간 예약 상태가 표시된다
```

---

# UC-002: 날짜/시간대 선택

## Meta
- **UC ID**: UC-002
- **Flow ID**: UF-002 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0

---

## Primary Actor
회의실을 예약하려는 사용자

---

## Precondition (사용자 관점)
- 사용자가 회의실을 선택했다
- 회의실 상세 페이지에 접속한 상태다

---

## Trigger
회의실 카드에서 "예약하기" 버튼 클릭

---

## Data Contract

### Request
```json
{
  "roomId": "01HP9X...",
  "date": "2025-11-15"
}
```

### Response (Success)
```json
{
  "room": {
    "id": "01HP9X...",
    "name": "아이디어룸",
    "location": "2층 서쪽",
    "capacity": 4
  },
  "availableSlots": [
    {"start": "09:00", "end": "10:00", "isAvailable": true},
    {"start": "10:00", "end": "11:00", "isAvailable": false},
    {"start": "11:00", "end": "12:00", "isAvailable": true}
  ]
}
```

---

## Main Scenario

1. **회의실 선택** (Actor: User)
   - 회의실 카드에서 "예약하기" 클릭
   - 선택된 회의실 정보 표시

2. **날짜 선택** (Actor: User)
   - 달력 컴포넌트에서 날짜 선택 (오늘 이후만 가능)

3. **시간대 조회** (Actor: System)
   - 선택된 날짜의 예약 현황 조회
   - 9시-18시 1시간 단위 슬롯 생성
   - 예약된 시간은 비활성화 처리

4. **시간 선택** (Actor: User)
   - 빈 시간대 클릭
   - "다음 단계" 버튼 활성화

5. **임시 저장** (Actor: System)
   - 선택 정보 세션/로컬스토리지 저장 (@SPEC:UC002-TMP-001)

---

## Business Rules (EARS 기반)

### Ubiquitous (항상)
- **BR-001**: 시스템은 과거 날짜 선택을 방지해야 한다
  - @SPEC:UC002-UBI-001
  - Validation: 달력 컴포넌트에서 비활성화

### Event-driven (이벤트 발생 시)
- **BR-002**: WHEN 날짜가 선택되면 해당 날짜의 예약 현황을 조회해야 한다
  - @SPEC:UC002-EVT-001
  - Validation: API 호출로 실시간 데이터 조회

### Constraints (제약)
- **BR-003**: 운영 시간은 9시-18시 1시간 단위로 제한해야 한다
  - @SPEC:UC002-CON-001
  - Validation: 시간 슬롯 생성 로직

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 빈 시간대 선택 성공
```gherkin
Given 사용자가 "아이디어룸"을 선택했다
  And 2025-11-15에 10시-11시가 예약되어 있다
When 2025-11-15를 선택한다
Then 9시-10시는 선택 가능하다
  And 10시-11시는 비활성화되어 있다
  And 11시-12시는 선택 가능하다
```

---

# UC-003: 예약 정보 입력 및 등록

## Meta
- **UC ID**: UC-003
- **Flow ID**: UF-003 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0

---

## Primary Actor
예약을 등록하려는 사용자

---

## Precondition (사용자 관점)
- 사용자가 회의실과 날짜/시간을 선택했다
- 예약 정보 입력 페이지에 있다

---

## Trigger
날짜/시간 선택 후 "예약 정보 입력" 버튼 클릭

---

## Data Contract

### Request
```json
{
  "roomId": "01HP9X...",
  "userName": "김철수",
  "phone": "010-1234-5678",
  "purpose": "프로젝트 회의 진행을 위한 공간 활용",
  "password": "1234",
  "bookingDate": "2025-11-15",
  "startTime": "14:00",
  "endTime": "15:00",
  "agreedToPrivacyPolicy": true
}
```

### Response (Success)
```json
{
  "bookingId": "01HP9X...",
  "confirmationNumber": "BOOK-20251115-0001",
  "room": {
    "name": "아이디어룸",
    "location": "2층 서쪽"
  },
  "bookingDate": "2025-11-15",
  "startTime": "14:00",
  "endTime": "15:00",
  "createdAt": "2025-11-07T12:00:00Z"
}
```

### Error Shape
```json
{
  "code": "VAL-003",
  "message": "이미 예약된 시간입니다. 다른 시간을 선택해주세요",
  "field": "timeSlot"
}
```

---

## Main Scenario

1. **입력 필드 검증** (Actor: Presentation)
   - 예약자명: 2-20자 (@SPEC:UC003-VAL-001)
   - 휴대폰번호: 010-XXXX-XXXX 형식 (@SPEC:UC003-VAL-002)
   - 예약 목적: 10-100자 (@SPEC:UC003-VAL-003)
   - 비밀번호: 4-8자 숫자 (@SPEC:UC003-VAL-004)

2. **중복 검증** (Actor: Application)
   - 동일 시간대 예약 존재 여부 확인
   - 동일 휴대폰번호 중복 예약 방지

3. **데이터 저장** (Actor: Infrastructure)
   - 비밀번호 해싱 처리 (bcrypt)
   - bookings 테이블에 INSERT
   - 확인번호 자동 생성 (BOOK-YYYYMMDD-XXXX)

4. **응답 반환** (Actor: System)
   - 201 Created
   - 예약 완료 페이지로 이동
   - 확인번호 표시 (@SPEC:UC003-CONF-001)

---

## Edge Cases

### EC-001: 동시 예약 충돌
- **조건**: 동일 시간대에 다른 사용자가 먼저 예약
- **처리**: 409 Conflict, VAL-003
- **결과**: "이미 예약된 시간입니다" + 시간 재선택 유도
- **보장**: 입력 데이터 보존, 트랜잭션 롤백

### EC-002: 휴대폰번호 형식 오류
- **조건**: 올바르지 않은 휴대폰번호 형식
- **처리**: 400 Bad Request, VAL-002
- **결과**: "올바른 휴대폰번호를 입력하세요 (010-XXXX-XXXX)"
- **보장**: 실시간 형식 검증

---

## Business Rules (EARS 기반)

### Ubiquitous (항상)
- **BR-001**: 시스템은 휴대폰번호 형식(010-XXXX-XXXX)을 검증해야 한다
  - @SPEC:UC003-UBI-001
  - Validation: Zod schema (Presentation)

### Event-driven (이벤트 발생 시)
- **BR-002**: WHEN 유효한 예약 정보가 제공되면 예약을 생성해야 한다
  - @SPEC:UC003-EVT-001
  - Validation: Application Use Case

### Constraints (제약)
- **BR-003**: 비밀번호 해싱은 bcrypt salt rounds ≥ 10이어야 한다
  - @SPEC:UC003-CON-001
  - Validation: Infrastructure Layer

### Optional (선택)
- **BR-004**: WHERE 중복 예약 방지 기능이 활성화되면 동일 시간대 예약을 차단할 수 있다
  - @SPEC:UC003-OPT-001
  - Validation: DB Unique Constraint

---

## Error Catalogue

| Code | HTTP | Message | Recovery |
|------|------|---------|----------|
| VAL-001 | 400 | 예약자명은 2-20자로 입력하세요 | 길이 조정 |
| VAL-002 | 400 | 올바른 휴대폰번호를 입력하세요 | 형식 수정 |
| VAL-003 | 409 | 이미 예약된 시간입니다 | 다른 시간 선택 |
| VAL-004 | 400 | 비밀번호는 4-8자 숫자로 입력하세요 | 규칙 준수 |
| VAL-005 | 400 | 개인정보 처리 방침에 동의해주세요 | 체크박스 선택 |

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 신규 예약 성공
```gherkin
Given 사용자가 빈 시간대를 선택했다
  And 모든 필수 정보를 입력했다
  And 개인정보 처리에 동의했다
When 예약 등록을 요청한다
Then 201 Created 응답을 받는다
  And 확인번호가 반환된다
  And "예약 완료" 메시지가 보인다
```

### Scenario 2: 동시 예약 충돌
```gherkin
Given 다른 사용자가 14시-15시를 예약했다
When 동일 시간대로 예약을 요청한다
Then 409 Conflict 응답을 받는다
  And 에러 코드는 "VAL-003"이다
  And 입력값은 유지된다
```

---

# UC-004: 예약 조회

## Meta
- **UC ID**: UC-004
- **Flow ID**: UF-004 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0

---

## Primary Actor
예약 내역을 확인하려는 사용자

---

## Precondition (사용자 관점)
- 사용자가 과거에 예약을 생성했다
- 휴대폰번호와 비밀번호를 기억하고 있다

---

## Trigger
메인 페이지에서 "내 예약 조회" 버튼 클릭

---

## Data Contract

### Request
```json
{
  "phone": "010-1234-5678",
  "password": "1234"
}
```

### Response (Success)
```json
{
  "bookings": [
    {
      "id": "01HP9X...",
      "confirmationNumber": "BOOK-20251115-0001",
      "userName": "김철수",
      "purpose": "프로젝트 회의",
      "bookingDate": "2025-11-15",
      "startTime": "14:00",
      "endTime": "15:00",
      "status": "confirmed",
      "room": {
        "name": "아이디어룸",
        "location": "2층 서쪽"
      },
      "createdAt": "2025-11-07T12:00:00Z"
    }
  ]
}
```

---

## Main Scenario

1. **인증 정보 입력** (Actor: User)
   - 휴대폰번호, 비밀번호 입력

2. **형식 검증** (Actor: Presentation)
   - 휴대폰번호 형식 검증 (@SPEC:UC004-VAL-001)

3. **예약 조회** (Actor: Application)
   - 휴대폰번호로 예약 내역 조회
   - 비밀번호 해시 비교 검증

4. **결과 정렬** (Actor: System)
   - 진행 예정 → 완료 → 취소 순서
   - 각 예약별 "상세보기", "취소하기" 버튼 제공

5. **조회 로그** (Actor: System)
   - 조회 로그 기록 (@SPEC:UC004-LOG-001)

---

## Edge Cases

### EC-001: 휴대폰번호 미존재
- **조건**: 등록된 예약 내역이 없음
- **처리**: 200 OK with empty array
- **결과**: "등록된 예약 내역이 없습니다"
- **보장**: UI 깨짐 없음

### EC-002: 비밀번호 불일치
- **조건**: 잘못된 비밀번호 입력
- **처리**: 401 Unauthorized, AUTH-001
- **결과**: "비밀번호가 일치하지 않습니다"
- **보장**: 3회 실패 시 5분 잠금

### EC-003: 연속 실패 시도
- **조건**: 5분 내 3회 이상 실패
- **처리**: 429 Too Many Requests, RATE-001
- **결과**: "보안을 위해 5분 후 다시 시도해주세요"
- **보장**: Rate limiting 적용

---

## Business Rules (EARS 기반)

### Ubiquitous (항상)
- **BR-001**: 시스템은 비밀번호 해시 비교로 인증해야 한다
  - @SPEC:UC004-UBI-001
  - Validation: bcrypt.compare()

### State-driven (상태 기반)
- **BR-002**: WHILE 연속 실패 시도 중일 때 접근을 차단해야 한다
  - @SPEC:UC004-STA-001
  - Validation: Rate limiting middleware

### Event-driven (이벤트 발생 시)
- **BR-003**: WHEN 조회가 성공하면 예약 목록을 날짜 순으로 정렬해야 한다
  - @SPEC:UC004-EVT-001
  - Validation: ORDER BY booking_date DESC

---

## Error Catalogue

| Code | HTTP | Message | Recovery |
|------|------|---------|----------|
| VAL-001 | 400 | 올바른 휴대폰번호를 입력하세요 | 형식 수정 |
| AUTH-001 | 401 | 비밀번호가 일치하지 않습니다 | 비밀번호 재입력 |
| RATE-001 | 429 | 5분 후 다시 시도해주세요 | 대기 후 재시도 |

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 예약 조회 성공
```gherkin
Given 사용자가 2건의 예약을 가지고 있다
When 올바른 휴대폰번호와 비밀번호를 입력한다
Then 200 OK 응답을 받는다
  And 2건의 예약이 표시된다
  And 예약은 날짜 순으로 정렬되어 있다
```

---

# UC-005: 예약 취소

## Meta
- **UC ID**: UC-005
- **Flow ID**: UF-005 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0

---

## Primary Actor
예약을 취소하려는 사용자

---

## Precondition (사용자 관점)
- 사용자가 예약 조회를 완료했다
- 취소하려는 예약이 '확정' 상태다
- 예약 시작 1시간 전이다

---

## Trigger
예약 조회 결과에서 "취소하기" 버튼 클릭

---

## Data Contract

### Request
```json
{
  "bookingId": "01HP9X...",
  "cancelReason": "일정 변경"
}
```

### Response (Success)
```json
{
  "bookingId": "01HP9X...",
  "confirmationNumber": "BOOK-20251115-0001",
  "status": "cancelled",
  "cancelledAt": "2025-11-07T12:00:00Z",
  "cancelReason": "일정 변경"
}
```

---

## Main Scenario

1. **취소 가능성 검증** (Actor: System)
   - 예약 상태 확인 (confirmed만 취소 가능)
   - 취소 가능 시점 검증 (시작 1시간 전까지)

2. **취소 확인** (Actor: User)
   - 취소 확인 팝업 표시
   - 취소 사유 선택 (드롭다운)

3. **예약 취소 처리** (Actor: Application)
   - status를 'cancelled'로 업데이트
   - cancelled_at, cancelled_reason 기록

4. **시간대 해제** (Actor: System)
   - 해당 시간대를 다시 예약 가능 상태로 변경
   - 실시간 업데이트 (@SPEC:UC005-RT-001)

5. **성공 알림** (Actor: Presentation)
   - "예약이 취소되었습니다" 메시지
   - 예약 목록 새로고침

---

## Edge Cases

### EC-001: 이미 취소된 예약
- **조건**: 예약 상태가 'cancelled'
- **처리**: 400 Bad Request, BIZ-001
- **결과**: "이미 취소된 예약입니다"
- **보장**: "취소하기" 버튼 비활성화

### EC-002: 과거 예약
- **조건**: 예약 날짜가 과거
- **처리**: 400 Bad Request, BIZ-002
- **결과**: "완료된 예약은 취소할 수 없습니다"
- **보장**: 버튼 비활성화

### EC-003: 취소 불가 시점
- **조건**: 예약 시작 1시간 전 경과
- **처리**: 400 Bad Request, BIZ-003
- **결과**: "예약 시작 1시간 전까지만 취소 가능합니다"
- **보장**: 실시간 시간 검증

---

## Business Rules (EARS 기반)

### State-driven (상태 기반)
- **BR-001**: WHILE 예약이 'confirmed' 상태일 때만 취소할 수 있다
  - @SPEC:UC005-STA-001
  - Validation: Status check before update

### Constraints (제약)
- **BR-002**: 예약 시작 1시간 전까지만 취소 가능해야 한다
  - @SPEC:UC005-CON-001
  - Validation: Time comparison logic

### Event-driven (이벤트 발생 시)
- **BR-003**: WHEN 예약이 취소되면 해당 시간대를 다시 예약 가능하게 해야 한다
  - @SPEC:UC005-EVT-001
  - Validation: Real-time availability update

---

## Error Catalogue

| Code | HTTP | Message | Recovery |
|------|------|---------|----------|
| BIZ-001 | 400 | 이미 취소된 예약입니다 | 새로고침 |
| BIZ-002 | 400 | 완료된 예약은 취소할 수 없습니다 | 고객센터 문의 |
| BIZ-003 | 400 | 예약 시작 1시간 전까지만 취소 가능합니다 | - |

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 예약 취소 성공
```gherkin
Given 사용자가 내일 14시 예약을 가지고 있다
  And 현재 시간이 내일 12시 이전이다
When "취소하기" 버튼을 클릭한다
  And 취소를 확인한다
Then 200 OK 응답을 받는다
  And 예약 상태가 "취소됨"으로 변경된다
  And "예약이 취소되었습니다" 메시지가 보인다
```

---

# UC-006: 테스트 관리자 접근

## Meta
- **UC ID**: UC-006
- **Flow ID**: UF-006 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0

---

## Primary Actor
포트폴리오 검토자 (채용 담당자, 개발팀)

---

## Precondition (사용자 관점)
- 사용자가 관리자 기능을 확인하려고 한다
- 테스트 계정 정보를 알고 있거나 힌트가 제공된다

---

## Trigger
URL 직접 접근 (`/admin`) 또는 메인에서 "관리자 모드" 버튼 클릭

---

## Data Contract

### Request
```json
{
  "adminId": "admin",
  "password": "1234"
}
```

### Response (Success)
```json
{
  "sessionId": "01HP9X...",
  "adminId": "admin",
  "loginTime": "2025-11-07T12:00:00Z",
  "isTestAccount": true
}
```

---

## Main Scenario

1. **로그인 폼 표시** (Actor: Presentation)
   - 간단한 로그인 폼 렌더링
   - 테스트 계정 힌트 표시

2. **하드코딩 검증** (Actor: Application)
   - 입력값과 테스트 계정(`admin` / `1234`) 비교
   - 클라이언트 사이드 검증

3. **세션 생성** (Actor: System)
   - admin_sessions 테이블에 로그인 기록
   - 로컬스토리지에 간단한 플래그 저장

4. **관리자 대시보드 접근** (Actor: Presentation)
   - "테스트 관리자 모드" 표시
   - 회의실 관리, 예약 현황 메뉴 제공

---

## Edge Cases

### EC-001: 잘못된 정보
- **조건**: admin/1234가 아닌 다른 정보 입력
- **처리**: 클라이언트 사이드 검증
- **결과**: "테스트 계정: admin / 1234" 힌트 표시
- **보장**: 자동 입력 버튼 제공

### EC-002: 빈 필드
- **조건**: ID 또는 비밀번호 미입력
- **처리**: 폼 검증
- **결과**: 기본값 자동 입력 옵션 제공
- **보장**: 접근성 향상

---

## Business Rules (EARS 기반)

### Ubiquitous (항상)
- **BR-001**: 시스템은 테스트 계정(admin/1234)만 허용해야 한다
  - @SPEC:UC006-UBI-001
  - Validation: 하드코딩된 값 비교

### Optional (선택)
- **BR-002**: WHERE 포트폴리오 검토 중이면 힌트를 제공할 수 있다
  - @SPEC:UC006-OPT-001
  - Validation: UI에 힌트 표시

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 테스트 관리자 로그인 성공
```gherkin
Given 사용자가 관리자 로그인 페이지에 있다
When "admin"과 "1234"를 입력한다
Then 로그인이 성공한다
  And 관리자 대시보드가 표시된다
  And "테스트 관리자 모드" 라벨이 보인다
```

---

# UC-007: 어드민 회의실 관리

## Meta
- **UC ID**: UC-007
- **Flow ID**: UF-007 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0

---

## Primary Actor
테스트 관리자

---

## Precondition (사용자 관점)
- 테스트 관리자로 로그인했다
- 관리자 대시보드에 접속한 상태다

---

## Trigger
테스트 관리자 로그인 후 "회의실 관리" 메뉴 클릭

---

## Data Contract

### Request (회의실 추가)
```json
{
  "name": "신규회의실",
  "location": "5층 중앙",
  "capacity": 8,
  "operatingHours": {"start": "09:00", "end": "18:00"}
}
```

### Response (Success)
```json
{
  "id": "01HP9X...",
  "name": "신규회의실",
  "location": "5층 중앙",
  "capacity": 8,
  "operatingHours": {"start": "09:00", "end": "18:00"},
  "isActive": true,
  "createdAt": "2025-11-07T12:00:00Z"
}
```

---

## Main Scenario

1. **회의실 목록 조회** (Actor: System)
   - 모든 회의실 조회 (활성/비활성 포함)
   - 각 회의실별 예약 통계 표시

2. **CRUD 기능 제공** (Actor: Presentation)
   - "회의실 추가" / "수정" / "삭제" 버튼
   - 모달 형태의 입력 폼

3. **데이터 검증** (Actor: Application)
   - 회의실명 중복 검사
   - 필수 필드 검증 (이름, 위치, 수용인원)

4. **데이터 저장** (Actor: Infrastructure)
   - conference_rooms 테이블 UPDATE/INSERT/DELETE
   - 예약 데이터 영향도 고려

5. **UI 업데이트** (Actor: Presentation)
   - 성공 토스트 메시지
   - 목록 새로고침

---

## Edge Cases

### EC-001: 중복 회의실명
- **조건**: 동일한 이름의 회의실 존재
- **처리**: 400 Bad Request, VAL-001
- **결과**: "동일한 이름의 회의실이 존재합니다"
- **보장**: 입력 데이터 보존

### EC-002: 예약 중인 회의실 삭제
- **조건**: 확정된 예약이 있는 회의실 삭제 시도
- **처리**: 비활성화 처리 (is_active = FALSE)
- **결과**: "예약이 있는 회의실은 비활성화됩니다"
- **보장**: 예약 데이터 보존

---

## Business Rules (EARS 기반)

### Ubiquitous (항상)
- **BR-001**: 시스템은 회의실명 중복을 방지해야 한다
  - @SPEC:UC007-UBI-001
  - Validation: DB UNIQUE constraint

### Event-driven (이벤트 발생 시)
- **BR-002**: WHEN 예약이 있는 회의실을 삭제하면 비활성화 처리해야 한다
  - @SPEC:UC007-EVT-001
  - Validation: Soft delete 로직

### Constraints (제약)
- **BR-003**: 수용인원은 1-100명 범위여야 한다
  - @SPEC:UC007-CON-001
  - Validation: CHECK constraint

---

## Error Catalogue

| Code | HTTP | Message | Recovery |
|------|------|---------|----------|
| VAL-001 | 400 | 동일한 이름의 회의실이 존재합니다 | 다른 이름 사용 |
| VAL-002 | 400 | 필수 입력사항입니다 | 빈 필드 입력 |
| VAL-003 | 400 | 수용인원은 1-100명 사이로 입력하세요 | 범위 조정 |

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 회의실 추가 성공
```gherkin
Given 테스트 관리자로 로그인했다
When 새로운 회의실 정보를 입력한다
  And "저장" 버튼을 클릭한다
Then 201 Created 응답을 받는다
  And "저장되었습니다" 메시지가 보인다
  And 회의실 목록이 업데이트된다
```

---

# UC-008: 어드민 예약 현황 조회

## Meta
- **UC ID**: UC-008
- **Flow ID**: UF-008 (from userflow.md)
- **Created**: 2025-11-07
- **Version**: 1.0

---

## Primary Actor
테스트 관리자

---

## Precondition (사용자 관점)
- 테스트 관리자로 로그인했다
- 관리자 대시보드에 접속한 상태다

---

## Trigger
테스트 관리자 로그인 후 "예약 현황" 메뉴 클릭

---

## Data Contract

### Request
```json
{
  "startDate": "2025-11-01",
  "endDate": "2025-11-07",
  "roomId": "01HP9X...",
  "status": "confirmed"
}
```

### Response (Success)
```json
{
  "bookings": [
    {
      "id": "01HP9X...",
      "confirmationNumber": "BOOK-20251115-0001",
      "userName": "김철수",
      "phone": "010-****-5678",
      "purpose": "프로젝트 회의",
      "bookingDate": "2025-11-15",
      "startTime": "14:00",
      "endTime": "15:00",
      "status": "confirmed",
      "room": {
        "name": "아이디어룸",
        "location": "2층 서쪽",
        "capacity": 4
      },
      "createdAt": "2025-11-07T12:00:00Z"
    }
  ],
  "statistics": {
    "totalBookings": 25,
    "confirmedBookings": 22,
    "cancelledBookings": 3,
    "cancellationRate": 12.0,
    "roomsUsed": 4,
    "daysWithBookings": 5
  }
}
```

---

## Main Scenario

1. **필터 설정** (Actor: User)
   - 조회 날짜 범위 (기본: 오늘부터 7일)
   - 회의실 필터 (전체 또는 특정 회의실)
   - 예약 상태 필터 (전체/확정/취소)

2. **데이터 조회** (Actor: System)
   - 필터 조건에 따른 예약 데이터 조회
   - 개인정보 마스킹 처리 (휴대폰번호 일부)

3. **결과 표시** (Actor: Presentation)
   - 날짜별, 회의실별 그룹화
   - 예약 상세 정보 테이블
   - 통계 정보 차트

4. **부가 기능** (Actor: System)
   - 엑셀 다운로드 기능
   - 페이징 처리 (대용량 데이터)

---

## Edge Cases

### EC-001: 데이터 없음
- **조건**: 선택한 기간에 예약 없음
- **처리**: 200 OK with empty array
- **결과**: "선택한 기간에 예약 내역이 없습니다"
- **보장**: 빈 테이블 상태 표시

### EC-002: 대용량 데이터
- **조건**: 조회 결과가 1000건 초과
- **처리**: 페이징 처리 적용
- **결과**: "데이터가 많아 시간이 걸릴 수 있습니다" 알림
- **보장**: 성능 최적화

---

## Business Rules (EARS 기반)

### Ubiquitous (항상)
- **BR-001**: 시스템은 개인정보를 마스킹 처리해야 한다
  - @SPEC:UC008-UBI-001
  - Validation: 휴대폰번호 일부 숨김 (010-****-5678)

### Event-driven (이벤트 발생 시)
- **BR-002**: WHEN 조회 요청이 들어오면 통계 정보를 계산해야 한다
  - @SPEC:UC008-EVT-001
  - Validation: 취소율, 이용률 계산

### Constraints (제약)
- **BR-003**: 조회 기간은 최대 90일로 제한해야 한다
  - @SPEC:UC008-CON-001
  - Validation: 날짜 범위 검증

---

## Acceptance Criteria (Gherkin)

### Scenario 1: 예약 현황 조회 성공
```gherkin
Given 테스트 관리자로 로그인했다
  And 최근 7일간 예약이 10건 존재한다
When "예약 현황" 메뉴를 클릭한다
Then 200 OK 응답을 받는다
  And 10건의 예약이 표시된다
  And 통계 정보가 계산되어 있다
  And 휴대폰번호가 마스킹되어 있다
```

---

## 🔗 Traceability Matrix

| UC ID | Related Files | @SPEC:ID Mapping |
|-------|---------------|------------------|
| UC-001 | `/app/rooms/page.tsx`, `/lib/api/rooms.ts` | UC001-UBI-001, UC001-EVT-001, UC001-STA-001 |
| UC-002 | `/app/booking/[roomId]/page.tsx` | UC002-UBI-001, UC002-EVT-001, UC002-CON-001 |
| UC-003 | `/app/booking/form/page.tsx` | UC003-UBI-001, UC003-EVT-001, UC003-CON-001, UC003-OPT-001 |
| UC-004 | `/app/my-bookings/page.tsx` | UC004-UBI-001, UC004-STA-001, UC004-EVT-001 |
| UC-005 | `/app/api/bookings/cancel/route.ts` | UC005-STA-001, UC005-CON-001, UC005-EVT-001 |
| UC-006 | `/app/admin/login/page.tsx` | UC006-UBI-001, UC006-OPT-001 |
| UC-007 | `/app/admin/rooms/page.tsx` | UC007-UBI-001, UC007-EVT-001, UC007-CON-001 |
| UC-008 | `/app/admin/dashboard/page.tsx` | UC008-UBI-001, UC008-EVT-001, UC008-CON-001 |

---

## 🚀 Implementation Notes

### Phase 0 구현 우선순위
1. **UC-001, UC-002, UC-003**: 핵심 예약 플로우
2. **UC-004, UC-005**: 사용자 예약 관리
3. **UC-006, UC-007, UC-008**: 관리자 기능

### 테스트 전략
- **Unit Tests**: 각 UC의 비즈니스 로직 검증
- **Integration Tests**: API 엔드포인트 테스트
- **E2E Tests**: 전체 사용자 여정 검증

### 성능 고려사항
- **UC-001**: 회의실 목록 캐싱
- **UC-002**: 실시간 예약 현황 최적화
- **UC-008**: 대용량 데이터 페이징

---

## Related Documents
- [PRD](prd/conference_room_booking_prd_v1.md)
- [Userflow](userflow.md)
- [Database Schema](dataflow-schema.md)
- [Architecture](architecture.md)