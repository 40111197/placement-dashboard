-- =============================================================================
-- MIGRATION: Add 'batch' column to field_visits table
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run
-- =============================================================================

ALTER TABLE field_visits
ADD COLUMN IF NOT EXISTS batch VARCHAR(50);

-- Verify the column was added
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'field_visits'
  AND table_schema = 'public'
ORDER BY ordinal_position;
