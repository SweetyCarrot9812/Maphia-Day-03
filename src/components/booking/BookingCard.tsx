import { useState } from 'react';
import { BookingWithConcert } from '@/types';
import { formatDate, formatCurrency } from '@/lib/utils/format';
import { useBooking } from '@/contexts/BookingContext';
import { QRCodeSVG } from 'qrcode.react';

interface BookingCardProps {
  booking: BookingWithConcert;
}

export default function BookingCard({ booking }: BookingCardProps) {
  const { cancelBooking } = useBooking();
  const [showModal, setShowModal] = useState(false);
  const [showCancelConfirm, setShowCancelConfirm] = useState(false);
  const [canceling, setCanceling] = useState(false);

  const statusColor =
    booking.status === 'confirmed' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
  const statusText = booking.status === 'confirmed' ? '예약 확정' : '예약 취소';

  const isCancelable =
    booking.status === 'confirmed' &&
    booking.concert &&
    new Date(booking.concert.date) > new Date();

  const handleCancel = async () => {
    if (!cancelBooking) return;

    setCanceling(true);
    try {
      await cancelBooking(booking.id);
      alert('예약이 취소되었습니다.');
      setShowCancelConfirm(false);
    } catch (error) {
      alert(error instanceof Error ? error.message : '예약 취소에 실패했습니다');
    } finally {
      setCanceling(false);
    }
  };

  const qrData = JSON.stringify({
    bookingNumber: booking.booking_number,
    concertTitle: booking.concert?.title,
    date: booking.concert?.date,
  });

  return (
    <>
      <div className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition border-l-4 border-blue-500">
      <div className="flex justify-between items-start mb-4">
        <div>
          <p className="text-sm text-gray-500 mb-1">예약번호</p>
          <p className="font-mono font-semibold text-lg">{booking.booking_number}</p>
        </div>
        <span className={`px-3 py-1 rounded-full text-sm font-medium ${statusColor}`}>
          {statusText}
        </span>
      </div>

      {booking.concert && (
        <div className="mb-4 pb-4 border-b border-gray-200">
          <h3 className="font-bold text-xl mb-2">{booking.concert.title}</h3>
          <div className="space-y-1 text-gray-600">
            <p className="flex items-center">
              <span className="text-gray-400 mr-2">📅</span>
              {formatDate(booking.concert.date)}
            </p>
            <p className="flex items-center">
              <span className="text-gray-400 mr-2">📍</span>
              {booking.concert.venue}
            </p>
          </div>
        </div>
      )}

      <div className="mb-4">
        <p className="text-sm text-gray-500 mb-2">예약 좌석</p>
        <div className="flex flex-wrap gap-2">
          {booking.seats && booking.seats.length > 0 ? (
            booking.seats.map((seat, index) => (
              <span
                key={index}
                className="px-3 py-1 bg-blue-50 text-blue-700 rounded-md text-sm font-medium"
              >
                {seat.row}행 {seat.number}번 ({seat.grade}석)
              </span>
            ))
          ) : (
            <span className="text-gray-500 text-sm">좌석 정보를 불러오는 중...</span>
          )}
        </div>
      </div>

      <div className="pt-4 border-t border-gray-200">
        <div className="flex justify-between items-center">
          <span className="text-gray-600 font-medium">총 결제금액</span>
          <span className="text-2xl font-bold text-blue-600">
            {formatCurrency(booking.total_amount)}
          </span>
        </div>
      </div>

      <div className="mt-4 pt-4 border-t border-gray-200 text-sm text-gray-500">
        <div className="flex justify-between mb-4">
          <span>예약자: {booking.customer_name}</span>
          <span>{new Date(booking.created_at).toLocaleDateString('ko-KR')}</span>
        </div>

        {/* 액션 버튼 */}
        <div className="flex gap-2">
          <button
            onClick={() => setShowModal(true)}
            className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-lg font-semibold hover:bg-blue-700 transition"
          >
            상세보기
          </button>
          {isCancelable && (
            <button
              onClick={() => setShowCancelConfirm(true)}
              className="flex-1 bg-red-600 text-white py-2 px-4 rounded-lg font-semibold hover:bg-red-700 transition"
            >
              예약취소
            </button>
          )}
        </div>
      </div>
    </div>

      {/* 상세 모달 */}
      {showModal && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
          onClick={() => setShowModal(false)}
        >
          <div
            className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="p-6 space-y-6">
              {/* 헤더 */}
              <div className="flex justify-between items-start">
                <h2 className="text-2xl font-bold">예약 상세 정보</h2>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-gray-400 hover:text-gray-600 text-2xl"
                >
                  ×
                </button>
              </div>

              {/* QR 코드 */}
              <div className="flex justify-center">
                <div className="bg-white p-4 rounded-lg shadow-md border-2 border-gray-200">
                  <QRCodeSVG value={qrData} size={200} level="H" />
                  <p className="text-xs text-gray-500 text-center mt-2">입장 시 제시</p>
                </div>
              </div>

              {/* 예약 정보 */}
              <div className="bg-gray-50 rounded-lg p-6 space-y-4">
                <div className="flex justify-between items-center pb-4 border-b border-gray-200">
                  <span className="text-sm text-gray-500 font-medium">예약 번호</span>
                  <span className="text-lg font-bold text-blue-600">
                    {booking.booking_number}
                  </span>
                </div>

                <div className="flex justify-between items-center pb-4 border-b border-gray-200">
                  <span className="text-sm text-gray-500 font-medium">상태</span>
                  <span className={`px-3 py-1 rounded-full text-sm font-medium ${statusColor}`}>
                    {statusText}
                  </span>
                </div>

                {booking.concert && (
                  <>
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-gray-500 font-medium">콘서트</span>
                      <span className="text-base text-gray-900 font-semibold">
                        {booking.concert.title}
                      </span>
                    </div>

                    <div className="flex justify-between items-center">
                      <span className="text-sm text-gray-500 font-medium">일시</span>
                      <span className="text-base text-gray-900">
                        {formatDate(booking.concert.date)}
                      </span>
                    </div>

                    <div className="flex justify-between items-center">
                      <span className="text-sm text-gray-500 font-medium">장소</span>
                      <span className="text-base text-gray-900">{booking.concert.venue}</span>
                    </div>
                  </>
                )}

                <div className="pt-4 border-t border-gray-200">
                  <span className="text-sm text-gray-500 font-medium block mb-2">예약 좌석</span>
                  <div className="flex flex-wrap gap-2">
                    {booking.seats && booking.seats.length > 0 ? (
                      booking.seats.map((seat, index) => (
                        <span
                          key={index}
                          className="px-3 py-1 bg-blue-50 text-blue-700 rounded-md text-sm font-medium"
                        >
                          {seat.row}행 {seat.number}번 ({seat.grade}석)
                        </span>
                      ))
                    ) : (
                      <span className="text-gray-500 text-sm">좌석 정보 없음</span>
                    )}
                  </div>
                </div>

                <div className="pt-4 border-t border-gray-200">
                  <span className="text-sm text-gray-500 font-medium block mb-2">예약자 정보</span>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-500">이름</span>
                      <span className="text-gray-900">{booking.customer_name}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">전화번호</span>
                      <span className="text-gray-900">{booking.customer_phone}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-500">이메일</span>
                      <span className="text-gray-900">{booking.customer_email}</span>
                    </div>
                  </div>
                </div>

                <div className="flex justify-between items-center pt-4 border-t-2 border-gray-300">
                  <span className="text-base font-bold text-gray-900">총 결제 금액</span>
                  <span className="text-xl font-bold text-blue-600">
                    {formatCurrency(booking.total_amount)}
                  </span>
                </div>
              </div>

              {/* 액션 버튼 */}
              <div className="flex gap-2">
                {isCancelable && (
                  <button
                    onClick={() => {
                      setShowModal(false);
                      setShowCancelConfirm(true);
                    }}
                    className="flex-1 bg-red-600 text-white py-3 px-6 rounded-lg font-semibold hover:bg-red-700 transition"
                  >
                    예약 취소
                  </button>
                )}
                <button
                  onClick={() => setShowModal(false)}
                  className="flex-1 bg-gray-100 text-gray-700 py-3 px-6 rounded-lg font-semibold hover:bg-gray-200 transition"
                >
                  닫기
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 취소 확인 모달 */}
      {showCancelConfirm && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
          onClick={() => !canceling && setShowCancelConfirm(false)}
        >
          <div
            className="bg-white rounded-lg max-w-md w-full p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="text-xl font-bold mb-4">예약 취소 확인</h3>
            <p className="text-gray-600 mb-6">
              정말로 예약을 취소하시겠습니까?
              <br />
              취소된 예약은 복구할 수 없습니다.
            </p>
            <div className="flex gap-2">
              <button
                onClick={handleCancel}
                disabled={canceling}
                className="flex-1 bg-red-600 text-white py-3 px-6 rounded-lg font-semibold hover:bg-red-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {canceling ? '취소 중...' : '예약 취소'}
              </button>
              <button
                onClick={() => setShowCancelConfirm(false)}
                disabled={canceling}
                className="flex-1 bg-gray-100 text-gray-700 py-3 px-6 rounded-lg font-semibold hover:bg-gray-200 transition disabled:opacity-50"
              >
                돌아가기
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
