# System Architecture: Day04 Experience Matching Platform

## Meta
- **Created**: 2025-11-07
- **Version**: v1.0
- **Architecture Style**: Modular Monolith + DDD Lite
- **Tech Foundation**: React 18 + Node.js/Express + PostgreSQL

---

## 🏗️ ARCHITECTURE @DOC:ARCHITECTURE-001

### Architectural Style: Modular Monolith + DDD Lite

**Selection Rationale**:
- **Domain Complexity**: 3 clear bounded contexts (Auth, Campaign, Application)
- **Team Size**: Single full-stack developer (DDD overhead minimized)
- **Portfolio Goal**: Demonstrates domain-driven thinking without over-engineering
- **Scalability**: Clear module boundaries enable future microservice extraction

**Core Principles**:
- **Domain-First**: Business logic drives technical decisions
- **Dependency Inversion**: High-level modules don't depend on low-level details
- **Single Responsibility**: Each module has one reason to change
- **Result Pattern**: Railway-oriented programming for error handling

---

## 📦 MODULES @DOC:MODULES-001

### Frontend Architecture (React 18 + TypeScript)

```
src/
├── app/                    # Application shell
├── shared/                 # Cross-cutting concerns
│   ├── components/         # Reusable UI components
│   ├── hooks/             # Custom React hooks
│   ├── utils/             # Pure utility functions
│   └── types/             # TypeScript definitions
├── features/              # Feature-based modules
│   ├── auth/              # Authentication & authorization
│   ├── campaigns/         # Campaign management
│   ├── applications/      # Application workflows
│   └── dashboard/         # User dashboards
└── infrastructure/        # External concerns
    ├── api/               # HTTP client configuration
    ├── routing/           # React Router setup
    └── storage/           # Local storage management
```

**Module Responsibilities**:
- **auth**: User registration, login, role selection, session management
- **campaigns**: Campaign CRUD, search/filter, categorization
- **applications**: Application submission, status tracking, selection process
- **dashboard**: Role-specific management interfaces

### Backend Architecture (Node.js + Express + DDD Lite)

```
src/
├── api/                   # HTTP interface layer
│   ├── routes/            # Express route definitions
│   ├── middleware/        # Authentication, validation, CORS
│   └── controllers/       # Request/response handling
├── application/           # Application services
│   ├── commands/          # Command handlers (write operations)
│   ├── queries/           # Query handlers (read operations)
│   └── services/          # Cross-domain application logic
├── domain/                # Business logic core
│   ├── auth/              # Authentication domain
│   │   ├── entities/      # User, Session
│   │   ├── value-objects/ # Email, Password, Role
│   │   └── services/      # AuthenticationService
│   ├── campaigns/         # Campaign domain
│   │   ├── entities/      # Campaign, Advertiser
│   │   ├── value-objects/ # Title, Description, Deadline
│   │   └── services/      # CampaignManagementService
│   └── applications/      # Application domain
│       ├── entities/      # Application, Influencer
│       ├── value-objects/ # ApplicationStatus, Motivation
│       └── services/      # SelectionService
└── infrastructure/        # External adapters
    ├── database/          # PostgreSQL repositories
    ├── email/             # Email service integration
    └── validation/        # Input validation schemas
```

**Domain Boundaries**:
- **Auth Context**: User registration, authentication, authorization
- **Campaign Context**: Campaign lifecycle, advertiser management
- **Application Context**: Application workflow, selection process

---

## 🔗 INTEGRATION @DOC:INTEGRATION-001

### Database Design (PostgreSQL)

**Core Tables & Relationships**:
```sql
users (id, email, password_hash, role, created_at)
  ├── advertisers (user_id, company_name, business_number, address)
  ├── influencers (user_id, channel_name, follower_count, birth_date)
  └── auth_tokens (user_id, token, type, expires_at)

campaigns (id, advertiser_id, title, description, status, deadline)
  └── applications (id, campaign_id, influencer_id, status, motivation)

notifications (id, user_id, type, content, read_at)
```

**Key Constraints**:
- Foreign key relationships enforced at database level
- Role-based access patterns implemented via application layer
- Audit trails for all state changes

### API Design Pattern

**RESTful Endpoints**:
```
Authentication:
  POST /api/auth/register     # User registration
  POST /api/auth/login        # User authentication
  POST /api/auth/logout       # Session termination

Campaigns:
  GET /api/campaigns          # List campaigns (public)
  POST /api/campaigns         # Create campaign (advertiser only)
  PUT /api/campaigns/:id      # Update campaign (owner only)
  DELETE /api/campaigns/:id   # Delete campaign (owner only)

Applications:
  POST /api/campaigns/:id/apply    # Submit application (influencer only)
  GET /api/applications/mine       # List user's applications
  PUT /api/applications/:id        # Update application status (advertiser only)
```

**Response Patterns**:
- **Success**: Consistent JSON structure with data payload
- **Error**: HTTP status codes + error details following RFC 7807
- **Pagination**: Cursor-based for campaigns, offset-based for small lists

---

## 🔍 TRACEABILITY @DOC:TRACEABILITY-001

### @TAG Strategy

**Tag Categories**:
- **@SPEC**: Business requirements and user stories
- **@TEST**: Test cases and validation criteria
- **@CODE**: Implementation components and modules
- **@DOC**: Documentation and architectural decisions

**Traceability Chain**:
```
@SPEC:USER-001 (Product definition)
  ↓
@TEST:AUTH-001 (Authentication test scenarios)
  ↓
@CODE:AUTH-CONTROLLER (Implementation)
  ↓
@DOC:AUTH-API (API documentation)
```

### Quality Gates

**Code Quality Standards**:
- **TypeScript**: Strict mode with 100% type coverage
- **Testing**: >80% code coverage for business logic
- **Documentation**: All public APIs documented
- **Security**: OWASP guidelines followed

**Architecture Validation**:
- Module dependencies follow defined boundaries
- No circular dependencies between domains
- Clear separation of concerns across layers

---

## 🚀 DEPLOYMENT @DOC:DEPLOYMENT-001

### Environment Strategy

**Development**:
- Local PostgreSQL instance
- Hot reload for both frontend and backend
- Mock external services where needed

**Production** (Railway):
- Containerized deployment via Dockerfile
- PostgreSQL managed service
- Environment-based configuration
- SSL termination at platform level

**Build Process**:
```
Frontend: React build → static files → served by Express
Backend: TypeScript compilation → Node.js runtime
Database: Prisma migrations → PostgreSQL schema
```

---

## 🔄 HISTORY

### v1.0 (2025-11-07)
- **CREATED**: System architecture based on Modular Monolith + DDD Lite pattern
- **RATIONALE**: Balances domain complexity with single-developer constraints
- **SOURCE**: Derived from architecture analysis and technical requirements
- **AUTHOR**: @Alfred (MoAI-ADK)
- **VALIDATION**: Aligned with React 18 + Node.js + PostgreSQL tech stack