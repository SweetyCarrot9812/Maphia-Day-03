-- Migration: Add concert configuration fields
-- Created: 2025-10-16
-- Purpose: Support dynamic seat limits and layout per concert

-- Add max_seats_per_booking column (default: 4)
ALTER TABLE concerts
ADD COLUMN IF NOT EXISTS max_seats_per_booking INTEGER NOT NULL DEFAULT 4
CHECK (max_seats_per_booking > 0 AND max_seats_per_booking <= 10);

-- Add seat_layout column as JSONB
ALTER TABLE concerts
ADD COLUMN IF NOT EXISTS seat_layout JSONB NOT NULL DEFAULT '{"rows": 15, "columns": 10}'::jsonb;

-- Add constraint to validate seat_layout structure
ALTER TABLE concerts
ADD CONSTRAINT seat_layout_structure_check
CHECK (
  seat_layout ? 'rows' AND
  seat_layout ? 'columns' AND
  (seat_layout->>'rows')::int > 0 AND
  (seat_layout->>'rows')::int <= 30 AND
  (seat_layout->>'columns')::int > 0 AND
  (seat_layout->>'columns')::int <= 20
);

-- Comment on columns
COMMENT ON COLUMN concerts.max_seats_per_booking IS
'Maximum number of seats a user can select per booking (1-10)';

COMMENT ON COLUMN concerts.seat_layout IS
'Seat grid configuration in JSON format: {"rows": number, "columns": number}';

-- Update existing concerts with default values (if needed)
UPDATE concerts
SET
  max_seats_per_booking = 4,
  seat_layout = '{"rows": 15, "columns": 10}'::jsonb
WHERE max_seats_per_booking IS NULL OR seat_layout IS NULL;

-- Create index for common query patterns
CREATE INDEX IF NOT EXISTS idx_concerts_date ON concerts(date);
