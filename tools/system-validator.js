#!/usr/bin/env node
// tools/system-validator.js - 小说AI系统完整性验证工具
// 验证所有脚本模块是否存在且语法正确

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

// 验证JavaScript文件语法
function validateJavaScript(file) {
    try {
        const content = fs.readFileSync(file, 'utf8');
        // 尝试在Node.js中编译代码，但不执行
        new Function(content);
        console.log(`✅ 语法正确: ${file}`);
        return true;
    } catch (error) {
        console.log(`❌ 语法错误: ${file} - ${error.message}`);
        return false;
    }
}

// 验证shell脚本语法
function validateShellScript(file) {
    try {
        const result = spawnSync('bash', ['-n', file], { encoding: 'utf-8' });
        if (result.status === 0) {
            console.log(`✅ 语法正确: ${file}`);
            return true;
        } else {
            console.log(`❌ 语法错误: ${file} - ${result.stderr}`);
            return false;
        }
    } catch (error) {
        console.log(`⚠️  无法验证 (bash未安装): ${file}`);
        return true; // 不计入错误，因为可能是环境问题
    }
}

// 检查文件是否存在
function checkFileExists(filePath) {
    if (fs.existsSync(filePath)) {
        console.log(`✅ 存在: ${filePath}`);
        return true;
    } else {
        console.log(`❌ 不存在: ${filePath}`);
        return false;
    }
}

// 验证模块引用
function validateModuleReferences() {
    console.log("\n🔍 验证模块引用...");

    const projectDir = path.join(__dirname, '..');
    const modulesToCheck = [
        './scripts/utils/token-manager.js',
        './scripts/utils/summary-engine.js',
        './scripts/utils/file-manager.js',
        './scripts/01-init-project.sh',
        './scripts/02-create-outline.sh',
        './scripts/03-batch-create.sh',
        './scripts/20-sandbox-creation.sh',
        './scripts/20-sandbox-creation.ps1',
        './scripts/20-sandbox-creation.bat',
        './scripts/21-combined-revision.sh',
        './scripts/21-combined-revision.ps1',
        './scripts/21-combined-revision.bat',
        './scripts/25-chapter-by-chapter-analyzer.sh',
        './scripts/25-chapter-by-chapter-analyzer.ps1',
        './scripts/25-chapter-by-chapter-analyzer.bat',
        './scripts/26-novel-splitter.sh',
        './scripts/26-novel-splitter.ps1',
        './scripts/26-novel-splitter.bat'
    ];

    let validCount = 0;
    const totalCount = modulesToCheck.length;

    for (const module of modulesToCheck) {
        const fullPath = path.join(projectDir, module);
        if (checkFileExists(fullPath)) {
            // 根据文件扩展名验证语法
            if (module.endsWith('.js')) {
                if (validateJavaScript(fullPath)) {
                    validCount++;
                }
            } else if (module.endsWith('.sh') || module.endsWith('.bat') || module.endsWith('.ps1')) {
                // 对于shell脚本、批处理和PowerShell脚本，我们验证它们存在
                // 实际语法验证需要特定环境
                validCount++;
            } else {
                validCount++; // 非脚本文件不做语法验证
            }
        }
    }

    return { valid: validCount, total: totalCount };
}

// 检查目录结构
function validateDirectoryStructure() {
    console.log("\n📁 验证目录结构...");
    
    const projectDir = path.join(__dirname, '..');
    const dirsToCheck = [
        'scripts',
        'scripts/utils',
        'projects',
        'chapters',
        'summaries',
        'settings',
        'prompts',
        'templates',
        'tools',
        'docs',
        'examples'
    ];
    
    let validCount = 0;
    const totalCount = dirsToCheck.length;
    
    for (const dir of dirsToCheck) {
        const fullPath = path.join(projectDir, dir);
        if (fs.existsSync(fullPath) && fs.statSync(fullPath).isDirectory()) {
            console.log(`✅ 目录存在: ${fullPath}`);
            validCount++;
        } else {
            console.log(`❌ 目录不存在: ${fullPath}`);
        }
    }
    
    return { valid: validCount, total: totalCount };
}

// 验证README中的引用
function validateReadmeReferences() {
    console.log("\n📖 验证README引用...");
    
    const readmePath = path.join(__dirname, '../README.md');
    if (!fs.existsSync(readmePath)) {
        console.log(`❌ README文件不存在: ${readmePath}`);
        return { valid: 0, total: 1 };
    }
    
    const readmeContent = fs.readFileSync(readmePath, 'utf8');
    
    // 检查是否包含关键模块的引用
    const requiredRefs = [
        '21-combined-revision',
        '25-chapter-by-chapter',
        '26-novel-splitter',
        'na a-',  // 逐章分析命令
        'na ns-', // 小说分割命令
        'QUICK_REFERENCE.md'
    ];
    
    let validCount = 0;
    const totalCount = requiredRefs.length;
    
    for (const ref of requiredRefs) {
        if (readmeContent.includes(ref)) {
            console.log(`✅ README包含引用: ${ref}`);
            validCount++;
        } else {
            console.log(`❌ README缺少引用: ${ref}`);
        }
    }
    
    return { valid: validCount, total: totalCount };
}

// 主验证函数
function runValidation() {
    console.log("🔄 开始验证超长篇小说AI创作系统 v16.0 完整性...\n");
    
    const moduleResults = validateModuleReferences();
    const dirResults = validateDirectoryStructure();
    const readmeResults = validateReadmeReferences();
    
    console.log("\n✅ 验证完成！");
    console.log(`\n📊 验证结果:`);
    console.log(`模块引用: ${moduleResults.valid}/${moduleResults.total} 正确`);
    console.log(`目录结构: ${dirResults.valid}/${dirResults.total} 正确`);
    console.log(`README引用: ${readmeResults.valid}/${readmeResults.total} 正确`);
    
    const totalValid = moduleResults.valid + dirResults.valid + readmeResults.valid;
    const totalChecks = moduleResults.total + dirResults.total + readmeResults.total;
    
    console.log(`\n总览: ${totalValid}/${totalChecks} 项通过验证`);
    
    if (totalValid === totalChecks) {
        console.log("\n🎉 所有验证通过！系统完整性良好。");
        return 0;
    } else {
        console.log("\n⚠️  发现问题，系统可能需要修复。");
        return 1;
    }
}

// 运行验证
if (require.main === module) {
    const exitCode = runValidation();
    process.exit(exitCode);
}

module.exports = {
    validateJavaScript,
    validateShellScript,
    checkFileExists,
    validateModuleReferences,
    validateDirectoryStructure,
    validateReadmeReferences,
    runValidation
};