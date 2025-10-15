import { supabase } from '../supabase/client';
import { Booking, BookingWithConcert } from '@/types';
import { seatRepository } from './seatRepository';

interface CreateBookingData {
  concertId: string;
  seatIds: string[];
  customerName: string;
  customerPhone: string;
  customerEmail: string;
  customerBirthdate?: string;
  totalAmount: number;
}

export const bookingRepository = {
  async create(data: CreateBookingData): Promise<Booking> {
    const bookingNumber = `BK-${Date.now()}-${Math.floor(Math.random() * 10000)
      .toString()
      .padStart(4, '0')}`;

    const bookingData = {
      booking_number: bookingNumber,
      concert_id: data.concertId,
      seat_ids: data.seatIds,
      customer_name: data.customerName,
      customer_phone: data.customerPhone,
      customer_email: data.customerEmail,
      customer_birthdate: data.customerBirthdate || null,
      total_amount: data.totalAmount,
      status: 'confirmed' as const,
    };

    // 예약 생성
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .insert(bookingData)
      .select()
      .single();

    if (bookingError) throw new Error(bookingError.message);

    // 좌석 상태 업데이트
    await seatRepository.updateBooked(data.seatIds, true);

    return booking;
  },

  async fetchAll(): Promise<BookingWithConcert[]> {
    const { data, error } = await supabase
      .from('bookings')
      .select(
        `
        *,
        concert:concerts(title, date, venue, image_url)
      `
      )
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    if (!data || data.length === 0) return [];

    // N+1 쿼리 최적화: 모든 좌석 ID를 한 번에 조회
    const allSeatIds = data.flatMap((booking) => booking.seat_ids);
    const uniqueSeatIds = [...new Set(allSeatIds)];

    // 모든 좌석 정보를 한 번의 쿼리로 가져오기
    const { data: allSeats } = await supabase
      .from('seats')
      .select('id, row, number, grade')
      .in('id', uniqueSeatIds);

    // 좌석 ID를 키로 하는 Map 생성
    const seatMap = new Map(
      (allSeats || []).map((seat) => [seat.id, seat])
    );

    // 각 예약에 해당하는 좌석 정보 매핑
    type SeatData = { id: string; row: number; number: number; grade: string };
    const bookingsWithSeats = data.map((item) => ({
      ...item,
      concert: Array.isArray(item.concert) ? item.concert[0] : item.concert,
      seats: item.seat_ids
        .map((seatId: string) => seatMap.get(seatId))
        .filter((seat: SeatData | undefined): seat is SeatData => seat !== undefined)
        .map(({ row, number, grade }: SeatData) => ({ row, number, grade })), // id 제외하고 반환
    }));

    return bookingsWithSeats;
  },

  async fetchById(id: string): Promise<BookingWithConcert | null> {
    const { data, error } = await supabase
      .from('bookings')
      .select(
        `
        *,
        concert:concerts(title, date, venue, image_url)
      `
      )
      .eq('id', id)
      .single();

    if (error) throw new Error(error.message);
    return {
      ...data,
      concert: Array.isArray(data.concert) ? data.concert[0] : data.concert,
    };
  },

  async cancel(id: string): Promise<void> {
    // 예약 정보 조회
    const { data: booking, error: fetchError } = await supabase
      .from('bookings')
      .select('seat_ids, status')
      .eq('id', id)
      .single();

    if (fetchError) throw new Error(fetchError.message);
    if (!booking) throw new Error('예약을 찾을 수 없습니다');
    if (booking.status === 'cancelled') throw new Error('이미 취소된 예약입니다');

    // 예약 상태 취소로 업데이트
    const { error: updateError } = await supabase
      .from('bookings')
      .update({ status: 'cancelled' })
      .eq('id', id);

    if (updateError) throw new Error(updateError.message);

    // 좌석 상태 원복 (예약 해제)
    await seatRepository.updateBooked(booking.seat_ids, false);
  },
};
