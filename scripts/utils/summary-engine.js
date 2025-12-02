#!/usr/bin/env node

/**
 * 总结引擎 - 智能生成小说章节摘要
 */

const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');

class RecursiveSummarizer {
  /**
   * 加载章节内容
   * @param {string} projectDir - 项目目录
   * @param {number} startChapter - 起始章节号
   * @param {number} endChapter - 结束章节号
   * @returns {Promise<Array>} 章节内容数组
   */
  async loadChapters(projectDir, startChapter, endChapter) {
    const chapters = [];

    for (let i = startChapter; i <= endChapter; i++) {
      const formattedNum = String(i).padStart(3, '0');
      const chapterFiles = await this.findChapterFiles(projectDir, formattedNum);

      if (chapterFiles.length > 0) {
        const content = await fs.readFile(chapterFiles[0], 'utf8');
        chapters.push(content);
      }
    }

    return chapters;
  }

  /**
   * 查找特定章节号的文件
   * @param {string} projectDir - 项目目录
   * @param {string} chapterNum - 章节号（格式化后）
   * @returns {Promise<Array>} 文件路径数组
   */
  async findChapterFiles(projectDir, chapterNum) {
    const chapterDir = path.join(projectDir, 'chapters');
    const files = await fs.readdir(chapterDir);
    return files
      .filter(file => file.startsWith(`chapter_${chapterNum}_`) && file.endsWith('.md'))
      .map(file => path.join(chapterDir, file));
  }

  /**
   * 将文本分割为块
   * @param {string} text - 输入文本
   * @param {number} maxChunkSize - 最大块大小
   * @returns {Array} 文本块数组
   */
  splitIntoChunks(text, maxChunkSize) {
    const chunks = [];
    let currentChunk = '';

    const paragraphs = text.split(/\n\s*\n/);

    for (const paragraph of paragraphs) {
      if (currentChunk.length + paragraph.length <= maxChunkSize) {
        currentChunk += paragraph + '\n\n';
      } else {
        if (currentChunk) {
          chunks.push(currentChunk.trim());
        }
        currentChunk = paragraph + '\n\n';
      }
    }

    if (currentChunk) {
      chunks.push(currentChunk.trim());
    }

    return chunks;
  }

  /**
   * 使用Qwen API总结文本块
   * @param {string} text - 要总结的文本
   * @returns {Promise<string>} 总结结果
   */
  async summarizeWithQwen(text) {
    return new Promise((resolve, reject) => {
      const qwen = spawn('qwen', [], { stdio: ['pipe', 'pipe', 'pipe'] });

      const prompt = `你是一个专业的小说编辑，擅长总结章节内容。

请将以下内容整合成一个连贯的摘要，突出主要情节、角色发展和重要事件：
${text}

---

请输出：
1. 故事进展摘要（核心情节、角色成长、重要事件）
2. 伏笔与线索（埋设的伏笔、已回收的线索）
3. 重要角色变化（角色发展、关系变化）
4. 下一阶段预期（基于当前情节的自然发展）

摘要：`;

      qwen.stdin.write(prompt);
      qwen.stdin.end();

      let summary = '';
      qwen.stdout.on('data', (data) => {
        summary += data.toString();
      });

      qwen.on('close', (code) => {
        if (code === 0) {
          resolve(summary.trim());
        } else {
          reject(new Error(`Qwen returned error code: ${code}`));
        }
      });

      qwen.on('error', reject);
    });
  }

  /**
   * 总结章节
   * @param {string} projectDir - 项目目录
   * @param {number} startChapter - 起始章节
   * @param {number} endChapter - 结束章节
   * @returns {Promise<string>} 总结内容
   */
  async summarizeChapters(projectDir, startChapter, endChapter) {
    const chapters = await this.loadChapters(projectDir, startChapter, endChapter);
    const combinedText = chapters.join('\n\n');

    // 如果内容超过一定长度，分块处理
    if (combinedText.length > 4000) {
      const chunks = this.splitIntoChunks(combinedText, 4000);
      const summaries = [];

      for (const chunk of chunks) {
        try {
          const summary = await this.summarizeWithQwen(chunk);
          summaries.push(summary);
        } catch (error) {
          console.error(`处理块时出错:`, error.message);
          // 如果Qwen调用失败，使用基础方法
          summaries.push(`[摘要生成失败: ${chunk.substring(0, 100)}...]`);
        }
      }

      // 如果块级摘要过长，再次合并总结
      const combined = summaries.join('\n\n');
      if (combined.length > 4000) {
        try {
          return await this.summarizeWithQwen(combined);
        } catch (error) {
          console.error(`最终摘要生成失败:`, error.message);
          return combined; // 返回合并的块级摘要
        }
      }
      return combined;
    }

    // 内容不长，直接总结
    try {
      return await this.summarizeWithQwen(combinedText);
    } catch (error) {
      console.error(`章节总结失败:`, error.message);
      return `章节内容(${combinedText.substring(0, 200)}...)`;
    }
  }

  /**
   * 智能摘要生成 - 根据章节范围生成摘要
   * @param {string} projectDir - 项目目录
   * @param {number} currentChapter - 当前章节数
   * @returns {Promise<string>} 总结内容
   */
  async generateSmartSummary(projectDir, currentChapter) {
    const summariesDir = path.join(projectDir, 'summaries');

    // 创建摘要目录
    try {
      await fs.access(summariesDir);
    } catch (error) {
      await fs.mkdir(summariesDir, { recursive: true });
    }

    // 计算摘要范围（每10章生成一个摘要，或根据需要调整）
    const range = 10;
    const startChapter = Math.floor((currentChapter - 1) / range) * range + 1;
    const endChapter = Math.min(startChapter + range - 1, currentChapter);

    if (startChapter > currentChapter) {
      return `当前章数(${currentChapter})未达到摘要范围(${range}章)，跳过摘要生成`;
    }

    // 检查是否已存在该范围的摘要
    const summaryFileName = `summary_${String(startChapter).padStart(3, '0')}-${String(endChapter).padStart(3, '0')}.md`;
    const summaryFilePath = path.join(summariesDir, summaryFileName);

    try {
      await fs.access(summaryFilePath);
      return `摘要文件已存在: ${summaryFilePath}`;
    } catch (error) {
      // 文件不存在，继续生成新摘要
    }

    // 生成新的摘要
    const summary = await this.summarizeChapters(projectDir, startChapter, endChapter);

    // 保存摘要到文件
    await fs.writeFile(summaryFilePath, `# 第${startChapter}-${endChapter}章总结\n\n${summary}`);

    return `摘要已生成并保存到: ${summaryFilePath}`;
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log('用法: node summary-engine.js <项目目录> <当前章节>');
    console.log('或: node summary-engine.js <项目目录> <起始章节> <结束章节>');
    process.exit(1);
  }

  const projectDir = args[0];
  const startChapter = parseInt(args[1]);
  const endChapter = args[2] ? parseInt(args[2]) : startChapter;

  if (isNaN(startChapter) || (args[2] && isNaN(endChapter))) {
    console.error('错误: 章节号必须是数字');
    process.exit(1);
  }

  const summarizer = new RecursiveSummarizer();

  if (args[2]) {
    // 传统模式：总结指定范围的章节
    summarizer.summarizeChapters(projectDir, startChapter, endChapter)
      .then(summary => {
        console.log('章节总结:');
        console.log(summary);
      })
      .catch(err => {
        console.error('Error:', err.message);
      });
  } else {
    // 智能模式：根据当前章节数生成摘要
    summarizer.generateSmartSummary(projectDir, startChapter)
      .then(result => {
        console.log(result);
      })
      .catch(err => {
        console.error('Error:', err.message);
      });
  }
}

module.exports = RecursiveSummarizer;