/**
 * Express服务器 - 为小说创作系统提供API接口
 * 集成认证、限速等中间件
 */

const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const path = require('path');

// 导入工具模块
const TokenManager = require('../scripts/utils/token-manager.js');
const SummaryEngine = require('../scripts/utils/summary-engine.js');
const FileManager = require('../scripts/utils/file-manager.js');

const app = express();

// 安全中间件
app.use(helmet());

// CORS配置
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:3001'],
  credentials: true
}));

// 请求体解析
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// 限速中间件
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 限制每个IP 15分钟内最多100个请求
  message: {
    error: '请求过于频繁，请稍后再试',
    retryAfter: '60秒'
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// 另一个更严格的限速器用于认证端点
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 5, // 限制每个IP 15分钟内最多5次认证请求
  message: {
    error: '登录尝试次数过多，请稍后再试',
    retryAfter: '15分钟'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// 模拟用户数据库（实际应用中应使用真实数据库）
const users = new Map();

// 认证中间件
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: '访问被拒绝，缺少认证令牌' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your-super-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: '令牌无效或已过期' });
    }
    req.user = user;
    next();
  });
};

// 路由

// 注册
app.post('/api/auth/register', authLimiter, async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: '用户名和密码为必填项' });
    }

    if (users.has(username)) {
      return res.status(409).json({ error: '用户名已存在' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    users.set(username, {
      id: Date.now().toString(),
      username,
      password: hashedPassword,
      createdAt: new Date()
    });

    res.status(201).json({ message: '注册成功' });
  } catch (error) {
    res.status(500).json({ error: '注册失败', details: error.message });
  }
});

// 登录
app.post('/api/auth/login', authLimiter, async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: '用户名和密码为必填项' });
    }

    const user = users.get(username);
    if (!user) {
      return res.status(401).json({ error: '用户名或密码错误' });
    }

    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: '用户名或密码错误' });
    }

    const token = jwt.sign(
      { 
        id: user.id, 
        username: user.username 
      },
      process.env.JWT_SECRET || 'your-super-secret-key',
      { expiresIn: '24h' }
    );

    res.json({ 
      message: '登录成功', 
      token,
      user: {
        id: user.id,
        username: user.username
      }
    });
  } catch (error) {
    res.status(500).json({ error: '登录失败', details: error.message });
  }
});

// 获取当前用户信息
app.get('/api/auth/me', authenticateToken, (req, res) => {
  res.json({
    user: {
      id: req.user.id,
      username: req.user.username
    }
  });
});

// 项目相关路由

// 创建新项目
app.post('/api/projects', authenticateToken, async (req, res) => {
  try {
    const { name, chapterCount, genre } = req.body;
    const projectPath = path.join(__dirname, '..', 'projects', name);
    
    // 使用现有的初始化脚本逻辑
    const fileManager = new FileManager();
    await fileManager.ensureDirectory(projectPath);
    await fileManager.ensureDirectory(path.join(projectPath, 'chapters'));
    await fileManager.ensureDirectory(path.join(projectPath, 'settings'));
    await fileManager.ensureDirectory(path.join(projectPath, 'summaries'));
    
    // 创建基本设置文件
    await fileManager.writeJsonFile(
      path.join(projectPath, 'settings', 'characters.json'), 
      { protagonist: { name: '', description: '', personality: '', abilities: [], development: [], characterArc: [] }, supporting: [], antagonists: [] }
    );
    
    await fileManager.writeJsonFile(
      path.join(projectPath, 'settings', 'worldview.json'),
      { setting: '', rules: {}, cultures: [], geography: '', history: '', magicSystem: {}, technologyLevel: '', socialStructure: '' }
    );
    
    await fileManager.writeJsonFile(
      path.join(projectPath, 'settings', 'power-system.json'),
      { name: '', levels: [], requirements: '', limitations: '', acquisitionMethod: '', trainingProcess: '', powerSources: [] }
    );
    
    await fileManager.writeJsonFile(
      path.join(projectPath, 'settings', 'foreshadows.json'),
      { active: [], resolved: [], planned: [], plotThreads: [] }
    );
    
    const metadata = {
      title: name,
      chapterCount: chapterCount || 100,
      createdAt: new Date().toISOString(),
      lastModified: new Date().toISOString(),
      status: 'initialized',
      currentChapter: 0,
      totalWords: 0,
      genre: genre || 'novel'
    };
    
    await fileManager.writeJsonFile(path.join(projectPath, 'metadata.json'), metadata);

    res.status(201).json({ 
      message: '项目创建成功', 
      project: { name, path: projectPath, metadata } 
    });
  } catch (error) {
    res.status(500).json({ error: '项目创建失败', details: error.message });
  }
});

// 获取所有项目
app.get('/api/projects', authenticateToken, async (req, res) => {
  try {
    const projectsDir = path.join(__dirname, '..', 'projects');
    const fileManager = new FileManager();
    
    if (!(await fileManager.directoryExists(projectsDir))) {
      return res.json({ projects: [] });
    }
    
    const projectNames = await fs.promises.readdir(projectsDir);
    const projects = [];
    
    for (const projectName of projectNames) {
      const projectPath = path.join(projectsDir, projectName);
      if (await fileManager.directoryExists(projectPath)) {
        const metadataPath = path.join(projectPath, 'metadata.json');
        if (await fileManager.fileExists(metadataPath)) {
          const metadata = await fileManager.readJsonFile(metadataPath);
          projects.push({
            name: projectName,
            path: projectPath,
            metadata
          });
        }
      }
    }
    
    res.json({ projects });
  } catch (error) {
    res.status(500).json({ error: '获取项目列表失败', details: error.message });
  }
});

// 生成大纲
app.post('/api/projects/:projectName/outline', authenticateToken, async (req, res) => {
  try {
    const { projectName } = req.params;
    const { genre, protagonist, mainConflict } = req.body;
    
    // 这里可以实现大纲生成功能
    // 暂时返回模拟响应
    res.json({
      message: '大纲生成成功',
      outline: {
        projectName,
        chapters: Array.from({ length: 10 }, (_, i) => ({
          number: i + 1,
          title: `第${i + 1}章 - 章节标题`,
          summary: `第${i + 1}章的概要内容`,
          keyEvents: ['关键事件1', '关键事件2']
        }))
      }
    });
  } catch (error) {
    res.status(500).json({ error: '大纲生成失败', details: error.message });
  }
});

// 生成章节
app.post('/api/projects/:projectName/chapters/:chapterNumber', authenticateToken, async (req, res) => {
  try {
    const { projectName, chapterNumber } = req.params;
    const projectPath = path.join(__dirname, '..', 'projects', projectName);
    const fileManager = new FileManager();
    
    // 验证项目是否存在
    if (!(await fileManager.directoryExists(projectPath))) {
      return res.status(404).json({ error: '项目不存在' });
    }
    
    // 使用TokenManager和Qwen生成章节内容
    const tokenManager = new TokenManager();
    
    // 构建提示词
    const prompt = `请创作小说《${projectName}》的第${chapterNumber}章。
    
    创作要求：
    - 保持故事连贯性
    - 符合角色设定
    - 控制在3000字左右
    - 包含适当的对话和叙述
    `;
    
    // 模拟生成内容（在实际实现中，这里会调用Qwen）
    const chapterContent = `# 第${chapterNumber}章 - 章节标题

这是第${chapterNumber}章的内容。

故事继续发展...

（此处为AI生成的内容）

章节结束。`;
    
    const chapterFileName = `chapter_${String(chapterNumber).padStart(3, '0')}_generated.md`;
    const chapterFilePath = path.join(projectPath, 'chapters', chapterFileName);
    
    await fileManager.writeChapter(chapterFilePath, chapterContent);
    
    res.json({
      message: '章节生成成功',
      chapter: {
        number: parseInt(chapterNumber),
        title: `第${chapterNumber}章 - 章节标题`,
        path: chapterFilePath,
        wordCount: chapterContent.split(/\s+/).length
      }
    });
  } catch (error) {
    res.status(500).json({ error: '章节生成失败', details: error.message });
  }
});

// 获取章节内容
app.get('/api/projects/:projectName/chapters/:chapterNumber', authenticateToken, async (req, res) => {
  try {
    const { projectName, chapterNumber } = req.params;
    const projectPath = path.join(__dirname, '..', 'projects', projectName);
    const fileManager = new FileManager();
    
    // 查找章节文件
    const chapterFiles = await fileManager.getChapterFiles(projectPath);
    const targetFile = chapterFiles.find(f => 
      path.basename(f).startsWith(`chapter_${String(chapterNumber).padStart(3, '0')}_`)
    );
    
    if (!targetFile) {
      return res.status(404).json({ error: '章节不存在' });
    }
    
    const content = await fileManager.readChapter(targetFile);
    
    res.json({
      chapter: {
        number: parseInt(chapterNumber),
        path: targetFile,
        content,
        wordCount: content.split(/\s+/).length
      }
    });
  } catch (error) {
    res.status(500).json({ error: '获取章节失败', details: error.message });
  }
});

// 令牌使用情况
app.get('/api/token-usage', authenticateToken, async (req, res) => {
  try {
    const tokenManager = new TokenManager();
    const usage = await tokenManager.getSessionTokenUsage();
    
    res.json({
      usage: {
        used: usage.used,
        available: usage.available,
        limit: usage.limit,
        safetyMargin: usage.safetyMargin
      }
    });
  } catch (error) {
    res.status(500).json({ error: '获取令牌使用情况失败', details: error.message });
  }
});

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: '服务器内部错误' });
});

// 404处理
app.use('*', (req, res) => {
  res.status(404).json({ error: '请求的资源不存在' });
});

module.exports = app;