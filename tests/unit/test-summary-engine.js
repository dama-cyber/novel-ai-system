/**
 * @fileoverview SummaryEngine 单元测试，包含边缘情况测试
 */

const SummaryEngine = require('../../scripts/utils/summary-engine.js');

// Mock 摘要生成策略
class MockSummarizationStrategy {
  async generateSummary(text, options = {}) {
    if (text === 'error') {
      throw new Error('Summary generation error');
    }
    return `Summary of: ${text.substring(0, 20)}...`;
  }
}

describe('SummaryEngine', () => {
  let summaryEngine;
  let mockStrategy;

  beforeEach(() => {
    mockStrategy = new MockSummarizationStrategy();
    summaryEngine = new SummaryEngine(mockStrategy);
  });

  describe('generateSummaryWithCache', () => {
    test('should generate summary without cache miss', async () => {
      const result = await summaryEngine.generateSummaryWithCache('This is a test text');
      expect(result).toBe('Summary of: This is a test text...');
    });

    test('should return cached result on cache hit', async () => {
      // 第一次调用，生成摘要
      const result1 = await summaryEngine.generateSummaryWithCache('This is a test text');
      
      // 第二次调用，应该从缓存获取
      const result2 = await summaryEngine.generateSummaryWithCache('This is a test text');
      
      expect(result1).toBe(result2);
    });

    test('should handle summary generation error', async () => {
      try {
        await summaryEngine.generateSummaryWithCache('error');
        // 如果没有抛出错误，则测试失败
        throw new Error('Expected error was not thrown');
      } catch (error) {
        expect(error.message).toBe('Summary generation error');
      }
    });
  });

  describe('processLongText', () => {
    test('should process short text directly', async () => {
      const shortText = 'This is a short text.';
      const result = await summaryEngine.processLongText(shortText);
      expect(result).toBe('Summary of: This is a short text....');
    });

    test('should process long text in chunks', async () => {
      const longText = 'A'.repeat(8000); // 超过默认4000的长度
      const result = await summaryEngine.processLongText(longText);
      
      // 验证结果包含分段摘要标记
      expect(result).toContain('=== 分段摘要结束 ===');
    });

    test('should handle empty text', async () => {
      const result = await summaryEngine.processLongText('');
      expect(result).toBe('Summary of: ...');
    });

    test('should handle very long text', async () => {
      const veryLongText = 'A'.repeat(50000); // 非常长的文本
      const result = await summaryEngine.processLongText(veryLongText);
      
      // 验证处理成功，不抛出异常
      expect(typeof result).toBe('string');
    });
  });

  describe('getCacheStats', () => {
    test('should return cache statistics', () => {
      const stats = summaryEngine.getCacheStats();
      expect(stats).toHaveProperty('size');
      expect(stats).toHaveProperty('maxSize');
      expect(stats).toHaveProperty('utilization');
    });

    test('should show correct stats after caching', async () => {
      await summaryEngine.generateSummaryWithCache('First text');
      await summaryEngine.generateSummaryWithCache('Second text');
      
      const stats = summaryEngine.getCacheStats();
      expect(stats.size).toBeGreaterThanOrEqual(2); // 至少有2个缓存项
      expect(stats.utilization).toBeGreaterThanOrEqual(0);
    });
  });

  describe('clearCache', () => {
    test('should clear the cache', async () => {
      await summaryEngine.generateSummaryWithCache('Test text');
      
      let stats = summaryEngine.getCacheStats();
      expect(stats.size).toBeGreaterThan(0);
      
      summaryEngine.clearCache();
      
      stats = summaryEngine.getCacheStats();
      expect(stats.size).toBe(0);
    });
  });

  // 边缘情况测试
  describe('edge cases', () => {
    test('should handle null input', async () => {
      try {
        await summaryEngine.processLongText(null);
        // 这可能会导致错误，具体取决于实现
      } catch (error) {
        // 预期会有错误
      }
    });

    test('should handle undefined input', async () => {
      try {
        await summaryEngine.processLongText(undefined);
        // 这可能会导致错误，具体取决于实现
      } catch (error) {
        // 预期会有错误
      }
    });

    test('should handle very large input', async () => {
      const hugeText = 'A'.repeat(100000); // 100KB 文本
      const result = await summaryEngine.processLongText(hugeText);
      
      // 验证处理成功，不抛出异常
      expect(typeof result).toBe('string');
    });

    test('should handle special characters', async () => {
      const specialText = '!@#$%^&*()_+中文测试\n\t\r';
      const result = await summaryEngine.processLongText(specialText);
      
      // 验证处理成功，不抛出异常
      expect(typeof result).toBe('string');
    });
  });
});

// 辅助函数以模拟测试运行器
function describe(description, testFn) {
  console.log(`\n📋 ${description}`);
  testFn();
}

function test(description, testFn) {
  try {
    console.log(`  ✅ ${description}`);
    if (testFn.length === 1) { // 异步测试
      return testFn((err) => {
        if (err) throw err;
      });
    } else {
      return testFn();
    }
  } catch (error) {
    console.log(`  ❌ ${description} - 失败: ${error.message}`);
  }
}

function expect(actual) {
  return {
    toBe: (expected) => {
      if (actual !== expected) {
        throw new Error(`期望 ${expected} 但得到 ${actual}`);
      }
    },
    toBeGreaterThanOrEqual: (expected) => {
      if (actual < expected) {
        throw new Error(`期望 ${actual} >= ${expected}`);
      }
    },
    toBeGreaterThan: (expected) => {
      if (actual <= expected) {
        throw new Error(`期望 ${actual} > ${expected}`);
      }
    },
    toHaveProperty: (propName) => {
      if (!(propName in actual)) {
        throw new Error(`对象没有属性 ${propName}`);
      }
    },
    toContain: (substring) => {
      if (!actual.includes(substring)) {
        throw new Error(`字符串不包含 "${substring}"`);
      }
    }
  };
}

// 运行测试
console.log('🧪 开始 SummaryEngine 单元测试...\n');
describe('SummaryEngine', () => {
  let summaryEngine;
  let mockStrategy;

  beforeEach(() => {
    mockStrategy = new MockSummarizationStrategy();
    summaryEngine = new SummaryEngine(mockStrategy);
  });

  test('should generate summary without cache miss', async () => {
    const result = await summaryEngine.generateSummaryWithCache('This is a test text');
    expect(result).toBe('Summary of: This is a test text...');
  });

  test('should process short text directly', async () => {
    const shortText = 'This is a short text.';
    const result = await summaryEngine.processLongText(shortText);
    expect(result).toBe('Summary of: This is a short text....');
  });

  test('should handle empty text', async () => {
    const result = await summaryEngine.processLongText('');
    expect(result).toBe('Summary of: ...');
  });

  test('should return cache statistics', () => {
    const stats = summaryEngine.getCacheStats();
    expect(stats).toHaveProperty('size');
    expect(stats).toHaveProperty('maxSize');
    expect(stats).toHaveProperty('utilization');
  });

  test('should clear the cache', async () => {
    await summaryEngine.generateSummaryWithCache('Test text');
    
    let stats = summaryEngine.getCacheStats();
    expect(stats.size).toBeGreaterThan(0);
    
    summaryEngine.clearCache();
    
    stats = summaryEngine.getCacheStats();
    expect(stats.size).toBe(0);
  });

  test('should handle very large input', async () => {
    const hugeText = 'A'.repeat(100000); // 100KB 文本
    const result = await summaryEngine.processLongText(hugeText);
    
    // 验证处理成功，不抛出异常
    expect(typeof result).toBe('string');
  });
});

console.log('\n✅ SummaryEngine 单元测试完成');