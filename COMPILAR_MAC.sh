#!/bin/bash
# WinMac - Compilar .dmg para macOS

cd "$(dirname "$0")"

echo "============================================"
echo "  WinMac - Gerando Instalador .DMG"
echo "============================================"
echo ""
echo "Este processo vai gerar o .dmg final."
echo "Pode demorar 2-5 minutos..."
echo ""

# Verifica Node.js
if ! command -v node &> /dev/null; then
    echo "[ERRO] Node.js não encontrado!"
    echo "Instale em: https://nodejs.org"
    exit 1
fi

# Instala dependências se necessário
if [ ! -d "node_modules" ]; then
    echo "[INFO] Instalando dependências..."
    npm install
    if [ $? -ne 0 ]; then
        echo "[ERRO] Falha ao instalar dependências!"
        exit 1
    fi
fi

# Remove build anterior
if [ -d "release" ]; then
    echo "[INFO] Removendo build anterior..."
    rm -rf release
fi

echo "[INFO] Compilando para macOS..."
echo ""

npm run build:mac

if [ $? -ne 0 ]; then
    echo ""
    echo "============================================"
    echo "  [ERRO] Falha na compilação!"
    echo "  Verifique as mensagens acima."
    echo "============================================"
    exit 1
fi

echo ""
echo "============================================"
echo "  [OK] COMPILAÇÃO CONCLUÍDA COM SUCESSO!"
echo "============================================"
echo ""
echo "Arquivos gerados em: release/"
ls release/*.dmg 2>/dev/null
echo ""

read -p "Abrir pasta release? (s/n): " abre
if [ "$abre" = "s" ] || [ "$abre" = "S" ]; then
    open release
fi
