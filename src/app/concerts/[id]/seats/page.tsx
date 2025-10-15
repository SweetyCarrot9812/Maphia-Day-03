'use client';

import { use, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useSeat } from '@/contexts/SeatContext';
import { useConcert } from '@/contexts/ConcertContext';
import { Seat } from '@/types';
import SeatGrid from '@/components/seats/SeatGrid';
import SeatLegend from '@/components/seats/SeatLegend';
import SeatSummary from '@/components/seats/SeatSummary';
import Loading from '@/components/common/Loading';
import ErrorMessage from '@/components/common/ErrorMessage';

interface SeatsPageProps {
  params: Promise<{ id: string }>;
}

export default function SeatsPage({ params }: SeatsPageProps) {
  const unwrappedParams = use(params);
  const router = useRouter();
  const { selectedConcert } = useConcert();
  const { seats, selectedSeats, loading, error, loadSeats, toggleSeat } = useSeat();
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    const loadSeatsData = async () => {
      try {
        await loadSeats(unwrappedParams.id, selectedConcert?.max_seats_per_booking);
      } catch (err) {
        setLoadError(err instanceof Error ? err.message : '좌석 정보를 불러오는데 실패했습니다');
      }
    };
    loadSeatsData();
  }, [unwrappedParams.id, loadSeats, selectedConcert?.max_seats_per_booking]);

  const handleToggleSeat = (seat: Seat) => {
    try {
      toggleSeat(seat.id);
    } catch (err) {
      alert(err instanceof Error ? err.message : '좌석 선택에 실패했습니다');
    }
  };

  const handleBooking = () => {
    if (selectedSeats.length === 0) {
      alert('좌석을 선택해주세요');
      return;
    }
    router.push('/booking/info');
  };

  if (loading) return <Loading />;
  if (error || loadError) return <ErrorMessage message={error || loadError || '오류가 발생했습니다'} />;

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div className="text-center">
        <h1 className="text-3xl font-bold mb-2">좌석 선택</h1>
        {selectedConcert && (
          <p className="text-gray-600 text-lg">
            {selectedConcert.title} - {selectedConcert.artist}
          </p>
        )}
      </div>

      <SeatLegend />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow-lg p-6">
            <SeatGrid
              seats={seats}
              selectedSeats={selectedSeats}
              onToggleSeat={handleToggleSeat}
              layout={selectedConcert?.seat_layout}
            />
          </div>
        </div>

        <div className="space-y-4">
          <SeatSummary selectedSeats={selectedSeats} />

          <button
            onClick={handleBooking}
            disabled={selectedSeats.length === 0}
            className="w-full bg-blue-600 text-white py-4 px-6 rounded-lg font-bold text-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-blue-600"
          >
            예약하기
          </button>
        </div>
      </div>
    </div>
  );
}
