$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$pythonExe = Join-Path $projectRoot "tools\python\python.exe"
$modelsDir = Join-Path $projectRoot "models"

if (-not (Test-Path $pythonExe)) {
    throw "Portable Python not found. Run .\scripts\setup-portable-env.ps1 first."
}

New-Item -ItemType Directory -Force -Path $modelsDir | Out-Null

& $pythonExe -c "from huggingface_hub import hf_hub_download; p1=hf_hub_download(repo_id='Qwen/Qwen3-VL-4B-Instruct-GGUF', filename='Qwen3VL-4B-Instruct-Q4_K_M.gguf', local_dir=r'$modelsDir'); p2=hf_hub_download(repo_id='Qwen/Qwen3-VL-4B-Instruct-GGUF', filename='mmproj-Qwen3VL-4B-Instruct-F16.gguf', local_dir=r'$modelsDir'); print(p1); print(p2)"

if ($LASTEXITCODE -ne 0) {
    throw "Multimodal model download failed."
}
