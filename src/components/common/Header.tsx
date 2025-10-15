import Link from 'next/link';

export default function Header() {
  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="container mx-auto px-4 py-4">
        <nav className="flex items-center justify-between">
          <Link
            href="/"
            className="text-2xl font-bold text-indigo-600 hover:text-indigo-700 transition-colors"
          >
            Concert Booking
          </Link>

          <div className="flex items-center gap-6">
            <Link
              href="/"
              className="text-gray-700 hover:text-indigo-600 font-medium transition-colors"
            >
              Concerts
            </Link>
            <Link
              href="/bookings"
              className="text-gray-700 hover:text-indigo-600 font-medium transition-colors"
            >
              My Bookings
            </Link>
          </div>
        </nav>
      </div>
    </header>
  );
}
