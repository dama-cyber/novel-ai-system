# 小说生成流程详解

## 整体流程概述

超长篇小说AI创作系统 v16.0 的小说生成流程分为以下几个核心阶段：

1. **项目初始化** - 创建项目基础结构
2. **大纲生成** - 构建故事框架
3. **章节创作** - 逐章生成内容
4. **质量控制** - 检查和优化内容
5. **导出与分析** - 生成最终作品和分析报告

## 详细流程描述

### 第一阶段：项目初始化 (01-init-project.sh)

```bash
./scripts/01-init-project.sh "我的玄幻小说" 100
```

**流程步骤：**
1. 创建项目目录结构
2. 生成基础配置文件
   - `characters.json` - 角色设定
   - `worldview.json` - 世界观设定
   - `power-system.json` - 力量体系
   - `foreshadows.json` - 伏笔记录
3. 创建必要的子目录 (chapters, summaries, settings, logs)

### 第二阶段：大纲生成 (02-create-outline.sh)

**可选方法：**

**方法A: 手动创建大纲**
```bash
# 通过交互式提示生成大纲
echo -e "玄幻\n林轩\n废材逆袭" | ./scripts/02-create-outline.sh "./projects/我的玄幻小说" 100
```

**方法B: 使用Qwen生成大纲**
```bash
# 直接使用Qwen生成详细大纲
./scripts/11-unified-workflow.sh -a "我的玄幻小说" 100 "玄幻" "林轩" "废材逆袭"
```

**流程步骤：**
1. 收集用户输入的基本信息 (类型、主角、冲突)
2. 构建Qwen提示词模板
3. 调用Qwen生成详细大纲
4. 保存大纲到 `outline.md`

### 第三阶段：章节创作 (03-batch-create.sh)

```bash
./scripts/03-batch-create.sh "./projects/我的玄幻小说" 1 100
```

**流程步骤：**
1. 读取项目设定文件 (角色、世界观、力量体系等)
2. 读取大纲信息 (章节标题、概要)
3. 构建综合提示词模板，包括：
   - 核心设定 (永久保留，≈2000 tokens)
   - 近期情节 (最近5章，≈3000 tokens)
   - 历史总结 (压缩版，≈2000 tokens)
   - 记忆提醒 (≈1000 tokens)
   - 前情提要 (≈500 tokens)
4. 调用Qwen生成章节内容
5. 每5章自动压缩会话历史，避免Token超限

**分批创作策略：**
- 每10章为一批，避免API请求过于频繁
- 批次间暂停10秒，管理令牌使用

### 第四阶段：质量控制 (04-quality-check.sh)

```bash
./scripts/04-quality-check.sh "./projects/我的玄幻小说"
```

**流程步骤：**
1. 检查章节连贯性
2. 验证人物设定一致性
3. 分析情节逻辑
4. 生成质量报告

### 第五阶段：后期优化

#### A. 增强套件优化 (14-enhancement-suite.sh)
```bash
# 续写指定章节
./scripts/14-enhancement-suite.sh continue "./projects/我的小说" 10

# 修改指定章节
./scripts/14-enhancement-suite.sh revise "./projects/我的小说/chapters/chapter_001_标题.md"

# 优化章节质量
./scripts/14-enhancement-suite.sh optimize "./projects/我的小说/chapters/chapter_001_标题.md"
```

#### B. NovelWriter功能分析 (16-novelwriter-advanced.sh)
```bash
# 字数统计
./scripts/16-novelwriter-advanced.sh word-count "./projects/我的小说"

# 章节统计
./scripts/16-novelwriter-advanced.sh chapter-stats "./projects/我的小说"

# 视角分析
./scripts/16-novelwriter-advanced.sh pov-analysis "./projects/我的小说"

# 对话检查
./scripts/16-novelwriter-advanced.sh dialogue-check "./projects/我的小说"

# 可读性分析
./scripts/16-novelwriter-advanced.sh readability "./projects/我的小说"

# 时间线分析
./scripts/16-novelwriter-advanced.sh timeline "./projects/我的小说"

# 角色追踪
./scripts/16-novelwriter-advanced.sh character-tracker "./projects/我的小说"
```

#### C. LexicraftAI词汇优化 (17-lexicraftai-integration.sh)
```bash
# 词汇分析
./scripts/17-lexicraftai-integration.sh vocabulary-analysis "./projects/我的小说"

# 词频统计
./scripts/17-lexicraftai-integration.sh word-frequency "./projects/我的小说"

# 同义词替换
./scripts/17-lexicraftai-integration.sh synonym-replacer "./projects/我的小说"

# 风格分析
./scripts/17-lexicraftai-integration.sh style-analyzer "./projects/我的小说"

# 情感分析
./scripts/17-lexicraftai-integration.sh sentiment-check "./projects/我的小说"

# 生成词汇表
./scripts/17-lexicraftai-integration.sh generate-vocabulary "./projects/我的小说"
```

### 第六阶段：导出与分析

#### A. 格式导出 (15-novelwriter-integration.sh)
```bash
# 导出为Markdown格式
./scripts/15-novelwriter-integration.sh export-md "./projects/我的小说" "./exports/我的小说.md"

# 导出为HTML格式
./scripts/15-novelwriter-integration.sh export-html "./projects/我的小说" "./exports/我的小说.html"

# 编译完整书籍
./scripts/15-novelwriter-integration.sh compile-book "./projects/我的小说" "./compiled/我的小说.md"

# 导出为NovelWriter兼容格式
python tools/novelwriter-exporter.py "./projects/我的小说" "./novelwriter-export/"
```

#### B. 项目分析
```bash
# 项目整体分析
./scripts/15-novelwriter-integration.sh analyze-project "./projects/我的小说"

# 章节拆分为场景
./scripts/15-novelwriter-integration.sh split-scenes "./projects/我的小说"
```

## 一键完整流程

### 交互式完整流程
```bash
./scripts/11-unified-workflow.sh -i
```

### 自动化完整流程
```bash
./scripts/11-unified-workflow.sh -a "我的玄幻小说" 100 "玄幻" "林轩" "废材逆袭"
```

## Token管理与会话优化

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

## 最佳实践流程

### 推荐的创作流程
```bash
# 1. 环境设置 (首次)
./scripts/00-setup.sh

# 2. 创建新项目 (交互式)
./scripts/11-unified-workflow.sh -i

# 3. 或者分步执行
# 3a. 初始化项目
./scripts/01-init-project.sh "项目名" 100

# 3b. 生成大纲 (手动输入信息)
# (这一步需要用户按提示输入类型、主角、冲突)

# 3c. 批量创作章节 (分批进行)
./scripts/03-batch-create.sh "./projects/项目名" 1 20    # 第1批
./scripts/03-batch-create.sh "./projects/项目名" 21 40   # 第2批
./scripts/03-batch-create.sh "./projects/项目名" 41 60   # 第3批
# ... 继续直到完成

# 4. 质量检查
./scripts/04-quality-check.sh "./projects/项目名"

# 5. 高级分析与优化
./scripts/16-novelwriter-advanced.sh chapter-stats "./projects/项目名"
./scripts/17-lexicraftai-integration.sh vocabulary-analysis "./projects/项目名"

# 6. 导出最终作品
./scripts/15-novelwriter-integration.sh export-md "./projects/项目名" "./exports/最终作品.md"
```

这个流程充分利用了Qwen CLI的256K上下文能力，实现了高效的小说创作自动化。