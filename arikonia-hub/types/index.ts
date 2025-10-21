import { User, Session } from '@supabase/supabase-js'

export interface UserProfile {
  id: string
  email: string
  name: string
  nickname: string
  birth_date: string | null
  country_code: string | null
  phone: string | null
  phone_verified: boolean
  avatar_url: string | null
  created_at: string
  updated_at: string
}

export interface Subscription {
  plan_id: string
  plan_name: 'free' | 'basic' | 'premium' | 'enterprise'
  status: 'active' | 'expired' | 'cancelled'
  expires_at: string | null
  max_projects: number
  max_file_size_mb: number
}

export interface ProjectAccessResult {
  has_access: boolean
  project_name: string
  access_level?: 'view' | 'full' | 'admin'
  source?: 'plan' | 'individual'
  error?: string
  required_plan?: string
}

export type { User, Session }
