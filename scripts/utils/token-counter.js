#!/usr/bin/env node

/**
 * Token计数器
 * 用于估算文本的Token数量
 */

class TokenCounter {
  /**
   * 估算文本的Token数量
   * @param {string} text - 输入文本
   * @returns {number} 估算的Token数量
   */
  static estimateTokens(text) {
    // 中文：1字≈1.5 tokens
    // 英文：1词≈1.3 tokens
    const chineseChars = (text.match(/[\u4e00-\u9fa5]/g) || []).length;
    const englishWords = (text.match(/[a-zA-Z]+/g) || []).length;
    const spaces = (text.match(/\s+/g) || []).length;
    
    // 估算其他字符（标点符号、数字等）
    const otherChars = text.length - chineseChars - (englishWords > 0 ? englishWords : 0);
    
    return Math.ceil(chineseChars * 1.5 + englishWords * 1.3 + spaces * 0.25);
  }

  /**
   * 读取文件并估算Token数量
   * @param {string} filePath - 文件路径
   * @returns {Promise<number>} 估算的Token数量
   */
  static async estimateFileTokens(filePath) {
    const fs = require('fs').promises;
    try {
      const content = await fs.readFile(filePath, 'utf8');
      return this.estimateTokens(content);
    } catch (error) {
      console.error(`Error reading file ${filePath}:`, error.message);
      return 0;
    }
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log('用法: node token-counter.js <文件路径或直接输入文本>');
    process.exit(1);
  }
  
  if (args.length === 1 && args[0].endsWith('.txt') || args[0].endsWith('.md')) {
    // 如果参数是文件路径
    TokenCounter.estimateFileTokens(args[0])
      .then(tokens => {
        console.log(`文件 ${args[0]} 的估算Token数: ${tokens}`);
      })
      .catch(err => {
        console.error('Error:', err.message);
      });
  } else {
    // 如果参数是直接的文本
    const text = args.join(' ');
    const tokens = TokenCounter.estimateTokens(text);
    console.log(`文本的估算Token数: ${tokens}`);
  }
}

module.exports = TokenCounter;