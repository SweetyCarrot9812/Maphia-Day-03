# OAuth 디버깅 체크리스트

## 1. Supabase 설정 확인 (가장 중요!)

### Authentication → URL Configuration
https://supabase.com/dashboard/project/bijluuvpkzhjbypbhlqy/auth/url-configuration

**Site URL** (정확히 이렇게):
```
https://www.arikonia.com
```
⚠️ 뒤에 슬래시(/) 없이!

**Redirect URLs** (모두 추가):
```
https://www.arikonia.com/**
https://www.arikonia.com/auth/callback
http://localhost:3000/**
http://localhost:3000/auth/callback
```

### Authentication → Providers → Google
- **Enabled**: ✅ 체크
- **Client ID**: `681902870139-811mguf7aagsfkipsee0ac6lad8i2gpa.apps.googleusercontent.com`
- **Client Secret**: 설정되어 있는지 확인

---

## 2. Google Cloud Console 설정 확인

https://console.cloud.google.com/apis/credentials

OAuth 2.0 Client ID 설정:
- **Authorized JavaScript origins**:
  ```
  https://www.arikonia.com
  https://bijluuvpkzhjbypbhlqy.supabase.co
  ```

- **Authorized redirect URIs**:
  ```
  https://bijluuvpkzhjbypbhlqy.supabase.co/auth/v1/callback
  ```

---

## 3. Vercel 환경변수 확인

https://vercel.com/tkandpf26-9808s-projects/arikonia-hub/settings/environment-variables

반드시 있어야 할 변수:
- ✅ `NEXT_PUBLIC_SUPABASE_URL` = `https://bijluuvpkzhjbypbhlqy.supabase.co`
- ✅ `NEXT_PUBLIC_SUPABASE_ANON_KEY` = `eyJhbGci...`
- ✅ `SUPABASE_URL` = `https://bijluuvpkzhjbypbhlqy.supabase.co`
- ✅ `SUPABASE_ANON_KEY` = `eyJhbGci...`

모두 **Production** 환경에 설정되어 있어야 함!

---

## 4. 네트워크 흐름 확인

브라우저 개발자 도구 (F12) → Network 탭 열고:

1. `https://www.arikonia.com/login` 접속
2. "Google로 로그인" 클릭
3. 다음 요청들이 순서대로 발생하는지 확인:

```
✅ POST https://bijluuvpkzhjbypbhlqy.supabase.co/auth/v1/authorize
   → 302 Redirect to Google

✅ GET https://accounts.google.com/o/oauth2/v2/auth
   → Google 로그인 페이지

✅ (로그인 후) GET https://bijluuvpkzhjbypbhlqy.supabase.co/auth/v1/callback?code=...
   → 302 Redirect to app

❓ GET https://www.arikonia.com/auth/callback?code=...
   → 여기서 어떤 응답이 오는지 확인!
```

마지막 요청의 응답 상태 코드와 헤더를 확인하세요:
- **307 Redirect** → 어디로 리다이렉트되는지?
- **404 Not Found** → 라우트 파일이 배포 안 됨
- **500 Internal Server Error** → 서버 에러 발생

---

## 5. 간단한 테스트

### 콜백 라우트가 작동하는지 확인:
브라우저에서 직접 접속:
```
https://www.arikonia.com/auth/callback
```

**기대 결과**: `/dashboard`로 리다이렉트 (code 파라미터 없어도)

**만약 404 에러**면:
→ `app/auth/callback/route.ts` 파일이 배포 안 된 것
→ 재배포 필요

---

## 6. 브라우저 콘솔 에러 확인

F12 → Console 탭에서:
- CORS 에러가 있는지?
- 네트워크 에러가 있는지?
- JavaScript 에러가 있는지?

모두 복사해서 보여주세요.

---

## 7. Vercel 함수 로그 실시간 확인

터미널에서:
```bash
vercel logs https://www.arikonia.com
```

그 상태에서 OAuth 로그인 시도하면 실시간으로 로그가 나옵니다.

찾아야 할 로그:
```
[Auth Callback] ENV 체크 { hasUrl: true, hasKey: true, ... }
[Auth Callback] OAuth error: ...
```

---

## 8. 가장 흔한 원인들

### ❌ Supabase Redirect URL 불일치
- Site URL이 `https://www.arikonia.com/` (슬래시 있음)으로 설정됨
- Redirect URLs에 `https://www.arikonia.com/auth/callback`이 없음

### ❌ Google OAuth Redirect URI 불일치
- Authorized redirect URIs에 Supabase 콜백 URL 없음
- `https://bijluuvpkzhjbypbhlqy.supabase.co/auth/v1/callback` 필수

### ❌ 배포 문제
- 환경변수 설정 후 재배포 안 함
- 코드 변경 후 재배포 안 함
- 캐시 문제 (Ctrl+Shift+R로 강제 새로고침)

### ❌ PKCE 쿠키 문제
- 브라우저가 third-party 쿠키 차단
- 시크릿 모드에서 테스트해보기

---

## 현재 확인된 것

✅ 환경변수 정상 로드: `hasUrl: true, hasKey: true, keyLength: 209`
✅ Vercel 배포 완료
✅ 코드 수정 완료 (서버 전용 ENV, Node 런타임 강제)

## 아직 확인 안 된 것

❓ Supabase Redirect URLs 정확한 설정
❓ Google OAuth Redirect URIs 설정
❓ 실제 네트워크 흐름 (어디서 멈추는지)
❓ 브라우저 콘솔 에러
❓ Vercel 함수 로그 (OAuth 에러 메시지)

---

## 다음 단계

1. **Supabase 대시보드**에서 위 설정 모두 확인
2. **Google Cloud Console**에서 Redirect URIs 확인
3. **브라우저 F12 Network 탭** 열고 OAuth 시도
4. `/auth/callback?code=...` 요청의 **응답 상태 코드와 헤더** 확인
5. 결과 보고

이 중 하나라도 잘못되면 OAuth는 절대 작동하지 않습니다.
