const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

// Extract config from config.js
const configContent = fs.readFileSync('config.js', 'utf8');
const supabaseUrlMatch = configContent.match(/window\.ENV\.SUPABASE_URL\s*=\s*'([^']+)'/);
const supabaseKeyMatch = configContent.match(/window\.ENV\.SUPABASE_ANON_KEY\s*=\s*'([^']+)'/);

if (!supabaseUrlMatch || !supabaseKeyMatch) {
    console.error("Could not find Supabase credentials in config.js");
    process.exit(1);
}

const supabaseUrl = supabaseUrlMatch[1];
const supabaseKey = supabaseKeyMatch[1];
const _sb = createClient(supabaseUrl, supabaseKey);

async function getAcademicYearPlacementRate() {
    try {
        const now   = new Date();
        const month = now.getMonth() + 1;
        const year  = now.getFullYear();

        // 1. Fetch all required data once for efficiency
        const { data: students, error: sErr } = await _sb.from('students').select('enrollment_number, batch, admitted_year, opted_for_placement');
        if (sErr) throw sErr;
        const { data: placementsRaw, error: pErr } = await _sb.from('placements').select('enrollment_number, role, remarks');
        if (pErr) throw pErr;

        const validPlacements = (placementsRaw || []).filter(p => {
            const role = String(p.role || '').toLowerCase().trim();
            const remarks = String(p.remarks || '').toLowerCase().trim();
            return role !== 'awaiting for offer letter' && remarks !== 'awaiting for offer letter';
        });
        const placedSet = new Set(validPlacements.map(p => String(p.enrollment_number).trim()));

        // 2. Identify candidate academic years to check (Current and Previous 2)
        let candidates = [];
        let currStart = (month >= 7) ? year : year - 1;
        candidates.push({ start: currStart, end: currStart + 1 });
        candidates.push({ start: currStart - 1, end: currStart });
        candidates.push({ start: currStart - 2, end: currStart - 1 });

        let bestResult = null;

        for (const cand of candidates) {
            const batchLabel = `${cand.start}-${String(cand.end).slice(-2)}`;
            
            const targetStudents = (students || []).filter(s => {
                const b = String(s.batch || s.admitted_year || '').trim();
                if (!b) return false;
                const bLow = b.toLowerCase();

                // Primary: parse "YYYY-YYYY" or "YYYY-YY" and match by START year
                // e.g. "2024-2025" or "2024-25" → startYear = 2024
                const parts = b.split('-');
                if (parts.length === 2) {
                    const bStart = parseInt(parts[0]);
                    if (!isNaN(bStart) && bStart === cand.start) return true;
                }

                // Secondary: single year field (admitted_year) matches start year
                const singleYear = parseInt(b);
                if (!isNaN(singleYear) && parts.length === 1 && singleYear === cand.start) return true;

                // Tertiary: exact full label match (e.g. "2024-25" or "24-25")
                if (bLow === `${cand.start}-${String(cand.end).slice(-2)}`) return true;
                if (bLow === `${String(cand.start).slice(-2)}-${String(cand.end).slice(-2)}`) return true;

                return false;
            });

            const opted = targetStudents.filter(s => {
                const v = String(s.opted_for_placement || '').toLowerCase().trim();
                return v === 'yes' || v === '1' || v === 'true';
            });

            console.log(`Candidate ${batchLabel}: targetStudents=${targetStudents.length}, opted=${opted.length}`);

            if (opted.length > 0) {
                const placedCount = opted.filter(s => placedSet.has(String(s.enrollment_number).trim())).length;
                const rate = Math.round((placedCount / opted.length) * 100);
                
                const result = { rate, placed: placedCount, opted: opted.length, batchLabel };
                
                // If we found ANY placements, this is our best result (latest batch with data)
                if (placedCount > 0) return result;
                
                // Otherwise, save it as a fallback in case we find nothing better
                if (!bestResult) bestResult = result;
            }
        }

        return bestResult || { rate: 0, placed: 0, opted: 0, batchLabel: 'N/A' };

    } catch (err) {
        console.error('[api] getAcademicYearPlacementRate error:', err);
        return null;
    }
}

getAcademicYearPlacementRate().then(console.log);
