#!/bin/bash
# scripts/14-enhancement-suite.sh - 增强套件（Qwen Coder CLI优化）
# 提供各种增强功能，如续写、修改、优化等

set -e

show_help() {
    echo "✨ 超长篇小说AI创作系统 - 增强套件"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  continue   <项目路径> <章节号>    续写指定章节"
    echo "  revise     <章节路径>             修改指定章节"
    echo "  optimize   <章节路径>             优化指定章节"
    echo "  analyze    <项目路径>             分析项目质量"
    echo "  expand     <章节路径> <位置>      扩展章节内容"
    echo "  help                              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 continue \"./projects/我的小说\" 10"
    echo "  $0 revise \"./projects/我的小说/chapters/chapter_001_标题.md\""
    echo "  $0 analyze \"./projects/我的小说\""
}

# 续写章节
continue_chapter() {
    PROJECT_PATH=$1
    CHAPTER_NUM=$2
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    # 查找目标章节文件
    CHAPTER_FILE=""
    for file in "$PROJECT_PATH/chapters/chapter_$(printf "%03d" $CHAPTER_NUM)"_*".md"; do
        if [ -f "$file" ]; then
            CHAPTER_FILE="$file"
            break
        fi
    done
    
    if [ -z "$CHAPTER_FILE" ]; then
        echo "❌ 找不到第${CHAPTER_NUM}章: $PROJECT_PATH/chapters/chapter_$(printf "%03d" $CHAPTER_NUM)_*"
        exit 1
    fi
    
    echo "📖 正在续写: $CHAPTER_FILE"
    
    # 读取现有章节内容
    EXISTING_CONTENT=$(cat "$CHAPTER_FILE")
    
    # 提取正文部分（跳过标题）
    CONTENT_START=$(echo "$EXISTING_CONTENT" | grep -n "## 正文" | cut -d: -f1)
    if [ -n "$CONTENT_START" ]; then
        # 有正文标识
        CHAPTER_CONTENT=$(echo "$EXISTING_CONTENT" | sed -n "$((CONTENT_START+1)),\$p")
    else
        # 没有正文标识，使用全部内容
        CHAPTER_CONTENT="$EXISTING_CONTENT"
    fi
    
    # 构建续写提示
    cat > /tmp/continue_prompt.txt << EOF
# 任务
请续写以下小说章节内容。

# 现有内容
$CHAPTER_CONTENT

# 续写要求
- 保持原有文风和人物性格
- 确保情节逻辑连贯
- 增加约1000字的新内容
- 与现有结尾自然衔接

现在开始续写：
EOF
    
    # 生成续写内容
    ADDITIONAL_CONTENT=$(cat /tmp/continue_prompt.txt | qwen)
    
    # 更新章节文件
    if [ -n "$CONTENT_START" ]; then
        # 有正文标识，只替换正文部分
        HEADER_PART=$(echo "$EXISTING_CONTENT" | sed -n "1,$((CONTENT_START))p")
        NEW_CONTENT="${HEADER_PART}\n${ADDITIONAL_CONTENT}"
    else
        # 没有正文标识，直接追加
        NEW_CONTENT="${EXISTING_CONTENT}\n\n${ADDITIONAL_CONTENT}"
    fi
    
    echo -e "$NEW_CONTENT" > "$CHAPTER_FILE"
    
    echo "✅ 第${CHAPTER_NUM}章续写完成"
}

# 修改章节
revise_chapter() {
    CHAPTER_PATH=$1
    
    if [ ! -f "$CHAPTER_PATH" ]; then
        echo "❌ 章节文件不存在: $CHAPTER_PATH"
        exit 1
    fi
    
    echo "🔧 正在修改: $CHAPTER_PATH"
    
    # 读取现有内容
    EXISTING_CONTENT=$(cat "$CHAPTER_PATH")
    
    # 构建修改提示
    cat > /tmp/revise_prompt.txt << EOF
# 任务
请根据以下要求修改小说章节内容。

# 原始内容
$EXISTING_CONTENT

# 修改要求
- 改进语言表达，使其更生动
- 增强人物对话的个性化
- 优化情节节奏和张力
- 保持原有故事线不变
- 润色文笔，减少AI腔

现在进行修改：
EOF
    
    # 生成修改后的内容
    REVISED_CONTENT=$(cat /tmp/revise_prompt.txt | qwen)
    
    # 更新文件
    echo "$REVISED_CONTENT" > "$CHAPTER_PATH"
    
    echo "✅ 章节修改完成"
}

# 优化章节
optimize_chapter() {
    CHAPTER_PATH=$1
    
    if [ ! -f "$CHAPTER_PATH" ]; then
        echo "❌ 章节文件不存在: $CHAPTER_PATH"
        exit 1
    fi
    
    echo "⚡ 正在优化: $CHAPTER_PATH"
    
    # 读取现有内容
    EXISTING_CONTENT=$(cat "$CHAPTER_PATH")
    
    # 构建优化提示
    cat > /tmp/optimize_prompt.txt << EOF
# 任务
请对以下章节进行优化，使其更符合高质量网络小说标准。

# 原始内容
$EXISTING_CONTENT

# 优化标准
- 优化语言，消除AI腔表达
- 增强情节的爽点和转折
- 优化人物对话和心理描写
- 增加细节描写，提升画面感
- 调整节奏，确保每千字有至少一个看点
- 检查逻辑一致性，修正矛盾

请输出优化后的内容：
EOF
    
    # 生成优化后的内容
    OPTIMIZED_CONTENT=$(cat /tmp/optimize_prompt.txt | qwen)
    
    # 更新文件
    echo "$OPTIMIZED_CONTENT" > "$CHAPTER_PATH"
    
    echo "✅ 章节优化完成"
}

# 分析项目
analyze_project() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔍 正在分析项目: $PROJECT_PATH"
    
    # 统计信息
    CHAPTERS=($(find "$PROJECT_PATH/chapters" -name "chapter_*.md" | sort))
    CHAPTER_COUNT=${#CHAPTERS[@]}
    
    echo "📊 项目分析报告"
    echo "总章节数: $CHAPTER_COUNT"
    
    if [ $CHAPTER_COUNT -gt 0 ]; then
        # 随机选择几章进行AI分析（避免过多API调用）
        SAMPLE_SIZE=3
        if [ $CHAPTER_COUNT -lt $SAMPLE_SIZE ]; then
            SAMPLE_SIZE=$CHAPTER_COUNT
        fi
        
        SAMPLE_CHAPTERS=()
        for i in $(seq 0 $((SAMPLE_SIZE-1))); do
            INDEX=$((i * CHAPTER_COUNT / SAMPLE_SIZE))
            SAMPLE_CHAPTERS+=("${CHAPTERS[$INDEX]}")
        done
        
        ANALYSIS_INPUT=""
        for chapter_path in "${SAMPLE_CHAPTERS[@]}"; do
            chapter_content=$(head -c 1000 "$chapter_path")  # 只取前1000字符作为样本
            ANALYSIS_INPUT="$ANALYSIS_INPUT\n章节 $(basename "$chapter_path"): $chapter_content\n\n"
        done
        
        # 构建分析提示
        cat > /tmp/analyze_prompt.txt << EOF
# 任务
请分析以下小说章节样本，提供质量评估和改进建议。

# 章节样本
$ANALYSIS_INPUT

# 分析维度
- 文笔质量
- 情节连贯性
- 人物塑造
- 节奏把控
- 语言风格

# 输出格式
- 优点分析
- 改进建议
- 风格评价

请分析：
EOF
        
        # 获取AI分析结果
        ANALYSIS_RESULT=$(cat /tmp/analyze_prompt.txt | qwen)
        
        # 生成分析报告
        ANALYSIS_REPORT_PATH="$PROJECT_PATH/analysis-report.md"
        cat > "$ANALYSIS_REPORT_PATH" << EOF
# 《$(basename "$PROJECT_PATH")》项目分析报告

## 📊 概览
- 分析时间: $(date -Iseconds)
- 总章节数: $CHAPTER_COUNT
- 抽样分析: $SAMPLE_SIZE 章

## 🧠 AI分析结果
$ANALYSIS_RESULT

## 📈 项目统计
- 章节文件数: $CHAPTER_COUNT
- 设置文件: $(ls "$PROJECT_PATH/settings/"*.json 2>/dev/null | wc -l)
- 总字数估算: $(find "$PROJECT_PATH/chapters" -name "*.md" -exec cat {} \; | wc -w) 字

## 📋 提示
如需进一步优化，可使用增强套件中的 optimize 命令。
EOF
        
        echo "✅ 项目分析完成，报告已保存: $ANALYSIS_REPORT_PATH"
    else
        echo "⚠️  未找到章节文件"
    fi
}

# 扩展章节内容
expand_chapter() {
    CHAPTER_PATH=$1
    EXPAND_AT=${2:-"end"}  # 默认扩展末尾
    
    if [ ! -f "$CHAPTER_PATH" ]; then
        echo "❌ 章节文件不存在: $CHAPTER_PATH"
        exit 1
    fi
    
    echo "➕ 正在扩展: $CHAPTER_PATH (位置: $EXPAND_AT)"
    
    # 读取现有内容
    EXISTING_CONTENT=$(cat "$CHAPTER_PATH")
    
    # 根据扩展位置构建提示
    if [ "$EXPAND_AT" = "end" ]; then
        CONTEXT="在章节末尾扩展以下内容"
        TARGET_CONTENT="$EXISTING_CONTENT"
    elif [ "$EXPAND_AT" = "middle" ]; then
        # 取中间部分进行扩展
        LINE_COUNT=$(echo "$EXISTING_CONTENT" | wc -l)
        MIDDLE_START=$((LINE_COUNT / 3))
        MIDDLE_END=$(((LINE_COUNT * 2) / 3))
        CONTEXT="扩展以下章节中间部分的内容"
        TARGET_CONTENT=$(echo "$EXISTING_CONTENT" | sed -n "${MIDDLE_START},${MIDDLE_END}p")
    else
        echo "❌ 无效的扩展位置: $EXPAND_AT"
        exit 1
    fi
    
    # 构建扩展提示
    cat > /tmp/expand_prompt.txt << EOF
# 任务
$CONTEXT

# 原始内容
$TARGET_CONTENT

# 扩展要求
- 保持原有情节和文风
- 增加丰富的细节描写
- 扩展人物心理活动
- 增加环境描写
- 增加约1000字内容
- 确保扩展部分与原有内容自然融合

请提供扩展后的内容：
EOF
    
    # 生成扩展后的内容
    EXPANDED_CONTENT=$(cat /tmp/expand_prompt.txt | qwen)
    
    # 根据扩展位置决定如何保存
    if [ "$EXPAND_AT" = "end" ]; then
        # 扩展末尾，直接追加
        echo -e "$EXISTING_CONTENT\n\n$EXPANDED_CONTENT" > "$CHAPTER_PATH"
    elif [ "$EXPAND_AT" = "middle" ]; then
        # 扩展中间，替换中间部分
        LINE_COUNT=$(echo "$EXISTING_CONTENT" | wc -l)
        MIDDLE_START=$((LINE_COUNT / 3))
        MIDDLE_END=$(((LINE_COUNT * 2) / 3))
        
        # 保留开始部分、插入扩展内容、保留结束部分
        START_PART=$(echo "$EXISTING_CONTENT" | sed -n "1,$((MIDDLE_START-1))p")
        END_PART=$(echo "$EXISTING_CONTENT" | sed -n "$((MIDDLE_END+1)),$ p")
        
        NEW_CONTENT="$START_PART\n$EXPANDED_CONTENT\n$END_PART"
        echo -e "$NEW_CONTENT" > "$CHAPTER_PATH"
    fi
    
    echo "✅ 章节扩展完成"
}

# 主逻辑
COMMAND=$1
if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

shift  # 移除命令参数

case $COMMAND in
    "continue")
        if [ $# -lt 2 ]; then
            echo "❌ 续写命令需要提供: 项目路径 章节号"
            exit 1
        fi
        continue_chapter "$1" "$2"
        ;;
    "revise")
        if [ $# -lt 1 ]; then
            echo "❌ 修改命令需要提供: 章节路径"
            exit 1
        fi
        revise_chapter "$1"
        ;;
    "optimize")
        if [ $# -lt 1 ]; then
            echo "❌ 优化命令需要提供: 章节路径"
            exit 1
        fi
        optimize_chapter "$1"
        ;;
    "analyze")
        if [ $# -lt 1 ]; then
            echo "❌ 分析命令需要提供: 项目路径"
            exit 1
        fi
        analyze_project "$1"
        ;;
    "expand")
        if [ $# -lt 1 ]; then
            echo "❌ 扩展命令需要提供: 章节路径 [扩展位置]"
            exit 1
        fi
        expand_chapter "$1" "$2"
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