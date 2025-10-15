import { supabase } from '../supabase/client';
import { Seat } from '@/types';

export const seatRepository = {
  async fetchByConcertId(concertId: string): Promise<Seat[]> {
    const { data, error } = await supabase
      .from('seats')
      .select('*')
      .eq('concert_id', concertId)
      .order('row', { ascending: true })
      .order('number', { ascending: true });

    if (error) throw new Error(error.message);
    return data || [];
  },

  async updateBooked(seatIds: string[], isBooked: boolean): Promise<void> {
    const { error } = await supabase
      .from('seats')
      .update({ is_booked: isBooked })
      .in('id', seatIds);

    if (error) throw new Error(error.message);
  },
};
