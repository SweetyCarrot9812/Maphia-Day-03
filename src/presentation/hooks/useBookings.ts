/**
 * @SPEC:HOOKS-002 Bookings API Hooks
 * TanStack Query hooks for booking data fetching and mutations
 */
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { BookingRepository } from '../../infrastructure/database/repositories/BookingRepository';
import { Booking } from '../../domain/entities/Booking';
import { PhoneNumber } from '../../domain/value-objects/PhoneNumber';
import { TimeSlot } from '../../domain/types/common';
import { useUIStore } from '../stores/uiStore';
import { useBookingStore } from '../stores/bookingStore';

const bookingRepository = new BookingRepository();

// Query keys
export const bookingKeys = {
  all: ['bookings'] as const,
  lists: () => [...bookingKeys.all, 'list'] as const,
  list: (filters: Record<string, unknown>) => [...bookingKeys.lists(), filters] as const,
  details: () => [...bookingKeys.all, 'detail'] as const,
  detail: (id: string) => [...bookingKeys.details(), id] as const,
  byRoom: (roomId: string, timeSlot?: TimeSlot) => [...bookingKeys.all, 'by-room', roomId, timeSlot] as const,
  byUser: (phoneNumber: string) => [...bookingKeys.all, 'by-user', phoneNumber] as const,
  upcoming: () => [...bookingKeys.all, 'upcoming'] as const,
};

// Fetch booking by ID
export function useBooking(id: string) {
  const { showToast } = useUIStore();

  return useQuery({
    queryKey: bookingKeys.detail(id),
    queryFn: async () => {
      const result = await bookingRepository.findById(id);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    enabled: !!id,
    staleTime: 2 * 60 * 1000, // 2 minutes
    onError: (error: Error) => {
      showToast(`Failed to load booking: ${error.message}`, 'error');
    },
  });
}

// Fetch bookings by room and time range
export function useBookingsByRoomAndTime(roomId: string, timeSlot?: TimeSlot) {
  const { showToast } = useUIStore();

  return useQuery({
    queryKey: bookingKeys.byRoom(roomId, timeSlot),
    queryFn: async () => {
      if (!timeSlot) return [];

      const result = await bookingRepository.findByRoomAndTimeRange(roomId, timeSlot);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    enabled: !!roomId && !!timeSlot,
    staleTime: 1 * 60 * 1000, // 1 minute (real-time data)
    onError: (error: Error) => {
      showToast(`Failed to check room availability: ${error.message}`, 'error');
    },
  });
}

// Fetch bookings by user phone
export function useBookingsByUser(phoneNumber: string) {
  const { showToast } = useUIStore();

  return useQuery({
    queryKey: bookingKeys.byUser(phoneNumber),
    queryFn: async () => {
      const phone = new PhoneNumber(phoneNumber);
      const result = await bookingRepository.findByUserPhone(phone);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    enabled: !!phoneNumber,
    staleTime: 5 * 60 * 1000, // 5 minutes
    onError: (error: Error) => {
      showToast(`Failed to load your bookings: ${error.message}`, 'error');
    },
  });
}

// Fetch upcoming bookings
export function useUpcomingBookings() {
  const { showToast } = useUIStore();

  return useQuery({
    queryKey: bookingKeys.upcoming(),
    queryFn: async () => {
      const result = await bookingRepository.findUpcomingBookings();
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    staleTime: 2 * 60 * 1000, // 2 minutes
    refetchInterval: 5 * 60 * 1000, // Auto-refresh every 5 minutes
    onError: (error: Error) => {
      showToast(`Failed to load upcoming bookings: ${error.message}`, 'error');
    },
  });
}

// Create booking mutation
export function useCreateBooking() {
  const queryClient = useQueryClient();
  const { showToast, setLoading } = useUIStore();
  const { resetBookingForm, setCurrentStep } = useBookingStore();

  return useMutation({
    mutationFn: async (booking: Booking) => {
      const result = await bookingRepository.save(booking);
      if (!result.success) {
        throw new Error(result.error.message);
      }
      return result.data;
    },
    onMutate: () => {
      setLoading(true, 'Creating your booking...');
    },
    onSuccess: (data, variables) => {
      // Invalidate related queries
      queryClient.invalidateQueries({ queryKey: bookingKeys.all });
      queryClient.invalidateQueries({ queryKey: bookingKeys.byRoom(data.roomId) });
      queryClient.invalidateQueries({ queryKey: bookingKeys.upcoming() });

      // Update specific booking cache
      queryClient.setQueryData(bookingKeys.detail(data.id), data);

      // Reset booking form and navigate to confirmation
      resetBookingForm();
      setCurrentStep('confirmation');

      showToast('Booking created successfully!', 'success');
      setLoading(false);
    },
    onError: (error: Error) => {
      showToast(`Failed to create booking: ${error.message}`, 'error');
      setLoading(false);
    },
  });
}

// Cancel booking mutation
export function useCancelBooking() {
  const queryClient = useQueryClient();
  const { showToast, setLoading } = useUIStore();

  return useMutation({
    mutationFn: async (bookingId: string) => {
      // First get the booking to cancel it
      const getResult = await bookingRepository.findById(bookingId);
      if (!getResult.success) {
        throw new Error(getResult.error.message);
      }

      const booking = getResult.data;
      booking.cancel(); // Domain method

      const saveResult = await bookingRepository.save(booking);
      if (!saveResult.success) {
        throw new Error(saveResult.error.message);
      }

      return saveResult.data;
    },
    onMutate: () => {
      setLoading(true, 'Cancelling booking...');
    },
    onSuccess: (data, variables) => {
      // Invalidate related queries
      queryClient.invalidateQueries({ queryKey: bookingKeys.all });
      queryClient.invalidateQueries({ queryKey: bookingKeys.byRoom(data.roomId) });
      queryClient.invalidateQueries({ queryKey: bookingKeys.upcoming() });

      // Update specific booking cache
      queryClient.setQueryData(bookingKeys.detail(data.id), data);

      showToast('Booking cancelled successfully', 'success');
      setLoading(false);
    },
    onError: (error: Error) => {
      showToast(`Failed to cancel booking: ${error.message}`, 'error');
      setLoading(false);
    },
  });
}

// Check room availability (utility hook)
export function useRoomAvailability(roomId: string, timeSlot?: TimeSlot) {
  const { data: conflictingBookings = [], isLoading } = useBookingsByRoomAndTime(roomId, timeSlot);

  const isAvailable = conflictingBookings.length === 0;

  return {
    isAvailable,
    isLoading,
    conflictingBookings,
  };
}