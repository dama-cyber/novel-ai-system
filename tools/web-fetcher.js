/**
 * 网页内容抓取工具
 * 使用fetch API从指定URL获取内容
 */
const fetch = require('node-fetch');

/**
 * 从URL获取网页内容
 * @param {string} url - 要获取内容的URL
 * @returns {Promise<string>} 返回网页的HTML内容
 */
async function fetchWebContent(url) {
  // 验证URL格式
  if (!isValidUrl(url)) {
    throw new Error('无效的URL格式');
  }

  try {
    // 对URL进行编码，处理特殊字符
    const encodedUrl = encodeURI(url);

    // 设置请求选项
    const options = {
      method: 'GET',
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; Novel-AI-System/16.0; +http://www.example.com/bot)'
      }
    };

    // 发起fetch请求
    const response = await fetch(encodedUrl, options);

    if (!response.ok) {
      throw new Error(`HTTP请求失败: ${response.status} ${response.statusText}`);
    }

    // 获取响应文本
    const content = await response.text();

    return content;
  } catch (error) {
    console.error(`获取网页内容失败: ${url}`, error.message);
    throw error;
  }
}

/**
 * 提取网页的纯文本内容
 * @param {string} html - HTML内容
 * @returns {string} 纯文本内容
 */
function extractTextFromHtml(html) {
  // 简单的HTML标签移除方法，仅用于演示
  // 在实际应用中，您可能需要使用像jsdom这样的库来更精确地处理HTML
  return html
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '') // 移除script标签
    .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '') // 移除style标签
    .replace(/<[^>]*>/g, '') // 移除所有HTML标签
    .replace(/&nbsp;/g, ' ') // 替换不间断空格
    .replace(/&amp;/g, '&') // 替换&符号
    .replace(/&lt;/g, '<') // 替换<符号
    .replace(/&gt;/g, '>') // 替换>符号
    .replace(/\s+/g, ' ') // 合并多个空白字符
    .trim();
}

/**
 * 验证URL格式
 * @param {string} url - 要验证的URL
 * @returns {boolean} URL是否有效
 */
function isValidUrl(url) {
  try {
    new URL(url);
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * 从URL获取网页的纯文本内容
 * @param {string} url - 要获取内容的URL
 * @returns {Promise<string>} 返回网页的纯文本内容
 */
async function fetchWebTextContent(url) {
  const html = await fetchWebContent(url);
  return extractTextFromHtml(html);
}

// 导出模块函数
module.exports = {
  fetchWebContent,
  fetchWebTextContent,
  extractTextFromHtml,
  isValidUrl
};

// 如果直接运行此脚本，则进行测试
if (require.main === module) {
  const testUrl = process.argv[2] || 'https://httpbin.org/html';
  
  console.log(`正在获取: ${testUrl}`);
  
  fetchWebTextContent(testUrl)
    .then(content => {
      console.log('获取到的内容:');
      console.log(content.substring(0, 500) + (content.length > 500 ? '...' : ''));
    })
    .catch(error => {
      console.error('错误:', error.message);
    });
}