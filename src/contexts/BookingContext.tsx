'use client';

import {
  createContext,
  useContext,
  useReducer,
  useCallback,
  ReactNode,
  useMemo,
  useEffect,
} from 'react';
import { Booking, BookingFormData, BookingWithConcert } from '@/types';
import { bookingRepository } from '@/lib/repositories/bookingRepository';

interface BookingState {
  bookings: BookingWithConcert[];
  currentBooking: Partial<BookingFormData> | null;
  loading: boolean;
  error: string | null;
}

type BookingAction =
  | { type: 'LOAD_BOOKINGS_REQUEST' }
  | { type: 'LOAD_BOOKINGS_SUCCESS'; payload: BookingWithConcert[] }
  | { type: 'LOAD_BOOKINGS_FAILURE'; payload: string }
  | { type: 'SET_BOOKING_INFO'; payload: Partial<BookingFormData> }
  | { type: 'CREATE_BOOKING_REQUEST' }
  | { type: 'CREATE_BOOKING_SUCCESS'; payload: Booking }
  | { type: 'CREATE_BOOKING_FAILURE'; payload: string }
  | { type: 'CANCEL_BOOKING_REQUEST' }
  | { type: 'CANCEL_BOOKING_SUCCESS'; payload: string }
  | { type: 'CANCEL_BOOKING_FAILURE'; payload: string }
  | { type: 'CLEAR_CURRENT_BOOKING' };

interface BookingContextValue {
  bookings: BookingWithConcert[];
  currentBooking: Partial<BookingFormData> | null;
  loading: boolean;
  error: string | null;
  loadBookings: () => Promise<void>;
  setBookingInfo: (info: Partial<BookingFormData>) => void;
  createBooking: (concertId: string, seatIds: string[], totalAmount: number) => Promise<Booking>;
  cancelBooking: (bookingId: string) => Promise<void>;
  clearCurrentBooking: () => void;
  upcomingBookings: BookingWithConcert[];
  pastBookings: BookingWithConcert[];
}

const initialState: BookingState = {
  bookings: [],
  currentBooking: null,
  loading: false,
  error: null,
};

function bookingReducer(state: BookingState, action: BookingAction): BookingState {
  switch (action.type) {
    case 'LOAD_BOOKINGS_REQUEST':
      return { ...state, loading: true, error: null };

    case 'LOAD_BOOKINGS_SUCCESS':
      return { ...state, bookings: action.payload, loading: false };

    case 'LOAD_BOOKINGS_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'SET_BOOKING_INFO':
      return { ...state, currentBooking: { ...state.currentBooking, ...action.payload } };

    case 'CREATE_BOOKING_REQUEST':
      return { ...state, loading: true, error: null };

    case 'CREATE_BOOKING_SUCCESS':
      return {
        ...state,
        currentBooking: null,
        loading: false,
      };

    case 'CREATE_BOOKING_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'CANCEL_BOOKING_REQUEST':
      return { ...state, loading: true, error: null };

    case 'CANCEL_BOOKING_SUCCESS':
      return {
        ...state,
        bookings: state.bookings.map((booking) =>
          booking.id === action.payload ? { ...booking, status: 'cancelled' as const } : booking
        ),
        loading: false,
      };

    case 'CANCEL_BOOKING_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'CLEAR_CURRENT_BOOKING':
      return { ...state, currentBooking: null };

    default:
      return state;
  }
}

const BookingContext = createContext<BookingContextValue | null>(null);

export function BookingProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(bookingReducer, initialState);

  const loadBookings = useCallback(async () => {
    dispatch({ type: 'LOAD_BOOKINGS_REQUEST' });
    try {
      const bookings = await bookingRepository.fetchAll();
      dispatch({ type: 'LOAD_BOOKINGS_SUCCESS', payload: bookings });
    } catch (error) {
      dispatch({
        type: 'LOAD_BOOKINGS_FAILURE',
        payload: error instanceof Error ? error.message : 'Failed to load bookings',
      });
    }
  }, []);

  const setBookingInfo = useCallback((info: Partial<BookingFormData>) => {
    dispatch({ type: 'SET_BOOKING_INFO', payload: info });
  }, []);

  const createBooking = useCallback(
    async (concertId: string, seatIds: string[], totalAmount: number) => {
      if (!state.currentBooking) {
        throw new Error('예약 정보를 입력해주세요');
      }

      const { name, phone, email, birthdate } = state.currentBooking;

      if (!name || !phone || !email) {
        throw new Error('필수 항목을 입력해주세요');
      }

      if (seatIds.length === 0) {
        throw new Error('좌석을 선택해주세요');
      }

      dispatch({ type: 'CREATE_BOOKING_REQUEST' });

      try {
        const booking = await bookingRepository.create({
          concertId,
          seatIds,
          customerName: name,
          customerPhone: phone,
          customerEmail: email,
          customerBirthdate: birthdate,
          totalAmount,
        });

        dispatch({ type: 'CREATE_BOOKING_SUCCESS', payload: booking });
        return booking;
      } catch (error) {
        dispatch({
          type: 'CREATE_BOOKING_FAILURE',
          payload: error instanceof Error ? error.message : 'Failed to create booking',
        });
        throw error;
      }
    },
    [state.currentBooking]
  );

  const cancelBooking = useCallback(async (bookingId: string) => {
    dispatch({ type: 'CANCEL_BOOKING_REQUEST' });

    try {
      await bookingRepository.cancel(bookingId);
      dispatch({ type: 'CANCEL_BOOKING_SUCCESS', payload: bookingId });
    } catch (error) {
      dispatch({
        type: 'CANCEL_BOOKING_FAILURE',
        payload: error instanceof Error ? error.message : 'Failed to cancel booking',
      });
      throw error;
    }
  }, []);

  const clearCurrentBooking = useCallback(() => {
    dispatch({ type: 'CLEAR_CURRENT_BOOKING' });
  }, []);

  const upcomingBookings = useMemo(
    () =>
      state.bookings.filter(
        (booking) => booking.concert && new Date(booking.concert.date) > new Date()
      ),
    [state.bookings]
  );

  const pastBookings = useMemo(
    () =>
      state.bookings.filter(
        (booking) => booking.concert && new Date(booking.concert.date) <= new Date()
      ),
    [state.bookings]
  );

  useEffect(() => {
    loadBookings();
  }, [loadBookings]);

  const value: BookingContextValue = {
    bookings: state.bookings,
    currentBooking: state.currentBooking,
    loading: state.loading,
    error: state.error,
    loadBookings,
    setBookingInfo,
    createBooking,
    cancelBooking,
    clearCurrentBooking,
    upcomingBookings,
    pastBookings,
  };

  return <BookingContext.Provider value={value}>{children}</BookingContext.Provider>;
}

export function useBooking() {
  const context = useContext(BookingContext);
  if (!context) {
    throw new Error('useBooking must be used within BookingProvider');
  }
  return context;
}
