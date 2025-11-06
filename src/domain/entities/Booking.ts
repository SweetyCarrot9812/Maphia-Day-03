import { PhoneNumber } from '../value-objects/PhoneNumber';

/**
 * @SPEC:ENT-002 Booking Entity
 * Represents a conference room booking with business rules
 */
export interface BookingProps {
  id: string;
  roomId: string;
  userName: string;
  userPhone: PhoneNumber;
  purpose: string;
  startTime: Date;
  endTime: Date;
  status: 'confirmed' | 'cancelled';
  createdAt: Date;
  updatedAt: Date;
}

export class Booking {
  private props: BookingProps;

  constructor(props: BookingProps) {
    this.validateProps(props);
    this.props = props;
  }

  private validateProps(props: BookingProps): void {
    if (!props.userName || props.userName.trim().length === 0) {
      throw new Error('User name is required');
    }

    if (!props.purpose || props.purpose.trim().length === 0) {
      throw new Error('Booking purpose is required');
    }

    if (props.startTime >= props.endTime) {
      throw new Error('Start time must be before end time');
    }

    if (props.startTime < new Date()) {
      throw new Error('Cannot book in the past');
    }

    const durationHours = (props.endTime.getTime() - props.startTime.getTime()) / (1000 * 60 * 60);
    if (durationHours > 8) {
      throw new Error('Booking cannot exceed 8 hours');
    }

    if (durationHours < 0.5) {
      throw new Error('Minimum booking duration is 30 minutes');
    }
  }

  // Getters
  get id(): string {
    return this.props.id;
  }

  get roomId(): string {
    return this.props.roomId;
  }

  get userName(): string {
    return this.props.userName;
  }

  get userPhone(): PhoneNumber {
    return this.props.userPhone;
  }

  get purpose(): string {
    return this.props.purpose;
  }

  get startTime(): Date {
    return this.props.startTime;
  }

  get endTime(): Date {
    return this.props.endTime;
  }

  get status(): 'confirmed' | 'cancelled' {
    return this.props.status;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get updatedAt(): Date {
    return this.props.updatedAt;
  }

  // Business methods
  cancel(): void {
    if (this.props.status === 'cancelled') {
      throw new Error('Booking is already cancelled');
    }

    if (this.props.startTime < new Date()) {
      throw new Error('Cannot cancel past bookings');
    }

    this.props.status = 'cancelled';
    this.props.updatedAt = new Date();
  }

  getDurationInHours(): number {
    return (this.props.endTime.getTime() - this.props.startTime.getTime()) / (1000 * 60 * 60);
  }

  isActive(): boolean {
    const now = new Date();
    return this.props.status === 'confirmed' &&
           this.props.startTime <= now &&
           this.props.endTime > now;
  }

  isUpcoming(): boolean {
    return this.props.status === 'confirmed' && this.props.startTime > new Date();
  }

  toPlainObject(): Omit<BookingProps, 'userPhone'> & { userPhone: string } {
    return {
      ...this.props,
      userPhone: this.props.userPhone.getValue(),
    };
  }
}