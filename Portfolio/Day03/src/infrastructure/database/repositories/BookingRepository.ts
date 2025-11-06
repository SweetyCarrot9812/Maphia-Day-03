/**
 * @SPEC:REPO-002 Booking Repository Implementation
 * Handles data persistence for bookings using Supabase
 */
import { supabase } from '../supabase';
import { Booking, BookingProps } from '../../../domain/entities/Booking';
import { PhoneNumber } from '../../../domain/value-objects/PhoneNumber';
import { Repository, Result, TimeSlot } from '../../../domain/types/common';

export class BookingRepository implements Repository<Booking> {
  async findById(id: string): Promise<Result<Booking>> {
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .eq('id', id)
        .single();

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      if (!data) {
        return { success: false, error: new Error('Booking not found') };
      }

      const booking = new Booking({
        id: data.id,
        roomId: data.room_id,
        userName: data.user_name,
        userPhone: new PhoneNumber(data.user_phone),
        purpose: data.purpose,
        startTime: new Date(data.start_time),
        endTime: new Date(data.end_time),
        status: data.status,
        createdAt: new Date(data.created_at),
        updatedAt: new Date(data.updated_at),
      });

      return { success: true, data: booking };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async save(booking: Booking): Promise<Result<Booking>> {
    try {
      const bookingData = {
        id: booking.id,
        room_id: booking.roomId,
        user_name: booking.userName,
        user_phone: booking.userPhone.getValue(),
        purpose: booking.purpose,
        start_time: booking.startTime.toISOString(),
        end_time: booking.endTime.toISOString(),
        status: booking.status,
        updated_at: new Date().toISOString(),
      };

      const { data, error } = await supabase
        .from('bookings')
        .upsert(bookingData)
        .select()
        .single();

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      const savedBooking = new Booking({
        id: data.id,
        roomId: data.room_id,
        userName: data.user_name,
        userPhone: new PhoneNumber(data.user_phone),
        purpose: data.purpose,
        startTime: new Date(data.start_time),
        endTime: new Date(data.end_time),
        status: data.status,
        createdAt: new Date(data.created_at),
        updatedAt: new Date(data.updated_at),
      });

      return { success: true, data: savedBooking };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async delete(id: string): Promise<Result<void>> {
    try {
      const { error } = await supabase
        .from('bookings')
        .delete()
        .eq('id', id);

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      return { success: true, data: undefined };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async findByRoomAndTimeRange(roomId: string, timeSlot: TimeSlot): Promise<Result<Booking[]>> {
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .eq('room_id', roomId)
        .eq('status', 'confirmed')
        .or(`start_time.lte.${timeSlot.endTime.toISOString()},end_time.gte.${timeSlot.startTime.toISOString()}`)
        .order('start_time');

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      const bookings = data.map(booking => new Booking({
        id: booking.id,
        roomId: booking.room_id,
        userName: booking.user_name,
        userPhone: new PhoneNumber(booking.user_phone),
        purpose: booking.purpose,
        startTime: new Date(booking.start_time),
        endTime: new Date(booking.end_time),
        status: booking.status,
        createdAt: new Date(booking.created_at),
        updatedAt: new Date(booking.updated_at),
      }));

      return { success: true, data: bookings };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async findByUserPhone(phoneNumber: PhoneNumber): Promise<Result<Booking[]>> {
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .eq('user_phone', phoneNumber.getValue())
        .order('created_at', { ascending: false });

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      const bookings = data.map(booking => new Booking({
        id: booking.id,
        roomId: booking.room_id,
        userName: booking.user_name,
        userPhone: new PhoneNumber(booking.user_phone),
        purpose: booking.purpose,
        startTime: new Date(booking.start_time),
        endTime: new Date(booking.end_time),
        status: booking.status,
        createdAt: new Date(booking.created_at),
        updatedAt: new Date(booking.updated_at),
      }));

      return { success: true, data: bookings };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }

  async findUpcomingBookings(): Promise<Result<Booking[]>> {
    try {
      const now = new Date().toISOString();

      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .eq('status', 'confirmed')
        .gte('start_time', now)
        .order('start_time');

      if (error) {
        return { success: false, error: new Error(error.message) };
      }

      const bookings = data.map(booking => new Booking({
        id: booking.id,
        roomId: booking.room_id,
        userName: booking.user_name,
        userPhone: new PhoneNumber(booking.user_phone),
        purpose: booking.purpose,
        startTime: new Date(booking.start_time),
        endTime: new Date(booking.end_time),
        status: booking.status,
        createdAt: new Date(booking.created_at),
        updatedAt: new Date(booking.updated_at),
      }));

      return { success: true, data: bookings };
    } catch (error) {
      return { success: false, error: error as Error };
    }
  }
}