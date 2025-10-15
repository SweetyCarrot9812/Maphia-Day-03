import Image from 'next/image';
import { Concert } from '@/types';
import { formatDate } from '@/lib/utils/format';

interface ConcertDetailProps {
  concert: Concert;
  onSelectSeats: () => void;
}

export default function ConcertDetail({ concert, onSelectSeats }: ConcertDetailProps) {
  return (
    <div className="bg-white rounded-lg shadow-lg overflow-hidden">
      <div className="relative aspect-[16/9] w-full bg-gray-100">
        {concert.image_url ? (
          <Image
            src={concert.image_url}
            alt={concert.title}
            fill
            className="object-cover"
            sizes="100vw"
            priority
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-gray-200">
            <span className="text-gray-400 text-lg">No Image</span>
          </div>
        )}
      </div>

      <div className="p-8 space-y-6">
        <div className="space-y-2">
          <h1 className="text-3xl font-bold text-gray-900">
            {concert.title}
          </h1>
          <p className="text-xl text-gray-600 font-medium">
            {concert.artist}
          </p>
        </div>

        <div className="border-t border-gray-200 pt-6 space-y-4">
          <div className="flex items-start gap-3">
            <span className="text-xl">📅</span>
            <div>
              <p className="text-sm text-gray-500 font-medium">공연 일시</p>
              <p className="text-base text-gray-900">{formatDate(concert.date)}</p>
            </div>
          </div>

          <div className="flex items-start gap-3">
            <span className="text-xl">📍</span>
            <div>
              <p className="text-sm text-gray-500 font-medium">공연 장소</p>
              <p className="text-base text-gray-900">{concert.venue}</p>
            </div>
          </div>

          <div className="flex items-start gap-3">
            <span className="text-xl">⏱️</span>
            <div>
              <p className="text-sm text-gray-500 font-medium">공연 시간</p>
              <p className="text-base text-gray-900">{concert.running_time}분</p>
            </div>
          </div>

          {concert.description && (
            <div className="flex items-start gap-3">
              <span className="text-xl">📝</span>
              <div className="flex-1">
                <p className="text-sm text-gray-500 font-medium">공연 안내</p>
                <p className="text-base text-gray-700 whitespace-pre-wrap mt-1">
                  {concert.description}
                </p>
              </div>
            </div>
          )}
        </div>

        <div className="border-t border-gray-200 pt-6">
          <button
            onClick={onSelectSeats}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 px-6 rounded-lg transition-colors duration-200 text-lg"
          >
            좌석 선택하기
          </button>
        </div>
      </div>
    </div>
  );
}
