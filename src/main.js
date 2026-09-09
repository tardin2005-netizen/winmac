const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const installer = require('./utils/installer');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1000,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false
    },
    icon: path.join(__dirname, 'assets/icon.png')
  });

  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  if (process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// Eventos IPC do instalador
ipcMain.handle('get-os-info', () => {
  return {
    platform: process.platform, // 'win32' ou 'darwin'
    isWindows: process.platform === 'win32',
    isMac: process.platform === 'darwin'
  };
});

ipcMain.handle('check-dependencies', async () => {
  return await installer.checkDependencies();
});

ipcMain.handle('get-apps-catalog', async () => {
  return await installer.loadAppsCatalog();
});

ipcMain.handle('install-apps', async (event, selectedApps) => {
  return new Promise((resolve) => {
    let output = '';
    let errorOutput = '';

    // Listener para receber mensagens do processo de instalação
    const onInstallProgress = (data) => {
      output += data;
      mainWindow.webContents.send('install-progress', {
        type: 'stdout',
        data: data.toString()
      });
    };

    const onInstallError = (data) => {
      errorOutput += data;
      mainWindow.webContents.send('install-progress', {
        type: 'stderr',
        data: data.toString()
      });
    };

    installer.installApps(selectedApps, onInstallProgress, onInstallError)
      .then(() => {
        resolve({
          success: true,
          output,
          errorOutput,
          message: 'Instalação concluída com sucesso!'
        });
      })
      .catch((error) => {
        resolve({
          success: false,
          output,
          errorOutput,
          message: `Erro durante instalação: ${error.message}`
        });
      });
  });
});

ipcMain.handle('cancel-installation', async () => {
  installer.cancelInstallation();
  return { success: true };
});

ipcMain.handle('open-termo', () => {
  const termoWindow = new BrowserWindow({
    width: 820,
    height: 700,
    minWidth: 600,
    minHeight: 500,
    title: 'Termo de Responsabilidade',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });
  termoWindow.loadFile(path.join(__dirname, 'assets/termo.html'));
  termoWindow.setMenuBarVisibility(false);
  return { success: true };
});

// Inicializar app
app.on('ready', createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

module.exports = { mainWindow };
