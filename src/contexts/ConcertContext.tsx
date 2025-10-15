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
import { Concert } from '@/types';
import { concertRepository } from '@/lib/repositories/concertRepository';

interface ConcertState {
  concerts: Concert[];
  selectedConcert: Concert | null;
  loading: boolean;
  error: string | null;
}

type ConcertAction =
  | { type: 'LOAD_CONCERTS_REQUEST' }
  | { type: 'LOAD_CONCERTS_SUCCESS'; payload: Concert[] }
  | { type: 'LOAD_CONCERTS_FAILURE'; payload: string }
  | { type: 'SELECT_CONCERT'; payload: Concert }
  | { type: 'CLEAR_SELECTED_CONCERT' };

interface ConcertContextValue {
  concerts: Concert[];
  selectedConcert: Concert | null;
  loading: boolean;
  error: string | null;
  loadConcerts: () => Promise<void>;
  selectConcert: (concert: Concert) => void;
  clearSelectedConcert: () => void;
  availableConcerts: Concert[];
  upcomingConcerts: Concert[];
}

const initialState: ConcertState = {
  concerts: [],
  selectedConcert: null,
  loading: false,
  error: null,
};

function concertReducer(state: ConcertState, action: ConcertAction): ConcertState {
  switch (action.type) {
    case 'LOAD_CONCERTS_REQUEST':
      return { ...state, loading: true, error: null };

    case 'LOAD_CONCERTS_SUCCESS':
      return { ...state, concerts: action.payload, loading: false };

    case 'LOAD_CONCERTS_FAILURE':
      return { ...state, error: action.payload, loading: false };

    case 'SELECT_CONCERT':
      return { ...state, selectedConcert: action.payload };

    case 'CLEAR_SELECTED_CONCERT':
      return { ...state, selectedConcert: null };

    default:
      return state;
  }
}

const ConcertContext = createContext<ConcertContextValue | null>(null);

export function ConcertProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(concertReducer, initialState);

  const loadConcerts = useCallback(async () => {
    dispatch({ type: 'LOAD_CONCERTS_REQUEST' });
    try {
      const concerts = await concertRepository.fetchAll();
      dispatch({ type: 'LOAD_CONCERTS_SUCCESS', payload: concerts });
    } catch (error) {
      dispatch({
        type: 'LOAD_CONCERTS_FAILURE',
        payload: error instanceof Error ? error.message : 'Failed to load concerts',
      });
    }
  }, []);

  const selectConcert = useCallback((concert: Concert) => {
    dispatch({ type: 'SELECT_CONCERT', payload: concert });
  }, []);

  const clearSelectedConcert = useCallback(() => {
    dispatch({ type: 'CLEAR_SELECTED_CONCERT' });
  }, []);

  const availableConcerts = useMemo(
    () => state.concerts.filter((concert) => new Date(concert.date) > new Date()),
    [state.concerts]
  );

  const upcomingConcerts = useMemo(
    () =>
      [...availableConcerts].sort(
        (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
      ),
    [availableConcerts]
  );

  useEffect(() => {
    loadConcerts();
  }, [loadConcerts]);

  const value: ConcertContextValue = {
    concerts: state.concerts,
    selectedConcert: state.selectedConcert,
    loading: state.loading,
    error: state.error,
    loadConcerts,
    selectConcert,
    clearSelectedConcert,
    availableConcerts,
    upcomingConcerts,
  };

  return <ConcertContext.Provider value={value}>{children}</ConcertContext.Provider>;
}

export function useConcert() {
  const context = useContext(ConcertContext);
  if (!context) {
    throw new Error('useConcert must be used within ConcertProvider');
  }
  return context;
}
