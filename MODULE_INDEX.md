# 超长篇小说AI创作系统模块索引

## 系统模块引用索引

本文件提供系统所有功能模块的快速引用，便于AI理解整个系统的构成和功能。

### 1. 项目初始化模块
- `@./scripts/01-init-project.sh` - 项目初始化，创建基础目录结构和配置文件
- `@./scripts/02-create-outline.sh` - 生成小说大纲
- `@./scripts/03-batch-create.sh` - 批量创作章节

### 2. 质量控制模块
- `@./scripts/04-quality-check.sh` - 质量检查与一致性验证
- `@./scripts/05-compress-session.sh` - 会话压缩与Token管理

### 3. 拆书分析模块
- `@./scripts/21-combined-revision.sh` - 传统批量拆书-换元-仿写流程
- `@./scripts/22-split-book-analyzer.sh` - 专项拆书分析工具
- `@./scripts/23-element-swapper.sh` - 换元设计工具
- `@./scripts/24-content-rewriter.sh` - 仿写实施工具

### 4. 逐章累积分析模块（新）
- `@./scripts/25-chapter-by-chapter-analyzer.sh` - 基于强制逐章累积分析师的拆书工具集
  - `na a-init` - 初始化累积分析项目
  - `na a-analyze` - 逐章分析并累积
  - `na a-view` - 查看累积报告
  - `na a-export` - 导出累积报告

### 5. 沙盒创作法模块
- `@./scripts/20-sandbox-creation.sh` - 沙盒创作法完整流程
  - `na x-init` - 初始化沙盒项目
  - `na x-sbox` - 沙盒阶段创作
  - `na x-expand` - 扩展阶段创作

### 6. 增强功能模块
- `@./scripts/14-enhancement-suite.sh` - 章节增强套件
  - `na e-revise` - 修改指定章节
  - `na e-opt` - 优化指定章节
  - `na e-cont` - 续写指定章节

### 7. NovelWriter集成模块
- `@./scripts/15-novelwriter-integration.sh` - NovelWriter功能整合
- `@./scripts/16-novelwriter-advanced.sh` - NovelWriter高级分析功能

### 8. LexicraftAI集成模块
- `@./scripts/17-lexicraftai-integration.sh` - 词汇分析与优化功能

### 9. 系统工具模块
- `@./scripts/98-project-validator.sh` - 项目完整性验证
- `@./scripts/99-error-checker.sh` - 项目错误检查与修复
- `@./scripts/flow-visualizer.sh` - 工作流可视化

### 10. 工作流模块
- `@./scripts/11-unified-workflow.sh` - 统一工作流（交互式/自动式）
- `@./scripts/09-full-workflow.sh` - 完整工作流自动化

### 11. 小说分割模块（新）
- `@./scripts/26-novel-splitter.sh` - 小说分割与合并工具集
  - `na ns-split` - 按章节分割整本小说
  - `na ns-analyze-split` - 分析分割后的章节
  - `na ns-full-split` - 完整分割分析流程
  - `na ns-merge` - 合并不同版本的章节

### 12. 工具函数模块
- `@./scripts/utils/token-manager.js` - Token管理工具
- `@./scripts/utils/summary-engine.js` - 摘要生成引擎
- `@./scripts/utils/file-manager.js` - 文件管理工具
- `@./scripts/utils/token-counter.js` - Token计数器

---

## 快速启动命令
- `na p-init "项目名" 章节数` - 初始化项目
- `na a-init "./projects/项目名" "小说名"` - 初始化累积分析
- `na a-analyze "./projects/项目名" 章节号 "./content.txt"` - 逐章分析
- `na s-analyze "./projects/项目名" 起始章 结束章` - 批量拆书分析
- `na x-sbox "./projects/项目名"` - 沙盒创作阶段
- `na e-revise "./chapters/章节文件"` - 优化章节内容

## 模块说明

- **拆书分析模块**: 提供对小说内容的深度分析，理解情节结构、人物关系、写作技巧等
- **逐章累积分析模块**: 基于强制逐章累积分析师概念，逐章分析并累积形成完整报告
- **沙盒创作法模块**: 提供分阶段的创作方法，先在小范围内验证设定
- **增强功能模块**: 提供章节修改、续写、优化等功能
- **质量控制模块**: 确保创作输出的质量和一致性

如需详细了解任一模块的功能和实现，请使用 "qwen @<模块路径> [具体问题]" 格式进行查询。