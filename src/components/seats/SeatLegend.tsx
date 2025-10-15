export default function SeatLegend() {
  const gradeInfo = [
    { grade: 'VIP', color: 'bg-purple-500', price: '150,000원' },
    { grade: 'R석', color: 'bg-pink-500', price: '120,000원' },
    { grade: 'S석', color: 'bg-blue-500', price: '90,000원' },
    { grade: 'A석', color: 'bg-green-500', price: '60,000원' },
  ];

  const statusInfo = [
    { label: '선택 가능', color: 'bg-gray-300', icon: '○' },
    { label: '선택됨', color: 'bg-blue-600', icon: '●' },
    { label: '예약 완료', color: 'bg-gray-400', icon: '✕' },
  ];

  return (
    <div className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl shadow-sm p-6 space-y-4">
      {/* 좌석 등급 및 가격 */}
      <div>
        <h3 className="text-sm font-bold text-gray-700 mb-3">💺 좌석 등급 및 가격</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {gradeInfo.map((info) => (
            <div
              key={info.grade}
              className="flex items-center gap-3 bg-white rounded-lg p-3 shadow-sm hover:shadow-md transition"
            >
              <div className={`w-8 h-8 ${info.color} rounded-lg shadow-sm`}></div>
              <div>
                <div className="text-sm font-bold text-gray-900">{info.grade}</div>
                <div className="text-xs font-medium text-blue-600">{info.price}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* 좌석 상태 */}
      <div>
        <h3 className="text-sm font-bold text-gray-700 mb-3">📌 좌석 상태</h3>
        <div className="flex flex-wrap gap-4">
          {statusInfo.map((info) => (
            <div key={info.label} className="flex items-center gap-2">
              <div
                className={`w-6 h-6 ${info.color} rounded-lg shadow-sm flex items-center justify-center text-white text-xs font-bold`}
              >
                {info.icon}
              </div>
              <span className="text-sm font-medium text-gray-700">{info.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* 안내 메시지 */}
      <div className="text-xs text-gray-500 bg-white rounded-lg p-3 border-l-4 border-blue-500">
        💡 <strong>Tip:</strong> 좌석에 마우스를 올리면 상세 정보를 확인할 수 있습니다. 최대 4석까지 선택 가능합니다.
      </div>
    </div>
  );
}
