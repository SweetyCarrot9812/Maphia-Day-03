export default function SeatLegend() {
  return (
    <div className="flex items-center justify-center gap-6 p-4 bg-gray-50 rounded-lg">
      <div className="flex items-center gap-2">
        <div className="w-6 h-6 bg-green-500 rounded"></div>
        <span className="text-sm font-medium text-gray-700">🟢 선택 가능</span>
      </div>

      <div className="flex items-center gap-2">
        <div className="w-6 h-6 bg-red-500 rounded"></div>
        <span className="text-sm font-medium text-gray-700">🔴 예약 완료</span>
      </div>

      <div className="flex items-center gap-2">
        <div className="w-6 h-6 bg-yellow-500 rounded"></div>
        <span className="text-sm font-medium text-gray-700">🟡 선택됨</span>
      </div>
    </div>
  );
}
