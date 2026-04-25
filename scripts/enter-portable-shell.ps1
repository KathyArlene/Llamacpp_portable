$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$toolsDir = Join-Path $projectRoot "tools"

$pathParts = @(
    (Join-Path $toolsDir "python"),
    (Join-Path $toolsDir "python\Scripts"),
    (Join-Path $toolsDir "llama"),
    (Join-Path $toolsDir "node")
)

$env:PATH = (($pathParts -join ";") + ";" + $env:PATH)

Write-Host "Portable environment activated for this shell."
Write-Host ("Project root: " + $projectRoot)
Write-Host ""
Write-Host "Tool versions:"
& (Join-Path $toolsDir "python\python.exe") --version
& (Join-Path $toolsDir "llama\llama-server.exe") --version
if (Test-Path (Join-Path $toolsDir "node\node.exe")) {
    & (Join-Path $toolsDir "node\node.exe") --version
}
