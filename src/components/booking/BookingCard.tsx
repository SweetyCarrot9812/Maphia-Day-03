import { BookingWithConcert } from '@/types';
import { formatDate, formatCurrency } from '@/lib/utils/format';

interface BookingCardProps {
  booking: BookingWithConcert;
}

export default function BookingCard({ booking }: BookingCardProps) {
  const statusColor = booking.status === 'confirmed' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
  const statusText = booking.status === 'confirmed' ? '예약 확정' : '예약 취소';

  return (
    <div className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition">
      <div className="flex justify-between items-start mb-4">
        <div>
          <p className="text-sm text-gray-500 mb-1">예약번호</p>
          <p className="font-mono font-semibold text-lg">{booking.booking_number}</p>
        </div>
        <span className={`px-3 py-1 rounded-full text-sm font-medium ${statusColor}`}>
          {statusText}
        </span>
      </div>

      {booking.concert && (
        <div className="mb-4 pb-4 border-b border-gray-200">
          <h3 className="font-bold text-xl mb-2">{booking.concert.title}</h3>
          <div className="space-y-1 text-gray-600">
            <p className="flex items-center">
              <span className="text-gray-400 mr-2">📅</span>
              {formatDate(booking.concert.date)}
            </p>
            <p className="flex items-center">
              <span className="text-gray-400 mr-2">📍</span>
              {booking.concert.venue}
            </p>
          </div>
        </div>
      )}

      <div className="mb-4">
        <p className="text-sm text-gray-500 mb-2">예약 좌석</p>
        <div className="flex flex-wrap gap-2">
          {booking.seat_ids.map((seatId) => (
            <span
              key={seatId}
              className="px-3 py-1 bg-blue-50 text-blue-700 rounded-md text-sm font-medium"
            >
              {seatId}
            </span>
          ))}
        </div>
      </div>

      <div className="pt-4 border-t border-gray-200">
        <div className="flex justify-between items-center">
          <span className="text-gray-600 font-medium">총 결제금액</span>
          <span className="text-2xl font-bold text-blue-600">
            {formatCurrency(booking.total_amount)}
          </span>
        </div>
      </div>

      <div className="mt-4 pt-4 border-t border-gray-200 text-sm text-gray-500">
        <div className="flex justify-between">
          <span>예약자: {booking.customer_name}</span>
          <span>{new Date(booking.created_at).toLocaleDateString('ko-KR')}</span>
        </div>
      </div>
    </div>
  );
}
