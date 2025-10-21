# Arikonia Hub - Deployment Guide
**Version**: 1.0.0
**Date**: 2025-10-21
**Phase**: 1 MVP Authentication

---

## Pre-Deployment Checklist

### 1. Database Setup (Supabase)

#### **Step 1: Create Supabase Project**
1. Go to [supabase.com](https://supabase.com)
2. Create new project: `arikonia-hub`
3. Note down:
   - Project URL: `https://your-project.supabase.co`
   - Anon Key: `eyJhbGc...`

#### **Step 2: Run Migration SQL**
```sql
-- Copy from: supabase/migrations/20251021000000_initial_schema.sql
-- Paste into: Supabase SQL Editor
-- Execute the migration
```

**Migration creates**:
- Tables: `users`, `subscription_plans`, `user_subscriptions`, `projects`, `plan_project_access`, `user_project_access`
- Functions: `handle_new_user()`, `update_updated_at()`, `check_project_access()`
- Triggers: Auto-create user profile on signup
- RLS Policies: Row-level security for all tables

#### **Step 3: Verify Database**
```sql
-- Check tables created
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Check functions created
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public';

-- Check RLS policies
SELECT tablename, policyname FROM pg_policies;
```

#### **Step 4: Insert Initial Data**
```sql
-- Insert subscription plans
INSERT INTO subscription_plans (name, display_name, max_projects, max_file_size_mb, price_monthly) VALUES
  ('free', 'Free', 1, 5, 0),
  ('basic', 'Basic', 2, 10, 9900),
  ('premium', 'Premium', 5, 50, 19900),
  ('enterprise', 'Enterprise', 999, 500, 49900);

-- Insert projects
INSERT INTO projects (code, name, description, url, is_active) VALUES
  ('carelit', 'Care-Lit', '간호사 국가고시 학습 플랫폼', 'https://care-lit.vercel.app', true),
  ('temflow', 'Tem-Flow', '템플릿 워크플로우 관리', 'https://tem-flow.vercel.app', true),
  ('arisper', 'Arisper', '아리스퍼 프로젝트', 'https://arisper.vercel.app', true);

-- Insert plan-project access mappings
-- Free plan: carelit (view)
INSERT INTO plan_project_access (plan_id, project_id, access_level)
SELECT p.id, pr.id, 'view'
FROM subscription_plans p, projects pr
WHERE p.name = 'free' AND pr.code = 'carelit';

-- Basic plan: carelit (full), temflow (view)
INSERT INTO plan_project_access (plan_id, project_id, access_level)
SELECT p.id, pr.id, 'full'
FROM subscription_plans p, projects pr
WHERE p.name = 'basic' AND pr.code = 'carelit';

INSERT INTO plan_project_access (plan_id, project_id, access_level)
SELECT p.id, pr.id, 'view'
FROM subscription_plans p, projects pr
WHERE p.name = 'basic' AND pr.code = 'temflow';

-- Premium plan: carelit (full), temflow (full), arisper (view)
INSERT INTO plan_project_access (plan_id, project_id, access_level)
SELECT p.id, pr.id, 'full'
FROM subscription_plans p, projects pr
WHERE p.name = 'premium' AND pr.code IN ('carelit', 'temflow');

INSERT INTO plan_project_access (plan_id, project_id, access_level)
SELECT p.id, pr.id, 'view'
FROM subscription_plans p, projects pr
WHERE p.name = 'premium' AND pr.code = 'arisper';

-- Enterprise plan: all (full)
INSERT INTO plan_project_access (plan_id, project_id, access_level)
SELECT p.id, pr.id, 'full'
FROM subscription_plans p, projects pr
WHERE p.name = 'enterprise';
```

#### **Step 5: Enable Google OAuth**
1. Go to Supabase Dashboard → Authentication → Providers
2. Enable Google OAuth
3. Add authorized redirect URL: `https://your-app.vercel.app/auth/callback`
4. Note down Google Client ID and Secret

---

### 2. Environment Variables

#### **Development (.env.local)**
```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...

# Optional: For development
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

#### **Production (Vercel)**
Add to Vercel project settings:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
NEXT_PUBLIC_APP_URL=https://arikonia-hub.vercel.app
```

---

### 3. Vercel Deployment

#### **Step 1: Connect GitHub Repository**
```bash
# Initialize git (if not already)
git init
git add .
git commit -m "feat: Phase 1 MVP Authentication complete"

# Create GitHub repository
# Push to GitHub
git remote add origin https://github.com/your-username/arikonia-hub.git
git branch -M main
git push -u origin main
```

#### **Step 2: Deploy to Vercel**
1. Go to [vercel.com](https://vercel.com)
2. Click "New Project"
3. Import from GitHub: `your-username/arikonia-hub`
4. Configure:
   - Framework Preset: Next.js
   - Root Directory: `./`
   - Build Command: `npm run build`
   - Output Directory: `.next`

#### **Step 3: Add Environment Variables**
In Vercel project settings:
- Add `NEXT_PUBLIC_SUPABASE_URL`
- Add `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- Add `NEXT_PUBLIC_APP_URL`

#### **Step 4: Deploy**
- Click "Deploy"
- Wait for deployment to complete
- Note down deployment URL: `https://your-app.vercel.app`

#### **Step 5: Update Supabase Redirect URLs**
In Supabase Dashboard → Authentication → URL Configuration:
- Add redirect URL: `https://your-app.vercel.app/auth/callback`
- Add site URL: `https://your-app.vercel.app`

---

### 4. Post-Deployment Verification

#### **Test UC-001: Email Signup**
1. Go to `/signup`
2. Fill form: email, password, nickname
3. Submit
4. Check email for verification (if enabled)
5. Verify user created in Supabase Dashboard

#### **Test UC-002: Google OAuth Signup**
1. Go to `/signup`
2. Click "Google로 시작하기"
3. Complete Google OAuth
4. Should redirect to `/dashboard`
5. Verify user and subscription created

#### **Test UC-003: Login**
1. Go to `/login`
2. Login with email/password or Google
3. Should redirect to `/dashboard`
4. Verify session persisted

#### **Test UC-004: Project Access Control**
1. Go to `/dashboard`
2. Click "접속하기" on Care-Lit (free plan should have access)
3. Check access denied for premium projects
4. Verify toast messages appear

---

### 5. Monitoring & Analytics

#### **Recommended Services**
- **Error Monitoring**: [Sentry](https://sentry.io)
- **Analytics**: [Vercel Analytics](https://vercel.com/analytics)
- **Performance**: [Vercel Speed Insights](https://vercel.com/docs/speed-insights)

#### **Setup Sentry (Optional)**
```bash
npm install @sentry/nextjs

# Initialize
npx @sentry/wizard@latest -i nextjs

# Add to .env.local
NEXT_PUBLIC_SENTRY_DSN=https://...@sentry.io/...
```

---

## Troubleshooting

### Issue: "User not found after signup"
**Cause**: Database trigger not working
**Fix**: Check `handle_new_user()` trigger exists and is enabled

### Issue: "OAuth callback failed"
**Cause**: Redirect URL mismatch
**Fix**: Ensure redirect URL in Supabase matches exactly (including trailing slash)

### Issue: "Access denied for all projects"
**Cause**: `check_project_access()` function missing or RLS policies too strict
**Fix**: Verify function exists and RLS policies allow reads

### Issue: "Session not persisting"
**Cause**: localStorage blocked or cookies disabled
**Fix**: Check browser settings, ensure site is HTTPS in production

### Issue: "CORS errors"
**Cause**: Supabase CORS configuration
**Fix**: Add your domain to Supabase CORS allowed origins

---

## Security Checklist

- [ ] Environment variables not committed to git
- [ ] `.env.local` in `.gitignore`
- [ ] Supabase RLS policies enabled on all tables
- [ ] Google OAuth redirect URLs whitelisted
- [ ] HTTPS enforced in production (Vercel does this automatically)
- [ ] Session tokens not exposed in logs
- [ ] Error messages don't leak sensitive info

---

## Performance Optimization

### Vercel Configuration
```json
// vercel.json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    }
  ],
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "/api/:path*"
    }
  ]
}
```

### Next.js Configuration
```typescript
// next.config.ts
const nextConfig = {
  poweredByHeader: false,
  compress: true,
  images: {
    domains: ['lh3.googleusercontent.com'], // For Google avatars
    formats: ['image/webp', 'image/avif'],
  },
}
```

---

## Rollback Plan

### If deployment fails:
1. Check Vercel deployment logs
2. Verify environment variables set correctly
3. Check Supabase connection
4. Rollback to previous Vercel deployment: Deployments → ⋯ → Promote to Production

### If database migration fails:
1. Backup database first: `pg_dump`
2. Drop tables and re-run migration
3. Or manually fix migration errors

---

## Maintenance

### Regular Tasks
- **Weekly**: Check error logs in Sentry
- **Monthly**: Review Supabase usage and quotas
- **Quarterly**: Update dependencies (`npm outdated`)

### Updating Dependencies
```bash
# Check outdated packages
npm outdated

# Update non-breaking
npm update

# Update Next.js
npm install next@latest react@latest react-dom@latest

# Update Supabase
npm install @supabase/supabase-js@latest @supabase/ssr@latest
```

---

## Support & Documentation

- **Next.js Docs**: https://nextjs.org/docs
- **Supabase Docs**: https://supabase.com/docs
- **Vercel Docs**: https://vercel.com/docs
- **Zustand Docs**: https://zustand.docs.pmnd.rs

---

**Deployment Guide Version**: 1.0.0
**Last Updated**: 2025-10-21
**Maintained By**: Development Team
