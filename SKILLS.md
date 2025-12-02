# 核心指令原则
1. 保持简短（不超过60行）
2. 将复杂指令放到单独目录，然后在此文件中增加索引

# 主要技能索引（Skills）
- `@./scripts/` - 核心创作脚本
  - `/01-init-project.sh` - 项目初始化
  - `/02-create-outline.sh` - 生成大纲
  - `/03-batch-create.sh` - 批量创作章节
  - `/04-quality-check.sh` - 质量检查
  - `/05-compress-session.sh` - 会话压缩
  - `/06-split-book.sh` - 拆书分析
  - `/07-style-engineer.sh` - 风格工程
  - `/08-revise-book.sh` - 修订功能
  - `/09-full-workflow.sh` - 完整工作流（旧版）
  - `/11-unified-workflow.sh` - 统一工作流（推荐）
  - `/12-purge-old-versions.sh` - 清理旧版本
  - `/13-frankentexts-integration.sh` - Frankentexts融合拼接
  - `/14-enhancement-suite.sh` - 增强功能套件
  - `/15-novelwriter-integration.sh` - NovelWriter集成
  - `/16-novelwriter-advanced.sh` - NovelWriter高级分析
  - `/17-lexicraftai-integration.sh` - LexicraftAI集成
  - `/20-sandbox-creation.sh` - 沙盒创作法
  - `/21-combined-revision.sh` - 拆书分析与换元仿写一体化
  - `/22-split-book-analyzer.sh` - 拆书分析器
  - `/23-element-swapper.sh` - 元素替换工具
  - `/24-content-rewriter.sh` - 内容重写工具
  - `/25-chapter-by-chapter-analyzer.sh` - 逐章累积分析
  - `/26-novel-splitter.sh` - 小说分割器
  - `/30-stylus-engine.sh` - AI文体工程 - 换元与仿写（新）
  - `/98-project-validator.sh` - 项目完整性验证
  - `/99-error-checker.sh` - 错误检查修复

- `@./config/` - 配置管理
  - `/qwen-settings.json` - Qwen CLI配置
  - `/novel-template.json` - 小说模板配置
  - `/prompt-library.json` - 提示词库配置

- `@./tools/` - 辅助工具
  - `/diagnostic.js` - 环境诊断
  - `/token-manager.js` - Token管理
  - `/memory-enhancer.js` - 记忆增强
  - `/quality-analyzer.js` - 质量分析
  - `/validation-checker.js` - 系统验证
  - `/project-validator.js` - 项目验证

- `@./modules/` - 专业模块
  - `/stylus-engine.md` - AI文体工程模块定义

# 使用方式
针对具体任务，可使用AI直接引用以上目录和脚本，例如：
- `@./scripts/03-batch-create.sh 分析批量创作脚本的实现逻辑`
- `@./config/prompt-library.json 优化提示词库配置`
- `@./tools/diagnostic.js 诊断系统安装和配置问题`
- `@./modules/stylus-engine.md 查阅AI文体工程模块规范`