/**
 * @SPEC:STATE-003 Booking State Management Store
 * Manages booking-related client state using Zustand
 */
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface BookingFormData {
  roomId: string;
  userName: string;
  userPhone: string;
  purpose: string;
  startTime: Date | null;
  endTime: Date | null;
}

interface BookingState {
  // Current booking form data
  currentBooking: BookingFormData;

  // Selected time slots and room
  selectedDate: Date | null;
  selectedTimeSlots: Array<{ start: Date; end: Date }>;
  selectedRoomId: string | null;

  // Booking flow state
  currentStep: 'room-selection' | 'time-selection' | 'form-filling' | 'confirmation';
  isBookingInProgress: boolean;

  // Filter preferences
  filters: {
    capacity: number | null;
    amenities: string[];
    dateRange: {
      start: Date | null;
      end: Date | null;
    };
  };

  // Actions
  setCurrentBooking: (booking: Partial<BookingFormData>) => void;
  setSelectedDate: (date: Date | null) => void;
  setSelectedTimeSlots: (slots: Array<{ start: Date; end: Date }>) => void;
  setSelectedRoomId: (roomId: string | null) => void;
  setCurrentStep: (step: BookingState['currentStep']) => void;
  setBookingInProgress: (inProgress: boolean) => void;
  setFilters: (filters: Partial<BookingState['filters']>) => void;
  resetBookingForm: () => void;
  resetFilters: () => void;
  reset: () => void;
}

const initialBookingData: BookingFormData = {
  roomId: '',
  userName: '',
  userPhone: '',
  purpose: '',
  startTime: null,
  endTime: null,
};

const initialState = {
  currentBooking: initialBookingData,
  selectedDate: null,
  selectedTimeSlots: [],
  selectedRoomId: null,
  currentStep: 'room-selection' as const,
  isBookingInProgress: false,
  filters: {
    capacity: null,
    amenities: [],
    dateRange: {
      start: null,
      end: null,
    },
  },
};

export const useBookingStore = create<BookingState>()(
  devtools(
    persist(
      (set, get) => ({
        ...initialState,

        setCurrentBooking: (booking: Partial<BookingFormData>) =>
          set(
            (state) => ({
              currentBooking: {
                ...state.currentBooking,
                ...booking,
              },
            }),
            false,
            'booking/setCurrentBooking'
          ),

        setSelectedDate: (selectedDate: Date | null) =>
          set(
            { selectedDate },
            false,
            'booking/setSelectedDate'
          ),

        setSelectedTimeSlots: (selectedTimeSlots: Array<{ start: Date; end: Date }>) =>
          set(
            { selectedTimeSlots },
            false,
            'booking/setSelectedTimeSlots'
          ),

        setSelectedRoomId: (selectedRoomId: string | null) =>
          set(
            { selectedRoomId },
            false,
            'booking/setSelectedRoomId'
          ),

        setCurrentStep: (currentStep: BookingState['currentStep']) =>
          set(
            { currentStep },
            false,
            'booking/setCurrentStep'
          ),

        setBookingInProgress: (isBookingInProgress: boolean) =>
          set(
            { isBookingInProgress },
            false,
            'booking/setBookingInProgress'
          ),

        setFilters: (newFilters: Partial<BookingState['filters']>) =>
          set(
            (state) => ({
              filters: {
                ...state.filters,
                ...newFilters,
              },
            }),
            false,
            'booking/setFilters'
          ),

        resetBookingForm: () =>
          set(
            {
              currentBooking: initialBookingData,
              selectedDate: null,
              selectedTimeSlots: [],
              selectedRoomId: null,
              currentStep: 'room-selection',
              isBookingInProgress: false,
            },
            false,
            'booking/resetBookingForm'
          ),

        resetFilters: () =>
          set(
            {
              filters: {
                capacity: null,
                amenities: [],
                dateRange: {
                  start: null,
                  end: null,
                },
              },
            },
            false,
            'booking/resetFilters'
          ),

        reset: () =>
          set(initialState, false, 'booking/reset'),
      }),
      {
        name: 'booking-store',
        partialize: (state) => ({
          // Only persist user preferences, not sensitive booking data
          filters: state.filters,
        }),
      }
    ),
    {
      name: 'booking-store',
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);