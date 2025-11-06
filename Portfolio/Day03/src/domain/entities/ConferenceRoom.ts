/**
 * @SPEC:ENT-001 Conference Room Entity
 * Represents a conference room with its properties and business rules
 */
export interface ConferenceRoomProps {
  id: string;
  name: string;
  capacity: number;
  amenities: string[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export class ConferenceRoom {
  private props: ConferenceRoomProps;

  constructor(props: ConferenceRoomProps) {
    this.validateProps(props);
    this.props = props;
  }

  private validateProps(props: ConferenceRoomProps): void {
    if (!props.name || props.name.trim().length === 0) {
      throw new Error('Conference room name is required');
    }

    if (props.capacity <= 0) {
      throw new Error('Conference room capacity must be greater than 0');
    }

    if (props.capacity > 100) {
      throw new Error('Conference room capacity cannot exceed 100');
    }
  }

  // Getters
  get id(): string {
    return this.props.id;
  }

  get name(): string {
    return this.props.name;
  }

  get capacity(): number {
    return this.props.capacity;
  }

  get amenities(): string[] {
    return [...this.props.amenities];
  }

  get isActive(): boolean {
    return this.props.isActive;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get updatedAt(): Date {
    return this.props.updatedAt;
  }

  // Business methods
  activate(): void {
    this.props.isActive = true;
    this.props.updatedAt = new Date();
  }

  deactivate(): void {
    this.props.isActive = false;
    this.props.updatedAt = new Date();
  }

  updateCapacity(newCapacity: number): void {
    if (newCapacity <= 0 || newCapacity > 100) {
      throw new Error('Invalid capacity: must be between 1 and 100');
    }

    this.props.capacity = newCapacity;
    this.props.updatedAt = new Date();
  }

  addAmenity(amenity: string): void {
    if (!this.props.amenities.includes(amenity)) {
      this.props.amenities.push(amenity);
      this.props.updatedAt = new Date();
    }
  }

  removeAmenity(amenity: string): void {
    const index = this.props.amenities.indexOf(amenity);
    if (index > -1) {
      this.props.amenities.splice(index, 1);
      this.props.updatedAt = new Date();
    }
  }

  toPlainObject(): ConferenceRoomProps {
    return {
      ...this.props,
      amenities: [...this.props.amenities],
    };
  }
}