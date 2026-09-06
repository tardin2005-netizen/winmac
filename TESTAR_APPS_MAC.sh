#!/bin/bash
# WinMac - Verificador de pacotes Homebrew (sem instalar)

cd "$(dirname "$0")"

echo ""
echo "============================================"
echo "  WinMac - Verificador de Pacotes (macOS)"
echo "  Testando IDs sem instalar nada"
echo "============================================"
echo ""

if ! command -v brew &> /dev/null; then
    echo "[ERRO] Homebrew não encontrado. Instale primeiro."
    exit 1
fi

OK=0
FALHOU=0

check() {
    local name=$1
    local id=$2
    local result
    result=$(brew info --cask "$id" 2>&1)
    if echo "$result" | grep -q "No available formula"; then
        echo "  [FALHOU] $name ($id)"
        ((FALHOU++))
    else
        echo "  [OK]     $name"
        ((OK++))
    fi
}

echo "  --- Navegadores ---"
check "Google Chrome"          "google-chrome"

echo ""
echo "  --- Acesso Remoto ---"
check "AnyDesk"                "anydesk"
check "Google Remote Desktop"  "chrome-remote-desktop-host"

echo ""
echo "  --- Segurança ---"
echo "  [BUNDLED] Kaspersky Endpoint Security (instalador local)"

echo ""
echo "  --- Produtividade ---"
check "WhatsApp"               "whatsapp"

echo ""
echo "  --- Mídia ---"
check "VLC Media Player"       "vlc"
check "GIMP"                   "gimp"

echo ""
echo "  --- Utilitários ---"
check "7-Zip (Keka)"           "keka"

echo ""
echo "  --- Dev Tools ---"
check "Visual Studio Code"     "visual-studio-code"
check "Docker Desktop"         "docker"
check "Postman"                "postman"
check "Git"                    "git"
check "Node.js"                "node"
check "Python 3"               "python"

echo ""
echo "============================================"
echo "  RESULTADO: $OK OK  |  $FALHOU FALHARAM"
echo "============================================"
echo ""
read -p "Pressione Enter para fechar..."
