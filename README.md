# 超长篇小说AI创作系统 v16.0 [Qwen-Code专属版]

## 📖 项目概述

**超长篇小说AI创作系统 v16.0 [Qwen-Code专属版]** 是专为Qwen CLI深度优化的本地化小说创作系统，实现**零成本、高效率、隐私保护**的超长篇创作。

### 核心特性

- **Qwen CLI原生能力深度利用** - 256K上下文、仓库级理解、自动化操作
- **本地化零成本运行** - 免2000次/天、离线能力、数据隐私
- **文件系统智能化** - 自动项目管理、Git集成、批量操作
- **会话工程优化** - Token精准控制、智能压缩、记忆管理
- **一键自动化流程** - 完整可执行脚本、傻瓜式操作
- **增强功能套件** - 续写、修改、优化、分析、扩展

### 项目架构

详细项目结构请参见 [QUICK_GUIDE.md](QUICK_GUIDE.md) 或 [SKILLS.md](SKILLS.md)

### 核心模块

1. **项目管理模块** (01-05): 初始化、大纲生成、章节创作、质量检查
2. **沙盒创作模块** (20): 沙盒创作法实现
3. **拆书分析模块** (21): 拆书分析与换元仿写一体化
4. **逐章分析模块** (25): 逐章累积分析
5. **文体工程模块** (30): AI文体工程 - 换元与仿写
6. **集成工具模块** (14-17): 增强功能、NovelWriter集成、LexicraftAI集成

## 🔧 跨平台支持

本系统支持多种操作系统环境：
- **Linux/Mac**: 直接运行 `.sh` 脚本
- **Windows (Git Bash/WSL)**: 运行 `.sh` 脚本
- **Windows (PowerShell)**: 运行 `.ps1` 脚本
- **Windows (CMD)**: 运行 `.bat` 脚本

### Windows用户注意事项

在Windows系统上使用本系统，您需要先安装以下工具之一：

1. **Git for Windows** (包含Git Bash):
   - 下载地址: https://git-scm.com/download/win
   - 安装后可使用Git Bash运行.sh脚本

2. **Windows Subsystem for Linux (WSL)**:
   - 在PowerShell中运行: `wsl --install`
   - 安装后可在WSL环境中运行.sh脚本

3. **Cygwin**:
   - 下载地址: https://www.cygwin.com/
   - 安装时选择bash和其他必要工具

安装上述任一环境后，您可以使用如下命令运行系统：

```bash
# 在Git Bash或WSL中
./scripts/11-unified-workflow.sh -a "我的玄幻小说" 100 "玄幻" "林轩" "宗门试炼"
```

## 🔧 构建和运行

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

# 4. 下载本系统
git clone https://github.com/yourusername/novel-ai-system-v16.git
cd novel-ai-system-v16

# 5. 运行环境诊断
node tools/diagnostic.js
```

### 一键创作小说

```shellscript
# 方法1: 使用统一工作流脚本 (推荐)
./scripts/11-unified-workflow.sh -i    # 交互式模式
# 或
./scripts/11-unified-workflow.sh -a "我的玄幻小说" 100 "玄幻" "林轩" "宗门试炼"  # 自动模式

# 方法2: 分步执行
# Step 1: 初始化项目
./scripts/01-init-project.sh "我的玄幻小说" 100

# Step 2: 生成大纲
./scripts/02-create-outline.sh "./projects/我的玄幻小说" 100
# 按提示输入：类型、主角、冲突

# Step 3: 批量创作章节
./scripts/03-batch-create.sh "./projects/我的玄幻小说" 1 100
# 等待系统自动生成100章

# Step 4: 质量检查
./scripts/04-quality-check.sh "./projects/我的玄幻小说"

✅ 完成！您的100章小说已生成！
```

### 增强功能

系统提供了多种增强功能脚本，用于优化和完善您的小说：

```shellscript
# 1. 续写指定章节
./scripts/14-enhancement-suite.sh continue "./projects/我的小说" 10

# 2. 修改指定章节
./scripts/14-enhancement-suite.sh revise "./projects/我的小说/chapters/chapter_001_标题.md"

# 3. 优化章节质量
./scripts/14-enhancement-suite.sh optimize "./projects/我的小说/chapters/chapter_001_标题.md"

# 4. 分析项目质量
./scripts/14-enhancement-suite.sh analyze "./projects/我的小说"

# 5. 扩展章节内容
./scripts/14-enhancement-suite.sh expand "./projects/我的小说/chapters/chapter_001_标题.md" "end"
```

### NovelWriter功能整合

系统集成了EdwardAThomson/NovelWriter的特性，提供多种导出和分析功能：

```shellscript
# 1. 导出为Markdown格式
./scripts/15-novelwriter-integration.sh export-md "./projects/我的小说" "./exports/我的小说.md"

# 2. 导出为HTML格式
./scripts/15-novelwriter-integration.sh export-html "./projects/我的小说" "./exports/我的小说.html"

# 3. 分析项目结构和统计信息
./scripts/15-novelwriter-integration.sh analyze-project "./projects/我的小说"

# 4. 将章节拆分为场景
./scripts/15-novelwriter-integration.sh split-scenes "./projects/我的小说"

# 5. 编译完整书籍
./scripts/15-novelwriter-integration.sh compile-book "./projects/我的小说" "./compiled/我的小说.md"

# 6. 导出为NovelWriter兼容格式
python tools/novelwriter-exporter.py "./projects/我的小说" "./novelwriter-export/"

# 7. 高级分析功能
./scripts/16-novelwriter-advanced.sh word-count "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh chapter-stats "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh pov-analysis "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh dialogue-check "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh readability "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh timeline "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh character-tracker "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh consistency-check "./projects/我的小说"
```

### LexicraftAI功能融合

系统集成了EuclidStellar/LexicraftAI的特性，提供高级词汇分析和优化功能：

```shellscript
# 1. 词汇分析
./scripts/17-lexicraftai-integration.sh vocabulary-analysis "./projects/我的小说"

# 2. 词频统计
./scripts/17-lexicraftai-integration.sh word-frequency "./projects/我的小说"

# 3. 同义词替换优化
./scripts/17-lexicraftai-integration.sh synonym-replacer "./projects/我的小说"

# 4. 风格分析
./scripts/17-lexicraftai-integration.sh style-analyzer "./projects/我的小说"

# 5. 情感分析
./scripts/17-lexicraftai-integration.sh sentiment-check "./projects/我的小说"

# 6. 可读性改进
./scripts/17-lexicraftai-integration.sh readability-improver "./projects/我的小说"

# 7. 生成词汇表
./scripts/17-lexicraftai-integration.sh generate-vocabulary "./projects/我的小说"

# 8. 导出词典
./scripts/17-lexicraftai-integration.sh export-lexicon "./projects/我的小说" "./lexicons/我的小说"

# 9. 上下文优化
./scripts/17-lexicraftai-integration.sh context-optimizer "./projects/我的小说"

# 10. 散文增强
./scripts/17-lexicraftai-integration.sh prose-enhancer "./projects/我的小说"
```

### 项目维护和验证

```shellscript
# 1. 项目完整性验证
./scripts/98-project-validator.sh

# 2. 项目错误检查和修复
./scripts/99-error-checker.sh
```

### 流程可视化

```shellscript
# 1. 查看小说生成流程图
./scripts/flow-visualizer.sh

# 2. 查看快速开始命令
./scripts/flow-visualizer.sh -c
```

### 沙盒创作法

```shellscript
# 1. 初始化沙盒项目
./scripts/20-sandbox-creation.sh init "我的玄幻小说" 100 "玄幻"

# 2. 沙盒阶段创作（前10章，验证核心设定）
./scripts/20-sandbox-creation.sh sandbox "./projects/我的玄幻小说"

# 3. 扩展阶段创作（扩大世界观）
./scripts/20-sandbox-creation.sh expand "./projects/我的玄幻小说" 11 30

# 4. 完成整个创作流程
./scripts/20-sandbox-creation.sh complete "./projects/我的玄幻小说"

# 5. 分析项目完整性
./scripts/20-sandbox-creation.sh analyze "./projects/我的玄幻小说"
```

### 拆书分析与换元仿写一体化

```shellscript
# 1. 传统批量拆书分析
./scripts/21-combined-revision.sh analyze "./projects/我的小说" 1 10

# 2. 换元设计
./scripts/21-combined-revision.sh swap "./projects/我的小说" 1 10 "加入神秘导师角色"

# 3. 仿写实施
./scripts/21-combined-revision.sh rewrite "./projects/我的小说" 1 10 "加入神秘导师角色"

# 4. 完整拆书-换元-仿写流程
./scripts/21-combined-revision.sh full "./projects/我的小说" 1 10 "加入神秘导师角色"

# 5. 版本合并
./scripts/21-combined-revision.sh merge "./projects/我的小说" 1 10 "main"
```

### 逐章累积分析（新功能 - 基于强制逐章累积分析师）

```shellscript
# 1. 初始化累积分析
./scripts/25-chapter-by-chapter-analyzer.sh init "./projects/我的小说" "小说名"

# 2. 逐章分析并累积（每分析一章，自动累积到完整报告）
./scripts/25-chapter-by-chapter-analyzer.sh analyze "./projects/我的小说" 1 "./chapters/chapter_001_content.txt"
./scripts/25-chapter-by-chapter-analyzer.sh analyze "./projects/我的小说" 2 "./chapters/chapter_002_content.txt"
./scripts/25-chapter-by-chapter-analyzer.sh analyze "./projects/我的小说" 3 "./chapters/chapter_003_content.txt"

# 3. 查看当前累积分析报告
./scripts/25-chapter-by-chapter-analyzer.sh view "./projects/我的小说"

# 4. 导出完整累积分析报告
./scripts/25-chapter-by-chapter-analyzer.sh export "./projects/我的小说" "./exports/accumulated-analysis.md"
```

### 小说分割功能（新模块）

```shellscript
# 1. 按章节分割整本小说
./scripts/26-novel-splitter.sh split "novel.txt" "./projects/我的小说" "我的玄幻小说"

# 2. 对分割后的章节进行分析
./scripts/26-novel-splitter.sh analyze "./projects/我的小说" 1 10

# 3. 完整分割分析流程
./scripts/26-novel-splitter.sh full "novel.txt" "./projects/我的小说" "我的玄幻小说"

# 4. 合并不同版本的章节
./scripts/26-novel-splitter.sh merge "./projects/我的小说" 1 10 "main"
```

### 系统模块快速引用

系统功能模块的完整索引请参考 [QUICK_REFERENCE.md](QUICK_REFERENCE.md) 文档。
此外，详细使用指南请参阅 [docs/chapter-by-chapter-analysis.md](docs/chapter-by-chapter-analysis.md)。

## 📋 开发约定

### 快速启动

- **完整指南**: [QUICK_START.md](QUICK_START.md) - 快速启动和模块调用指南
- **主提示词索引**: [PROMPTS.md](PROMPTS.md) - 完整模块和功能说明
- **简化指令映射**: [SHORTCUTS.md](SHORTCUTS.md) - 简化指令与完整脚本的映射表

### 简化指令系统

系统提供了一套简化指令，前缀为`na`，便于快速调用：

```bash
# 1. 项目管理指令
na p-init "我的玄幻小说" 100                    # 初始化项目
na p-outline "./projects/我的玄幻小说" 100       # 生成大纲
na p-create "./projects/我的玄幻小说" 1 100      # 批量创作章节
na p-check "./projects/我的玄幻小说"             # 质量检查

# 2. 拆书分析指令
na s-analyze "./projects/我的小说" 1 10         # 拆书分析
na s-swap "./projects/我的小说" 1 10 "加入导师角色"  # 换元设计
na s-rewrite "./projects/我的小说" 1 10 "加入导师角色" # 仿写实施
na s-full "./projects/我的小说" 1 10 "加入导师角色"   # 完整流程

# 3. 沙盒创作指令
na x-init "我的小说" 100 "玄幻"                # 初始化项目
na x-sbox "./projects/我的小说"                # 沙盒阶段创作
na x-expand "./projects/我的小说" 11 100        # 扩展阶段创作

# 4. 增强功能指令
na e-revise "./projects/我的小说/chapters/chapter_001_标题.md"  # 修改章节
na e-opt "./projects/我的小说/chapters/chapter_001_标题.md"      # 优化章节
na e-cont "./projects/我的小说" 10              # 续写第10章

# 5. 分析工具指令
na na-stats "./projects/我的小说"               # 章节统计
na na-pov "./projects/我的小说"                 # 视角分析
na l-vocab "./projects/我的小说"                # 词汇分析
na l-read "./projects/我的小说"                 # 可读性分析
```

简化指令快速映射表：
- `na p-*` → 项目管理 (Project Management)
- `na s-*` → 拆书分析 (Split book Analysis)
- `na x-*` → 沙盒创作 (SandboX creation)
- `na e-*` → 增强功能 (Enhancement)
- `na n-*` → NovelWriter功能 (NovelWriter)
- `na na-*` → NovelWriter高级分析 (NovelWriter Advanced)
- `na l-*` → 词汇分析 (LexicraftAI)
- `na a-*` → 逐章累积分析 (Accumulative Analysis)
- `na sys-*` → 系统工具 (System Tools)

### Token管理策略

- **Token限制**: 32000 tokens (Qwen CLI)
- **安全阈值**: 25000 tokens (保留20%余量)
- **中文字符**: 1字≈1.5 tokens
- **英文单词**: 1词≈1.3 tokens

### 会话工程优化

- **定期压缩**: 每5章主动压缩会话历史
- **上下文构建**:
  - 核心设定（永久保留，≈2000 tokens）
  - 近期情节（最近5章，≈3000 tokens）
  - 历史总结（压缩版，≈2000 tokens）
  - 记忆提醒（≈1000 tokens）
  - 前情提要（≈500 tokens）
- **总计约8500 tokens**，远低于32000限制

### 文件命名规范

```
chapters/
├── chapter_001_开局废材.md
├── chapter_002_奇遇逆袭.md
├── chapter_003_拜师学艺.md
└── ...

summaries/
├── summary_001-010.md          # 第1-10章总结
├── summary_011-020.md          # 第11-20章总结
└── ...

settings/
├── characters.json             # 角色档案
├── worldview.json              # 世界观设定
├── power-system.json           # 力量体系
└── foreshadows.json            # 伏笔记录
```

### 会话模式说明

- **plan模式**: 仅分析，不修改文件 (`/approval-mode plan`)
- **default模式**: 需要审批的修改
- **auto-edit模式**: 自动批准编辑 (`/approval-mode auto-edit`)

## 🎯 最佳实践

### 1. 完整创作流程（沙盒创作法）

```shellscript
# 方法1: 一键交互式创作 (推荐)
./scripts/11-unified-workflow.sh -i

# 方法2: 一键自动创作
./scripts/11-unified-workflow.sh -a "我的玄幻小说" 100 "玄幻" "林轩" "废材逆袭"

# 方法3: 分步创作（采用沙盒创作法）
# 步骤1: 初始化项目（建立基础结构和设定）
./scripts/01-init-project.sh "我的玄幻小说" 100

# 步骤2: 世界观构建和角色设计（在settings/目录下完善设定）
# - 编辑 settings/worldview.json (世界观设定)
# - 编辑 settings/power-system.json (力量体系)
# - 编辑 settings/characters.json (角色档案)

# 步骤3: 生成详细大纲
./scripts/02-create-outline.sh "./projects/我的玄幻小说" 100

# 步骤4: 沙盒创作阶段 (前10章，验证核心设定和人物关系)
./scripts/03-batch-create.sh "./projects/我的玄幻小说" 1 10

# 步骤5: 扩展创作阶段 (分批进行，逐步扩大世界观)
./scripts/03-batch-create.sh "./projects/我的玄幻小说" 11 20    # 第2批 (扩大世界)
./scripts/03-batch-create.sh "./projects/我的玄幻小说" 21 40   # 第3批 (深化情节)
./scripts/03-batch-create.sh "./projects/我的玄幻小说" 41 60   # 第4批 (推进主线)
# ... 继续直到完成

# 步骤6: 质量检查和优化
./scripts/04-quality-check.sh "./projects/我的玄幻小说"
./scripts/14-enhancement-suite.sh analyze "./projects/我的玄幻小说"
```

### 2. 分批创作策略（沙盒方法）

```shellscript
# 沙盒阶段: 前10章集中在一个环境
./scripts/03-batch-create.sh "./project" 1 10    # 沙盒环境创作

# 扩展阶段: 每批10-20章，逐步扩大世界
./scripts/03-batch-create.sh "./project" 11 20   # 扩展到更大范围
./scripts/03-batch-create.sh "./project" 21 30   # 深化人物关系
./scripts/03-batch-create.sh "./project" 31 40   # 推进主线冲突
# ... 继续直到完成
```

### 2. 定期备份

```shellscript
# 每创作10章备份一次
cd projects/我的小说
git add .
git commit -m "完成10章"
git push
```

### 3. 后期优化与分析

```shellscript
# 章节优化
./scripts/14-enhancement-suite.sh continue "./projects/我的小说" 10    # 续写
./scripts/14-enhancement-suite.sh revise "./projects/我的小说/chapters/chapter_001_标题.md"  # 修改
./scripts/14-enhancement-suite.sh optimize "./projects/我的小说/chapters/chapter_001_标题.md" # 优化

# 项目分析
./scripts/16-novelwriter-advanced.sh chapter-stats "./projects/我的小说"   # 章节统计
./scripts/16-novelwriter-advanced.sh pov-analysis "./projects/我的小说"     # 视角分析
./scripts/16-novelwriter-advanced.sh dialogue-check "./projects/我的小说"   # 对话检查
./scripts/17-lexicraftai-integration.sh vocabulary-analysis "./projects/我的小说"  # 词汇分析

# 格式导出
./scripts/15-novelwriter-integration.sh export-md "./projects/我的小说" "./exports/我的小说.md"
./scripts/15-novelwriter-integration.sh export-html "./projects/我的小说" "./exports/我的小说.html"
```

### 4. 人工精修

AI生成80% + 人工精修20%，重点检查：
- 删除AI腔句式
- 补充细节和情感
- 调整节奏和张力
- 优化对话和动作

### 5. 使用Qwen CLI的仓库级理解

```shellscript
qwen> @./projects/我的小说 分析所有章节中主角的性格变化

qwen> @./projects/我的小说 找出所有未回收的伏笔

qwen> @./projects/我的小说 生成整本小说的角色关系图
```

## 📚 更多信息

更多详细功能说明请参见:
- **快速指南**: [QUICK_GUIDE.md](QUICK_GUIDE.md) - 快速上手指南
- **技能索引**: [SKILLS.md](SKILLS.md) - 完整功能索引和使用方式
- **详细文档**: [docs/](docs/) - 详细技术文档
- **安装指南**: [INSTALL.md](INSTALL.md) - 详细安装步骤
- **模块索引**: [MODULE_INDEX.md](MODULE_INDEX.md) - 系统功能模块完整索引

## 🧪 系统验证

完成安装后，使用以下命令验证系统是否正常工作：

```bash
# 1. 运行环境诊断
node tools/diagnostic.js

# 2. 检查系统组件
node tools/validation-checker.js

# 3. 运行错误检查
./scripts/99-error-checker.sh  # 在 Git Bash/WSL 中运行

# 4. 创建测试项目验证整体功能
./scripts/11-unified-workflow.sh -a "验证测试" 3 "科幻" "测试者" "系统验证"
```

## 🚨 注意事项

- 系统依赖Qwen CLI的256K上下文能力
- 每天有2000次API请求限制
- 建议定期压缩会话历史以避免Token超限
- 100章小说约需500-1000次请求
- 推荐使用Git进行版本控制
- Windows用户需要安装 Git Bash 或 WSL 才能运行shell脚本

## 🔧 维护和更新

### 项目完整性验证
```bash
# 验证项目结构和文件完整性
./scripts/98-project-validator.sh

# 检查并修复常见问题
./scripts/99-error-checker.sh
```

### 系统更新
```bash
# 备份现有项目
cp -r projects/ projects-backup-$(date +%Y%m%d)

# 拉取最新代码
git pull origin main

# 重新安装必要依赖
npm install
```

## ✅ 系统组件清单

### 核心脚本
- `01-init-project.sh` - 项目初始化
- `02-create-outline.sh` - 大纲生成
- `03-batch-create.sh` - 批量章节创作
- `11-unified-workflow.sh` - 统一工作流
- `20-sandbox-creation.sh` - 沙盒创作法
- `21-combined-revision.sh` - 拆书分析与换元仿写
- `25-chapter-by-chapter-analyzer.sh` - 逐章累积分析

### 工具脚本
- `diagnostic.js` - 环境诊断
- `token-manager.js` - Token管理
- `memory-enhancer.js` - 记忆增强
- `quality-analyzer.js` - 质量分析
- `validation-checker.js` - 系统验证

### 集成功能
- NovelWriter 特性集成 (scripts/15-*)
- LexicraftAI 特性集成 (scripts/17-*)
- 高级分析工具 (scripts/16-*)

**版本**: v16.0
**发布日期**: 2025年12月1日
**作者**: Your Name
**协议**: MIT License