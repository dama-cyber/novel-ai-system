#!/usr/bin/env node

/**
 * 记忆增强工具
 * 构建智能上下文以增强AI对小说的理解
 */

class ContextBuilder {
  /**
   * 构建章节创作上下文
   * @param {number} chapterNum - 当前章节号
   * @param {Object} novelData - 小说数据
   * @returns {Object} 上下文对象
   */
  buildChapterContext(chapterNum, novelData) {
    return {
      // 1. 核心设定（永久保留，≈2000 tokens）
      coreSettings: {
        characters: this.getCharacterCards(novelData),  // 主要角色3-5人
        worldview: this.getWorldviewCore(novelData),    // 核心规则
        powerSystem: novelData.powerSystem              // 力量体系
      },

      // 2. 近期情节（最近5章，≈3000 tokens）
      recentPlot: this.loadChapters(chapterNum - 5, chapterNum - 1),

      // 3. 历史总结（压缩版，≈2000 tokens）
      historySummary: this.getCompressedHistory(chapterNum),

      // 4. 记忆提醒（≈1000 tokens）
      reminders: {
        activeForeshadows: this.getActiveForeshadows(novelData),
        characterStatus: this.getCharacterStatus(novelData),
        openPlotlines: this.getOpenPlotlines(novelData)
      },

      // 5. 前情提要（≈500 tokens）
      recap: this.generateRecap(chapterNum - 1)
    };

    // 总计约8500 tokens，远低于32000限制
  }

  /**
   * 获取角色卡片
   * @param {Object} novelData - 小说数据
   * @returns {Array} 角色卡片数组
   */
  getCharacterCards(novelData) {
    if (!novelData.characters) return [];
    
    // 只返回主要角色（重要性评分 > 0.7）
    return novelData.characters.filter(char => 
      char.importance === undefined || char.importance > 0.7
    );
  }

  /**
   * 获取核心世界观
   * @param {Object} novelData - 小说数据
   * @returns {Object} 核心世界观
   */
  getWorldviewCore(novelData) {
    if (!novelData.worldview) return {};
    
    // 只返回核心规则，忽略细节
    return {
      setting: novelData.worldview.setting,
      rules: novelData.worldview.rules,
      powerSystem: novelData.worldview.powerSystem
    };
  }

  /**
   * 加载章节内容
   * @param {number} start - 起始章节
   * @param {number} end - 结束章节
   * @returns {Array} 章节内容数组
   */
  loadChapters(start, end) {
    // 模拟加载章节内容
    const chapters = [];
    for (let i = Math.max(1, start); i <= end; i++) {
      chapters.push(`第${i}章内容摘要`);
    }
    return chapters;
  }

  /**
   * 获取压缩历史
   * @param {number} chapterNum - 章节号
   * @returns {string} 压缩历史
   */
  getCompressedHistory(chapterNum) {
    // 返回之前的章节摘要（每10章一个摘要）
    const summaryBlock = Math.floor((chapterNum - 1) / 10) * 10;
    if (summaryBlock >= 10) {
      return `第1-${summaryBlock}章摘要`;
    }
    return "无早期历史";
  }

  /**
   * 获取活跃伏笔
   * @param {Object} novelData - 小说数据
   * @returns {Array} 活跃伏笔数组
   */
  getActiveForeshadows(novelData) {
    if (!novelData.foreshadows) return [];
    return novelData.foreshadows.active || [];
  }

  /**
   * 获取角色状态
   * @param {Object} novelData - 小说数据
   * @returns {Array} 角色状态数组
   */
  getCharacterStatus(novelData) {
    if (!novelData.characters) return [];
    return novelData.characters.map(char => ({
      name: char.name,
      status: char.status || 'active',
      development: char.development || 'stable'
    }));
  }

  /**
   * 获取开放的情节线
   * @param {Object} novelData - 小说数据
   * @returns {Array} 开放情节线数组
   */
  getOpenPlotlines(novelData) {
    if (!novelData.plotlines) return [];
    return novelData.plotlines.filter(plot => plot.status === 'open');
  }

  /**
   * 生成前情提要
   * @param {number} prevChapter - 上一章号
   * @returns {string} 前情提要
   */
  generateRecap(prevChapter) {
    if (prevChapter < 1) return "这是第一章，无前情";
    return `在第${prevChapter}章中，主角经历了...`;
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log('用法: node memory-enhancer.js <命令> [参数]');
    console.log('命令:');
    console.log('  context <章节号> - 生成章节上下文');
    process.exit(1);
  }
  
  const command = args[0];
  const contextBuilder = new ContextBuilder();
  
  switch (command) {
    case 'context':
      const chapterNum = parseInt(args[1]);
      if (isNaN(chapterNum)) {
        console.error('错误: 章节号必须是数字');
        process.exit(1);
      }
      
      const mockNovelData = {
        characters: [
          { name: "主角", importance: 1.0, status: "active", development: "growing" },
          { name: "配角", importance: 0.5, status: "active", development: "stable" }
        ],
        worldview: {
          setting: "玄幻世界",
          rules: { mana: "灵力系统", cultivation: "修炼等级" }
        },
        powerSystem: { name: "修炼等级", levels: ["练气", "筑基", "金丹"] },
        foreshadows: { active: ["神秘传承", "身世之谜"] },
        plotlines: [
          { name: "主线剧情", status: "open" },
          { name: "感情线", status: "pending" }
        ]
      };
      
      const context = contextBuilder.buildChapterContext(chapterNum, mockNovelData);
      console.log(`第${chapterNum}章的上下文构建完成:`);
      console.log(JSON.stringify(context, null, 2));
      break;
      
    default:
      console.log(`未知命令: ${command}`);
      break;
  }
}

module.exports = ContextBuilder;