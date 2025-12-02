#!/usr/bin/env node

/**
 * 环境诊断工具
 * 检查系统环境是否满足运行要求
 */

const os = require('os');
const fs = require('fs');
const { execSync } = require('child_process');

function checkNodeVersion() {
  const version = process.version;
  const majorVersion = parseInt(version.split('.')[0].substring(1));
  
  console.log(`Node.js 版本: ${version}`);
  
  if (majorVersion >= 20) {
    console.log('✅ Node.js 版本满足要求 (≥ 20.0)');
    return true;
  } else {
    console.log('❌ Node.js 版本过低，需要 ≥ 20.0');
    return false;
  }
}

function checkQwenCLI() {
  try {
    const version = execSync('qwen --version', { encoding: 'utf8' });
    console.log(`Qwen CLI 版本: ${version.trim()}`);
    console.log('✅ Qwen CLI 已安装');
    return true;
  } catch (error) {
    console.log('❌ Qwen CLI 未安装或不可用');
    console.log('请运行: npm install -g @qwen-code/qwen-code@latest');
    return false;
  }
}

function checkDiskSpace() {
  const freeSpace = Math.round(os.freemem() / (1024 * 1024 * 1024)); // GB
  console.log(`可用磁盘空间: ${freeSpace} GB`);
  
  if (freeSpace > 1) {
    console.log('✅ 磁盘空间充足');
    return true;
  } else {
    console.log('⚠️ 磁盘空间可能不足');
    return false;
  }
}

function checkInternetConnection() {
  try {
    // 尝试访问一个可靠的网站
    execSync('ping -c 1 baidu.com', { timeout: 5000 });
    console.log('✅ 网络连接正常');
    return true;
  } catch (error) {
    console.log('⚠️ 网络连接可能存在问题');
    return false;
  }
}

function checkGit() {
  try {
    const version = execSync('git --version', { encoding: 'utf8' });
    console.log(`Git 版本: ${version.trim()}`);
    console.log('✅ Git 已安装');
    return true;
  } catch (error) {
    console.log('⚠️ Git 未安装或不可用');
    return false;
  }
}

function runDiagnostics() {
  console.log('🔍 开始环境诊断...\n');
  
  const checks = [
    { name: 'Node.js 版本检查', fn: checkNodeVersion },
    { name: 'Qwen CLI 检查', fn: checkQwenCLI },
    { name: '磁盘空间检查', fn: checkDiskSpace },
    { name: '网络连接检查', fn: checkInternetConnection },
    { name: 'Git 检查', fn: checkGit }
  ];
  
  const results = [];
  
  for (const check of checks) {
    console.log(`\n📋 ${check.name}:`);
    const result = check.fn();
    results.push({ name: check.name, passed: result });
  }
  
  console.log('\n📊 诊断结果汇总:');
  let passedCount = 0;
  for (const result of results) {
    const status = result.passed ? '✅' : '❌';
    console.log(`${status} ${result.name}: ${result.passed ? '通过' : '未通过'}`);
    if (result.passed) passedCount++;
  }
  
  console.log(`\n总通过率: ${passedCount}/${checks.length} (${Math.round((passedCount/checks.length)*100)}%)`);
  
  if (passedCount === checks.length) {
    console.log('\n🎉 所有检查均通过！环境准备就绪。');
  } else {
    console.log('\n⚠️ 环境存在问题，请按提示修复后重试。');
  }
  
  return passedCount === checks.length;
}

// 如果直接运行此脚本
if (require.main === module) {
  runDiagnostics();
}

module.exports = {
  checkNodeVersion,
  checkQwenCLI,
  checkDiskSpace,
  checkInternetConnection,
  checkGit,
  runDiagnostics
};