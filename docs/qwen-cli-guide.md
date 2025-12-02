# Qwen CLI使用指南

本文档介绍如何在小说创作系统中有效使用Qwen CLI。

## 1. Qwen CLI基础

### 安装和授权
```bash
# 安装Qwen CLI
npm install -g @qwen-code/qwen-code@latest

# 授权（推荐使用Qwen OAuth，每天2000次免费请求）
qwen auth
```

### 基本命令
```bash
# 查看版本
qwen --version

# 进入交互模式
qwen

# 执行单次请求
echo "你的问题" | qwen

# 查看会话统计信息
qwen /stats

# 压缩会话历史
qwen /compress
```

## 2. 会话模式管理

### 不同审批模式
```bash
# Plan模式：仅分析，不修改文件
qwen> /approval-mode plan
qwen> 分析这个小说大纲的逻辑性和完整性

# Default模式：需要审批的修改
qwen> /approval-mode default
qwen> 创作第10章
# 系统会展示计划，需要用户确认

# Auto-edit模式：自动批准编辑
qwen> /approval-mode auto-edit
qwen> 批量创作第11-15章
```

## 3. 仓库级理解功能

Qwen CLI可以理解整个项目结构，这在小说创作中特别有用：

### 分析整个项目
```bash
# 分析所有章节
qwen> @./projects/我的小说 分析所有章节中主角的性格变化

# 检查一致性
qwen> @./projects/我的小说 检查世界观设定的一致性

# 生成总结
qwen> @./projects/我的小说 生成整本小说的情节总结
```

### 特定文件分析
```bash
# 分析特定章节
qwen> @./projects/我的小说/chapters/chapter_001*.md 分析第一章的写作质量

# 比较多个文件
qwen> @./projects/我的小说/settings 比较角色设定和实际写作的匹配度
```

## 4. 上下文管理

### 查看当前上下文
```bash
qwen> /stats  # 查看当前会话的Token使用情况
```

### 管理会话历史
```bash
# 压缩会话，移除不重要的历史
qwen> /compress

# 清空会话（谨慎使用）
qwen> /reset
```

## 5. 高级技巧

### 使用变量
可以在提示中使用文件内容作为变量：

```bash
# 将设定作为上下文
qwen> 以下是世界观设定：@./projects/我的小说/settings/worldview.json 请按照这个设定创作第5章
```

### 批量处理
结合shell脚本进行批量处理：

```bash
# 批量分析多个章节
for file in ./projects/我的小说/chapters/*.md; do
  echo "分析文件: $file"
  qwen> @.$file 找出主要情节和角色活动
done
```

## 6. 配置优化

### 会话配置
在 `config/qwen-settings.json` 中配置：

```json
{
  "sessionTokenLimit": 32000,
  "experimental": {
    "vlmSwitchMode": "once",
    "visionModelPreview": false
  },
  "novel": {
    "autoSave": true,
    "autoBackup": true,
    "backupInterval": 10,
    "compressionThreshold": 25000
  }
}
```

### 性能优化建议
- 定期压缩会话历史以保持性能
- 使用适当的审批模式以提高效率
- 合理利用文件引用功能，避免重复输入设定
- 分批处理大量内容以避免Token超限