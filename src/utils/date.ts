/**
 * 날짜 관련 유틸리티 함수
 *
 * 콘서트 및 예약 날짜 비교 로직을 중앙화하여 일관성을 유지합니다.
 */

/**
 * 주어진 날짜가 미래인지 확인합니다.
 *
 * @param dateString - ISO 8601 형식의 날짜 문자열
 * @returns 현재 시각보다 미래이면 true
 *
 * @example
 * ```typescript
 * isFutureConcert('2025-12-31T19:00:00Z') // true (현재가 2025년 이전이라면)
 * isFutureConcert('2024-01-01T19:00:00Z') // false (현재가 2024년 이후라면)
 * ```
 */
export function isFutureDate(dateString: string): boolean {
  return new Date(dateString) > new Date();
}

/**
 * 주어진 날짜가 과거인지 확인합니다.
 *
 * @param dateString - ISO 8601 형식의 날짜 문자열
 * @returns 현재 시각보다 과거이면 true
 */
export function isPastDate(dateString: string): boolean {
  return new Date(dateString) <= new Date();
}

/**
 * 날짜를 한국어 형식으로 포맷합니다.
 *
 * @param dateString - ISO 8601 형식의 날짜 문자열
 * @param includeTime - 시간 포함 여부 (기본값: false)
 * @returns 포맷된 날짜 문자열
 *
 * @example
 * ```typescript
 * formatKoreanDate('2025-12-31T19:00:00Z', false) // '2025년 12월 31일'
 * formatKoreanDate('2025-12-31T19:00:00Z', true)  // '2025년 12월 31일 19:00'
 * ```
 */
export function formatKoreanDate(dateString: string, includeTime: boolean = false): string {
  const date = new Date(dateString);
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();

  let formatted = `${year}년 ${month}월 ${day}일`;

  if (includeTime) {
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    formatted += ` ${hours}:${minutes}`;
  }

  return formatted;
}

/**
 * 두 날짜 사이의 일 수를 계산합니다.
 *
 * @param startDateString - 시작 날짜 (ISO 8601 형식)
 * @param endDateString - 종료 날짜 (ISO 8601 형식)
 * @returns 일 수 차이
 */
export function getDaysDifference(startDateString: string, endDateString: string): number {
  const start = new Date(startDateString);
  const end = new Date(endDateString);
  const diffMs = end.getTime() - start.getTime();
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}
