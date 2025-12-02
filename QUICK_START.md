# 快速开始指南

## 系统要求
- Node.js 20.x 或更高版本
- Qwen CLI (已授权)
- Git for Windows (Windows用户) 或 WSL
- 稳定的网络连接

## 安装步骤

### 1. 安装 Node.js
- 访问 [Node.js 官网](https://nodejs.org/)
- 下载并安装 20.x 或更高版本

### 2. 安装 Qwen CLI
```bash
npm install -g @qwen-code/qwen-code@latest
```

### 3. 授权 Qwen CLI
```bash
qwen auth
```
选择 Qwen OAuth 并按提示完成授权。

### 4. 下载系统
```bash
git clone https://github.com/yourusername/novel-ai-system-v16.git
cd novel-ai-system-v16
```

### 5. 验证安装
```bash
# 在 Git Bash 或 WSL 中运行
node tools/diagnostic.js
node tools/validation-checker.js
```

## 快速创作您的第一部小说

### 方法1：一键自动化创作
```bash
# 在 Git Bash 或 WSL 中运行
./scripts/11-unified-workflow.sh -a "我的第一部小说" 10 "玄幻" "主角" "废材逆袭"
```

### 方法2：交互式创作
```bash
# 在 Git Bash 或 WSL 中运行
./scripts/11-unified-workflow.sh -i
```

### 方法3：分步创作
```bash
# 1. 初始化项目
./scripts/01-init-project.sh "我的小说" 50

# 2. 生成大纲
./scripts/02-create-outline.sh "./projects/我的小说" 50

# 3. 批量创作章节
./scripts/03-batch-create.sh "./projects/我的小说" 1 50

# 4. 质量检查
./scripts/04-quality-check.sh "./projects/我的小说"
```

## 核心功能介绍

### 沙盒创作法
先创作前10章验证核心设定，再扩展至完整小说：
```bash
# 初始化项目
./scripts/20-sandbox-creation.sh init "沙盒项目" 100 "玄幻"

# 沙盒阶段（前10章）
./scripts/20-sandbox-creation.sh sandbox "./projects/沙盒项目"

# 扩展阶段（第11-100章）
./scripts/20-sandbox-creation.sh expand "./projects/沙盒项目" 11 100

# 完成整个流程
./scripts/20-sandbox-creation.sh complete "./projects/沙盒项目"
```

### 拆书分析与换元仿写
分析现有章节，设计替换元素，重新创作：
```bash
# 分析第1-10章
./scripts/21-combined-revision.sh analyze "./projects/我的小说" 1 10

# 设计加入新元素（例如：神秘导师）
./scripts/21-combined-revision.sh swap "./projects/我的小说" 1 10 "加入神秘导师"

# 仿写实施
./scripts/21-combined-revision.sh rewrite "./projects/我的小说" 1 10 "加入神秘导师"

# 完整流程
./scripts/21-combined-revision.sh full "./projects/我的小说" 1 10 "加入神秘导师"
```

### 逐章累积分析
对章节进行逐章分析并累积形成完整报告：
```bash
# 初始化累积分析
./scripts/25-chapter-by-chapter-analyzer.sh init "./projects/我的小说" "小说名"

# 分析第1章并累积
./scripts/25-chapter-by-chapter-analyzer.sh analyze "./projects/我的小说" 1 "./chapters/chapter_001_content.txt"

# 分析第2章并累积
./scripts/25-chapter-by-chapter-analyzer.sh analyze "./projects/我的小说" 2 "./chapters/chapter_002_content.txt"

# 查看当前累积报告
./scripts/25-chapter-by-chapter-analyzer.sh view "./projects/我的小说"

# 导出累积报告
./scripts/25-chapter-by-chapter-analyzer.sh export "./projects/我的小说" "./exports/accumulated-analysis.md"
```

## 增强功能

### 章节修改和优化
```bash
# 修改指定章节
./scripts/14-enhancement-suite.sh revise "./projects/我的小说/chapters/chapter_001_标题.md"

# 优化章节质量
./scripts/14-enhancement-suite.sh optimize "./projects/我的小说/chapters/chapter_001_标题.md"

# 续写指定章节
./scripts/14-enhancement-suite.sh continue "./projects/我的小说" 10
```

### 项目分析和导出
```bash
# 项目质量分析
./scripts/14-enhancement-suite.sh analyze "./projects/我的小说"

# 导出为不同格式
./scripts/15-novelwriter-integration.sh export-md "./projects/我的小说" "./exports/我的小说.md"
./scripts/15-novelwriter-integration.sh export-html "./projects/我的小说" "./exports/我的小说.html"

# 高级分析
./scripts/16-novelwriter-advanced.sh chapter-stats "./projects/我的小说"
./scripts/16-novelwriter-advanced.sh pov-analysis "./projects/我的小说"
./scripts/17-lexicraftai-integration.sh vocabulary-analysis "./projects/我的小说"
```

## 系统维护

### 验证系统完整性
```bash
# 检查系统组件
node tools/validation-checker.js

# 运行错误检查
./scripts/99-error-checker.sh

# 验证项目完整性
./scripts/98-project-validator.sh
```

## 常见问题

### Windows 用户运行脚本问题
如果在 Windows 上无法运行 `.sh` 脚本，请安装 Git for Windows 并使用 Git Bash 终端，或使用 WSL。

### Token 限制问题
- 系统自动管理会话历史和 Token 使用
- 如遇 Token 超限，系统会自动压缩会话历史
- 建议每创作约10章后暂停一下让模型"休息"

### API 请求限制
- Qwen CLI 每日有 2000 次请求限制
- 100章小说大约需要 500-1000 次请求
- 如果用完当日限额，第二天可继续使用

## 技巧和最佳实践

1. **定期备份项目**：在开始新阶段前备份项目
2. **分批创作**：建议每批创作10-20章，避免 Token 超限
3. **完善设定**：在创作前完善世界观和角色设定
4. **质量检查**：创作完成后运行质量检查脚本

## 资源链接

- [完整使用文档](README.md)
- [系统功能索引](SKILLS.md)
- [模块功能说明](MODULE_INDEX.md)
- [示例项目](examples/)