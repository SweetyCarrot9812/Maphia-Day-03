'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useBooking } from '@/contexts/BookingContext';
import { useSeat } from '@/contexts/SeatContext';
import { useConcert } from '@/contexts/ConcertContext';
import BookingForm from '@/components/booking/BookingForm';
import SeatSummary from '@/components/seats/SeatSummary';
import ErrorMessage from '@/components/common/ErrorMessage';
import { BookingFormData } from '@/types';

export default function BookingInfoPage() {
  const router = useRouter();
  const { selectedConcert } = useConcert();
  const { selectedSeats, totalAmount, clearSelectedSeats } = useSeat();
  const { createBooking, setBookingInfo, loading } = useBooking();
  const [error, setError] = useState<string | null>(null);

  if (!selectedConcert) {
    return <ErrorMessage message="선택된 콘서트가 없습니다. 다시 선택해주세요." />;
  }

  if (selectedSeats.length === 0) {
    return <ErrorMessage message="선택된 좌석이 없습니다. 좌석을 선택해주세요." />;
  }

  const handleSubmit = async (data: BookingFormData) => {
    try {
      setError(null);
      setBookingInfo(data);

      const seatIds = selectedSeats.map((seat) => seat.id);
      await createBooking(selectedConcert.id, seatIds, totalAmount);

      clearSelectedSeats();
      router.push('/booking/confirmation');
    } catch (err) {
      setError(err instanceof Error ? err.message : '예약에 실패했습니다');
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="text-center">
        <h1 className="text-3xl font-bold mb-2">예약자 정보 입력</h1>
        <p className="text-gray-600">예약을 완료하기 위해 정보를 입력해주세요</p>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <p className="text-red-600">{error}</p>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow-lg p-6">
            <h2 className="text-xl font-bold mb-4">예약 정보</h2>
            <div className="space-y-4 mb-6 pb-6 border-b border-gray-200">
              <div>
                <p className="text-sm text-gray-500 font-medium">콘서트</p>
                <p className="text-base text-gray-900 font-semibold">{selectedConcert.title}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 font-medium">아티스트</p>
                <p className="text-base text-gray-900">{selectedConcert.artist}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 font-medium">장소</p>
                <p className="text-base text-gray-900">{selectedConcert.venue}</p>
              </div>
            </div>

            <h2 className="text-xl font-bold mb-4">예약자 정보</h2>
            <BookingForm onSubmit={handleSubmit} loading={loading} />
          </div>
        </div>

        <div>
          <SeatSummary selectedSeats={selectedSeats} />
        </div>
      </div>
    </div>
  );
}
