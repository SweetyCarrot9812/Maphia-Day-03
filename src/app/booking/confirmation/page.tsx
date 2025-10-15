'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useBooking } from '@/contexts/BookingContext';
import { formatDate, formatCurrency } from '@/lib/utils/format';
import Loading from '@/components/common/Loading';
import ErrorMessage from '@/components/common/ErrorMessage';

export default function BookingConfirmationPage() {
  const router = useRouter();
  const { bookings, loading, loadBookings } = useBooking();

  useEffect(() => {
    loadBookings();
  }, [loadBookings]);

  if (loading) return <Loading />;

  const latestBooking = bookings[0];

  if (!latestBooking) {
    return <ErrorMessage message="예약 정보를 찾을 수 없습니다" />;
  }

  const handleGoToBookings = () => {
    router.push('/bookings');
  };

  const handleGoHome = () => {
    router.push('/');
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="bg-white rounded-lg shadow-lg p-8 text-center space-y-6">
        <div className="text-6xl mb-4">✅</div>

        <h1 className="text-3xl font-bold text-gray-900">예약이 완료되었습니다!</h1>

        <p className="text-gray-600">
          예약 정보를 이메일로 발송했습니다.
          <br />
          예약 번호로 언제든지 조회할 수 있습니다.
        </p>

        <div className="bg-gray-50 rounded-lg p-6 space-y-4 text-left">
          <div className="flex justify-between items-center pb-4 border-b border-gray-200">
            <span className="text-sm text-gray-500 font-medium">예약 번호</span>
            <span className="text-lg font-bold text-blue-600">{latestBooking.booking_number}</span>
          </div>

          {latestBooking.concert && (
            <>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-500 font-medium">콘서트</span>
                <span className="text-base text-gray-900 font-semibold">
                  {latestBooking.concert.title}
                </span>
              </div>

              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-500 font-medium">일시</span>
                <span className="text-base text-gray-900">
                  {formatDate(latestBooking.concert.date)}
                </span>
              </div>

              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-500 font-medium">장소</span>
                <span className="text-base text-gray-900">{latestBooking.concert.venue}</span>
              </div>
            </>
          )}

          <div className="flex justify-between items-center">
            <span className="text-sm text-gray-500 font-medium">좌석 수</span>
            <span className="text-base text-gray-900">{latestBooking.seat_ids.length}석</span>
          </div>

          <div className="flex justify-between items-center pt-4 border-t border-gray-200">
            <span className="text-base font-bold text-gray-900">총 결제 금액</span>
            <span className="text-xl font-bold text-blue-600">
              {formatCurrency(latestBooking.total_amount)}
            </span>
          </div>
        </div>

        <div className="pt-4 space-y-3">
          <button
            onClick={handleGoToBookings}
            className="w-full bg-blue-600 text-white py-4 px-6 rounded-lg font-bold text-lg hover:bg-blue-700 transition"
          >
            예약 조회
          </button>

          <button
            onClick={handleGoHome}
            className="w-full bg-gray-100 text-gray-700 py-4 px-6 rounded-lg font-bold text-lg hover:bg-gray-200 transition"
          >
            홈으로
          </button>
        </div>

        <p className="text-sm text-gray-500 pt-4">
          예약과 관련하여 문의사항이 있으시면 고객센터로 연락해주세요.
        </p>
      </div>
    </div>
  );
}
