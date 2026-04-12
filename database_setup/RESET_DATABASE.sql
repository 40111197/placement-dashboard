-- =============================================================================
-- PLACEMENT DASHBOARD — RESET DATABASE SQL
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run
-- WARNING: THIS DELETES ALL EXISTING DATA IN THESE TABLES.
-- =============================================================================
-- ─── 0. DROP ALL DATA TABLES (Preserving 'settings') ─────────────────────────
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS placements CASCADE;
DROP TABLE IF EXISTS internships CASCADE;
DROP TABLE IF EXISTS field_visits CASCADE;
-- ─── 1. RECREATE STUDENTS TABLE ──────────────────────────────────────────────
CREATE TABLE students (
    enrollment_number VARCHAR(50) PRIMARY KEY,
    student_name VARCHAR(150) NOT NULL,
    student_email_id VARCHAR(150),
    mobile_number VARCHAR(20),
    programme VARCHAR(100),
    higher_education_plan VARCHAR(10) DEFAULT 'No',
    placement_status VARCHAR(10) DEFAULT 'No',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ─── 2. RECREATE COMPANIES TABLE ─────────────────────────────────────────────
CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    role VARCHAR(150),
    contact_person VARCHAR(150),
    contact VARCHAR(150),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ─── 3. RECREATE PLACEMENTS TABLE ────────────────────────────────────────────
CREATE TABLE placements (
    id BIGSERIAL PRIMARY KEY,
    course VARCHAR(100),
    name VARCHAR(150),
    remarks TEXT,
    company VARCHAR(150),
    city VARCHAR(150),
    ctc VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ─── 4. RECREATE INTERNSHIPS TABLE ───────────────────────────────────────────
CREATE TABLE internships (
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
-- ─── 5. RECREATE FIELD VISITS TABLE ──────────────────────────────────────────
CREATE TABLE field_visits (
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
-- ─── 6. RE-ENABLE ROW LEVEL SECURITY (RLS) ───────────────────────────────────
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE placements ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_visits ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for anon - students" ON students FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - companies" ON companies FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - placements" ON placements FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - internships" ON internships FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - field_visits" ON field_visits FOR ALL USING (true) WITH CHECK (true);
-- ─── 7. VERIFY RECREATION ────────────────────────────────────────────────────
SELECT table_name,
    (
        SELECT COUNT(*)
        FROM information_schema.columns c
        WHERE c.table_name = t.table_name
            AND c.table_schema = 'public'
    ) AS column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
    AND table_name IN (
        'students',
        'companies',
        'placements',
        'internships',
        'field_visits'
    )
ORDER BY table_name;