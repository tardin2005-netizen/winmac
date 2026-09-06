# TESTAR_APPS.ps1
# Verifica todos os IDs de pacotes sem instalar nada

$ErrorActionPreference = 'SilentlyContinue'

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  WinMac - Verificador de Pacotes" -ForegroundColor Cyan
Write-Host "  Testando IDs sem instalar nada" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

$apps = @(
    # Navegadores
    @{cat="Navegadores";  name="Google Chrome";           id="Google.Chrome";                     store=$false},
    @{cat="Navegadores";  name="Mozilla Firefox";         id="Mozilla.Firefox";                   store=$false},
    @{cat="Navegadores";  name="Microsoft Edge";          id="Microsoft.Edge";                    store=$false},
    @{cat="Navegadores";  name="Brave Browser";           id="Brave.Brave";                       store=$false},
    # Acesso Remoto
    @{cat="Acesso Remoto"; name="AnyDesk";               id="AnyDesk.AnyDesk";                   store=$false},
    @{cat="Acesso Remoto"; name="TeamViewer";             id="TeamViewer.TeamViewer";             store=$false},
    @{cat="Acesso Remoto"; name="Zoom";                   id="Zoom.Zoom";                         store=$false},
    @{cat="Acesso Remoto"; name="ClickShare";             id="Barco.ClickShare";                  store=$false},
    @{cat="Acesso Remoto"; name="Remote Desktop";         id="Microsoft.RemoteDesktopClient";     store=$false},
    # Seguranca
    @{cat="Seguranca";    name="Kaspersky Free";          id="Kaspersky.KasperskyAntiVirus";      store=$false},
    @{cat="Seguranca";    name="Malwarebytes";            id="Malwarebytes.Malwarebytes";         store=$false},
    @{cat="Seguranca";    name="Bitwarden";               id="Bitwarden.Bitwarden";               store=$false},
    @{cat="Seguranca";    name="VeraCrypt";               id="IDRIX.VeraCrypt";                   store=$false},
    @{cat="Seguranca";    name="ExpressVPN";              id="ExpressVPN.ExpressVPN";             store=$false},
    # Produtividade
    @{cat="Produtividade"; name="Notion";                 id="Notion.Notion";                     store=$false},
    @{cat="Produtividade"; name="Slack";                  id="SlackTechnologies.Slack";           store=$false},
    @{cat="Produtividade"; name="Microsoft Teams";        id="Microsoft.Teams";                   store=$false},
    @{cat="Produtividade"; name="Discord";                id="Discord.Discord";                   store=$false},
    @{cat="Produtividade"; name="Telegram";               id="Telegram.TelegramDesktop";          store=$false},
    @{cat="Produtividade"; name="WhatsApp";               id="9NKSQGP7F2NH";                      store=$true},
    # Midia
    @{cat="Midia";        name="VLC Media Player";        id="VideoLAN.VLC";                      store=$false},
    @{cat="Midia";        name="Spotify";                 id="Spotify.Spotify";                   store=$false},
    @{cat="Midia";        name="GIMP";                    id="GIMP.GIMP";                         store=$false},
    @{cat="Midia";        name="Audacity";                id="Audacity.Audacity";                 store=$false},
    @{cat="Midia";        name="OBS Studio";              id="OBSProject.OBSStudio";              store=$false},
    # Utilitarios
    @{cat="Utilitarios";  name="7-Zip";                   id="7zip.7zip";                         store=$false},
    @{cat="Utilitarios";  name="CCleaner";                id="Piriform.CCleaner";                 store=$false},
    @{cat="Utilitarios";  name="Rufus";                   id="Rufus.Rufus";                       store=$false},
    @{cat="Utilitarios";  name="WinRAR";                  id="RARLab.WinRAR";                     store=$false},
    @{cat="Utilitarios";  name="Everything";              id="voidtools.Everything";              store=$false},
    @{cat="Utilitarios";  name="Notepad++";               id="Notepad++.Notepad++";               store=$false},
    # Dev Tools
    @{cat="Dev Tools";    name="Visual Studio Code";      id="Microsoft.VisualStudioCode";        store=$false},
    @{cat="Dev Tools";    name="Git";                     id="Git.Git";                           store=$false},
    @{cat="Dev Tools";    name="Docker Desktop";          id="Docker.DockerDesktop";              store=$false},
    @{cat="Dev Tools";    name="Node.js";                 id="OpenJS.NodeJS";                     store=$false},
    @{cat="Dev Tools";    name="Python 3";                id="Python.Python.3.12";                store=$false},
    @{cat="Dev Tools";    name="Postman";                 id="Postman.Postman";                   store=$false}
)

Write-Host "Atualizando fontes do WinGet..." -ForegroundColor Yellow
winget source update --disable-interactivity 2>&1 | Out-Null
Write-Host "Fontes atualizadas.`n" -ForegroundColor Green

$ok = 0
$fail = 0
$failed = @()
$currentCat = ""

foreach ($app in $apps) {
    if ($app.cat -ne $currentCat) {
        $currentCat = $app.cat
        Write-Host "`n  --- $currentCat ---" -ForegroundColor Cyan
    }

    $source = if ($app.store) { "msstore" } else { "winget" }
    $result = winget show --id $app.id -e --source $source 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [OK]     $($app.name)" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "    [FALHOU] $($app.name)  ($($app.id))" -ForegroundColor Red
        $fail++
        $failed += $app
    }
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  RESULTADO: $ok OK  |  $fail FALHARAM" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Yellow" })
Write-Host "============================================" -ForegroundColor Cyan

if ($failed.Count -gt 0) {
    Write-Host "`nPacotes com ID invalido ou nao disponivel no WinGet:" -ForegroundColor Red
    foreach ($app in $failed) {
        Write-Host "  - $($app.name): $($app.id)" -ForegroundColor Red
    }
    Write-Host "`nOpcoes:" -ForegroundColor Yellow
    Write-Host "  1) Verificar o ID correto em: https://winget.run" -ForegroundColor Yellow
    Write-Host "  2) Buscar manualmente: winget search <nome>" -ForegroundColor Yellow
    Write-Host "  3) Atualizar o arquivo apps-catalog.json com o ID correto" -ForegroundColor Yellow
}

Write-Host "`nPressione qualquer tecla para fechar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
