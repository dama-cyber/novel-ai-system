# 安装指南

## 系统要求

- **操作系统**: Linux, macOS, 或 Windows (需要 Git Bash 或 WSL)
- **Node.js**: 20.x 或更高版本
- **Qwen CLI**: 最新版本
- **磁盘空间**: 至少 2GB 可用空间
- **网络**: 用于API请求的稳定连接

## Windows 环境设置

### 方法1：Git for Windows (推荐)
1. 下载并安装 [Git for Windows](https://git-scm.com/download/win)
2. 安装过程中选择 "Git Bash" 选项
3. 安装完成后，使用 Git Bash 终端运行脚本

### 方法2：Windows Subsystem for Linux (WSL)
1. 在 PowerShell 中运行: `wsl --install`
2. 安装完成后，可在 WSL 环境中运行脚本

## Linux/macOS 环境设置

无需特殊设置，系统已具备运行脚本的环境。

## 安装步骤

### 1. 安装 Node.js (≥20.x)
- 从 [Node.js 官网](https://nodejs.org/) 下载并安装最新版本
- 验证安装：`node --version`

### 2. 安装 Qwen CLI
```bash
npm install -g @qwen-code/qwen-code@latest
```

### 3. 授权 Qwen CLI
```bash
qwen auth
```
选择 "Qwen OAuth (推荐)" 并按提示完成授权。

### 4. 下载并设置项目
```bash
git clone https://github.com/yourusername/novel-ai-system-v16.git
cd novel-ai-system-v16

# 运行环境诊断
node tools/diagnostic.js
```

### 5. 验证安装
```bash
# 检查系统组件
node tools/validation-checker.js

# 运行错误检查
./scripts/99-error-checker.sh  # 在 Git Bash/WSL 中运行
```

## 依赖项

无需额外安装依赖，系统完全独立运行。

## 故障排除

### Windows 上无法运行 .sh 脚本
- 确保已安装 Git for Windows 或 WSL
- 使用 Git Bash 或 WSL 终端执行脚本

### Qwen CLI 未响应
- 检查 `qwen auth` 是否已成功完成
- 确保网络连接正常
- 检查每日请求限制是否已用完

### 脚本权限问题
在 Linux/macOS 或 Git Bash 中：
```bash
chmod +x scripts/*.sh
chmod +x tools/*.py
```

## 验证安装

创建一个测试项目来验证系统是否正常工作：

```bash
# 在 Git Bash/WSL 中执行
./scripts/11-unified-workflow.sh -a "测试项目" 5 "玄幻" "主角" "冒险"
```

如果项目成功创建，则安装完成。