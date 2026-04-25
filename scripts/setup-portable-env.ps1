param(
    [string]$PythonVersion = "3.12.10",
    [string]$LlamaVersion = "b8925",
    [switch]$InstallModelTools = $true
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$toolsDir = Join-Path $projectRoot "tools"
$downloadsDir = Join-Path $projectRoot "downloads"

New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
New-Item -ItemType Directory -Force -Path $downloadsDir | Out-Null

function Download-IfMissing {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$OutFile
    )
    if (-not (Test-Path $OutFile)) {
        Write-Host ("Downloading: " + $Url)
        Invoke-WebRequest -Uri $Url -OutFile $OutFile
    } else {
        Write-Host ("Using cached file: " + $OutFile)
    }
}

function Expand-ZipFresh {
    param(
        [Parameter(Mandatory = $true)][string]$ZipPath,
        [Parameter(Mandatory = $true)][string]$Dest
    )
    if (Test-Path $Dest) {
        Remove-Item -Recurse -Force $Dest
    }
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Expand-Archive -Path $ZipPath -DestinationPath $Dest -Force
}

# 1) Portable Python (embeddable)
$pyZip = Join-Path $downloadsDir ("python-" + $PythonVersion + "-embed-amd64.zip")
$pyUrl = "https://www.python.org/ftp/python/" + $PythonVersion + "/python-" + $PythonVersion + "-embed-amd64.zip"
$pyDest = Join-Path $toolsDir "python"

Download-IfMissing -Url $pyUrl -OutFile $pyZip
Expand-ZipFresh -ZipPath $pyZip -Dest $pyDest

$pthFile = Get-ChildItem -Path $pyDest -Filter "python*._pth" | Select-Object -First 1
if ($null -ne $pthFile) {
    $pthLines = Get-Content $pthFile.FullName
    $pthLines = $pthLines -replace '^#import site$', 'import site'
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($pthFile.FullName, $pthLines, $utf8NoBom)
}

$getPipPath = Join-Path $downloadsDir "get-pip.py"
Download-IfMissing -Url "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPipPath

$pyExe = Join-Path $pyDest "python.exe"
& $pyExe $getPipPath --no-warn-script-location
if ($LASTEXITCODE -ne 0) {
    throw "Portable Python pip bootstrap failed."
}

if ($InstallModelTools) {
    & $pyExe -m pip install -U huggingface_hub
    if ($LASTEXITCODE -ne 0) {
        throw "Install huggingface_hub failed."
    }
}

# 2) Portable llama.cpp binaries
$llamaZip = Join-Path $downloadsDir ("llama-" + $LlamaVersion + "-bin-win-vulkan-x64.zip")
$llamaUrl = "https://github.com/ggml-org/llama.cpp/releases/download/" + $LlamaVersion + "/llama-" + $LlamaVersion + "-bin-win-vulkan-x64.zip"
$llamaDest = Join-Path $toolsDir "llama"

Download-IfMissing -Url $llamaUrl -OutFile $llamaZip
Expand-ZipFresh -ZipPath $llamaZip -Dest $llamaDest

Write-Host ""
Write-Host "Portable environment setup completed."
Write-Host ("Python : " + $pyExe)
Write-Host ("Llama  : " + (Join-Path $llamaDest "llama-server.exe"))
