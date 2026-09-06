const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

let currentProcess = null;
let cancelled = false;

function checkDependencies() {
  const isWin = process.platform === 'win32';
  const isMac = process.platform === 'darwin';

  if (isWin) {
    try {
      execSync('winget --version', { stdio: 'pipe' });
      return { ready: true, message: 'WinGet encontrado e pronto para usar.', needsInstall: false };
    } catch {
      return { ready: false, message: 'WinGet não encontrado. Instale via Microsoft Store.', needsInstall: false };
    }
  }

  if (isMac) {
    try {
      execSync('brew --version', { stdio: 'pipe' });
      return { ready: true, message: 'Homebrew encontrado e pronto para usar.', needsInstall: false };
    } catch {
      return { ready: false, message: 'Homebrew não encontrado. Clique em Instalar Homebrew.', needsInstall: true };
    }
  }

  return { ready: true, message: 'Sistema pronto.', needsInstall: false };
}

function loadAppsCatalog() {
  try {
    const catalogPath = path.join(__dirname, '../assets/apps-catalog.json');
    return JSON.parse(fs.readFileSync(catalogPath, 'utf-8'));
  } catch (e) {
    console.error('Erro ao carregar catálogo:', e);
    return { categories: [] };
  }
}

async function installApps(selectedApps, onProgress, onError) {
  cancelled = false;
  const os = selectedApps[0]?.targetOS || 'win';

  onProgress(`\n📦 Iniciando instalação de ${selectedApps.length} app(s)...\n`);
  onProgress(`🖥️  Sistema alvo: ${os === 'win' ? 'Windows (WinGet)' : 'macOS (Homebrew)'}\n`);
  onProgress('─'.repeat(50) + '\n');

  if (os === 'win') {
    onProgress('🔄 Atualizando fontes do WinGet...\n');
    try {
      execSync('winget source update --disable-interactivity', { stdio: 'pipe', timeout: 60000 });
      onProgress('✅ Fontes atualizadas.\n');
    } catch {
      onProgress('⚠️  Não foi possível atualizar fontes (continuando).\n');
    }
    onProgress('─'.repeat(50) + '\n');
  }

  for (const app of selectedApps) {
    if (cancelled) {
      onProgress('\n⚠️  Instalação cancelada.\n');
      break;
    }
    await installOne(app, onProgress, onError);
  }

  if (!cancelled) {
    onProgress('\n' + '─'.repeat(50) + '\n');
    onProgress('✅ Processo finalizado!\n');
  }
}

function getBundledPath(filename) {
  // Em produção: pasta bundled ao lado do executável
  // Em dev: pasta bundled na raiz do projeto
  const appDir = require('electron').app
    ? require('path').dirname(require('electron').app.getPath('exe'))
    : path.join(__dirname, '../../');
  const candidates = [
    path.join(appDir, 'bundled', filename),
    path.join(__dirname, '../../bundled', filename),
  ];
  for (const p of candidates) {
    if (fs.existsSync(p)) return p;
  }
  return null;
}

function installOne(app, onProgress, onError) {
  return new Promise((resolve) => {
    const os = app.targetOS || 'win';
    let command, args;
    let output = '';

    onProgress(`\n📥 Instalando: ${app.name}\n`);

    // ── BUNDLED (instalador local) ──
    if (app.bundled) {
      const filename = os === 'win' ? app.bundledWin : app.bundledMac;
      if (!filename) {
        const note = app.macNote || `${app.name} não tem instalador automático para ${os === 'win' ? 'Windows' : 'macOS'}.`;
        onProgress(`\nⓘ  ${note}\n`);
        resolve(); return;
      }
      const installerPath = getBundledPath(filename);
      if (!installerPath) {
        onError(`❌ Instalador bundled não encontrado: ${filename}\n`);
        resolve(); return;
      }
      onProgress(`   Arquivo local: ${installerPath}\n`);
      if (os === 'win') {
        command = installerPath;
        // Flags silenciosas: /S para NSIS (ClickShare), /s /pEULA=1 para Kaspersky, /quiet para MSI
        const silentFlags = app.id === 'kaspersky'
          ? ['/s', '/pEULA=1', '/pKSN=0', '/pALLUSERS=1']
          : ['/S', '/norestart'];
        args = silentFlags;
      } else {
        // macOS: monta DMG, instala .pkg silenciosamente via osascript (1 popup de senha)
        // Se não tiver .pkg dentro, copia o .app para /Applications
        const script = [
          `set dmg to "${installerPath}"`,
          `do shell script "hdiutil attach " & quoted form of dmg & " -nobrowse -quiet" with administrator privileges`,
          `set vol to do shell script "ls /Volumes | tail -1"`,
          `set pkgPath to do shell script "find /Volumes/" & vol & " -name '*.pkg' 2>/dev/null | head -1"`,
          `if pkgPath is not "" then`,
          `  do shell script "installer -pkg " & quoted form of pkgPath & " -target / -verboseR" with administrator privileges`,
          `else`,
          `  set appPath to do shell script "find /Volumes/" & vol & " -name '*.app' -maxdepth 2 | head -1"`,
          `  do shell script "cp -R " & quoted form of appPath & " /Applications/" with administrator privileges`,
          `end if`,
          `do shell script "hdiutil detach /Volumes/" & vol & " -quiet" with administrator privileges`,
        ].join('\n');
        command = 'osascript';
        args = ['-e', script];
      }
      currentProcess = spawn(command, args, { stdio: ['pipe', 'pipe', 'pipe'] });
      currentProcess.stdout.on('data', d => { output += d.toString().toLowerCase(); onProgress(d.toString()); });
      currentProcess.stderr.on('data', d => { const m = d.toString(); output += m.toLowerCase(); if (m.trim()) onError(m); });
      currentProcess.on('close', (code) => {
        if (code === 0 || code === 1) onProgress(`✅ ${app.name} — instalador iniciado com sucesso!\n`);
        else if (!cancelled) onError(`❌ Erro ao instalar ${app.name} (código: ${code})\n`);
        currentProcess = null; resolve();
      });
      currentProcess.on('error', (e) => { onError(`❌ Erro: ${e.message}\n`); currentProcess = null; resolve(); });
      return;
    }

    // ── WINGET / HOMEBREW ──
    if (os === 'win') {
      command = 'powershell.exe';
      // MS Store IDs: alphanumeric without dots, e.g. 9NKSQGP7F2NH
      const isStoreId = /^[0-9][A-Z0-9]{9,}$/.test(app.wingetId);
      const src = isStoreId ? 'msstore' : 'winget';
      args = [
        '-NoProfile', '-NonInteractive', '-Command',
        `winget install --id "${app.wingetId}" -e --source ${src} --accept-package-agreements --accept-source-agreements --silent`
      ];
    } else {
      command = '/bin/bash';
      // homebrewFormula = true → fórmula (git, node, python); false/ausente → cask
      const brewCmd = app.homebrewFormula
        ? `brew install "${app.homebrewId}" --quiet 2>&1`
        : `brew install --cask "${app.homebrewId}" --quiet 2>&1`;
      args = ['-c', brewCmd];
    }

    const pkgId = os === 'win' ? app.wingetId : app.homebrewId;
    if (!pkgId) {
      onProgress(`\n⚠️  ${app.name} não está disponível para ${os === 'win' ? 'Windows' : 'macOS'}. Pulando.\n`);
      currentProcess = null;
      resolve();
      return;
    }

    onProgress(`   Pacote: ${pkgId}\n`);

    currentProcess = spawn(command, args, { stdio: ['pipe', 'pipe', 'pipe'] });

    currentProcess.stdout.on('data', (d) => {
      const text = d.toString();
      output += text.toLowerCase();
      onProgress(text);
    });

    currentProcess.stderr.on('data', (d) => {
      const msg = d.toString();
      output += msg.toLowerCase();
      if (msg.trim()) onError(msg);
    });

    currentProcess.on('close', (code) => {
      const alreadyOk = output.includes('already installed') ||
                        output.includes('no available upgrade') ||
                        output.includes('already up to date') ||
                        output.includes('já instalado') ||
                        output.includes('is already installed') ||
                        output.includes('already up-to-date');
      if (code === 0) {
        onProgress(`✅ ${app.name} instalado com sucesso!\n`);
      } else if (alreadyOk) {
        onProgress(`⚠️  ${app.name} já está instalado (versão mais recente).\n`);
      } else if (!cancelled) {
        onError(`❌ Erro ao instalar ${app.name} (código: ${code})\n`);
      }
      currentProcess = null;
      resolve();
    });

    currentProcess.on('error', (e) => {
      onError(`❌ Erro no processo: ${e.message}\n`);
      currentProcess = null;
      resolve();
    });
  });
}

function cancelInstallation() {
  cancelled = true;
  if (currentProcess) {
    try {
      if (process.platform === 'win32') {
        execSync(`taskkill /PID ${currentProcess.pid} /T /F`, { stdio: 'pipe' });
      } else {
        currentProcess.kill('SIGTERM');
      }
    } catch {}
    currentProcess = null;
  }
  return { success: true };
}

module.exports = {
  checkDependencies,
  loadAppsCatalog,
  installApps,
  cancelInstallation
};
