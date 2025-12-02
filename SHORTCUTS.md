# 超长篇小说AI创作系统 - 简化指令映射表

## 指令命名原则
所有指令前缀为 `na` (NovelAI的简写)，避免与Qwen Coder CLI指令冲突
格式：na-[功能缩写]-[操作缩写] [参数]

## 完整指令映射表

### 项目管理指令 (Project Management)
na-p-init <项目名> <章节数>                 → ./scripts/01-init-project.sh
na-p-outline <项目路径> <章节数>             → ./scripts/02-create-outline.sh
na-p-create <项目路径> <起始章> <结束章>      → ./scripts/03-batch-create.sh
na-p-check <项目路径>                       → ./scripts/04-quality-check.sh
na-p-compress <项目路径>                    → ./scripts/05-compress-session.sh

### 拆书分析指令 (Split Book Analysis)
na-s-analyze <项目路径> <起始章> <结束章>     → ./scripts/22-split-book-analyzer.sh
na-s-swap <项目路径> <起始章> <结束章> <新元素> → ./scripts/23-element-swapper.sh
na-s-rewrite <项目路径> <起始章> <结束章> <新元素> → ./scripts/24-content-rewriter.sh
na-s-full <项目路径> <起始章> <结束章> <新元素> → ./scripts/21-combined-revision.sh full

### 沙盒创作指令 (Sandbox Creation)
na-x-init <项目名> <章节数> <类型>            → ./scripts/20-sandbox-creation.sh init
na-x-sbox <项目路径>                        → ./scripts/20-sandbox-creation.sh sandbox
na-x-expand <项目路径> <起始章> <结束章>      → ./scripts/20-sandbox-creation.sh expand
na-x-complete <项目路径>                     → ./scripts/20-sandbox-creation.sh complete
na-x-analyze <项目路径>                      → ./scripts/20-sandbox-creation.sh analyze

### 增强功能指令 (Enhancement Suite)
na-e-cont <项目路径> <章节号>                → ./scripts/14-enhancement-suite.sh continue
na-e-revise <章节路径>                       → ./scripts/14-enhancement-suite.sh revise
na-e-opt <章节路径>                          → ./scripts/14-enhancement-suite.sh optimize
na-e-analyze <项目路径>                      → ./scripts/14-enhancement-suite.sh analyze
na-e-expand <章节路径> <位置>                 → ./scripts/14-enhancement-suite.sh expand

### NovelWriter集成指令 (NovelWriter Integration)
na-n-md <项目路径> <输出路径>                 → ./scripts/15-novelwriter-integration.sh export-md
na-n-html <项目路径> <输出路径>               → ./scripts/15-novelwriter-integration.sh export-html
na-n-compile <项目路径> <输出路径>            → ./scripts/15-novelwriter-integration.sh compile-book
na-n-analyze <项目路径>                      → ./scripts/15-novelwriter-integration.sh analyze-project
na-n-scenes <项目路径>                       → ./scripts/15-novelwriter-integration.sh split-scenes

### NovelWriter高级指令 (NovelWriter Advanced)
na-na-wc <项目路径>                          → ./scripts/16-novelwriter-advanced.sh word-count
na-na-stats <项目路径>                       → ./scripts/16-novelwriter-advanced.sh chapter-stats
na-na-pov <项目路径>                         → ./scripts/16-novelwriter-advanced.sh pov-analysis
na-na-dial <项目路径>                        → ./scripts/16-novelwriter-advanced.sh dialogue-check
na-na-read <项目路径>                        → ./scripts/16-novelwriter-advanced.sh readability
na-na-timeline <项目路径>                    → ./scripts/16-novelwriter-advanced.sh timeline
na-na-char <项目路径>                        → ./scripts/16-novelwriter-advanced.sh character-tracker
na-na-cons <项目路径>                        → ./scripts/16-novelwriter-advanced.sh consistency-check

### LexicraftAI集成指令 (LexicraftAI Integration)
na-l-vocab <项目路径>                        → ./scripts/17-lexicraftai-integration.sh vocabulary-analysis
na-l-freq <项目路径>                         → ./scripts/17-lexicraftai-integration.sh word-frequency
na-l-syn <项目路径>                          → ./scripts/17-lexicraftai-integration.sh synonym-replacer
na-l-style <项目路径>                        → ./scripts/17-lexicraftai-integration.sh style-analyzer
na-l-sent <项目路径>                         → ./scripts/17-lexicraftai-integration.sh sentiment-check
na-l-read <项目路径>                         → ./scripts/17-lexicraftai-integration.sh readability-improver
na-l-gen <项目路径>                          → ./scripts/17-lexicraftai-integration.sh generate-vocabulary
na-l-exp <项目路径> <输出路径>                → ./scripts/17-lexicraftai-integration.sh export-lexicon
na-l-ctx <项目路径>                          → ./scripts/17-lexicraftai-integration.sh context-optimizer
na-l-prose <项目路径>                        → ./scripts/17-lexicraftai-integration.sh prose-enhancer

### 系统工具指令 (System Tools)
na-sys-val <项目路径>                        → ./scripts/98-project-validator.sh
na-sys-fix <项目路径>                        → ./scripts/99-error-checker.sh

### 工作流指令 (Workflow)
na-w-iflow <模式> [参数]                      → ./scripts/11-unified-workflow.sh
na-w-full <项目路径> <章节数> <类型> <主角> <冲突> → ./scripts/09-full-workflow.sh

### 流程可视化指令 (Flow Visualization)
na-fv-show                                   → ./scripts/flow-visualizer.sh
na-fv-cmds                                   → ./scripts/flow-visualizer.sh -c

### 合并与版本控制指令 (Merge & Version Control)
na-m-merge <项目路径> <起始章> <结束章> <分支> → ./scripts/21-combined-revision.sh merge

### 项目验证与清理指令 (Validation & Cleanup)
na-v-purge <项目路径>                        → ./scripts/12-purge-old-versions.sh

### Frankentexts集成指令 (Frankentexts Integration)
na-f-integ <项目路径> <起始章> <结束章> <类型> → ./scripts/13-frankentexts-integration.sh

## 跨平台支持映射
所有.sh指令都有对应的:
- .ps1 - Windows PowerShell版本
- .bat - Windows批处理版本

例如:
- na-p-create → ./scripts/03-batch-create.sh (Linux/Mac)
- na-p-create → ./scripts/03-batch-create.ps1 (Windows PowerShell)  
- na-p-create → ./scripts/03-batch-create.bat (Windows CMD)

## 使用示例
# 创建新项目
na-p-init "我的玄幻小说" 100

# 生成大纲
na-p-outline "./projects/我的玄幻小说" 100

# 批量创作前10章
na-p-create "./projects/我的玄幻小说" 1 10

# 拆书分析（第1-10章）
na-s-analyze "./projects/我的小说" 1 10

# 换元设计（加入新角色）
na-s-swap "./projects/我的小说" 1 10 "加入神秘导师角色"

# 仿写实施
na-s-rewrite "./projects/我的小说" 1 10 "加入神秘导师角色"

# 沙盒创作法完整流程
na-x-init "我的小说" 100 "玄幻"
na-x-sbox "./projects/我的小说"
na-x-expand "./projects/我的小说" 11 100

# 质量分析
na-na-stats "./projects/我的小说"
na-na-pov "./projects/我的小说"
na-la-read "./projects/我的小说"