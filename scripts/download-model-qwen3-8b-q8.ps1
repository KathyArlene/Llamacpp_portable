$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$pythonExe = Join-Path $projectRoot "tools\python\python.exe"
$modelsDir = Join-Path $projectRoot "models"

if (-not (Test-Path $pythonExe)) {
    throw "Portable Python not found. Run .\scripts\setup-portable-env.ps1 first."
}

New-Item -ItemType Directory -Force -Path $modelsDir | Out-Null

& $pythonExe -c "from huggingface_hub import hf_hub_download; p=hf_hub_download(repo_id='Qwen/Qwen3-8B-GGUF', filename='Qwen3-8B-Q8_0.gguf', local_dir=r'$modelsDir'); print(p)"

if ($LASTEXITCODE -ne 0) {
    throw "Model download failed."
}
