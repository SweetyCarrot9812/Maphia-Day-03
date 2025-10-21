// Application Constants

// Subscription Plans
export const PLAN_NAMES = {
  FREE: 'free',
  BASIC: 'basic',
  PREMIUM: 'premium',
  ENTERPRISE: 'enterprise',
} as const

export type PlanName = (typeof PLAN_NAMES)[keyof typeof PLAN_NAMES]

// Project Codes
export const PROJECT_CODES = {
  CARELIT: 'carelit',
  TEMFLOW: 'temflow',
  ARISPER: 'arisper',
} as const

export type ProjectCode = (typeof PROJECT_CODES)[keyof typeof PROJECT_CODES]

// Project Configuration
export const PROJECTS = [
  {
    code: PROJECT_CODES.CARELIT,
    name: 'Care-Lit',
    description: '간호사 국가고시 학습 플랫폼',
    url: process.env.NEXT_PUBLIC_CARELIT_URL || 'https://care-lit.vercel.app',
  },
  {
    code: PROJECT_CODES.TEMFLOW,
    name: 'Tem-Flow',
    description: '템플릿 워크플로우 관리',
    url: process.env.NEXT_PUBLIC_TEMFLOW_URL || 'https://tem-flow.vercel.app',
  },
  {
    code: PROJECT_CODES.ARISPER,
    name: 'Arisper',
    description: '아리스퍼 프로젝트',
    url: process.env.NEXT_PUBLIC_ARISPER_URL || 'https://arisper.vercel.app',
  },
] as const

// Access Levels
export const ACCESS_LEVELS = {
  VIEW: 'view',
  FULL: 'full',
  ADMIN: 'admin',
} as const

export type AccessLevel = (typeof ACCESS_LEVELS)[keyof typeof ACCESS_LEVELS]

// Subscription Status
export const SUBSCRIPTION_STATUS = {
  ACTIVE: 'active',
  EXPIRED: 'expired',
  CANCELLED: 'cancelled',
} as const

export type SubscriptionStatus =
  (typeof SUBSCRIPTION_STATUS)[keyof typeof SUBSCRIPTION_STATUS]

// Error Categories
export const ERROR_CATEGORIES = {
  NETWORK: 'network',
  VALIDATION: 'validation',
  AUTH: 'auth',
  PERMISSION: 'permission',
  UNKNOWN: 'unknown',
} as const

export type ErrorCategory = (typeof ERROR_CATEGORIES)[keyof typeof ERROR_CATEGORIES]

// Cache Configuration
export const CACHE_CONFIG = {
  PROJECT_ACCESS_TTL: 5 * 60 * 1000, // 5 minutes
  USER_PROFILE_TTL: 30 * 60 * 1000, // 30 minutes
} as const

// API Endpoints (if needed)
export const API_ENDPOINTS = {
  AUTH: '/api/auth',
  PROJECTS: '/api/projects',
  SUBSCRIPTION: '/api/subscription',
} as const
