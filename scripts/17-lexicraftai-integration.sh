#!/bin/bash
# scripts/17-lexicraftai-integration.sh - LexicraftAI功能融合脚本
# 将EuclidStellar/LexicraftAI的特性整合到本地项目中

set -e

show_help() {
    echo "💎 LexicraftAI功能融合脚本"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  vocabulary-analysis <项目路径>    词汇分析"
    echo "  word-frequency <项目路径>         词频统计"
    echo "  synonym-replacer <项目路径>       同义词替换优化"
    echo "  style-analyzer <项目路径>         风格分析"
    echo "  sentiment-check <项目路径>        情感分析"
    echo "  readability-improver <项目路径>   可读性改进"
    echo "  generate-vocabulary <项目路径>    生成词汇表"
    echo "  export-lexicon <项目路径> <输出路径> 导出词典"
    echo "  context-optimizer <项目路径>      上下文优化"
    echo "  prose-enhancer <项目路径>         散文增强"
    echo "  help                            显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 vocabulary-analysis \"./projects/我的小说\""
    echo "  $0 word-frequency \"./projects/我的小说\""
    echo "  $0 synonym-replacer \"./projects/我的小说\""
}

# 词汇分析
vocabulary_analysis() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔤 词汇分析: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 合并所有章节内容
    ALL_CONTENT=""
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            ALL_CONTENT="$ALL_CONTENT"$'\n'"$(cat "$chapter_file")"
        fi
    done
    
    # 统计中文词汇
    TOTAL_CHARS=$(echo "$ALL_CONTENT" | grep -o '[^[:space:]]' | wc -l)
    UNIQUE_CHARS=$(echo "$ALL_CONTENT" | grep -o '[^[:space:]]' | sort | uniq | wc -l)
    
    # 统计汉字（排除标点）
    CHINESE_CHARS=$(echo "$ALL_CONTENT" | grep -o '[一-龯]' | wc -l)
    UNIQUE_CHINESE_CHARS=$(echo "$ALL_CONTENT" | grep -o '[一-龯]' | sort | uniq | wc -l)
    
    # 估算词汇数
    WORDS=$(echo "$ALL_CONTENT" | wc -w)
    
    echo "总字符数: $TOTAL_CHARS"
    echo "唯一字符数: $UNIQUE_CHARS"
    echo "汉字总数: $CHINESE_CHARS"
    echo "唯一汉字数: $UNIQUE_CHINESE_CHARS"
    echo "估算词数: $WORDS"
    echo "词汇丰富度: $(echo "scale=2; $UNIQUE_CHINESE_CHARS * 100 / $CHINESE_CHARS" | bc)%"
    
    if [ $CHINESE_CHARS -gt 0 ]; then
        RICHNESS=$(echo "scale=2; $UNIQUE_CHINESE_CHARS * 100 / $CHINESE_CHARS" | bc)
        if [ $(echo "$RICHNESS > 30" | bc) -eq 1 ]; then
            echo "✅ 词汇丰富度良好"
        else
            echo "⚠️  词汇丰富度较低，建议增加词汇多样性"
        fi
    fi
}

# 词频统计
word_frequency() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "📊 词频统计: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 合并所有章节内容
    ALL_CONTENT=""
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            ALL_CONTENT="$ALL_CONTENT"$'\n'"$(cat "$chapter_file")"
        fi
    done
    
    # 提取中文词汇（2字及以上）
    temp_file=$(mktemp)
    echo "$ALL_CONTENT" | grep -oE '[一-龯]{2,}' | sort | uniq -c | sort -nr > "$temp_file"
    
    echo "高频词汇 (前20):"
    head -20 "$temp_file" | awk '{printf "%-6s %s\n", $1, $2}'
    
    # 清理临时文件
    rm "$temp_file"
    
    echo ""
    echo "💡 提示: 高频词汇可能需要替换以增加多样性"
}

# 同义词替换优化
synonym_replacer() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔄 同义词替换优化: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 检查是否有Qwen CLI可用
    if ! command -v qwen &> /dev/null; then
        echo "⚠️  Qwen CLI不可用，无法执行同义词替换"
        return
    fi
    
    # 获取高频词列表
    ALL_CONTENT=""
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            ALL_CONTENT="$ALL_CONTENT"$'\n'"$(cat "$chapter_file")"
        fi
    done
    
    # 找出高频重复词（出现10次以上）
    temp_file=$(mktemp)
    echo "$ALL_CONTENT" | grep -oE '[一-龯]{2,}' | sort | uniq -c | awk '$1 > 10 {print $2}' > "$temp_file"
    
    REPLACEMENTS=()
    while IFS= read -r word; do
        if [ -n "$word" ]; then
            # 创建优化提示
            PROMPT="请为中文词汇'$word'提供5个同义词或近义词，用逗号分隔，不要解释，只输出同义词列表："
            
            # 调用Qwen获取同义词
            SYNONYMS=$(echo "$PROMPT" | qwen 2>/dev/null || echo "")
            
            if [ -n "$SYNONYMS" ] && [ "$SYNONYMS" != "$word" ]; then
                REPLACEMENTS+=("$word|$SYNONYMS")
                echo "词汇 '$word' 的同义词: $SYNONYMS"
            fi
        fi
    done < "$temp_file"
    
    # 清理临时文件
    rm "$temp_file"
    
    if [ ${#REPLACEMENTS[@]} -gt 0 ]; then
        echo ""
        echo "正在应用同义词替换..."
        
        # 为每个章节应用同义词替换
        for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
            if [ -f "$chapter_file" ]; then
                echo "  处理: $(basename "$chapter_file")"
                
                # 读取原始内容
                CONTENT=$(cat "$chapter_file")
                
                # 应用替换
                for replacement in "${REPLACEMENTS[@]}"; do
                    ORIGINAL=$(echo "$replacement" | cut -d'|' -f1)
                    SYNONYMS=$(echo "$replacement" | cut -d'|' -f2)
                    
                    # 从同义词列表中随机选择一个进行替换
                    IFS=',' read -ra SYNONYM_LIST <<< "$SYNONYMS"
                    if [ ${#SYNONYM_LIST[@]} -gt 0 ]; then
                        RANDOM_INDEX=$((RANDOM % ${#SYNONYM_LIST[@]}))
                        REPLACEMENT_WORD=$(echo "${SYNONYM_LIST[$RANDOM_INDEX]}" | xargs)  # 去除空格
                        
                        # 随机替换部分实例（避免全部替换）
                        if [ $((RANDOM % 3)) -eq 0 ]; then  # 约33%的替换概率
                            # 使用sed进行替换
                            CONTENT=$(echo "$CONTENT" | sed "s/$ORIGINAL/$REPLACEMENT_WORD/g")
                        fi
                    fi
                done
                
                # 写回文件
                echo "$CONTENT" > "$chapter_file"
            fi
        done
        
        echo "✅ 同义词替换优化完成"
    else
        echo "未找到高频词汇，无需替换"
    fi
}

# 风格分析
style_analyzer() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🎭 风格分析: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 合并所有章节内容
    ALL_CONTENT=""
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            ALL_CONTENT="$ALL_CONTENT"$'\n'"$(cat "$chapter_file")"
        fi
    done
    
    # 统计句子长度
    SENTENCE_LENGTHS=$(echo "$ALL_CONTENT" | grep -o '[^。！？]*[。！？]' | awk '{print length($0)}')
    if [ -n "$SENTENCE_LENGTHS" ]; then
        AVG_LENGTH=$(echo "$SENTENCE_LENGTHS" | awk '{sum += $1; count++} END {if(count > 0) print sum/count; else print 0}')
        echo "平均句长: $(printf "%.2f" $AVG_LENGTH) 字"
    fi
    
    # 统计对话比例
    DIALOGUE_COUNT=$(echo "$ALL_CONTENT" | grep -o '"[^"]*"' | wc -l)
    TOTAL_WORDS=$(echo "$ALL_CONTENT" | wc -w)
    if [ $TOTAL_WORDS -gt 0 ]; then
        DIALOGUE_RATIO=$(echo "scale=2; $DIALOGUE_COUNT * 100 / $TOTAL_WORDS" | bc)
        echo "对话密度: $DIALOGUE_RATIO%"
    fi
    
    # 统计形容词和副词使用
    DESCRIPTIVE_WORDS=$(echo "$ALL_CONTENT" | grep -o -E '非常|特别|极其|十分|很|最|极其地|非常地|特别地' | wc -l)
    if [ $TOTAL_WORDS -gt 0 ]; then
        DESCRIPTIVE_RATIO=$(echo "scale=2; $DESCRIPTIVE_WORDS * 100 / $TOTAL_WORDS" | bc)
        echo "描述词密度: $DESCRIPTIVE_RATIO%"
        
        if [ $(echo "$DESCRIPTIVE_RATIO > 5" | bc) -eq 1 ]; then
            echo "⚠️  描述词使用过多，可能影响阅读体验"
        else
            echo "✅ 描述词使用适中"
        fi
    fi
    
    # 分析语气词使用
    TONE_WORDS=$(echo "$ALL_CONTENT" | grep -o -E '啊|呀|呢|吧|嘛|哦|嘿|哼|嗯|哎' | wc -l)
    if [ $TOTAL_WORDS -gt 0 ]; then
        TONE_RATIO=$(echo "scale=2; $TONE_WORDS * 100 / $TOTAL_WORDS" | bc)
        echo "语气词密度: $TONE_RATIO%"
        
        if [ $(echo "$TONE_RATIO > 3" | bc) -eq 1 ]; then
            echo "⚠️  语气词使用过多，可能显得口语化"
        fi
    fi
}

# 情感分析（概念实现）
sentiment_check() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "❤️  情感分析: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 检查是否有Qwen CLI可用
    if ! command -v qwen &> /dev/null; then
        echo "⚠️  Qwen CLI不可用，使用关键词分析"
        
        # 简单的情感关键词分析
        ALL_CONTENT=""
        for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
            if [ -f "$chapter_file" ]; then
                ALL_CONTENT="$ALL_CONTENT"$'\n'"$(cat "$chapter_file")"
            fi
        done
        
        POSITIVE_WORDS="好,美,爱,快乐,幸福,喜悦,温暖,阳光,希望,美好,善良,优美,开心,愉快"
        NEGATIVE_WORDS="坏,恨,痛苦,悲伤,绝望,黑暗,恐惧,害怕,仇恨,沮丧,愤怒,恶劣,讨厌,伤心"
        
        POS_COUNT=0
        NEG_COUNT=0
        
        IFS=',' read -ra POS_ARRAY <<< "$POSITIVE_WORDS"
        IFS=',' read -ra NEG_ARRAY <<< "$NEGATIVE_WORDS"
        
        for word in "${POS_ARRAY[@]}"; do
            count=$(echo "$ALL_CONTENT" | grep -o "$word" | wc -l)
            POS_COUNT=$((POS_COUNT + count))
        done
        
        for word in "${NEG_ARRAY[@]}"; do
            count=$(echo "$ALL_CONTENT" | grep -o "$word" | wc -l)
            NEG_COUNT=$((NEG_COUNT + count))
        done
        
        TOTAL_EMOTIONAL=$(($POS_COUNT + $NEG_COUNT))
        if [ $TOTAL_EMOTIONAL -gt 0 ]; then
            POS_RATIO=$(echo "scale=2; $POS_COUNT * 100 / $TOTAL_EMOTIONAL" | bc)
            NEG_RATIO=$(echo "scale=2; $NEG_COUNT * 100 / $TOTAL_EMOTIONAL" | bc)
            
            echo "正面情感词汇: $POS_COUNT 个 ($POS_RATIO%)"
            echo "负面情感词汇: $NEG_COUNT 个 ($NEG_RATIO%)"
            
            if [ $POS_COUNT -gt $((NEG_COUNT * 2)) ]; then
                echo "📈 情感倾向: 积极"
            elif [ $NEG_COUNT -gt $((POS_COUNT * 2)) ]; then
                echo "📉 情感倾向: 消极"
            else
                echo "📊 情感倾向: 平衡"
            fi
        else
            echo "ℹ️  未检测到明显情感词汇"
        fi
        return
    fi
    
    # 使用Qwen进行情感分析
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            chapter_name=$(basename "$chapter_file" | sed 's/chapter_\([0-9]*\)_\(.*\)\.md/第\1章 \2/')
            content=$(head -c 2000 "$chapter_file")  # 只取前2000字符分析
            
            PROMPT="请分析以下文本的情感倾向，输出格式为：情感倾向：[积极/消极/中性]，正面情感词：[词汇]，负面情感词：[词汇]，情感强度：[1-10]，主要情感主题：[主题]。文本：$content"
            
            RESULT=$(echo "$PROMPT" | qwen 2>/dev/null || echo "分析失败")
            echo "$chapter_name: $RESULT"
            echo ""
        fi
    done
}

# 可读性改进
readability_improver() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "📈 可读性改进: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 检查是否有Qwen CLI可用
    if ! command -v qwen &> /dev/null; then
        echo "⚠️  Qwen CLI不可用，无法执行可读性改进"
        return
    fi
    
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            chapter_name=$(basename "$chapter_file")
            echo "处理: $chapter_name"
            
            # 读取章节内容
            content=$(cat "$chapter_file")
            
            # 创建改进提示
            PROMPT="请改进以下文本的可读性，要求：1)简化复杂句式 2)替换难懂词汇 3)保持原意 4)改进段落结构 5)增强清晰度。原文：$content"
            
            # 调用Qwen改进
            IMPROVED_CONTENT=$(echo "$PROMPT" | qwen 2>/dev/null || echo "$content")
            
            if [ "$IMPROVED_CONTENT" != "$content" ]; then
                # 备份原文件
                cp "$chapter_file" "${chapter_file}.readability_bak"
                # 写入改进后的内容
                echo "$IMPROVED_CONTENT" > "$chapter_file"
                echo "  ✅ $chapter_name 已改进"
            else
                echo "  ℹ️  $chapter_name 无需改进或改进失败"
            fi
        fi
    done
}

# 生成词汇表
generate_vocabulary() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "📚 生成词汇表: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 合并所有章节内容
    ALL_CONTENT=""
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            ALL_CONTENT="$ALL_CONTENT"$'\n'"$(cat "$chapter_file")"
        fi
    done
    
    # 提取所有中文词汇（2字符以上）
    VOCAB_FILE="$PROJECT_PATH/vocabulary.txt"
    echo "$ALL_CONTENT" | grep -oE '[一-龯]{2,}' | sort | uniq -c | sort -nr > "$VOCAB_FILE"
    
    # 统计信息
    TOTAL_WORDS=$(cat "$VOCAB_FILE" | wc -l)
    UNIQUE_WORDS=$(cat "$VOCAB_FILE" | wc -l)
    
    # 创建包含词义解释的词汇表
    LEXICON_FILE="$PROJECT_PATH/lexicon.md"
    {
        echo "# 《$(basename "$PROJECT_PATH")》词汇表"
        echo ""
        echo "生成时间: $(date -Iseconds)"
        echo "总词汇数: $TOTAL_WORDS"
        echo ""
        echo "## 词汇列表"
        echo ""
    } > "$LEXICON_FILE"
    
    # 为高频词汇添加解释（使用Qwen）
    if command -v qwen &> /dev/null; then
        echo "正在为高频词汇添加解释..."
        
        # 只为出现5次以上的词汇添加解释
        while read -r line; do
            COUNT=$(echo "$line" | awk '{print $1}')
            WORD=$(echo "$line" | awk '{print $2}')
            
            if [ "$COUNT" -gt 5 ] && [ ${#WORD} -ge 2 ]; then
                # 创建查询提示
                PROMPT="请为中文词汇'$WORD'提供1个简洁的含义解释，只输出解释，不要其他内容："
                
                MEANING=$(echo "$PROMPT" | qwen 2>/dev/null || echo "含义待定")
                
                echo "- **$WORD** ($COUNT次): $MEANING" >> "$LEXICON_FILE"
            fi
        done < <(head -50 "$VOCAB_FILE")  # 只处理前50个高频词
    else
        # 如果没有Qwen，只列出词汇
        while read -r line; do
            COUNT=$(echo "$line" | awk '{print $1}')
            WORD=$(echo "$line" | awk '{print $2}')
            
            if [ "$COUNT" -gt 5 ] && [ ${#WORD} -ge 2 ]; then
                echo "- **$WORD** ($COUNT次): 含义待定" >> "$LEXICON_FILE"
            fi
        done < <(head -50 "$VOCAB_FILE")
    fi
    
    echo "✅ 词汇表生成完成"
    echo "  - 简单词汇表: $VOCAB_FILE"
    echo "  - 详细词典: $LEXICON_FILE"
}

# 导出词典
export_lexicon() {
    PROJECT_PATH=$1
    OUTPUT_PATH=$2
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    if [ -z "$OUTPUT_PATH" ]; then
        OUTPUT_PATH="$PROJECT_PATH/lexicon_export"
    fi
    
    echo "📤 导出词典到: $OUTPUT_PATH"
    
    # 确保输出目录存在
    mkdir -p "$OUTPUT_PATH"
    
    # 生成词汇表
    generate_vocabulary "$PROJECT_PATH"
    
    # 复制词典文件
    cp "$PROJECT_PATH/vocabulary.txt" "$OUTPUT_PATH/" 2>/dev/null || true
    cp "$PROJECT_PATH/lexicon.md" "$OUTPUT_PATH/" 2>/dev/null || true
    
    # 创建JSON格式的词典
    JSON_LEXICON="$OUTPUT_PATH/lexicon.json"
    {
        echo "{"
        echo "  \"title\": \"$(basename "$PROJECT_PATH") 词典\","
        echo "  \"generated\": \"$(date -Iseconds)\","
        echo "  \"words\": ["
    } > "$JSON_LEXICON"
    
    # 读取词汇表并转换为JSON格式
    is_first=true
    while read -r line; do
        COUNT=$(echo "$line" | awk '{print $1}')
        WORD=$(echo "$line" | awk '{print $2}')
        
        if [ "$COUNT" -gt 3 ] && [ ${#WORD} -ge 2 ]; then
            if [ "$is_first" = true ]; then
                is_first=false
            else
                echo "    }," >> "$JSON_LEXICON"
            fi
            
            # 获取词义（如果Qwen可用）
            if command -v qwen &> /dev/null; then
                PROMPT="请为中文词汇'$WORD'提供1个简洁的含义解释，只输出解释，不要其他内容："
                MEANING=$(echo "$PROMPT" | qwen 2>/dev/null || echo "含义待定")
            else
                MEANING="含义待定"
            fi
            
            echo "    {" >> "$JSON_LEXICON"
            echo "      \"word\": \"$WORD\"," >> "$JSON_LEXICON"
            echo "      \"frequency\": $COUNT," >> "$JSON_LEXICON"
            echo "      \"meaning\": \"$MEANING\"" >> "$JSON_LEXICON"
        fi
    done < <(head -100 "$PROJECT_PATH/vocabulary.txt")
    
    if [ "$is_first" = false ]; then
        echo "    }" >> "$JSON_LEXICON"
    fi
    
    echo "  ]" >> "$JSON_LEXICON"
    echo "}" >> "$JSON_LEXICON"
    
    echo "✅ 词典导出完成: $OUTPUT_PATH"
}

# 上下文优化
context_optimizer() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔄 上下文优化: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 检查是否有Qwen CLI可用
    if ! command -v qwen &> /dev/null; then
        echo "⚠️  Qwen CLI不可用，无法执行上下文优化"
        return
    fi
    
    # 获取章节列表
    CHAPTER_FILES=($(find "$PROJECT_PATH/chapters" -name "*.md" | sort))
    
    for i in "${!CHAPTER_FILES[@]}"; do
        chapter_file="${CHAPTER_FILES[$i]}"
        chapter_name=$(basename "$chapter_file")
        echo "优化: $chapter_name"
        
        # 读取当前章节内容
        current_content=$(cat "$chapter_file")
        
        # 获取前一章内容作为上下文（如果存在）
        prev_content=""
        if [ $i -gt 0 ]; then
            prev_file="${CHAPTER_FILES[$((i-1))]}"
            prev_content="# 前一章内容:\n$(head -c 1000 "$prev_file")\n\n"
        fi
        
        # 获取后一章内容作为上下文（如果存在）
        next_content=""
        if [ $((i+1)) -lt ${#CHAPTER_FILES[@]} ]; then
            next_file="${CHAPTER_FILES[$((i+1))]}"
            next_content="# 后一章预告:\n$(head -c 500 "$next_file")\n\n"
        fi
        
        # 创建优化提示
        PROMPT="请优化以下章节内容的上下文连贯性，使其与前后章节衔接更自然。$prev_content$next_content# 当前章节内容:\n$current_content\n\n# 优化要求:\n1) 改进与前章的承接\n2) 为后章做铺垫\n3) 保持原意不变\n4) 优化段落过渡"
        
        # 调用Qwen优化
        OPTIMIZED_CONTENT=$(echo "$PROMPT" | qwen 2>/dev/null || echo "$current_content")
        
        if [ "$OPTIMIZED_CONTENT" != "$current_content" ]; then
            # 备份原文件
            cp "$chapter_file" "${chapter_file}.context_bak"
            # 写入优化后的内容
            echo "$OPTIMIZED_CONTENT" > "$chapter_file"
            echo "  ✅ $chapter_name 上下文已优化"
        else
            echo "  ℹ️  $chapter_name 无需优化或优化失败"
        fi
    done
}

# 散文增强
prose_enhancer() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "✨ 散文增强: $(basename "$PROJECT_PATH")"
    echo ""
    
    # 检查是否有Qwen CLI可用
    if ! command -v qwen &> /dev/null; then
        echo "⚠️  Qwen CLI不可用，无法执行散文增强"
        return
    fi
    
    for chapter_file in "$PROJECT_PATH/chapters/"*.md; do
        if [ -f "$chapter_file" ]; then
            chapter_name=$(basename "$chapter_file")
            echo "增强: $chapter_name"
            
            # 读取章节内容
            content=$(cat "$chapter_file")
            
            # 创建增强提示
            PROMPT="请增强以下文本的文学性，要求：1)增加形象化描述 2)使用修辞手法 3)优化语言节奏 4)增强画面感 5)提升感染力，但要保持原意。原文：$content"
            
            # 调用Qwen增强
            ENHANCED_CONTENT=$(echo "$PROMPT" | qwen 2>/dev/null || echo "$content")
            
            if [ "$ENHANCED_CONTENT" != "$content" ]; then
                # 备份原文件
                cp "$chapter_file" "${chapter_file}.prose_bak"
                # 写入增强后的内容
                echo "$ENHANCED_CONTENT" > "$chapter_file"
                echo "  ✅ $chapter_name 已增强"
            else
                echo "  ℹ️  $chapter_name 无需增强或增强失败"
            fi
        fi
    done
}

# 主逻辑
COMMAND=$1
if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

shift  # 移除命令参数

case $COMMAND in
    "vocabulary-analysis")
        if [ $# -lt 1 ]; then
            echo "❌ 词汇分析命令需要提供: 项目路径"
            exit 1
        fi
        vocabulary_analysis "$1"
        ;;
    "word-frequency")
        if [ $# -lt 1 ]; then
            echo "❌ 词频统计命令需要提供: 项目路径"
            exit 1
        fi
        word_frequency "$1"
        ;;
    "synonym-replacer")
        if [ $# -lt 1 ]; then
            echo "❌ 同义词替换命令需要提供: 项目路径"
            exit 1
        fi
        synonym_replacer "$1"
        ;;
    "style-analyzer")
        if [ $# -lt 1 ]; then
            echo "❌ 风格分析命令需要提供: 项目路径"
            exit 1
        fi
        style_analyzer "$1"
        ;;
    "sentiment-check")
        if [ $# -lt 1 ]; then
            echo "❌ 情感分析命令需要提供: 项目路径"
            exit 1
        fi
        sentiment_check "$1"
        ;;
    "readability-improver")
        if [ $# -lt 1 ]; then
            echo "❌ 可读性改进命令需要提供: 项目路径"
            exit 1
        fi
        readability_improver "$1"
        ;;
    "generate-vocabulary")
        if [ $# -lt 1 ]; then
            echo "❌ 生成词汇表命令需要提供: 项目路径"
            exit 1
        fi
        generate_vocabulary "$1"
        ;;
    "export-lexicon")
        if [ $# -lt 1 ]; then
            echo "❌ 导出词典命令需要提供: 项目路径 [输出路径]"
            exit 1
        fi
        export_lexicon "$1" "$2"
        ;;
    "context-optimizer")
        if [ $# -lt 1 ]; then
            echo "❌ 上下文优化命令需要提供: 项目路径"
            exit 1
        fi
        context_optimizer "$1"
        ;;
    "prose-enhancer")
        if [ $# -lt 1 ]; then
            echo "❌ 散文增强命令需要提供: 项目路径"
            exit 1
        fi
        prose_enhancer "$1"
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