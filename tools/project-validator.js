#!/usr/bin/env node

/**
 * 项目完整性验证器
 * 验证整个超长篇小说AI创作系统的完整性
 */

const fs = require('fs').promises;
const path = require('path');

async function validateSystemIntegrity() {
    console.log('🔍 开始验证系统完整性...\n');
    
    const projectRoot = path.dirname(__dirname);
    let errors = 0;
    let warnings = 0;
    
    // 验证必要目录
    console.log('📁 验证必要目录...');
    const requiredDirs = [
        'scripts',
        'tools',
        'config',
        'prompts',
        'projects',
        'docs',
        'templates',
        'examples'
    ];
    
    for (const dir of requiredDirs) {
        try {
            await fs.access(path.join(projectRoot, dir));
            console.log(`  ✅ ${dir}/`);
        } catch (error) {
            console.log(`  ❌ ${dir}/ - 缺失`);
            errors++;
        }
    }
    
    console.log('');
    
    // 验证核心脚本
    console.log('📜 验证核心脚本...');
    const coreScripts = [
        'scripts/01-init-project.sh',
        'scripts/02-create-outline.sh',
        'scripts/03-batch-create.sh',
        'scripts/04-quality-check.sh',
        'scripts/11-unified-workflow.sh',
        'scripts/20-sandbox-creation.sh',
        'scripts/21-combined-revision.sh',
        'scripts/25-chapter-by-chapter-analyzer.sh',
        'scripts/98-project-validator.sh',
        'scripts/99-error-checker.sh'
    ];
    
    for (const script of coreScripts) {
        try {
            await fs.access(path.join(projectRoot, script));
            console.log(`  ✅ ${script}`);
        } catch (error) {
            console.log(`  ❌ ${script} - 缺失`);
            errors++;
        }
    }
    
    console.log('');
    
    // 验证核心工具
    console.log('🛠️  验证核心工具...');
    const coreTools = [
        'tools/diagnostic.js',
        'tools/token-manager.js',
        'tools/memory-enhancer.js',
        'tools/quality-analyzer.js',
        'tools/validation-checker.js'
    ];
    
    for (const tool of coreTools) {
        try {
            await fs.access(path.join(projectRoot, tool));
            console.log(`  ✅ ${tool}`);
        } catch (error) {
            console.log(`  ❌ ${tool} - 缺失`);
            errors++;
        }
    }
    
    console.log('');
    
    // 验证配置文件
    console.log('⚙️  验证配置文件...');
    const configFiles = [
        'config/qwen-settings.json',
        'config/novel-template.json',
        'config/prompt-library.json'
    ];
    
    for (const config of configFiles) {
        try {
            await fs.access(path.join(projectRoot, config));
            console.log(`  ✅ ${config}`);
        } catch (error) {
            console.log(`  ❌ ${config} - 缺失`);
            errors++;
        }
    }
    
    console.log('');
    
    // 验证文档文件
    console.log('📄 验证文档文件...');
    const docFiles = [
        'README.md',
        'INSTALL.md',
        'LICENSE',
        'QUICK_START.md',
        'QUICK_GUIDE.md'
    ];
    
    for (const doc of docFiles) {
        try {
            await fs.access(path.join(projectRoot, doc));
            console.log(`  ✅ ${doc}`);
        } catch (error) {
            console.log(`  ⚠️  ${doc} - 缺失`);
            warnings++;
        }
    }
    
    console.log('');
    
    // 检查package文件
    console.log('📦 验证包文件...');
    const packageFiles = [
        'package.json',
        'package-lock.json'
    ];
    
    for (const file of packageFiles) {
        try {
            await fs.access(path.join(projectRoot, file));
            console.log(`  ✅ ${file}`);
        } catch (error) {
            console.log(`  ⚠️  ${file} - 缺失`);
            warnings++;
        }
    }
    
    console.log('');
    
    // 验证prompts目录结构
    console.log('💬 验证prompts目录结构...');
    const promptDirs = [
        'prompts/outline',
        'prompts/chapter',
        'prompts/character',
        'prompts/worldview'
    ];
    
    for (const promptDir of promptDirs) {
        try {
            await fs.access(path.join(projectRoot, promptDir));
            console.log(`  ✅ ${promptDir}/`);
        } catch (error) {
            console.log(`  ⚠️  ${promptDir}/ - 缺失`);
            warnings++;
        }
    }
    
    console.log('');
    
    // 汇总结果
    console.log('📊 验证结果汇总:');
    console.log(`- 错误数量: ${errors}`);
    console.log(`- 警告数量: ${warnings}`);
    
    if (errors === 0) {
        console.log('\n🎉 系统完整性验证通过！');
        console.log('所有核心组件均已找到，系统可以正常运行。');
    } else {
        console.log(`\n❌ 系统完整性验证失败！发现 ${errors} 个错误。`);
        console.log('请检查上述缺失的文件或目录。');
    }
    
    if (warnings > 0) {
        console.log(`\n⚠️  发现 ${warnings} 个警告。`);
        console.log('虽然系统可以运行，但建议修复这些警告以获得完整功能。');
    }
    
    return {
        errors,
        warnings,
        passed: errors === 0
    };
}

// 运行验证
if (require.main === module) {
    validateSystemIntegrity()
        .then(result => {
            process.exit(result.passed ? 0 : 1);
        })
        .catch(error => {
            console.error('验证过程中发生错误:', error);
            process.exit(1);
        });
}

module.exports = { validateSystemIntegrity };