const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  // Informações do sistema
  getOSInfo: () => ipcRenderer.invoke('get-os-info'),

  // Verificar dependências (Homebrew, WinGet)
  checkDependencies: () => ipcRenderer.invoke('check-dependencies'),

  // Carregar catálogo de aplicativos
  getAppsCatalog: () => ipcRenderer.invoke('get-apps-catalog'),

  // Instalar aplicativos selecionados
  installApps: (selectedApps) => ipcRenderer.invoke('install-apps', selectedApps),

  // Cancelar instalação em progresso
  cancelInstallation: () => ipcRenderer.invoke('cancel-installation'),

  // Listener para progresso da instalação
  onInstallProgress: (callback) => {
    ipcRenderer.on('install-progress', (event, data) => callback(data));
  },

  // Remover listener
  removeInstallProgressListener: () => {
    ipcRenderer.removeAllListeners('install-progress');
  }
});
