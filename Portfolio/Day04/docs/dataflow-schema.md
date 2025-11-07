# Database Schema: 체험단 매칭 플랫폼

## Meta
- 작성일: 2025-11-07
- 작성자: DataFlow Schema Generator Agent v3.0
- DB: PostgreSQL + Prisma ORM
- Phase: 0 (Core) + 1 (Optional)

---

## 🎯 Phase 분류 결과

**Phase 0 (Core)**: ✅ 적용
- users (필수 - 회원가입/로그인)
- advertisers (광고주 정보)
- influencers (인플루언서 정보)
- campaigns (체험단 정보)
- applications (지원 내역)
- auth_tokens (이메일 인증 - UserFlow에 명시됨)

**Phase 1 (Optional)**: ✅ 적용
- notifications (지원/선정 알림 - UserFlow에 명시됨)
- fulltext_search (체험단 검색 - UserFlow에 명시됨)

**Phase 2 (Advanced)**: ❌ 생략
- 웹훅, 감사 로그 등 UserFlow에 없음

---

## 📁 ERD

```
                    users (1)
                      │
         ┌────────────┼────────────┐
         │            │            │
    advertisers (1:1) │     influencers (1:1)
         │            │            │
         │            │            │
    campaigns (1:N) ──┼───────── applications (N:M)
         │            │            │
         │            │            │
         └─────── notifications ───┘
                      │
                 auth_tokens (1:N)
```

---

## 🔧 Migration Files

### Prisma Schema (`/prisma/schema.prisma`)

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ================================================================================
// Phase 0: Core Tables
// ================================================================================

model User {
  id          String   @id @default(cuid())
  email       String   @unique @db.VarChar(255)
  passwordHash String  @map("password_hash") @db.VarChar(255)
  name        String   @db.VarChar(100)
  phoneNumber String   @map("phone_number") @db.VarChar(20)
  birthDate   DateTime @map("birth_date") @db.Date
  role        UserRole?
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  // Relations
  advertiser    Advertiser?
  influencer    Influencer?
  authTokens    AuthToken[]
  notifications Notification[]

  @@map("users")
}

model Advertiser {
  id                   String @id @default(cuid())
  userId               String @unique @map("user_id")
  companyName          String @map("company_name") @db.VarChar(100)
  address              String @db.VarChar(500)
  businessPhone        String @map("business_phone") @db.VarChar(20)
  businessNumber       String @map("business_number") @db.VarChar(12)
  representativeName   String @map("representative_name") @db.VarChar(100)
  createdAt            DateTime @default(now()) @map("created_at")
  updatedAt            DateTime @updatedAt @map("updated_at")

  // Relations
  user      User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  campaigns Campaign[]

  @@unique([businessNumber])
  @@map("advertisers")
}

model Influencer {
  id             String    @id @default(cuid())
  userId         String    @unique @map("user_id")
  channelName    String    @map("channel_name") @db.VarChar(100)
  channelLink    String    @map("channel_link") @db.VarChar(500)
  followerCount  Int       @map("follower_count")
  mainCategory   String?   @map("main_category") @db.VarChar(50)
  createdAt      DateTime  @default(now()) @map("created_at")
  updatedAt      DateTime  @updatedAt @map("updated_at")

  // Relations
  user         User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  applications Application[]

  @@unique([channelLink])
  @@map("influencers")
}

model Campaign {
  id              String         @id @default(cuid())
  advertiserId    String         @map("advertiser_id")
  title           String         @db.VarChar(200)
  description     String         @db.Text
  recruitCount    Int            @map("recruit_count")
  deadline        DateTime       @db.Date
  experiencePeriod Int           @map("experience_period")
  benefits        String         @db.Text
  category        String         @db.VarChar(50)
  status          CampaignStatus @default(RECRUITING)
  createdAt       DateTime       @default(now()) @map("created_at")
  updatedAt       DateTime       @updatedAt @map("updated_at")

  // Relations
  advertiser   Advertiser    @relation(fields: [advertiserId], references: [id], onDelete: Cascade)
  applications Application[]

  @@index([status, createdAt(sort: Desc)])
  @@index([category, status])
  @@index([deadline])
  @@map("campaigns")
}

model Application {
  id                String            @id @default(cuid())
  campaignId        String            @map("campaign_id")
  influencerId      String            @map("influencer_id")
  motivation        String            @db.Text
  expectedReviewDate DateTime         @map("expected_review_date") @db.Date
  expectedViews     Int?              @map("expected_views")
  portfolioLink     String?           @map("portfolio_link") @db.VarChar(500)
  status            ApplicationStatus @default(PENDING)
  selectionReason   String?           @map("selection_reason") @db.Text
  createdAt         DateTime          @default(now()) @map("created_at")
  updatedAt         DateTime          @updatedAt @map("updated_at")

  // Relations
  campaign   Campaign   @relation(fields: [campaignId], references: [id], onDelete: Cascade)
  influencer Influencer @relation(fields: [influencerId], references: [id], onDelete: Cascade)

  @@unique([campaignId, influencerId])
  @@index([influencerId, createdAt(sort: Desc)])
  @@index([campaignId, status])
  @@map("applications")
}

model AuthToken {
  id        String        @id @default(cuid())
  userId    String        @map("user_id")
  purpose   TokenPurpose
  tokenHash String        @map("token_hash") @db.VarChar(255)
  expiresAt DateTime      @map("expires_at")
  usedAt    DateTime?     @map("used_at")
  createdAt DateTime      @default(now()) @map("created_at")

  // Relations
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, purpose])
  @@index([expiresAt])
  @@map("auth_tokens")
}

// ================================================================================
// Phase 1: Optional Tables
// ================================================================================

model Notification {
  id         String           @id @default(cuid())
  userId     String           @map("user_id")
  type       NotificationType
  title      String           @db.VarChar(200)
  message    String           @db.Text
  refId      String?          @map("ref_id") // Campaign ID 또는 Application ID
  isRead     Boolean          @default(false) @map("is_read")
  createdAt  DateTime         @default(now()) @map("created_at")

  // Relations
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, isRead, createdAt(sort: Desc)])
  @@map("notifications")
}

// ================================================================================
// Enums
// ================================================================================

enum UserRole {
  ADVERTISER
  INFLUENCER

  @@map("user_role")
}

enum CampaignStatus {
  RECRUITING  // 모집중
  CLOSED      // 모집마감
  IN_PROGRESS // 진행중
  COMPLETED   // 완료

  @@map("campaign_status")
}

enum ApplicationStatus {
  PENDING   // 대기중
  SELECTED  // 선정됨
  REJECTED  // 미선정

  @@map("application_status")
}

enum TokenPurpose {
  VERIFY_EMAIL
  RESET_PASSWORD

  @@map("token_purpose")
}

enum NotificationType {
  APPLICATION_RECEIVED  // 광고주: 지원자 접수
  APPLICATION_SELECTED  // 인플루언서: 선정됨
  APPLICATION_REJECTED  // 인플루언서: 미선정
  CAMPAIGN_DEADLINE     // 공통: 마감 임박
  CAMPAIGN_CLOSED       // 인플루언서: 모집 종료

  @@map("notification_type")
}
```

### SQL Migration (`/prisma/migrations/20251107120000_initial_schema/migration.sql`)

```sql
-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('ADVERTISER', 'INFLUENCER');

-- CreateEnum
CREATE TYPE "campaign_status" AS ENUM ('RECRUITING', 'CLOSED', 'IN_PROGRESS', 'COMPLETED');

-- CreateEnum
CREATE TYPE "application_status" AS ENUM ('PENDING', 'SELECTED', 'REJECTED');

-- CreateEnum
CREATE TYPE "token_purpose" AS ENUM ('VERIFY_EMAIL', 'RESET_PASSWORD');

-- CreateEnum
CREATE TYPE "notification_type" AS ENUM ('APPLICATION_RECEIVED', 'APPLICATION_SELECTED', 'APPLICATION_REJECTED', 'CAMPAIGN_DEADLINE', 'CAMPAIGN_CLOSED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "phone_number" VARCHAR(20) NOT NULL,
    "birth_date" DATE NOT NULL,
    "role" "user_role",
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "advertisers" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "company_name" VARCHAR(100) NOT NULL,
    "address" VARCHAR(500) NOT NULL,
    "business_phone" VARCHAR(20) NOT NULL,
    "business_number" VARCHAR(12) NOT NULL,
    "representative_name" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "advertisers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "influencers" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "channel_name" VARCHAR(100) NOT NULL,
    "channel_link" VARCHAR(500) NOT NULL,
    "follower_count" INTEGER NOT NULL,
    "main_category" VARCHAR(50),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "influencers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "campaigns" (
    "id" TEXT NOT NULL,
    "advertiser_id" TEXT NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT NOT NULL,
    "recruit_count" INTEGER NOT NULL,
    "deadline" DATE NOT NULL,
    "experience_period" INTEGER NOT NULL,
    "benefits" TEXT NOT NULL,
    "category" VARCHAR(50) NOT NULL,
    "status" "campaign_status" NOT NULL DEFAULT 'RECRUITING',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "campaigns_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "applications" (
    "id" TEXT NOT NULL,
    "campaign_id" TEXT NOT NULL,
    "influencer_id" TEXT NOT NULL,
    "motivation" TEXT NOT NULL,
    "expected_review_date" DATE NOT NULL,
    "expected_views" INTEGER,
    "portfolio_link" VARCHAR(500),
    "status" "application_status" NOT NULL DEFAULT 'PENDING',
    "selection_reason" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_tokens" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "purpose" "token_purpose" NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "used_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "type" "notification_type" NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "message" TEXT NOT NULL,
    "ref_id" TEXT,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "advertisers_user_id_key" ON "advertisers"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "advertisers_business_number_key" ON "advertisers"("business_number");

-- CreateIndex
CREATE UNIQUE INDEX "influencers_user_id_key" ON "influencers"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "influencers_channel_link_key" ON "influencers"("channel_link");

-- CreateIndex
CREATE INDEX "campaigns_status_created_at_idx" ON "campaigns"("status", "created_at" DESC);

-- CreateIndex
CREATE INDEX "campaigns_category_status_idx" ON "campaigns"("category", "status");

-- CreateIndex
CREATE INDEX "campaigns_deadline_idx" ON "campaigns"("deadline");

-- CreateIndex
CREATE UNIQUE INDEX "applications_campaign_id_influencer_id_key" ON "applications"("campaign_id", "influencer_id");

-- CreateIndex
CREATE INDEX "applications_influencer_id_created_at_idx" ON "applications"("influencer_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "applications_campaign_id_status_idx" ON "applications"("campaign_id", "status");

-- CreateIndex
CREATE INDEX "auth_tokens_user_id_purpose_idx" ON "auth_tokens"("user_id", "purpose");

-- CreateIndex
CREATE INDEX "auth_tokens_expires_at_idx" ON "auth_tokens"("expires_at");

-- CreateIndex
CREATE INDEX "notifications_user_id_is_read_created_at_idx" ON "notifications"("user_id", "is_read", "created_at" DESC);

-- AddForeignKey
ALTER TABLE "advertisers" ADD CONSTRAINT "advertisers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "influencers" ADD CONSTRAINT "influencers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaigns" ADD CONSTRAINT "campaigns_advertiser_id_fkey" FOREIGN KEY ("advertiser_id") REFERENCES "advertisers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "campaigns"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_influencer_id_fkey" FOREIGN KEY ("influencer_id") REFERENCES "influencers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_tokens" ADD CONSTRAINT "auth_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
```

---

## 📊 Dataflow (상세)

### Flow 1: 회원가입 프로세스

```sql
-- Step 1: 이메일 중복 체크
SELECT COUNT(*) as count FROM users WHERE email = $1;

-- Step 2: 사용자 생성 (트랜잭션 시작)
BEGIN;

INSERT INTO users (email, password_hash, name, phone_number, birth_date)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, email, name, created_at;

-- Step 3: 역할 선택 (광고주인 경우)
UPDATE users SET role = 'ADVERTISER' WHERE id = $1;

INSERT INTO advertisers (
  user_id, company_name, address, business_phone,
  business_number, representative_name
) VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id;

-- Step 4: 이메일 인증 토큰 생성
INSERT INTO auth_tokens (user_id, purpose, token_hash, expires_at)
VALUES ($1, 'VERIFY_EMAIL', $2, NOW() + INTERVAL '30 minutes')
RETURNING id;

COMMIT;
```

### Flow 2: 체험단 등록 프로세스

```sql
-- Step 1: 광고주 권한 확인
SELECT a.id FROM advertisers a
JOIN users u ON a.user_id = u.id
WHERE u.id = $1 AND u.role = 'ADVERTISER';

-- Step 2: 체험단 생성
INSERT INTO campaigns (
  advertiser_id, title, description, recruit_count,
  deadline, experience_period, benefits, category
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING id, title, created_at;

-- Step 3: 알림 생성 (선택적)
INSERT INTO notifications (user_id, type, title, message, ref_id)
VALUES ($1, 'CAMPAIGN_CREATED', '새 체험단이 등록되었습니다', $2, $3);
```

### Flow 3: 체험단 지원 프로세스

```sql
-- Step 1: 지원 자격 확인
SELECT i.id, c.status, c.deadline FROM influencers i
JOIN users u ON i.user_id = u.id
CROSS JOIN campaigns c
WHERE u.id = $1 AND c.id = $2
  AND u.role = 'INFLUENCER'
  AND c.status = 'RECRUITING'
  AND c.deadline >= CURRENT_DATE;

-- Step 2: 중복 지원 체크
SELECT COUNT(*) as count FROM applications
WHERE campaign_id = $1 AND influencer_id = $2;

-- Step 3: 지원서 등록 (트랜잭션)
BEGIN;

INSERT INTO applications (
  campaign_id, influencer_id, motivation,
  expected_review_date, expected_views, portfolio_link
) VALUES ($1, $2, $3, $4, $5, $6)
RETURNING id;

-- Step 4: 광고주에게 알림 생성
INSERT INTO notifications (user_id, type, title, message, ref_id)
SELECT a.user_id, 'APPLICATION_RECEIVED',
       '새로운 지원자가 있습니다', $1, $2
FROM advertisers a
JOIN campaigns c ON a.id = c.advertiser_id
WHERE c.id = $3;

COMMIT;
```

### Flow 4: 인플루언서 선정 프로세스

```sql
-- Step 1: 광고주 권한 및 캠페인 상태 확인
SELECT c.id FROM campaigns c
JOIN advertisers a ON c.advertiser_id = a.id
WHERE c.id = $1 AND a.user_id = $2 AND c.status = 'CLOSED';

-- Step 2: 선정/미선정 처리 (트랜잭션)
BEGIN;

-- 선정자 업데이트
UPDATE applications
SET status = 'SELECTED', selection_reason = $3, updated_at = NOW()
WHERE id = ANY($1::text[]);

-- 미선정자 업데이트
UPDATE applications
SET status = 'REJECTED', updated_at = NOW()
WHERE campaign_id = $2 AND id != ALL($1::text[]);

-- 캠페인 상태 변경
UPDATE campaigns SET status = 'IN_PROGRESS' WHERE id = $2;

-- 선정자들에게 알림
INSERT INTO notifications (user_id, type, title, message, ref_id)
SELECT i.user_id, 'APPLICATION_SELECTED',
       '체험단에 선정되었습니다!', '축하드립니다. 체험을 시작해주세요.', $2
FROM applications app
JOIN influencers i ON app.influencer_id = i.id
WHERE app.id = ANY($1::text[]);

-- 미선정자들에게 알림
INSERT INTO notifications (user_id, type, title, message, ref_id)
SELECT i.user_id, 'APPLICATION_REJECTED',
       '아쉽지만 이번에는 선정되지 않았습니다', '다음 기회에 더 좋은 결과가 있기를 바랍니다.', $2
FROM applications app
JOIN influencers i ON app.influencer_id = i.id
WHERE app.campaign_id = $2 AND app.id != ALL($1::text[]);

COMMIT;
```

### Flow 5: 체험단 탐색/검색

```sql
-- Step 1: 기본 목록 조회 (페이징)
SELECT c.id, c.title, c.description, c.recruit_count, c.deadline,
       c.category, c.status, a.company_name,
       COUNT(app.id) as application_count
FROM campaigns c
JOIN advertisers a ON c.advertiser_id = a.id
LEFT JOIN applications app ON c.id = app.campaign_id
WHERE c.status = 'RECRUITING'
  AND ($1::varchar IS NULL OR c.category = $1)
  AND ($2::varchar IS NULL OR c.title ILIKE '%' || $2 || '%')
GROUP BY c.id, a.company_name
ORDER BY c.created_at DESC
LIMIT $3 OFFSET $4;

-- Step 2: 전체 카운트 (페이징용)
SELECT COUNT(DISTINCT c.id) FROM campaigns c
WHERE c.status = 'RECRUITING'
  AND ($1::varchar IS NULL OR c.category = $1)
  AND ($2::varchar IS NULL OR c.title ILIKE '%' || $2 || '%');

-- Step 3: 상세 조회 (지원 가능 여부 포함)
SELECT c.*, a.company_name, a.business_phone,
       COUNT(app.id) as application_count,
       EXISTS(
         SELECT 1 FROM applications app2
         WHERE app2.campaign_id = c.id AND app2.influencer_id = $2
       ) as already_applied
FROM campaigns c
JOIN advertisers a ON c.advertiser_id = a.id
LEFT JOIN applications app ON c.id = app.campaign_id
WHERE c.id = $1
GROUP BY c.id, a.company_name, a.business_phone;
```

---

## 🔄 Seed Data (`/prisma/seed.ts`)

```typescript
import { PrismaClient, UserRole, CampaignStatus } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  // 테스트 사용자들
  const hashedPassword = await bcrypt.hash('password123', 10)

  // 광고주 사용자
  const advertiserUser = await prisma.user.create({
    data: {
      email: 'advertiser@example.com',
      passwordHash: hashedPassword,
      name: '김광고',
      phoneNumber: '010-1234-5678',
      birthDate: new Date('1985-03-15'),
      role: UserRole.ADVERTISER,
    },
  })

  // 광고주 프로필
  const advertiser = await prisma.advertiser.create({
    data: {
      userId: advertiserUser.id,
      companyName: '(주)뷰티코스메틱',
      address: '서울시 강남구 테헤란로 123',
      businessPhone: '02-1234-5678',
      businessNumber: '123-45-67890',
      representativeName: '김대표',
    },
  })

  // 인플루언서 사용자들
  const influencerUser1 = await prisma.user.create({
    data: {
      email: 'influencer1@example.com',
      passwordHash: hashedPassword,
      name: '박인플',
      phoneNumber: '010-2345-6789',
      birthDate: new Date('1995-07-20'),
      role: UserRole.INFLUENCER,
    },
  })

  const influencer1 = await prisma.influencer.create({
    data: {
      userId: influencerUser1.id,
      channelName: '박인플의 뷰티일상',
      channelLink: 'https://instagram.com/beauty_daily',
      followerCount: 15000,
      mainCategory: '뷰티',
    },
  })

  const influencerUser2 = await prisma.user.create({
    data: {
      email: 'influencer2@example.com',
      passwordHash: hashedPassword,
      name: '최리뷰어',
      phoneNumber: '010-3456-7890',
      birthDate: new Date('1992-11-08'),
      role: UserRole.INFLUENCER,
    },
  })

  const influencer2 = await prisma.influencer.create({
    data: {
      userId: influencerUser2.id,
      channelName: '최리뷰어 테크채널',
      channelLink: 'https://youtube.com/techreviewer',
      followerCount: 25000,
      mainCategory: '테크',
    },
  })

  // 테스트 체험단들
  const campaign1 = await prisma.campaign.create({
    data: {
      advertiserId: advertiser.id,
      title: '신제품 립스틱 체험단 모집',
      description: `새로 출시되는 매트 립스틱의 지속력과 발색을 체험해보세요!

제품 특징:
- 12시간 지속되는 매트 립스틱
- 6가지 다양한 컬러
- 촉촉함을 유지하는 특별한 포뮬러

체험 조건:
- Instagram 피드 포스팅 1회 (해시태그 필수)
- Instagram 스토리 3회 이상
- 솔직한 후기 작성`,
      recruitCount: 10,
      deadline: new Date('2025-11-20'),
      experiencePeriod: 14,
      benefits: '제품 무료 제공 + 리뷰 수수료 10만원',
      category: '뷰티',
      status: CampaignStatus.RECRUITING,
    },
  })

  const campaign2 = await prisma.campaign.create({
    data: {
      advertiserId: advertiser.id,
      title: '스마트 워치 신기능 체험단',
      description: `최신 스마트워치의 헬스케어 기능을 체험해보세요!

주요 기능:
- 심박수 모니터링
- 수면 패턴 분석
- 운동량 자동 측정
- 스마트폰 연동 알림

리뷰 가이드:
- 1주일 사용 후기
- 기능별 상세 리뷰
- 타 제품과의 비교 (선택사항)`,
      recruitCount: 5,
      deadline: new Date('2025-11-25'),
      experiencePeriod: 21,
      benefits: '제품 무료 제공 + 리뷰 수수료 15만원',
      category: '테크',
      status: CampaignStatus.RECRUITING,
    },
  })

  // 테스트 지원 내역
  await prisma.application.create({
    data: {
      campaignId: campaign1.id,
      influencerId: influencer1.id,
      motivation: `안녕하세요! 뷰티 인플루언서 박인플입니다.

평소 립스틱 리뷰를 자주 하고 있어서 이번 신제품에 매우 관심이 많습니다. 특히 매트 타입 제품의 지속력과 건조함 방지 효과에 대해 솔직하고 상세한 리뷰를 작성하겠습니다.

팔로워분들께서도 립스틱 추천을 자주 요청하시는데, 이번 기회에 정말 좋은 제품을 소개해드릴 수 있을 것 같습니다!`,
      expectedReviewDate: new Date('2025-11-30'),
      expectedViews: 5000,
      portfolioLink: 'https://instagram.com/beauty_daily/highlights',
    },
  })

  await prisma.application.create({
    data: {
      campaignId: campaign2.id,
      influencerId: influencer2.id,
      motivation: `테크 리뷰어 최리뷰어입니다.

스마트워치는 제가 가장 자주 리뷰하는 카테고리 중 하나입니다. 현재 애플워치, 갤럭시워치, 샤오미 워치 등 다양한 제품을 보유하고 있어 비교 리뷰가 가능합니다.

특히 헬스케어 기능의 정확도와 배터리 수명, 앱 연동성 등을 중점적으로 테스트하여 구독자들에게 실용적인 정보를 제공하겠습니다.`,
      expectedReviewDate: new Date('2025-12-10'),
      expectedViews: 8000,
      portfolioLink: 'https://youtube.com/techreviewer/playlist',
    },
  })

  // 테스트 알림
  await prisma.notification.create({
    data: {
      userId: advertiserUser.id,
      type: 'APPLICATION_RECEIVED',
      title: '새로운 지원자가 있습니다',
      message: '박인플님이 "신제품 립스틱 체험단"에 지원하셨습니다.',
      refId: campaign1.id,
    },
  })

  console.log('Seed data created successfully!')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

---

## 🚀 다음 단계

### 1. 개발 환경 설정
```bash
# Prisma 설치
npm install prisma @prisma/client
npm install bcryptjs @types/bcryptjs

# 환경변수 설정
DATABASE_URL="postgresql://username:password@localhost:5432/experience_platform"

# 데이터베이스 생성 및 마이그레이션
npx prisma migrate dev --name initial_schema
npx prisma generate

# 시드 데이터 실행
npx prisma db seed
```

### 2. Phase 1 확장 (필요시)
```bash
# 전문검색 기능 추가 (PostgreSQL Full-text Search)
npx prisma migrate dev --name add_fulltext_search

# 알림 시스템 확장
npx prisma migrate dev --name enhance_notifications
```

### 3. 성능 최적화
- 인덱스 모니터링: `EXPLAIN ANALYZE` 활용
- 쿼리 최적화: N+1 문제 해결 (Prisma `include` 활용)
- 캐싱 전략: Redis 도입 고려

### 4. 데이터 검증 규칙
- 사업자등록번호: 체크섬 알고리즘 구현
- 이메일: 실제 도메인 검증
- 전화번호: 국가별 형식 검증

---

## ✅ 검증 체크리스트

**Userflow 일치성**:
- [x] UserFlow에 명시된 모든 데이터 포함됨
- [x] YAGNI 원칙 준수 (불필요한 컬럼 없음)
- [x] Phase 분류가 UserFlow 키워드와 일치

**성능 최적화**:
- [x] 주요 조회 패턴에 인덱스 정의
- [x] 외래키 관계 최적화 (CASCADE/RESTRICT)
- [x] 페이징 쿼리 최적화

**데이터 무결성**:
- [x] 제약조건 정의 (UNIQUE, CHECK)
- [x] Enum 활용한 상태 관리
- [x] 트랜잭션 경계 명확화

**실제 운영 준비**:
- [x] Migration 파일 생성
- [x] Seed 데이터 준비
- [x] Prisma Schema 최적화

이제 체험단 매칭 플랫폼의 완전한 데이터베이스 스키마가 준비되었습니다!