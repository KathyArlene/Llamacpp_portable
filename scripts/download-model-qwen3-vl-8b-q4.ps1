$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Push-Location $projectRoot
try {
    & ".\scripts\download-model-qwen3-vl-4b-q4.ps1"
} finally {
    Pop-Location
}
