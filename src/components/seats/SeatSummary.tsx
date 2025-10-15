import { Seat } from '@/types';
import { formatCurrency } from '@/lib/utils/format';

interface SeatSummaryProps {
  selectedSeats: Seat[];
}

export default function SeatSummary({ selectedSeats }: SeatSummaryProps) {
  const totalAmount = selectedSeats.reduce((sum, seat) => sum + seat.price, 0);

  if (selectedSeats.length === 0) {
    return (
      <div className="p-6 bg-gray-50 rounded-lg text-center">
        <p className="text-gray-500">선택된 좌석이 없습니다</p>
      </div>
    );
  }

  return (
    <div className="p-6 bg-white border border-gray-200 rounded-lg shadow-sm">
      <h3 className="text-lg font-bold mb-4">선택한 좌석</h3>

      <div className="space-y-2 mb-4">
        {selectedSeats.map((seat) => (
          <div
            key={seat.id}
            className="flex justify-between items-center py-2 border-b border-gray-100"
          >
            <span className="font-medium text-gray-700">
              {seat.row}행 {seat.number}번 ({seat.grade}석)
            </span>
            <span className="text-gray-900 font-semibold">
              {formatCurrency(seat.price)}
            </span>
          </div>
        ))}
      </div>

      <div className="pt-4 border-t-2 border-gray-300">
        <div className="flex justify-between items-center">
          <span className="text-lg font-bold text-gray-900">총 금액</span>
          <span className="text-xl font-bold text-blue-600">
            {formatCurrency(totalAmount)}
          </span>
        </div>
      </div>
    </div>
  );
}
