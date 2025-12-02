# 最佳实践

本文档介绍使用超长篇小说AI创作系统的最佳实践。

## 1. 分批创作策略

建议每次创作10-20章，分多次完成大部头作品：

```bash
# 推荐：每次10-20章，分多次创作
./scripts/03-batch-create.sh "./project" 1 20    # 第1批
./scripts/03-batch-create.sh "./project" 21 40   # 第2批
./scripts/03-batch-create.sh "./project" 41 60   # 第3批
```

这样做的好处：
- 更容易控制质量和一致性
- 减少Token压力
- 可以根据前期创作调整后续计划

## 2. 定期备份

每创作10章备份一次项目：

```bash
# 每创作10章备份一次
cd projects/我的小说
git add .
git commit -m "完成10章"
git push
```

## 3. 人工精修

AI生成80% + 人工精修20%，重点关注：

- 删除AI腔句式（如"然而"、"显然"、"毫无疑问"）
- 补充细节和情感描写
- 调整节奏和张力
- 优化对话和动作描写
- 检查逻辑连贯性

## 4. 有效利用Qwen CLI能力

### 仓库级理解
```bash
qwen> @./projects/我的小说 分析所有章节中主角的性格变化

qwen> @./projects/我的小说 找出所有未回收的伏笔

qwen> @./projects/我的小说 生成整本小说的角色关系图
```

### 智能会话管理
```bash
# 大纲阶段：plan模式（仅分析，不修改文件）
qwen> /approval-mode plan
qwen> 分析这个小说大纲的逻辑性和完整性

# 创作阶段：default模式（需要审批）
qwen> /approval-mode default
qwen> 创作第10章
# 系统会先展示计划，等待用户确认

# 批量创作：auto-edit模式（自动批准编辑）
qwen> /approval-mode auto-edit
qwen> 批量创作第11-15章
```

## 5. Token管理策略

- **Token限制**: 32000 tokens (Qwen CLI)
- **安全阈值**: 25000 tokens (保留20%余量)
- **定期压缩**: 每5章主动压缩会话历史
- **智能上下文**: 只保留核心设定，压缩历史内容

## 6. 设定文件维护

定期更新和优化设定文件以保持一致性：

- `characters.json` - 角色档案
- `worldview.json` - 世界观设定
- `power-system.json` - 力量体系
- `foreshadows.json` - 伏笔记录

## 7. 质量控制

在创作过程中定期运行质量检查：

```bash
./scripts/04-quality-check.sh "./projects/我的小说"
```

关注以下指标：
- 情节连贯性
- 角色一致性
- 世界观统一性
- 语言质量