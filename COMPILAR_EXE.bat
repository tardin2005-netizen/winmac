@echo off
title WinMac - Compilando .EXE
color 0E
cls

echo ============================================
echo   WinMac - Gerando Instalador .EXE
echo ============================================
echo.
echo Este processo vai gerar o .exe final que
echo o usuario vai instalar no computador.
echo.
echo Pode demorar 2-5 minutos...
echo.

:: Verifica Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Node.js nao encontrado!
    echo Instale em: https://nodejs.org
    pause
    exit /b 1
)

:: Instala dependencias se necessario
if not exist "node_modules" (
    echo [INFO] Instalando dependencias...
    npm install
    if errorlevel 1 (
        echo [ERRO] Falha ao instalar dependencias!
        pause
        exit /b 1
    )
)

:: Remove build anterior se existir
if exist "release" (
    echo [INFO] Removendo build anterior...
    rmdir /s /q release
)

echo [INFO] Compilando aplicativo...
echo.

npm run build:win

if errorlevel 1 (
    echo.
    echo ============================================
    echo   [ERRO] Falha na compilacao!
    echo   Verifique as mensagens acima.
    echo ============================================
    pause
    exit /b 1
)

echo.
echo ============================================
echo   [OK] COMPILACAO CONCLUIDA COM SUCESSO!
echo ============================================
echo.
echo Os arquivos estao na pasta: release\
echo.
echo Arquivos gerados:
dir release\*.exe /b 2>nul
echo.
echo Abrir pasta release?
set /p abre="Digite S para abrir ou N para fechar: "
if /i "%abre%"=="S" (
    explorer release
)

pause
