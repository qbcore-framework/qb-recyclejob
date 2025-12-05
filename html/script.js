// Recycle Job Ranking UI Script

const container = document.getElementById('ranking-container');
const playerLevel = document.getElementById('player-level');
const xpBar = document.getElementById('xp-bar');
const xpText = document.getElementById('xp-text');
const playerDeliveries = document.getElementById('player-deliveries');
const playerRank = document.getElementById('player-rank');
const rankingsList = document.getElementById('rankings-list');
const xpPopup = document.getElementById('xp-popup');
const levelupPopup = document.getElementById('levelup-popup');
const levelupLevel = document.getElementById('levelup-level');

// Format number with commas
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// Update player stats
function updatePlayerStats(data) {
    playerLevel.textContent = data.level || 1;
    playerDeliveries.textContent = formatNumber(data.totalDeliveries || 0);

    const currentXP = data.currentXP || 0;
    const xpForNext = data.xpForNextLevel || 100;
    const percentage = Math.min((currentXP / xpForNext) * 100, 100);

    xpBar.style.width = percentage + '%';
    xpText.textContent = formatNumber(currentXP) + ' / ' + formatNumber(xpForNext) + ' XP';

    if (data.rank && data.rank > 0) {
        playerRank.textContent = '#' + data.rank;
    } else {
        playerRank.textContent = '-';
    }
}

// Update rankings list
function updateRankings(rankings) {
    rankingsList.innerHTML = '';

    if (!rankings || rankings.length === 0) {
        rankingsList.innerHTML = '<div style="color: rgba(255,255,255,0.4); font-size: 0.7em; text-align: center; padding: 10px;">No rankings yet</div>';
        return;
    }

    rankings.forEach((player, index) => {
        const position = index + 1;
        const item = document.createElement('div');
        item.className = 'ranking-item';

        if (position === 1) item.classList.add('top-1');
        else if (position === 2) item.classList.add('top-2');
        else if (position === 3) item.classList.add('top-3');

        item.innerHTML = `
            <div class="ranking-position">${position}</div>
            <div class="ranking-info">
                <div class="ranking-name">${escapeHtml(player.name || 'Unknown')}</div>
                <div class="ranking-details">${formatNumber(player.total_deliveries || 0)} deliveries</div>
            </div>
            <div class="ranking-level">Lv.${player.level || 1}</div>
        `;

        rankingsList.appendChild(item);
    });
}

// Show XP gain popup
function showXPPopup(xpGained) {
    const popupText = xpPopup.querySelector('.xp-popup-text');
    popupText.textContent = '+' + formatNumber(xpGained) + ' XP';

    xpPopup.classList.remove('hidden');

    // Reset animation
    popupText.style.animation = 'none';
    popupText.offsetHeight; // Trigger reflow
    popupText.style.animation = 'xpFloat 1.5s ease-out forwards';

    setTimeout(() => {
        xpPopup.classList.add('hidden');
    }, 1500);
}

// Show level up popup
function showLevelUpPopup(level) {
    levelupLevel.textContent = 'Level ' + level;

    levelupPopup.classList.remove('hidden');

    // Reset animation
    const content = levelupPopup.querySelector('.levelup-content');
    content.style.animation = 'none';
    content.offsetHeight; // Trigger reflow
    content.style.animation = 'levelUpPop 2s ease-out forwards';

    setTimeout(() => {
        levelupPopup.classList.add('hidden');
    }, 2000);
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Show UI
function showUI() {
    container.classList.remove('hidden');
}

// Hide UI
function hideUI() {
    container.classList.add('hidden');
}

// Listen for NUI messages
window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.action) {
        case 'show':
            showUI();
            break;

        case 'hide':
            hideUI();
            break;

        case 'updatePlayer':
            updatePlayerStats({
                level: data.level,
                currentXP: data.currentXP,
                xpForNextLevel: data.xpForNextLevel,
                totalDeliveries: data.totalDeliveries,
                rank: data.rank
            });
            break;

        case 'updateRankings':
            updateRankings(data.rankings);
            break;

        case 'xpGain':
            showXPPopup(data.xpGained);
            updatePlayerStats({
                level: data.level,
                currentXP: data.currentXP,
                xpForNextLevel: data.xpForNextLevel,
                totalDeliveries: data.totalDeliveries
            });
            break;

        case 'levelUp':
            showLevelUpPopup(data.level);
            break;
    }
});

// Initialize - hidden by default
hideUI();
