# 超长篇小说AI创作系统CLI文档

## 概述

超长篇小说AI创作系统提供了一套完整的命令行工具，用于自动化小说创作流程。这些工具支持从项目初始化到小说生成、优化和质量检查的完整流程。

## 前置要求

在使用CLI之前，请确保：
- 已安装Node.js（版本20.0或更高）
- 已安装Qwen CLI并完成授权
- 已安装Git
- 已完成项目的安装和配置

## 核心脚本说明

### 1. 项目初始化脚本
```bash
./scripts/01-init-project.sh <项目名称> <章节数>
```
- 创建一个新的小说项目目录结构
- 参数：
  - `<项目名称>`: 新项目的名称
  - `<章节数>`: 预计小说的总章节数

### 2. 大纲生成脚本
```bash
./scripts/02-create-outline.sh <项目目录> <章节数> <小说类型> <主角> <核心冲突>
```
- 基于给定信息生成小说大纲
- 参数：
  - `<项目目录>`: 项目的完整路径
  - `<章节数>`: 小说的章节数量
  - `<小说类型>`: 小说的类型（如玄幻、科幻等）
  - `<主角>`: 小说的主角
  - `<核心冲突>`: 小说的核心冲突

### 3. 批量创作章节脚本
```bash
./scripts/03-batch-create.sh <项目目录> <起始章节> <结束章节>
```
- 批量生成指定范围内的小说章节
- 参数：
  - `<项目目录>`: 项目目录路径
  - `<起始章节>`: 起始章节号
  - `<结束章节>`: 结束章节号

### 4. 质量检查脚本
```bash
./scripts/04-quality-check.sh <项目目录>
```
- 分析和检查小说内容的质量
- 参数：
  - `<项目目录>`: 项目目录路径

### 5. 会话压缩脚本
```bash
./scripts/05-compress-session.sh <项目目录>
```
- 压缩和优化创作过程中的历史数据
- 参数：
  - `<项目目录>`: 项目目录路径

### 6. 拆书分析脚本
```bash
./scripts/06-split-book.sh <项目目录> <起始章节> <结束章节>
```
- 对指定章节范围进行详细分析
- 参数：
  - `<项目目录>`: 项目目录路径
  - `<起始章节>`: 起始章节号
  - `<结束章节>`: 结束章节号

### 7. 文体工程脚本
```bash
./scripts/07-style-engineer.sh <项目目录> <目标风格> <起始章节> <结束章节>
```
- 将文本转换为指定的写作风格
- 参数：
  - `<项目目录>`: 项目目录路径
  - `<目标风格>`: 目标文体风格
  - `<起始章节>`: 起始章节号
  - `<结束章节>`: 结束章节号

### 8. 拆书-换元-仿写脚本
```bash
./scripts/08-revise-book.sh <项目目录> <起始章节> <结束章节> <新元素描述>
```
- 执行拆书、换元、仿写的完整流程
- 参数：
  - `<项目目录>`: 项目目录路径
  - `<起始章节>`: 起始章节号
  - `<结束章节>`: 结束章节号
  - `<新元素描述>`: 需要添加的新元素描述

### 9. 完整工作流程脚本
```bash
./scripts/09-full-workflow.sh <项目目录>
```
- 执行从初始化到完成的完整工作流程
- 参数：
  - `<项目目录>`: 项目目录路径

### 10. 统一工作流脚本
```bash
./scripts/11-unified-workflow.sh <项目目录> <动作> [参数...]
```
- 统一接口，支持多种操作
- 动作选项：
  - `analyze`: 拆书分析
  - `style`: 文体工程
  - `revise`: 拆书换元
  - `frankentexts`: Frankentexts融合拼接
  - `enhance`: 增强套件
  - `full`: 完整流程
  - `cleanup`: 清理旧版
- 使用示例：
  ```bash
  # 拆书分析
  ./scripts/11-unified-workflow.sh "./projects/小说" analyze 1 10
  
  # 文体工程
  ./scripts/11-unified-workflow.sh "./projects/小说" style "轻松幽默" 1 10
  
  # 拆书-换元-仿写
  ./scripts/11-unified-workflow.sh "./projects/小说" revise 1 10 "加入新角色"
  ```

### 11. 清理旧版本脚本
```bash
./scripts/12-purge-old-versions.sh <项目目录>
```
- 删除旧版章节文件，保持项目结构清洁
- 参数：
  - `<项目目录>`: 项目目录路径

### 12. Frankentexts融合拼接脚本
```bash
./scripts/13-frankentexts-integration.sh <项目目录> <章节号> [迭代次数]
```
- 使用Frankentexts方法优化指定章节
- 参数：
  - `<项目目录>`: 项目目录路径
  - `<章节号>`: 需要优化的章节号
  - `[迭代次数]`: 优化迭代次数（可选，默认为100）

## 使用示例

### 完整创作流程
```bash
# 1. 初始化项目
./scripts/01-init-project.sh "我的玄幻小说" 100

# 2. 生成大纲（提供类型、主角、冲突）
./scripts/02-create-outline.sh "./projects/我的玄幻小说" 100 "玄幻" "林轩" "废材逆袭，挑战权威"

# 3. 批量创作章节
./scripts/03-batch-create.sh "./projects/我的玄幻小说" 1 100

# 4. 质量检查
./scripts/04-quality-check.sh "./projects/我的玄幻小说"
```

### 优化和修订流程
```bash
# 方式1: 使用统一工作流脚本（推荐）
./scripts/11-unified-workflow.sh "./projects/我的玄幻小说" full 1 10 "加入神秘导师角色"

# 方式2: Frankentexts融合拼接优化
./scripts/11-unified-workflow.sh "./projects/我的玄幻小说" frankentexts 5 100

# 方式3: 分步执行
# 3.1 拆书分析
./scripts/06-split-book.sh "./projects/我的玄幻小说" 1 10

# 3.2 拆书-换元-仿写
./scripts/08-revise-book.sh "./projects/我的玄幻小说" 1 10 "加入神秘导师角色"

# 3.3 Frankentexts融合拼接（关键章节）
./scripts/13-frankentexts-integration.sh "./projects/我的玄幻小说" 5 50

# 3.4 文体工程（可选）
./scripts/07-style-engineer.sh "./projects/我的玄幻小说" "轻松幽默" 1 10

# 3.5 清理旧版本
./scripts/11-unified-workflow.sh "./projects/我的玄幻小说" cleanup
```

## 配置文件

系统使用 `config/qwen-settings.json` 文件进行配置，主要参数包括：
- `sessionTokenLimit`: 会话Token限制（默认32000）
- `tokenSafetyMargin`: Token安全余量（默认7000）
- `novel` 部分包含小说创作相关配置
- `revision` 部分包含修订流程相关配置

## 故障排除

如果遇到问题：
1. 运行诊断工具检查环境：`node tools/diagnostic.js`
2. 检查Qwen CLI是否正确授权：`qwen auth`
3. 确保有足够的磁盘空间和网络连接

## 注意事项

- 建议每次创作10-20章后进行备份
- 定期使用质量检查脚本确保内容一致
- 使用拆书分析功能检查情节连贯性
- 保持项目目录结构不被意外修改