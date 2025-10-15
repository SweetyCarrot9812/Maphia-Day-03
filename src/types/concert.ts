export interface SeatLayout {
  rows: number;
  columns: number;
}

export interface Concert {
  id: string;
  title: string;
  artist: string;
  date: string;
  venue: string;
  description: string | null;
  image_url: string | null;
  running_time: number;
  created_at: string;
  updated_at: string;
  /** 예약당 최대 선택 가능 좌석 수 (1-10) */
  max_seats_per_booking: number;
  /** 좌석 그리드 구성 */
  seat_layout: SeatLayout;
}
