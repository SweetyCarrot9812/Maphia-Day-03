export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          name: string
          phone: string
          email: string
          role: 'influencer' | 'advertiser'
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          name: string
          phone: string
          email: string
          role: 'influencer' | 'advertiser'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          phone?: string
          email?: string
          role?: 'influencer' | 'advertiser'
          created_at?: string
          updated_at?: string
        }
      }
      influencer_profiles: {
        Row: {
          id: string
          user_id: string
          birth_date: string
          is_verified: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          birth_date: string
          is_verified?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          birth_date?: string
          is_verified?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      influencer_channels: {
        Row: {
          id: string
          influencer_id: string
          channel_type: string
          channel_name: string
          channel_url: string
          is_verified: boolean
          verification_status: 'pending' | 'verified' | 'failed'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          influencer_id: string
          channel_type: string
          channel_name: string
          channel_url: string
          is_verified?: boolean
          verification_status?: 'pending' | 'verified' | 'failed'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          influencer_id?: string
          channel_type?: string
          channel_name?: string
          channel_url?: string
          is_verified?: boolean
          verification_status?: 'pending' | 'verified' | 'failed'
          created_at?: string
          updated_at?: string
        }
      }
      advertiser_profiles: {
        Row: {
          id: string
          user_id: string
          business_name: string
          business_location: string
          business_category: string
          business_registration_number: string
          is_verified: boolean
          verification_status: 'pending' | 'verified' | 'failed'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          business_name: string
          business_location: string
          business_category: string
          business_registration_number: string
          is_verified?: boolean
          verification_status?: 'pending' | 'verified' | 'failed'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          business_name?: string
          business_location?: string
          business_category?: string
          business_registration_number?: string
          is_verified?: boolean
          verification_status?: 'pending' | 'verified' | 'failed'
          created_at?: string
          updated_at?: string
        }
      }
      campaigns: {
        Row: {
          id: string
          advertiser_id: string
          title: string
          description: string
          benefits: string
          mission: string
          store_location: string
          recruitment_start: string
          recruitment_end: string
          max_participants: number
          status: 'recruiting' | 'closed' | 'selected' | 'completed'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          advertiser_id: string
          title: string
          description: string
          benefits: string
          mission: string
          store_location: string
          recruitment_start: string
          recruitment_end: string
          max_participants: number
          status?: 'recruiting' | 'closed' | 'selected' | 'completed'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          advertiser_id?: string
          title?: string
          description?: string
          benefits?: string
          mission?: string
          store_location?: string
          recruitment_start?: string
          recruitment_end?: string
          max_participants?: number
          status?: 'recruiting' | 'closed' | 'selected' | 'completed'
          created_at?: string
          updated_at?: string
        }
      }
      applications: {
        Row: {
          id: string
          campaign_id: string
          influencer_id: string
          motivation: string
          visit_date: string
          status: 'pending' | 'selected' | 'rejected'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          campaign_id: string
          influencer_id: string
          motivation: string
          visit_date: string
          status?: 'pending' | 'selected' | 'rejected'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          campaign_id?: string
          influencer_id?: string
          motivation?: string
          visit_date?: string
          status?: 'pending' | 'selected' | 'rejected'
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}
