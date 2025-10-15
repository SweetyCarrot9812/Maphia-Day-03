export default function SkeletonCard() {
  return (
    <div className="bg-white rounded-lg shadow-md p-6 animate-pulse">
      {/* 이미지 스켈레톤 */}
      <div className="w-full h-48 bg-gray-200 rounded-lg mb-4"></div>

      {/* 제목 스켈레톤 */}
      <div className="h-6 bg-gray-200 rounded w-3/4 mb-3"></div>

      {/* 내용 스켈레톤 */}
      <div className="space-y-2 mb-4">
        <div className="h-4 bg-gray-200 rounded w-full"></div>
        <div className="h-4 bg-gray-200 rounded w-5/6"></div>
      </div>

      {/* 버튼 스켈레톤 */}
      <div className="h-10 bg-gray-200 rounded w-full"></div>
    </div>
  );
}
