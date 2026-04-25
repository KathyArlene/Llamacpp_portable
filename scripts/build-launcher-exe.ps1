$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$launcherCs = Join-Path $projectRoot "launcher\TinyLMLauncher.cs"
$distDir = Join-Path $projectRoot "launcher\bin"
$outputExe = Join-Path $distDir "TinyLMLauncher.exe"
$csc64 = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$csc32 = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
$cscExe = $null

if (Test-Path $csc64) {
    $cscExe = $csc64
} elseif (Test-Path $csc32) {
    $cscExe = $csc32
}

if ($null -eq $cscExe) {
    throw "csc.exe not found."
}

if (-not (Test-Path $launcherCs)) {
    throw "Launcher source not found: $launcherCs"
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null

& $cscExe `
    /target:winexe `
    /nologo `
    /out:$outputExe `
    /reference:System.dll `
    /reference:System.Windows.Forms.dll `
    /reference:System.Drawing.dll `
    $launcherCs

if ($LASTEXITCODE -ne 0) {
    throw "Build launcher exe failed."
}

Write-Host ("Launcher EXE generated: " + $outputExe)
