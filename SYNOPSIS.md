# 超长篇小说AI创作系统 - 功能概要

## 核心概念
超长篇小说AI创作系统是一个基于Qwen CLI的强大工具集，专为本地化、零成本、隐私保护的长篇小说创作而设计。

## 主要模块

### 1. 项目初始化 (`scripts/01-05`)
- `01-init-project.sh` - 创建项目结构
- `02-create-outline.sh` - 生成小说大纲
- `03-batch-create.sh` - 批量创作章节
- `04-quality-check.sh` - 质量检查
- `05-compress-session.sh` - 会话压缩

### 2. 专业创作流程 (`scripts/06-09`)
- `06-split-book.sh` - 拆书分析
- `08-revise-book.sh` - 拆书-换元-仿写流程
- `09-full-workflow.sh` - 完整自动化流程

### 3. 智能工作流 (`scripts/11-17`)
- `11-unified-workflow.sh` - 统一工作流（Qwen Coder CLI优化版）
- `14-enhancement-suite.sh` - 增强套件（续写、修改、优化）
- `15-novelwriter-integration.sh` - NovelWriter功能整合
- `17-lexicraftai-integration.sh` - 词汇智能分析

### 4. 专项创作法 (`scripts/20-21`)
- `20-sandbox-creation.*` - 沙盒创作法（跨平台支持）
- `21-combined-revision.*` - 拆书分析与换元仿写一体化（跨平台支持）

### 5. 系统工具 (`scripts/98-99`)
- `98-project-validator.sh` - 项目完整性验证
- `99-error-checker.sh` - 项目错误检查和修复

## 快速启动

```bash
# 交互式创建小说
./scripts/11-unified-workflow.sh -i

# 沙盒创作法
./scripts/20-sandbox-creation.sh init "我的小说" 100 "玄幻"
./scripts/20-sandbox-creation.sh sandbox "./projects/我的小说"
./scripts/20-sandbox-creation.sh expand "./projects/我的小说" 11 100

# 拆书-换元-仿写流程
./scripts/21-combined-revision.sh full "./projects/我的小说" 1 10 "加入新角色"
```

## 文件结构
- `projects/` - 存放所有小说项目
- `chapters/` - 章节文件
- `settings/` - 项目设定（角色、世界观、力量体系等）
- `summaries/` - 内容摘要和分析
- `config/` - 系统配置文件
- `scripts/` - 核心脚本
- `tools/` - 辅助工具

## 核心优势
1. **零成本** - 利用Qwen CLI免费额度
2. **本地化** - 所有数据存储在本地
3. **智能化** - AI辅助创作全过程
4. **专业化** - 支持拆书、换元、仿写等专业流程
5. **跨平台** - 支持Linux/Mac/Windows