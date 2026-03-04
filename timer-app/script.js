/* ==========================================
   WORK TIMER APPLICATION
   Modern timer with leaderboard for week/month
   ========================================== */

class WorkTimer {
    constructor() {
        // Timer state
        this.totalSeconds = 0;
        this.isRunning = false;
        this.intervalId = null;

        // DOM Elements
        this.hoursEl = document.getElementById('hours');
        this.minutesEl = document.getElementById('minutes');
        this.secondsEl = document.getElementById('seconds');
        this.startBtn = document.getElementById('startBtn');
        this.pauseBtn = document.getElementById('pauseBtn');
        this.resetBtn = document.getElementById('resetBtn');
        this.saveSessionBtn = document.getElementById('saveSessionBtn');
        this.weekLeaderboard = document.getElementById('weekLeaderboard');
        this.monthLeaderboard = document.getElementById('monthLeaderboard');
        this.weekTotal = document.getElementById('weekTotal');
        this.monthTotal = document.getElementById('monthTotal');
        this.sessionCount = document.getElementById('sessionCount');

        // Tab buttons
        this.tabButtons = document.querySelectorAll('.tab-btn');

        // Storage
        this.storageKey = 'workTimerSessions';

        // User name
        this.userName = this.getUserName();

        // Initialize
        this.initEventListeners();
        this.loadSessions();
        this.updateStats();
    }

    /* ==========================================
       USER NAME MANAGEMENT
       ========================================== */

    getUserName() {
        let name = localStorage.getItem('timerUserName');
        if (!name) {
            name = prompt('Quel est ton nom?', 'Utilisateur') || 'Utilisateur';
            localStorage.setItem('timerUserName', name);
        }
        return name;
    }

    /* ==========================================
       EVENT LISTENERS
       ========================================== */

    initEventListeners() {
        // Timer buttons
        this.startBtn.addEventListener('click', () => this.start());
        this.pauseBtn.addEventListener('click', () => this.pause());
        this.resetBtn.addEventListener('click', () => this.reset());
        this.saveSessionBtn.addEventListener('click', () => this.saveSession());

        // Tab buttons
        this.tabButtons.forEach(btn => {
            btn.addEventListener('click', (e) => this.switchTab(e.target.closest('.tab-btn')));
        });
    }

    /* ==========================================
       TIMER CONTROLS
       ========================================== */

    start() {
        if (this.isRunning) return;

        this.isRunning = true;
        this.startBtn.disabled = true;
        this.pauseBtn.disabled = false;

        this.intervalId = setInterval(() => {
            this.totalSeconds++;
            this.updateDisplay();
        }, 1000);
    }

    pause() {
        this.isRunning = false;
        clearInterval(this.intervalId);

        this.startBtn.disabled = false;
        this.pauseBtn.disabled = true;
        this.saveSessionBtn.disabled = false;
    }

    reset() {
        this.isRunning = false;
        clearInterval(this.intervalId);
        this.totalSeconds = 0;

        this.updateDisplay();
        this.startBtn.disabled = false;
        this.pauseBtn.disabled = true;
        this.saveSessionBtn.disabled = true;
    }

    /* ==========================================
       DISPLAY UPDATES
       ========================================== */

    updateDisplay() {
        const hours = Math.floor(this.totalSeconds / 3600);
        const minutes = Math.floor((this.totalSeconds % 3600) / 60);
        const seconds = this.totalSeconds % 60;

        this.hoursEl.textContent = this.pad(hours);
        this.minutesEl.textContent = this.pad(minutes);
        this.secondsEl.textContent = this.pad(seconds);
    }

    pad(num) {
        return String(num).padStart(2, '0');
    }

    formatTime(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;

        if (hours > 0) {
            return `${hours}h ${minutes}m ${secs}s`;
        }
        return `${minutes}m ${secs}s`;
    }

    formatTimeShort(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);

        if (hours > 0) {
            return `${hours}h ${minutes}m`;
        }
        return `${minutes}m`;
    }

    /* ==========================================
       SESSION MANAGEMENT
       ========================================== */

    saveSession() {
        if (this.totalSeconds < 60) {
            alert('La session doit durer au moins 1 minute');
            return;
        }

        const session = {
            id: Date.now(),
            name: this.userName,
            seconds: this.totalSeconds,
            timestamp: new Date().toISOString(),
            date: new Date().toLocaleDateString('fr-FR', {
                weekday: 'short',
                month: 'short',
                day: 'numeric'
            })
        };

        // Get existing sessions
        let sessions = JSON.parse(localStorage.getItem(this.storageKey) || '[]');
        sessions.push(session);

        // Save to storage
        localStorage.setItem(this.storageKey, JSON.stringify(sessions));

        // Show confirmation
        this.showNotification(`✓ Session de ${this.formatTime(session.seconds)} enregistrée!`);

        // Reset timer
        this.reset();

        // Update leaderboards
        this.loadSessions();
    }

    showNotification(message) {
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--color-success);
            color: white;
            padding: 12px 20px;
            border-radius: var(--radius-md);
            font-weight: 600;
            z-index: 1000;
            animation: slideIn 0.3s ease;
            box-shadow: var(--shadow-lg);
        `;
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }

    /* ==========================================
       LEADERBOARD MANAGEMENT
       ========================================== */

    loadSessions() {
        const sessions = JSON.parse(localStorage.getItem(this.storageKey) || '[]');
        const now = new Date();

        // Get week and month sessions
        const weekSessions = this.getWeekSessions(sessions, now);
        const monthSessions = this.getMonthSessions(sessions, now);

        // Render leaderboards
        this.renderLeaderboard(this.weekLeaderboard, weekSessions);
        this.renderLeaderboard(this.monthLeaderboard, monthSessions);

        // Update stats
        this.updateStats();
    }

    getWeekSessions(sessions, now) {
        const weekAgo = new Date(now);
        weekAgo.setDate(weekAgo.getDate() - 7);

        return sessions
            .filter(s => new Date(s.timestamp) > weekAgo)
            .sort((a, b) => b.seconds - a.seconds);
    }

    getMonthSessions(sessions, now) {
        const monthAgo = new Date(now);
        monthAgo.setMonth(monthAgo.getMonth() - 1);

        return sessions
            .filter(s => new Date(s.timestamp) > monthAgo)
            .sort((a, b) => b.seconds - a.seconds);
    }

    renderLeaderboard(container, sessions) {
        if (sessions.length === 0) {
            container.innerHTML = `
                <div class="leaderboard-empty">
                    <p>Aucune session</p>
                    <span class="empty-icon">🏃</span>
                </div>
            `;
            return;
        }

        let html = '';
        sessions.forEach((session, index) => {
            const rank = index + 1;
            const rankClass = rank <= 3 ? `rank-${rank}` : 'rank-other';

            html += `
                <div class="leaderboard-item" data-id="${session.id}">
                    <div class="rank-badge ${rankClass}">${rank}</div>
                    <div class="item-content">
                        <div class="item-name">${session.name}</div>
                        <div class="item-date">${session.date}</div>
                    </div>
                    <div class="item-time">${this.formatTimeShort(session.seconds)}</div>
                </div>
            `;
        });

        container.innerHTML = html;

        // Add delete functionality
        container.querySelectorAll('.leaderboard-item').forEach(item => {
            item.addEventListener('contextmenu', (e) => {
                e.preventDefault();
                const id = parseInt(item.dataset.id);
                if (confirm('Supprimer cette session?')) {
                    this.deleteSession(id);
                }
            });
        });
    }

    deleteSession(id) {
        let sessions = JSON.parse(localStorage.getItem(this.storageKey) || '[]');
        sessions = sessions.filter(s => s.id !== id);
        localStorage.setItem(this.storageKey, JSON.stringify(sessions));
        this.loadSessions();
        this.showNotification('✓ Session supprimée');
    }

    switchTab(button) {
        // Update active tab
        this.tabButtons.forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');

        // Show corresponding leaderboard
        const tab = button.dataset.tab;
        this.weekLeaderboard.classList.toggle('hidden', tab !== 'week');
        this.monthLeaderboard.classList.toggle('hidden', tab !== 'month');
    }

    /* ==========================================
       STATISTICS
       ========================================== */

    updateStats() {
        const sessions = JSON.parse(localStorage.getItem(this.storageKey) || '[]');
        const now = new Date();

        const weekSessions = this.getWeekSessions(sessions, now);
        const monthSessions = this.getMonthSessions(sessions, now);

        // Calculate totals
        const weekTotal = weekSessions.reduce((sum, s) => sum + s.seconds, 0);
        const monthTotal = monthSessions.reduce((sum, s) => sum + s.seconds, 0);

        // Update display
        this.weekTotal.textContent = this.formatTimeShort(weekTotal);
        this.monthTotal.textContent = this.formatTimeShort(monthTotal);
        this.sessionCount.textContent = sessions.length;
    }
}

/* ==========================================
   INITIALIZE APP
   ========================================== */

document.addEventListener('DOMContentLoaded', () => {
    new WorkTimer();
});

/* ==========================================
   ADD MISSING ANIMATIONS
   ========================================== */

const style = document.createElement('style');
style.textContent = `
    @keyframes slideOut {
        from {
            opacity: 1;
            transform: translateX(0);
        }
        to {
            opacity: 0;
            transform: translateX(100%);
        }
    }
`;
document.head.appendChild(style);
