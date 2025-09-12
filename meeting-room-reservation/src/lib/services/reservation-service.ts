import { createClient } from '../supabase/client';
import type { 
  Room, 
  Reservation, 
  ReservationWithRoom, 
  ReservationFormData, 
  ReservationAuthData,
  TimeSlot,
  DatabaseResponse 
} from '../types';

export class ReservationService {
  private supabase = createClient();

  // 회의실 목록 조회
  async getRooms(): Promise<DatabaseResponse<Room[]>> {
    try {
      const { data, error } = await this.supabase
        .from('rooms')
        .select('*')
        .order('name');

      return { data, error };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  }

  // 특정 회의실 조회
  async getRoomById(id: string): Promise<DatabaseResponse<Room>> {
    try {
      const { data, error } = await this.supabase
        .from('rooms')
        .select('*')
        .eq('id', id)
        .single();

      return { data, error };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  }

  // 예약 생성
  async createReservation(roomId: string, formData: ReservationFormData): Promise<DatabaseResponse<Reservation>> {
    try {
      // 시간 충돌 검사
      const conflictCheck = await this.checkTimeConflicts(roomId, formData.start_time, formData.end_time);
      if (conflictCheck.data && conflictCheck.data.length > 0) {
        return { 
          data: null, 
          error: new Error('선택한 시간에 이미 예약이 있습니다.') 
        };
      }

      // 예약 데이터 생성
      const reservationData = {
        room_id: roomId,
        reserver_name: formData.reserver_name,
        reserver_phone: formData.reserver_phone.replace(/-/g, ''), // 하이픈 제거
        password_hash: this.hashPassword(formData.password), // 간단한 해시
        title: formData.title,
        start_time: `${formData.date}T${formData.start_time}:00.000Z`,
        end_time: `${formData.date}T${formData.end_time}:00.000Z`,
      };

      const { data, error } = await this.supabase
        .from('reservations')
        .insert([reservationData])
        .select()
        .single();

      return { data, error };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  }

  // 휴대폰번호와 비밀번호로 예약 조회
  async getReservationsByAuth(phone: string, password: string): Promise<DatabaseResponse<ReservationWithRoom[]>> {
    try {
      const cleanPhone = phone.replace(/-/g, '');
      const hashedPassword = this.hashPassword(password);

      const { data, error } = await this.supabase
        .from('reservations')
        .select(`
          *,
          room:rooms(*)
        `)
        .eq('reserver_phone', cleanPhone)
        .eq('password_hash', hashedPassword)
        .order('start_time', { ascending: false });

      if (error) {
        return { data: null, error };
      }

      // 예약 상태 결정
      const now = new Date();
      const reservationsWithStatus = data?.map(reservation => {
        const startTime = new Date(reservation.start_time);
        const endTime = new Date(reservation.end_time);
        
        let status: 'upcoming' | 'ongoing' | 'completed';
        if (now < startTime) {
          status = 'upcoming';
        } else if (now >= startTime && now <= endTime) {
          status = 'ongoing';
        } else {
          status = 'completed';
        }

        return {
          ...reservation,
          status
        };
      }) || [];

      return { data: reservationsWithStatus, error: null };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  }

  // 특정 회의실의 특정 날짜 예약 조회
  async getRoomReservations(roomId: string, date: string): Promise<DatabaseResponse<Reservation[]>> {
    try {
      const startOfDay = `${date}T00:00:00.000Z`;
      const endOfDay = `${date}T23:59:59.999Z`;

      const { data, error } = await this.supabase
        .from('reservations')
        .select('*')
        .eq('room_id', roomId)
        .gte('start_time', startOfDay)
        .lte('start_time', endOfDay);

      return { data, error };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  }

  // 시간 충돌 검사
  async checkTimeConflicts(roomId: string, startTime: string, endTime: string, excludeId?: string): Promise<DatabaseResponse<Reservation[]>> {
    try {
      let query = this.supabase
        .from('reservations')
        .select('*')
        .eq('room_id', roomId)
        .or(`and(start_time.lte.${startTime},end_time.gt.${startTime}),and(start_time.lt.${endTime},end_time.gte.${endTime}),and(start_time.gte.${startTime},end_time.lte.${endTime})`);

      if (excludeId) {
        query = query.neq('id', excludeId);
      }

      const { data, error } = await query;

      return { data, error };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  }

  // 예약 가능한 시간대 계산
  async getAvailableTimeSlots(roomId: string, date: string): Promise<TimeSlot[]> {
    try {
      const reservationsResponse = await this.getRoomReservations(roomId, date);
      const reservations = reservationsResponse.data || [];
      
      const slots: TimeSlot[] = [];
      const today = new Date();
      const selectedDate = new Date(date);
      const isToday = selectedDate.toDateString() === today.toDateString();
      const currentHour = today.getHours();

      for (let hour = 9; hour < 18; hour++) {
        const startTime = `${hour.toString().padStart(2, '0')}:00`;
        const endTime = `${(hour + 1).toString().padStart(2, '0')}:00`;
        const fullStartTime = `${date}T${startTime}:00.000Z`;
        const fullEndTime = `${date}T${endTime}:00.000Z`;

        // 과거 시간인지 확인 (오늘 날짜인 경우)
        const isPast = isToday && hour <= currentHour;
        
        // 예약 충돌 확인
        const conflictsResponse = await this.checkTimeConflicts(roomId, fullStartTime, fullEndTime);
        const isReserved = (conflictsResponse.data?.length || 0) > 0;

        slots.push({
          start: startTime,
          end: endTime,
          available: !isPast && !isReserved
        });
      }

      return slots;
    } catch (error) {
      console.error('Error getting available time slots:', error);
      return [];
    }
  }

  // 간단한 해시 함수 (실제 프로덕션에서는 bcrypt 사용)
  private hashPassword(password: string): string {
    let hash = 0;
    for (let i = 0; i < password.length; i++) {
      const char = password.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // 32bit integer로 변환
    }
    return Math.abs(hash).toString();
  }

  // 예약 삭제 (관리자용)
  async deleteReservation(reservationId: string): Promise<DatabaseResponse<boolean>> {
    try {
      const { error } = await this.supabase
        .from('reservations')
        .delete()
        .eq('id', reservationId);

      return { data: !error, error };
    } catch (error) {
      return { data: false, error: error as Error };
    }
  }

  // 통계 정보
  async getStats() {
    try {
      const { data, error } = await this.supabase
        .from('reservations')
        .select('*');

      if (error || !data) {
        return { total: 0, upcoming: 0, completed: 0, ongoing: 0 };
      }

      const now = new Date();
      
      return {
        total: data.length,
        upcoming: data.filter(r => new Date(r.start_time) > now).length,
        completed: data.filter(r => new Date(r.end_time) < now).length,
        ongoing: data.filter(r => {
          const start = new Date(r.start_time);
          const end = new Date(r.end_time);
          return start <= now && now <= end;
        }).length
      };
    } catch (error) {
      console.error('Error getting stats:', error);
      return { total: 0, upcoming: 0, completed: 0, ongoing: 0 };
    }
  }
}