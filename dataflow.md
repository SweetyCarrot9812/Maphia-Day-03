# 데이터베이스 관점의 데이터플로우

## 핵심 원칙
- 유저플로우에 명시된 데이터만 포함
- PostgreSQL + Supabase Auth 사용
- RLS(Row Level Security)로 권한 관리

---

## 1. 회원가입 & 역할 선택

```
[User Input]
├─ name, phone, email, role
└─ terms agreement, auth method

[Processing]
├─ Supabase Auth: auth.users 생성 (email verification)
├─ INSERT profiles (id, name, phone, email, role)
└─ INSERT terms_agreements (user_id, terms_version, agreed_at, ip_address)

[Output]
├─ profiles.id (user_id)
├─ profiles.role → 분기점
│  ├─ 'influencer' → 인플루언서 정보 등록 플로우
│  └─ 'advertiser' → 광고주 정보 등록 플로우
└─ Email verification 발송
```

---

## 2. 인플루언서 정보 등록

```
[User Input]
├─ birth_date
└─ channels[] (channel_type, channel_name, channel_url)

[Processing]
├─ INSERT influencer_profiles (user_id, birth_date)
│  └─ age 자동 계산 (GENERATED ALWAYS AS)
├─ INSERT influencer_channels[] (influencer_id, channel_type, channel_name, channel_url)
│  └─ verification_status = 'pending'
└─ INSERT verification_jobs (entity_type='influencer_channel', entity_id=channel.id)

[Output]
├─ influencer_profiles.id
├─ influencer_channels[].id
├─ influencer_channels[].verification_status
└─ influencer_profiles.is_verified (검증 완료 시 TRUE)
```

---

## 3. 광고주 정보 등록

```
[User Input]
├─ business_name, business_location, business_category
└─ business_registration_number

[Processing]
├─ INSERT advertiser_profiles (user_id, business_name, business_location,
│                               business_category, business_registration_number)
│  └─ verification_status = 'pending'
└─ INSERT verification_jobs (entity_type='advertiser_business', entity_id=advertiser.id)

[Output]
├─ advertiser_profiles.id
├─ advertiser_profiles.verification_status
└─ advertiser_profiles.is_verified (검증 완료 시 TRUE)
```

---

## 4. 홈 & 체험단 목록 탐색

```
[User Input]
├─ 홈 접속
└─ 필터/정렬 선택

[Processing]
└─ SELECT campaigns WHERE status = 'recruiting'
   ├─ ORDER BY recruitment_start DESC (or filter options)
   └─ LIMIT/OFFSET (pagination)

[Output]
├─ campaigns[] (id, title, description, benefits, recruitment_end, max_participants)
└─ 클릭 시 campaign_id → 상세 페이지
```

---

## 5. 체험단 상세

```
[User Input]
└─ campaign_id (from URL or click)

[Processing]
├─ SELECT campaigns WHERE id = campaign_id
├─ JOIN advertiser_profiles (for store info)
└─ SELECT influencer_profiles WHERE user_id = auth.uid()
   └─ CHECK is_verified = TRUE (지원 가능 여부)

[Output]
├─ campaign 상세 (title, description, benefits, mission, store_location, recruitment_end)
├─ max_participants vs 현재 지원자 수
└─ 지원 버튼 활성화 여부 (is_verified 기반)
```

---

## 6. 체험단 지원

```
[User Input]
├─ campaign_id
├─ motivation (각오 한마디)
└─ visit_date (방문 예정일자)

[Processing]
├─ SELECT influencer_profiles WHERE user_id = auth.uid()
│  └─ CHECK is_verified = TRUE
├─ SELECT campaigns WHERE id = campaign_id
│  └─ CHECK status = 'recruiting'
│  └─ CHECK recruitment_end > NOW()
├─ SELECT applications WHERE campaign_id = X AND influencer_id = Y
│  └─ UNIQUE constraint (중복 지원 방지)
└─ INSERT applications (campaign_id, influencer_id, motivation, visit_date)
   └─ status = 'pending'

[Output]
├─ applications.id
├─ applications.status = 'pending'
└─ 지원 완료 피드백
```

---

## 7. 내 지원 목록 (인플루언서 전용)

```
[User Input]
└─ status filter ('pending', 'selected', 'rejected', or ALL)

[Processing]
├─ SELECT influencer_profiles WHERE user_id = auth.uid()
└─ SELECT applications
   ├─ WHERE influencer_id = influencer_profiles.id
   ├─ AND status = [filter] (if specified)
   ├─ JOIN campaigns (for campaign details)
   └─ ORDER BY created_at DESC

[Output]
└─ applications[] (
     campaign_title,
     motivation,
     visit_date,
     status,
     created_at
   )
```

---

## 8. 광고주 체험단 관리

```
[User Input - View]
└─ 광고주 메뉴 접근

[Processing]
├─ SELECT advertiser_profiles WHERE user_id = auth.uid()
│  └─ CHECK is_verified = TRUE
└─ SELECT campaigns WHERE advertiser_id = advertiser_profiles.id
   └─ ORDER BY created_at DESC

[Output]
└─ campaigns[] (id, title, status, recruitment_period, max_participants)

---

[User Input - Create]
├─ title, description, benefits, mission, store_location
├─ recruitment_start, recruitment_end
└─ max_participants

[Processing]
├─ SELECT advertiser_profiles WHERE user_id = auth.uid()
│  └─ CHECK is_verified = TRUE (권한 검증)
└─ INSERT campaigns (advertiser_id, title, description, benefits, mission,
                     store_location, recruitment_start, recruitment_end,
                     max_participants)
   └─ status = 'recruiting'

[Output]
├─ campaigns.id
└─ 목록 갱신
```

---

## 9. 광고주 체험단 상세 & 모집 관리

```
[User Input - View Applications]
└─ campaign_id

[Processing]
├─ SELECT campaigns WHERE id = campaign_id
│  └─ CHECK advertiser_id = (current user's advertiser_profiles.id)
└─ SELECT applications WHERE campaign_id = campaign_id
   └─ JOIN influencer_profiles, influencer_channels (for influencer details)

[Output]
└─ applications[] (influencer_name, motivation, visit_date, status)

---

[User Input - Close Recruitment]
└─ campaign_id

[Processing]
└─ UPDATE campaigns SET status = 'closed' WHERE id = campaign_id
   └─ CHECK current status = 'recruiting'

[Output]
└─ campaigns.status = 'closed'

---

[User Input - Select Winners]
├─ campaign_id
└─ selected_application_ids[]

[Processing]
├─ UPDATE applications SET status = 'selected'
│  └─ WHERE id IN (selected_application_ids)
├─ UPDATE applications SET status = 'rejected'
│  └─ WHERE campaign_id = X AND id NOT IN (selected_application_ids)
└─ UPDATE campaigns SET status = 'selected' WHERE id = campaign_id

[Output]
├─ applications[].status = 'selected' or 'rejected'
└─ campaigns.status = 'selected'
```

---

## 상태 전이 다이어그램

### Campaign Status Flow
```
recruiting → closed → selected → completed
```

### Application Status Flow
```
pending → selected
        → rejected
```

### Verification Status Flow
```
pending → verified
        → failed
```

---

## 권한 가드 체크 포인트

| 작업 | 필수 조건 |
|------|-----------|
| 체험단 지원 | `influencer_profiles.is_verified = TRUE` |
| 체험단 생성 | `advertiser_profiles.is_verified = TRUE` |
| 체험단 관리 | `campaigns.advertiser_id = current_user.advertiser_id` |
| 지원 목록 조회 | `applications.influencer_id = current_user.influencer_id` |

---

## RLS(Row Level Security) 정책

- **profiles**: 본인 프로필만 조회/수정
- **influencer_profiles/channels**: 본인 데이터만 관리
- **advertiser_profiles**: 본인 데이터만 관리
- **campaigns**: 모집중인 것은 모두 조회 가능, 관리는 본인 것만
- **applications**: 본인 지원 내역만 관리, 광고주는 본인 캠페인 지원자만 조회

---

## 비동기 검증 프로세스

```
[Trigger]
└─ INSERT verification_jobs (entity_type, entity_id, status='pending')

[Background Job]
├─ SELECT verification_jobs WHERE status = 'pending'
├─ Process verification (external API call)
└─ UPDATE verification_jobs SET status = 'completed', result = {...}

[Callback]
└─ UPDATE influencer_channels or advertiser_profiles
   ├─ verification_status = 'verified' or 'failed'
   └─ is_verified = TRUE (if all verifications passed)
```
