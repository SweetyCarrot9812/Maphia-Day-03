# Database Migration Guide

## Migration: Add Concert Configuration

**Created**: 2025-10-16
**Migration File**: `supabase/migrations/20251016_add_concert_configuration.sql`

### Overview

This migration adds dynamic concert configuration capabilities, allowing each concert to have different seat limits and grid layouts instead of hardcoded values.

### Changes

#### 1. New Database Columns

**`concerts.max_seats_per_booking`**
- Type: `INTEGER NOT NULL DEFAULT 4`
- Constraint: `CHECK (max_seats_per_booking > 0 AND max_seats_per_booking <= 10)`
- Purpose: Define maximum seats per booking for each concert
- Default: 4 seats (existing behavior)

**`concerts.seat_layout`**
- Type: `JSONB NOT NULL DEFAULT '{"rows": 15, "columns": 10}'`
- Constraint: Validates rows (1-30) and columns (1-20)
- Purpose: Define seat grid dimensions per concert
- Default: 15 rows × 10 columns (existing behavior)

#### 2. Constraints

```sql
-- Seat layout structure validation
CHECK (
  seat_layout ? 'rows' AND
  seat_layout ? 'columns' AND
  (seat_layout->>'rows')::int > 0 AND
  (seat_layout->>'rows')::int <= 30 AND
  (seat_layout->>'columns')::int > 0 AND
  (seat_layout->>'columns')::int <= 20
)
```

#### 3. Index

```sql
CREATE INDEX IF NOT EXISTS idx_concerts_date ON concerts(date);
```

### How to Apply Migration

#### Option 1: Supabase Dashboard (Recommended for Development)

1. Go to Supabase Dashboard
2. Navigate to SQL Editor
3. Copy contents of `supabase/migrations/20251016_add_concert_configuration.sql`
4. Execute the SQL
5. Verify changes in Table Editor

#### Option 2: Supabase CLI (Recommended for Production)

```bash
# Ensure Supabase CLI is installed
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Apply migration
supabase db push

# Verify migration
supabase db diff
```

### TypeScript Changes

The `Concert` type has been updated to include the new fields:

```typescript
export interface SeatLayout {
  rows: number;
  columns: number;
}

export interface Concert {
  // ... existing fields
  max_seats_per_booking: number;
  seat_layout: SeatLayout;
}
```

### Application Changes

#### 1. SeatContext
- Now accepts `maxSeatsPerBooking` parameter in `loadSeats()`
- Dynamically enforces seat selection limit based on concert config
- Falls back to `BOOKING_CONSTRAINTS.MAX_SEATS_PER_BOOKING` (4) if not provided

#### 2. SeatGrid Component
- Now accepts optional `layout` prop
- Dynamically renders grid based on concert's seat_layout
- Falls back to `GRID_SIZE.DEFAULT_ROWS` (15) and `GRID_SIZE.DEFAULT_COLS` (10) if not provided

#### 3. SeatsPage
- Passes `selectedConcert.max_seats_per_booking` to `loadSeats()`
- Passes `selectedConcert.seat_layout` to `SeatGrid`

### Backward Compatibility

✅ **Fully backward compatible**

- Existing concerts automatically get default values (4 seats, 15×10 grid)
- Application falls back to constants if concert config is not available
- No breaking changes to existing functionality

### Testing Checklist

After migration, verify:

- [ ] Existing concerts display correctly with default values
- [ ] Seat selection still limited to 4 seats for existing concerts
- [ ] Grid renders as 15×10 for existing concerts
- [ ] New concerts can be created with custom configurations
- [ ] Seat limit validation works with custom values
- [ ] Grid renders correctly with custom dimensions
- [ ] Error handling works for invalid configurations

### Example: Creating Concert with Custom Config

```sql
INSERT INTO concerts (
  title,
  artist,
  date,
  venue,
  running_time,
  max_seats_per_booking,
  seat_layout
) VALUES (
  'VIP Concert',
  'Famous Artist',
  '2025-12-31T19:00:00Z',
  'Grand Theater',
  120,
  2,  -- Only 2 seats per booking
  '{"rows": 10, "columns": 8}'  -- Smaller venue
);
```

### Rollback Plan

If issues arise, rollback with:

```sql
-- Remove constraints
ALTER TABLE concerts DROP CONSTRAINT IF EXISTS seat_layout_structure_check;
ALTER TABLE concerts DROP CONSTRAINT IF EXISTS concerts_max_seats_per_booking_check;

-- Remove columns
ALTER TABLE concerts DROP COLUMN IF EXISTS max_seats_per_booking;
ALTER TABLE concerts DROP COLUMN IF EXISTS seat_layout;

-- Remove index
DROP INDEX IF EXISTS idx_concerts_date;
```

### Future Enhancements

Possible future improvements:
- Add seat pricing tiers per concert
- Support non-rectangular seat layouts
- Add disabled seat positions for accessibility
- Support multiple seating sections per concert
- Add capacity management and sold-out detection

### Support

If you encounter issues:
1. Check Supabase logs in Dashboard
2. Verify column types match expected schema
3. Test with `SELECT * FROM concerts LIMIT 1` to inspect structure
4. Review application logs for TypeScript type errors

---

**Status**: ✅ Ready for deployment
**Breaking Changes**: None
**Requires Data Migration**: No (defaults applied automatically)
