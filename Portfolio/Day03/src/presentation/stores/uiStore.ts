/**
 * @SPEC:STATE-002 UI State Management Store
 * Manages global UI state using Zustand
 */
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface UIState {
  // Loading states
  isLoading: boolean;
  loadingMessage: string;

  // Modal states
  isModalOpen: boolean;
  modalType: 'booking' | 'confirmation' | 'error' | null;
  modalData: Record<string, unknown> | null;

  // Toast notifications
  toast: {
    isVisible: boolean;
    message: string;
    type: 'success' | 'error' | 'info' | 'warning';
  };

  // Mobile responsive
  isMobileMenuOpen: boolean;
  screenSize: 'mobile' | 'tablet' | 'desktop';

  // Actions
  setLoading: (isLoading: boolean, message?: string) => void;
  openModal: (type: UIState['modalType'], data?: Record<string, unknown>) => void;
  closeModal: () => void;
  showToast: (message: string, type: UIState['toast']['type']) => void;
  hideToast: () => void;
  toggleMobileMenu: () => void;
  setScreenSize: (size: UIState['screenSize']) => void;
  reset: () => void;
}

const initialState = {
  isLoading: false,
  loadingMessage: '',
  isModalOpen: false,
  modalType: null,
  modalData: null,
  toast: {
    isVisible: false,
    message: '',
    type: 'info' as const,
  },
  isMobileMenuOpen: false,
  screenSize: 'desktop' as const,
};

export const useUIStore = create<UIState>()(
  devtools(
    (set, get) => ({
      ...initialState,

      setLoading: (isLoading: boolean, message = '') =>
        set(
          { isLoading, loadingMessage: message },
          false,
          'ui/setLoading'
        ),

      openModal: (type: UIState['modalType'], data = null) =>
        set(
          {
            isModalOpen: true,
            modalType: type,
            modalData: data,
          },
          false,
          'ui/openModal'
        ),

      closeModal: () =>
        set(
          {
            isModalOpen: false,
            modalType: null,
            modalData: null,
          },
          false,
          'ui/closeModal'
        ),

      showToast: (message: string, type: UIState['toast']['type']) =>
        set(
          {
            toast: {
              isVisible: true,
              message,
              type,
            },
          },
          false,
          'ui/showToast'
        ),

      hideToast: () =>
        set(
          {
            toast: {
              isVisible: false,
              message: '',
              type: 'info',
            },
          },
          false,
          'ui/hideToast'
        ),

      toggleMobileMenu: () =>
        set(
          (state) => ({ isMobileMenuOpen: !state.isMobileMenuOpen }),
          false,
          'ui/toggleMobileMenu'
        ),

      setScreenSize: (screenSize: UIState['screenSize']) =>
        set({ screenSize }, false, 'ui/setScreenSize'),

      reset: () =>
        set(initialState, false, 'ui/reset'),
    }),
    {
      name: 'ui-store',
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);