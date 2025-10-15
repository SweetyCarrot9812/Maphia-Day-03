'use client';

import {
  createContext,
  useContext,
  useReducer,
  useCallback,
  ReactNode,
  useMemo,
} from 'react';
import { Seat } from '@/types';
import { seatRepository } from '@/lib/repositories/seatRepository';
import { BOOKING_CONSTRAINTS } from '@/constants/ui';

interface SeatState {
  seats: Seat[];
  selectedSeatIds: string[];
  loading: boolean;
  error: string | null;
  maxSeatsPerBooking: number;
}

type SeatAction =
  | { type: 'LOAD_SEATS_REQUEST' }
  | { type: 'LOAD_SEATS_SUCCESS'; payload: { seats: Seat[]; maxSeatsPerBooking: number } }
  | { type: 'LOAD_SEATS_FAILURE'; payload: string }
  | { type: 'TOGGLE_SEAT'; payload: string }
  | { type: 'CLEAR_SELECTED_SEATS' };

interface SeatContextValue {
  seats: Seat[];
  selectedSeatIds: string[];
  loading: boolean;
  error: string | null;
  loadSeats: (concertId: string, maxSeatsPerBooking?: number) => Promise<void>;
  toggleSeat: (seatId: string) => void;
  clearSelectedSeats: () => void;
  selectedSeats: Seat[];
  totalAmount: number;
  availableSeats: Seat[];
  canSelectMore: boolean;
  maxSeatsPerBooking: number;
}

const initialState: SeatState = {
  seats: [],
  selectedSeatIds: [],
  loading: false,
  error: null,
  maxSeatsPerBooking: BOOKING_CONSTRAINTS.MAX_SEATS_PER_BOOKING,
};

function seatReducer(state: SeatState, action: SeatAction): SeatState {
  switch (action.type) {
    case 'LOAD_SEATS_REQUEST':
      return { ...state, loading: true, error: null };

    case 'LOAD_SEATS_SUCCESS':
      return {
        ...state,
        seats: action.payload.seats,
        maxSeatsPerBooking: action.payload.maxSeatsPerBooking,
        loading: false,
        selectedSeatIds: [],
      };

    case 'LOAD_SEATS_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'TOGGLE_SEAT': {
      const seatId = action.payload;
      const isSelected = state.selectedSeatIds.includes(seatId);

      return {
        ...state,
        selectedSeatIds: isSelected
          ? state.selectedSeatIds.filter((id) => id !== seatId)
          : [...state.selectedSeatIds, seatId],
      };
    }

    case 'CLEAR_SELECTED_SEATS':
      return { ...state, selectedSeatIds: [] };

    default:
      return state;
  }
}

const SeatContext = createContext<SeatContextValue | null>(null);

export function SeatProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(seatReducer, initialState);

  const loadSeats = useCallback(async (concertId: string, maxSeatsPerBooking?: number) => {
    dispatch({ type: 'LOAD_SEATS_REQUEST' });
    try {
      const seats = await seatRepository.fetchByConcertId(concertId);
      dispatch({
        type: 'LOAD_SEATS_SUCCESS',
        payload: {
          seats,
          maxSeatsPerBooking: maxSeatsPerBooking ?? BOOKING_CONSTRAINTS.MAX_SEATS_PER_BOOKING,
        },
      });
    } catch (error) {
      dispatch({
        type: 'LOAD_SEATS_FAILURE',
        payload: error instanceof Error ? error.message : 'Failed to load seats',
      });
    }
  }, []);

  const toggleSeat = useCallback(
    (seatId: string) => {
      const isSelected = state.selectedSeatIds.includes(seatId);

      if (!isSelected) {
        if (state.selectedSeatIds.length >= state.maxSeatsPerBooking) {
          throw new Error(`최대 ${state.maxSeatsPerBooking}개까지만 선택할 수 있습니다`);
        }

        const seat = state.seats.find((s) => s.id === seatId);
        if (!seat || seat.is_booked) {
          throw new Error('이미 예약된 좌석입니다');
        }
      }

      dispatch({ type: 'TOGGLE_SEAT', payload: seatId });
    },
    [state.seats, state.selectedSeatIds, state.maxSeatsPerBooking]
  );

  const clearSelectedSeats = useCallback(() => {
    dispatch({ type: 'CLEAR_SELECTED_SEATS' });
  }, []);

  const selectedSeats = useMemo(
    () => state.seats.filter((seat) => state.selectedSeatIds.includes(seat.id)),
    [state.seats, state.selectedSeatIds]
  );

  const totalAmount = useMemo(
    () => selectedSeats.reduce((sum, seat) => sum + seat.price, 0),
    [selectedSeats]
  );

  const availableSeats = useMemo(
    () => state.seats.filter((seat) => !seat.is_booked),
    [state.seats]
  );

  const canSelectMore = useMemo(
    () => state.selectedSeatIds.length < state.maxSeatsPerBooking,
    [state.selectedSeatIds, state.maxSeatsPerBooking]
  );

  const value: SeatContextValue = {
    seats: state.seats,
    selectedSeatIds: state.selectedSeatIds,
    loading: state.loading,
    error: state.error,
    loadSeats,
    toggleSeat,
    clearSelectedSeats,
    selectedSeats,
    totalAmount,
    availableSeats,
    canSelectMore,
    maxSeatsPerBooking: state.maxSeatsPerBooking,
  };

  return <SeatContext.Provider value={value}>{children}</SeatContext.Provider>;
}

export function useSeat() {
  const context = useContext(SeatContext);
  if (!context) {
    throw new Error('useSeat must be used within SeatProvider');
  }
  return context;
}
