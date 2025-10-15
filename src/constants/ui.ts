/**
 * UI 레이아웃 상수
 *
 * 컴포넌트 전역에서 사용되는 UI 관련 매직 넘버를 정의합니다.
 * Tailwind CSS 클래스명을 사용하여 일관된 디자인을 유지합니다.
 */

export const SEAT_LAYOUT = {
  /** 좌석 버튼 크기 */
  SEAT_SIZE: {
    WIDTH: 'w-10',
    HEIGHT: 'h-10',
  },
  /** 행 번호 표시 영역 너비 */
  ROW_NUMBER_WIDTH: 'w-8',
  /** 좌석 간 간격 */
  SEAT_GAP: 'gap-1',
  /** 행 간 간격 */
  ROW_GAP: 'gap-2',
} as const;

export const BOOKING_CONSTRAINTS = {
  /** 예약당 최대 선택 가능 좌석 수 (기본값, 추후 DB에서 동적으로 가져올 예정) */
  MAX_SEATS_PER_BOOKING: 4,
} as const;

export const GRID_SIZE = {
  /** 좌석 배치 기본 행 수 (추후 DB에서 동적으로 가져올 예정) */
  DEFAULT_ROWS: 15,
  /** 좌석 배치 기본 열 수 (추후 DB에서 동적으로 가져올 예정) */
  DEFAULT_COLS: 10,
} as const;
