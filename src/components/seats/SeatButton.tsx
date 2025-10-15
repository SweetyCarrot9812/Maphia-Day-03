import { Seat } from '@/types';
import { useState } from 'react';

interface SeatButtonProps {
  seat: Seat;
  isSelected: boolean;
  onToggle: (seat: Seat) => void;
}

export default function SeatButton({ seat, isSelected, onToggle }: SeatButtonProps) {
  const [showTooltip, setShowTooltip] = useState(false);

  const getButtonStyle = () => {
    if (seat.is_booked) {
      return 'bg-gray-400 cursor-not-allowed opacity-50';
    }
    if (isSelected) {
      return 'bg-blue-600 hover:bg-blue-700 shadow-lg scale-110 ring-2 ring-blue-300';
    }

    // 등급별 색상
    switch (seat.grade) {
      case 'VIP':
        return 'bg-purple-500 hover:bg-purple-600 hover:shadow-md hover:scale-105';
      case 'R':
        return 'bg-pink-500 hover:bg-pink-600 hover:shadow-md hover:scale-105';
      case 'S':
        return 'bg-blue-500 hover:bg-blue-600 hover:shadow-md hover:scale-105';
      case 'A':
        return 'bg-green-500 hover:bg-green-600 hover:shadow-md hover:scale-105';
      default:
        return 'bg-gray-500 hover:bg-gray-600 hover:shadow-md hover:scale-105';
    }
  };

  const handleClick = () => {
    if (!seat.is_booked) {
      onToggle(seat);
    }
  };

  const getGradeLabel = () => {
    const gradeLabels: Record<string, string> = {
      VIP: 'VIP석',
      R: 'R석',
      S: 'S석',
      A: 'A석',
    };
    return gradeLabels[seat.grade] || `${seat.grade}석`;
  };

  return (
    <div className="relative">
      <button
        onClick={handleClick}
        disabled={seat.is_booked}
        onMouseEnter={() => setShowTooltip(true)}
        onMouseLeave={() => setShowTooltip(false)}
        className={`
          w-12 h-12 rounded-lg text-white text-xs font-bold
          transition-all duration-200
          ${getButtonStyle()}
          ${seat.is_booked ? '' : 'active:scale-95'}
        `}
        aria-label={`${seat.row}행 ${seat.number}번 - ${getGradeLabel()}`}
      >
        {seat.row}-{seat.number}
      </button>

      {/* 툴팁 */}
      {showTooltip && (
        <div className="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-3 py-2 bg-gray-900 text-white text-xs rounded-lg shadow-lg whitespace-nowrap z-10 pointer-events-none">
          <div className="font-semibold">{seat.row}행 {seat.number}번</div>
          <div className="text-gray-300">{getGradeLabel()}</div>
          <div className="font-bold text-yellow-300">{seat.price.toLocaleString()}원</div>
          {seat.is_booked && <div className="text-red-300 mt-1">예약 완료</div>}
          {/* 툴팁 화살표 */}
          <div className="absolute top-full left-1/2 transform -translate-x-1/2 -mt-1">
            <div className="border-4 border-transparent border-t-gray-900"></div>
          </div>
        </div>
      )}
    </div>
  );
}
