'use client';

import { useState, useEffect } from 'react';

// Force dynamic rendering
export const dynamic = 'force-dynamic';
import { useParams, useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { ArrowLeft, MapPin, Users, Clock, Calendar } from 'lucide-react';
import Link from 'next/link';
import { ReservationService } from '@/lib/services/reservation-service';
import type { Room, TimeSlot, ReservationFormData } from '@/lib/types';

export default function RoomDetailPage() {
  const params = useParams();
  const router = useRouter();
  const roomId = params.id as string;
  
  const [room, setRoom] = useState<Room | null>(null);
  const [timeSlots, setTimeSlots] = useState<TimeSlot[]>([]);
  const [selectedSlot, setSelectedSlot] = useState<TimeSlot | null>(null);
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [showReservationModal, setShowReservationModal] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  
  const getReservationService = () => new ReservationService();

  useEffect(() => {
    const fetchRoom = async () => {
      try {
        const reservationService = getReservationService();
        const { data, error } = await reservationService.getRoomById(roomId);
        if (error) {
          console.error('Error fetching room:', error);
          setRoom(null);
        } else {
          setRoom(data);
          
          // 기본값으로 오늘 날짜 설정
          const today = new Date();
          const todayString = today.toISOString().split('T')[0];
          setSelectedDate(todayString);
          
          if (data) {
            const slots = await reservationService.getAvailableTimeSlots(roomId, todayString);
            setTimeSlots(slots);
          }
        }
      } catch (error) {
        console.error('Error:', error);
        setRoom(null);
      } finally {
        setLoading(false);
      }
    };

    fetchRoom();
  }, [roomId]);

  // 날짜가 변경될 때마다 시간대 업데이트
  useEffect(() => {
    const updateTimeSlots = async () => {
      if (roomId && selectedDate) {
        const reservationService = getReservationService();
        const slots = await reservationService.getAvailableTimeSlots(roomId, selectedDate);
        setTimeSlots(slots);
        setSelectedSlot(null); // 날짜 변경 시 선택된 시간 초기화
      }
    };

    updateTimeSlots();
  }, [roomId, selectedDate]);

  const handleSlotSelect = (slot: TimeSlot) => {
    if (slot.available) {
      setSelectedSlot(slot);
    }
  };

  const handleReservationSubmit = async (formData: ReservationFormData) => {
    setSubmitting(true);
    try {
      const reservationService = getReservationService();
      const { data, error } = await reservationService.createReservation(roomId, {
        ...formData,
        date: selectedDate,
        start_time: selectedSlot?.start || '',
        end_time: selectedSlot?.end || ''
      });
      
      if (error) {
        alert(error.message || '예약에 실패했습니다. 다시 시도해주세요.');
        return;
      }
      
      console.log('예약 완료:', data);
      alert('예약이 완료되었습니다!');
      setShowReservationModal(false);
      
      // 예약 조회 페이지로 이동
      router.push('/my-reservations');
      
    } catch (error) {
      console.error('예약 실패:', error);
      alert('예약에 실패했습니다. 다시 시도해주세요.');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">회의실 정보를 불러오는 중...</p>
        </div>
      </div>
    );
  }

  if (!room) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">회의실을 찾을 수 없습니다</h1>
          <p className="text-gray-600 mb-4">요청하신 회의실이 존재하지 않습니다.</p>
          <Link href="/">
            <Button>메인으로 돌아가기</Button>
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center">
            <Link href="/" className="mr-4">
              <Button variant="ghost" size="sm">
                <ArrowLeft className="w-4 h-4 mr-2" />
                뒤로가기
              </Button>
            </Link>
            <h1 className="text-xl font-semibold text-gray-900">회의실 예약</h1>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* 회의실 정보 */}
          <div className="lg:col-span-1">
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl">{room.name}</CardTitle>
                <div className="flex items-center text-gray-600 space-x-4">
                  <div className="flex items-center">
                    <MapPin className="w-4 h-4 mr-1" />
                    <span>{room.location}</span>
                  </div>
                  <Badge variant="secondary">
                    <Users className="w-3 h-3 mr-1" />
                    {room.capacity}명
                  </Badge>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                {room.description && (
                  <p className="text-gray-600 leading-relaxed">{room.description}</p>
                )}
                
                <div className="flex items-center text-sm text-gray-500">
                  <Clock className="w-4 h-4 mr-1" />
                  <span>운영시간: 09:00 - 18:00</span>
                </div>

                <div className="border-t pt-4">
                  <h3 className="font-medium text-gray-900 mb-2">주요 시설</h3>
                  <ul className="text-sm text-gray-600 space-y-1">
                    <li>• 대형 디스플레이</li>
                    <li>• 화상회의 시설</li>
                    <li>• 무선 프로젝터</li>
                    <li>• 화이트보드</li>
                    <li>• 무료 WiFi</li>
                  </ul>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* 예약 폼 */}
          <div className="lg:col-span-2">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Calendar className="w-5 h-5 mr-2" />
                  예약 일정 선택
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* 날짜 선택 */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    예약 날짜
                  </label>
                  <input
                    type="date"
                    value={selectedDate}
                    onChange={(e) => setSelectedDate(e.target.value)}
                    min={new Date().toISOString().split('T')[0]}
                    className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>

                {/* 시간대 선택 */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-3">
                    예약 시간 선택
                  </label>
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                    {timeSlots.map((slot, index) => (
                      <button
                        key={index}
                        onClick={() => handleSlotSelect(slot)}
                        disabled={!slot.available}
                        className={`
                          p-3 rounded-lg border text-sm font-medium transition-colors
                          ${selectedSlot === slot
                            ? 'bg-blue-600 text-white border-blue-600'
                            : slot.available
                            ? 'bg-white hover:bg-blue-50 border-gray-200 text-gray-900'
                            : 'bg-gray-100 border-gray-200 text-gray-400 cursor-not-allowed'
                          }
                        `}
                      >
                        {slot.start} - {slot.end}
                        {!slot.available && (
                          <div className="text-xs mt-1">예약됨</div>
                        )}
                      </button>
                    ))}
                  </div>
                </div>

                {/* 선택된 시간 표시 */}
                {selectedSlot && (
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                    <h3 className="font-medium text-blue-900 mb-2">선택된 예약 정보</h3>
                    <div className="text-sm text-blue-800 space-y-1">
                      <p><strong>회의실:</strong> {room.name}</p>
                      <p><strong>날짜:</strong> {selectedDate}</p>
                      <p><strong>시간:</strong> {selectedSlot.start} - {selectedSlot.end}</p>
                    </div>
                  </div>
                )}

                {/* 예약하기 버튼 */}
                <div className="flex justify-end">
                  <Button 
                    size="lg"
                    disabled={!selectedSlot}
                    className="px-8"
                    onClick={() => setShowReservationModal(true)}
                  >
                    {selectedSlot ? '예약하기' : '시간을 선택해주세요'}
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>

      {/* 예약 모달 */}
      <Dialog open={showReservationModal} onOpenChange={setShowReservationModal}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>회의실 예약</DialogTitle>
            <DialogDescription>
              예약자 정보를 입력해주세요.
            </DialogDescription>
          </DialogHeader>
          
          {selectedSlot && room && (
            <div className="space-y-4">
              {/* 예약 정보 요약 */}
              <div className="bg-gray-50 p-4 rounded-lg space-y-2">
                <h3 className="font-medium text-gray-900">예약 정보</h3>
                <div className="text-sm text-gray-600 space-y-1">
                  <p><strong>회의실:</strong> {room.name}</p>
                  <p><strong>날짜:</strong> {selectedDate}</p>
                  <p><strong>시간:</strong> {selectedSlot.start} - {selectedSlot.end}</p>
                </div>
              </div>

              {/* 간소화된 예약 폼 */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    예약자 이름 *
                  </label>
                  <input
                    type="text"
                    id="reserver_name"
                    placeholder="이름을 입력해주세요"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    휴대폰번호 *
                  </label>
                  <input
                    type="tel"
                    id="reserver_phone"
                    placeholder="010-0000-0000"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    비밀번호 *
                  </label>
                  <input
                    type="password"
                    id="password"
                    placeholder="4자리 이상 입력"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <p className="text-xs text-gray-500 mt-1">예약 조회 시 사용됩니다</p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    예약 제목 *
                  </label>
                  <input
                    type="text"
                    id="title"
                    placeholder="회의 제목을 입력해주세요"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>

                <div className="flex space-x-2 pt-4">
                  <Button
                    variant="outline"
                    className="flex-1"
                    onClick={() => setShowReservationModal(false)}
                    disabled={submitting}
                  >
                    취소
                  </Button>
                  <Button
                    className="flex-1"
                    onClick={async () => {
                      // 간단한 폼 데이터 수집 및 제출
                      const formData = {
                        reserver_name: (document.getElementById('reserver_name') as HTMLInputElement).value,
                        reserver_phone: (document.getElementById('reserver_phone') as HTMLInputElement).value,
                        password: (document.getElementById('password') as HTMLInputElement).value,
                        title: (document.getElementById('title') as HTMLInputElement).value,
                        date: selectedDate,
                        start_time: selectedSlot.start,
                        end_time: selectedSlot.end
                      };
                      
                      // 간단한 검증
                      if (!formData.reserver_name || !formData.reserver_phone || !formData.password || !formData.title) {
                        alert('모든 필수 항목을 입력해주세요.');
                        return;
                      }
                      
                      await handleReservationSubmit(formData);
                    }}
                    disabled={submitting}
                  >
                    {submitting ? '예약 중...' : '예약 완료'}
                  </Button>
                </div>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}