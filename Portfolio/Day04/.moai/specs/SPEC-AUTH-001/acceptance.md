---
title: "로그인 시스템 수락 기준서"
spec_id: "SPEC-AUTH-001"
version: "1.0"
status: "draft"
date: "2025-01-19"
---

# @ACCEPTANCE:AUTH-001 로그인 시스템 수락 기준서

## 개요

본 문서는 SPEC-AUTH-001 로그인 시스템의 수락 기준을 Given-When-Then 형식으로 정의합니다. 모든 테스트 시나리오는 자동화된 테스트로 구현되어야 하며, 배포 전 100% 통과해야 합니다.

## 회원가입 기능 수락 기준

### AC-001: 정상적인 회원가입

**Given** 사용자가 회원가입 페이지에 접근하고
**When** 유효한 이메일(test@example.com), 강력한 비밀번호(SecurePass123!), 이름(홍길동)을 입력하고 회원가입 버튼을 클릭하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 회원가입 성공 메시지가 표시된다
- 데이터베이스에 새 사용자 레코드가 생성된다
- 비밀번호는 암호화되어 저장된다
- 이메일 인증 메일이 발송된다
- HTTP 201 상태 코드가 반환된다

```javascript
// 테스트 코드 예시
describe('회원가입 성공 시나리오', () => {
  it('should create user with valid input', async () => {
    const userData = {
      email: 'test@example.com',
      password: 'SecurePass123!',
      name: '홍길동'
    };

    const response = await request(app)
      .post('/api/auth/register')
      .send(userData)
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.message).toContain('회원가입이 완료');

    // 데이터베이스 확인
    const user = await prisma.user.findUnique({
      where: { email: userData.email }
    });
    expect(user).toBeTruthy();
    expect(user.email_verified).toBe(false);
  });
});
```

### AC-002: 이메일 중복 방지

**Given** 이미 등록된 이메일(existing@example.com)이 데이터베이스에 존재하고
**When** 동일한 이메일로 회원가입을 시도하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- "이미 등록된 이메일입니다" 오류 메시지가 표시된다
- 새로운 사용자 레코드가 생성되지 않는다
- HTTP 409 상태 코드가 반환된다

### AC-003: 비밀번호 강도 검증

**Given** 사용자가 회원가입 폼에 접근하고
**When** 약한 비밀번호(123456)를 입력하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- "비밀번호는 최소 8자 이상이어야 하며, 대소문자, 숫자, 특수문자를 포함해야 합니다" 오류 메시지가 표시된다
- 회원가입이 진행되지 않는다
- HTTP 400 상태 코드가 반환된다

### AC-004: 필수 필드 검증

**Given** 사용자가 회원가입 폼에 접근하고
**When** 이메일 필드를 비워두고 회원가입을 시도하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- "이메일은 필수 입력 항목입니다" 오류 메시지가 표시된다
- 폼 제출이 차단된다
- HTTP 400 상태 코드가 반환된다

## 로그인 기능 수락 기준

### AC-005: 정상적인 로그인

**Given** 유효한 사용자 계정(test@example.com / SecurePass123!)이 존재하고 이메일 인증이 완료된 상태에서
**When** 올바른 이메일과 비밀번호로 로그인을 시도하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 로그인 성공 메시지가 표시된다
- 유효한 JWT 액세스 토큰이 발급된다
- 유효한 JWT 리프레시 토큰이 발급된다
- 사용자 정보가 응답에 포함된다
- HTTP 200 상태 코드가 반환된다
- 메인 페이지로 리다이렉트된다

```javascript
// 테스트 코드 예시
describe('로그인 성공 시나리오', () => {
  it('should login with valid credentials', async () => {
    const credentials = {
      email: 'test@example.com',
      password: 'SecurePass123!'
    };

    const response = await request(app)
      .post('/api/auth/login')
      .send(credentials)
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(response.body.token).toBeDefined();
    expect(response.body.refreshToken).toBeDefined();
    expect(response.body.user.email).toBe(credentials.email);

    // JWT 토큰 유효성 검증
    const decoded = jwt.verify(response.body.token, process.env.JWT_SECRET);
    expect(decoded.userId).toBeDefined();
  });
});
```

### AC-006: 잘못된 비밀번호 로그인 실패

**Given** 유효한 이메일(test@example.com)이 등록되어 있고
**When** 잘못된 비밀번호(WrongPassword)로 로그인을 시도하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- "이메일 또는 비밀번호가 올바르지 않습니다" 오류 메시지가 표시된다
- 토큰이 발급되지 않는다
- 로그인 실패 횟수가 1 증가한다
- HTTP 401 상태 코드가 반환된다

### AC-007: 계정 잠금 메커니즘

**Given** 사용자 계정(test@example.com)이 존재하고
**When** 5회 연속으로 잘못된 비밀번호로 로그인을 시도하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 계정이 15분간 잠금된다
- "계정이 일시적으로 잠겼습니다. 15분 후 다시 시도해주세요" 메시지가 표시된다
- 올바른 비밀번호로도 로그인할 수 없다
- HTTP 423 상태 코드가 반환된다

```javascript
// 테스트 코드 예시
describe('계정 잠금 시나리오', () => {
  it('should lock account after 5 failed attempts', async () => {
    const email = 'test@example.com';

    // 5회 연속 실패
    for (let i = 0; i < 5; i++) {
      await request(app)
        .post('/api/auth/login')
        .send({ email, password: 'wrongpassword' })
        .expect(401);
    }

    // 6번째 시도는 계정 잠금으로 거부
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email, password: 'wrongpassword' })
      .expect(423);

    expect(response.body.error.message).toContain('계정이 일시적으로 잠겼습니다');
  });
});
```

### AC-008: 존재하지 않는 이메일 로그인

**Given** 등록되지 않은 이메일(nonexistent@example.com)이 있고
**When** 해당 이메일로 로그인을 시도하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- "이메일 또는 비밀번호가 올바르지 않습니다" 오류 메시지가 표시된다 (보안상 동일한 메시지)
- 토큰이 발급되지 않는다
- HTTP 401 상태 코드가 반환된다

## 세션 관리 수락 기준

### AC-009: JWT 토큰 검증

**Given** 유효한 JWT 토큰이 발급된 상태에서
**When** 보호된 API 엔드포인트에 토큰과 함께 요청을 보내면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 요청이 성공적으로 처리된다
- 사용자 정보에 접근할 수 있다
- HTTP 200 상태 코드가 반환된다

### AC-010: 만료된 토큰 처리

**Given** 만료된 JWT 토큰이 있고
**When** 보호된 API 엔드포인트에 만료된 토큰으로 요청을 보내면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- "토큰이 만료되었습니다" 오류 메시지가 표시된다
- 요청이 거부된다
- HTTP 401 상태 코드가 반환된다

### AC-011: 토큰 갱신

**Given** 유효한 리프레시 토큰이 있고
**When** 토큰 갱신 엔드포인트에 리프레시 토큰을 보내면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 새로운 액세스 토큰이 발급된다
- 새로운 리프레시 토큰이 발급된다
- 이전 리프레시 토큰은 무효화된다
- HTTP 200 상태 코드가 반환된다

### AC-012: 로그아웃

**Given** 로그인된 사용자가 있고
**When** 로그아웃 버튼을 클릭하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 클라이언트에서 토큰이 제거된다
- 서버에서 해당 세션이 무효화된다
- 로그인 페이지로 리다이렉트된다
- HTTP 200 상태 코드가 반환된다

## 비밀번호 관리 수락 기준

### AC-013: 비밀번호 재설정 요청

**Given** 등록된 이메일(test@example.com)이 있고
**When** 비밀번호 재설정을 요청하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 비밀번호 재설정 이메일이 발송된다
- 재설정 토큰이 데이터베이스에 저장된다
- "재설정 링크를 이메일로 발송했습니다" 메시지가 표시된다
- HTTP 200 상태 코드가 반환된다

### AC-014: 비밀번호 재설정 실행

**Given** 유효한 재설정 토큰이 있고
**When** 새로운 비밀번호(NewSecurePass123!)로 재설정을 완료하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 비밀번호가 성공적으로 변경된다
- 새 비밀번호로 로그인할 수 있다
- 재설정 토큰이 무효화된다
- "비밀번호가 성공적으로 변경되었습니다" 메시지가 표시된다

### AC-015: 비밀번호 변경

**Given** 로그인된 사용자가 있고
**When** 현재 비밀번호(SecurePass123!)와 새 비밀번호(NewPassword456!)를 입력하여 변경을 요청하면
**Then** 다음과 같은 결과를 확인할 수 있어야 한다:
- 현재 비밀번호가 올바른지 검증된다
- 새 비밀번호가 이전 비밀번호와 다른지 확인된다
- 비밀번호가 성공적으로 변경된다
- "비밀번호가 변경되었습니다" 메시지가 표시된다

## 성능 수락 기준

### AC-016: 로그인 응답 시간

**Given** 정상적인 서버 상태에서
**When** 로그인 요청을 보내면
**Then** 평균 2초 이하의 응답 시간을 보장해야 한다

```javascript
// 성능 테스트 예시
describe('성능 테스트', () => {
  it('should respond to login within 2 seconds', async () => {
    const startTime = Date.now();

    await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'SecurePass123!' })
      .expect(200);

    const responseTime = Date.now() - startTime;
    expect(responseTime).toBeLessThan(2000);
  });
});
```

### AC-017: 동시 사용자 처리

**Given** 1000명의 사용자가 동시에 로그인을 시도할 때
**When** 서버가 요청을 처리하면
**Then** 모든 요청이 성공적으로 처리되어야 한다

## 보안 수락 기준

### AC-018: 비밀번호 암호화 저장

**Given** 사용자가 회원가입을 완료했을 때
**When** 데이터베이스를 확인하면
**Then** 비밀번호가 bcrypt로 암호화되어 저장되어야 한다

```javascript
// 보안 테스트 예시
describe('비밀번호 보안', () => {
  it('should store encrypted password', async () => {
    const userData = {
      email: 'security@example.com',
      password: 'TestPassword123!',
      name: '보안테스트'
    };

    await request(app)
      .post('/api/auth/register')
      .send(userData);

    const user = await prisma.user.findUnique({
      where: { email: userData.email }
    });

    // 평문 비밀번호와 다르게 저장되어야 함
    expect(user.password_hash).not.toBe(userData.password);
    // bcrypt 해시 형태인지 확인
    expect(user.password_hash).toMatch(/^\$2[aby]\$\d+\$/);
  });
});
```

### AC-019: HTTPS 강제

**Given** 사용자가 HTTP로 접근을 시도할 때
**When** 서버가 요청을 받으면
**Then** HTTPS로 리다이렉트되어야 한다

### AC-020: Rate Limiting

**Given** 동일한 IP에서 과도한 로그인 시도가 발생할 때
**When** 1분간 10회 이상 시도하면
**Then** 추가 요청이 차단되어야 한다

## 사용성 수락 기준

### AC-021: 명확한 오류 메시지

**Given** 사용자가 잘못된 입력을 했을 때
**When** 폼을 제출하면
**Then** 사용자가 이해할 수 있는 명확한 한국어 오류 메시지가 표시되어야 한다

### AC-022: 로딩 상태 표시

**Given** 사용자가 로그인 버튼을 클릭했을 때
**When** 서버 응답을 기다리는 동안
**Then** 로딩 스피너 또는 상태 메시지가 표시되어야 한다

### AC-023: 반응형 디자인

**Given** 사용자가 모바일 기기를 사용할 때
**When** 로그인 페이지에 접근하면
**Then** 모바일 화면에 최적화된 레이아웃이 표시되어야 한다

## 브라우저 호환성 수락 기준

### AC-024: 주요 브라우저 지원

**Given** 다음 브라우저들에서
- Chrome (최신 2개 버전)
- Firefox (최신 2개 버전)
- Safari (최신 2개 버전)
- Edge (최신 2개 버전)

**When** 로그인 시스템을 사용하면
**Then** 모든 기능이 정상적으로 동작해야 한다

## Definition of Done (완료 정의)

### 개발 완료 기준
- [ ] 모든 기능 요구사항이 구현되었다
- [ ] 모든 수락 기준 테스트가 통과한다
- [ ] 단위 테스트 커버리지가 80% 이상이다
- [ ] 통합 테스트가 모두 통과한다
- [ ] 코드 리뷰가 완료되었다
- [ ] 보안 검토가 완료되었다

### 배포 완료 기준
- [ ] 스테이징 환경에서 모든 테스트가 통과한다
- [ ] 성능 테스트가 완료되었다
- [ ] 보안 스캔이 완료되었다
- [ ] 운영 모니터링이 설정되었다
- [ ] 백업 및 복구 절차가 수립되었다
- [ ] 사용자 문서가 작성되었다

## 테스트 자동화 계획

### 단위 테스트 (Jest)
- 모든 서비스 함수
- 유틸리티 함수
- 미들웨어 함수

### 통합 테스트 (Supertest)
- API 엔드포인트
- 데이터베이스 연동
- 이메일 서비스 연동

### E2E 테스트 (Playwright/Cypress)
- 사용자 시나리오
- 브라우저별 호환성
- 모바일 반응형 테스트

### 보안 테스트
- JWT 토큰 검증
- SQL 인젝션 방지
- XSS 방지
- CSRF 방지

---

**수락 기준서 버전**: 1.0
**작성일**: 2025-01-19
**검토자**: QA 팀, 보안 팀
**승인자**: 제품 책임자
**다음 검토일**: 구현 완료 후