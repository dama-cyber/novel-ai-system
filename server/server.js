/**
 * Express服务器入口文件
 */

require('dotenv').config();

const app = require('./app');
const fs = require('fs').promises;
const path = require('path');

const PORT = process.env.PORT || 3000;

// 确保必要目录存在
async function ensureDirectories() {
  const requiredDirs = [
    path.join(__dirname, '..', 'projects'),
    path.join(__dirname, '..', 'chapters'),
    path.join(__dirname, '..', 'summaries'),
    path.join(__dirname, '..', 'settings')
  ];
  
  for (const dir of requiredDirs) {
    try {
      await fs.access(dir);
    } catch (error) {
      // 目录不存在，创建它
      await fs.mkdir(dir, { recursive: true });
      console.log(`创建目录: ${dir}`);
    }
  }
}

// 启动服务器
async function startServer() {
  try {
    await ensureDirectories();
    
    app.listen(PORT, () => {
      console.log(`\n🚀 小说AI创作系统服务器运行在端口 ${PORT}`);
      console.log(`\n📋 API端点:`);
      console.log(`   POST   /api/auth/register - 用户注册`);
      console.log(`   POST   /api/auth/login - 用户登录`);
      console.log(`   GET    /api/auth/me - 获取当前用户信息`);
      console.log(`   POST   /api/projects - 创建新项目`);
      console.log(`   GET    /api/projects - 获取项目列表`);
      console.log(`   POST   /api/projects/:projectName/outline - 生成大纲`);
      console.log(`   POST   /api/projects/:projectName/chapters/:chapterNumber - 生成章节`);
      console.log(`   GET    /api/projects/:projectName/chapters/:chapterNumber - 获取章节内容`);
      console.log(`   GET    /api/token-usage - 获取令牌使用情况`);
      console.log(`\n🔗 访问 http://localhost:${PORT} 查看服务器状态\n`);
    });
  } catch (error) {
    console.error('启动服务器失败:', error);
    process.exit(1);
  }
}

// 处理未捕获的异常
process.on('uncaughtException', (err) => {
  console.error('未捕获的异常:', err);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('未处理的Promise拒绝:', reason);
  process.exit(1);
});

startServer();