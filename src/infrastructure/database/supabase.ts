/**
 * @SPEC:INFRA-001 Supabase Database Configuration
 * Centralized database client configuration
 */
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase configuration. Please check your environment variables.');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
  db: {
    schema: 'public',
  },
  global: {
    headers: {
      'x-application-name': 'conference-room-booking',
    },
  },
});

// Database type definitions
export interface Database {
  public: {
    Tables: {
      conference_rooms: {
        Row: {
          id: string;
          name: string;
          capacity: number;
          amenities: string[];
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          capacity: number;
          amenities?: string[];
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          capacity?: number;
          amenities?: string[];
          is_active?: boolean;
          updated_at?: string;
        };
      };
      bookings: {
        Row: {
          id: string;
          room_id: string;
          user_name: string;
          user_phone: string;
          purpose: string;
          start_time: string;
          end_time: string;
          status: 'confirmed' | 'cancelled';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          room_id: string;
          user_name: string;
          user_phone: string;
          purpose: string;
          start_time: string;
          end_time: string;
          status?: 'confirmed' | 'cancelled';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          room_id?: string;
          user_name?: string;
          user_phone?: string;
          purpose?: string;
          start_time?: string;
          end_time?: string;
          status?: 'confirmed' | 'cancelled';
          updated_at?: string;
        };
      };
      admin_sessions: {
        Row: {
          id: string;
          admin_id: string;
          password_hash: string;
          last_login: string;
          is_active: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          admin_id: string;
          password_hash: string;
          last_login?: string;
          is_active?: boolean;
          created_at?: string;
        };
        Update: {
          id?: string;
          admin_id?: string;
          password_hash?: string;
          last_login?: string;
          is_active?: boolean;
        };
      };
    };
  };
}