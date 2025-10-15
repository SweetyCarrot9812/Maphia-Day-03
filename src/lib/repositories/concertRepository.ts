import { supabase } from '../supabase/client';
import { Concert } from '@/types';

export const concertRepository = {
  async fetchAll(): Promise<Concert[]> {
    const { data, error } = await supabase
      .from('concerts')
      .select('*')
      .order('date', { ascending: true });

    if (error) throw new Error(error.message);
    return data || [];
  },

  async fetchById(id: string): Promise<Concert | null> {
    const { data, error } = await supabase
      .from('concerts')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw new Error(error.message);
    return data;
  },
};
