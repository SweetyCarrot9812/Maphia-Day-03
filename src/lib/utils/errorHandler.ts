import { normalizeError } from '@/lib/errors/AppError';

interface ErrorHandlerOptions {
  context?: string;
  silent?: boolean;
  showToast?: (message: string, type: 'error' | 'warning' | 'info') => void;
}

export function handleError(error: unknown, options: ErrorHandlerOptions = {}) {
  const appError = normalizeError(error);

  // 개발 환경에서는 콘솔에 로깅
  if (process.env.NODE_ENV === 'development') {
    console.error(`[${options.context || 'Error'}]`, appError);
  }

  // 프로덕션 환경에서는 모니터링 서비스로 전송
  // TODO: Sentry 등 모니터링 도구 연동

  // Toast 표시
  if (!options.silent && options.showToast) {
    options.showToast(appError.message, appError.severity as 'error' | 'warning' | 'info');
  }

  return appError;
}

export function createErrorHandler(showToast: (message: string, type: 'error' | 'warning' | 'info') => void) {
  return (error: unknown, context?: string) => {
    return handleError(error, { context, showToast });
  };
}
