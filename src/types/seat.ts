export type SeatGrade = 'VIP' | 'R' | 'S' | 'A';

export interface Seat {
  id: string;
  concert_id: string;
  row: number;
  number: number;
  grade: SeatGrade;
  price: number;
  is_booked: boolean;
  created_at: string;
  updated_at: string;
}
