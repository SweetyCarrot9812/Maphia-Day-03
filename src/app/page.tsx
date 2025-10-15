'use client';

import { useConcert } from '@/contexts/ConcertContext';
import ConcertList from '@/components/concerts/ConcertList';
import Loading from '@/components/common/Loading';
import ErrorMessage from '@/components/common/ErrorMessage';
import { useRouter } from 'next/navigation';
import { Concert } from '@/types';

export default function HomePage() {
  const { concerts, loading, error, selectConcert } = useConcert();
  const router = useRouter();

  if (loading) return <Loading />;
  if (error) return <ErrorMessage message={error} />;

  const handleConcertClick = (concert: Concert) => {
    selectConcert(concert);
    router.push(`/concerts/${concert.id}`);
  };

  return (
    <div>
      <h1 className="text-3xl font-bold mb-8">콘서트 목록</h1>
      <ConcertList concerts={concerts} onConcertClick={handleConcertClick} />
    </div>
  );
}
