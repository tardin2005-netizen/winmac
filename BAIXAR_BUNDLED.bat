@echo off
setlocal
title WinMac - Baixar Instaladores

echo ============================================================
echo   WinMac - Download de Instaladores
echo ============================================================
echo.
echo Este script baixa os instaladores grandes do GitHub Releases.
echo.

set REPO=https://github.com/tardin2005-netizen/winmac/releases/download/v1-installers

if not exist bundled mkdir bundled

echo [1/4] Baixando Kaspersky para Windows...
curl -L --progress-bar -o "bundled\kaspersky-win.exe" "%REPO%/kaspersky-win.exe"
if errorlevel 1 (
    echo ERRO ao baixar kaspersky-win.exe
) else (
    echo OK: kaspersky-win.exe
)

echo.
echo [2/4] Baixando ClickShare para Windows...
curl -L --progress-bar -o "bundled\clickshare-win.exe" "%REPO%/clickshare-win.exe"
if errorlevel 1 (
    echo ERRO ao baixar clickshare-win.exe
) else (
    echo OK: clickshare-win.exe
)

echo.
echo [3/4] Baixando Kaspersky para Mac...
curl -L --progress-bar -o "bundled\kaspersky-mac.dmg" "%REPO%/kaspersky-mac.dmg"
if errorlevel 1 (
    echo ERRO ao baixar kaspersky-mac.dmg
) else (
    echo OK: kaspersky-mac.dmg
)

echo.
echo [4/4] Baixando ClickShare para Mac...
curl -L --progress-bar -o "bundled\clickshare-mac.dmg" "%REPO%/clickshare-mac.dmg"
if errorlevel 1 (
    echo ERRO ao baixar clickshare-mac.dmg
) else (
    echo OK: clickshare-mac.dmg
)

echo.
echo ============================================================
echo   Download concluido! Arquivos salvos em bundled\
echo ============================================================
echo.
pause
