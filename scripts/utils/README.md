# 超长篇小说AI创作系统 - 工具模块

## 概述

这是超长篇小说AI创作系统 (v16.0) 的工具模块集合，包含令牌管理、摘要生成和文件管理功能。

## 组件列表

### 1. TokenManager (令牌管理器)

TokenManager 是一个用于监控和管理Qwen CLI令牌使用的组件，遵循SOLID设计原则。

#### 功能特性
- 令牌估算：支持中英文混合文本的令牌估算
- 令牌监控：监控当前会话的令牌使用情况
- 令牌检查：验证是否有足够的令牌执行操作
- Qwen调用：封装Qwen CLI的调用逻辑
- 自动压缩：当令牌使用接近限制时自动压缩会话

#### 安装和使用

```javascript
const { TokenManager } = require('./scripts/utils/token-manager.js');

// 创建TokenManager实例
const tokenManager = new TokenManager();

// 估算文本令牌数
const tokens = tokenManager.estimateTokens('这是一个测试文本');
console.log(`估算令牌数: ${tokens}`);

// 检查是否有足够的令牌
const hasEnough = await tokenManager.hasEnoughTokens(1000);
if (hasEnough) {
  // 调用Qwen
  const response = await tokenManager.callQwen('写一个简短的故事');
  console.log(response);
}
```

#### API 参考

- `estimateTokens(text)` - 估算文本令牌数
- `getSessionTokenUsage()` - 获取当前令牌使用情况
- `hasEnoughTokens(requiredTokens)` - 检查令牌是否充足
- `callQwen(prompt, options)` - 调用Qwen
- `autoCompress()` - 自动压缩会话

### 2. SummaryEngine (摘要引擎)

SummaryEngine 负责生成章节摘要、回顾和长期记忆，包含缓存机制以提高性能。

#### 功能特性
- 摘要生成：为长文本生成简洁摘要
- 缓存机制：使用LRU缓存避免重复计算
- 分块处理：自动处理超长文本
- 章节摘要：为小说章节生成摘要

#### 安装和使用

```javascript
const SummaryEngine = require('./scripts/utils/summary-engine.js');

// 创建SummaryEngine实例
const summaryEngine = new SummaryEngine();

// 生成文本摘要
const summary = await summaryEngine.processLongText('这是一个很长的文本...');
console.log(summary);

// 获取缓存统计
const stats = summaryEngine.getCacheStats();
console.log(`缓存使用率: ${stats.utilization}%`);
```

#### API 参考

- `generateSummaryWithCache(text, options)` - 带缓存的摘要生成
- `processLongText(text, options)` - 处理长文本
- `generateChapterSummary(projectDir, startChapter, endChapter, options)` - 生成章节摘要
- `clearCache()` - 清除缓存
- `getCacheStats()` - 获取缓存统计

### 3. FileManager (文件管理器)

FileManager 提供小说项目文件的管理功能，使用async/await模式和全面的错误处理。

#### 功能特性
- 异步文件操作：使用Promise和async/await
- 文件类型管理：JSON文件读写、章节文件管理
- 设置管理：项目设置的加载和保存
- 错误处理：全面的错误处理机制
- 事件通知：操作状态的事件发射

#### 安装和使用

```javascript
const FileManager = require('./scripts/utils/file-manager.js');

// 创建FileManager实例
const fileManager = new FileManager();

// 读取项目设置
const settings = await fileManager.getProjectSettings('./my-project');

// 获取章节文件列表
const chapterFiles = await fileManager.getChapterFiles('./my-project');
console.log(`找到 ${chapterFiles.length} 个章节文件`);
```

#### API 参考

- `directoryExists(dirPath)` - 检查目录是否存在
- `fileExists(filePath)` - 检查文件是否存在
- `ensureDirectory(dirPath)` - 确保目录存在
- `readJsonFile(filePath)` - 读取JSON文件
- `writeJsonFile(filePath, data)` - 写入JSON文件
- `getChapterFiles(projectDir)` - 获取章节文件列表
- `getProjectSettings(projectDir)` - 获取项目设置
- `saveProjectSettings(projectDir, settings)` - 保存项目设置
- `readChapter(chapterPath)` - 读取章节内容
- `writeChapter(chapterPath, content)` - 写入章节内容
- `updateCurrentChapter(projectDir, chapterNum)` - 更新当前章节
- `getLatestChapterNumber(projectDir)` - 获取最新章节号

## 单元测试

所有组件都包含全面的单元测试，包括边缘情况处理：

- `tests/unit/test-token-manager.js` - TokenManager测试
- `tests/unit/test-summary-engine.js` - SummaryEngine测试
- `tests/unit/test-file-manager.js` - FileManager测试

运行测试：
```bash
# 运行TokenManager测试
node tests/unit/test-token-manager.js

# 运行SummaryEngine测试
node tests/unit/test-summary-engine.js

# 运行FileManager测试
node tests/unit/test-file-manager.js
```

## 设计原则

这些组件遵循以下设计原则：

- **SOLID原则**：在TokenManager中实现接口分离、依赖倒置等原则
- **缓存机制**：SummaryEngine中的LRU缓存提升性能
- **异步操作**：FileManager使用async/await提高效率
- **错误处理**：全面的错误处理和事件发射机制
- **可扩展性**：通过策略模式实现功能扩展

## 许可证

MIT License