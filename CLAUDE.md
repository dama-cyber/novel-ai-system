# 超长篇小说AI创作系统 CLAUDE实践指南

## 核心指令原则
1. 保持简短（不超过60行）
2. 将复杂指令放到单独目录，然后在此文件中增加索引

## 主要技能索引（Skills）
- `@./scripts/` - 核心创作脚本
  - `/01-init-project.sh` - 项目初始化
  - `/02-create-outline.sh` - 生成大纲
  - `/03-batch-create.sh` - 批量创作章节
  - `/06-split-book.sh` - 拆书分析
  - `/08-revise-book.sh` - 拆书-换元-仿写流程
  - `/13-frankentexts-integration.sh` - Frankentexts融合拼接

- `@./config/` - 配置管理
  - `/qwen-settings.json` - Qwen CLI配置
  - `/novel-template.json` - 小说模板配置
  - `/prompt-library.json` - 提示词库配置

- `@./tools/` - 辅助工具
  - `/diagnostic.js` - 环境诊断
  - `/token-manager.js` - Token管理
  - `/quality-analyzer.js` - 质量分析

## 使用方式
针对具体任务，可使用CLAUDE直接引用以上目录和脚本，例如：
- `@./scripts/03-batch-create.sh 分析批量创作脚本的实现逻辑`
- `@./config/prompt-library.json 优化提示词库配置`
- `@./tools/diagnostic.js 诊断系统安装和配置问题`