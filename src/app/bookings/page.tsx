'use client';

import { useEffect, useState, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useBooking } from '@/contexts/BookingContext';
import BookingList from '@/components/booking/BookingList';
import Loading from '@/components/common/Loading';
import ErrorMessage from '@/components/common/ErrorMessage';

type FilterType = 'all' | 'upcoming' | 'past' | 'cancelled';

export default function BookingsPage() {
  const router = useRouter();
  const { bookings, loading, error, loadBookings } = useBooking();
  const [filter, setFilter] = useState<FilterType>('all');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    loadBookings();
  }, [loadBookings]);

  // 필터링된 예약 목록
  const filteredBookings = useMemo(() => {
    let result = bookings;

    // 상태별 필터
    if (filter === 'upcoming') {
      result = result.filter(
        (booking) =>
          booking.status === 'confirmed' &&
          booking.concert &&
          new Date(booking.concert.date) > new Date()
      );
    } else if (filter === 'past') {
      result = result.filter(
        (booking) =>
          booking.status === 'confirmed' &&
          booking.concert &&
          new Date(booking.concert.date) <= new Date()
      );
    } else if (filter === 'cancelled') {
      result = result.filter((booking) => booking.status === 'cancelled');
    }

    // 검색어 필터
    if (searchTerm) {
      result = result.filter(
        (booking) =>
          booking.booking_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
          booking.concert?.title.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    return result;
  }, [bookings, filter, searchTerm]);

  if (loading) return <Loading />;
  if (error) return <ErrorMessage message={error} />;

  const handleGoHome = () => {
    router.push('/');
  };

  const filterButtons = [
    { value: 'all' as FilterType, label: '전체', count: bookings.length },
    {
      value: 'upcoming' as FilterType,
      label: '예정',
      count: bookings.filter(
        (b) =>
          b.status === 'confirmed' && b.concert && new Date(b.concert.date) > new Date()
      ).length,
    },
    {
      value: 'past' as FilterType,
      label: '지난 예약',
      count: bookings.filter(
        (b) =>
          b.status === 'confirmed' && b.concert && new Date(b.concert.date) <= new Date()
      ).length,
    },
    {
      value: 'cancelled' as FilterType,
      label: '취소됨',
      count: bookings.filter((b) => b.status === 'cancelled').length,
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:justify-between md:items-center gap-4">
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

      {/* 검색 및 필터 */}
      {bookings.length > 0 && (
        <div className="space-y-4">
          {/* 검색창 */}
          <div className="relative">
            <input
              type="text"
              placeholder="예약 번호 또는 콘서트 이름으로 검색..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full px-4 py-3 pl-12 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <div className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400">
              🔍
            </div>
          </div>

          {/* 필터 버튼 */}
          <div className="flex flex-wrap gap-2">
            {filterButtons.map((btn) => (
              <button
                key={btn.value}
                onClick={() => setFilter(btn.value)}
                className={`px-4 py-2 rounded-lg font-semibold transition ${
                  filter === btn.value
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {btn.label} <span className="text-sm">({btn.count})</span>
              </button>
            ))}
          </div>
        </div>
      )}

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
      ) : filteredBookings.length === 0 ? (
        <div className="bg-white rounded-lg shadow-lg p-12">
          <div className="text-center space-y-4">
            <div className="text-4xl mb-4">🔍</div>
            <h3 className="text-xl font-semibold text-gray-700">
              {searchTerm ? '검색 결과가 없습니다' : '해당 조건의 예약이 없습니다'}
            </h3>
            <p className="text-gray-500">다른 필터나 검색어를 시도해보세요.</p>
          </div>
        </div>
      ) : (
        <BookingList bookings={filteredBookings} />
      )}
    </div>
  );
}
