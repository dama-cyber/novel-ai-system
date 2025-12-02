/**
 * 高级限速中间件
 * 基于用户ID和IP地址的智能限速
 */

const Redis = require('ioredis');
const crypto = require('crypto');

// 尝试连接到Redis，如果不可用则使用内存存储作为备选
let redis;
try {
  redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
  console.log('✅ 已连接到Redis用于限速存储');
} catch (error) {
  console.log('⚠️ Redis不可用，使用内存存储限速数据');
  redis = null;
}

// 内存存储（Redis不可用时的备选方案）
const memoryStore = new Map();

class AdvancedRateLimiter {
  constructor(options = {}) {
    this.windowMs = options.windowMs || 15 * 60 * 1000; // 15分钟
    this.max = options.max || 100; // 默认最大请求数
    this.message = options.message || { error: '请求过于频繁，请稍后再试' };
    this.keyGenerator = options.keyGenerator || this.defaultKeyGenerator;
    this.skipFailedRequests = options.skipFailedRequests || false;
    this.skipSuccessfulRequests = options.skipSuccessfulRequests || false;
  }

  // 默认键生成器
  defaultKeyGenerator(req) {
    // 基于用户ID（如果已认证）或IP地址生成唯一键
    const userId = req.user?.id;
    const ip = req.ip || req.connection.remoteAddress;
    
    return userId ? `user:${userId}` : `ip:${ip}`;
  }

  // 获取存储键
  getStoreKey(key) {
    return `rate-limit:${key}`;
  }

  // 获取当前时间窗口的键
  getWindowKey(key) {
    const windowStart = Date.now() - this.windowMs;
    return `${this.getStoreKey(key)}:${Math.floor(windowStart / this.windowMs)}`;
  }

  async getRateLimitInfo(key) {
    if (redis) {
      // 使用Redis
      const windowKey = this.getWindowKey(key);
      const count = await redis.incr(windowKey);
      
      if (count === 1) {
        // 设置过期时间以清理旧数据
        await redis.expire(windowKey, Math.ceil(this.windowMs / 1000) + 1);
      }
      
      return {
        current: count,
        max: this.max,
        windowMs: this.windowMs,
        msBeforeNext: this.windowMs - (Date.now() % this.windowMs)
      };
    } else {
      // 使用内存存储
      const windowKey = this.getWindowKey(key);
      const currentCount = memoryStore.get(windowKey) || 0;
      const newCount = currentCount + 1;
      
      memoryStore.set(windowKey, newCount);
      
      // 设置过期
      setTimeout(() => {
        if (memoryStore.get(windowKey) === newCount) {
          memoryStore.delete(windowKey);
        }
      }, this.windowMs);
      
      return {
        current: newCount,
        max: this.max,
        windowMs: this.windowMs,
        msBeforeNext: this.windowMs - (Date.now() % this.windowMs)
      };
    }
  }

  middleware() {
    return async (req, res, next) => {
      try {
        // 跳过某些请求类型
        if (
          (this.skipFailedRequests && res.statusCode >= 400) ||
          (this.skipSuccessfulRequests && res.statusCode < 400)
        ) {
          return next();
        }

        const key = this.keyGenerator(req);
        const rateLimitInfo = await this.getRateLimitInfo(key);

        // 设置响应头
        res.setHeader('X-RateLimit-Limit', this.max);
        res.setHeader('X-RateLimit-Remaining', Math.max(this.max - rateLimitInfo.current, 0));
        res.setHeader('X-RateLimit-Reset', new Date(Date.now() + rateLimitInfo.msBeforeNext).toISOString());

        if (rateLimitInfo.current > this.max) {
          // 触发限速
          res.status(429).json({
            ...this.message,
            error: `请求过于频繁，请在 ${Math.ceil(rateLimitInfo.msBeforeNext / 1000)} 秒后重试`,
            limit: this.max,
            current: rateLimitInfo.current,
            windowMs: this.windowMs
          });
          return;
        }

        next();
      } catch (error) {
        console.error('限速中间件错误:', error);
        // 发生错误时不限制请求
        next();
      }
    };
  }

  // 异步清理过期数据
  async cleanup() {
    if (redis) {
      // Redis会自动过期，无需手动清理
      return;
    }

    // 清理内存存储中的过期数据
    const now = Date.now();
    for (const [key, value] of memoryStore.entries()) {
      const keyTime = parseInt(key.split(':')[2] || '0');
      if (now - keyTime > this.windowMs) {
        memoryStore.delete(key);
      }
    }
  }
}

// 预设的限速配置
const rateLimitPresets = {
  // 全局限速
  global: (max = 1000) => new AdvancedRateLimiter({
    windowMs: 15 * 60 * 1000, // 15分钟
    max
  }).middleware(),

  // 用户相关操作限速
  userActions: () => new AdvancedRateLimiter({
    windowMs: 15 * 60 * 1000, // 15分钟
    max: 100,
    keyGenerator: (req) => {
      const userId = req.user?.id;
      return userId ? `user-actions:${userId}` : `ip-actions:${req.ip}`;
    }
  }).middleware(),

  // 认证相关操作限速（更严格的限制）
  auth: () => new AdvancedRateLimiter({
    windowMs: 15 * 60 * 1000, // 15分钟
    max: 5,
    message: { error: '登录尝试次数过多，请稍后再试' },
    keyGenerator: (req) => {
      // 认证相关操作基于IP进行限制，而不是用户ID
      return `auth:${req.ip}`;
    }
  }).middleware(),

  // API调用限速
  apiCalls: (max = 100) => new AdvancedRateLimiter({
    windowMs: 60 * 1000, // 1分钟
    max,
    keyGenerator: (req) => {
      const userId = req.user?.id;
      return userId ? `api:${userId}` : `api:${req.ip}`;
    }
  }).middleware()
};

module.exports = {
  AdvancedRateLimiter,
  rateLimitPresets
};