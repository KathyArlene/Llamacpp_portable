# 本地推理服务（llama.cpp + 多模型路由）

## 目录说明
- `start-server.ps1`：启动本地 `llama-server`
- `smoke-test.ps1`：对 OpenAI 兼容接口做最小可用性测试

## 前置要求
- 优先使用项目内 `tools\llama\llama-server.exe`
- 已准备模型文件（GGUF），默认包含：
  - `Qwen3-8B Q8_0`（纯文本）
  - `Qwen3-VL-4B Q4_K_M + mmproj`（多模态）

## 可移植环境（推荐）
先在项目根目录执行：
```powershell
.\scripts\setup-portable-env.ps1
```

之后每次打开新终端，先执行：
```powershell
.\scripts\enter-portable-shell.ps1
```

## 快速启动
1. 在项目根目录执行：
   ```powershell
   .\infra\llama\start-server.ps1 -RouterMode $true -ModelsPreset ".\models\models.ini" -Port 8080
   ```
   浏览器打开 `http://127.0.0.1:8080` 可直接使用 llama.cpp WebUI。  
2. 新开一个终端执行自测：
   ```powershell
   .\infra\llama\smoke-test.ps1 -BaseUrl "http://127.0.0.1:8080" -Model "qwen3-8b-q8"
   ```

## 通过标准
- `smoke-test.ps1` 输出模型回复文本
- 失败时有清晰报错（模型路径、服务连接等）

## Qwen3-VL 模型组成
- `Qwen3VL-4B-Instruct-Q4_K_M.gguf` 和 `mmproj-Qwen3VL-4B-Instruct-F16.gguf` 是一组配套文件。
- 前者是语言模型权重，后者是视觉投影器；缺一会导致图片输入能力不可用。
