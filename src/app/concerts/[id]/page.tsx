'use client';

import { use, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useConcert } from '@/contexts/ConcertContext';
import { concertRepository } from '@/lib/repositories/concertRepository';
import ConcertDetail from '@/components/concerts/ConcertDetail';
import Loading from '@/components/common/Loading';
import ErrorMessage from '@/components/common/ErrorMessage';
import { Concert } from '@/types';

interface ConcertDetailPageProps {
  params: Promise<{ id: string }>;
}

export default function ConcertDetailPage({ params }: ConcertDetailPageProps) {
  const unwrappedParams = use(params);
  const router = useRouter();
  const { selectConcert, selectedConcert } = useConcert();
  const [concert, setConcert] = useState<Concert | null>(selectedConcert);
  const [loading, setLoading] = useState<boolean>(!selectedConcert);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!selectedConcert) {
      const loadConcert = async () => {
        try {
          setLoading(true);
          const fetchedConcert = await concertRepository.fetchById(unwrappedParams.id);
          if (fetchedConcert) {
            setConcert(fetchedConcert);
            selectConcert(fetchedConcert);
          } else {
            setError('콘서트를 찾을 수 없습니다');
          }
        } catch (err) {
          setError(err instanceof Error ? err.message : '콘서트 정보를 불러오는데 실패했습니다');
        } finally {
          setLoading(false);
        }
      };
      loadConcert();
    }
  }, [unwrappedParams.id, selectedConcert, selectConcert]);

  const handleSelectSeats = () => {
    router.push(`/concerts/${unwrappedParams.id}/seats`);
  };

  if (loading) return <Loading />;
  if (error) return <ErrorMessage message={error} />;
  if (!concert) return <ErrorMessage message="콘서트를 찾을 수 없습니다" />;

  return (
    <div className="max-w-4xl mx-auto">
      <ConcertDetail concert={concert} onSelectSeats={handleSelectSeats} />
    </div>
  );
}
