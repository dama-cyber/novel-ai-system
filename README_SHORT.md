# 超长篇小说AI创作系统 v16.0 [Qwen-Code专属版]

## 📖 项目概述

**超长篇小说AI创作系统 v16.0 [Qwen-Code专属版]** 是专为Qwen CLI深度优化的本地化小说创作系统，实现**零成本、高效率、隐私保护**的超长篇创作。

### 核心特性

- **Qwen CLI原生能力深度利用** - 256K上下文、仓库级理解、自动化操作
- **本地化零成本运行** - 免费2000次/天、离线能力、数据隐私
- **文件系统智能化** - 自动项目管理、Git集成、批量操作
- **会话工程优化** - Token精准控制、智能压缩、记忆管理
- **一键自动化流程** - 完整可执行脚本、傻瓜式操作
- **增强功能套件** - 续写、修改、优化、分析、扩展

## 🚀 快速开始

完整的项目结构和详细使用指南请参见 [QUICK_GUIDE.md](QUICK_GUIDE.md) 或 [SKILLS.md](SKILLS.md)

### 安装步骤

```shellscript
# 1. 检查Node.js版本
node --version  # 需要 ≥ 20.0

# 2. 安装Qwen CLI
npm install -g @qwen-code/qwen-code@latest

# 3. 授权Qwen CLI
qwen auth
# 选择: Qwen OAuth (推荐)
# 浏览器授权后，每天2000次免费请求

# 4. 运行环境诊断
node tools/diagnostic.js
```

### 一键创作小说

```shellscript
# 交互式模式 (推荐)
./scripts/11-unified-workflow.sh -i

# 或使用沙盒创作法 (专业)
./scripts/20-sandbox-creation.sh init "我的小说" 100 "玄幻"
./scripts/20-sandbox-creation.sh sandbox "./projects/我的小说"
./scripts/20-sandbox-creation.sh expand "./projects/我的小说" 11 100
```

## 🛠️ 核心功能模块

- **初始化**: `01-init-project.sh`
- **大纲生成**: `02-create-outline.sh`
- **批量创作**: `03-batch-create.sh`
- **沙盒创作法**: `20-sandbox-creation.*` (跨平台)
- **拆书-换元-仿写**: `21-combined-revision.*` (跨平台)

## 📚 更多信息

- **快速指南**: [QUICK_GUIDE.md](QUICK_GUIDE.md) - 快速上手指南
- **技能索引**: [SKILLS.md](SKILLS.md) - 完整功能索引和使用方式
- **详细文档**: [docs/](docs/) - 详细技术文档