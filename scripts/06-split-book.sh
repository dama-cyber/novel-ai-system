#!/bin/bash
# scripts/06-split-book.sh - 拆书脚本

set -e

PROJECT_DIR=$1
CHAPTER_START=$2
CHAPTER_END=$3

if [ -z "$PROJECT_DIR" ] || [ -z "$CHAPTER_START" ] || [ -z "$CHAPTER_END" ]; then
    echo "用法: $0 <项目目录> <起始章节> <结束章节>"
    echo "例如: $0 \"./projects/我的玄幻小说\" 1 50"
    exit 1
fi

echo "✂️  开始拆书任务（第${CHAPTER_START}章到第${CHAPTER_END}章）..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
OUTPUT_DIR="$PROJECT_DIR/split-analysis"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 用于汇总分析结果的文件
ANALYSIS_FILE="$OUTPUT_DIR/split-analysis.md"
{
    echo "# 拆书分析报告"
    echo ""
    echo "## 项目信息"
    echo "- 项目路径: $PROJECT_DIR"
    echo "- 分析范围: 第${CHAPTER_START}章 到 第${CHAPTER_END}章"
    echo "- 生成时间: $(date -Iseconds)"
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
    
    if [ -n "$CHAPTER_FILE" ]; then
        echo "正在分析第${i}章..."
        
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

        # 调用Qwen进行拆书分析
        ANALYSIS_OUTPUT="$OUTPUT_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
        echo "$SPLIT_PROMPT" | qwen > "$ANALYSIS_OUTPUT"
        
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
        
        echo "✅ 第${i}章拆书分析完成"
    else
        echo "⚠️  第${i}章文件不存在"
        
        # 在汇总报告中记录缺失章节
        {
            echo "### 第${i}章：文件不存在"
            echo ""
            echo "> 该章节文件未找到，无法进行拆书分析"
            echo ""
        } >> "$ANALYSIS_FILE"
    fi
done

echo "✅ 拆书任务完成！分析报告已生成: $ANALYSIS_FILE"