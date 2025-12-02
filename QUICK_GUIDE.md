# 超长篇小说AI创作系统 快速指南

## 核心指令原则
保持简短（不超过60行），将复杂指令放到单独目录，然后在此文件中增加索引

## 主要技能索引

### 1. 项目初始化与大纲生成 (@./scripts/)
- `01-init-project.sh` - 项目初始化
- `02-create-outline.sh` - 生成大纲
- `03-batch-create.sh` - 批量创作章节
- `04-quality-check.sh` - 质量检查

### 2. 拆书与修订流程 (@./scripts/)
- `06-split-book.sh` - 拆书分析
- `08-revise-book.sh` - 拆书-换元-仿写流程
- `21-combined-revision.sh` - 拆书分析与换元仿写一体化

### 3. 增强功能 (@./scripts/)
- `14-enhancement-suite.sh` - 增强套件（续写、修改、优化）
- `15-novelwriter-integration.sh` - NovelWriter功能整合
- `17-lexicraftai-integration.sh` - 词汇分析与优化

### 4. 沙盒创作法 (@./scripts/)
- `20-sandbox-creation.sh` - 沙盒创作法（跨平台支持）

### 5. 系统工具 (@./tools/)
- `diagnostic.js` - 环境诊断
- `token-manager.js` - Token管理
- `quality-analyzer.js` - 质量分析

## 快速启动
- `./scripts/11-unified-workflow.sh -i` - 交互式创建小说
- `./scripts/20-sandbox-creation.sh complete "./projects/小说名"` - 沙盒创作全流程
- `./scripts/21-combined-revision.sh full "./projects/小说名" 1 10 "新元素"` - 拆书换元仿写流程

## 配置文件 (@./config/)
- `qwen-settings.json` - Qwen CLI配置
- `novel-template.json` - 小说模板配置
- `prompt-library.json` - 提示词库配置