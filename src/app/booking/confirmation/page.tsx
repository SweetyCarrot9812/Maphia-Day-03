'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useBooking } from '@/contexts/BookingContext';
import { formatDate, formatCurrency } from '@/lib/utils/format';
import Loading from '@/components/common/Loading';
import ErrorMessage from '@/components/common/ErrorMessage';
import { QRCodeSVG } from 'qrcode.react';

export default function BookingConfirmationPage() {
  const router = useRouter();
  const { bookings, loading, loadBookings } = useBooking();
  const [showAnimation, setShowAnimation] = useState(false);

  useEffect(() => {
    loadBookings();
    // 애니메이션 트리거
    setTimeout(() => setShowAnimation(true), 100);
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

  const handlePrint = () => {
    window.print();
  };

  // QR 코드 데이터 (예약 번호 + 예약 정보)
  const qrData = JSON.stringify({
    bookingNumber: latestBooking.booking_number,
    concertTitle: latestBooking.concert?.title,
    date: latestBooking.concert?.date,
  });

  return (
    <div className="max-w-2xl mx-auto">
      <div
        className={`bg-white rounded-lg shadow-lg p-8 text-center space-y-6 transition-all duration-700 ${
          showAnimation ? 'opacity-100 scale-100' : 'opacity-0 scale-95'
        }`}
      >
        {/* 성공 애니메이션 */}
        <div className="relative">
          <div
            className={`text-6xl mb-4 transition-all duration-500 ${
              showAnimation ? 'scale-100 rotate-0' : 'scale-0 rotate-180'
            }`}
          >
            ✅
          </div>
          <div
            className={`absolute inset-0 flex items-center justify-center transition-opacity duration-700 ${
              showAnimation ? 'opacity-0' : 'opacity-100'
            }`}
          >
            <div className="w-20 h-20 border-4 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
          </div>
        </div>

        <h1
          className={`text-3xl font-bold text-gray-900 transition-all duration-500 delay-200 ${
            showAnimation ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'
          }`}
        >
          예약이 완료되었습니다!
        </h1>

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

        {/* QR 코드 */}
        <div className="flex justify-center pt-4">
          <div className="bg-white p-4 rounded-lg shadow-md border-2 border-gray-200">
            <QRCodeSVG value={qrData} size={160} level="H" />
            <p className="text-xs text-gray-500 text-center mt-2">입장 시 제시</p>
          </div>
        </div>

        <div className="pt-4 space-y-3">
          <button
            onClick={handlePrint}
            className="w-full bg-green-600 text-white py-4 px-6 rounded-lg font-bold text-lg hover:bg-green-700 transition flex items-center justify-center gap-2"
          >
            🖨️ 예약 확인증 인쇄
          </button>

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

      {/* 인쇄용 스타일 */}
      <style jsx global>{`
        @media print {
          body * {
            visibility: hidden;
          }
          .max-w-2xl,
          .max-w-2xl * {
            visibility: visible;
          }
          .max-w-2xl {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
          }
          button {
            display: none !important;
          }
        }
      `}</style>
    </div>
  );
}
