# 超长篇小说AI创作系统 - 主提示词索引

## 核心指令原则
保持简短（不超过60行），将复杂指令放到单独目录，然后在此文件中增加索引

## 系统模块索引

### 1. 项目初始化与管理 (01-05)
- `@./scripts/01-init-project.sh` - 项目初始化
- `@./scripts/02-create-outline.sh` - 生成大纲
- `@./scripts/03-batch-create.sh` - 批量创作章节
- `@./scripts/04-quality-check.sh` - 质量检查
- `@./scripts/05-compress-session.sh` - 会话压缩

### 2. 拆书-换元-仿写流程 (22-24) - 三大核心模块
- `@./scripts/22-split-book-analyzer.sh` - 拆书分析模块
  - 功能：深度分析章节结构、内容、写作技巧、伏笔呼应
  - 用法：`./scripts/22-split-book-analyzer.sh "./projects/我的小说" 1 10`

- `@./scripts/23-element-swapper.sh` - 换元设计模块
  - 功能：基于拆书分析设计如何融入新元素
  - 用法：`./scripts/23-element-swapper.sh "./projects/我的小说" 1 10 "加入神秘导师角色"`

- `@./scripts/24-content-rewriter.sh` - 仿写实施模块
  - 功能：根据设计方案实际重写章节内容
  - 用法：`./scripts/24-content-rewriter.sh "./projects/我的小说" 1 10 "加入神秘导师角色"`

### 3. 一体化流程 (21) - 整合模块
- `@./scripts/21-combined-revision.sh` - 拆书-换元-仿写完整流程
  - 用法：`./scripts/21-combined-revision.sh full "./projects/我的小说" 1 10 "加入神秘导师角色"`

### 4. 沙盒创作法 (20)
- `@./scripts/20-sandbox-creation.sh` - 沙盒创作法（跨平台支持）
  - 用法：`./scripts/20-sandbox-creation.sh init "我的小说" 100`

### 5. 增强功能 (14-17)
- `@./scripts/14-enhancement-suite.sh` - 增强套件（续写、修改、优化）
- `@./scripts/15-novelwriter-integration.sh` - NovelWriter功能整合
- `@./scripts/16-novelwriter-advanced.sh` - NovelWriter高级分析
- `@./scripts/17-lexicraftai-integration.sh` - 词汇分析与优化

### 6. 系统工具 (98-99)
- `@./scripts/98-project-validator.sh` - 项目完整性验证
- `@./scripts/99-error-checker.sh` - 项目错误检查和修复

### 7. 工作流自动化 (09, 11)
- `@./scripts/09-full-workflow.sh` - 完整工作流自动化
- `@./scripts/11-unified-workflow.sh` - 统一工作流（Qwen Coder CLI优化版）

## 快速调用示例
针对具体任务，可使用AI直接引用以上目录和脚本，例如：

- `@./scripts/03-batch-create.sh 分析批量创作脚本的实现逻辑`
- `@./scripts/22-split-book-analyzer.sh 拆书分析模块的详细介绍`
- `@./scripts/23-element-swapper.sh 换元设计模块的详细介绍`
- `@./scripts/24-content-rewriter.sh 仿写实施模块的详细介绍`
- `@./scripts/21-combined-revision.sh 完整拆书-换元-仿写流程的说明`
- `@./scripts/20-sandbox-creation.sh 沙盒创作法完整说明`