import Image from 'next/image';
import { Concert } from '@/types';
import { formatDate } from '@/lib/utils/format';

interface ConcertCardProps {
  concert: Concert;
  onClick: (concert: Concert) => void;
}

export default function ConcertCard({ concert, onClick }: ConcertCardProps) {
  return (
    <div
      onClick={() => onClick(concert)}
      className="cursor-pointer group overflow-hidden rounded-lg border border-gray-200 bg-white shadow-sm transition-all hover:shadow-md hover:border-gray-300"
    >
      <div className="relative aspect-[3/4] w-full overflow-hidden bg-gray-100">
        {concert.image_url ? (
          <Image
            src={concert.image_url}
            alt={concert.title}
            fill
            className="object-cover transition-transform duration-300 group-hover:scale-105"
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-gray-200">
            <span className="text-gray-400 text-sm">No Image</span>
          </div>
        )}
      </div>

      <div className="p-4 space-y-2">
        <h3 className="text-lg font-bold text-gray-900 line-clamp-1 group-hover:text-blue-600 transition-colors">
          {concert.title}
        </h3>

        <p className="text-sm text-gray-600 font-medium">
          {concert.artist}
        </p>

        <div className="space-y-1 text-sm text-gray-500">
          <p className="flex items-center gap-1">
            <span className="font-medium">📅</span>
            {formatDate(concert.date)}
          </p>
          <p className="flex items-center gap-1">
            <span className="font-medium">📍</span>
            {concert.venue}
          </p>
        </div>
      </div>
    </div>
  );
}
