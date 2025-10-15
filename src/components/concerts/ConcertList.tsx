import { Concert } from '@/types';
import ConcertCard from './ConcertCard';

interface ConcertListProps {
  concerts: Concert[];
  onConcertClick: (concert: Concert) => void;
}

export default function ConcertList({ concerts, onConcertClick }: ConcertListProps) {
  if (concerts.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 text-gray-500">
        <p className="text-lg">등록된 공연이 없습니다.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
      {concerts.map((concert) => (
        <ConcertCard
          key={concert.id}
          concert={concert}
          onClick={onConcertClick}
        />
      ))}
    </div>
  );
}
