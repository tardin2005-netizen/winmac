#!/bin/bash
echo "============================================================"
echo "  WinMac - Download de Instaladores"
echo "============================================================"
echo ""
echo "Este script baixa os instaladores grandes do GitHub Releases."
echo ""

REPO="https://github.com/tardin2005-netizen/winmac/releases/download/v1-installers"

mkdir -p bundled

echo "[1/3] Baixando Kaspersky para Mac..."
curl -L --progress-bar -o "bundled/kaspersky-mac.dmg" "$REPO/kaspersky-mac.dmg" && echo "OK: kaspersky-mac.dmg" || echo "ERRO ao baixar kaspersky-mac.dmg"

echo ""
echo "[2/3] Baixando ClickShare para Mac..."
curl -L --progress-bar -o "bundled/clickshare-mac.dmg" "$REPO/clickshare-mac.dmg" && echo "OK: clickshare-mac.dmg" || echo "ERRO ao baixar clickshare-mac.dmg"

echo ""
echo "[3/3] Baixando Google Remote Desktop para Mac..."
curl -L --progress-bar -o "bundled/chrome-remote-desktop-mac.dmg" "$REPO/chrome-remote-desktop-mac.dmg" && echo "OK: chrome-remote-desktop-mac.dmg" || echo "ERRO ao baixar chrome-remote-desktop-mac.dmg"

echo ""
echo "============================================================"
echo "  Download concluido! Arquivos salvos em bundled/"
echo "============================================================"
