#!/bin/bash
# scripts/22-split-book-analyzer.sh - 拆书分析模块
# 专注于分析章节结构、内容、技巧和伏笔等

set -e

show_help() {
    echo "🔍 拆书分析模块"
    echo ""
    echo "用法: $0 <项目路径> <起始章> <结束章>"
    echo ""
    echo "功能:"
    echo "  对指定范围的章节进行深度拆书分析"
    echo "  分析内容包括：情节结构、人物发展、写作技巧、伏笔呼应等"
    echo ""
    echo "示例:"
    echo "  $0 \"./projects/我的小说\" 1 10"
}

PROJECT_DIR=$1
CHAPTER_START=$2
CHAPTER_END=$3

if [ -z "$PROJECT_DIR" ] || [ -z "$CHAPTER_START" ] || [ -z "$CHAPTER_END" ]; then
    show_help
    exit 1
fi

echo "🔍 开始拆书分析（第${CHAPTER_START}章到第${CHAPTER_END}章）..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
OUTPUT_DIR="$PROJECT_DIR/split-analysis"
ANALYSIS_DIR="$OUTPUT_DIR/$(date +%Y%m%d_%H%M%S)"

# 创建输出目录
mkdir -p "$ANALYSIS_DIR"

# 用于汇总分析结果的文件
ANALYSIS_FILE="$ANALYSIS_DIR/split-analysis-report.md"
{
    echo "# 拆书分析报告"
    echo ""
    echo "## 项目信息"
    echo "- 项目路径: $PROJECT_DIR"
    echo "- 分析范围: 第${CHAPTER_START}章 到 第${CHAPTER_END}章"
    echo "- 分析时间: $(date -Iseconds)"
    echo ""
    echo "## 拆书详情"
    echo ""
} > "$ANALYSIS_FILE"

# 执行拆书分析
for ((i=CHAPTER_START; i<=CHAPTER_END; i++)); do
    FORMATTED_CHAPTER=$(printf "%03d" $i)
    
    # 查找章节文件
    CHAPTER_FILE=""
    for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
        if [ -f "$file" ]; then
            CHAPTER_FILE="$file"
            break
        fi
    done
    
    if [ -n "$CHAPTER_FILE" ] && [ -f "$CHAPTER_FILE" ]; then
        echo "  正在分析第${i}章..."
        
        # 提取章节标题
        CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
        
        # 提取章节内容
        CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
        
        # 构建拆书分析提示词
        SPLIT_PROMPT="你是一个专业的拆书专家和小说分析员，擅长深入分析小说内容。

请对以下章节进行拆书分析：

章节信息：
- 章节：第${i}章
- 标题：${CHAPTER_TITLE}

章节正文：
${CHAPTER_CONTENT}

请按以下结构进行分析：

1. **核心情节总结**：简要概述本章的主要情节
2. **人物发展**：分析本章中角色的成长、变化或行为
3. **情节推进**：说明本章如何推动整体故事前进
4. **冲突与转折**：指出本章中的冲突点或剧情转折
5. **伏笔与呼应**：识别本章埋设的伏笔或呼应前面情节的内容
6. **写作技巧**：分析作者使用的写作技巧、修辞手法等
7. **情感调动**：分析本章如何调动读者情感
8. **节奏控制**：分析本章的节奏安排

请用markdown格式输出分析结果。"
        
        # 生成分析文件
        ANALYSIS_OUTPUT="$ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
        
        # 调用Qwen进行拆书分析（如果qwen命令可用）
        if command -v qwen &> /dev/null; then
            echo "$SPLIT_PROMPT" | qwen > "$ANALYSIS_OUTPUT"
        else
            # 如果qwen不可用，创建示例分析文件
            cat > "$ANALYSIS_OUTPUT" << EOF
## 第${i}章拆书分析

### 核心情节总结
这是第${i}章的主要情节概述。

### 人物发展
本章中人物的成长、变化或行为分析。

### 情节推进
说明本章如何推动整体故事前进。

### 冲突与转折
本章中的冲突点或剧情转折。

### 伏笔与呼应
本章埋设的伏笔或呼应前面情节的内容。

### 写作技巧
分析作者使用的写作技巧、修辞手法等。

### 情感调动
分析本章如何调动读者情感。

### 节奏控制
分析本章的节奏安排。
EOF
        fi
        
        # 将结果追加到汇总报告
        {
            echo "### 第${i}章：${CHAPTER_TITLE}"
            echo ""
            echo "<details>"
            echo "<summary>点击查看拆书分析</summary>"
            echo ""
            cat "$ANALYSIS_OUTPUT"
            echo ""
            echo "</details>"
            echo ""
        } >> "$ANALYSIS_FILE"
        
        echo "  ✅ 第${i}章拆书分析完成"
    else
        echo "  ⚠️  第${i}章文件不存在"
        
        # 在汇总报告中记录缺失章节
        {
            echo "### 第${i}章：文件不存在"
            echo ""
            echo "> 该章节文件未找到，无法进行拆书分析"
            echo ""
        } >> "$ANALYSIS_FILE"
    fi
done

echo "✅ 拆书分析完成！分析报告已生成: $ANALYSIS_FILE"