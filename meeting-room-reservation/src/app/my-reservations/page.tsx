'use client';

import { useState } from 'react';

// Force dynamic rendering
export const dynamic = 'force-dynamic';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { ArrowLeft, Phone, Lock, Calendar, Clock, MapPin, Users, Eye, EyeOff } from 'lucide-react';
import Link from 'next/link';
import { ReservationService } from '@/lib/services/reservation-service';
import type { ReservationWithRoom } from '@/lib/types';

export default function MyReservationsPage() {
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [reservations, setReservations] = useState<ReservationWithRoom[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [authenticated, setAuthenticated] = useState(false);
  
  const getReservationService = () => new ReservationService();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!phone || !password) {
      setError('휴대폰번호와 비밀번호를 모두 입력해주세요.');
      return;
    }
    
    setLoading(true);
    setError('');
    
    try {
      const reservationService = getReservationService();
      const { data, error: serviceError } = await reservationService.getReservationsByAuth(phone, password);
      
      if (serviceError) {
        setError('예약 조회 중 오류가 발생했습니다. 다시 시도해주세요.');
        return;
      }
      
      if (data && data.length > 0) {
        setReservations(data);
        setAuthenticated(true);
      } else {
        setError('해당 휴대폰번호와 비밀번호로 등록된 예약이 없습니다.');
      }
    } catch (error) {
      console.error('인증 실패:', error);
      setError('예약 조회 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('ko-KR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      weekday: 'long'
    });
  };

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleTimeString('ko-KR', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false
    });
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'upcoming':
        return <span className="inline-flex px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">예약됨</span>;
      case 'ongoing':
        return <span className="inline-flex px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">진행중</span>;
      case 'completed':
        return <span className="inline-flex px-2 py-1 text-xs font-medium bg-gray-100 text-gray-800 rounded-full">완료됨</span>;
      default:
        return null;
    }
  };

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
            <h1 className="text-xl font-semibold text-gray-900">내 예약 조회</h1>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {!authenticated ? (
          /* 로그인 폼 */
          <Card className="max-w-md mx-auto">
            <CardHeader>
              <CardTitle className="text-center">예약 조회</CardTitle>
              <p className="text-center text-gray-600">
                예약 시 입력한 휴대폰번호와 비밀번호를 입력해주세요.
              </p>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleLogin} className="space-y-4">
                <div>
                  <Label htmlFor="phone" className="flex items-center">
                    <Phone className="w-4 h-4 mr-1" />
                    휴대폰번호
                  </Label>
                  <Input
                    id="phone"
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="010-0000-0000"
                    className="mt-1"
                  />
                </div>

                <div>
                  <Label htmlFor="password" className="flex items-center">
                    <Lock className="w-4 h-4 mr-1" />
                    비밀번호
                  </Label>
                  <div className="relative mt-1">
                    <Input
                      id="password"
                      type={showPassword ? "text" : "password"}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="예약 시 설정한 비밀번호"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    >
                      {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                  </div>
                </div>

                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-md">
                    <p className="text-sm text-red-600">{error}</p>
                  </div>
                )}

                <Button type="submit" className="w-full" disabled={loading}>
                  {loading ? '조회 중...' : '예약 조회'}
                </Button>

                {/* 사용 안내 */}
                <div className="mt-6 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                  <p className="text-sm text-blue-800 font-medium mb-1">사용 안내</p>
                  <p className="text-xs text-blue-600">
                    예약 시 입력하신 휴대폰번호와 비밀번호를 정확히 입력해주세요.
                  </p>
                </div>
              </form>
            </CardContent>
          </Card>
        ) : (
          /* 예약 목록 */
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-2xl font-bold text-gray-900">
                내 예약 내역 ({reservations.length}건)
              </h2>
              <Button
                variant="outline"
                onClick={() => {
                  setAuthenticated(false);
                  setReservations([]);
                  setPhone('');
                  setPassword('');
                  setError('');
                }}
              >
                다른 계정으로 조회
              </Button>
            </div>

            {reservations.length === 0 ? (
              <Card>
                <CardContent className="text-center py-12">
                  <Calendar className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">
                    예약 내역이 없습니다
                  </h3>
                  <p className="text-gray-500 mb-4">
                    아직 예약하신 회의실이 없습니다.
                  </p>
                  <Link href="/">
                    <Button>회의실 예약하기</Button>
                  </Link>
                </CardContent>
              </Card>
            ) : (
              <div className="space-y-4">
                {reservations.map((reservation) => (
                  <Card key={reservation.id} className="hover:shadow-md transition-shadow">
                    <CardContent className="p-6">
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <div className="flex items-center space-x-3 mb-2">
                            <h3 className="text-lg font-semibold text-gray-900">
                              {reservation.title}
                            </h3>
                            {getStatusBadge(reservation.status)}
                          </div>
                          
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                            <div className="space-y-2">
                              <div className="flex items-center">
                                <MapPin className="w-4 h-4 mr-2" />
                                <span>{reservation.room.name} ({reservation.room.location})</span>
                              </div>
                              <div className="flex items-center">
                                <Users className="w-4 h-4 mr-2" />
                                <span>최대 {reservation.room.capacity}명</span>
                              </div>
                            </div>
                            
                            <div className="space-y-2">
                              <div className="flex items-center">
                                <Calendar className="w-4 h-4 mr-2" />
                                <span>{formatDate(reservation.start_time)}</span>
                              </div>
                              <div className="flex items-center">
                                <Clock className="w-4 h-4 mr-2" />
                                <span>
                                  {formatTime(reservation.start_time)} - {formatTime(reservation.end_time)}
                                </span>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}