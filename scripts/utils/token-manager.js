#!/usr/bin/env node

/**
 * 令牌管理器 - 监控和管理Qwen CLI令牌使用
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

// 读取配置
const configPath = path.join(__dirname, '../../config/qwen-settings.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

class TokenManager {
  constructor() {
    this.sessionTokenLimit = config.sessionTokenLimit;
    this.tokenSafetyMargin = config.tokenSafetyMargin || 7000;
    this.maxTokensAvailable = this.sessionTokenLimit - this.tokenSafetyMargin;
  }

  /**
   * 估算文本的令牌数量
   * @param {string} text - 要估算的文本
   * @returns {number} 估算的令牌数
   */
  estimateTokens(text) {
    // 简单估算：中文字符 ≈ 1.5 tokens，英文单词 ≈ 1.3 tokens
    const chineseChars = (text.match(/[\u4e00-\u9fa5]/g) || []).length;
    const englishWords = (text.match(/[a-zA-Z]+\b/g) || []).length;
    const otherChars = text.length - chineseChars - englishWords.length;
    
    return Math.ceil((chineseChars * 1.5) + (englishWords * 1.3) + (otherChars * 0.75));
  }

  /**
   * 获取当前会话的令牌使用情况
   * @returns {Promise<Object>} 令牌使用情况对象
   */
  async getSessionTokenUsage() {
    return new Promise((resolve, reject) => {
      // 目前没有直接的API获取当前会话令牌使用量，返回估算值
      // 在实际实现中，这里会调用Qwen的API来获取精确值
      resolve({
        used: 0, // 估算当前会话使用的令牌数
        available: this.maxTokensAvailable,
        limit: this.sessionTokenLimit,
        safetyMargin: this.tokenSafetyMargin
      });
    });
  }

  /**
   * 检查是否有足够的令牌执行操作
   * @param {number} requiredTokens - 需要的令牌数
   * @returns {Promise<boolean>} 是否有足够的令牌
   */
  async hasEnoughTokens(requiredTokens) {
    const usage = await this.getSessionTokenUsage();
    return usage.available >= requiredTokens;
  }

  /**
   * 调用Qwen并监控令牌使用
   * @param {string} prompt - 提示词
   * @param {Object} options - 选项
   * @returns {Promise<string>} Qwen的响应
   */
  async callQwen(prompt, options = {}) {
    const promptTokens = this.estimateTokens(prompt);
    
    if (!(await this.hasEnoughTokens(promptTokens))) {
      throw new Error(`令牌不足，需要 ${promptTokens}，但可用 ${this.maxTokensAvailable}`);
    }
    
    // 如果指定了最大令牌输出，也要考虑进去
    const maxTokens = options.maxTokens || 1000;
    const estimatedTotal = promptTokens + maxTokens;
    
    if (!(await this.hasEnoughTokens(estimatedTotal))) {
      console.warn(`警告：请求的令牌总数（${estimatedTotal}）接近限制`);
    }
    
    // 调用Qwen
    return new Promise((resolve, reject) => {
      const qwen = spawn('qwen', [], { stdio: ['pipe', 'pipe', 'pipe'] });
      
      let response = '';
      
      qwen.stdin.write(prompt);
      qwen.stdin.end();
      
      qwen.stdout.on('data', (data) => {
        response += data.toString();
      });
      
      qwen.on('close', (code) => {
        if (code === 0) {
          resolve(response.trim());
        } else {
          reject(new Error(`Qwen调用失败，退出码: ${code}`));
        }
      });
      
      qwen.on('error', reject);
      
      // 设置超时
      if (config.api && config.api.timeout) {
        setTimeout(() => {
          qwen.kill();
          reject(new Error('Qwen调用超时'));
        }, config.api.timeout);
      }
    });
  }

  /**
   * 自动压缩会话（当令牌使用接近限制时）
   * @returns {Promise<boolean>} 压缩是否成功
   */
  async autoCompress() {
    const usage = await this.getSessionTokenUsage();
    const usedPercentage = (usage.used / this.sessionTokenLimit) * 100;
    
    if (usedPercentage > 75) { // 当使用超过75%时自动压缩
      console.log(`令牌使用率已达${usedPercentage.toFixed(2)}%，执行自动压缩...`);
      
      return new Promise((resolve) => {
        const compress = spawn('qwen', ['/compress'], { stdio: 'inherit' });
        
        compress.on('close', (code) => {
          resolve(code === 0);
        });
      });
    }
    
    return true;
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 1) {
    console.log('用法: node token-manager.js <命令> [参数]');
    console.log('命令:');
    console.log('  estimate <文本>     - 估算令牌数量');
    console.log('  usage              - 获取当前会话令牌使用情况');
    console.log('  compress           - 执行会话压缩');
    process.exit(1);
  }
  
  const command = args[0];
  const tokenManager = new TokenManager();
  
  switch(command) {
    case 'estimate':
      const text = args.slice(1).join(' ');
      console.log(`估算令牌数: ${tokenManager.estimateTokens(text)}`);
      break;
      
    case 'usage':
      tokenManager.getSessionTokenUsage()
        .then(usage => {
          console.log(`令牌使用情况:`);
          console.log(`  已用: ${usage.used}`);
          console.log(`  可用: ${usage.available}`);
          console.log(`  限制: ${usage.limit}`);
          console.log(`  安全余量: ${usage.safetyMargin}`);
        })
        .catch(err => console.error('获取使用情况失败:', err));
      break;
      
    case 'compress':
      tokenManager.autoCompress()
        .then(success => {
          console.log(success ? '压缩成功' : '压缩失败');
        })
        .catch(err => console.error('压缩失败:', err));
      break;
      
    default:
      console.error(`未知命令: ${command}`);
      process.exit(1);
  }
}

module.exports = TokenManager;