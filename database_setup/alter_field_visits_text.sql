-- Run this against your Supabase database in the SQL Editor.
-- This alters the program_name and staff_name columns to TEXT to safely store JSON strings for the multiple-entries feature.

ALTER TABLE field_visits ALTER COLUMN program_name TYPE TEXT;
ALTER TABLE field_visits ALTER COLUMN staff_name TYPE TEXT;
