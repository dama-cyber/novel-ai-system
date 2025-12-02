#!/bin/bash
# scripts/26-novel-splitter.sh - 小说分割工具
# 将整本小说按章节分割成独立文件，然后可以进行逐章分析

set -e

show_help() {
    echo "✂️  小说分割工具"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  split    <整本小说文件> <输出目录> [项目名]  按章节分割整本小说"
    echo "  analyze  <项目路径> <起始章> <结束章>      对分割后的章节进行逐章分析"
    echo "  full     <整本小说文件> <输出目录> [项目名]  完整流程（分割+分析）"
    echo "  help                                    显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 split \"novel.txt\" \"./projects/我的小说\" \"我的玄幻小说\""
    echo "  $0 analyze \"./projects/我的小说\" 1 10"
    echo "  $0 full \"novel.txt\" \"./projects/我的小说\" \"我的玄幻小说\""
}

# 按章节分割整本小说
split_novel() {
    local NOVEL_FILE=$1
    local OUTPUT_DIR=$2
    local PROJECT_NAME=${3:-"未命名小说"}
    
    if [ ! -f "$NOVEL_FILE" ]; then
        echo "❌ 小说文件不存在: $NOVEL_FILE"
        exit 1
    fi
    
    echo "✂️  开始分割小说: $NOVEL_FILE"
    
    # 创建输出目录
    mkdir -p "$OUTPUT_DIR/chapters"
    mkdir -p "$OUTPUT_DIR/settings"
    
    # 初始化项目元数据
    cat > "$OUTPUT_DIR/metadata.json" << EOF
{
  "title": "$PROJECT_NAME",
  "totalChapters": 0,
  "created": "$(date -Iseconds)",
  "status": "splitting"
}
EOF
    
    # 使用不同的模式尝试分割
    echo "🔍 尝试使用不同模式分割章节..."
    
    # 模式1: 查找以"第"开头的标题（如"第1章"、"第1节"等）
    local CHAPTER_PATTERN="^第[0-9一二三四五六七八九十百千万]*[章节回部节].*"
    local CHAPTER_COUNT=0
    
    # 临时文件存储当前章节内容
    local TEMP_CHAPTER_FILE=""
    local CURRENT_CHAPTER_TITLE=""
    local LINE_NUM=0
    
    # 逐行读取并分割
    while IFS= read -r line || [ -n "$line" ]; do  # 处理最后一行没有换行符的情况
        LINE_NUM=$((LINE_NUM + 1))
        
        # 检查是否是章节标题
        if [[ $line =~ ^第[0-9一二三四五六七八九十百千万]*[章节回部节].* ]]; then
            # 如果之前已经有章节内容，先保存
            if [ -n "$TEMP_CHAPTER_FILE" ] && [ -f "$TEMP_CHAPTER_FILE" ]; then
                # 添加标题到章节内容开头
                (echo "# $CURRENT_CHAPTER_TITLE" && echo "" && echo "## 概要" && echo "待AI生成" && echo "" && echo "## 正文" && echo "" && cat "$TEMP_CHAPTER_FILE") > "${TEMP_CHAPTER_FILE}.tmp"
                mv "${TEMP_CHAPTER_FILE}.tmp" "$TEMP_CHAPTER_FILE"
                echo "  保存章节: $CURRENT_CHAPTER_TITLE"
            fi
            
            # 准备新章节
            CHAPTER_TITLE=$(echo "$line" | sed 's/^[[:space:]]*[第 chapters]*[0-9一二三四五六七八九十百千万]*[章节回部节：:]*[[:space:]]*//')
            CHAPTER_COUNT=$((CHAPTER_COUNT + 1))
            FORMATTED_CHAPTER=$(printf "%03d" $CHAPTER_COUNT)
            
            TEMP_CHAPTER_FILE="$OUTPUT_DIR/chapters/chapter_${FORMATTED_CHAPTER}_$(echo $CHAPTER_TITLE | sed 's/[^a-zA-Z0-9\u4e00-\u9fa5]//g' | cut -c1-30).md"
            CURRENT_CHAPTER_TITLE="$CHAPTER_TITLE"
            
            # 创建新章节文件
            echo "" > "$TEMP_CHAPTER_FILE"
            
            echo "  发现章节: $CHAPTER_TITLE (第${CHAPTER_COUNT}章)"
        else
            # 非章节标题，添加到当前章节内容
            if [ -n "$TEMP_CHAPTER_FILE" ]; then
                echo "$line" >> "$TEMP_CHAPTER_FILE"
            fi
        fi
    done < "$NOVEL_FILE"
    
    # 处理最后一个章节
    if [ -n "$TEMP_CHAPTER_FILE" ] && [ -f "$TEMP_CHAPTER_FILE" ]; then
        (echo "# $CURRENT_CHAPTER_TITLE" && echo "" && echo "## 概要" && echo "待AI生成" && echo "" && echo "## 正文" && echo "" && cat "$TEMP_CHAPTER_FILE") > "${TEMP_CHAPTER_FILE}.tmp"
        mv "${TEMP_CHAPTER_FILE}.tmp" "$TEMP_CHAPTER_FILE"
        echo "  保存章节: $CURRENT_CHAPTER_TITLE"
    fi
    
    # 更新元数据
    cat > "$OUTPUT_DIR/metadata.json" << EOF
{
  "title": "$PROJECT_NAME",
  "totalChapters": $CHAPTER_COUNT,
  "created": "$(date -Iseconds)",
  "status": "split_complete",
  "sourceFile": "$(basename "$NOVEL_FILE")"
}
EOF
    
    echo "✅ 小说分割完成！"
    echo "📁 章节文件已保存至: $OUTPUT_DIR/chapters/"
    echo "📊 共分割出: $CHAPTER_COUNT 章"
}

# 对分割后的章节进行逐章分析
analyze_split_chapters() {
    local PROJECT_DIR=$1
    local START_CHAPTER=$2
    local END_CHAPTER=$3
    
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "❌ 项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    
    echo "🔍 开始逐章分析（第${START_CHAPTER}章到第${END_CHAPTER}章）..."
    
    # 使用我们之前创建的累积分析工具进行逐章分析
    for ((i=START_CHAPTER; i<=END_CHAPTER; i++)); do
        FORMATTED_CHAPTER=$(printf "%03d" $i)
        
        # 查找章节文件
        CHAPTER_FILE=""
        for file in "$PROJECT_DIR/chapters/chapter_${FORMATTED_CHAPTER}"_*".md"; do
            if [ -f "$file" ]; then
                CHAPTER_FILE="$file"
                break
            fi
        done
        
        if [ -n "$CHAPTER_FILE" ]; then
            echo "  正在分析第${i}章: $(basename "$CHAPTER_FILE")"
            
            # 使用逐章累积分析器处理此章节
            ./scripts/25-chapter-by-chapter-analyzer.sh analyze "$PROJECT_DIR" "$i" "$CHAPTER_FILE"
        else
            echo "  ⚠️  第${i}章文件不存在"
        fi
    done
    
    echo "✅ 逐章分析完成！"
}

# 完整流程（分割+分析）
full_process() {
    local NOVEL_FILE=$1
    local OUTPUT_DIR=$2
    local PROJECT_NAME=${3:-"未命名小说"}
    
    echo "🔄 开始完整处理流程..."
    
    # 步骤1: 分割小说
    split_novel "$NOVEL_FILE" "$OUTPUT_DIR" "$PROJECT_NAME"
    
    # 步骤2: 获取章节总数进行分析
    TOTAL_CHAPTERS=$(jq -r '.totalChapters' "$OUTPUT_DIR/metadata.json" 2>/dev/null || echo "0")
    
    if [ "$TOTAL_CHAPTERS" -gt 0 ]; then
        echo "📈 检测到 $TOTAL_CHAPTERS 章，开始分析..."
        analyze_split_chapters "$OUTPUT_DIR" 1 $TOTAL_CHAPTERS
    else
        echo "⚠️  未检测到章节，跳过分析步骤"
    fi
    
    echo "✅ 完整处理流程完成！"
}

# 主逻辑
COMMAND=$1
if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

shift  # 移除命令参数

case $COMMAND in
    "split")
        if [ $# -lt 2 ]; then
            echo "❌ split命令需要提供: 小说文件 输出目录 [项目名]"
            exit 1
        fi
        split_novel "$1" "$2" "$3"
        ;;
    "analyze")
        if [ $# -lt 3 ]; then
            echo "❌ analyze命令需要提供: 项目路径 起始章 结束章"
            exit 1
        fi
        analyze_split_chapters "$1" "$2" "$3"
        ;;
    "full")
        if [ $# -lt 2 ]; then
            echo "❌ full命令需要提供: 小说文件 输出目录 [项目名]"
            exit 1
        fi
        full_process "$1" "$2" "$3"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ 未知命令: $COMMAND"
        show_help
        exit 1
        ;;
esac