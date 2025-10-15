import { Seat, SeatLayout } from '@/types';
import SeatButton from './SeatButton';
import { GRID_SIZE, SEAT_LAYOUT } from '@/constants/ui';

interface SeatGridProps {
  seats: Seat[];
  selectedSeats: Seat[];
  onToggleSeat: (seat: Seat) => void;
  layout?: SeatLayout;
}

export default function SeatGrid({ seats, selectedSeats, onToggleSeat, layout }: SeatGridProps) {
  const ROWS = layout?.rows ?? GRID_SIZE.DEFAULT_ROWS;
  const COLS = layout?.columns ?? GRID_SIZE.DEFAULT_COLS;

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
      <div className={`flex flex-col ${SEAT_LAYOUT.ROW_GAP}`}>
        {Array.from({ length: ROWS }, (_, rowIndex) => {
          const rowNumber = rowIndex + 1;
          return (
            <div key={rowNumber} className={`flex items-center ${SEAT_LAYOUT.SEAT_GAP}`}>
              {/* Row Number */}
              <div className={`${SEAT_LAYOUT.ROW_NUMBER_WIDTH} text-center font-semibold text-gray-700`}>
                {rowNumber}
              </div>

              {/* Seats in Row */}
              <div className={`flex ${SEAT_LAYOUT.SEAT_GAP}`}>
                {Array.from({ length: COLS }, (_, colIndex) => {
                  const seatNumber = colIndex + 1;
                  const seat = getSeatByPosition(rowNumber, seatNumber);

                  if (!seat) {
                    return (
                      <div
                        key={`${rowNumber}-${seatNumber}`}
                        className={`${SEAT_LAYOUT.SEAT_SIZE.WIDTH} ${SEAT_LAYOUT.SEAT_SIZE.HEIGHT}`}
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
