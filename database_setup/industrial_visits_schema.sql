-- INDUSTRIAL VISITS TABLE
CREATE TABLE industrial_visits (
    id BIGSERIAL PRIMARY KEY,
    organization_name TEXT NOT NULL,
    visit_date TEXT NOT NULL,
    visit_type TEXT DEFAULT 'Private', -- Government/Private
    no_of_students_visited INTEGER,
    program_name TEXT,
    no_of_staff_visited INTEGER,
    staff_name TEXT,
    city TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Note: Run the following in your Supabase SQL Editor to enable RLS Policies
-- ALTER TABLE industrial_visits ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Public Access" ON industrial_visits FOR ALL USING (true) WITH CHECK (true);
