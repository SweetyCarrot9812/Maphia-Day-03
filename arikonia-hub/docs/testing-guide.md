# Testing Guide - Arikonia Hub
**Version**: 1.0.0
**Date**: 2025-10-21
**Status**: Ready for Manual Testing

---

## 🎯 Testing Overview

This guide provides step-by-step testing instructions for all implemented use cases and Phase 1 improvements.

**Testing Environment**:
- **Development Server**: http://localhost:3006
- **Database**: Supabase (requires setup - see prerequisites)
- **Browser**: Chrome/Firefox (latest)
- **Tools**: Browser DevTools, Network tab, Application Storage

---

## 📋 Prerequisites

### ⚠️ CRITICAL: Database Setup Required

Before testing, you **MUST** execute the database migration:

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to SQL Editor
3. Execute migration from `/supabase/migrations/20251021000000_initial_schema.sql`
4. Verify tables created:
   ```sql
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = 'public';
   ```
   Expected tables: `users`, `subscription_plans`, `user_subscriptions`, `projects`, `project_access_mappings`

5. Insert initial data (subscription plans, projects):
   ```sql
   -- See deployment-guide.md for complete SQL
   ```

### Environment Variables Check

Verify `.env.local` exists with:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

---

## 🧪 Test Cases

### TC-001: Email Signup (UC-001)

**Objective**: Verify email signup creates user profile with free plan

**Steps**:
1. Navigate to http://localhost:3006/signup
2. Fill in form:
   - Email: `test1@example.com`
   - Password: `password123`
   - Nickname: `테스터1`
3. Click "회원가입"

**Expected Results**:
- ✅ Success toast: "회원가입 성공!"
- ✅ Redirect to `/dashboard`
- ✅ User profile created in `users` table
- ✅ Free plan subscription created in `user_subscriptions`
- ✅ Dashboard shows user info and "Free" plan badge

**Validation Queries**:
```sql
-- Check user profile
SELECT * FROM users WHERE email = 'test1@example.com';

-- Check subscription
SELECT us.*, sp.*
FROM user_subscriptions us
JOIN subscription_plans sp ON us.plan_id = sp.id
WHERE us.user_id = (SELECT id FROM users WHERE email = 'test1@example.com');
```

**Edge Cases**:
- [ ] TC-001a: Duplicate email shows error "이미 사용 중인 이메일입니다"
- [ ] TC-001b: Weak password (< 6 chars) shows validation error
- [ ] TC-001c: Invalid nickname (special chars) shows error
- [ ] TC-001d: Empty fields show validation errors

---

### TC-002: Google OAuth Signup (UC-002)

**Objective**: Verify Google OAuth creates user profile with auto-generated nickname

**Prerequisites**:
- Google OAuth configured in Supabase (see deployment-guide.md)

**Steps**:
1. Navigate to http://localhost:3006/signup
2. Click "구글로 시작하기" button
3. Complete Google OAuth flow
4. (First-time users) Redirect to `/dashboard`

**Expected Results**:
- ✅ Success toast: "회원가입 성공! (구글)"
- ✅ Redirect to `/dashboard`
- ✅ User profile created with:
   - Email from Google
   - Auto-generated nickname from email (e.g., `test_user` from `test.user@gmail.com`)
   - Avatar URL from Google profile
- ✅ Free plan subscription created

**DevTools Validation**:
1. Open DevTools → Application → Cookies
2. Verify Supabase auth cookies present:
   - `sb-<project>-auth-token`
   - `sb-<project>-auth-token.0`

**Edge Cases**:
- [ ] TC-002a: Existing Google user shows login instead of signup
- [ ] TC-002b: OAuth popup blocked shows error
- [ ] TC-002c: OAuth cancelled returns to signup page

---

### TC-003: Email Login (UC-003)

**Objective**: Verify email login restores session and loads user data

**Prerequisites**:
- User created from TC-001

**Steps**:
1. Navigate to http://localhost:3006/login
2. Fill in form:
   - Email: `test1@example.com`
   - Password: `password123`
3. Click "로그인"

**Expected Results**:
- ✅ Success toast: "로그인 성공!"
- ✅ Redirect to `/dashboard`
- ✅ User profile loaded with subscription info
- ✅ Session persisted in Supabase cookies (NOT localStorage)

**DevTools Validation - Phase 1 Security Improvement**:
1. Open DevTools → Application → Local Storage → `http://localhost:3006`
2. Check `auth-storage` key:
   ```json
   {
     "state": {
       "user": {
         "id": "uuid",
         "email": "test1@example.com"
       }
     },
     "version": 0
   }
   ```
3. **VERIFY**: `session` key is **NOT** present (security fix)
4. **VERIFY**: JWT tokens are **NOT** in localStorage

**Network Tab Validation - Phase 1 DB Optimization**:
1. Open DevTools → Network tab
2. Clear network log
3. Login
4. Filter by "supabase"
5. **VERIFY**: Only **1 database query** for user data (not 2)
6. Check request:
   - URL: `/rest/v1/users?...`
   - Should have `select=*,user_subscriptions!inner(...)` (JOIN query)

**Edge Cases**:
- [ ] TC-003a: Wrong password shows error "이메일 또는 비밀번호가 올바르지 않습니다"
- [ ] TC-003b: Non-existent email shows same error
- [ ] TC-003c: Session persists after page refresh

---

### TC-004: Google OAuth Login (UC-003)

**Objective**: Verify Google OAuth login for existing users

**Prerequisites**:
- User created from TC-002

**Steps**:
1. Navigate to http://localhost:3006/login
2. Click "구글로 로그인" button
3. Complete Google OAuth flow

**Expected Results**:
- ✅ Success toast: "로그인 성공! (구글)"
- ✅ Redirect to `/dashboard`
- ✅ Existing user profile loaded (no duplicate created)
- ✅ Session restored

**Edge Cases**:
- [ ] TC-004a: Different Google account creates new user
- [ ] TC-004b: OAuth flow cancelled returns to login

---

### TC-005: Project Access Control - Free Plan (UC-004)

**Objective**: Verify free plan users can only access Care-Lit (view)

**Prerequisites**:
- User logged in with Free plan (from TC-001 or TC-003)

**Steps**:
1. On Dashboard (http://localhost:3006/dashboard)
2. Verify 3 project cards displayed:
   - Care-Lit (간호사 국가고시 학습 플랫폼)
   - Tem-Flow (템플릿 워크플로우 관리)
   - Arisper (아리스퍼 프로젝트)

**Test 5a: Allowed Access (Care-Lit)**
1. Click "접속하기" on Care-Lit card
2. **Expected**:
   - ✅ Loading state shown briefly
   - ✅ Success toast: "Care-Lit 접속 중..."
   - ✅ Redirect to `https://care-lit.vercel.app?token=<JWT>`
   - ✅ SSO token passed in URL

**DevTools Validation - Phase 1 Cache Implementation**:
1. Click "접속하기" on Care-Lit again (within 5 minutes)
2. Open DevTools → Network tab
3. **VERIFY**: No new database query (cache hit)
4. **Expected**: ~1ms response time (vs ~200ms for first call)

**Test 5b: Denied Access (Tem-Flow)**
1. Click "접속하기" on Tem-Flow card
2. **Expected**:
   - ✅ Error toast: "접근 권한이 없습니다"
   - ✅ Description: "BASIC 플랜 이상이 필요합니다"
   - ✅ No redirect (stays on dashboard)

**Test 5c: Denied Access (Arisper)**
1. Click "접속하기" on Arisper card
2. **Expected**:
   - ✅ Error toast: "접근 권한이 없습니다"
   - ✅ Description: "PREMIUM 플랜 이상이 필요합니다"
   - ✅ No redirect

**Cache Expiration Test**:
1. Wait 5 minutes after first Care-Lit access
2. Click "접속하기" on Care-Lit again
3. Open DevTools → Network tab
4. **VERIFY**: New database query made (cache expired)

**Edge Cases**:
- [ ] TC-005d: Logout and login preserves access check cache
- [ ] TC-005e: Force refresh bypasses cache (if implemented)

---

### TC-006: Project Access Control - Premium Plan (UC-004)

**Objective**: Verify premium plan users can access all projects

**Prerequisites**:
- Create premium user manually in database:
  ```sql
  -- Update existing user to premium
  UPDATE user_subscriptions
  SET plan_id = (SELECT id FROM subscription_plans WHERE name = 'premium')
  WHERE user_id = (SELECT id FROM users WHERE email = 'test1@example.com');
  ```
- Login with premium user

**Steps**:
1. On Dashboard, click "접속하기" on each project:
   - Care-Lit
   - Tem-Flow
   - Arisper

**Expected Results**:
- ✅ All projects redirect with SSO token
- ✅ Success toast for each project
- ✅ No "접근 권한이 없습니다" errors

---

## 🔐 Phase 1 Security Improvements Validation

### SEC-001: Session Persistence Security

**Objective**: Verify JWT tokens not exposed in localStorage

**Steps**:
1. Login with any user
2. Open DevTools → Application → Local Storage
3. Check `auth-storage` key

**Expected**:
```json
{
  "state": {
    "user": {
      "id": "uuid",
      "email": "user@example.com"
    }
  },
  "version": 0
}
```

**CRITICAL Checks**:
- ❌ `session` key should **NOT** exist
- ❌ `access_token` should **NOT** be visible
- ❌ `refresh_token` should **NOT** be visible
- ✅ Only `user.id` and `user.email` persisted

**Security Test**:
1. Open Console, run:
   ```javascript
   JSON.parse(localStorage.getItem('auth-storage'))
   ```
2. **VERIFY**: No sensitive tokens present

---

### PERF-001: Database Query Optimization

**Objective**: Verify single JOIN query for user data load

**Steps**:
1. Logout
2. Open DevTools → Network tab
3. Clear network log
4. Login
5. Filter by "supabase" or "rest/v1"

**Expected**:
- ✅ Only **1 request** to `/rest/v1/users`
- ✅ Request includes:
  ```
  select=*,user_subscriptions!inner(plan_id,status,expires_at,subscription_plans(id,name,display_name,max_projects,max_file_size_mb))
  ```
- ❌ No separate request to `/rest/v1/user_subscriptions`

**Performance Metrics**:
- First load (uncached): ~90ms (acceptable)
- Subsequent loads: ~50-70ms (good)

---

### CACHE-001: Cache Expiration Logic

**Objective**: Verify 5-minute cache with expiration

**Steps**:
1. Login
2. Dashboard → Click "접속하기" on Care-Lit (First call)
3. Check Network tab → should see database query
4. Immediately click "접속하기" again (Second call)
5. Check Network tab → should see **NO** database query
6. Wait 5 minutes
7. Click "접속하기" again (Third call)
8. Check Network tab → should see database query

**Expected Cache Behavior**:
- **Call 1**: Cache miss → Database query → ~200ms
- **Call 2**: Cache hit → Memory lookup → ~1ms
- **Call 3** (after 5min): Cache expired → Database query → ~200ms

**DevTools Validation**:
1. Open Console, run:
   ```javascript
   // Access Zustand store directly
   window.__ZUSTAND_DEVTOOLS_GLOBAL_HOOK__?.stores?.get(0)?.getState()
   ```
2. Check `accessResults` object:
   ```javascript
   {
     "carelit": {
       "result": { has_access: true, ... },
       "timestamp": 1729486800000,
       "expiresAt": 1729487100000  // timestamp + 300000ms (5 min)
     }
   }
   ```

---

### CONFIG-001: Constants File Usage

**Objective**: Verify centralized configuration in use

**Steps**:
1. Check Dashboard displays projects from constants
2. Open browser DevTools → Sources → webpack:// → lib/constants.ts
3. Verify PROJECTS array loaded

**Code Validation**:
1. Check `app/dashboard/page.tsx` imports:
   ```typescript
   import { PROJECTS } from '@/lib/constants'
   ```
2. Verify no hardcoded project URLs in components

---

## 📊 Performance Benchmarks

### Baseline Metrics

| Operation | Target | Measurement Method |
|-----------|--------|-------------------|
| **Page Load (Dashboard)** | < 2s | Network → Finish time |
| **Login API Call** | < 500ms | Network → auth endpoint |
| **Load User Data** | < 100ms | Network → users endpoint |
| **Access Check (first)** | < 250ms | Network → rpc/check_project_access |
| **Access Check (cached)** | < 5ms | Console → performance.now() |
| **Cache Hit Rate** | > 90% | Manual calculation |

### How to Measure

**1. Page Load Time**:
```
DevTools → Network → Disable cache → Reload → Check "Finish" time
```

**2. API Response Time**:
```
DevTools → Network → Filter "fetch/XHR" → Check "Time" column
```

**3. Cache Performance**:
```javascript
// In browser console
const start = performance.now()
// Click "접속하기"
const end = performance.now()
console.log(`Access check took ${end - start}ms`)
```

---

## 🐛 Known Issues & Limitations

### Current Limitations

1. **Database Not Configured**:
   - Migration not executed
   - Initial data not inserted
   - Tests will fail without DB setup

2. **Google OAuth Not Configured**:
   - OAuth redirect URL not set
   - TC-002 and TC-004 will fail
   - See deployment-guide.md for setup

3. **SSO Token in URL**:
   - Security concern: `?token=<JWT>` logged in browser history
   - Recommendation: Implement POST-based SSO (Phase 2)

4. **localStorage Session Exposure** (FIXED in Phase 1):
   - ✅ Session tokens removed from localStorage
   - ✅ Only minimal user info persisted

5. **No Cache Expiration** (FIXED in Phase 1):
   - ✅ 5-minute TTL implemented
   - ✅ Force refresh option available

---

## ✅ Testing Checklist

### Pre-Testing Setup
- [ ] Database migration executed
- [ ] Initial data inserted (plans, projects)
- [ ] Environment variables configured
- [ ] Development server running (http://localhost:3006)
- [ ] Browser DevTools ready

### Functional Testing
- [ ] TC-001: Email Signup
- [ ] TC-001a-d: Edge cases
- [ ] TC-002: Google OAuth Signup (if configured)
- [ ] TC-003: Email Login
- [ ] TC-004: Google OAuth Login (if configured)
- [ ] TC-005: Free Plan Access Control
- [ ] TC-005a-e: Cache and edge cases
- [ ] TC-006: Premium Plan Access Control

### Security Testing
- [ ] SEC-001: Session not in localStorage
- [ ] Verify httpOnly cookies present
- [ ] Verify JWT not exposed in DevTools

### Performance Testing
- [ ] PERF-001: Single JOIN query
- [ ] CACHE-001: Cache hit/miss behavior
- [ ] Measure baseline metrics
- [ ] Verify 5-minute cache expiration

### Configuration Testing
- [ ] CONFIG-001: Constants file in use
- [ ] Environment variables working
- [ ] Project URLs correct

---

## 📝 Test Results Template

```markdown
## Test Execution Report
**Date**: 2025-10-21
**Tester**: [Your Name]
**Environment**: Development (localhost:3006)

### Test Results Summary
- **Total Tests**: X
- **Passed**: X
- **Failed**: X
- **Skipped**: X (e.g., OAuth not configured)

### Failed Tests
| Test ID | Description | Expected | Actual | Notes |
|---------|-------------|----------|--------|-------|
| TC-XXX | ... | ... | ... | ... |

### Performance Results
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Page Load | < 2s | Xs | ✅/❌ |
| Load User Data | < 100ms | Xms | ✅/❌ |
| Cache Hit Rate | > 90% | X% | ✅/❌ |

### Issues Found
1. **Issue**: [Description]
   - **Severity**: Critical/High/Medium/Low
   - **Steps to Reproduce**: ...
   - **Expected**: ...
   - **Actual**: ...

### Recommendations
1. [Action item 1]
2. [Action item 2]
```

---

## 🚀 Next Steps After Testing

1. **If All Tests Pass**:
   - Proceed to Vercel deployment
   - Configure production Supabase
   - Set production environment variables
   - Execute deployment checklist

2. **If Tests Fail**:
   - Document failures in test report
   - Create GitHub issues for bugs
   - Prioritize critical issues
   - Fix and re-test

3. **Optional Enhancements** (Phase 2):
   - Implement error categorization
   - Add loading skeletons
   - Create unit tests
   - Set up E2E tests with Playwright

---

**Ready for Testing**: All code complete, documentation ready, dev server running.

**Blockers**: Database migration required before functional tests can pass.

**Estimated Testing Time**: 30-45 minutes (with DB setup)
