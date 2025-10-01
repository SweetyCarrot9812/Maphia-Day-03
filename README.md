# Day01 - 블로그 체험단 SaaS 플랫폼

블로거와 광고주를 연결하는 체험단 매칭 플랫폼

## 기능

- 인플루언서/광고주 회원가입 및 온보딩
- 캠페인 목록 및 상세 조회
- 캠페인 지원
- 광고주 캠페인 관리 (모집 마감, 선발)
- 내 지원 목록 조회

## 기술 스택

- Next.js 15 (App Router)
- React 19
- TypeScript
- Supabase (Auth + PostgreSQL)
- Tailwind CSS 4

## 설치 및 실행

```bash
# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env.local
# .env.local 파일에 Supabase 정보 입력

# 개발 서버 실행
npm run dev
```

## Vercel 배포

### 환경 변수 설정

Vercel 프로젝트에서 다음 환경 변수를 설정하세요:

1. Vercel 대시보드 → Settings → Environment Variables
2. 다음 변수 추가:
   - `NEXT_PUBLIC_SUPABASE_URL`: Supabase 프로젝트 URL
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Supabase Anon Key
3. Environment: Production, Preview 선택
4. Save 후 Redeploy

## 데이터베이스 스키마

`database_schema.sql` 파일 참고

## Use Cases

- [Use Case 01: 회원가입](./usecase_01_signup.spec.md)
- [Use Case 02: 인플루언서 등록](./usecase_02_influencer_registration.spec.md)
- [Use Case 03: 광고주 등록](./usecase_03_advertiser_registration.spec.md)
- [Use Case 04: 캠페인 목록](./usecase_04_campaign_browsing.spec.md)
- [Use Case 05: 캠페인 상세](./usecase_05_campaign_detail.spec.md)
- [Use Case 06: 캠페인 지원](./usecase_06_application_submit.spec.md)
- [Use Case 07: 내 지원 목록](./usecase_07_my_applications.spec.md)
- [Use Case 08: 광고주 캠페인 관리](./usecase_08_advertiser_campaign_management.spec.md)
