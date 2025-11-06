/**
 * @SPEC:STATE-004 Admin State Management Store
 * Manages admin authentication and dashboard state using Zustand
 */
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface AdminUser {
  adminId: string;
  lastLogin: Date;
  isActive: boolean;
}

interface AdminState {
  // Authentication state
  isAuthenticated: boolean;
  currentAdmin: AdminUser | null;
  authToken: string | null;

  // Dashboard state
  dashboardData: {
    totalRooms: number;
    activeBookings: number;
    todaysBookings: number;
    utilizationRate: number;
  } | null;

  // Admin actions state
  isPerformingAction: boolean;
  lastAction: string | null;

  // Settings
  settings: {
    autoRefreshInterval: number; // in seconds
    showSystemNotifications: boolean;
    defaultView: 'dashboard' | 'bookings' | 'rooms';
  };

  // Actions
  login: (admin: AdminUser, token: string) => void;
  logout: () => void;
  setDashboardData: (data: AdminState['dashboardData']) => void;
  setPerformingAction: (isPerforming: boolean, action?: string) => void;
  updateSettings: (settings: Partial<AdminState['settings']>) => void;
  reset: () => void;
}

const initialState = {
  isAuthenticated: false,
  currentAdmin: null,
  authToken: null,
  dashboardData: null,
  isPerformingAction: false,
  lastAction: null,
  settings: {
    autoRefreshInterval: 30,
    showSystemNotifications: true,
    defaultView: 'dashboard' as const,
  },
};

export const useAdminStore = create<AdminState>()(
  devtools(
    (set, get) => ({
      ...initialState,

      login: (admin: AdminUser, token: string) =>
        set(
          {
            isAuthenticated: true,
            currentAdmin: admin,
            authToken: token,
          },
          false,
          'admin/login'
        ),

      logout: () =>
        set(
          {
            isAuthenticated: false,
            currentAdmin: null,
            authToken: null,
            dashboardData: null,
            isPerformingAction: false,
            lastAction: null,
          },
          false,
          'admin/logout'
        ),

      setDashboardData: (dashboardData: AdminState['dashboardData']) =>
        set(
          { dashboardData },
          false,
          'admin/setDashboardData'
        ),

      setPerformingAction: (isPerformingAction: boolean, action?: string) =>
        set(
          {
            isPerformingAction,
            lastAction: action || null,
          },
          false,
          'admin/setPerformingAction'
        ),

      updateSettings: (newSettings: Partial<AdminState['settings']>) =>
        set(
          (state) => ({
            settings: {
              ...state.settings,
              ...newSettings,
            },
          }),
          false,
          'admin/updateSettings'
        ),

      reset: () =>
        set(initialState, false, 'admin/reset'),
    }),
    {
      name: 'admin-store',
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);

// Selectors for common admin state combinations
export const useAdminAuth = () => {
  const { isAuthenticated, currentAdmin, authToken } = useAdminStore();
  return { isAuthenticated, currentAdmin, authToken };
};

export const useAdminDashboard = () => {
  const { dashboardData, isPerformingAction, lastAction } = useAdminStore();
  return { dashboardData, isPerformingAction, lastAction };
};