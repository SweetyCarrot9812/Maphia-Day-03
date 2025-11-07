# Architecture Design: 체험단 매칭 플랫폼

## Meta
- 작성일: 2025-11-07
- 작성자: Architecture Patterns Agent v3.0
- 버전: 1.0
- 기반 기술: React 18, Node.js + Express, PostgreSQL, Railway

---

## Phase 1: 아키텍처 스타일 선정

### 자동 추론 결과

```yaml
architecture_style: Modular Monolith + DDD Lite
rationale:
  - 도메인 엔티티: 8개 (User, Advertiser, Influencer, Campaign, Application, etc.)
  - Bounded Context: 3개 (Auth, Campaign, Application)
  - 팀 규모: 1-2명 (DDD 경험 제한적)
  - 프로젝트 특성: 포트폴리오 (과도한 복잡성 지양)
  - Full DDD는 오버엔지니어링, 단순 CRUD는 비즈니스 로직 부족
```

### 선정 근거

**✅ Modular Monolith + DDD Lite를 선택하는 이유:**
- 명확한 도메인 경계 (광고주 vs 인플루언서)
- 복잡한 비즈니스 규칙 (역할별 권한, 지원/선정 프로세스)
- 단일 팀 개발 (Context 간 통신 오버헤드 최소화)
- 점진적 DDD 학습 (Value Object → Entity → Domain Event)

**❌ 대안들을 제외한 이유:**
- **Full DDD**: 8개 엔티티로는 과도한 복잡성
- **Layered (3-Tier)**: 역할 기반 비즈니스 로직 복잡도 고려 부족
- **Microservice**: 포트폴리오 프로젝트에 운영 복잡성 과다

---

## Phase 2: 디렉토리 구조

### 전체 구조

```
src/
├── features/                    # Bounded Contexts
│   ├── authentication/         # 인증 컨텍스트
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.entity.ts
│   │   │   ├── value-objects/
│   │   │   │   ├── email.vo.ts
│   │   │   │   └── password.vo.ts
│   │   │   ├── events/
│   │   │   │   ├── user-registered.event.ts
│   │   │   │   └── role-selected.event.ts
│   │   │   └── repositories/
│   │   │       └── user.repository.ts (Interface)
│   │   ├── application/
│   │   │   ├── use-cases/
│   │   │   │   ├── register-user.use-case.ts
│   │   │   │   ├── login-user.use-case.ts
│   │   │   │   └── select-role.use-case.ts
│   │   │   ├── commands/
│   │   │   │   ├── register-user.command.ts
│   │   │   │   └── select-role.command.ts
│   │   │   ├── queries/
│   │   │   │   └── get-user-profile.query.ts
│   │   │   └── dto/
│   │   │       ├── user-profile.dto.ts
│   │   │       └── login-response.dto.ts
│   │   ├── infrastructure/
│   │   │   ├── repositories/
│   │   │   │   └── user.repository.impl.ts
│   │   │   └── mappers/
│   │   │       └── user.mapper.ts
│   │   └── presentation/
│   │       ├── api/
│   │       │   ├── auth.controller.ts
│   │       │   └── user.controller.ts
│   │       └── validators/
│   │           └── register-user.validator.ts
│   │
│   ├── campaign/               # 체험단 관리 컨텍스트
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── campaign.entity.ts
│   │   │   │   ├── advertiser.entity.ts
│   │   │   │   └── influencer.entity.ts
│   │   │   ├── value-objects/
│   │   │   │   ├── campaign-title.vo.ts
│   │   │   │   ├── business-number.vo.ts
│   │   │   │   └── follower-count.vo.ts
│   │   │   ├── events/
│   │   │   │   ├── campaign-created.event.ts
│   │   │   │   └── campaign-closed.event.ts
│   │   │   └── repositories/
│   │   │       ├── campaign.repository.ts
│   │   │       ├── advertiser.repository.ts
│   │   │       └── influencer.repository.ts
│   │   ├── application/
│   │   │   ├── use-cases/
│   │   │   │   ├── create-campaign.use-case.ts
│   │   │   │   ├── close-campaign.use-case.ts
│   │   │   │   ├── register-advertiser.use-case.ts
│   │   │   │   └── register-influencer.use-case.ts
│   │   │   ├── commands/
│   │   │   │   ├── create-campaign.command.ts
│   │   │   │   └── register-advertiser.command.ts
│   │   │   ├── queries/
│   │   │   │   ├── get-campaigns.query.ts
│   │   │   │   └── get-campaign-detail.query.ts
│   │   │   └── dto/
│   │   │       ├── campaign-list.dto.ts
│   │   │       └── campaign-detail.dto.ts
│   │   ├── infrastructure/
│   │   │   ├── repositories/
│   │   │   │   ├── campaign.repository.impl.ts
│   │   │   │   ├── advertiser.repository.impl.ts
│   │   │   │   └── influencer.repository.impl.ts
│   │   │   └── mappers/
│   │   │       ├── campaign.mapper.ts
│   │   │       └── profile.mapper.ts
│   │   └── presentation/
│   │       ├── api/
│   │       │   ├── campaign.controller.ts
│   │       │   └── profile.controller.ts
│   │       └── validators/
│   │           ├── create-campaign.validator.ts
│   │           └── register-profile.validator.ts
│   │
│   └── application-process/    # 지원/선정 컨텍스트
│       ├── domain/
│       │   ├── entities/
│       │   │   └── application.entity.ts
│       │   ├── value-objects/
│       │   │   ├── application-status.vo.ts
│       │   │   └── selection-reason.vo.ts
│       │   ├── events/
│       │   │   ├── application-submitted.event.ts
│       │   │   └── influencer-selected.event.ts
│       │   └── repositories/
│       │       └── application.repository.ts
│       ├── application/
│       │   ├── use-cases/
│       │   │   ├── submit-application.use-case.ts
│       │   │   └── select-influencer.use-case.ts
│       │   ├── commands/
│       │   │   ├── submit-application.command.ts
│       │   │   └── select-influencer.command.ts
│       │   ├── queries/
│       │   │   ├── get-applications.query.ts
│       │   │   └── get-applicant-list.query.ts
│       │   └── dto/
│       │       ├── application.dto.ts
│       │       └── applicant-list.dto.ts
│       ├── infrastructure/
│       │   ├── repositories/
│       │   │   └── application.repository.impl.ts
│       │   └── mappers/
│       │       └── application.mapper.ts
│       └── presentation/
│           ├── api/
│           │   └── application.controller.ts
│           └── validators/
│               └── submit-application.validator.ts
│
├── shared/                     # 공유 커널
│   ├── domain/                 # 공통 도메인 타입
│   │   ├── entity.base.ts
│   │   ├── value-object.base.ts
│   │   ├── domain-event.base.ts
│   │   └── aggregate-root.base.ts
│   ├── infrastructure/         # 공통 인프라
│   │   ├── result.ts           # Result<T> 패턴
│   │   ├── error.ts            # AppError 타입
│   │   └── event-bus.ts        # 도메인 이벤트 버스
│   └── types/                  # 공통 타입
│       ├── user-role.enum.ts
│       ├── campaign-status.enum.ts
│       └── application-status.enum.ts
│
└── infrastructure/             # 전역 인프라
    ├── composition-root.ts     # DI 컨테이너
    ├── database/               # DB 연결
    │   ├── prisma.client.ts
    │   ├── unit-of-work.ts
    │   └── migrations/
    ├── config/                 # 환경 설정
    │   └── env.ts
    └── web/                    # Express 설정
        ├── app.ts
        ├── middleware/
        └── routes/
```

### Context 간 통신 규칙

```typescript
// ✅ 허용: 도메인 이벤트를 통한 비동기 통신
// authentication 컨텍스트에서 이벤트 발행
await this.eventBus.publish(new UserRegistered(userId, email))

// campaign 컨텍스트에서 이벤트 처리
@EventHandler(UserRegistered)
async handleUserRegistered(event: UserRegistered) {
  // 웰컴 캠페인 추천 로직
}

// ❌ 금지: 직접 import를 통한 결합
// import { CampaignService } from '../campaign/application/campaign.service' // 금지

// ⚠️ 제한적 허용: 내부 API 호출 (동기 통신)
// 조회 전용, 성능 크리티컬한 경우에만
const campaigns = await this.internalApiClient.get('/campaigns/user/' + userId)
```

---

## Phase 3: 핵심 패턴 적용

### 3.1 Composition Root (의존성 주입)

```typescript
// src/infrastructure/composition-root.ts
export class AppCompositionRoot {
  private static instance: AppCompositionRoot
  private readonly prisma: PrismaClient
  private readonly unitOfWork: UnitOfWork

  private constructor() {
    this.prisma = new PrismaClient()
    this.unitOfWork = new UnitOfWork(this.prisma)
  }

  static getInstance(): AppCompositionRoot {
    if (!this.instance) {
      this.instance = new AppCompositionRoot()
    }
    return this.instance
  }

  // Authentication Context
  createUserRepository(): UserRepository {
    return new UserRepositoryImpl(this.prisma)
  }

  createRegisterUserUseCase(): RegisterUserUseCase {
    const userRepo = this.createUserRepository()
    const eventBus = EventBus.getInstance()
    return new RegisterUserUseCase(userRepo, eventBus, this.unitOfWork)
  }

  createLoginUserUseCase(): LoginUserUseCase {
    const userRepo = this.createUserRepository()
    const jwtService = new JwtService()
    return new LoginUserUseCase(userRepo, jwtService)
  }

  // Campaign Context
  createCampaignRepository(): CampaignRepository {
    return new CampaignRepositoryImpl(this.prisma)
  }

  createAdvertiserRepository(): AdvertiserRepository {
    return new AdvertiserRepositoryImpl(this.prisma)
  }

  createCreateCampaignUseCase(): CreateCampaignUseCase {
    const campaignRepo = this.createCampaignRepository()
    const advertiserRepo = this.createAdvertiserRepository()
    const eventBus = EventBus.getInstance()
    return new CreateCampaignUseCase(campaignRepo, advertiserRepo, eventBus)
  }

  // Application Process Context
  createApplicationRepository(): ApplicationRepository {
    return new ApplicationRepositoryImpl(this.prisma)
  }

  createSubmitApplicationUseCase(): SubmitApplicationUseCase {
    const appRepo = this.createApplicationRepository()
    const influencerRepo = this.createInfluencerRepository()
    const campaignRepo = this.createCampaignRepository()
    return new SubmitApplicationUseCase(appRepo, influencerRepo, campaignRepo)
  }
}
```

### 3.2 Result 패턴 (에러 처리)

```typescript
// src/shared/infrastructure/result.ts
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

  get isSuccess(): boolean { return this._isSuccess }
  get isFailure(): boolean { return !this._isSuccess }

  get value(): T {
    if (!this._isSuccess || this._value === undefined) {
      throw new Error('Cannot get value from failed result')
    }
    return this._value
  }

  get error(): AppError {
    if (this._isSuccess || this._error === undefined) {
      throw new Error('Cannot get error from success result')
    }
    return this._error
  }

  map<U>(fn: (value: T) => U): Result<U> {
    if (this.isFailure) {
      return Result.fail<U>(this.error)
    }
    return Result.ok(fn(this.value))
  }

  flatMap<U>(fn: (value: T) => Result<U>): Result<U> {
    if (this.isFailure) {
      return Result.fail<U>(this.error)
    }
    return fn(this.value)
  }
}

// src/shared/infrastructure/error.ts
export interface AppError {
  code: string
  message: string
  details?: any
}

export class DomainError implements AppError {
  constructor(
    public readonly code: string,
    public readonly message: string,
    public readonly details?: any
  ) {}
}

export class ValidationError implements AppError {
  constructor(
    public readonly code: string,
    public readonly message: string,
    public readonly details: any[]
  ) {}
}
```

### 3.3 Value Object 패턴

```typescript
// src/features/authentication/domain/value-objects/email.vo.ts
export class Email {
  private constructor(private readonly value: string) {}

  static create(email: string): Result<Email> {
    if (!email || email.trim().length === 0) {
      return Result.fail(new DomainError(
        'INVALID_EMAIL',
        'Email is required'
      ))
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      return Result.fail(new DomainError(
        'INVALID_EMAIL_FORMAT',
        'Invalid email format'
      ))
    }

    if (email.length > 255) {
      return Result.fail(new DomainError(
        'EMAIL_TOO_LONG',
        'Email must be less than 255 characters'
      ))
    }

    return Result.ok(new Email(email.toLowerCase().trim()))
  }

  getValue(): string {
    return this.value
  }

  equals(other: Email): boolean {
    return this.value === other.value
  }
}

// src/features/campaign/domain/value-objects/business-number.vo.ts
export class BusinessNumber {
  private constructor(private readonly value: string) {}

  static create(businessNumber: string): Result<BusinessNumber> {
    if (!businessNumber || businessNumber.trim().length === 0) {
      return Result.fail(new DomainError(
        'BUSINESS_NUMBER_REQUIRED',
        'Business number is required'
      ))
    }

    // XXX-XX-XXXXX 형식 검증
    const cleaned = businessNumber.replace(/[-]/g, '')
    if (!/^\d{10}$/.test(cleaned)) {
      return Result.fail(new DomainError(
        'INVALID_BUSINESS_NUMBER_FORMAT',
        'Business number must be 10 digits in XXX-XX-XXXXX format'
      ))
    }

    // 체크섬 알고리즘 검증 (실제 사업자등록번호 검증 로직)
    if (!this.isValidChecksum(cleaned)) {
      return Result.fail(new DomainError(
        'INVALID_BUSINESS_NUMBER',
        'Invalid business number checksum'
      ))
    }

    return Result.ok(new BusinessNumber(this.formatBusinessNumber(cleaned)))
  }

  private static isValidChecksum(digits: string): boolean {
    // 사업자등록번호 체크섬 알고리즘 구현
    const checkArray = [1, 3, 7, 1, 3, 7, 1, 3, 5]
    let sum = 0

    for (let i = 0; i < 9; i++) {
      sum += parseInt(digits[i]) * checkArray[i]
    }

    sum += Math.floor((parseInt(digits[8]) * 5) / 10)
    const remainder = sum % 10
    const checkDigit = remainder === 0 ? 0 : 10 - remainder

    return parseInt(digits[9]) === checkDigit
  }

  private static formatBusinessNumber(digits: string): string {
    return `${digits.substr(0, 3)}-${digits.substr(3, 2)}-${digits.substr(5, 5)}`
  }

  getValue(): string {
    return this.value
  }

  equals(other: BusinessNumber): boolean {
    return this.value === other.value
  }
}
```

### 3.4 Entity 패턴

```typescript
// src/shared/domain/entity.base.ts
export abstract class Entity<T> {
  protected constructor(protected readonly _id: T) {}

  get id(): T {
    return this._id
  }

  equals(entity: Entity<T>): boolean {
    return this._id === entity._id
  }
}

// src/features/authentication/domain/entities/user.entity.ts
export interface UserProps {
  email: Email
  password: Password
  name: string
  phoneNumber: string
  birthDate: Date
  role?: UserRole
  createdAt: Date
  updatedAt: Date
}

export class User extends Entity<string> {
  private _props: UserProps

  private constructor(id: string, props: UserProps) {
    super(id)
    this._props = props
  }

  static create(id: string, props: Omit<UserProps, 'createdAt' | 'updatedAt'>): User {
    return new User(id, {
      ...props,
      createdAt: new Date(),
      updatedAt: new Date()
    })
  }

  static fromPersistence(id: string, props: UserProps): User {
    return new User(id, props)
  }

  get email(): Email {
    return this._props.email
  }

  get password(): Password {
    return this._props.password
  }

  get name(): string {
    return this._props.name
  }

  get role(): UserRole | undefined {
    return this._props.role
  }

  selectRole(role: UserRole): void {
    if (this._props.role) {
      throw new DomainError('ROLE_ALREADY_SELECTED', 'User role already selected')
    }
    this._props.role = role
    this._props.updatedAt = new Date()
  }

  isAdvertiser(): boolean {
    return this._props.role === UserRole.ADVERTISER
  }

  isInfluencer(): boolean {
    return this._props.role === UserRole.INFLUENCER
  }

  getProps(): UserProps {
    return { ...this._props }
  }
}
```

### 3.5 Use Case 패턴

```typescript
// src/features/authentication/application/use-cases/register-user.use-case.ts
export interface RegisterUserCommand {
  email: string
  password: string
  name: string
  phoneNumber: string
  birthDate: string // ISO string
  role: string
}

export class RegisterUserUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly eventBus: EventBus,
    private readonly unitOfWork: UnitOfWork
  ) {}

  async execute(command: RegisterUserCommand): Promise<Result<UserDto>> {
    // 1. Value Object 검증
    const emailResult = Email.create(command.email)
    if (emailResult.isFailure) {
      return Result.fail(emailResult.error)
    }

    const passwordResult = Password.create(command.password)
    if (passwordResult.isFailure) {
      return Result.fail(passwordResult.error)
    }

    // 2. 비즈니스 규칙 검증
    const existingUser = await this.userRepository.findByEmail(emailResult.value)
    if (existingUser) {
      return Result.fail(new DomainError(
        'EMAIL_ALREADY_EXISTS',
        'User with this email already exists'
      ))
    }

    // 3. 트랜잭션 내에서 생성
    return this.unitOfWork.transaction(async (tx) => {
      const user = User.create(generateId(), {
        email: emailResult.value,
        password: passwordResult.value,
        name: command.name,
        phoneNumber: command.phoneNumber,
        birthDate: new Date(command.birthDate),
        role: UserRole.fromString(command.role)
      })

      const savedUser = await this.userRepository.save(user)

      // 4. 도메인 이벤트 발행
      await this.eventBus.publish(new UserRegistered(
        savedUser.id,
        savedUser.email.getValue(),
        savedUser.name,
        savedUser.role!
      ))

      return Result.ok(UserDto.fromEntity(savedUser))
    })
  }
}
```

### 3.6 Boundary Validation (API 계층)

```typescript
// src/features/authentication/presentation/validators/register-user.validator.ts
import { z } from 'zod'

export const RegisterUserSchema = z.object({
  email: z.string()
    .email('Invalid email format')
    .max(255, 'Email too long'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .max(100, 'Password too long')
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, 'Password must contain upper, lower, and number'),
  name: z.string()
    .min(2, 'Name must be at least 2 characters')
    .max(50, 'Name too long'),
  phoneNumber: z.string()
    .regex(/^010-\d{4}-\d{4}$/, 'Phone number must be in 010-XXXX-XXXX format'),
  birthDate: z.string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Birth date must be YYYY-MM-DD format'),
  role: z.enum(['advertiser', 'influencer'], {
    errorMap: () => ({ message: 'Role must be either advertiser or influencer' })
  })
})

export type RegisterUserDto = z.infer<typeof RegisterUserSchema>

export function validateRegisterUser(data: unknown): Result<RegisterUserDto> {
  const parsed = RegisterUserSchema.safeParse(data)

  if (!parsed.success) {
    return Result.fail(new ValidationError(
      'VALIDATION_ERROR',
      'Invalid input data',
      parsed.error.issues
    ))
  }

  return Result.ok(parsed.data)
}

// src/features/authentication/presentation/api/auth.controller.ts
export class AuthController {
  constructor(private readonly compositionRoot: AppCompositionRoot) {}

  async register(req: Request, res: Response): Promise<Response> {
    // 1. 입력 검증
    const validationResult = validateRegisterUser(req.body)
    if (validationResult.isFailure) {
      return res.status(400).json({
        error: validationResult.error.code,
        message: validationResult.error.message,
        details: validationResult.error.details
      })
    }

    // 2. Use Case 실행
    const useCase = this.compositionRoot.createRegisterUserUseCase()
    const result = await useCase.execute(validationResult.value)

    if (result.isFailure) {
      const statusCode = this.mapErrorToHttpStatus(result.error.code)
      return res.status(statusCode).json({
        error: result.error.code,
        message: result.error.message
      })
    }

    // 3. 성공 응답
    return res.status(201).json({
      success: true,
      data: result.value
    })
  }

  private mapErrorToHttpStatus(errorCode: string): number {
    switch (errorCode) {
      case 'EMAIL_ALREADY_EXISTS': return 409
      case 'INVALID_EMAIL':
      case 'INVALID_PASSWORD': return 400
      default: return 500
    }
  }
}
```

---

## Phase 4: Express.js 프레임워크 통합

### Express App 구성

```typescript
// src/infrastructure/web/app.ts
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import { authRouter } from '../../features/authentication/presentation/api/auth.routes'
import { campaignRouter } from '../../features/campaign/presentation/api/campaign.routes'
import { applicationRouter } from '../../features/application-process/presentation/api/application.routes'

export function createApp(): express.Application {
  const app = express()

  // 보안 미들웨어
  app.use(helmet())
  app.use(cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    credentials: true
  }))

  // 파싱 미들웨어
  app.use(express.json({ limit: '10mb' }))
  app.use(express.urlencoded({ extended: true }))

  // 헬스체크
  app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() })
  })

  // Feature 라우터
  app.use('/api/auth', authRouter)
  app.use('/api/campaigns', campaignRouter)
  app.use('/api/applications', applicationRouter)

  // 에러 핸들러
  app.use(errorHandler)

  return app
}

function errorHandler(err: any, req: express.Request, res: express.Response, next: express.NextFunction) {
  console.error(err.stack)

  res.status(err.status || 500).json({
    error: err.code || 'INTERNAL_SERVER_ERROR',
    message: err.message || 'Something went wrong'
  })
}

// src/features/authentication/presentation/api/auth.routes.ts
import { Router } from 'express'
import { AppCompositionRoot } from '../../../infrastructure/composition-root'
import { AuthController } from './auth.controller'

export const authRouter = Router()
const compositionRoot = AppCompositionRoot.getInstance()
const authController = new AuthController(compositionRoot)

authRouter.post('/register', (req, res) => authController.register(req, res))
authRouter.post('/login', (req, res) => authController.login(req, res))
authRouter.post('/select-role', (req, res) => authController.selectRole(req, res))
authRouter.get('/profile', (req, res) => authController.getProfile(req, res))
```

### Unit of Work (트랜잭션)

```typescript
// src/infrastructure/database/unit-of-work.ts
export class UnitOfWork {
  constructor(private readonly prisma: PrismaClient) {}

  async transaction<T>(
    work: (tx: Prisma.TransactionClient) => Promise<Result<T>>
  ): Promise<Result<T>> {
    try {
      return await this.prisma.$transaction(async (tx) => {
        const result = await work(tx)

        if (result.isFailure) {
          throw new Error(result.error.message) // 롤백 트리거
        }

        return result
      })
    } catch (error) {
      if (error instanceof Error) {
        return Result.fail(new DomainError(
          'TRANSACTION_FAILED',
          error.message
        ))
      }
      return Result.fail(new DomainError(
        'UNKNOWN_ERROR',
        'Unknown transaction error'
      ))
    }
  }
}
```

---

## Phase 5: 아키텍처 테스트 자동화

### ESLint Boundaries 설정

```javascript
// .eslintrc.js
module.exports = {
  plugins: ['boundaries'],
  settings: {
    'boundaries/elements': [
      { type: 'domain', pattern: 'src/features/*/domain/**/*' },
      { type: 'application', pattern: 'src/features/*/application/**/*' },
      { type: 'infrastructure', pattern: 'src/features/*/infrastructure/**/*' },
      { type: 'presentation', pattern: 'src/features/*/presentation/**/*' },
      { type: 'shared', pattern: 'src/shared/**/*' }
    ]
  },
  rules: {
    'boundaries/element-types': [
      'error',
      {
        default: 'disallow',
        rules: [
          // Domain 계층: 자기 자신과 shared만 참조
          {
            from: 'domain',
            allow: ['domain', 'shared']
          },
          // Application 계층: Domain과 자신, shared 참조
          {
            from: 'application',
            allow: ['domain', 'application', 'shared']
          },
          // Infrastructure: 모든 계층 참조 가능 (Adapter)
          {
            from: 'infrastructure',
            allow: '*'
          },
          // Presentation: Application, Infrastructure 참조
          {
            from: 'presentation',
            allow: ['application', 'infrastructure', 'shared']
          }
        ]
      }
    ]
  }
}
```

### CI 통합

```yaml
# .github/workflows/architecture-tests.yml
name: Architecture Tests

on: [push, pull_request]

jobs:
  architecture-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run architecture boundary tests
        run: npm run lint:boundaries

      - name: Run unit tests
        run: npm run test:domain
```

---

## Phase 6: 품질 체크리스트

### ✅ Clean Architecture 준수

- [ ] **Domain 계층**: infrastructure import 없음, 순수 비즈니스 로직
- [ ] **Application 계층**: Domain만 의존, Use Case 중심
- [ ] **Infrastructure 계층**: Port 인터페이스 구현, Repository 실체
- [ ] **Presentation 계층**: Use Case만 호출, HTTP 관심사 분리

### ✅ DDD 패턴 적용

- [ ] **Value Object**: Email, Password, BusinessNumber 등 도메인 개념
- [ ] **Entity**: User, Campaign, Application 등 식별성 있는 객체
- [ ] **Domain Event**: UserRegistered, CampaignCreated 등 비즈니스 이벤트
- [ ] **Repository Interface**: Domain에서 정의, Infrastructure에서 구현
- [ ] **Use Case**: Command/Query 분리, 단일 책임

### ✅ 변경 영향 최소화

- [ ] **기능 추가**: 1개 Context만 변경
- [ ] **UI 변경**: Domain 영향 없음
- [ ] **DB 스키마 변경**: Mapper/Repository만 영향
- [ ] **외부 API 변경**: Adapter만 영향

### ✅ 테스트 가능성

- [ ] **Use Case 단위 테스트**: Mock Repository 사용
- [ ] **Domain 로직 테스트**: 순수 함수, 의존성 없음
- [ ] **Value Object 테스트**: 생성 규칙, 비교 로직
- [ ] **Integration 테스트**: Repository 실체 테스트

---

## 안티패턴 경고

| 안티패턴 | 문제점 | 올바른 해결책 |
|---------|--------|---------------|
| **Controller에서 ORM 직접 사용** | 계층 위반, 테스트 불가 | Repository 패턴 + Use Case 사용 |
| **Domain에 Prisma import** | 프레임워크 결합 | Port/Adapter 패턴으로 분리 |
| **try-catch로 비즈니스 로직 제어** | 명시적 에러 처리 부재 | Result 패턴 사용 |
| **Context 간 직접 import** | 높은 결합도 | 도메인 이벤트 사용 |
| **God Use Case** | 단일 책임 위반 | Use Case 분리, Command/Query 구분 |

### 자동 검증 스크립트

```bash
# package.json scripts
{
  "scripts": {
    "lint:boundaries": "eslint src --rule 'boundaries/element-types: error'",
    "test:domain": "jest src/**/*.domain.test.ts",
    "test:architecture": "npm run lint:boundaries && npm run test:domain",
    "ci:architecture": "npm run test:architecture"
  }
}
```

---

## 팀 온보딩 가이드

### Week 1: 기초 패턴 학습
- Result 패턴 이해 및 연습
- Value Object 작성 실습
- Entity vs Value Object 구분 학습

### Week 2: Use Case 패턴 적용
- Command/Query 분리 개념
- Repository 인터페이스 정의
- 단위 테스트 작성 방법

### Week 3: 전체 플로우 통합
- API → Use Case → Repository 연결
- Composition Root 설정
- 도메인 이벤트 활용

### Week 4: 고급 패턴 적용
- Unit of Work 패턴
- Context 간 통신 설계
- 아키텍처 테스트 작성

---

## 예상 구현 일정

### Phase 1 (Week 1): Infrastructure 기반 구축
- Composition Root 설정
- Result 패턴 구현
- Database 연결 및 Unit of Work

### Phase 2 (Week 2-3): Authentication Context
- User Entity, Value Objects
- 회원가입/로그인 Use Case
- API Controller 및 Validation

### Phase 3 (Week 3-4): Campaign Context
- Campaign, Advertiser, Influencer Entity
- 체험단 생성/관리 Use Case
- 역할별 접근 제어

### Phase 4 (Week 4): Application Process Context
- Application Entity
- 지원/선정 Use Case
- Context 간 이벤트 연동

### Phase 5 (Week 5): Testing & Optimization
- 아키텍처 테스트 설정
- 단위/통합 테스트 작성
- 성능 최적화

---

이 Clean Architecture + DDD Lite 설계로 체험단 매칭 플랫폼을 확장 가능하고 유지보수가 용이한 구조로 개발할 수 있습니다. 특히 포트폴리오 프로젝트에서 현대적인 아키텍처 패턴 적용 능력을 효과적으로 보여줄 수 있습니다.