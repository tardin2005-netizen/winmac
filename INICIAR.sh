#!/bin/bash
# WinMac - Script de inicialização para macOS

cd "$(dirname "$0")"

echo "============================================"
echo "  WinMac - Iniciando Aplicativo"
echo "============================================"
echo ""

# Verifica Node.js
if ! command -v node &> /dev/null; then
    echo "[ERRO] Node.js não encontrado!"
    echo "Instale em: https://nodejs.org"
    read -p "Pressione Enter para fechar..."
    exit 1
fi

echo "[OK] Node.js encontrado: $(node --version)"
echo ""

# Verifica Homebrew (necessário para instalar apps no Mac)
if ! command -v brew &> /dev/null; then
    echo "[INFO] Homebrew não encontrado. Instalando..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo ""
fi

# Instala dependências se necessário
if [ ! -d "node_modules" ]; then
    echo "[INFO] Instalando dependências pela primeira vez..."
    npm install
    if [ $? -ne 0 ]; then
        echo "[ERRO] Falha ao instalar dependências!"
        read -p "Pressione Enter para fechar..."
        exit 1
    fi
    echo "[OK] Dependências instaladas!"
    echo ""
else
    echo "[OK] Dependências já instaladas."
    echo ""
fi

# Pede senha de admin uma única vez para cachear o sudo
echo "[INFO] Solicitando permissão de administrador..."
sudo -v
if [ $? -ne 0 ]; then
    echo "[AVISO] Sem permissão de admin — instaladores bundled podem pedir senha individualmente."
fi
echo ""

echo "[INFO] Iniciando WinMac..."
echo "============================================"
echo "  Aguarde a janela do app abrir..."
echo "============================================"
echo ""

npm start
