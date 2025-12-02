#!/usr/bin/env node

/**
 * 文件管理工具
 * 用于管理小说项目中的文件操作
 */

const fs = require('fs').promises;
const path = require('path');

class FileManager {
  /**
   * 确保目录存在，如果不存在则创建
   * @param {string} dirPath - 目录路径
   */
  static async ensureDir(dirPath) {
    try {
      await fs.mkdir(dirPath, { recursive: true });
    } catch (error) {
      if (error.code !== 'EEXIST') {
        throw error;
      }
    }
  }

  /**
   * 读取目录中的所有文件
   * @param {string} dirPath - 目录路径
   * @returns {Promise<Array>} 文件路径数组
   */
  static async readDir(dirPath) {
    const files = await fs.readdir(dirPath);
    return files.map(file => path.join(dirPath, file));
  }

  /**
   * 读取章节文件列表
   * @param {string} projectDir - 项目目录
   * @returns {Promise<Array>} 章节文件路径数组
   */
  static async getChapterFiles(projectDir) {
    const chapterDir = path.join(projectDir, 'chapters');
    const files = await this.readDir(chapterDir);
    return files.filter(file => path.extname(file) === '.md').sort();
  }

  /**
   * 读取设定文件
   * @param {string} projectDir - 项目目录
   * @returns {Promise<Object>} 设定数据
   */
  static async loadSettings(projectDir) {
    const settingsDir = path.join(projectDir, 'settings');
    const result = {};
    
    try {
      // 读取角色设定
      const characterFile = path.join(settingsDir, 'characters.json');
      if (await this.fileExists(characterFile)) {
        result.characters = JSON.parse(await fs.readFile(characterFile, 'utf8'));
      }
      
      // 读取世界观设定
      const worldviewFile = path.join(settingsDir, 'worldview.json');
      if (await this.fileExists(worldviewFile)) {
        result.worldview = JSON.parse(await fs.readFile(worldviewFile, 'utf8'));
      }
      
      // 读取力量体系设定
      const powerSystemFile = path.join(settingsDir, 'power-system.json');
      if (await this.fileExists(powerSystemFile)) {
        result.powerSystem = JSON.parse(await fs.readFile(powerSystemFile, 'utf8'));
      }
      
      // 读取伏笔设定
      const foreshadowFile = path.join(settingsDir, 'foreshadows.json');
      if (await this.fileExists(foreshadowFile)) {
        result.foreshadows = JSON.parse(await fs.readFile(foreshadowFile, 'utf8'));
      }
    } catch (error) {
      console.error('Error loading settings:', error.message);
    }
    
    return result;
  }

  /**
   * 检查文件是否存在
   * @param {string} filePath - 文件路径
   * @returns {Promise<boolean>} 文件是否存在
   */
  static async fileExists(filePath) {
    try {
      await fs.access(filePath);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * 保存设定文件
   * @param {string} projectDir - 项目目录
   * @param {string} fileName - 文件名
   * @param {Object} data - 数据
   */
  static async saveSettings(projectDir, fileName, data) {
    const settingsDir = path.join(projectDir, 'settings');
    await this.ensureDir(settingsDir);
    
    const filePath = path.join(settingsDir, fileName);
    await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log('用法: node file-manager.js <命令> [参数]');
    console.log('命令:');
    console.log('  list-chapters <项目目录> - 列出章节文件');
    console.log('  load-settings <项目目录> - 加载设定文件');
    process.exit(1);
  }
  
  const command = args[0];
  const projectDir = args[1];
  
  switch (command) {
    case 'list-chapters':
      if (!projectDir) {
        console.error('错误: 请提供项目目录路径');
        process.exit(1);
      }
      FileManager.getChapterFiles(projectDir)
        .then(files => {
          console.log('章节文件列表:');
          files.forEach(file => console.log(`  - ${file}`));
        })
        .catch(err => {
          console.error('Error:', err.message);
        });
      break;
      
    case 'load-settings':
      if (!projectDir) {
        console.error('错误: 请提供项目目录路径');
        process.exit(1);
      }
      FileManager.loadSettings(projectDir)
        .then(settings => {
          console.log('设定文件内容:');
          console.log(JSON.stringify(settings, null, 2));
        })
        .catch(err => {
          console.error('Error:', err.message);
        });
      break;
      
    default:
      console.log(`未知命令: ${command}`);
      break;
  }
}

module.exports = FileManager;