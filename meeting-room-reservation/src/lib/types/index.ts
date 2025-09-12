// 회의실 예약 시스템 타입 정의

export interface Room {
  id: string;
  name: string;
  location: string;
  capacity: number;
  description?: string;
  created_at: string;
  updated_at: string;
}

export interface Reservation {
  id: string;
  room_id: string;
  reserver_name: string;
  reserver_phone: string;
  password_hash: string;
  title: string;
  start_time: string;
  end_time: string;
  created_at: string;
}

export interface ReservationWithRoom extends Reservation {
  room: Room;
  status: 'upcoming' | 'ongoing' | 'completed';
}

export interface TimeSlot {
  start: string;
  end: string;
  available: boolean;
}

export interface ReservationFormData {
  reserver_name: string;
  reserver_phone: string;
  password: string;
  title: string;
  date: string;
  start_time: string;
  end_time: string;
}

export interface ReservationAuthData {
  reserver_phone: string;
  password: string;
}

// 데이터베이스 응답 타입
export interface DatabaseResponse<T> {
  data: T | null;
  error: Error | null;
}

export interface ReservationConflictCheckParams {
  room_id: string;
  start_time: string;
  end_time: string;
  exclude_id?: string;
}