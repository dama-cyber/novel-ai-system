#!/usr/bin/env node

/**
 * Token管理工具
 * 管理Qwen会话中的Token使用
 */

class TokenManager {
  constructor() {
    this.limit = 32000;
    this.safeThreshold = 25000;  // 留20%余量
    this.currentUsage = 0;
  }

  /**
   * 估算文本的Token数量
   * @param {string} text - 输入文本
   * @returns {number} 估算的Token数量
   */
  estimateTokens(text) {
    // 中文：1字≈1.5 tokens
    // 英文：1词≈1.3 tokens
    const chineseChars = (text.match(/[\u4e00-\u9fa5]/g) || []).length;
    const englishWords = (text.match(/[a-zA-Z]+/g) || []).length;
    
    return Math.ceil(chineseChars * 1.5 + englishWords * 1.3);
  }

  /**
   * 检查并压缩会话历史
   * @param {Object} qwenSession - Qwen会话对象
   */
  async checkAndCompress(qwenSession) {
    // 这里应该调用真实的Qwen API来获取统计信息
    // 模拟实现
    this.currentUsage = this.estimateTokens("模拟的会话内容");
    
    if (this.currentUsage > this.safeThreshold) {
      console.log(`⚠️ Token使用: ${this.currentUsage}/${this.limit}`);
      console.log('🔧 自动压缩会话历史...');
      
      // 在实际实现中，这里会调用qwen的压缩命令
      // await qwenSession.command('/compress');
      
      console.log('✅ 压缩完成');
    }
  }

  /**
   * 判断是否需要在当前章节压缩
   * @param {number} chapterNum - 章节号
   * @returns {boolean} 是否需要压缩
   */
  shouldCompressAt(chapterNum) {
    return chapterNum % 5 === 0;
  }

  /**
   * 获取当前使用状态
   * @returns {Object} 使用状态
   */
  getStatus() {
    return {
      limit: this.limit,
      safeThreshold: this.safeThreshold,
      currentUsage: this.currentUsage,
      usagePercent: this.currentUsage / this.limit * 100,
      needsCompression: this.currentUsage > this.safeThreshold
    };
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log('用法: node token-manager.js <命令> [参数]');
    console.log('命令:');
    console.log('  estimate <文本> - 估算Token数');
    console.log('  status - 显示当前状态');
    process.exit(1);
  }
  
  const command = args[0];
  const tokenManager = new TokenManager();
  
  switch (command) {
    case 'estimate':
      if (args.length < 2) {
        console.error('错误: 请提供要估算的文本');
        process.exit(1);
      }
      const text = args.slice(1).join(' ');
      const tokens = tokenManager.estimateTokens(text);
      console.log(`文本 "${text.substring(0, 30)}..." 的估算Token数: ${tokens}`);
      break;
      
    case 'status':
      const status = tokenManager.getStatus();
      console.log('Token使用状态:');
      console.log(`  限制: ${status.limit}`);
      console.log(`  当前使用: ${status.currentUsage}`);
      console.log(`  使用百分比: ${status.usagePercent.toFixed(2)}%`);
      console.log(`  需要压缩: ${status.needsCompression ? '是' : '否'}`);
      break;
      
    default:
      console.log(`未知命令: ${command}`);
      break;
  }
}

module.exports = TokenManager;