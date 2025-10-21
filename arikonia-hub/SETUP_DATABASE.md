# Database Setup Guide

## Prerequisites

- Supabase account and project created
- Project URL and Anon Key configured in `.env.local`

## Step 1: Run Database Migration

You need to apply the database schema to your Supabase project. Choose one of the methods below:

### Option A: Supabase Dashboard (Recommended)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy the entire contents of `supabase/migrations/20251021000000_initial_schema.sql`
5. Paste into the SQL editor
6. Click **Run** to execute the migration

### Option B: Supabase CLI

If you have Supabase CLI installed:

```bash
# Login to Supabase
supabase login

# Link your project
supabase link --project-ref YOUR_PROJECT_REF

# Push the migration
supabase db push
```

## Step 2: Verify Setup

After running the migration, verify the tables were created:

```sql
-- Run this in Supabase SQL Editor
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

You should see these tables:
- `users`
- `subscription_plans`
- `user_subscriptions`
- `projects`
- `plan_project_access`
- `user_project_access`

## Step 3: Verify Environment Variables

Check your `.env.local` file has the correct values:

```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...your-key-here
```

Get these from: **Settings** → **API** in your Supabase dashboard

## Step 4: Restart Dev Server

After applying the migration:

```bash
# Stop the current dev server (Ctrl+C)
# Clear Next.js cache
rm -rf .next

# Restart
npm run dev
```

## Troubleshooting

### Error: "Invalid API key"

**Solution**:
1. Check your `.env.local` file has the correct `NEXT_PUBLIC_SUPABASE_ANON_KEY`
2. Go to Supabase Dashboard → Settings → API
3. Copy the **anon public** key (not the service_role key)
4. Update `.env.local` and restart the server

### Error: "relation 'users' does not exist"

**Solution**: You haven't run the migration yet. Follow Step 1 above.

### Error: Column "name" does not exist

**Solution**:
1. Drop the old `users` table if it exists
2. Re-run the migration from `supabase/migrations/20251021000000_initial_schema.sql`

## Database Schema Overview

### users table
- `id` (UUID) - Primary key, references auth.users
- `email` (TEXT) - Unique, not null
- `name` (TEXT) - Real name (실명), not null
- `nickname` (TEXT) - Display name, not null
- `birth_date` (DATE) - Optional
- `country_code` (TEXT) - Default '+82'
- `phone` (TEXT) - Full phone with country code
- `phone_verified` (BOOLEAN) - Default false
- `avatar_url` (TEXT) - Profile image URL
- `created_at`, `updated_at` (TIMESTAMPTZ)

### subscription_plans table
- Pre-populated with: free, basic, premium, enterprise

### user_subscriptions table
- Automatically created when user signs up (via trigger)
- Admin email gets 'enterprise' plan
- Others get 'free' plan

## Email Confirmation

By default, Supabase requires email confirmation for new users.

**To enable/disable**:
1. Go to **Authentication** → **Providers** → **Email**
2. Toggle **Confirm email** setting
3. For testing, you can disable it
4. For production, keep it enabled

## Next Steps

After setup is complete, try the signup flow:
1. Navigate to http://localhost:3009/signup
2. Fill in all fields:
   - Email
   - Name (실명)
   - Nickname
   - Birth Date (optional)
   - Country Code + Phone
   - Password
   - Terms agreement
3. Submit and check for email confirmation (if enabled)
