// ── Estado ──────────────────────────────────────
const state = {
  currentOS: 'win',
  currentCat: null,
  catalog: [],
  selected: new Set(),   // Set de app.id
  installing: false
};

// Emojis por categoria
const CAT_ICONS = {
  browsers:     '🌐',
  remote:       '🖥️',
  security:     '🔒',
  productivity: '📊',
  media:        '🎬',
  utilities:    '🛠️',
  'dev-tools':  '⚒️'
};

// Emojis por app
const APP_ICONS = {
  chrome: '🌐', firefox: '🦊', edge: '🌀', brave: '🦁',
  anydesk: '🖥️', teamviewer: '🔗', zoom: '📹', clickshare: '📡', rdp: '🖧',
  kaspersky: '🛡️', malwarebytes: '🔬', bitwarden: '🔑', veracrypt: '🔐', 'vpn-express': '🌐',
  notion: '📝', slack: '💬', teams: '💼', discord: '🎮', telegram: '✈️', whatsapp: '💬',
  vlc: '🎬', spotify: '🎵', gimp: '🎨', audacity: '🎙️', obs: '🎥',
  '7zip': '📦', winrar: '🗜️', ccleaner: '🧹', rufus: '💾', everything: '🔍', notepadpp: '📄',
  vscode: '💻', git: '🔀', docker: '🐳', nodejs: '🟢', python: '🐍', postman: '📡'
};

// ── Helpers ─────────────────────────────────────
const CATALOG_FALLBACK = {"categories":[{"id":"browsers","name":"Navegadores","apps":[{"id":"chrome","name":"Google Chrome","description":"Google LLC","wingetId":"Google.Chrome","homebrewId":"google-chrome"},{"id":"firefox","name":"Mozilla Firefox","description":"Mozilla Corporation","wingetId":"Mozilla.Firefox","homebrewId":"firefox"},{"id":"edge","name":"Microsoft Edge","description":"Microsoft Corporation","wingetId":"Microsoft.Edge","homebrewId":"microsoft-edge"},{"id":"brave","name":"Brave Browser","description":"Brave Software Inc","wingetId":"BraveSoftware.BraveBrowser","homebrewId":"brave-browser"}]},{"id":"remote","name":"Acesso Remoto","apps":[{"id":"anydesk","name":"AnyDesk","description":"AnyDesk Software GmbH","wingetId":"AnyDeskSoftwareGmbH.AnyDesk","homebrewId":"anydesk"},{"id":"teamviewer","name":"TeamViewer","description":"TeamViewer GmbH","wingetId":"TeamViewer.TeamViewer","homebrewId":"teamviewer"},{"id":"zoom","name":"Zoom","description":"Zoom Video Communications","wingetId":"Zoom.Zoom","homebrewId":"zoom"},{"id":"clickshare","name":"ClickShare App","description":"Barco","wingetId":"Barco.ClickShare","homebrewId":"clickshare"},{"id":"rdp","name":"Microsoft Remote Desktop","description":"Microsoft Corporation","wingetId":"Microsoft.RemoteDesktopClient","homebrewId":"microsoft-remote-desktop"}]},{"id":"security","name":"Segurança & Antivírus","apps":[{"id":"kaspersky","name":"Kaspersky Antivirus","description":"Kaspersky Lab","wingetId":"Kaspersky.KasperskyFree","homebrewId":"kaspersky-security-cloud"},{"id":"malwarebytes","name":"Malwarebytes","description":"Malwarebytes Inc","wingetId":"Malwarebytes.Malwarebytes","homebrewId":"malwarebytes"},{"id":"bitwarden","name":"Bitwarden","description":"Bitwarden Inc","wingetId":"Bitwarden.Bitwarden","homebrewId":"bitwarden"},{"id":"veracrypt","name":"VeraCrypt","description":"IDRIX","wingetId":"IDRIX.VeraCrypt","homebrewId":"veracrypt"},{"id":"vpn-express","name":"ExpressVPN","description":"ExpressVPN International Ltd","wingetId":"ExpressVPN.ExpressVPN","homebrewId":"expressvpn"}]},{"id":"productivity","name":"Produtividade","apps":[{"id":"notion","name":"Notion","description":"Notion Labs Inc","wingetId":"Notion.Notion","homebrewId":"notion"},{"id":"slack","name":"Slack","description":"Salesforce, Inc","wingetId":"SlackTechnologies.Slack","homebrewId":"slack"},{"id":"teams","name":"Microsoft Teams","description":"Microsoft Corporation","wingetId":"Microsoft.Teams","homebrewId":"microsoft-teams"},{"id":"discord","name":"Discord","description":"Discord Inc","wingetId":"Discord.Discord","homebrewId":"discord"},{"id":"telegram","name":"Telegram Desktop","description":"Telegram FZ-LLC","wingetId":"Telegram.TelegramDesktop","homebrewId":"telegram"},{"id":"whatsapp","name":"WhatsApp","description":"WhatsApp LLC","wingetId":"9NKSQGP7F2NH","homebrewId":"whatsapp"}]},{"id":"media","name":"Mídia & Multimídia","apps":[{"id":"vlc","name":"VLC Media Player","description":"VideoLAN","wingetId":"VideoLAN.VLC","homebrewId":"vlc"},{"id":"spotify","name":"Spotify","description":"Spotify AB","wingetId":"Spotify.Spotify","homebrewId":"spotify"},{"id":"gimp","name":"GIMP","description":"The GIMP Team","wingetId":"GNOME.GIMP","homebrewId":"gimp"},{"id":"audacity","name":"Audacity","description":"Audacity Team","wingetId":"AudacityTeam.Audacity","homebrewId":"audacity"},{"id":"obs","name":"OBS Studio","description":"OBS Project","wingetId":"OBSProject.OBSStudio","homebrewId":"obs"}]},{"id":"utilities","name":"Utilitários","apps":[{"id":"7zip","name":"7-Zip","description":"Igor Pavlov","wingetId":"7zip.7zip","homebrewId":"keka"},{"id":"ccleaner","name":"CCleaner","description":"Piriform Software Ltd","wingetId":"Piriform.CCleaner","homebrewId":"ccleaner"},{"id":"rufus","name":"Rufus","description":"Pete Batard","wingetId":"pbatard.rufus","homebrewId":"balena-etcher"},{"id":"winrar","name":"WinRAR","description":"RARLab","wingetId":"RARLab.WinRAR","homebrewId":"the-unarchiver"},{"id":"everything","name":"Everything","description":"voidtools","wingetId":"voidtools.Everything","homebrewId":"mlocate"},{"id":"notepadpp","name":"Notepad++","description":"Don Ho","wingetId":"Notepad++.Notepad++","homebrewId":"notepadplusplus"}]},{"id":"dev-tools","name":"Dev Tools","apps":[{"id":"vscode","name":"Visual Studio Code","description":"Microsoft Corporation","wingetId":"Microsoft.VisualStudioCode","homebrewId":"visual-studio-code"},{"id":"git","name":"Git","description":"The Git Development Community","wingetId":"Git.Git","homebrewId":"git"},{"id":"docker","name":"Docker Desktop","description":"Docker Inc","wingetId":"Docker.DockerDesktop","homebrewId":"docker"},{"id":"nodejs","name":"Node.js","description":"OpenJS Foundation","wingetId":"OpenJS.NodeJS","homebrewId":"node"},{"id":"python","name":"Python 3","description":"Python Software Foundation","wingetId":"Python.Python.3.12","homebrewId":"python"},{"id":"postman","name":"Postman","description":"Postman Inc","wingetId":"Postman.Postman","homebrewId":"postman"}]}]};

async function getCatalog() {
  if (window.api) return window.api.getAppsCatalog();
  try {
    const r = await fetch('./assets/apps-catalog.json');
    if (r.ok) return r.json();
  } catch {}
  return CATALOG_FALLBACK;
}

function hasApi() { return !!window.api; }

// ── Init ────────────────────────────────────────
async function init() {
  try {
    const catalog = await getCatalog();
    state.catalog = catalog.categories || [];
  } catch (e) {
    console.error('Catálogo não encontrado', e);
    state.catalog = [];
  }

  renderSidebar();
  if (state.catalog.length) selectCat(state.catalog[0].id);

  if (hasApi()) window.api.onInstallProgress(onProgress);
}

// ── Sidebar ─────────────────────────────────────
function renderSidebar() {
  const el = document.getElementById('sidebarCats');
  el.innerHTML = '';

  state.catalog.forEach(cat => {
    const selCount = cat.apps.filter(a => state.selected.has(a.id)).length;
    const div = document.createElement('div');
    div.className = 'cat-item' + (cat.id === state.currentCat ? ' active' : '');
    div.dataset.id = cat.id;
    div.innerHTML = `
      <div class="cat-icon">${CAT_ICONS[cat.id] || '📦'}</div>
      <span class="cat-name">${cat.name.replace(/^.+?\s/, '')}</span>
      <span class="cat-count">${selCount > 0 ? selCount : cat.apps.length}</span>
    `;
    div.onclick = () => selectCat(cat.id);
    el.appendChild(div);
  });
}

// ── Select category ──────────────────────────────
function selectCat(id) {
  state.currentCat = id;
  document.querySelectorAll('.cat-item').forEach(el =>
    el.classList.toggle('active', el.dataset.id === id));

  const cat = state.catalog.find(c => c.id === id);
  if (cat) renderApps(cat);
}

// ── App list ─────────────────────────────────────
function renderApps(cat) {
  const el = document.getElementById('appList');
  el.innerHTML = '';

  cat.apps.forEach(app => {
    const isSelected = state.selected.has(app.id);
    const pkgId = state.currentOS === 'win' ? app.wingetId : app.homebrewId;

    const row = document.createElement('div');
    row.className = 'app-row' + (isSelected ? ' selected' : '');
    row.dataset.id = app.id;

    row.innerHTML = `
      <input type="checkbox" class="app-chk" data-id="${app.id}" ${isSelected ? 'checked' : ''}>
      <div class="app-logo">${APP_ICONS[app.id] || CAT_ICONS[cat.id] || '📦'}</div>
      <div class="app-meta">
        <div class="app-name">${app.name}</div>
        <div class="app-sub">${app.description}</div>
      </div>
      <div class="app-version">${pkgId ? pkgId.split('.').pop() : '—'}</div>
    `;

    const chk = row.querySelector('.app-chk');
    chk.addEventListener('change', e => {
      e.stopPropagation();
      toggleApp(app.id, chk.checked, row);
    });
    row.addEventListener('click', e => {
      if (e.target === chk) return;
      chk.checked = !chk.checked;
      toggleApp(app.id, chk.checked, row);
    });

    el.appendChild(row);
  });
}

// ── Toggle app ───────────────────────────────────
function toggleApp(id, on, rowEl) {
  if (on) state.selected.add(id);
  else state.selected.delete(id);
  rowEl.classList.toggle('selected', on);
  updateBottomBar();
  renderSidebar();
  // Reativar categoria atual
  document.querySelectorAll('.cat-item').forEach(el =>
    el.classList.toggle('active', el.dataset.id === state.currentCat));
}

// ── Select/Deselect helpers ───────────────────────
function selectAllCurrent() {
  const cat = state.catalog.find(c => c.id === state.currentCat);
  if (!cat) return;
  cat.apps.forEach(a => state.selected.add(a.id));
  renderApps(cat);
  updateBottomBar();
  renderSidebar();
  document.querySelectorAll('.cat-item').forEach(el =>
    el.classList.toggle('active', el.dataset.id === state.currentCat));
}

function deselectAll() {
  state.selected.clear();
  const cat = state.catalog.find(c => c.id === state.currentCat);
  if (cat) renderApps(cat);
  updateBottomBar();
  renderSidebar();
  document.querySelectorAll('.cat-item').forEach(el =>
    el.classList.toggle('active', el.dataset.id === state.currentCat));
}

// ── OS Toggle ────────────────────────────────────
function selectOS(os) {
  state.currentOS = os;
  document.getElementById('btnWin').classList.toggle('active', os === 'win');
  document.getElementById('btnMac').classList.toggle('active', os === 'mac');
  const cat = state.catalog.find(c => c.id === state.currentCat);
  if (cat) renderApps(cat);
}

// ── Bottom bar ───────────────────────────────────
function updateBottomBar() {
  const n = state.selected.size;
  const btn = document.getElementById('installBtn');
  const title = document.getElementById('installTitle');
  const sub = document.getElementById('installSub');

  btn.disabled = n === 0 || state.installing;

  if (n === 0) {
    title.textContent = 'Selecione apps para instalar';
    sub.textContent = 'Nenhum selecionado';
  } else {
    const mins = Math.max(3, n * 2);
    title.textContent = `INSTALL (${n} ${n === 1 ? 'item' : 'itens'} selected)`;
    sub.textContent = `Dynamic install time: ${mins}min`;
  }
}

// ── Install ──────────────────────────────────────
async function startInstall() {
  if (state.installing || state.selected.size === 0) return;

  const apps = [];
  state.catalog.forEach(cat =>
    cat.apps.forEach(app => {
      if (state.selected.has(app.id)) apps.push({ ...app, targetOS: state.currentOS });
    })
  );

  state.installing = true;
  document.getElementById('installBtn').disabled = true;
  document.getElementById('installBtn').querySelector('.install-btn-title').textContent = '⏳ Instalando...';
  document.getElementById('cancelBtn').style.display = 'block';

  openConsole();
  log(`🚀 Instalando ${apps.length} app(s) — ${state.currentOS === 'win' ? 'Windows' : 'macOS'}`, 'info');
  log('─'.repeat(48), 'info');
  document.getElementById('progressRow').style.display = 'block';

  const result = hasApi()
    ? await window.api.installApps(apps)
    : await new Promise(r => setTimeout(() => r({ success: true, message: 'Simulado' }), 2000));

  state.installing = false;
  document.getElementById('cancelBtn').style.display = 'none';
  document.getElementById('progressRow').style.display = 'none';
  document.getElementById('progressFill').style.width = '0%';
  updateBottomBar();

  log('─'.repeat(48), result.success ? 'success' : 'error');
  log(result.success ? '✅ Instalação concluída!' : '❌ ' + result.message,
      result.success ? 'success' : 'error');
}

async function cancelInstall() {
  if (hasApi()) await window.api.cancelInstallation();
  log('⚠️ Cancelado pelo usuário.', 'warn');
}

// ── Console ──────────────────────────────────────
function openConsole() {
  document.getElementById('consoleOverlay').classList.add('open');
}

function closeConsole() {
  document.getElementById('consoleOverlay').classList.remove('open');
}

let pct = 0;
function onProgress(data) {
  const text = data.data.trim();
  if (!text) return;
  log(text, data.type === 'stderr' ? 'error' : 'log');
  pct = Math.min(pct + 2, 94);
  document.getElementById('progressFill').style.width = pct + '%';
  document.getElementById('progressText').textContent = `Instalando... ${pct}%`;
}

function log(msg, type = 'log') {
  const out = document.getElementById('consoleOutput');
  const div = document.createElement('div');
  div.className = 'log-line ' + type;
  div.textContent = msg;
  out.appendChild(div);
  out.scrollTop = out.scrollHeight;
}

// ── Start ─────────────────────────────────────────
document.addEventListener('DOMContentLoaded', init);
