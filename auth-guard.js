/**
 * auth-guard.js — Redirect unauthenticated users to login.
 * Load this as the FIRST script on any protected page.
 * Works with pure Supabase (no Flask backend).
 */
(function () {
    const user = localStorage.getItem('pd_user');
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    const publicPages = ['index.html', 'forgot-password.html', 'mfa.html', ''];

    if (!user && !publicPages.includes(currentPage)) {
        window.location.replace('index.html');
        return;
    }

    function populateUserInfo() {
        try {
            const u = JSON.parse(localStorage.getItem('pd_user') || '{}');
            const nameEl   = document.querySelector('.user-name');
            const roleEl   = document.querySelector('.user-role');
            const avatarEl = document.querySelector('.avatar');

            if (nameEl   && u.username) nameEl.textContent   = u.username;
            if (roleEl   && u.role)     roleEl.textContent   = u.role.charAt(0).toUpperCase() + u.role.slice(1);
            if (avatarEl && u.username) avatarEl.textContent = u.username.charAt(0).toUpperCase();

            const profileEl = document.querySelector('.user-profile');
            if (profileEl) {
                profileEl.style.cursor = 'pointer';
                profileEl.title = 'Click to logout';
                profileEl.onclick = function () {
                    if (confirm('Log out?')) {
                        localStorage.removeItem('pd_token');
                        localStorage.removeItem('pd_user');
                        window.location.href = 'index.html';
                    }
                };
            }
        } catch (e) { /* silent */ }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', populateUserInfo);
    } else {
        populateUserInfo();
    }
})();
