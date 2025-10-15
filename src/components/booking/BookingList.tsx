import { BookingWithConcert } from '@/types';
import BookingCard from './BookingCard';

interface BookingListProps {
  bookings: BookingWithConcert[];
}

export default function BookingList({ bookings }: BookingListProps) {
  if (bookings.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-4">🎫</div>
        <h3 className="text-xl font-semibold text-gray-700 mb-2">
          예약 내역이 없습니다
        </h3>
        <p className="text-gray-500">
          콘서트를 예약하고 첫 번째 예약을 만들어보세요!
        </p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {bookings.map((booking) => (
        <BookingCard key={booking.id} booking={booking} />
      ))}
    </div>
  );
}
