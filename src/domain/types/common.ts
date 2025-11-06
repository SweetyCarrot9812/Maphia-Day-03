/**
 * @SPEC:TYPE-001 Common Types and Interfaces
 * Shared types across the domain layer
 */

// Result Pattern for error handling
export type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

// Repository interfaces
export interface Repository<T> {
  findById(id: string): Promise<Result<T>>;
  save(entity: T): Promise<Result<T>>;
  delete(id: string): Promise<Result<void>>;
}

// Query interfaces
export interface Query {
  execute<T>(): Promise<Result<T>>;
}

// Use case interface
export interface UseCase<TRequest, TResponse> {
  execute(request: TRequest): Promise<Result<TResponse>>;
}

// Domain events
export interface DomainEvent {
  eventId: string;
  eventType: string;
  aggregateId: string;
  occurredAt: Date;
  data: Record<string, unknown>;
}

// Common value objects
export interface TimeSlot {
  startTime: Date;
  endTime: Date;
}

// API Response types
export interface ApiResponse<T> {
  data: T;
  message?: string;
  timestamp: string;
}

export interface ErrorResponse {
  error: string;
  message: string;
  timestamp: string;
  details?: Record<string, unknown>;
}

// Pagination
export interface PaginationParams {
  page: number;
  limit: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}