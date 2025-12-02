#!/bin/bash
# test-stylus-engine.sh - 验证stylus-engine模块的测试脚本

echo "🧪 开始验证stylus-engine模块..."

PROJECT_PATH="./projects/test-stylus-project"
ANALYSIS_REPORT_PATH="./projects/test-stylus-project/analysis-report.md"

echo "检查项目路径: $PROJECT_PATH"
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ 测试项目不存在，创建中..."
    mkdir -p "$PROJECT_PATH/chapters" "$PROJECT_PATH/summaries" "$PROJECT_PATH/settings"
    echo "# 测试分析报告

## 第一部分：文风指纹 (Stylometric Fingerprint)
- 语言风格: 现代白话文，略带古风韵味
- 句式特点: 多用短句，偶有长句点缀

## 第二部分：剧情与结构分析 (Plot & Structural Analysis)
- 故事结构: 线性推进，辅以少量回忆片段
- 情节发展: 采用经典的起承转合模式" > "$ANALYSIS_REPORT_PATH"
fi

echo "检查分析报告: $ANALYSIS_REPORT_PATH"
if [ ! -f "$ANALYSIS_REPORT_PATH" ]; then
    echo "❌ 分析报告不存在"
    exit 1
fi

echo "✅ 所有前提条件满足，准备测试stylus-engine功能"

# 1. 测试初始化
echo ""
echo "📋 1. 测试初始化功能..."
bash ./scripts/30-stylus-engine.sh init "$PROJECT_PATH" "$ANALYSIS_REPORT_PATH"
if [ $? -eq 0 ]; then
    echo "✅ 初始化测试通过"
else
    echo "❌ 初始化测试失败"
fi

# 2. 测试抽卡模式
echo ""
echo "🎲 2. 测试抽卡模式..."
bash ./scripts/30-stylus-engine.sh gacha "$PROJECT_PATH"
if [ $? -eq 0 ]; then
    echo "✅ 抽卡模式测试通过"
else
    echo "❌ 抽卡模式测试失败"
fi

# 3. 测试蓝图生成
echo ""
echo "\Blueprint 3. 测试蓝图生成功能..."
bash ./scripts/30-stylus-engine.sh blueprint "$PROJECT_PATH" "现代都市"
if [ $? -eq 0 ]; then
    echo "✅ 蓝图生成功能测试通过"
else
    echo "❌ 蓝图生成功能测试失败"
fi

# 4. 检查生成的文件
echo ""
echo "📁 4. 检查生成的文件..."
if [ -f "$PROJECT_PATH/stylus-engine/blueprint.md" ]; then
    echo "✅ 蓝图文件已生成"
else
    echo "❌ 蓝图文件未生成"
fi

if [ -f "$PROJECT_PATH/stylus-engine/config.json" ]; then
    echo "✅ 配置文件已更新"
    # 显示配置文件内容
    echo "📋 配置内容:"
    cat "$PROJECT_PATH/stylus-engine/config.json"
else
    echo "❌ 配置文件未更新"
fi

echo ""
echo "🎉 stylus-engine模块验证完成！"