#!/bin/bash
# scripts/15-novelwriter-integration.sh - NovelWriter功能整合脚本
# 将EdwardAThomson/NovelWriter的特性整合到本地项目中

set -e

show_help() {
    echo "📚 NovelWriter功能整合脚本"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  export-md <项目路径> <输出路径>  将项目导出为Markdown格式"
    echo "  export-html <项目路径> <输出路径> 将项目导出为HTML格式"
    echo "  export-odt <项目路径> <输出路径>  将项目导出为ODT格式"
    echo "  analyze-project <项目路径>       分析项目结构和统计信息"
    echo "  split-scenes <项目路径>          将章节拆分为场景"
    echo "  compile-book <项目路径> <输出路径>  编译项目为完整书籍"
    echo "  help                            显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 export-md \"./projects/我的小说\" \"./exports/我的小说.md\""
    echo "  $0 analyze-project \"./projects/我的小说\""
}

# 导出为Markdown格式
export_to_markdown() {
    PROJECT_PATH=$1
    OUTPUT_PATH=$2
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "📝 正在导出为Markdown格式..."
    
    # 创建输出目录
    mkdir -p "$(dirname "$OUTPUT_PATH")"
    
    # 获取所有章节文件
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    # 写入标题和前言
    {
        echo "# $(basename "$PROJECT_PATH")"
        echo ""
        echo "## 前言"
        echo "这是一部由超长篇小说AI创作系统 v16.0 生成的小说。"
        echo "创作时间: $(date -Iseconds)"
        echo ""
    } > "$OUTPUT_PATH"
    
    # 添加章节内容
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            # 提取章节标题
            CHAPTER_TITLE=$(basename "$chapter_file" | sed 's/chapter_[0-9]*_\(.*\)\.md/\1/')
            CHAPTER_NUM=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\).*/\1/')
            
            # 读取章节内容并添加到输出文件
            {
                echo "## 第${CHAPTER_NUM}章: $CHAPTER_TITLE"
                echo ""
                cat "$chapter_file"
                echo ""
                echo "---"
                echo ""
            } >> "$OUTPUT_PATH"
        fi
    done
    
    echo "✅ Markdown导出完成: $OUTPUT_PATH"
}

# 导出为HTML格式
export_to_html() {
    PROJECT_PATH=$1
    OUTPUT_PATH=$2
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🌐 正在导出为HTML格式..."
    
    # 创建输出目录
    mkdir -p "$(dirname "$OUTPUT_PATH")"
    
    # 获取所有章节文件
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    # 生成HTML头部
    cat > "$OUTPUT_PATH" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$(basename "$PROJECT_PATH")</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 40px; }
        .chapter { margin-bottom: 40px; }
        .chapter-title { color: #333; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .divider { text-align: center; margin: 20px 0; }
    </style>
</head>
<body>
    <header>
        <h1>$(basename "$PROJECT_PATH")</h1>
        <p>创作时间: $(date -Iseconds)</p>
    </header>
    <hr>
EOF
    
    # 添加章节内容
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            # 提取章节标题
            CHAPTER_TITLE=$(basename "$chapter_file" | sed 's/chapter_[0-9]*_\(.*\)\.md/\1/')
            CHAPTER_NUM=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\).*/\1/')
            
            # 读取章节内容
            CHAPTER_CONTENT=$(cat "$chapter_file")
            
            # 转换Markdown格式为HTML
            TEMP_MD=$(mktemp)
            echo "$CHAPTER_CONTENT" > "$TEMP_MD"
            if command -v pandoc &>/dev/null; then
                HTML_CONTENT=$(pandoc -f markdown -t html "$TEMP_MD" 2>/dev/null || echo "$CHAPTER_CONTENT")
            else
                # 如果pandoc不可用，使用简单的转换
                HTML_CONTENT="$CHAPTER_CONTENT"
                # 这里可以实现简单的Markdown到HTML转换
            fi
            rm "$TEMP_MD"
            
            # 添加到HTML输出
            cat >> "$OUTPUT_PATH" << EOF
    <section class="chapter">
        <h2 class="chapter-title">第${CHAPTER_NUM}章: $CHAPTER_TITLE</h2>
        $HTML_CONTENT
    </section>
    <div class="divider">● ● ●</div>
EOF
        fi
    done
    
    # 添加HTML尾部
    cat >> "$OUTPUT_PATH" << EOF
</body>
</html>
EOF
    
    echo "✅ HTML导出完成: $OUTPUT_PATH"
}

# 分析项目结构和统计信息
analyze_project() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔍 正在分析项目: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 统计章节信息
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    TOTAL_CHAPTERS=${#CHAPTER_FILES[@]}
    
    echo "📊 项目统计:"
    echo "  章节数: $TOTAL_CHAPTERS"
    
    if [ $TOTAL_CHAPTERS -gt 0 ]; then
        # 统计字数和行数
        TOTAL_WORDS=0
        TOTAL_LINES=0
        
        for chapter_file in "${CHAPTER_FILES[@]}"; do
            if [ -f "$chapter_file" ]; then
                WORDS=$(wc -w < "$chapter_file")
                LINES=$(wc -l < "$chapter_file")
                TOTAL_WORDS=$((TOTAL_WORDS + WORDS))
                TOTAL_LINES=$((TOTAL_LINES + LINES))
            fi
        done
        
        echo "  总字数: $TOTAL_WORDS"
        echo "  总行数: $TOTAL_LINES"
        echo "  平均每章字数: $((TOTAL_WORDS / TOTAL_CHAPTERS))"
        echo "  平均每章行数: $((TOTAL_LINES / TOTAL_CHAPTERS))"
    fi
    
    # 检查设置文件
    echo ""
    echo "⚙️  项目设置:"
    SETTINGS_DIR="$PROJECT_PATH/settings"
    if [ -d "$SETTINGS_DIR" ]; then
        for setting_file in "$SETTINGS_DIR"/*.json; do
            if [ -f "$setting_file" ]; then
                SETTING_NAME=$(basename "$setting_file" .json)
                echo "  - $SETTING_NAME: $(if [ -s "$setting_file" ]; then echo "已配置"; else echo "未配置"; fi)"
            fi
        done
    else
        echo "  - 未找到设置目录"
    fi
    
    # 检查大纲文件
    echo ""
    echo "📋 大纲文件:"
    if [ -f "$PROJECT_PATH/outline.md" ]; then
        echo "  - 已生成"
    else
        echo "  - 未生成"
    fi
    
    # 生成详细分析报告
    ANALYSIS_REPORT="$PROJECT_PATH/novelwriter-analysis.md"
    cat > "$ANALYSIS_REPORT" << EOF
# 《$(basename "$PROJECT_PATH")》NovelWriter分析报告

## 📊 统计信息
- 章节数: $TOTAL_CHAPTERS
- 总字数: $TOTAL_WORDS
- 总行数: $TOTAL_LINES
- 平均每章字数: $((TOTAL_WORDS / TOTAL_CHAPTERS))
- 分析时间: $(date -Iseconds)

## 📝 章节列表
EOF

    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            CHAPTER_TITLE=$(basename "$chapter_file" | sed 's/chapter_[0-9]*_\(.*\)\.md/\1/')
            CHAPTER_NUM=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\).*/\1/')
            CHAPTER_WORDS=$(wc -w < "$chapter_file")
            echo "- 第${CHAPTER_NUM}章: $CHAPTER_TITLE ($CHAPTER_WORDS字)" >> "$ANALYSIS_REPORT"
        fi
    done
    
    echo "" >> "$ANALYSIS_REPORT"
    echo "## 📋 项目结构" >> "$ANALYSIS_REPORT"
    tree -L 2 "$PROJECT_PATH" >> "$ANALYSIS_REPORT" 2>/dev/null || echo "tree命令不可用，无法显示目录结构" >> "$ANALYSIS_REPORT"
    
    echo ""
    echo "✅ 详细分析报告已生成: $ANALYSIS_REPORT"
}

# 拆分章节为场景
split_scenes() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "✂️  正在拆分章节为场景..."
    
    # 创建场景目录
    SCENES_DIR="$PROJECT_PATH/scenes"
    mkdir -p "$SCENES_DIR"
    
    # 遍历所有章节
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            CHAPTER_BASENAME=$(basename "$chapter_file" .md)
            CHAPTER_NUM=$(echo "$CHAPTER_BASENAME" | sed 's/chapter_\([0-9]*\).*/\1/')
            CHAPTER_TITLE=$(echo "$CHAPTER_BASENAME" | sed 's/chapter_[0-9]*_\(.*\)/\1/')
            
            # 读取章节内容
            CHAPTER_CONTENT=$(cat "$chapter_file")
            
            # 按场景分隔符分割内容（通常是空行或特殊标记）
            # 这里我们使用简单的分隔方法，按"### "或"---"分隔
            SCENE_DIR="$SCENES_DIR/chapter_${CHAPTER_NUM}"
            mkdir -p "$SCENE_DIR"
            
            # 使用awk按分隔符分割内容
            SCENE_NUM=1
            echo "$CHAPTER_CONTENT" | awk -v scene_dir="$SCENE_DIR" -v chapter_num="$CHAPTER_NUM" -v scene_num="$SCENE_NUM" '
            BEGIN { 
                current_scene = 1; 
                filename = scene_dir "/scene_" chapter_num "_" sprintf("%03d", current_scene) ".md";
                output = "";
            }
            /^### / || /^---/ {  # 按###或---分隔场景
                if (length(output) > 0) {
                    print output > filename;
                    close(filename);
                    current_scene++;
                    filename = scene_dir "/scene_" chapter_num "_" sprintf("%03d", current_scene) ".md";
                    output = $0 "\n";
                } else {
                    output = $0 "\n";
                }
                next;
            }
            {
                output = output $0 "\n";
            }
            END {
                if (length(output) > 0) {
                    print output > filename;
                    close(filename);
                }
            }'
            
            echo "  - 第${CHAPTER_NUM}章拆分为$(ls "$SCENE_DIR" | wc -l)个场景"
        fi
    done
    
    echo "✅ 章节拆分完成，场景文件保存在: $SCENES_DIR"
}

# 编译完整书籍
compile_book() {
    PROJECT_PATH=$1
    OUTPUT_PATH=$2
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    if [ -z "$OUTPUT_PATH" ]; then
        OUTPUT_PATH="$PROJECT_PATH/compiled-book.md"
    fi
    
    echo "📚 正在编译完整书籍..."
    
    # 创建编译后的书籍
    {
        echo "# $(basename "$PROJECT_PATH")"
        echo ""
        echo "## 版权信息"
        echo "- 作者: AI创作"
        echo "- 创作时间: $(date -Iseconds)"
        echo "- 本书由超长篇小说AI创作系统 v16.0 生成"
        echo ""
        echo "## 目录"
    } > "$OUTPUT_PATH"
    
    # 添加目录
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            CHAPTER_TITLE=$(basename "$chapter_file" | sed 's/chapter_[0-9]*_\(.*\)\.md/\1/')
            CHAPTER_NUM=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\).*/\1/')
            echo "1. [第${CHAPTER_NUM}章: $CHAPTER_TITLE](#第${CHAPTER_NUM}章-$CHAPTER_TITLE)" >> "$OUTPUT_PATH"
        fi
    done
    
    echo "" >> "$OUTPUT_PATH"
    
    # 添加章节内容
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            CHAPTER_TITLE=$(basename "$chapter_file" | sed 's/chapter_[0-9]*_\(.*\)\.md/\1/')
            CHAPTER_NUM=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\).*/\1/')
            
            {
                echo "## 第${CHAPTER_NUM}章: $CHAPTER_TITLE"
                echo ""
                cat "$chapter_file"
                echo ""
                echo ""
            } >> "$OUTPUT_PATH"
        fi
    done
    
    echo "✅ 书籍编译完成: $OUTPUT_PATH"
}

# 主逻辑
COMMAND=$1
if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

shift  # 移除命令参数

case $COMMAND in
    "export-md")
        if [ $# -lt 2 ]; then
            echo "❌ 导出Markdown命令需要提供: 项目路径 输出路径"
            exit 1
        fi
        export_to_markdown "$1" "$2"
        ;;
    "export-html")
        if [ $# -lt 2 ]; then
            echo "❌ 导出HTML命令需要提供: 项目路径 输出路径"
            exit 1
        fi
        export_to_html "$1" "$2"
        ;;
    "analyze-project")
        if [ $# -lt 1 ]; then
            echo "❌ 分析项目命令需要提供: 项目路径"
            exit 1
        fi
        analyze_project "$1"
        ;;
    "split-scenes")
        if [ $# -lt 1 ]; then
            echo "❌ 拆分场景命令需要提供: 项目路径"
            exit 1
        fi
        split_scenes "$1"
        ;;
    "compile-book")
        if [ $# -lt 1 ]; then
            echo "❌ 编译书籍命令需要提供: 项目路径 [输出路径]"
            exit 1
        fi
        compile_book "$1" "$2"
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