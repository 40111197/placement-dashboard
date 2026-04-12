/**
 * OSINT JOB AGGREGATOR FRONTEND LOGIC
 * Uses the shared Supabase client from supabase-client.js (window._sb)
 */

let currentJobs = [];
let filters = {
    domain: '',
    jobType: '',
    platform: '',
    sector: '',   // 'Govt' or 'Private' or ''
    search: ''
};

// INITIALIZATION
document.addEventListener('DOMContentLoaded', async () => {
    setupEventListeners();
    fetchJobs();
});

// FETCH JOBS FROM SUPABASE
async function fetchJobs() {
    const grid = document.getElementById('jobGrid');
    
    // Show loading state
    grid.innerHTML = '<div class="skeleton-card"></div><div class="skeleton-card"></div><div class="skeleton-card"></div>';

    try {
        // Use shared client from supabase-client.js
        if (window._sb) {
            let query = window._sb.from('jobs').select('*').order('created_at', { ascending: false });
            
            // Apply filtering
            if (filters.domain) query = query.eq('domain', filters.domain);
            if (filters.jobType) query = query.eq('job_type', filters.jobType);
            if (filters.platform) query = query.eq('platform', filters.platform);
            // Sector filter: Govt = 'Govt Portal', Private = everything else
            if (filters.sector === 'Govt') query = query.eq('platform', 'Govt Portal');
            else if (filters.sector === 'Private') query = query.neq('platform', 'Govt Portal');

            const { data, error } = await query;
            if (error) throw error;
            
            currentJobs = data || [];
            
            // Only show simulated data if DB has zero jobs
            if (currentJobs.length === 0) {
                currentJobs = getSimulatedData();
            }
        } else {
            // Supabase not ready, show simulated data
            currentJobs = getSimulatedData();
        }

        renderJobs(currentJobs);
        updateStats();

    } catch (e) {
        console.error("OSINT Fetch Error:", e);
        // Fallback to simulated data on any error
        currentJobs = getSimulatedData();
        renderJobs(currentJobs);
        updateStats();
        
        const grid = document.getElementById('jobGrid');
        if (grid) {
            grid.insertAdjacentHTML('afterbegin', `<div class="error-state" style="grid-column:1/-1;padding:15px;background:rgba(245,158,11,0.1);border-radius:8px;color:var(--accent-orange);margin-bottom:20px;border:1px solid rgba(245,158,11,0.2);display:flex;align-items:center;gap:12px;">
                <i class="bi bi-exclamation-triangle" style="font-size:1.2rem;"></i> 
                <div>
                    <strong>Intelligence Feed Offline:</strong> Connecting to secondary cache. Showing simulated opportunities.
                </div>
            </div>`);
        }
    }
}

// RENDER JOB CARDS
function renderJobs(jobs) {
    const grid = document.getElementById('jobGrid');
    const empty = document.getElementById('emptyState');
    
    // Search filtering (local client-side)
    const filtered = jobs.filter(j => {
        const searchText = (j.title + j.company + j.description).toLowerCase();
        return searchText.includes(filters.search.toLowerCase());
    });

    if (filtered.length === 0) {
        grid.innerHTML = '';
        empty.style.display = 'flex';
        return;
    }

    empty.style.display = 'none';
    grid.innerHTML = filtered.map(job => {
        const isGovt = job.platform === 'Govt Portal';
        const govtBadge = isGovt ? `<span class="govt-badge"><i class="bi bi-bank"></i> Govt</span>` : '';
        const cardClass = isGovt ? 'job-card govt-card' : 'job-card';
        const platformTag = isGovt
            ? `<span class="platform-tag govt-platform-tag"><i class="bi bi-bank"></i> ${job.platform}</span>`
            : `<span class="platform-tag">${job.platform}</span>`;

        return `
        <div class="${cardClass}" onclick="window.open('${job.apply_link}', '_blank')">
            <div class="job-card-header">
                <div class="company-logo${isGovt ? ' govt-logo' : ''}">${job.company[0]}</div>
                ${platformTag}
            </div>
            <div class="job-content">
                <h3 class="job-title">${job.title} ${govtBadge}</h3>
                <div class="job-company">${job.company}</div>
                <div class="job-meta">
                    <span><i class="bi bi-geo-alt"></i> ${job.location || 'Remote'}</span>
                    <span><i class="bi bi-clock"></i> ${job.job_type}</span>
                </div>
                <div class="job-tags">
                    <span class="tag domain">${job.domain}</span>
                    <span class="tag">${job.experience}</span>
                </div>
            </div>
            <div class="card-footer">
                <span class="posted-date">${formatDate(job.created_at)}</span>
                <button class="btn-primary btn-sm${isGovt ? ' btn-govt' : ''}">Apply <i class="bi bi-box-arrow-up-right"></i></button>
            </div>
        </div>
    `;
    }).join('');
}

// UPDATE FEED STATS
function updateStats() {
    const feedStats = document.getElementById('feedStats');
    if (!feedStats) return;
    
    const count = currentJobs.length;
    let label = 'Intelligence & Security';
    if (filters.sector === 'Govt') label = 'Government Sector';
    else if (filters.sector === 'Private') label = 'Private Sector';
    else if (filters.domain) label = filters.domain;
    else if (filters.jobType) label = filters.jobType + 's';
    feedStats.innerText = `Found ${count} active opportunities in ${label}`;
}

// EVENT LISTENERS
function setupEventListeners() {
    // Domain & Filter tab items
    document.querySelectorAll('.job-filter-tab').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            document.querySelectorAll('.job-filter-tab').forEach(i => i.classList.remove('active'));
            item.classList.add('active');

            const filterType = item.getAttribute('data-filter');
            // Reset all filters first
            filters.domain = '';
            filters.jobType = '';
            filters.sector = '';

            if (filterType === 'Internship') {
                filters.jobType = 'Internship';
            } else if (filterType === 'Fresher') {
                filters.jobType = 'Fresher';
            } else if (filterType === 'Govt') {
                filters.sector = 'Govt';
            } else if (filterType === 'Private') {
                filters.sector = 'Private';
            } else if (filterType !== '') {
                filters.domain = filterType;
            }
            fetchJobs();
        });
    });

    // Platform chips
    document.querySelectorAll('.chip').forEach(chip => {
        chip.addEventListener('click', () => {
            document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
            chip.classList.add('active');
            filters.platform = chip.getAttribute('data-platform');
            fetchJobs();
        });
    });

    // Search bar
    document.getElementById('jobSearch').addEventListener('input', (e) => {
        filters.search = e.target.value;
        renderJobs(currentJobs);
    });

    // Refresh button (OSINT Scrape Trigger + Supabase Fetch)
    document.getElementById('refreshBtn').addEventListener('click', async () => {
        const btn = document.getElementById('refreshBtn');
        const originalHtml = btn.innerHTML;
        
        btn.disabled = true;
        btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Intelligence Gathering...';
        
        try {
            // 1. Try to trigger backend scrape (best effort)
            try {
                const res = await fetch('/api/jobs/scrape', { method: 'POST' });
                if (res.ok) {
                    const result = await res.json();
                } else {
                    console.warn(`Scraper not available (${res.status}). Fetching from DB directly.`);
                }
            } catch (scrapeErr) {
                console.warn('Scraper unreachable. Fetching from DB directly.', scrapeErr);
            }
            
            // 2. Always fetch fresh data from Supabase regardless
            await fetchJobs();
            
        } finally {
            btn.disabled = false;
            btn.innerHTML = originalHtml;
        }
    });
}

// UTILITIES
function formatDate(isoString) {
    if (!isoString) return 'Recently';
    const date = new Date(isoString);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

function getSimulatedData() {
    return [
        {
            title: "Cyber Security Intern (SOC/SIEM)",
            company: "TechGuard Defense",
            platform: "LinkedIn",
            domain: "Cyber Security",
            location: "Remote",
            job_type: "Internship",
            experience: "Freshers",
            apply_link: "#",
            created_at: new Date().toISOString()
        },
        {
            title: "Trainee Crime Analyst",
            company: "Forensic Services India",
            platform: "Internshala",
            domain: "Criminology",
            location: "Bangalore",
            job_type: "Fresher",
            experience: "0-1 years",
            apply_link: "#",
            created_at: new Date().toISOString()
        },
        {
            title: "Digital Forensics Researcher",
            company: "Global Intelligence Agency",
            platform: "Indeed",
            domain: "Digital Forensics",
            location: "New Delhi",
            job_type: "Internship",
            experience: "Freshers",
            apply_link: "#",
            created_at: new Date().toISOString()
        }
    ];
}
