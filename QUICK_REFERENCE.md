# 小说AI系统模块快速索引

## 指令格式
- `na` - 简化指令前缀
- `p-*` - 项目管理 (Project Management)
- `s-*` - 拆书分析 (Split book Analysis)
- `x-*` - 沙盒创作 (SandboX creation)
- `e-*` - 增强功能 (Enhancement)
- `n-*` - NovelWriter功能 (NovelWriter)
- `na-*` - NovelWriter高级分析 (NovelWriter Advanced)
- `l-*` - 词汇分析 (LexicraftAI)
- `a-*` - 逐章累积分析 (Accumulative Analysis)
- `ns-*` - 小说分割功能 (Novel Splitter)

## 快速指令引用

### 项目管理模块
- `na p-init` - 初始化项目
- `na p-outline` - 生成大纲
- `na p-create` - 批量创作章节
- `na p-check` - 质量检查
- `na p-compress` - 会话压缩

### 拆书分析模块
- `na s-analyze` - 拆书分析
- `na s-swap` - 换元设计
- `na s-rewrite` - 仿写实施
- `na s-full` - 完整拆书流程

### 累积分析模块
- `na a-init` - 初始化累积分析
- `na a-analyze` - 逐章累积分析
- `na a-view` - 查看累积报告
- `na a-export` - 导出累积报告

### 沙盒创作模块
- `na x-init` - 初始化沙盒项目
- `na x-sbox` - 沙盒阶段创作
- `na x-expand` - 扩展阶段创作
- `na x-complete` - 完成创作流程

### 小说分割模块
- `na ns-split` - 按章节分割小说
- `na ns-analyze-split` - 分析分割后章节
- `na ns-full-split` - 分割并分析完整流程

### 增强功能模块
- `na e-cont` - 续写章节
- `na e-revise` - 修改章节
- `na e-opt` - 优化章节
- `na e-analyze` - 项目分析

### 高级分析模块
- `na na-stats` - 章节统计
- `na na-pov` - 视角分析
- `na na-read` - 可读性分析
- `na l-vocab` - 词汇分析

## 一键完整流程
- `na 11-unified-workflow.sh -i` - 交互式完整创作流程
- `na 09-full-workflow.sh` - 自动化完整流程
- `./scripts/11-unified-workflow.sh -a "项目名" 章节数 "类型" "主角" "冲突"` - 自动创作

## 系统工具
- `na sys-val` - 项目验证
- `na sys-fix` - 错误检查与修复
- `./scripts/flow-visualizer.sh` - 流程可视化
- `./scripts/flow-visualizer.sh -c` - 快速命令

## 批处理命令
- `./scripts/14-enhancement-suite.sh` - 增强功能套件
- `./scripts/15-novelwriter-integration.sh` - NovelWriter功能整合
- `./scripts/16-novelwriter-advanced.sh` - NovelWriter高级功能
- `./scripts/17-lexicraftai-integration.sh` - LexicraftAI功能整合
- `./scripts/20-sandbox-creation.sh` - 沙盒创作法
- `./scripts/21-combined-revision.sh` - 拆书-换元-仿写一体化
- `./scripts/25-chapter-by-chapter-analyzer.sh` - 逐章累积分析器
- `./scripts/26-novel-splitter.sh` - 小说分割工具

## 工具函数
- `scripts/utils/token-manager.js` - Token管理器
- `scripts/utils/summary-engine.js` - 摘要引擎
- `scripts/utils/file-manager.js` - 文件管理器
- `scripts/utils/token-counter.js` - Token计数器

## 示例调用
- `na p-init "我的玄幻小说" 100` - 创建新项目
- `na ns-split "novel.txt" "./projects/我的小说" "我的玄幻小说"` - 分割整本小说
- `na a-analyze "./projects/我的小说" 1 10` - 逐章累积分析
- `na s-full "./projects/我的小说" 1 10 "加入神秘导师"` - 拆换仿完整流程