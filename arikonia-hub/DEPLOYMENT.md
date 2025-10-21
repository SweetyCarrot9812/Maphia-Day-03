# Arikonia Hub - Vercel 배포 가이드

## 1. Vercel 환경 변수 설정

Vercel 대시보드에서 다음 환경 변수들을 설정해야 합니다:

### 필수 환경 변수

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://bijluuvpkzhjbypbhlqy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpamx1dXZwa3poamJ5cGJobHF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY3MzA1OTksImV4cCI6MjA1MjMwNjU5OX0.0aSzHdLOaNKHb3WIK9iBwfMlj2tOz3qMFpk60n-RmWU

# Care-Lit Project URL (프로덕션 배포 후 업데이트)
NEXT_PUBLIC_CARELIT_URL=https://care-lit.vercel.app
```

## 2. Vercel CLI로 배포하기

### 사전 준비

1. Vercel CLI 설치 (아직 안 했다면):
```bash
npm install -g vercel
```

2. Vercel 로그인:
```bash
vercel login
```

### 배포 실행

1. 프로젝트 디렉토리로 이동:
```bash
cd C:\Users\tkand\Desktop\development\Hanoa\arikonia-hub
```

2. 첫 배포 (프로젝트 설정):
```bash
vercel
```

질문에 다음과 같이 답변:
- Set up and deploy? **Yes**
- Which scope? **개인 계정 선택**
- Link to existing project? **No**
- Project name? **arikonia-hub** (또는 원하는 이름)
- In which directory? **./** (기본값)
- Override settings? **No**

3. 프로덕션 배포:
```bash
vercel --prod
```

## 3. 도메인 연결

### Vercel 대시보드에서 설정

1. Vercel 프로젝트 대시보드 접속
2. **Settings** → **Domains** 메뉴로 이동
3. **Add Domain** 클릭
4. 보유한 도메인 입력 (예: `arikonia.com` 또는 `hub.arikonia.com`)
5. DNS 설정 안내에 따라 도메인 제공업체에서 DNS 레코드 추가:

**A 레코드** (루트 도메인의 경우):
```
Type: A
Name: @
Value: 76.76.21.21
```

**CNAME 레코드** (서브도메인의 경우):
```
Type: CNAME
Name: hub (또는 원하는 서브도메인)
Value: cname.vercel-dns.com
```

6. DNS 전파 대기 (최대 48시간, 보통 몇 분)

## 4. 배포 후 환경 변수 업데이트

Care-Lit도 배포한 후:

1. Vercel 대시보드 → **Settings** → **Environment Variables**
2. `NEXT_PUBLIC_CARELIT_URL` 값을 실제 배포된 URL로 업데이트
3. **Redeploy** 버튼 클릭하여 재배포

## 5. 확인 사항

배포 후 다음을 확인:

- [ ] 홈페이지 로딩 확인
- [ ] 회원가입/로그인 작동 확인
- [ ] Supabase 연결 확인 (프로필 설정 페이지)
- [ ] Care-Lit 프로젝트 접속 버튼 확인 (Care-Lit 배포 후)
- [ ] 도메인 접속 확인
- [ ] HTTPS 인증서 자동 발급 확인

## 6. Care-Lit 배포

Care-Lit도 동일한 방식으로 배포:

```bash
cd C:\Users\tkand\Desktop\development\Hanoa\clintest
vercel
vercel --prod
```

환경 변수:
```env
NEXT_PUBLIC_SUPABASE_URL=https://bijluuvpkzhjbypbhlqy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpamx1dXZwa3poamJ5cGJobHF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY3MzA1OTksImV4cCI6MjA1MjMwNjU5OX0.0aSzHdLOaNKHb3WIK9iBwfMlj2tOz3qMFpk60n-RmWU
NEXT_PUBLIC_HUB_URL=https://arikonia.com (또는 실제 Hub URL)
```

## 7. 문제 해결

### 빌드 오류 발생 시

1. 로컬에서 빌드 테스트:
```bash
npm run build
```

2. 오류 수정 후 다시 배포:
```bash
vercel --prod
```

### 환경 변수 관련 오류

1. Vercel 대시보드에서 환경 변수 재확인
2. Production, Preview, Development 모두 체크되어 있는지 확인
3. 재배포 실행

## 8. 도메인 정보

현재 보유하신 도메인을 알려주시면 구체적인 DNS 설정을 안내해드리겠습니다.
