'use client';

import { useState, useEffect } from 'react';

// Force dynamic rendering
export const dynamic = 'force-dynamic';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { MapPin, Users, Calendar, Clock, Search } from 'lucide-react';
import Link from 'next/link';
import { ReservationService } from '@/lib/services/reservation-service';
import type { Room } from '@/lib/types';

export default function Home() {
  const [rooms, setRooms] = useState<Room[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const getReservationService = () => new ReservationService();

  useEffect(() => {
    const fetchRooms = async () => {
      try {
        const reservationService = getReservationService();
        const { data, error } = await reservationService.getRooms();
        if (error) {
          console.error('Error fetching rooms:', error);
        } else {
          setRooms(data || []);
        }
      } catch (error) {
        console.error('Error:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchRooms();
  }, []);

  const filteredRooms = rooms.filter(room =>
    room.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    room.location.toLowerCase().includes(searchTerm.toLowerCase())
  );

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

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">회의실 예약 시스템</h1>
              <p className="mt-2 text-gray-600">원하는 회의실을 선택하고 예약하세요</p>
            </div>
            <div className="mt-4 md:mt-0">
              <Link href="/my-reservations">
                <Button variant="outline" className="gap-2">
                  <Calendar className="w-4 h-4" />
                  내 예약 조회
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Search Bar */}
        <div className="mb-8">
          <div className="relative max-w-md">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="회의실 이름 또는 위치로 검색..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>

        {/* Room Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRooms.map((room) => (
            <Card key={room.id} className="hover:shadow-lg transition-shadow cursor-pointer">
              <CardHeader>
                <div className="flex items-start justify-between">
                  <CardTitle className="text-xl">{room.name}</CardTitle>
                  <Badge variant="secondary">
                    <Users className="w-3 h-3 mr-1" />
                    {room.capacity}명
                  </Badge>
                </div>
                <div className="flex items-center text-gray-600">
                  <MapPin className="w-4 h-4 mr-1" />
                  <span>{room.location}</span>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {room.description && (
                    <p className="text-gray-600 text-sm leading-relaxed">
                      {room.description}
                    </p>
                  )}
                  
                  <div className="flex items-center text-sm text-gray-500">
                    <Clock className="w-4 h-4 mr-1" />
                    <span>운영시간: 09:00 - 18:00</span>
                  </div>

                  <div className="pt-2">
                    <Link href={`/rooms/${room.id}`}>
                      <Button className="w-full">
                        예약하기
                      </Button>
                    </Link>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {filteredRooms.length === 0 && (
          <div className="text-center py-12">
            <div className="text-gray-400 mb-4">
              <Search className="w-12 h-12 mx-auto" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              검색 결과가 없습니다
            </h3>
            <p className="text-gray-500">
              다른 검색어를 시도해보세요.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
