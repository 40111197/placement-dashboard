-- =============================================================================
-- TOTAL FACTORY RESET
-- Run this in your Supabase SQL Editor.
-- THIS WILL DELETE THE ENTIRE DATABASE, INCLUDING THE ADMIN LOGIN.
-- =============================================================================
-- ─── 1. DROP EVERY TABLE ─────────────────────────────────────────────────────
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS placements CASCADE;
DROP TABLE IF EXISTS internships CASCADE;
DROP TABLE IF EXISTS field_visits CASCADE;
DROP TABLE IF EXISTS settings CASCADE;
-- ─── 2. CREATE SETTINGS (ADMIN LOGIN) ────────────────────────────────────────
CREATE TABLE settings (
    id SERIAL PRIMARY KEY,
    theme_mode VARCHAR(20) DEFAULT 'light',
    admin_username VARCHAR(150) DEFAULT 'admin',
    admin_email VARCHAR(150) DEFAULT 'admin@rru.ac.in',
    admin_mobile VARCHAR(20) DEFAULT '',
    admin_password_hash VARCHAR(64) DEFAULT 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7',
    two_factor_enabled BOOLEAN DEFAULT false,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
INSERT INTO settings (id)
VALUES (1);
-- ─── 3. CREATE STUDENTS ──────────────────────────────────────────────────────
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
-- ─── 4. CREATE COMPANIES ─────────────────────────────────────────────────────
CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    role VARCHAR(150),
    contact_person VARCHAR(150),
    contact VARCHAR(150),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ─── 5. CREATE PLACEMENTS ────────────────────────────────────────────────────
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
-- ─── 6. CREATE INTERNSHIPS ───────────────────────────────────────────────────
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
-- ─── 7. CREATE FIELD VISITS ──────────────────────────────────────────────────
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
-- ─── 8. UNLOCK SECURITY PERMISSIONS ──────────────────────────────────────────
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE placements ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for anon - students" ON students FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - companies" ON companies FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - placements" ON placements FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - internships" ON internships FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - field_visits" ON field_visits FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for anon - settings" ON settings FOR ALL USING (true) WITH CHECK (true);