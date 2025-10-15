import type { Metadata } from 'next';
import './globals.css';
import { ConcertProvider } from '@/contexts/ConcertContext';
import { SeatProvider } from '@/contexts/SeatContext';
import { BookingProvider } from '@/contexts/BookingContext';
import { ToastProvider } from '@/contexts/ToastContext';
import ErrorBoundary from '@/components/common/ErrorBoundary';
import Header from '@/components/common/Header';

export const metadata: Metadata = {
  title: '콘서트 예약 플랫폼',
  description: '원하는 콘서트를 쉽고 빠르게 예약하세요',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body>
        <ErrorBoundary>
          <ToastProvider>
            <ConcertProvider>
              <SeatProvider>
                <BookingProvider>
                  <Header />
                  <main className="container mx-auto px-4 py-8 min-h-screen">
                    {children}
                  </main>
                </BookingProvider>
              </SeatProvider>
            </ConcertProvider>
          </ToastProvider>
        </ErrorBoundary>
      </body>
    </html>
  );
}
