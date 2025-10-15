# Tech Stack: 콘서트 예약 플랫폼

## 기술 스택 선정 기준

### 평가 기준
1. **AI 친화성**: Claude Code와의 호환성, 자동 생성 용이성
2. **활발한 유지보수**: GitHub Stars, npm 다운로드 수, 최근 업데이트
3. **하위 호환성**: Breaking changes 적음, 안정적인 API
4. **필수 요구사항**: Context API, Flux 패턴 지원
5. **개발 속도**: 빠른 프로토타이핑 및 배포

---

## 선정된 기술 스택

### Frontend Framework

#### ✅ **Next.js 15.1** (App Router)
- **선정 이유**:
  - React 기반 - Context API 네이티브 지원
  - 파일 기반 라우팅 - 직관적인 구조
  - TypeScript 기본 지원
  - Vercel 원클릭 배포
  - 강력한 개발자 경험 (Hot Reload, Error Overlay)

- **정량적 지표**:
  - GitHub Stars: 125k+
  - npm 주간 다운로드: 6M+
  - 최근 업데이트: 2025-01 (활발함)

- **대안 비교**:
  | 프레임워크 | Stars | 다운로드/주 | AI 친화성 | 선택 이유 |
  |-----------|-------|------------|-----------|----------|
  | Next.js | 125k+ | 6M+ | ⭐⭐⭐⭐⭐ | **선택** |
  | Vite + React | 67k+ | 10M+ | ⭐⭐⭐⭐ | 설정 복잡 |
  | Remix | 29k+ | 200k+ | ⭐⭐⭐ | 학습 곡선 |

---

### UI Language

#### ✅ **TypeScript 5.3+**
- **선정 이유**:
  - 타입 안정성 - 런타임 에러 사전 방지
  - 뛰어난 자동완성 및 IntelliSense
  - Claude Code의 타입 추론 능력 향상
  - 리팩토링 안전성

- **정량적 지표**:
  - GitHub Stars: 100k+
  - npm 주간 다운로드: 50M+
  - 업계 표준 언어

---

### Styling

#### ✅ **Tailwind CSS 3.4+**
- **선정 이유**:
  - Utility-first - 빠른 스타일링
  - 반응형 디자인 간편
  - 클래스명 고민 불필요
  - Next.js와 완벽한 통합

- **정량적 지표**:
  - GitHub Stars: 81k+
  - npm 주간 다운로드: 6M+
  - 현대적인 CSS 프레임워크 표준

- **대안 비교**:
  | 프레임워크 | Stars | 학습 곡선 | Next.js 통합 | 선택 이유 |
  |-----------|-------|----------|-------------|----------|
  | Tailwind | 81k+ | 낮음 | ⭐⭐⭐⭐⭐ | **선택** |
  | CSS Modules | - | 낮음 | ⭐⭐⭐⭐ | 보일러플레이트 많음 |
  | Styled Components | 40k+ | 중간 | ⭐⭐⭐ | 런타임 비용 |

---

### State Management

#### ✅ **React Context API + useReducer** (필수)
- **선정 이유**:
  - 평가 요구사항: Context 사용 필수
  - React 내장 기능 - 추가 라이브러리 불필요
  - Flux 패턴 적용 가능 (useReducer)
  - 중앙화된 비즈니스 로직 관리

- **구현 방식**:
  ```typescript
  // Flux Pattern with Context
  - Actions: 액션 타입 정의
  - Reducer: 상태 변경 로직 (Dispatcher 역할)
  - Context: Store 역할
  - Components: View 역할
  ```

- **추가 도구**: 없음 (순수 React API만 사용)

---

### Data Persistence

#### ✅ **localStorage** (클라이언트 사이드)
- **선정 이유**:
  - 간단한 API
  - 백엔드 없이 프로토타입 완성
  - 브라우저 기본 지원
  - 빠른 개발 및 배포

- **사용 용도**:
  - 콘서트 목록 데이터
  - 좌석 예약 상태
  - 예약 내역

- **향후 확장**:
  - Phase 2: Supabase / Firebase 연동
  - Phase 3: PostgreSQL + Prisma

---

### Form Validation

#### ✅ **React Hook Form 7.51+**
- **선정 이유**:
  - 최소 리렌더링 - 성능 최적화
  - 간단한 API
  - TypeScript 완벽 지원
  - 유연한 검증 규칙

- **정량적 지표**:
  - GitHub Stars: 41k+
  - npm 주간 다운로드: 3M+
  - 가장 인기 있는 React 폼 라이브러리

- **대안 비교**:
  | 라이브러리 | Stars | 번들 크기 | 리렌더링 | 선택 이유 |
  |-----------|-------|----------|---------|----------|
  | React Hook Form | 41k+ | 9KB | 최소 | **선택** |
  | Formik | 34k+ | 15KB | 많음 | 성능 이슈 |
  | 직접 구현 | - | 0KB | 많음 | 복잡도 증가 |

---

### Date Handling

#### ✅ **date-fns 3.0+**
- **선정 이유**:
  - Tree-shakable - 작은 번들 크기
  - 불변성 보장 - 버그 감소
  - TypeScript 지원
  - 직관적인 API

- **정량적 지표**:
  - GitHub Stars: 34k+
  - npm 주간 다운로드: 20M+

- **사용 용도**:
  - 콘서트 날짜 포맷팅
  - 생년월일 검증
  - 예약 날짜 정렬

---

### UI Components (Optional)

#### ✅ **Headless UI 2.0** (선택적)
- **선정 이유**:
  - Tailwind Labs 공식 라이브러리
  - 완전히 스타일링 가능
  - 접근성 기본 지원
  - TypeScript 지원

- **사용 컴포넌트**:
  - Dialog (모달)
  - Transition (애니메이션)
  - Disclosure (아코디언)

- **대안**: 직접 구현 (시간이 충분할 경우)

---

### Icon Library

#### ✅ **Lucide React 0.300+**
- **선정 이유**:
  - 깔끔한 디자인
  - Tree-shakable
  - 1000+ 아이콘
  - TypeScript 지원

- **정량적 지표**:
  - GitHub Stars: 9k+
  - npm 주간 다운로드: 1M+

- **사용 예시**:
  - ChevronLeft (뒤로가기)
  - Calendar (날짜)
  - MapPin (장소)
  - CreditCard (결제)

---

### Code Quality

#### ✅ **ESLint 8.x + Prettier 3.x**
- **선정 이유**:
  - Next.js 기본 설정 포함
  - 자동 포맷팅
  - 일관된 코드 스타일

- **설정**:
  ```json
  {
    "extends": ["next/core-web-vitals", "prettier"],
    "rules": {
      "no-unused-vars": "error",
      "no-console": "warn"
    }
  }
  ```

---

### Deployment

#### ✅ **Vercel**
- **선정 이유**:
  - Next.js 최적화
  - GitHub 연동 자동 배포
  - 무료 플랜
  - 프리뷰 배포 지원
  - 글로벌 CDN

- **대안 비교**:
  | 플랫폼 | Next.js 최적화 | 무료 플랜 | 배포 속도 | 선택 이유 |
  |--------|--------------|----------|---------|----------|
  | Vercel | ⭐⭐⭐⭐⭐ | ✅ | 빠름 | **선택** |
  | Netlify | ⭐⭐⭐⭐ | ✅ | 빠름 | Vercel이 더 최적화 |
  | AWS Amplify | ⭐⭐⭐ | ✅ | 보통 | 복잡한 설정 |

---

## 전체 기술 스택 요약

| 카테고리 | 기술 | 버전 | 이유 |
|---------|------|------|------|
| **프레임워크** | Next.js | 15.1+ | React 기반, App Router, Vercel 배포 |
| **언어** | TypeScript | 5.3+ | 타입 안정성, AI 친화적 |
| **스타일링** | Tailwind CSS | 3.4+ | Utility-first, 빠른 개발 |
| **상태관리** | Context + useReducer | - | 필수 요구사항, Flux 패턴 |
| **데이터** | localStorage | - | 간단한 영속성, 백엔드 불필요 |
| **폼 검증** | React Hook Form | 7.51+ | 성능 최적화, 간단한 API |
| **날짜** | date-fns | 3.0+ | Tree-shakable, 불변성 |
| **UI 컴포넌트** | Headless UI | 2.0 | 접근성, Tailwind 통합 |
| **아이콘** | Lucide React | 0.300+ | 깔끔한 디자인, Tree-shakable |
| **린트/포맷** | ESLint + Prettier | 8.x + 3.x | 코드 품질 유지 |
| **배포** | Vercel | - | Next.js 최적화, 자동 배포 |

---

## 패키지 의존성 (package.json)

### dependencies
```json
{
  "next": "^15.1.0",
  "react": "^19.0.0",
  "react-dom": "^19.0.0",
  "react-hook-form": "^7.51.0",
  "date-fns": "^3.0.0",
  "lucide-react": "^0.300.0",
  "@headlessui/react": "^2.0.0"
}
```

### devDependencies
```json
{
  "typescript": "^5.3.0",
  "@types/node": "^20.0.0",
  "@types/react": "^19.0.0",
  "@types/react-dom": "^19.0.0",
  "tailwindcss": "^3.4.0",
  "postcss": "^8.4.0",
  "autoprefixer": "^10.4.0",
  "eslint": "^8.0.0",
  "eslint-config-next": "^15.1.0",
  "eslint-config-prettier": "^9.1.0",
  "prettier": "^3.2.0"
}
```

---

## 프로젝트 초기화 명령어

```bash
# Next.js 프로젝트 생성 (TypeScript, Tailwind, ESLint 포함)
npx create-next-app@latest concert-booking --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"

# 추가 패키지 설치
cd concert-booking
npm install react-hook-form date-fns lucide-react @headlessui/react

# 개발 서버 실행
npm run dev
```

---

## 브라우저 지원

| 브라우저 | 최소 버전 | 지원 |
|---------|----------|------|
| Chrome | 90+ | ✅ |
| Firefox | 90+ | ✅ |
| Safari | 14+ | ✅ |
| Edge | 90+ | ✅ |
| Mobile Chrome | 90+ | ✅ |
| Mobile Safari | 14+ | ✅ |

---

## 개발 환경 요구사항

- **Node.js**: 18.17.0 이상
- **npm**: 9.0.0 이상 (또는 yarn, pnpm)
- **OS**: Windows, macOS, Linux
- **IDE**: VS Code (권장) + TypeScript Extension

---

## 성능 목표

| 지표 | 목표 |
|------|------|
| First Contentful Paint (FCP) | < 1.8s |
| Largest Contentful Paint (LCP) | < 2.5s |
| Time to Interactive (TTI) | < 3.8s |
| Total Blocking Time (TBT) | < 200ms |
| Cumulative Layout Shift (CLS) | < 0.1 |

---

## 향후 확장 가능성

### Phase 2 (백엔드 추가)
- **데이터베이스**: Supabase (PostgreSQL)
- **인증**: NextAuth.js
- **API**: Next.js API Routes

### Phase 3 (고급 기능)
- **결제**: Toss Payments / Stripe
- **실시간**: WebSocket (Socket.io)
- **이메일**: Resend / SendGrid
- **이미지**: Cloudinary / Vercel Blob

### Phase 4 (성능 최적화)
- **캐싱**: React Query / SWR
- **분석**: Vercel Analytics
- **모니터링**: Sentry
- **테스트**: Vitest + Testing Library

---

**문서 버전**: 1.0
**작성일**: 2025-01-16
**다음 단계**: Codebase Structure 설계
