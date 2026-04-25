param(
    [bool]$RouterMode = $true,
    [string]$ModelsPreset = ".\models\models.ini",
    [string]$ModelPath = ".\models\Qwen3-8B-Q8_0.gguf",
    [int]$Port = 8080,
    [int]$CtxSize = 32768,
    [int]$GpuLayers = 99
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

Push-Location $projectRoot
try {
    & ".\infra\llama\start-server.ps1" `
        -RouterMode $RouterMode `
        -ModelsPreset $ModelsPreset `
        -ModelPath $ModelPath `
        -Port $Port `
        -CtxSize $CtxSize `
        -GpuLayers $GpuLayers
} finally {
    Pop-Location
}
