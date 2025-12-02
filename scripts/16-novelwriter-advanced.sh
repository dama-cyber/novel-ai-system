#!/bin/bash
# scripts/16-novelwriter-advanced.sh - NovelWriter高级功能脚本
# 从EdwardAThomson/NovelWriter项目获取灵感，实现高级文本处理功能

set -e

show_help() {
    echo "🚀 NovelWriter高级功能脚本"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  word-count <项目路径>           统计项目字数"
    echo "  chapter-stats <项目路径>        章节统计分析"
    echo "  pov-analysis <项目路径>         视角分析"
    echo "  dialogue-check <项目路径>       对话检查"
    echo "  readability <项目路径>          可读性分析"
    echo "  timeline <项目路径>             时间线分析"
    echo "  character-tracker <项目路径>    角色追踪"
    echo "  consistency-check <项目路径>    一致性检查"
    echo "  export-novelwriter <项目路径> <输出路径>  导出为NovelWriter格式"
    echo "  help                            显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 word-count \"./projects/我的小说\""
    echo "  $0 chapter-stats \"./projects/我的小说\""
    echo "  $0 pov-analysis \"./projects/我的小说\""
}

# 统计项目字数
word_count() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "📊 项目字数统计: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 统计所有章节文件
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    TOTAL_WORDS=0
    TOTAL_CHARS=0
    TOTAL_PARAGRAPHS=0
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            WORDS=$(wc -w < "$chapter_file")
            CHARS=$(wc -m < "$chapter_file")
            PARAGRAPHS=$(grep -c "^$" "$chapter_file" 2>/dev/null || echo 0)
            PARAGRAPHS=$((PARAGRAPHS + 1)) # 加上最后一段
            
            echo "  $(basename "$chapter_file"): $WORDS 字, $CHARS 字符, $PARAGRAPHS 段落"
            
            TOTAL_WORDS=$((TOTAL_WORDS + WORDS))
            TOTAL_CHARS=$((TOTAL_CHARS + CHARS))
            TOTAL_PARAGRAPHS=$((TOTAL_PARAGRAPHS + PARAGRAPHS))
        fi
    done
    
    echo ""
    echo "总计:"
    echo "  $TOTAL_WORDS 字"
    echo "  $TOTAL_CHARS 字符"
    echo "  $TOTAL_PARAGRAPHS 段落"
    echo "  $((TOTAL_WORDS / ${#CHAPTER_FILES[@]})) 字/章 (平均)"
}

# 章节统计分析
chapter_stats() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "📈 章节统计分析: $(basename "$PROJECT_PATH")"
    echo ""
    
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    if [ ${#CHAPTER_FILES[@]} -eq 0 ]; then
        echo "未找到章节文件"
        return
    fi
    
    # 创建统计信息
    declare -a WORD_COUNTS
    TOTAL_WORDS=0
    MIN_WORDS=999999
    MAX_WORDS=0
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            WORDS=$(wc -w < "$chapter_file")
            WORD_COUNTS+=($WORDS)
            TOTAL_WORDS=$((TOTAL_WORDS + WORDS))
            
            if [ $WORDS -lt $MIN_WORDS ]; then
                MIN_WORDS=$WORDS
            fi
            if [ $WORDS -gt $MAX_WORDS ]; then
                MAX_WORDS=$WORDS
            fi
        fi
    done
    
    AVG_WORDS=$((TOTAL_WORDS / ${#CHAPTER_FILES[@]}))
    
    echo "总章节数: ${#CHAPTER_FILES[@]}"
    echo "总字数: $TOTAL_WORDS"
    echo "平均字数: $AVG_WORDS"
    echo "最少字数: $MIN_WORDS"
    echo "最多字数: $MAX_WORDS"
    echo ""
    
    # 显示每章字数
    echo "各章节字数分布:"
    for i in "${!CHAPTER_FILES[@]}"; do
        chapter_file="${CHAPTER_FILES[$i]}"
        words="${WORD_COUNTS[$i]}"
        
        # 显示一个简单的柱状图
        bar_length=$((words * 40 / MAX_WORDS))
        bar=$(printf '%*s' $bar_length | tr ' ' '█')
        
        chapter_name=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\)_\(.*\)\.md/第\1章 \2/')
        printf "%-30s [%-40s] %6d字\n" "$chapter_name" "$bar" "$words"
    done
}

# 视角分析（POV - Point of View）
pov_analysis() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔍 视角(POV)分析: $(basename "$PROJECT_PATH")"
    echo ""
    
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            chapter_name=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\)_\(.*\)\.md/第\1章 \2/')
            content=$(cat "$chapter_file")
            
            # 检查第一人称视角标记
            first_person=$(echo "$content" | grep -o -i -E "\b(我|我的|自己)\b" | wc -l)
            # 检查第二人称视角标记
            second_person=$(echo "$content" | grep -o -i -E "\b(你|你的|您)\b" | wc -l)
            # 检查第三人称视角标记
            third_person=$(echo "$content" | grep -o -i -E "\b(他|她|它|他们|她们|它的|他的|她的)\b" | wc -l)
            
            echo "$chapter_name:"
            echo "  第一人称(我): $first_person 次"
            echo "  第二人称(你): $second_person 次" 
            echo "  第三人称(他/她): $third_person 次"
            
            # 检测视角混乱（三种人称都出现很多）
            if [ $first_person -gt 20 ] && [ $third_person -gt 20 ]; then
                echo "  ⚠️  可能存在视角混乱"
            fi
            echo ""
        fi
    done
}

# 对话检查
dialogue_check() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "💬 对话检查: $(basename "$PROJECT_PATH")"
    echo ""
    
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    TOTAL_DIALOGUE_LINES=0
    TOTAL_QUOTES=0
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            chapter_name=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\)_\(.*\)\.md/第\1章 \2/')
            content=$(cat "$chapter_file")
            
            # 检查对话标记 (中文引号)
            dialogue_lines=$(echo "$content" | grep -o '"[^"]*"' | wc -l)
            dialogue_lines2=$(echo "$content" | grep -o "'[^']*'" | wc -l)
            total_chapter_dialogue=$((dialogue_lines + dialogue_lines2))
            
            TOTAL_DIALOGUE_LINES=$((TOTAL_DIALOGUE_LINES + total_chapter_dialogue))
            
            echo "$chapter_name: $total_chapter_dialogue 条对话"
        fi
    done
    
    echo ""
    echo "总计对话数: $TOTAL_DIALOGUE_LINES"
    if [ $TOTAL_DIALOGUE_LINES -eq 0 ]; then
        echo "⚠️  未发现对话，小说可能缺乏人物交互"
    elif [ $TOTAL_DIALOGUE_LINES -lt 10 ]; then
        echo "⚠️  对话较少，可考虑增加人物对话"
    else
        echo "✅ 对话数量适中"
    fi
}

# 可读性分析
readability() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🎯 可读性分析: $(basename "$PROJECT_PATH")"
    echo ""
    
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    TOTAL_SENTENCES=0
    TOTAL_WORDS=0
    TOTAL_PARAGRAPHS=0
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; do
            chapter_name=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\)_\(.*\)\.md/第\1章 \2/')
            content=$(cat "$chapter_file")
            
            # 简单的句子计数（基于中文句号）
            sentences=$(echo "$content" | grep -o "[。！？]" | wc -l)
            words=$(wc -w < "$chapter_file")
            paragraphs=$(grep -c "^$" "$chapter_file" 2>/dev/null || echo 0)
            paragraphs=$((paragraphs + 1))
            
            TOTAL_SENTENCES=$((TOTAL_SENTENCES + sentences))
            TOTAL_WORDS=$((TOTAL_WORDS + words))
            TOTAL_PARAGRAPHS=$((TOTAL_PARAGRAPHS + paragraphs))
            
            if [ $sentences -gt 0 ]; then
                avg_words_per_sentence=$((words / sentences))
            else
                avg_words_per_sentence=0
            fi
            
            echo "$chapter_name:"
            echo "  句子数: $sentences"
            echo "  字数: $words"
            echo "  平均句长: $avg_words_per_sentence 字"
            echo ""
        fi
    done
    
    if [ $TOTAL_SENTENCES -gt 0 ]; then
        overall_avg=$((TOTAL_WORDS / TOTAL_SENTENCES))
        echo "整体平均句长: $overall_avg 字"
        
        if [ $overall_avg -gt 25 ]; then
            echo "⚠️  平均句长过长，可能影响可读性"
        elif [ $overall_avg -lt 8 ]; then
            echo "⚠️  平均句长过短，可能显得零碎"
        else
            echo "✅ 句长适中"
        fi
    fi
}

# 时间线分析
timeline() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🕐 时间线分析: $(basename "$PROJECT_PATH")"
    echo ""
    
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    echo "搜索与时间相关的词汇..."
    
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            chapter_name=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\)_\(.*\)\.md/第\1章 \2/')
            content=$(cat "$chapter_file")
            
            # 搜索时间词汇
            time_references=$(echo "$content" | grep -o -i -E "(日|天|月|年|时|刻|早上|中午|晚上|夜晚|清晨|傍晚|春|夏|秋|冬|现在|当时|随后|之前|之后|过去|未来|古代|现代|昨天|今天|明天|一月|二月|三月|四月|五月|六月|七月|八月|九月|十月|十一月|十二月|一时辰|一天|一月|一年|时间|岁月|光阴|年代|世纪|年代)" | sort | uniq)
            
            if [ -n "$time_references" ]; then
                echo "$chapter_name:"
                echo "  时间标记: $time_references"
                echo ""
            fi
        fi
    done
}

# 角色追踪
character_tracker() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    # 从设置文件获取角色信息
    CHARACTERS_FILE="$PROJECT_PATH/settings/characters.json"
    
    if [ -f "$CHARACTERS_FILE" ]; then
        echo "👥 角色追踪: $(basename "$PROJECT_PATH")"
        echo ""
        
        # 提取角色名称
        CHARACTERS=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$CHARACTERS_FILE" | cut -d'"' -f4 | grep -v '^$' | sort | uniq)
        
        # 如果无法从JSON提取，使用默认方法
        if [ -z "$CHARACTERS" ]; then
            # 尝试从内容中提取可能的人名
            ALL_CONTENT=$(find "$PROJECT_PATH/chapters" -name "*.md" -exec cat {} \;)
            # 简单提取中文人名 (2-4字，通常在句子开头)
            CHARACTERS=$(echo "$ALL_CONTENT" | grep -o -E "[。？！][[:space:]]*[^，。？！]{2,4}[，。？！]" | sed 's/[。？！][[:space:]]*//' | sed 's/[，。？！].*//' | sort | uniq | head -20)
        fi
        
        CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
        
        # 为每个角色创建出现统计
        for character in $CHARACTERS; do
            if [ -n "$character" ] && [ ${#character} -ge 2 ]; then
                echo "角色: $character"
                
                for chapter_file in "${CHAPTER_FILES[@]}"; do
                    if [ -f "$chapter_file" ]; then
                        chapter_name=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\)_\(.*\)\.md/第\1章 \2/')
                        count=$(grep -o "$character" "$chapter_file" | wc -l)
                        
                        if [ $count -gt 0 ]; then
                            echo "  $chapter_name: 出现 $count 次"
                        fi
                    fi
                done
                
                echo ""
            fi
        done
    else
        echo "⚠️  未找到角色设定文件，无法进行角色追踪"
        echo "请确保 $CHARACTERS_FILE 文件存在"
    fi
}

# 一致性检查
consistency_check() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔍 一致性检查: $(basename "$PROJECT_PATH")"
    echo ""
    
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    if [ ${#CHAPTER_FILES[@]} -eq 0 ]; then
        echo "未找到章节文件"
        return
    fi
    
    # 合并所有章节内容
    ALL_CONTENT=""
    for chapter_file in "${CHAPTER_FILES[@]}"; do
        if [ -f "$chapter_file" ]; then
            ALL_CONTENT="$ALL_CONTENT"$'\n'"$(cat "$chapter_file")"
        fi
    done
    
    # 检查常见的不一致性
    echo "检查重复词汇..."
    DUPLICATE_WORDS=$(echo "$ALL_CONTENT" | grep -o -E '\b(\w+)\s+\1\b' | sort | uniq)
    
    if [ -n "$DUPLICATE_WORDS" ]; then
        echo "发现重复词汇:"
        echo "$DUPLICATE_WORDS"
        echo ""
    else
        echo "✅ 未发现明显重复词汇"
        echo ""
    fi
    
    # 检查可能的拼写/用词不一致
    echo "检查常用词汇变体..."
    # 检查"的" "地" "得"使用
    DE_COUNTS=$(echo "$ALL_CONTENT" | grep -o -E "[的地得]" | sort | uniq -c)
    echo "$DE_COUNTS"
    echo ""
    
    # 检查标点符号使用
    echo "检查标点符号使用..."
    PUNCTUATION_COUNTS=$(echo "$ALL_CONTENT" | grep -o -E "[。！？，、；：""''「」《》【】]" | sort | uniq -c)
    echo "$PUNCTUATION_COUNTS"
}

# 主逻辑
COMMAND=$1
if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

shift  # 移除命令参数

case $COMMAND in
    "word-count")
        if [ $# -lt 1 ]; then
            echo "❌ 字数统计命令需要提供: 项目路径"
            exit 1
        fi
        word_count "$1"
        ;;
    "chapter-stats")
        if [ $# -lt 1 ]; then
            echo "❌ 章节统计命令需要提供: 项目路径"
            exit 1
        fi
        chapter_stats "$1"
        ;;
    "pov-analysis")
        if [ $# -lt 1 ]; then
            echo "❌ 视角分析命令需要提供: 项目路径"
            exit 1
        fi
        pov_analysis "$1"
        ;;
    "dialogue-check")
        if [ $# -lt 1 ]; then
            echo "❌ 对话检查命令需要提供: 项目路径"
            exit 1
        fi
        dialogue_check "$1"
        ;;
    "readability")
        if [ $# -lt 1 ]; then
            echo "❌ 可读性分析命令需要提供: 项目路径"
            exit 1
        fi
        readability "$1"
        ;;
    "timeline")
        if [ $# -lt 1 ]; then
            echo "❌ 时间线分析命令需要提供: 项目路径"
            exit 1
        fi
        timeline "$1"
        ;;
    "character-tracker")
        if [ $# -lt 1 ]; then
            echo "❌ 角色追踪命令需要提供: 项目路径"
            exit 1
        fi
        character_tracker "$1"
        ;;
    "consistency-check")
        if [ $# -lt 1 ]; then
            echo "❌ 一致性检查命令需要提供: 项目路径"
            exit 1
        fi
        consistency_check "$1"
        ;;
    "export-novelwriter")
        if [ $# -lt 2 ]; then
            echo "❌ 导出NovelWriter格式命令需要提供: 项目路径 输出路径"
            exit 1
        fi
        python tools/novelwriter-exporter.py "$1" "$2"
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