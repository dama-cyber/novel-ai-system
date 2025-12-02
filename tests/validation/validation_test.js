/**
 * 验证测试 - 测试工具函数的正确性
 */

const assert = require('assert');
const TokenCounter = require('../../scripts/utils/token-counter.js');
const FileManager = require('../../scripts/utils/file-manager.js');
const QualityAnalyzer = require('../../tools/quality-analyzer.js');

async function runTests() {
  console.log('🧪 开始验证测试...\n');
  
  let passedTests = 0;
  const totalTests = 4;
  
  // Test 1: TokenCounter
  try {
    console.log('Test 1: Token计数器功能测试...');
    const text = "这是一个测试文本，用于验证Token计数功能。";
    const tokenCount = TokenCounter.estimateTokens(text);
    console.log(`  输入文本: "${text}"`);
    console.log(`  估算Token数: ${tokenCount}`);
    assert(tokenCount > 0, 'Token数应大于0');
    console.log('  ✅ 通过\n');
    passedTests++;
  } catch (error) {
    console.log(`  ❌ 失败: ${error.message}\n`);
  }
  
  // Test 2: FileManager
  try {
    console.log('Test 2: 文件管理器功能测试...');
    const testDir = './test_temp_dir';
    await FileManager.ensureDir(testDir);
    
    const exists = await FileManager.fileExists(testDir);
    console.log(`  创建目录: ${testDir}`);
    console.log(`  目录存在: ${exists}`);
    assert(exists, '目录应该存在');
    
    // 清理
    const fs = require('fs').promises;
    await fs.rmdir(testDir);
    
    console.log('  ✅ 通过\n');
    passedTests++;
  } catch (error) {
    console.log(`  ❌ 失败: ${error.message}\n`);
  }
  
  // Test 3: QualityAnalyzer
  try {
    console.log('Test 3: 质量分析器功能测试...');
    const analyzer = new QualityAnalyzer();
    
    // 创建一个临时测试项目
    const testProjectDir = './projects/test_project';
    await FileManager.ensureDir(`${testProjectDir}/chapters`);
    await FileManager.ensureDir(`${testProjectDir}/settings`);
    
    // 创建测试章节文件
    const fs = require('fs').promises;
    for (let i = 1; i <= 3; i++) {
      const content = `# 第${i}章\n\n这是第${i}章的测试内容，用于验证质量分析功能。`;
      await fs.writeFile(`${testProjectDir}/chapters/chapter_00${i}_test.md`, content);
    }
    
    // 创建测试设置文件
    await fs.writeFile(`${testProjectDir}/settings/characters.json`, '{}');
    await fs.writeFile(`${testProjectDir}/settings/worldview.json`, '{}');
    await fs.writeFile(`${testProjectDir}/settings/power-system.json`, '{}');
    await fs.writeFile(`${testProjectDir}/settings/foreshadows.json`, '{}');
    
    const report = await analyzer.analyzeQuality(testProjectDir);
    console.log(`  章节数量: ${report.details.chapterCount}`);
    console.log(`  整体评分: ${report.overallScore}/100`);
    assert(report.overallScore >= 0 && report.overallScore <= 100, '评分应在0-100范围内');
    
    // 清理测试项目
    await fs.rmdir(`${testProjectDir}/chapters`, { recursive: true });
    await fs.rmdir(`${testProjectDir}/settings`, { recursive: true });
    await fs.rmdir(testProjectDir);
    
    console.log('  ✅ 通过\n');
    passedTests++;
  } catch (error) {
    console.log(`  ❌ 失败: ${error.message}\n`);
  }
  
  // Test 4: TokenCounter with English text
  try {
    console.log('Test 4: Token计数器英文文本测试...');
    const englishText = "This is a test text for validating token counting functionality in English.";
    const tokenCount = TokenCounter.estimateTokens(englishText);
    console.log(`  输入文本: "${englishText}"`);
    console.log(`  估算Token数: ${tokenCount}`);
    assert(tokenCount > 0, 'Token数应大于0');
    console.log('  ✅ 通过\n');
    passedTests++;
  } catch (error) {
    console.log(`  ❌ 失败: ${error.message}\n`);
  }
  
  // 输出最终结果
  console.log('============================================================');
  console.log(`总计测试: ${totalTests}`);
  console.log(`通过测试: ${passedTests}`);
  console.log(`失败测试: ${totalTests - passedTests}`);
  console.log(`通过率: ${((passedTests/totalTests)*100).toFixed(2)}%`);
  
  if (passedTests === totalTests) {
    console.log('\n🎉 所有验证测试通过！');
  } else {
    console.log('\n⚠️  部分测试未通过');
  }
}

// 如果直接运行此脚本
if (require.main === module) {
  runTests().catch(error => {
    console.error('测试运行错误:', error);
    process.exit(1);
  });
}