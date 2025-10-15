'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useBooking } from '@/contexts/BookingContext';
import BookingList from '@/components/booking/BookingList';
import Loading from '@/components/common/Loading';
import ErrorMessage from '@/components/common/ErrorMessage';

export default function BookingsPage() {
  const router = useRouter();
  const { bookings, loading, error, loadBookings } = useBooking();

  useEffect(() => {
    loadBookings();
  }, [loadBookings]);

  if (loading) return <Loading />;
  if (error) return <ErrorMessage message={error} />;

  const handleGoHome = () => {
    router.push('/');
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">내 예약 내역</h1>
        {bookings.length > 0 && (
          <button
            onClick={handleGoHome}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-blue-700 transition"
          >
            새 예약하기
          </button>
        )}
      </div>

      {bookings.length === 0 ? (
        <div className="bg-white rounded-lg shadow-lg p-12">
          <div className="text-center space-y-4">
            <div className="text-6xl mb-4">🎫</div>
            <h3 className="text-xl font-semibold text-gray-700">예약 내역이 없습니다</h3>
            <p className="text-gray-500">콘서트를 예약하고 첫 번째 예약을 만들어보세요!</p>
            <button
              onClick={handleGoHome}
              className="mt-6 bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition"
            >
              콘서트 둘러보기
            </button>
          </div>
        </div>
      ) : (
        <BookingList bookings={bookings} />
      )}
    </div>
  );
}
