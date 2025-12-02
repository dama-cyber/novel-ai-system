/**
 * 数据库迁移脚本
 * 用于小说创作系统的数据表结构管理
 * （概念实现 - 当前项目使用文件系统，但提供数据库迁移模板）
 */

const fs = require('fs').promises;
const path = require('path');

class DatabaseMigration {
  constructor(migrationsDir = './migrations') {
    this.migrationsDir = migrationsDir;
    this.migrationLogPath = path.join(migrationsDir, 'migration-log.json');
  }

  async initialize() {
    // 确保迁移目录存在
    try {
      await fs.access(this.migrationsDir);
    } catch (error) {
      await fs.mkdir(this.migrationsDir, { recursive: true });
    }

    // 初始化迁移日志
    try {
      await fs.access(this.migrationLogPath);
    } catch (error) {
      await fs.writeFile(this.migrationLogPath, JSON.stringify({ applied: [] }, null, 2));
    }
  }

  async getAppliedMigrations() {
    const logContent = await fs.readFile(this.migrationLogPath, 'utf8');
    const log = JSON.parse(logContent);
    return log.applied || [];
  }

  async logMigration(migrationName) {
    const logContent = await fs.readFile(this.migrationLogPath, 'utf8');
    const log = JSON.parse(logContent);
    
    if (!log.applied) log.applied = [];
    if (!log.applied.includes(migrationName)) {
      log.applied.push(migrationName);
      await fs.writeFile(this.migrationLogPath, JSON.stringify(log, null, 2));
    }
  }

  // 概念：创建项目表迁移
  async createProjectsTable() {
    console.log('🏗️ 执行: 创建项目表迁移');
    
    // 这里是SQL概念，当前项目使用文件系统
    const migrationSQL = `
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255) NOT NULL,
        chapter_count INTEGER NOT NULL,
        genre VARCHAR(100),
        status VARCHAR(50) DEFAULT 'initialized',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        current_chapter INTEGER DEFAULT 0,
        total_words INTEGER DEFAULT 0
      );
    `;
    
    console.log('SQL概念:', migrationSQL.trim());
    await this.logMigration('create_projects_table');
    console.log('✅ 项目表迁移已记录');
  }

  // 概念：创建章节表迁移
  async createChaptersTable() {
    console.log('🏗️ 执行: 创建章节表迁移');
    
    const migrationSQL = `
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        chapter_number INTEGER NOT NULL,
        title VARCHAR(255),
        content TEXT,
        word_count INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects (id)
      );
    `;
    
    console.log('SQL概念:', migrationSQL.trim());
    await this.logMigration('create_chapters_table');
    console.log('✅ 章节表迁移已记录');
  }

  // 概念：创建角色设定表迁移
  async createCharactersTable() {
    console.log('🏗️ 执行: 创建角色设定表迁移');
    
    const migrationSQL = `
      CREATE TABLE characters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        personality TEXT,
        abilities TEXT, -- JSON格式
        development TEXT, -- JSON格式
        role VARCHAR(100), -- protagonist, supporting, antagonist
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects (id)
      );
    `;
    
    console.log('SQL概念:', migrationSQL.trim());
    await this.logMigration('create_characters_table');
    console.log('✅ 角色设定表迁移已记录');
  }

  // 概念：创建世界观表迁移
  async createWorldviewTable() {
    console.log('🏗️ 执行: 创建世界观表迁移');
    
    const migrationSQL = `
      CREATE TABLE worldview (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        setting TEXT,
        rules TEXT, -- JSON格式
        cultures TEXT, -- JSON格式
        geography TEXT,
        history TEXT,
        magic_system TEXT, -- JSON格式
        technology_level VARCHAR(100),
        social_structure TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects (id)
      );
    `;
    
    console.log('SQL概念:', migrationSQL.trim());
    await this.logMigration('create_worldview_table');
    console.log('✅ 世界观表迁移已记录');
  }

  // 概念：创建用户表迁移
  async createUsersTable() {
    console.log('🏗️ 执行: 创建用户表迁移');
    
    const migrationSQL = `
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(255) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    `;
    
    console.log('SQL概念:', migrationSQL.trim());
    await this.logMigration('create_users_table');
    console.log('✅ 用户表迁移已记录');
  }

  // 执行所有迁移
  async runAllMigrations() {
    await this.initialize();
    
    const appliedMigrations = await this.getAppliedMigrations();
    
    if (!appliedMigrations.includes('create_users_table')) {
      await this.createUsersTable();
    }
    
    if (!appliedMigrations.includes('create_projects_table')) {
      await this.createProjectsTable();
    }
    
    if (!appliedMigrations.includes('create_characters_table')) {
      await this.createCharactersTable();
    }
    
    if (!appliedMigrations.includes('create_worldview_table')) {
      await this.createWorldviewTable();
    }
    
    if (!appliedMigrations.includes('create_chapters_table')) {
      await this.createChaptersTable();
    }
    
    console.log('\n🎉 所有数据库迁移完成！');
  }

  // 回滚迁移（概念）
  async rollbackMigration(migrationName) {
    console.log(`🔄 回滚迁移: ${migrationName}`);
    
    // 在真实实现中，这会执行相应的DROP或ALTER语句
    const rollbackSQL = `-- 回滚 ${migrationName} 的SQL语句`;
    console.log('SQL概念:', rollbackSQL);
    
    // 从应用迁移列表中移除
    const logContent = await fs.readFile(this.migrationLogPath, 'utf8');
    const log = JSON.parse(logContent);
    
    if (log.applied) {
      log.applied = log.applied.filter(m => m !== migrationName);
      await fs.writeFile(this.migrationLogPath, JSON.stringify(log, null, 2));
    }
    
    console.log(`✅ ${migrationName} 迁移已回滚`);
  }
}

// 命令行接口
async function runMigrations() {
  const migration = new DatabaseMigration('./server/migrations');
  
  if (process.argv[2] === 'rollback') {
    const migrationName = process.argv[3];
    if (!migrationName) {
      console.error('请指定要回滚的迁移名称');
      process.exit(1);
    }
    
    await migration.rollbackMigration(migrationName);
  } else {
    await migration.runAllMigrations();
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  runMigrations().catch(err => {
    console.error('迁移执行错误:', err);
    process.exit(1);
  });
}

module.exports = DatabaseMigration;