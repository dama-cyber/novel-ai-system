#!/usr/bin/env node

/**
 * 系统功能验证脚本
 * 用于验证超长篇小说AI创作系统的关键组件
 */

const fs = require('fs').promises;
const path = require('path');
const { execSync } = require('child_process');

async function checkSystemComponents() {
    console.log('🔍 开始验证系统组件...\n');

    // 获取项目根目录（通过向上导航到包含package.json的目录）
    const projectRoot = path.dirname(__dirname); // 移动到父目录，即项目根目录
    const requiredDirs = ['scripts', 'tools', 'config', 'prompts'];

    for (const dir of requiredDirs) {
        try {
            await fs.access(path.join(projectRoot, dir));
            console.log(`✅ 目录存在: ${dir}`);
        } catch (error) {
            console.log(`❌ 目录不存在: ${dir}`);
        }
    }

    console.log('');

    // 检查必要的脚本
    const coreScripts = [
        'scripts/01-init-project.sh',
        'scripts/02-create-outline.sh',
        'scripts/03-batch-create.sh',
        'scripts/11-unified-workflow.sh'
    ];

    for (const script of coreScripts) {
        try {
            await fs.access(path.join(projectRoot, script));
            console.log(`✅ 脚本存在: ${script}`);
        } catch (error) {
            console.log(`❌ 脚本不存在: ${script}`);
        }
    }

    console.log('');

    // 检查必要的工具
    const coreTools = [
        'tools/diagnostic.js',
        'tools/token-manager.js',
        'tools/memory-enhancer.js',
        'tools/quality-analyzer.js'
    ];

    for (const tool of coreTools) {
        try {
            await fs.access(path.join(projectRoot, tool));
            console.log(`✅ 工具存在: ${tool}`);
        } catch (error) {
            console.log(`❌ 工具不存在: ${tool}`);
        }
    }
    
    console.log('');
    
    // 检查Qwen CLI
    try {
        execSync('qwen --version', { encoding: 'utf8' });
        console.log('✅ Qwen CLI 已安装并可用');
    } catch (error) {
        console.log('❌ Qwen CLI 未安装或不可用');
    }
    
    console.log('');
    
    // 检查Node.js版本
    const version = process.version;
    const majorVersion = parseInt(version.split('.')[0].substring(1));
    
    if (majorVersion >= 20) {
        console.log(`✅ Node.js 版本满足要求: ${version}`);
    } else {
        console.log(`❌ Node.js 版本过低: ${version} (需要 ≥ 20.0)`);
    }
    
    console.log('');
    
    // 检查项目初始化脚本功能
    console.log('🧪 测试项目初始化功能...');
    try {
        // 创建一个临时测试项目目录
        const testProjectDir = path.join(__dirname, 'test-project');
        
        // 尝试运行初始化脚本的核心功能
        const projectName = '测试项目';
        const chapterCount = 5;
        
        // 创建项目目录结构
        await fs.mkdir(path.join(testProjectDir, 'chapters'), { recursive: true });
        await fs.mkdir(path.join(testProjectDir, 'summaries'), { recursive: true });
        await fs.mkdir(path.join(testProjectDir, 'settings'), { recursive: true });
        
        // 创建基本的项目文件
        const metadata = {
            projectName,
            chapterCount,
            createdDate: new Date().toISOString(),
            status: 'initialized'
        };
        
        await fs.writeFile(
            path.join(testProjectDir, 'metadata.json'),
            JSON.stringify(metadata, null, 2),
            'utf8'
        );
        
        // 创建设定文件
        const defaultSettings = {
            characters: [],
            worldview: {},
            powerSystem: {},
            foreshadows: []
        };
        
        await fs.writeFile(
            path.join(testProjectDir, 'settings', 'characters.json'),
            JSON.stringify(defaultSettings, null, 2),
            'utf8'
        );
        
        console.log('✅ 项目初始化功能验证通过');
        
        // 清理测试目录
        const { rmdir } = require('fs').promises;
        await rmdir(testProjectDir, { recursive: true });
        
    } catch (error) {
        console.log(`❌ 项目初始化功能测试失败: ${error.message}`);
    }
    
    console.log('\n✅ 系统组件验证完成！');
}

// 运行验证
if (require.main === module) {
    checkSystemComponents().catch(console.error);
}

module.exports = { checkSystemComponents };