# INSTALAR_SEM_NODE.ps1
# Instalador com GUI usando PowerShell puro - nao precisa de Node.js ou Electron
# Funciona em qualquer Windows 10/11

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$apps = @(
    @{cat="Navegadores";   name="Google Chrome";        id="Google.Chrome";                  store=$false},
    @{cat="Navegadores";   name="Mozilla Firefox";      id="Mozilla.Firefox";                store=$false},
    @{cat="Navegadores";   name="Microsoft Edge";       id="Microsoft.Edge";                 store=$false},
    @{cat="Navegadores";   name="Brave Browser";        id="Brave.Brave";                    store=$false},
    @{cat="Acesso Remoto"; name="AnyDesk";              id="AnyDesk.AnyDesk";                store=$false},
    @{cat="Acesso Remoto"; name="TeamViewer";           id="TeamViewer.TeamViewer";          store=$false},
    @{cat="Acesso Remoto"; name="Zoom";                 id="Zoom.Zoom";                      store=$false},
    @{cat="Acesso Remoto"; name="ClickShare";           id="Barco.ClickShare";               store=$false},
    @{cat="Seguranca";     name="Kaspersky Free";       id="Kaspersky.KasperskyAntiVirus";   store=$false},
    @{cat="Seguranca";     name="Malwarebytes";         id="Malwarebytes.Malwarebytes";      store=$false},
    @{cat="Seguranca";     name="Bitwarden";            id="Bitwarden.Bitwarden";            store=$false},
    @{cat="Seguranca";     name="VeraCrypt";            id="IDRIX.VeraCrypt";                store=$false},
    @{cat="Produtividade"; name="Notion";               id="Notion.Notion";                  store=$false},
    @{cat="Produtividade"; name="Slack";                id="SlackTechnologies.Slack";        store=$false},
    @{cat="Produtividade"; name="Microsoft Teams";      id="Microsoft.Teams";               store=$false},
    @{cat="Produtividade"; name="Discord";              id="Discord.Discord";               store=$false},
    @{cat="Produtividade"; name="Telegram";             id="Telegram.TelegramDesktop";      store=$false},
    @{cat="Produtividade"; name="WhatsApp";             id="9NKSQGP7F2NH";                  store=$true},
    @{cat="Midia";         name="VLC Media Player";     id="VideoLAN.VLC";                  store=$false},
    @{cat="Midia";         name="Spotify";              id="Spotify.Spotify";               store=$false},
    @{cat="Midia";         name="OBS Studio";           id="OBSProject.OBSStudio";          store=$false},
    @{cat="Midia";         name="GIMP";                 id="GIMP.GIMP";                     store=$false},
    @{cat="Midia";         name="Audacity";             id="Audacity.Audacity";             store=$false},
    @{cat="Utilitarios";   name="7-Zip";                id="7zip.7zip";                     store=$false},
    @{cat="Utilitarios";   name="WinRAR";               id="RARLab.WinRAR";                 store=$false},
    @{cat="Utilitarios";   name="CCleaner";             id="Piriform.CCleaner";             store=$false},
    @{cat="Utilitarios";   name="Rufus";                id="Rufus.Rufus";                   store=$false},
    @{cat="Utilitarios";   name="Notepad++";            id="Notepad++.Notepad++";           store=$false},
    @{cat="Utilitarios";   name="Everything";           id="voidtools.Everything";          store=$false},
    @{cat="Dev Tools";     name="Visual Studio Code";   id="Microsoft.VisualStudioCode";    store=$false},
    @{cat="Dev Tools";     name="Git";                  id="Git.Git";                       store=$false},
    @{cat="Dev Tools";     name="Docker Desktop";       id="Docker.DockerDesktop";          store=$false},
    @{cat="Dev Tools";     name="Node.js";              id="OpenJS.NodeJS";                 store=$false},
    @{cat="Dev Tools";     name="Python 3";             id="Python.Python.3.12";            store=$false},
    @{cat="Dev Tools";     name="Postman";              id="Postman.Postman";               store=$false}
)

# ── Janela principal ──
$form = New-Object System.Windows.Forms.Form
$form.Text = "Universal Software Installer"
$form.Size = New-Object System.Drawing.Size(720, 620)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 247)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.MinimumSize = New-Object System.Drawing.Size(600, 500)

# Titulo
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Universal Software Installer"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(26,26,26)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true
$form.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Selecione os aplicativos que deseja instalar via WinGet"
$lblSub.ForeColor = [System.Drawing.Color]::Gray
$lblSub.Location = New-Object System.Drawing.Point(22, 42)
$lblSub.AutoSize = $true
$form.Controls.Add($lblSub)

# Barra de busca
$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Location = New-Object System.Drawing.Point(20, 70)
$txtSearch.Size = New-Object System.Drawing.Size(660, 24)
$txtSearch.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$txtSearch.ForeColor = [System.Drawing.Color]::Gray
$txtSearch.Text = "Pesquisar apps..."
$form.Controls.Add($txtSearch)

$txtSearch.Add_Enter({
    if ($txtSearch.Text -eq "Pesquisar apps...") {
        $txtSearch.Text = ""
        $txtSearch.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtSearch.Add_Leave({
    if ($txtSearch.Text -eq "") {
        $txtSearch.Text = "Pesquisar apps..."
        $txtSearch.ForeColor = [System.Drawing.Color]::Gray
    }
})

# Lista de checkboxes
$clb = New-Object System.Windows.Forms.CheckedListBox
$clb.Location = New-Object System.Drawing.Point(20, 105)
$clb.Size = New-Object System.Drawing.Size(660, 400)
$clb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$clb.CheckOnClick = $true
$clb.IntegralHeight = $false
$form.Controls.Add($clb)

# Preenche lista
$currentCat = ""
foreach ($app in $apps) {
    if ($app.cat -ne $currentCat) {
        $currentCat = $app.cat
        $clb.Items.Add("── $currentCat ──", $false) | Out-Null
    }
    $clb.Items.Add("  $($app.name)", $false) | Out-Null
}

# Impede selecionar cabecalhos de categoria
$clb.Add_ItemCheck({
    param($s, $e)
    $item = $clb.Items[$e.Index].ToString()
    if ($item.StartsWith("──")) { $e.NewValue = [System.Windows.Forms.CheckState]::Unchecked }
})

# Busca em tempo real
$txtSearch.Add_TextChanged({
    $q = $txtSearch.Text.Trim().ToLower()
    if ($q -eq "pesquisar apps...") { return }
    $clb.Items.Clear()
    $currentCat = ""
    if ($q -eq "") {
        foreach ($app in $apps) {
            if ($app.cat -ne $currentCat) { $currentCat = $app.cat; $clb.Items.Add("── $currentCat ──", $false) | Out-Null }
            $clb.Items.Add("  $($app.name)", $false) | Out-Null
        }
    } else {
        foreach ($app in $apps) {
            if ($app.name.ToLower().Contains($q) -or $app.id.ToLower().Contains($q) -or $app.cat.ToLower().Contains($q)) {
                $clb.Items.Add("  $($app.name)  [$($app.cat)]", $false) | Out-Null
            }
        }
    }
})

# Botoes
$btnAll = New-Object System.Windows.Forms.Button
$btnAll.Text = "Selecionar Todos"
$btnAll.Location = New-Object System.Drawing.Point(20, 518)
$btnAll.Size = New-Object System.Drawing.Size(130, 32)
$btnAll.FlatStyle = "Flat"
$form.Controls.Add($btnAll)
$btnAll.Add_Click({
    for ($i = 0; $i -lt $clb.Items.Count; $i++) {
        if (-not $clb.Items[$i].ToString().StartsWith("──")) { $clb.SetItemChecked($i, $true) }
    }
})

$btnNone = New-Object System.Windows.Forms.Button
$btnNone.Text = "Limpar"
$btnNone.Location = New-Object System.Drawing.Point(160, 518)
$btnNone.Size = New-Object System.Drawing.Size(80, 32)
$btnNone.FlatStyle = "Flat"
$form.Controls.Add($btnNone)
$btnNone.Add_Click({
    for ($i = 0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $false) }
})

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "INSTALAR"
$btnInstall.Location = New-Object System.Drawing.Point(560, 516)
$btnInstall.Size = New-Object System.Drawing.Size(120, 36)
$btnInstall.BackColor = [System.Drawing.Color]::FromArgb(10, 132, 255)
$btnInstall.ForeColor = [System.Drawing.Color]::White
$btnInstall.FlatStyle = "Flat"
$btnInstall.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnInstall.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnInstall)

$btnInstall.Add_Click({
    $selected = @()
    for ($i = 0; $i -lt $clb.Items.Count; $i++) {
        if ($clb.GetItemChecked($i)) {
            $label = $clb.Items[$i].ToString().Trim()
            # Remove sufixo [categoria] se presente (modo busca)
            $label = $label -replace '\s*\[.+\]$', ''
            $found = $apps | Where-Object { $_.name -eq $label }
            if ($found) { $selected += $found }
        }
    }

    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecione pelo menos um aplicativo.", "WinMac", "OK", "Warning")
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Instalar $($selected.Count) aplicativo(s)?`n`n" + ($selected | ForEach-Object { "  • $($_.name)" } | Out-String),
        "Confirmar instalacao", "YesNo", "Question"
    )
    if ($confirm -ne "Yes") { return }

    $form.Enabled = $false
    $btnInstall.Text = "Instalando..."

    # Abre console para output
    $console = New-Object System.Windows.Forms.Form
    $console.Text = "Log de Instalacao"
    $console.Size = New-Object System.Drawing.Size(700, 450)
    $console.StartPosition = "CenterScreen"
    $console.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 26)

    $rtb = New-Object System.Windows.Forms.RichTextBox
    $rtb.Dock = "Fill"
    $rtb.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 26)
    $rtb.ForeColor = [System.Drawing.Color]::FromArgb(212, 212, 212)
    $rtb.Font = New-Object System.Drawing.Font("Consolas", 10)
    $rtb.ReadOnly = $true
    $rtb.WordWrap = $false
    $console.Controls.Add($rtb)
    $console.Show()

    function Log($msg, $color) {
        $rtb.SelectionColor = if ($color) { $color } else { [System.Drawing.Color]::FromArgb(212,212,212) }
        $rtb.AppendText("$msg`n")
        $rtb.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()
    }

    Log "Atualizando fontes do WinGet..." ([System.Drawing.Color]::Yellow)
    winget source update --disable-interactivity 2>&1 | Out-Null
    Log "Fontes atualizadas.`n" ([System.Drawing.Color]::LightGreen)

    foreach ($app in $selected) {
        Log "Instalando: $($app.name)  [$($app.id)]" ([System.Drawing.Color]::Cyan)
        $src = if ($app.store) { "msstore" } else { "winget" }
        $output = winget install --id $app.id -e --source $src --accept-package-agreements --accept-source-agreements 2>&1
        $output | ForEach-Object { Log "  $_" $null }
        if ($LASTEXITCODE -eq 0) {
            Log "OK  $($app.name) instalado com sucesso!" ([System.Drawing.Color]::LightGreen)
        } elseif (($output -join " ").ToLower() -match "already installed|no available upgrade") {
            Log "JA INSTALADO  $($app.name) ja esta na versao mais recente." ([System.Drawing.Color]::Yellow)
        } else {
            Log "ERRO  Falha ao instalar $($app.name) (codigo: $LASTEXITCODE)" ([System.Drawing.Color]::Salmon)
        }
        Log "" $null
    }

    Log "Processo finalizado!" ([System.Drawing.Color]::LightGreen)
    $form.Enabled = $true
    $btnInstall.Text = "INSTALAR"
})

$form.ShowDialog() | Out-Null
