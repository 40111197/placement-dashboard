-- MASTER RESET: DROP & RECREATE SCHEMA (EXCEL ALIGNED)
-- WARNING: This will delete all existing data in these three tables.
-- Run this in your Supabase SQL Editor.
-- Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS internships;
DROP TABLE IF EXISTS placements;
DROP TABLE IF EXISTS students;
-- 1. STUDENT MASTER TABLE (MATCHES EXCEL HEADER ORDER & MANDATORY)
CREATE TABLE students (
    admitted_year TEXT NOT NULL,
    student_name TEXT NOT NULL,
    enrollment_number TEXT PRIMARY KEY,
    programme TEXT NOT NULL,
    batch TEXT NOT NULL,
    student_email_id TEXT NOT NULL,
    personal_email_id TEXT,
    mobile_number TEXT NOT NULL,
    remark TEXT,
    opted_for_placement TEXT DEFAULT 'No',
    placement_status TEXT DEFAULT 'No',
    created_at TIMESTAMPTZ DEFAULT now()
);
-- 2. PLACEMENT TABLE
CREATE TABLE placements (
    enrollment_number TEXT PRIMARY KEY REFERENCES students(enrollment_number) ON DELETE CASCADE,
    course TEXT,
    name TEXT,
    remarks TEXT,
    company TEXT,
    city TEXT,
    ctc TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);
-- 3. INTERNSHIP TABLE
-- Support multiple internships per student by using a unique ID
CREATE TABLE internships (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    enrollment_number TEXT REFERENCES students(enrollment_number) ON DELETE CASCADE,
    year TEXT,
    programme TEXT,
    name_of_student TEXT,
    gender TEXT,
    role TEXT,
    salary TEXT,
    internship_place_01 TEXT,
    duration_of_intership_01 TEXT,
    city_of_intership_01 TEXT,
    internship_place_02 TEXT,
    duration_of_intership_02 TEXT,
    city_of_intership_02 TEXT,
    type_of_organization TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);
-- Enable RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE placements ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
-- Allow all authenticated users access
DROP POLICY IF EXISTS "Public Access" ON students;
CREATE POLICY "Public Access" ON students FOR ALL USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Public Access" ON placements;
CREATE POLICY "Public Access" ON placements FOR ALL USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "Public Access" ON internships;
CREATE POLICY "Public Access" ON internships FOR ALL USING (true) WITH CHECK (true);