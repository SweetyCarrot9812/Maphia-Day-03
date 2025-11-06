import Link from 'next/link';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Conference Room Booking System
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Book conference rooms with real-time availability
          </p>

          <div className="space-y-4 max-w-md mx-auto">
            <Link
              href="/rooms"
              className="block w-full bg-blue-600 text-white py-3 px-6 rounded-lg hover:bg-blue-700 transition-colors"
            >
              View Available Rooms
            </Link>

            <Link
              href="/admin"
              className="block w-full bg-gray-600 text-white py-3 px-6 rounded-lg hover:bg-gray-700 transition-colors"
            >
              Admin Login
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}