import { Seat } from '@/types';

interface SeatButtonProps {
  seat: Seat;
  isSelected: boolean;
  onToggle: (seat: Seat) => void;
}

export default function SeatButton({ seat, isSelected, onToggle }: SeatButtonProps) {
  const getButtonStyle = () => {
    if (seat.is_booked) {
      return 'bg-red-500 cursor-not-allowed';
    }
    if (isSelected) {
      return 'bg-yellow-500 hover:bg-yellow-600';
    }
    return 'bg-green-500 hover:bg-green-600';
  };

  const handleClick = () => {
    if (!seat.is_booked) {
      onToggle(seat);
    }
  };

  return (
    <button
      onClick={handleClick}
      disabled={seat.is_booked}
      className={`
        w-10 h-10 rounded text-white text-xs font-medium
        transition-colors duration-200
        ${getButtonStyle()}
      `}
      title={`${seat.row}행 ${seat.number}번 - ${seat.grade}석`}
    >
      {seat.row}-{seat.number}
    </button>
  );
}
