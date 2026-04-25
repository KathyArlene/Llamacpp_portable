# Portable 运行说明

## 目标
- 所有运行依赖都在项目目录内，不依赖系统 PATH。
- 当前项目为纯 `llama.cpp` 路线，使用 `llama-server` 自带 WebUI。

## 一次性初始化
在项目根目录执行：

```powershell
.\scripts\setup-portable-env.ps1
```

该脚本会把工具安装到：
- `tools\python`
- `tools\llama`

## 下载 Qwen3 8B 8-bit（Q8_0）
在项目根目录执行：
```powershell
.\scripts\download-model-qwen3-8b-q8.ps1
```

## 下载 Qwen3-VL-4B 4-bit（多模态）
在项目根目录执行：
```powershell
.\scripts\download-model-qwen3-vl-4b-q4.ps1
```

## 启动 llama.cpp WebUI（多模型可切换）
```powershell
.\scripts\run-llama-ui.ps1 -RouterMode $true -ModelsPreset ".\models\models.ini" -Port 8080
```

打开：
- `http://127.0.0.1:8080`
- WebUI 中可在模型下拉中切换：
  - `qwen3-8b-q8`
  - `qwen3-vl-4b-q4`

## 一键启动（UI 启动器）
推荐直接双击：
- `.\启动器.bat`

这会打开图形界面，支持：
- 端口/上下文/GPU层数输入
- 项目内依赖检测（portable 检查）
- 一键启动 llama.cpp WebUI

如需 EXE 版本（可选）：
```powershell
.\scripts\build-launcher-exe.ps1
```
生成：`.\launcher\bin\TinyLMLauncher.exe`

## 接口自测
```powershell
.\infra\llama\smoke-test.ps1 -BaseUrl "http://127.0.0.1:8080" -Model "qwen3-8b-q8"
```

## Qwen3-VL 文件关系
- `Qwen3VL-4B-Instruct-Q4_K_M.gguf`：语言主模型（VL 主干）
- `mmproj-Qwen3VL-4B-Instruct-F16.gguf`：视觉投影器（图像编码桥接）
- 这两个文件需要配套，合起来算一个可用的多模态模型。

## 联网搜索（可选）
- 启动器已提供 `Web Search` 输入框与按钮（默认 DuckDuckGo）。
- 该功能会在浏览器中打开搜索结果页，便于你把结果复制回聊天窗口。
- 说明：`llama.cpp` 原生 WebUI 只负责本地模型推理，不会自动联网抓取网页内容。
