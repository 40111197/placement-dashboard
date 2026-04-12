-- =============================================================================
-- PLACEMENT DASHBOARD — SUPABASE SETUP SQL
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run
-- Only needs to be run ONCE.
-- =============================================================================
-- ─── 1. ADD MISSING COLUMNS TO SETTINGS ──────────────────────────────────────
ALTER TABLE settings
ADD COLUMN IF NOT EXISTS admin_username VARCHAR(150) DEFAULT 'admin';
ALTER TABLE settings
ADD COLUMN IF NOT EXISTS admin_email VARCHAR(150) DEFAULT 'admin@rru.ac.in';
ALTER TABLE settings
ADD COLUMN IF NOT EXISTS admin_mobile VARCHAR(20) DEFAULT '';
-- SHA-256 hex of 'Admin@123'
ALTER TABLE settings
ADD COLUMN IF NOT EXISTS admin_password_hash VARCHAR(64) DEFAULT 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7';
-- Update the existing settings row with admin credentials
UPDATE settings
SET admin_username = 'admin',
    admin_email = 'admin@rru.ac.in',
    admin_mobile = '',
    admin_password_hash = 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7'
WHERE id = 1;
-- ─── 2. PLACEMENTS ───────────────────────────────────────────────────────────
ALTER TABLE placements
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE placements
ADD COLUMN IF NOT EXISTS course VARCHAR(100);
ALTER TABLE placements
ADD COLUMN IF NOT EXISTS name VARCHAR(150);
ALTER TABLE placements
ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE placements
ADD COLUMN IF NOT EXISTS company VARCHAR(150);
ALTER TABLE placements
ADD COLUMN IF NOT EXISTS city VARCHAR(150);
ALTER TABLE placements
ADD COLUMN IF NOT EXISTS ctc VARCHAR(100);
-- ─── 3. CREATE STUDENTS TABLE IF MISSING ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS students (
    enrollment_number VARCHAR(50) PRIMARY KEY,
    student_name VARCHAR(150) NOT NULL,
    student_email_id VARCHAR(150),
    mobile_number VARCHAR(20),
    programme VARCHAR(100),
    higher_education_plan VARCHAR(10) DEFAULT 'No',
    placement_status VARCHAR(10) DEFAULT 'No',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ─── 4. CREATE COMPANIES TABLE IF MISSING ────────────────────────────────────
CREATE TABLE IF NOT EXISTS companies (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    role VARCHAR(150),
    contact_person VARCHAR(150),
    contact VARCHAR(150),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ─── 5. CREATE INTERNSHIPS TABLE IF MISSING ──────────────────────────────────
CREATE TABLE IF NOT EXISTS internships (
    id BIGSERIAL PRIMARY KEY,
    year VARCHAR(10),
    enrolment_no VARCHAR(50),
    programme VARCHAR(100),
    name_of_student VARCHAR(150),
    gender VARCHAR(20),
    internship_place_01 VARCHAR(255),
    duration_of_intership_01 VARCHAR(100),
    city_of_intership_01 VARCHAR(100),
    internship_place_02 VARCHAR(255),
    duration_of_intership_02 VARCHAR(100),
    city_of_intership_02 VARCHAR(100),
    type_of_organization VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ─── 5.5 CREATE FIELD VISITS TABLE IF MISSING ────────────────────────────────
CREATE TABLE IF NOT EXISTS field_visits (
    id BIGSERIAL PRIMARY KEY,
    enrollment_number VARCHAR(50),
    student_name VARCHAR(150),
    visit_date VARCHAR(20),
    programme VARCHAR(100),
    organization_name VARCHAR(150),
    location VARCHAR(150),
    faculty_coordinator VARCHAR(150),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Ensure column exists if table already existed
ALTER TABLE field_visits
ADD COLUMN IF NOT EXISTS student_name VARCHAR(150);
-- ─── 6. RLS POLICIES — Allow all operations via anon key ─────────────────────
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE placements ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for anon - students" ON students;
DROP POLICY IF EXISTS "Allow all for anon - companies" ON companies;
DROP POLICY IF EXISTS "Allow all for anon - placements" ON placements;
DROP POLICY IF EXISTS "Allow all for anon - internships" ON internships;
DROP POLICY IF EXISTS "Allow all for anon - field_visits" ON field_visits;
DROP POLICY IF EXISTS "Allow all for anon - settings" ON settings;
CREATE POLICY "Allow all for anon - students" ON students FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - companies" ON companies FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - placements" ON placements FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - internships" ON internships FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - field_visits" ON field_visits FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - settings" ON settings FOR ALL USING (true) WITH CHECK (true);
-- ─── 7. VERIFY RESULT ────────────────────────────────────────────────────────
SELECT table_name,
    (
        SELECT COUNT(*)
        FROM information_schema.columns c
        WHERE c.table_name = t.table_name
            AND c.table_schema = 'public'
    ) AS column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;