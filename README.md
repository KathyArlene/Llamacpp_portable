# TinyLM Project (llama.cpp Local WebUI)

## English

### Overview
TinyLM Project is a local-first `llama.cpp` setup for Windows.
It provides:
- Portable local runtime scripts
- A simple launcher UI (`Launcher.bat`)
- Multi-model routing via `models\models.ini`
- Optional browser-based web search button in the launcher UI

### Important: Models Are Not Included
This repository is designed to work even when no model files are present by default.
You must download model files yourself and place them in:

`d:\TinyLM_Project\models`

### Required Model Files (default preset)
The default `models\models.ini` expects:
- `Qwen3-8B-Q8_0.gguf`
- `Qwen3VL-4B-Instruct-Q4_K_M.gguf`
- `mmproj-Qwen3VL-4B-Instruct-F16.gguf`

If you use different files, edit `d:\TinyLM_Project\models\models.ini` accordingly.

### Quick Start
1. Open PowerShell in `d:\TinyLM_Project`.
2. Run:

```powershell
.\scripts\setup-portable-env.ps1
```

3. Put your model files into `d:\TinyLM_Project\models`.
4. Start UI launcher:

```powershell
.\Launcher.bat
```

5. Click `Start` in the launcher UI to run llama.cpp WebUI.

### Direct CLI Start (optional)
```powershell
.\scripts\run-llama-ui.ps1 -RouterMode $true -ModelsPreset ".\models\models.ini" -Port 8080
```

Then open:
`http://127.0.0.1:8080`

### Web Search Note
- The launcher UI includes a `Web Search` field and `Search` button.
- This opens browser search results (DuckDuckGo) for your query.
- `llama.cpp` itself does not automatically browse the web.

---

## 日本語

### 概要
TinyLM Project は、Windows 向けのローカル実行 `llama.cpp` 環境です。
主な内容:
- ポータブル実行スクリプト
- シンプルなランチャー UI（`Launcher.bat`）
- `models\models.ini` による複数モデル切り替え
- ランチャー UI のブラウザ検索ボタン（任意）

### 重要: モデルファイルは同梱されていません
このリポジトリにはモデルファイルを含めない前提です。
モデルは各自でダウンロードし、次のフォルダに配置してください:

`d:\TinyLM_Project\models`

### 既定プリセットで必要なファイル
既定の `models\models.ini` は次を参照します:
- `Qwen3-8B-Q8_0.gguf`
- `Qwen3VL-4B-Instruct-Q4_K_M.gguf`
- `mmproj-Qwen3VL-4B-Instruct-F16.gguf`

別名のモデルを使う場合は `d:\TinyLM_Project\models\models.ini` を編集してください。

### クイックスタート
1. `d:\TinyLM_Project` で PowerShell を開く
2. 実行:

```powershell
.\scripts\setup-portable-env.ps1
```

3. モデルを `d:\TinyLM_Project\models` に配置
4. ランチャー起動:

```powershell
.\Launcher.bat
```

5. UI の `Start` を押して llama.cpp WebUI を起動

### CLI から直接起動（任意）
```powershell
.\scripts\run-llama-ui.ps1 -RouterMode $true -ModelsPreset ".\models\models.ini" -Port 8080
```

アクセス先:
`http://127.0.0.1:8080`

### Web 検索について
- ランチャー UI に `Web Search` と `Search` ボタンがあります。
- 検索はブラウザ（DuckDuckGo）で開かれます。
- `llama.cpp` 自体が自動で Web 閲覧するわけではありません。

---

## 中文

### 项目简介
TinyLM Project 是一个面向 Windows 的本地 `llama.cpp` 运行环境，包含：
- 便携化运行脚本
- 启动器 UI（`Launcher.bat`）
- 基于 `models\models.ini` 的多模型切换
- 启动器内置浏览器搜索按钮（可选）

### 重要说明：仓库默认不包含模型文件
本项目按“默认无模型文件”设计。
请自行下载模型，并放到：

`d:\TinyLM_Project\models`

### 默认配置所需模型文件
当前 `models\models.ini` 默认指向：
- `Qwen3-8B-Q8_0.gguf`
- `Qwen3VL-4B-Instruct-Q4_K_M.gguf`
- `mmproj-Qwen3VL-4B-Instruct-F16.gguf`

如果你使用的是其他文件名，请同步修改 `d:\TinyLM_Project\models\models.ini`。

### 快速开始
1. 在 `d:\TinyLM_Project` 打开 PowerShell。
2. 执行：

```powershell
.\scripts\setup-portable-env.ps1
```

3. 将模型文件下载并放入 `d:\TinyLM_Project\models`。
4. 启动图形启动器：

```powershell
.\Launcher.bat
```

5. 在启动器里点击 `Start` 启动 llama.cpp WebUI。

### 命令行直接启动（可选）
```powershell
.\scripts\run-llama-ui.ps1 -RouterMode $true -ModelsPreset ".\models\models.ini" -Port 8080
```

浏览器访问：
`http://127.0.0.1:8080`

### 联网搜索说明
- 启动器提供 `Web Search` 输入框和 `Search` 按钮。
- 点击后会在浏览器打开 DuckDuckGo 搜索结果。
- `llama.cpp` 原生 WebUI 不会自动联网抓取网页内容。
