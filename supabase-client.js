/**
 * supabase-client.js
 * ─────────────────────────────────────────────────────────────────────────────
 * Central Supabase configuration for the Placement Dashboard.
 *
 * HOW TO MOVE TO A NEW HOST:
 *   1. Copy all HTML/CSS/JS files to the new location.
 *   2. Edit ONLY this file — update SUPABASE_URL and SUPABASE_ANON_KEY.
 *   3. Done. The entire app will work from any static host.
 *
 * SUPABASE PROJECT: https://supabase.com/dashboard/project/rnuuhgiqymukzojiflry
 * ─────────────────────────────────────────────────────────────────────────────
 */

const SUPABASE_URL      = 'https://rnuuhgiqymukzojiflry.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJudXVoZ2lxeW11a3pvamlmbHJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NDEzMDUsImV4cCI6MjA5MDUxNzMwNX0.IeKHzPrc4Hlz5_jjHUfy_crdavE38sI-IRkwuO9ES84';

// Create the singleton Supabase client.
// The supabase-js CDN must be loaded BEFORE this file.
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Make it globally available
window._sb = sb;
