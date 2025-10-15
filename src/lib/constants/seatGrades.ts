export const SEAT_GRADE_PRICES = {
  VIP: 150000,
  R: 100000,
  S: 70000,
  A: 50000,
} as const;

export const SEAT_GRADE_ROWS = {
  VIP: [1, 2],
  R: [3, 4, 5],
  S: [6, 7, 8, 9, 10],
  A: [11, 12, 13, 14, 15],
} as const;

export const SEAT_GRADE_COLORS = {
  VIP: 'bg-purple-500',
  R: 'bg-blue-500',
  S: 'bg-green-500',
  A: 'bg-gray-500',
} as const;
