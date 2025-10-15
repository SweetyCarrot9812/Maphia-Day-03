export type ErrorSeverity = 'info' | 'warning' | 'error';

export class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public severity: ErrorSeverity = 'error'
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super('VALIDATION_ERROR', message, 'warning');
    this.name = 'ValidationError';
  }
}

export class NetworkError extends AppError {
  constructor(message: string) {
    super('NETWORK_ERROR', message, 'error');
    this.name = 'NetworkError';
  }
}

export class BookingError extends AppError {
  constructor(message: string, severity: ErrorSeverity = 'error') {
    super('BOOKING_ERROR', message, severity);
    this.name = 'BookingError';
  }
}

export function normalizeError(error: unknown): AppError {
  if (error instanceof AppError) {
    return error;
  }

  if (error instanceof Error) {
    return new AppError('UNKNOWN_ERROR', error.message);
  }

  return new AppError('UNKNOWN_ERROR', String(error));
}
