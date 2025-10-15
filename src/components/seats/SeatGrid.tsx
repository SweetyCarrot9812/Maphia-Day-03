import { Seat } from '@/types';
import SeatButton from './SeatButton';

interface SeatGridProps {
  seats: Seat[];
  selectedSeats: Seat[];
  onToggleSeat: (seat: Seat) => void;
}

export default function SeatGrid({ seats, selectedSeats, onToggleSeat }: SeatGridProps) {
  const ROWS = 15;
  const COLS = 10;

  const getSeatByPosition = (row: number, col: number): Seat | undefined => {
    return seats.find((seat) => seat.row === row && seat.number === col);
  };

  const isSeatSelected = (seat: Seat): boolean => {
    return selectedSeats.some((s) => s.id === seat.id);
  };

  return (
    <div className="flex flex-col items-center gap-6 p-4">
      {/* Stage */}
      <div className="w-full max-w-2xl bg-gray-800 text-white text-center py-3 rounded-lg shadow-lg">
        <span className="text-lg font-bold tracking-wider">STAGE</span>
      </div>

      {/* Seat Grid */}
      <div className="flex flex-col gap-2">
        {Array.from({ length: ROWS }, (_, rowIndex) => {
          const rowNumber = rowIndex + 1;
          return (
            <div key={rowNumber} className="flex items-center gap-2">
              {/* Row Number */}
              <div className="w-8 text-center font-semibold text-gray-700">
                {rowNumber}
              </div>

              {/* Seats in Row */}
              <div className="flex gap-1">
                {Array.from({ length: COLS }, (_, colIndex) => {
                  const seatNumber = colIndex + 1;
                  const seat = getSeatByPosition(rowNumber, seatNumber);

                  if (!seat) {
                    return (
                      <div
                        key={`${rowNumber}-${seatNumber}`}
                        className="w-10 h-10"
                      />
                    );
                  }

                  return (
                    <SeatButton
                      key={seat.id}
                      seat={seat}
                      isSelected={isSeatSelected(seat)}
                      onToggle={onToggleSeat}
                    />
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
