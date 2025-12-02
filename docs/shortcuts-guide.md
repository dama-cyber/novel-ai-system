# 小说AI系统简化指令使用手册

## 简介

本系统提供了简化指令，前缀为`na`（NovelAI的简写），便于快速调用各种功能。这些指令映射到完整的脚本模块，实现快速操作。

## 指令格式

```
na <主命令> <子命令> [参数]
```

## 主命令索引

### p - 项目管理 (Project Management)
- `na p-init <项目名> <章节数>` - 初始化项目
- `na p-outline <项目路径> <章节数>` - 生成大纲
- `na p-create <项目路径> <起始章> <结束章>` - 批量创作章节
- `na p-check <项目路径>` - 质量检查
- `na p-compress <项目路径>` - 会话压缩

### s - 拆书分析 (Split Book Analysis) 
- `na s-analyze <项目路径> <起始章> <结束章>` - 拆书分析
- `na s-swap <项目路径> <起始章> <结束章> <新元素>` - 换元设计
- `na s-rewrite <项目路径> <起始章> <结束章> <新元素>` - 仿写实施
- `na s-full <项目路径> <起始章> <结束章> <新元素>` - 完整流程

### x - 沙盒创作 (SandboX Creation)
- `na x-init <项目名> <章节数> <类型>` - 初始化项目
- `na x-sbox <项目路径>` - 沙盒阶段创作
- `na x-expand <项目路径> <起始章> <结束章>` - 扩展阶段创作
- `na x-complete <项目路径>` - 完成整个创作流程
- `na x-analyze <项目路径>` - 分析项目完整性

### e - 增强功能 (Enhancement)
- `na e-cont <项目路径> <章节号>` - 续写章节
- `na e-revise <章节路径>` - 修改章节
- `na e-opt <章节路径>` - 优化章节
- `na e-analyze <项目路径>` - 分析项目质量
- `na e-expand <章节路径> <位置>` - 扩展章节内容

### n - NovelWriter集成 (NovelWriter Integration)
- `na n-md <项目路径> <输出路径>` - 导出为Markdown
- `na n-html <项目路径> <输出路径>` - 导出为HTML
- `na n-analyze <项目路径>` - 分析项目结构
- `na n-scenes <项目路径>` - 将章节拆分为场景
- `na n-compile <项目路径> <输出路径>` - 编译完整书籍

### na - NovelWriter高级 (NovelWriter Advanced)
- `na na-wc <项目路径>` - 字数统计
- `na na-stats <项目路径>` - 章节统计
- `na na-pov <项目路径>` - 视角分析
- `na na-dial <项目路径>` - 对话检查
- `na na-read <项目路径>` - 可读性分析
- `na na-timeline <项目路径>` - 时间线分析
- `na na-char <项目路径>` - 角色追踪
- `na na-cons <项目路径>` - 一致性检查

### l - LexicraftAI集成 (LexicraftAI Integration)
- `na l-vocab <项目路径>` - 词汇分析
- `na l-freq <项目路径>` - 词频统计
- `na l-syn <项目路径>` - 同义词替换
- `na l-style <项目路径>` - 风格分析
- `na l-sent <项目路径>` - 情感分析
- `na l-read <项目路径>` - 可读性改进
- `na l-gen <项目路径>` - 生成词汇表
- `na l-exp <项目路径> <输出路径>` - 导出词典
- `na l-ctx <项目路径>` - 上下文优化
- `na l-prose <项目路径>` - 散文增强

### sys - 系统工具 (System Tools)
- `na sys-val <项目路径>` - 项目完整性验证
- `na sys-fix <项目路径>` - 项目错误检查和修复

### fv - 流程可视化 (Flow Visualization)
- `na fv-show` - 查看小说生成流程图
- `na fv-cmds` - 查看快速开始命令

### w - 工作流 (Workflow)
- `na w-iflow -i` - 交互式工作流
- `na w-iflow -a <项目名> <章节数> <类型> <主角> <冲突>` - 自动工作流

## 使用示例

```bash
# 创建新项目
na p-init "我的玄幻小说" 100

# 生成大纲
na p-outline "./projects/我的玄幻小说" 100

# 创作前10章
na p-create "./projects/我的玄幻小说" 1 10

# 对第1-10章进行拆书分析
na s-analyze "./projects/我的小说" 1 10

# 为第1-10章设计加入新角色
na s-swap "./projects/我的小说" 1 10 "加入神秘导师角色"

# 实施仿写，融入新角色
na s-rewrite "./projects/我的小说" 1 10 "加入神秘导师角色"

# 沙盒创作流程
na x-init "我的小说" 100 "玄幻"
na x-sbox "./projects/我的小说"
na x-expand "./projects/我的小说" 11 100

# 质量分析
na na-stats "./projects/我的小说"
na l-vocab "./projects/我的小说"

# 项目验证
na sys-val "./projects/我的小说"
```

## 指令映射关系

所有简化指令最终会映射到对应的完整脚本，例如：
- `na p-create "./project" 1 10` → `./scripts/03-batch-create.sh "./project" 1 10`
- `na s-analyze "./project" 1 5` → `./scripts/22-split-book-analyzer.sh "./project" 1 5`
- `na x-sbox "./project"` → `./scripts/20-sandbox-creation.sh sandbox "./project"`

## 优势

1. **快速调用**: 简化指令减少键盘输入
2. **不易冲突**: 使用`na`前缀避免与系统命令冲突
3. **易于记忆**: 功能缩写便于记忆
4. **完整功能**: 所有简化指令映射到完整模块
5. **跨平台**: 在Windows、macOS、Linux上均可使用

## 注意事项

- 所有路径参数需要用引号包围，特别是包含空格的路径
- 参数顺序需严格按照说明提供
- 使用前请确保Qwen CLI已正确安装和授权