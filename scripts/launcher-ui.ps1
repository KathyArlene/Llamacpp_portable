param(
    [switch]$SelfTest
)

$ErrorActionPreference = "Stop"

function Get-ProjectRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Test-PortableDeps {
    param([string]$ProjectRoot)

    $checks = @(
        @{ Name = "llama-server"; Path = (Join-Path $ProjectRoot "tools\llama\llama-server.exe") },
        @{ Name = "models.ini"; Path = (Join-Path $ProjectRoot "models\models.ini") },
        @{ Name = "qwen3-8b-q8"; Path = (Join-Path $ProjectRoot "models\Qwen3-8B-Q8_0.gguf") },
        @{ Name = "qwen3-vl-4b-q4"; Path = (Join-Path $ProjectRoot "models\Qwen3VL-4B-Instruct-Q4_K_M.gguf") },
        @{ Name = "qwen3-vl-mmproj"; Path = (Join-Path $ProjectRoot "models\mmproj-Qwen3VL-4B-Instruct-F16.gguf") }
    )

    $results = foreach ($item in $checks) {
        [PSCustomObject]@{
            Name = $item.Name
            Path = $item.Path
            Exists = (Test-Path $item.Path)
        }
    }

    $ok = -not ($results.Exists -contains $false)
    return [PSCustomObject]@{
        Ok = $ok
        Items = $results
    }
}

$projectRoot = Get-ProjectRoot

if ($SelfTest) {
    $state = Test-PortableDeps -ProjectRoot $projectRoot
    $state.Items | ForEach-Object {
        $flag = if ($_.Exists) { "[OK]" } else { "[MISS]" }
        Write-Host ($flag + " " + $_.Name + " -> " + $_.Path)
    }
    if (-not $state.Ok) {
        exit 1
    }
    exit 0
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "TinyLM Portable Launcher"
$form.Size = New-Object System.Drawing.Size(700, 460)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$title = New-Object System.Windows.Forms.Label
$title.Text = "llama.cpp WebUI Launcher (Portable)"
$title.Location = New-Object System.Drawing.Point(20, 15)
$title.AutoSize = $true
$title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($title)

$lblPort = New-Object System.Windows.Forms.Label
$lblPort.Text = "Port:"
$lblPort.Location = New-Object System.Drawing.Point(20, 60)
$lblPort.AutoSize = $true
$form.Controls.Add($lblPort)

$txtPort = New-Object System.Windows.Forms.TextBox
$txtPort.Location = New-Object System.Drawing.Point(100, 56)
$txtPort.Size = New-Object System.Drawing.Size(120, 24)
$txtPort.Text = "8080"
$form.Controls.Add($txtPort)

$lblCtx = New-Object System.Windows.Forms.Label
$lblCtx.Text = "Context:"
$lblCtx.Location = New-Object System.Drawing.Point(250, 60)
$lblCtx.AutoSize = $true
$form.Controls.Add($lblCtx)

$txtCtx = New-Object System.Windows.Forms.TextBox
$txtCtx.Location = New-Object System.Drawing.Point(330, 56)
$txtCtx.Size = New-Object System.Drawing.Size(120, 24)
$txtCtx.Text = "32768"
$form.Controls.Add($txtCtx)

$lblNgl = New-Object System.Windows.Forms.Label
$lblNgl.Text = "GPU Layers:"
$lblNgl.Location = New-Object System.Drawing.Point(480, 60)
$lblNgl.AutoSize = $true
$form.Controls.Add($lblNgl)

$txtNgl = New-Object System.Windows.Forms.TextBox
$txtNgl.Location = New-Object System.Drawing.Point(570, 56)
$txtNgl.Size = New-Object System.Drawing.Size(90, 24)
$txtNgl.Text = "99"
$form.Controls.Add($txtNgl)

$lblRoot = New-Object System.Windows.Forms.Label
$lblRoot.Text = ("Project root: " + $projectRoot)
$lblRoot.Location = New-Object System.Drawing.Point(20, 95)
$lblRoot.Size = New-Object System.Drawing.Size(640, 20)
$form.Controls.Add($lblRoot)

$lblWeb = New-Object System.Windows.Forms.Label
$lblWeb.Text = "Web Search:"
$lblWeb.Location = New-Object System.Drawing.Point(20, 120)
$lblWeb.AutoSize = $true
$form.Controls.Add($lblWeb)

$txtWebQuery = New-Object System.Windows.Forms.TextBox
$txtWebQuery.Location = New-Object System.Drawing.Point(100, 116)
$txtWebQuery.Size = New-Object System.Drawing.Size(430, 24)
$txtWebQuery.Text = "llama.cpp qwen3"
$form.Controls.Add($txtWebQuery)

$btnWebSearch = New-Object System.Windows.Forms.Button
$btnWebSearch.Text = "Search"
$btnWebSearch.Location = New-Object System.Drawing.Point(550, 114)
$btnWebSearch.Size = New-Object System.Drawing.Size(110, 28)
$btnWebSearch.Add_Click({
    $query = $txtWebQuery.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($query)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a web search query.")
        return
    }
    $encoded = [System.Uri]::EscapeDataString($query)
    $url = "https://duckduckgo.com/?q=" + $encoded
    Start-Process $url | Out-Null
    Write-Status ("[WEB] opened browser search: " + $query)
})
$form.Controls.Add($btnWebSearch)

$txtStatus = New-Object System.Windows.Forms.TextBox
$txtStatus.Location = New-Object System.Drawing.Point(20, 155)
$txtStatus.Size = New-Object System.Drawing.Size(640, 205)
$txtStatus.Multiline = $true
$txtStatus.ScrollBars = "Vertical"
$txtStatus.ReadOnly = $true
$form.Controls.Add($txtStatus)

$serverProc = $null

function Write-Status {
    param([string]$Line)
    $txtStatus.AppendText($Line + [Environment]::NewLine)
}

function Run-DependencyCheck {
    $llamaState = Test-PortableDeps -ProjectRoot $projectRoot
    $txtStatus.Clear()

    Write-Status "=== llama.cpp dependencies ==="
    foreach ($item in $llamaState.Items) {
        if ($item.Exists) {
            Write-Status ("[OK]   " + $item.Name + " -> " + $item.Path)
        } else {
            Write-Status ("[MISS] " + $item.Name + " -> " + $item.Path)
        }
    }
    if ($llamaState.Ok) {
        Write-Status ""
        Write-Status "[READY] llama.cpp dependency check passed."
    } else {
        Write-Status ""
        Write-Status "[BLOCKED] llama.cpp files missing in project."
    }
    return $llamaState.Ok
}

$btnCheck = New-Object System.Windows.Forms.Button
$btnCheck.Text = "Check"
$btnCheck.Location = New-Object System.Drawing.Point(20, 375)
$btnCheck.Size = New-Object System.Drawing.Size(100, 30)
$btnCheck.Add_Click({
    Run-DependencyCheck | Out-Null
})
$form.Controls.Add($btnCheck)

$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "Start"
$btnStart.Location = New-Object System.Drawing.Point(140, 375)
$btnStart.Size = New-Object System.Drawing.Size(100, 30)
$btnStart.Add_Click({
    if (-not (Run-DependencyCheck)) {
        return
    }

    [int]$port = 0
    [int]$ctx = 0
    [int]$ngl = 0
    if (-not [int]::TryParse($txtPort.Text, [ref]$port) -or $port -lt 1 -or $port -gt 65535) {
        [System.Windows.Forms.MessageBox]::Show("Port must be 1-65535.")
        return
    }
    if (-not [int]::TryParse($txtCtx.Text, [ref]$ctx) -or $ctx -le 0) {
        [System.Windows.Forms.MessageBox]::Show("Context must be a positive integer.")
        return
    }
    if (-not [int]::TryParse($txtNgl.Text, [ref]$ngl) -or $ngl -lt 0) {
        [System.Windows.Forms.MessageBox]::Show("GPU layers must be >= 0.")
        return
    }

    if ($serverProc -and -not $serverProc.HasExited) {
        Write-Status ("[INFO] already running. PID=" + $serverProc.Id)
        return
    }

    $llamaExe = Join-Path $projectRoot "tools\llama\llama-server.exe"
    $modelsPreset = Join-Path $projectRoot "models\models.ini"
    $args = @(
        "-c", $ctx,
        "-ngl", $ngl,
        "--models-preset", $modelsPreset,
        "--webui",
        "--host", "127.0.0.1",
        "--port", $port
    )

    $serverProc = Start-Process -FilePath $llamaExe -ArgumentList $args -WorkingDirectory $projectRoot -PassThru
    Write-Status ("[START] llama.cpp started. PID=" + $serverProc.Id + ", port=" + $port)
    Start-Process ("http://127.0.0.1:" + $port + "/") | Out-Null
})
$form.Controls.Add($btnStart)

$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Text = "Stop"
$btnStop.Location = New-Object System.Drawing.Point(260, 375)
$btnStop.Size = New-Object System.Drawing.Size(100, 30)
$btnStop.Add_Click({
    if ($serverProc -and -not $serverProc.HasExited) {
        Stop-Process -Id $serverProc.Id -Force
        Write-Status ("[STOP] stopped PID=" + $serverProc.Id)
    } else {
        Write-Status "[INFO] no running process started by this launcher."
    }
})
$form.Controls.Add($btnStop)

[void](Run-DependencyCheck)
[void]$form.ShowDialog()
