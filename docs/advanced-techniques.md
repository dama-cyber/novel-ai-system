# 高级技巧

本文档介绍超长篇小说AI创作系统的高级使用技巧。

## 1. 智能上下文构建

### 使用ContextBuilder工具
系统内置的ContextBuilder工具可以智能构建创作上下文：

```javascript
// 在脚本中使用
const ContextBuilder = require('./tools/memory-enhancer.js');
const builder = new ContextBuilder();

const context = builder.buildChapterContext(25, novelData);
// context包含：
// - 核心设定（角色、世界观、力量体系）
// - 近期情节（最近5章）
// - 历史总结（压缩版）
// - 记忆提醒（伏笔、角色状态等）
// - 前情提要
```

### 上下文优化策略
- **核心设定永久保留**：角色、世界观、力量体系等关键信息始终在上下文中
- **近期情节详细保留**：最近5章的情节细节详细保留
- **历史内容压缩**：早期内容通过总结压缩，保留关键信息
- **智能提醒系统**：跟踪伏笔、角色状态、开放情节线

## 2. 自定义提示词

### 修改提示词模板
编辑`prompts/`目录下的文件来自定义创作提示：

```bash
# 修改章节创作提示词
vim prompts/chapter/mid-chapter.txt

# 修改大纲生成提示词
vim prompts/outline/detailed-outline.txt
```

### 提示词模板变量
系统支持以下变量替换：
- `{{GENRE}}` - 小说类型
- `{{CHAPTER_NUM}}` - 章节号
- `{{CHAPTER_TITLE}}` - 章节标题
- `{{CHARACTER_CARDS}}` - 角色设定
- `{{WORLDVIEW}}` - 世界观设定
- `{{POWER_SYSTEM}}` - 力量体系
- `{{RECAP}}` - 前情提要

## 3. 批量处理和自动化

### 多项目并行创作
```bash
# 同时初始化多个项目
./scripts/01-init-project.sh "项目1" 100 &
./scripts/01-init-project.sh "项目2" 50 &
./scripts/01-init-project.sh "项目3" 30 &
wait
```

### 定制化脚本
创建自己的脚本以满足特定需求：

```bash
#!/bin/bash
# 自定义质量控制脚本
PROJECT_DIR=$1

# 运行质量分析
node tools/quality-analyzer.js analyze "$PROJECT_DIR"

# 检查字数统计
WORD_COUNT=$(find "$PROJECT_DIR/chapters" -name "*.md" -exec wc -w {} + | awk 'END{print $1}')
echo "总字数: $WORD_COUNT"

# 生成总结
node scripts/utils/summary-engine.js "$PROJECT_DIR" 1 10
```

## 4. 数据分析和优化

### 使用质量分析工具
```bash
# 分析项目质量
node tools/quality-analyzer.js analyze "./projects/我的小说"

# 获取详细的章节分析
# 分析报告包含：整体评分、剧情创新性、角色发展、语言质量等
```

### Token使用优化
```bash
# 检查Token使用情况
node tools/token-manager.js status

# 估算特定文本的Token数
node tools/token-manager.js estimate "要估算的文本内容"
```

## 5. 高级Git工作流

### 自动化提交信息
```bash
# 生成基于章节变更的提交信息
git add .
git commit -m "完成第1-10章: $(node tools/custom-commit-generator.js)"
```

### 差异分析
```bash
# 分析不同版本间的内容差异
qwen> 分析以下两个版本的差异: @./projects/我的小说/chapters/old 和 @./projects/我的小说/chapters/new
```

## 6. 故障恢复和版本管理

### 自动备份策略
系统在`settings/`目录中定期备份关键设定：

```javascript
// 备份逻辑示例
const backupSettings = async (projectDir) => {
  const settingsDir = path.join(projectDir, 'settings');
  const backupDir = path.join(projectDir, 'backups', new Date().toISOString().split('T')[0]);
  
  // 备份所有设定文件
  await fs.copyFile(path.join(settingsDir, 'characters.json'), path.join(backupDir, 'characters.json'));
  await fs.copyFile(path.join(settingsDir, 'worldview.json'), path.join(backupDir, 'worldview.json'));
  await fs.copyFile(path.join(settingsDir, 'power-system.json'), path.join(backupDir, 'power-system.json'));
};
```

### 状态恢复
```bash
# 从备份恢复设定
./scripts/utils/restore-from-backup.sh "./projects/我的小说" "2025-12-01"
```

## 7. 性能调优

### 并行处理优化
对于大项目，可以调整脚本以优化并行处理：

```bash
# 调整批处理大小
./scripts/03-batch-create.sh "./project" 1 50 --batch-size 5
```

### 内存管理
使用工具监控和管理内存使用：

```bash
# 监控Node.js工具的内存使用
node --max-old-space-size=4096 tools/quality-analyzer.js analyze "./large-project"
```

## 8. 扩展开发

### 添加新的工具
可以创建新的工具脚本来扩展系统功能：

```javascript
// 新工具示例：情节线追踪器
class PlotTracker {
  constructor(projectDir) {
    this.projectDir = projectDir;
    this.plotlines = new Map();
  }

  async analyzePlotlines() {
    // 实现情节线分析逻辑
  }

  async generateReport() {
    // 生成情节线报告
  }
}
```

### 集成外部API
系统设计为可扩展，可以集成其他AI服务或数据源：

```javascript
// 示例：集成外部角色档案服务
const externalCharacterService = {
  async enrichCharacter(character) {
    // 调用外部API丰富角色信息
    return enhancedCharacter;
  }
};
```

这些高级技巧可以帮助您更高效地使用超长篇小说AI创作系统，并根据特定需求进行定制。