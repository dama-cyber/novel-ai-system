#!/bin/bash
# scripts/23-element-swapper.sh - 换元设计模块
# 专注于设计如何在现有章节中融入新元素

set -e

show_help() {
    echo "🔄 换元设计模块"
    echo ""
    echo "用法: $0 <项目路径> <起始章> <结束章> <新元素>"
    echo ""
    echo "功能:"
    echo "  基于拆书分析结果，设计如何在章节中融入新元素"
    echo "  生成详细的换元实施方案"
    echo ""
    echo "示例:"
    echo "  $0 \"./projects/我的小说\" 1 10 \"加入神秘导师角色\""
}

PROJECT_DIR=$1
CHAPTER_START=$2
CHAPTER_END=$3
NEW_ELEMENT=$4

if [ -z "$PROJECT_DIR" ] || [ -z "$CHAPTER_START" ] || [ -z "$CHAPTER_END" ] || [ -z "$NEW_ELEMENT" ]; then
    show_help
    exit 1
fi

echo "🔄 开始换元设计（第${CHAPTER_START}章到第${CHAPTER_END}章，添加:${NEW_ELEMENT}）..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
OUTPUT_DIR="$PROJECT_DIR/element-swap-designs"
SWAP_DIR="$OUTPUT_DIR/$(date +%Y%m%d_%H%M%S)"

# 创建输出目录
mkdir -p "$SWAP_DIR"

# 换元设计汇总报告
SWAP_REPORT="$SWAP_DIR/swap-design-report.md"
{
    echo "# 换元设计方案报告"
    echo ""
    echo "## 项目信息"
    echo "- 项目路径: $PROJECT_DIR"
    echo "- 设计范围: 第${CHAPTER_START}章 到 第${CHAPTER_END}章"
    echo "- 新元素: $NEW_ELEMENT"
    echo "- 生成时间: $(date -Iseconds)"
    echo ""
    echo "## 换元设计方案"
    echo ""
} > "$SWAP_REPORT"

# 执行换元设计
for ((i=CHAPTER_START; i<=CHAPTER_END; i++)); do
    FORMATTED_CHAPTER=$(printf "%03d" $i)
    
    # 查找章节和分析文件
    CHAPTER_FILE=""
    for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
        if [ -f "$file" ]; then
            CHAPTER_FILE="$file"
            break
        fi
    done
    
    ANALYSIS_FILE=""
    ANALYSIS_SEARCH_DIR="$PROJECT_DIR/split-analysis"
    if [ -d "$ANALYSIS_SEARCH_DIR" ]; then
        for file in "$ANALYSIS_SEARCH_DIR"/*/chapter_${FORMATTED_CHAPTER}_analysis.md; do
            if [ -f "$file" ]; then
                ANALYSIS_FILE="$file"
                break
            fi
        done
    fi
    
    if [ -n "$CHAPTER_FILE" ]; then
        echo "  正在设计第${i}章的换元方案..."
        
        # 提取章节内容
        CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
        CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
        
        ANALYSIS_CONTENT=""
        if [ -n "$ANALYSIS_FILE" ] && [ -f "$ANALYSIS_FILE" ]; then
            ANALYSIS_CONTENT=$(cat "$ANALYSIS_FILE")
        else
            ANALYSIS_CONTENT="未找到该章节的拆书分析"
        fi
        
        # 构建换元设计提示词
        SWAP_PROMPT="你是一个专业的换元设计师和故事重构专家。

请基于以下拆书分析和原章节内容，设计如何融入新元素：${NEW_ELEMENT}

原章节信息：
- 章节：第${i}章
- 标题：${CHAPTER_TITLE}

原章节正文：
${CHAPTER_CONTENT}

拆书分析：
${ANALYSIS_CONTENT}

新元素描述：${NEW_ELEMENT}

请按以下要求设计换元方案：

1. **融合方案**
   - 如何自然地引入新元素
   - 与原情节的结合点
   - 对角色关系/情节的影响

2. **具体修改点**
   - 哪些段落需要修改
   - 哪些情节需要调整
   - 需要新增的场景或对话

3. **保持一致性**
   - 如何保持原有的故事节奏
   - 如何保持原有语言风格
   - 对后续章节的影响

4. **实施计划**
   - 修改优先级
   - 需要注意的问题
   - 预期效果

请提供详细的换元设计方案，使用markdown格式输出。"
        
        # 生成换元设计文件
        SWAP_OUTPUT="$SWAP_DIR/chapter_${FORMATTED_CHAPTER}_swap-plan.md"
        
        # 调用Qwen进行换元设计（如果可用）
        if command -v qwen &> /dev/null; then
            echo "$SWAP_PROMPT" | qwen > "$SWAP_OUTPUT"
        else
            # 如果qwen不可用，创建示例方案文件
            cat > "$SWAP_OUTPUT" << EOF
## 第${i}章换元设计方案

### 融合方案
- 如何自然地引入"${NEW_ELEMENT}"的示例方法
- 与本章情节的结合点示例
- 对角色关系的影响示例

### 具体修改点
- 需要修改的段落实例
- 需要调整的情节示例
- 需要新增的场景或对话示例

### 保持一致性
- 保持原故事节奏的方法示例
- 保持原语言风格的方法示例
- 对后续章节影响的考虑示例

### 实施计划
- 修改优先级示例
- 需要注意的问题示例
- 预期效果示例
EOF
        fi
        
        # 将结果追加到汇总报告
        {
            echo "### 第${i}章：${CHAPTER_TITLE}"
            echo ""
            echo "<details>"
            echo "<summary>点击查看换元设计方案</summary>"
            echo ""
            cat "$SWAP_OUTPUT"
            echo ""
            echo "</details>"
            echo ""
        } >> "$SWAP_REPORT"
        
        echo "  ✅ 第${i}章换元设计完成"
    else
        echo "  ⚠️  第${i}章文件不存在"
        
        # 在汇总报告中记录缺失章节
        {
            echo "### 第${i}章：文件不存在"
            echo ""
            echo "> 该章节文件未找到，无法进行换元设计"
            echo ""
        } >> "$SWAP_REPORT"
    fi
done

echo "✅ 换元设计完成！方案报告已生成: $SWAP_REPORT"