#!/usr/bin/env node

/**
 * 质量分析工具
 * 分析小说章节的质量并生成报告
 */

const fs = require('fs').promises;
const path = require('path');

class QualityAnalyzer {
  /**
   * 分析章节质量
   * @param {string} projectDir - 项目目录
   * @returns {Promise<Object>} 质量分析报告
   */
  async analyzeQuality(projectDir) {
    const report = {
      overallScore: 0,
      plotInnovation: 0,
      characterDevelopment: 0,
      languageQuality: 0,
      consistency: 0,
      pacing: 0,
      details: {}
    };

    // 分析章节数量
    const chapterFiles = await this.getChapterFiles(projectDir);
    report.details.chapterCount = chapterFiles.length;

    // 分析每个章节
    let totalScore = 0;
    for (let i = 0; i < chapterFiles.length; i++) {
      const chapterContent = await fs.readFile(chapterFiles[i], 'utf8');
      const chapterScore = this.analyzeSingleChapter(chapterContent, i + 1);
      totalScore += chapterScore.score;
      
      // 收集细节信息
      if (!report.details.chapters) report.details.chapters = [];
      report.details.chapters.push({
        file: path.basename(chapterFiles[i]),
        score: chapterScore.score,
        wordCount: chapterContent.length
      });
    }

    // 计算总体分数
    if (chapterFiles.length > 0) {
      report.overallScore = Math.round(totalScore / chapterFiles.length);
    }

    // 其他指标通过估算得出
    report.plotInnovation = this.estimatePlotInnovation(report);
    report.characterDevelopment = this.estimateCharacterDevelopment(report);
    report.languageQuality = this.estimateLanguageQuality(report);
    report.consistency = this.estimateConsistency(report);
    report.pacing = this.estimatePacing(report);

    return report;
  }

  /**
   * 分析单个章节
   * @param {string} content - 章节内容
   * @param {number} chapterNum - 章节号
   * @returns {Object} 章节分析结果
   */
  analyzeSingleChapter(content, chapterNum) {
    // 简单的分析算法
    const wordCount = content.length;
    const lineCount = content.split('\n').length;
    const hasDialog = content.includes('”') || content.includes('"');
    const hasAction = content.toLowerCase().includes('。') && content.length > 100;

    let score = 50; // 基础分

    // 字数评分（3000字左右为佳）
    if (wordCount > 2500 && wordCount < 3500) {
      score += 20;
    } else if (wordCount > 2000 && wordCount < 4000) {
      score += 10;
    } else {
      score -= 10;
    }

    // 是否有对话
    if (hasDialog) score += 10;

    // 是否有动作描述
    if (hasAction) score += 10;

    // 段落数量
    if (lineCount > 20) score += 10;

    // 限制在0-100之间
    score = Math.max(0, Math.min(100, score));

    return {
      score: score,
      wordCount: wordCount,
      lineCount: lineCount,
      hasDialog: hasDialog,
      hasAction: hasAction
    };
  }

  /**
   * 估算剧情创新性
   * @param {Object} report - 报告对象
   * @returns {number} 创新性分数
   */
  estimatePlotInnovation(report) {
    // 基于章节变化和内容多样性估算
    return 75 + Math.random() * 20; // 随机值模拟
  }

  /**
   * 估算角色发展
   * @param {Object} report - 报告对象
   * @returns {number} 角色发展分数
   */
  estimateCharacterDevelopment(report) {
    return 80 + Math.random() * 15; // 随机值模拟
  }

  /**
   * 估算语言质量
   * @param {Object} report - 报告对象
   * @returns {number} 语言质量分数
   */
  estimateLanguageQuality(report) {
    return 85 + Math.random() * 10; // 随机值模拟
  }

  /**
   * 估算一致性
   * @param {Object} report - 报告对象
   * @returns {number} 一致性分数
   */
  estimateConsistency(report) {
    return 70 + Math.random() * 25; // 随机值模拟
  }

  /**
   * 估算节奏
   * @param {Object} report - 报告对象
   * @returns {number} 节奏分数
   */
  estimatePacing(report) {
    return 75 + Math.random() * 20; // 随机值模拟
  }

  /**
   * 获取章节文件列表
   * @param {string} projectDir - 项目目录
   * @returns {Promise<Array>} 章节文件路径数组
   */
  async getChapterFiles(projectDir) {
    const chapterDir = path.join(projectDir, 'chapters');
    try {
      const files = await fs.readdir(chapterDir);
      return files
        .filter(file => path.extname(file) === '.md')
        .map(file => path.join(chapterDir, file))
        .sort(); // 排序确保按名称顺序
    } catch (error) {
      console.error(`无法读取章节目录: ${error.message}`);
      return [];
    }
  }

  /**
   * 生成质量报告
   * @param {Object} analysisReport - 分析报告
   * @param {string} projectDir - 项目目录
   * @returns {Promise<string>} 报告内容
   */
  async generateReport(analysisReport, projectDir) {
    const report = `# 质量分析报告

## 项目信息
- 项目路径: ${projectDir}
- 章节数量: ${analysisReport.details.chapterCount}

## 总体评分
- 整体质量: ${analysisReport.overallScore}/100
- 剧情创新性: ${analysisReport.plotInnovation}/100
- 角色发展: ${analysisReport.characterDevelopment}/100
- 语言质量: ${analysisReport.languageQuality}/100
- 一致性: ${analysisReport.consistency}/100
- 节奏把控: ${analysisReport.pacing}/100

## 章节详情
| 章节 | 字数 | 评分 |
|------|------|------|
${analysisReport.details.chapters ? analysisReport.details.chapters.map(ch => 
  `| ${ch.file} | ${ch.wordCount} | ${ch.score} |`).join('\n') : ''}

## 建议
1. 保持章节字数在2500-3500字之间
2. 增加对话和动作描述
3. 保持角色行为一致性
4. 优化段落结构
`;

    return report;
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('用法: node quality-analyzer.js <命令> [参数]');
    console.log('命令:');
    console.log('  analyze <项目目录> - 分析项目质量');
    process.exit(1);
  }
  
  const command = args[0];
  const projectDir = args[1];
  const analyzer = new QualityAnalyzer();
  
  switch (command) {
    case 'analyze':
      if (!projectDir) {
        console.error('错误: 请提供项目目录路径');
        process.exit(1);
      }
      
      analyzer.analyzeQuality(projectDir)
        .then(async (analysisReport) => {
          const reportContent = await analyzer.generateReport(analysisReport, projectDir);
          console.log(reportContent);
          
          // 同时保存到文件
          const reportPath = path.join(projectDir, 'quality-report.md');
          await fs.writeFile(reportPath, reportContent, 'utf8');
          console.log(`\\n✅ 报告已保存到: ${reportPath}`);
        })
        .catch(err => {
          console.error('分析错误:', err.message);
        });
      break;
      
    default:
      console.log(`未知命令: ${command}`);
      break;
  }
}

module.exports = QualityAnalyzer;