@echo off
title WinMac - Iniciando...
color 0A
cls

:: Verifica se ja esta rodando como admin
net session >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d ""%~dp0"" && ""%~f0""' -Verb RunAs"
    exit /b
)

:: A partir daqui esta rodando como admin
cd /d "%~dp0"

echo ============================================
echo   WinMac - Iniciando Aplicativo (Admin)
echo ============================================
echo.

:: Verifica se Node.js esta instalado
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Node.js nao encontrado!
    echo Por favor instale o Node.js em: https://nodejs.org
    pause
    exit /b 1
)

echo [OK] Node.js encontrado:
node --version
echo.

:: Verifica se as dependencias estao instaladas
if not exist "node_modules" (
    echo [INFO] Instalando dependencias...
    npm install
    if errorlevel 1 (
        echo [ERRO] Falha ao instalar dependencias!
        pause
        exit /b 1
    )
    echo [OK] Dependencias instaladas!
    echo.
) else (
    echo [OK] Dependencias ja instaladas.
    echo.
)

echo [INFO] Iniciando WinMac...
echo ============================================
echo   Aguarde a janela do app abrir...
echo ============================================
echo.

npm start

pause
