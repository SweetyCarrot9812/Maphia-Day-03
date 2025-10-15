export interface Booking {
  id: string;
  booking_number: string;
  concert_id: string;
  seat_ids: string[];
  customer_name: string;
  customer_phone: string;
  customer_email: string;
  customer_birthdate: string | null;
  total_amount: number;
  status: 'confirmed' | 'cancelled';
  created_at: string;
  updated_at: string;
}

export interface BookingFormData {
  name: string;
  phone: string;
  email: string;
  birthdate?: string;
}

export interface BookingWithConcert extends Booking {
  concert?: {
    title: string;
    date: string;
    venue: string;
    image_url: string | null;
  };
  seats?: Array<{
    row: number;
    number: number;
    grade: string;
  }>;
}
