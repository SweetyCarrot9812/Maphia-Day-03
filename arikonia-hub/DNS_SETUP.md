# arikonia.com DNS 설정 가이드

## 현재 상태

- ✅ Vercel 배포 완료: https://arikonia-f4selfugc-tkandpf26-9808s-projects.vercel.app
- ✅ 도메인 추가 완료: arikonia.com, www.arikonia.com
- ⏳ DNS 설정 필요

## DNS 설정 방법

현재 네임서버: `ns1.hosting.co.kr`, `ns2.hosting.co.kr`, `ns3.hosting.co.kr`, `ns4.hosting.co.kr`

### 옵션 1: A 레코드 설정 (권장)

도메인 등록 업체(hosting.co.kr) 관리 페이지에서 다음 DNS 레코드를 추가하세요:

#### 1. 루트 도메인 (arikonia.com)

```
레코드 타입: A
호스트명: @ (또는 공백)
값: 76.76.21.21
TTL: 3600 (또는 기본값)
```

#### 2. www 서브도메인 (www.arikonia.com)

```
레코드 타입: A
호스트명: www
값: 76.76.21.21
TTL: 3600 (또는 기본값)
```

### 옵션 2: CNAME 레코드 (www만)

www만 CNAME으로 설정하려면:

```
레코드 타입: CNAME
호스트명: www
값: cname.vercel-dns.com
TTL: 3600 (또는 기본값)
```

**주의**: 루트 도메인(@)은 반드시 A 레코드를 사용해야 합니다.

## 단계별 설정 방법

### 1. hosting.co.kr 관리 페이지 접속

1. hosting.co.kr 웹사이트 접속
2. 로그인
3. 도메인 관리 메뉴 찾기
4. arikonia.com 선택
5. DNS 관리 또는 DNS 레코드 설정 메뉴 클릭

### 2. 기존 A 레코드 확인

기존에 설정된 A 레코드가 있다면:
- **@ (루트 도메인)**: 삭제 또는 `76.76.21.21`로 변경
- **www**: 삭제 또는 `76.76.21.21`로 변경

### 3. 새 A 레코드 추가

위의 "옵션 1: A 레코드 설정"에 따라 2개의 레코드 추가:
1. @ → 76.76.21.21
2. www → 76.76.21.21

### 4. 저장 및 적용

- 변경 사항 저장
- DNS 전파 대기 (최대 48시간, 보통 5-30분)

## DNS 전파 확인

### 1. 온라인 도구 사용

다음 사이트에서 DNS 전파 상태 확인:
- https://dnschecker.org
- 도메인: `arikonia.com` 입력
- 레코드 타입: `A` 선택
- 결과가 `76.76.21.21`로 표시되면 성공

### 2. 명령어로 확인

Windows PowerShell에서:

```powershell
# 루트 도메인 확인
nslookup arikonia.com

# www 확인
nslookup www.arikonia.com
```

결과에 `76.76.21.21`이 표시되면 성공

## 설정 완료 후

DNS가 전파되면:

1. **접속 테스트**
   - http://arikonia.com 접속
   - http://www.arikonia.com 접속
   - 자동으로 HTTPS로 리다이렉트되어야 함

2. **HTTPS 인증서**
   - Vercel이 자동으로 Let's Encrypt SSL 인증서 발급
   - 5-10분 소요
   - https://arikonia.com 접속하여 자물쇠 아이콘 확인

3. **환경 변수 업데이트**
   - Vercel 대시보드에서 환경 변수 수정 필요 (아래 참조)

## 환경 변수 설정 (중요!)

DNS 설정 완료 후 Vercel 대시보드에서 환경 변수 추가:

### Vercel 대시보드 접속

1. https://vercel.com/dashboard 접속
2. `arikonia-hub` 프로젝트 클릭
3. **Settings** 탭 클릭
4. **Environment Variables** 메뉴 클릭

### 환경 변수 추가

다음 환경 변수들을 추가하세요:

#### 1. Supabase URL
```
Name: NEXT_PUBLIC_SUPABASE_URL
Value: https://bijluuvpkzhjbypbhlqy.supabase.co
Environments: ✅ Production ✅ Preview ✅ Development
```

#### 2. Supabase Anon Key
```
Name: NEXT_PUBLIC_SUPABASE_ANON_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpamx1dXZwa3poamJ5cGJobHF5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY3MzA1OTksImV4cCI6MjA1MjMwNjU5OX0.0aSzHdLOaNKHb3WIK9iBwfMlj2tOz3qMFpk60n-RmWU
Environments: ✅ Production ✅ Preview ✅ Development
```

#### 3. Care-Lit URL (나중에 Care-Lit 배포 후 업데이트)
```
Name: NEXT_PUBLIC_CARELIT_URL
Value: http://localhost:3001 (임시)
Environments: ✅ Production ✅ Preview ✅ Development
```

### 재배포

환경 변수 추가 후:
1. Vercel 대시보드 **Deployments** 탭으로 이동
2. 최신 배포 옆 **...** 버튼 클릭
3. **Redeploy** 클릭
4. 재배포 완료 대기 (약 1-2분)

## 문제 해결

### DNS가 전파되지 않는 경우

1. **기존 레코드 확인**
   - hosting.co.kr에서 @ 및 www에 대한 기존 A 레코드 모두 삭제
   - 새로 추가한 레코드만 남겨두기

2. **TTL 값 확인**
   - TTL이 너무 높으면 전파가 느림
   - 3600 또는 1800으로 설정 권장

3. **DNS 캐시 초기화**
   ```powershell
   ipconfig /flushdns
   ```

### HTTPS 인증서가 발급되지 않는 경우

1. DNS가 완전히 전파될 때까지 대기 (최대 48시간)
2. Vercel 대시보드 → Domains에서 인증서 상태 확인
3. 필요시 도메인 제거 후 재추가

### 502 Bad Gateway 오류

- 환경 변수가 설정되지 않은 경우 발생
- Vercel 대시보드에서 환경 변수 확인
- 재배포 실행

## 다음 단계

DNS 설정 완료 후:

1. ✅ arikonia.com 접속 확인
2. ✅ HTTPS 인증서 확인
3. ✅ 회원가입/로그인 테스트
4. 🔜 Care-Lit 배포 및 SSO 연동 설정

## Care-Lit 배포 예정

Care-Lit을 배포할 서브도메인:
- **추천**: `carelit.arikonia.com`
- DNS 설정: `CNAME carelit → cname.vercel-dns.com`

배포 후:
- `NEXT_PUBLIC_CARELIT_URL`을 `https://carelit.arikonia.com`으로 업데이트
- Hub에서 Care-Lit 프로젝트 접속 버튼 활성화
