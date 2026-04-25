param(
    [bool]$RouterMode = $true,
    [string]$ModelsPreset = ".\models\models.ini",
    [string]$ModelPath = ".\models\Qwen3-8B-Q8_0.gguf",
    [int]$Port = 8080,
    [int]$CtxSize = 32768,
    [int]$GpuLayers = 99
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$portableLlama = Join-Path $projectRoot "tools\llama\llama-server.exe"

if (-not (Test-Path $portableLlama)) {
    Write-Error ("Portable llama-server not found: " + $portableLlama)
}

if ($RouterMode) {
    if (-not (Test-Path $ModelsPreset)) {
        Write-Error ("Models preset file not found: " + $ModelsPreset)
    }
} else {
    if (-not (Test-Path $ModelPath)) {
        Write-Error ("Model file not found: " + $ModelPath)
    }
}

Write-Host "Starting llama.cpp server..."
Write-Host ("RouterMode: " + $RouterMode)
if ($RouterMode) {
    Write-Host ("ModelsPreset: " + $ModelsPreset)
} else {
    Write-Host ("Model: " + $ModelPath)
}
Write-Host ("Port : " + $Port)
Write-Host ("Ctx  : " + $CtxSize)
Write-Host ("GPU Layers: " + $GpuLayers)

$llamaServerExe = $portableLlama
if ($RouterMode) {
    & $llamaServerExe `
        -c $CtxSize `
        -ngl $GpuLayers `
        --models-preset $ModelsPreset `
        --webui `
        --host 127.0.0.1 `
        --port $Port
} else {
    & $llamaServerExe `
        -m $ModelPath `
        -c $CtxSize `
        -ngl $GpuLayers `
        --webui `
        --host 127.0.0.1 `
        --port $Port
}
