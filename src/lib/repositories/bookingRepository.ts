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

    // 각 예약의 좌석 정보 가져오기
    const bookingsWithSeats = await Promise.all(
      (data || []).map(async (item) => {
        // seat_ids 배열에 있는 좌석 정보 조회
        const { data: seats } = await supabase
          .from('seats')
          .select('row, number, grade')
          .in('id', item.seat_ids);

        return {
          ...item,
          concert: Array.isArray(item.concert) ? item.concert[0] : item.concert,
          seats: seats || [],
        };
      })
    );

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
};
