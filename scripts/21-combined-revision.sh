#!/bin/bash
# scripts/21-combined-revision.sh - 拆书分析与换元仿写一体化脚本
# 结合06拆书和08修订功能，提供从分析到实现的完整流程

set -e

show_help() {
    echo "🔄 拆书分析与换元仿写一体化脚本"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  analyze  <项目路径> <起始章> <结束章>  拆书分析"
    echo "  swap     <项目路径> <起始章> <结束章> <新元素>  换元设计"
    echo "  rewrite  <项目路径> <起始章> <结束章> <新元素>  仿写实施"
    echo "  full     <项目路径> <起始章> <结束章> <新元素>  完整流程"
    echo "  merge    <项目路径> <起始章> <结束章> [分支]  合并版本"
    echo "  help                                  显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 analyze \"./projects/我的小说\" 1 10"
    echo "  $0 swap \"./projects/我的小说\" 1 10 \"加入神秘导师角色\""
    echo "  $0 full \"./projects/我的小说\" 1 10 \"加入神秘导师角色\""
}

# 拆书分析函数
perform_analysis() {
    local PROJECT_DIR=$1
    local CHAPTER_START=$2
    local CHAPTER_END=$3
    
    echo "🔍 开始拆书分析（第${CHAPTER_START}章到第${CHAPTER_END}章）..."
    
    local CHAPTERS_DIR="$PROJECT_DIR/chapters"
    local OUTPUT_DIR="$PROJECT_DIR/composite-revision-analysis"
    local ANALYSIS_DIR="$OUTPUT_DIR/analysis"
    
    # 创建输出目录
    mkdir -p "$ANALYSIS_DIR"
    
    # 用于汇总分析结果的文件
    local ANALYSIS_FILE="$ANALYSIS_DIR/composite-analysis.md"
    {
        echo "# 复合拆书分析报告"
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
            
            # 调用Qwen进行拆书分析
            ANALYSIS_OUTPUT="$ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
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
}

# 换元设计函数
perform_swap_design() {
    local PROJECT_DIR=$1
    local CHAPTER_START=$2
    local CHAPTER_END=$3
    local NEW_ELEMENT=$4
    
    echo "🔄 开始换元设计（第${CHAPTER_START}章到第${CHAPTER_END}章，添加:${NEW_ELEMENT}）..."
    
    local CHAPTERS_DIR="$PROJECT_DIR/chapters"
    local OUTPUT_DIR="$PROJECT_DIR/composite-revision-analysis"
    local ANALYSIS_DIR="$OUTPUT_DIR/analysis"
    local SWAP_DIR="$OUTPUT_DIR/swap-design"
    
    # 创建输出目录
    mkdir -p "$SWAP_DIR"
    
    # 换元设计汇总报告
    local SWAP_REPORT="$SWAP_DIR/swap-design-report.md"
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
    
    for ((i=CHAPTER_START; i<=CHAPTER_END; i++)); do
        FORMATTED_CHAPTER=$(printf "%03d" $i)
        
        ANALYSIS_FILE="$ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
        CHAPTER_FILE=""
        for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
            if [ -f "$file" ]; then
                CHAPTER_FILE="$file"
                break
            fi
        done
        
        if [ -f "$ANALYSIS_FILE" ] && [ -n "$CHAPTER_FILE" ]; then
            echo "  正在设计第${i}章的换元方案..."
            
            # 提取章节内容
            CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
            CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
            SUMMARY=$(sed -n '/## 概要/,/## 正文/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2 | sed '/^[[:space:]]*$/d')
            
            # 获取拆书分析结果
            ANALYSIS_CONTENT=$(cat "$ANALYSIS_FILE")
            
            # 构建换元设计提示词
            SWAP_PROMPT="你是一个专业的换元设计师和故事重构专家。

基于以下拆书分析和原章节内容，设计如何在章节中融入新元素：${NEW_ELEMENT}

原章节信息：
- 章节：第${i}章
- 标题：${CHAPTER_TITLE}
- 概要：${SUMMARY}

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

请提供详细的换元设计方案。"
            
            # 调用Qwen进行换元设计
            SWAP_FILE="$SWAP_DIR/chapter_${FORMATTED_CHAPTER}_swap-plan.md"
            echo "$SWAP_PROMPT" | qwen > "$SWAP_FILE"
            
            # 追加到汇总报告
            {
                echo "### 第${i}章：${CHAPTER_TITLE}"
                echo ""
                echo "<details>"
                echo "<summary>点击查看换元设计方案</summary>"
                echo ""
                cat "$SWAP_FILE"
                echo ""
                echo "</details>"
                echo ""
            } >> "$SWAP_REPORT"
            
            echo "  ✅ 第${i}章换元设计完成"
        fi
    done
    
    echo "✅ 换元设计完成！方案报告已生成: $SWAP_REPORT"
}

# 仿写实施函数
perform_rewrite() {
    local PROJECT_DIR=$1
    local CHAPTER_START=$2
    local CHAPTER_END=$3
    local NEW_ELEMENT=$4
    
    echo "✍️  开始仿写实施（第${CHAPTER_START}章到第${CHAPTER_END}章，添加:${NEW_ELEMENT}）..."
    
    local CHAPTERS_DIR="$PROJECT_DIR/chapters"
    local OUTPUT_DIR="$PROJECT_DIR/composite-revision-analysis"
    local ANALYSIS_DIR="$OUTPUT_DIR/analysis"
    local SWAP_DIR="$OUTPUT_DIR/swap-design"
    local REWRITE_DIR="$OUTPUT_DIR/rewrites"
    local BACKUP_DIR="$OUTPUT_DIR/backup-$(date +%Y%m%d_%H%M%S)"
    
    # 创建输出和备份目录
    mkdir -p "$REWRITE_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # 备份原始章节
    echo "🔄 正在备份原始章节..."
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
            cp "$CHAPTER_FILE" "$BACKUP_DIR/"
        fi
    done
    
    # 仿写实施
    for ((i=CHAPTER_START; i<=CHAPTER_END; i++)); do
        FORMATTED_CHAPTER=$(printf "%03d" $i)
        
        ANALYSIS_FILE="$ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
        SWAP_FILE="$SWAP_DIR/chapter_${FORMATTED_CHAPTER}_swap-plan.md"
        CHAPTER_FILE=""
        for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
            if [ -f "$file" ]; then
                CHAPTER_FILE="$file"
                break
            fi
        done
        
        if [ -f "$ANALYSIS_FILE" ] && [ -f "$SWAP_FILE" ] && [ -n "$CHAPTER_FILE" ]; then
            echo "  正在仿写第${i}章..."
            
            # 提取原章节各部分
            CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
            CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
            SUMMARY=$(sed -n '/## 概要/,/## 正文/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2 | sed '/^[[:space:]]*$/d')
            
            NEXT_CHAPTER_TEASER=$(grep -o "下一章预告.*" "$CHAPTER_FILE" | head -n 1)
            if [ -z "$NEXT_CHAPTER_TEASER" ]; then
                NEXT_CHAPTER_TEASER="下一章预告待定"
            fi
            
            WORD_COUNT=$(grep -o "字数统计.*" "$CHAPTER_FILE" | head -n 1)
            if [ -z "$WORD_COUNT" ]; then
                WORD_COUNT="字数统计待定"
            fi
            
            # 获取分析和换元方案
            ANALYSIS_CONTENT=$(cat "$ANALYSIS_FILE")
            SWAP_PLAN=$(cat "$SWAP_FILE")
            
            # 构建仿写提示词
            REWRITE_PROMPT="你是一个专业的仿写专家和故事重构大师。

请根据拆书分析、换元方案和原内容，重写章节内容融入新元素：${NEW_ELEMENT}

要求：
1. 保留原章节核心情节和结构
2. 自然融入新元素：${NEW_ELEMENT}
3. 参考换元方案中的具体建议
4. 保持原作的语言风格和节奏
5. 适当调整相关情节以保持逻辑一致性
6. 确保内容流畅自然

原始章节信息：
- 章节：第${i}章
- 标题：${CHAPTER_TITLE}
- 概要：${SUMMARY}

原始正文：
${CHAPTER_CONTENT}

拆书分析：
${ANALYSIS_CONTENT}

换元方案：
${SWAP_PLAN}

请按以下模板输出重写后的内容：

# 第${i}章 ${CHAPTER_TITLE}

## 概要

[保持或根据新元素调整后的概要]

## 正文

[重写后的正文内容，融入了${NEW_ELEMENT}]

---

**下一章预告**：${NEXT_CHAPTER_TEASER}

**字数统计**：${WORD_COUNT}

注意保持章节的完整性。"
            
            # 调用Qwen进行仿写
            REWRITTEN_CONTENT=$(echo "$REWRITE_PROMPT" | qwen)
            
            if [ -n "$REWRITTEN_CONTENT" ]; then
                # 生成新文件名（在标题后添加修订标识）
                NEW_TITLE="${CHAPTER_TITLE}-修订版"
                NEW_FILE="$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_${NEW_TITLE}.md"
                
                # 保存重写后的内容
                echo "$REWRITTEN_CONTENT" > "$NEW_FILE"
                
                # 删除原始文件
                rm "$CHAPTER_FILE"
                
                # 同时保存重写版本到单独文件
                echo "$REWRITTEN_CONTENT" > "$REWRITE_DIR/chapter_${FORMATTED_CHAPTER}_revised.md"
                
                echo "  ✅ 第${i}章仿写完成"
            else
                echo "  ⚠️  第${i}章仿写失败，保留原始文件"
            fi
        fi
    done
    
    echo "✅ 仿写实施完成！"
}

# 合并版本函数
perform_merge() {
    local PROJECT_DIR=$1
    local CHAPTER_START=$2
    local CHAPTER_END=$3
    local BRANCH=${4:-"main"}  # 默认main分支，可以指定其他分支
    
    echo "🔗 开始合井版本（第${CHAPTER_START}章到第${CHAPTER_END}章）..."
    
    local CHAPTERS_DIR="$PROJECT_DIR/chapters"
    local OUTPUT_DIR="$PROJECT_DIR/composite-revision-analysis"
    local MERGE_DIR="$OUTPUT_DIR/merge-$(date +%Y%m%d_%H%M%S)"
    
    mkdir -p "$MERGE_DIR"
    
    # 创建合并报告
    MERGE_REPORT="$MERGE_DIR/merge-report.md"
    {
        echo "# 版本合并报告"
        echo ""
        echo "## 项目信息"
        echo "- 项目路径: $PROJECT_DIR"
        echo "- 合并范围: 第${CHAPTER_START}章 到 第${CHAPTER_END}章"
        echo "- 合并分支: $BRANCH"
        echo "- 合并时间: $(date -Iseconds)"
        echo ""
        echo "## 合并详情"
        echo ""
    } > "$MERGE_REPORT"
    
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
            echo "  处理第${i}章合并..."
            
            # 提取章节内容
            CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
            CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
            
            # 构建合并策略提示词
            MERGE_PROMPT="你是一个专业的版本合并专家。

以下是第${i}章的当前版本内容：

章节标题：${CHAPTER_TITLE}
章节内容：
${CHAPTER_CONTENT}

请考虑以下因素进行版本合并策略制定：
1. 如何处理不同版本间的冲突
2. 如何保持故事连贯性
3. 如何保留有价值的修改
4. 如何保持整体风格统一

请为章节合并提供策略建议。"
            
            # 获取合并策略
            MERGE_STRATEGY="$MERGE_DIR/chapter_${FORMATTED_CHAPTER}_merge-strategy.md"
            echo "$MERGE_PROMPT" | qwen > "$MERGE_STRATEGY"
            
            {
                echo "### 第${i}章：${CHAPTER_TITLE}"
                echo ""
                echo "<details>"
                echo "<summary>点击查看合并策略</summary>"
                echo ""
                cat "$MERGE_STRATEGY"
                echo ""
                echo "</details>"
                echo ""
            } >> "$MERGE_REPORT"
            
            echo "  ✅ 第${i}章合并策略制定完成"
        fi
    done
    
    echo "✅ 版本合并策略制定完成！报告已生成: $MERGE_REPORT"
}

# 完整流程函数
perform_full_process() {
    local PROJECT_DIR=$1
    local CHAPTER_START=$2
    local CHAPTER_END=$3
    local NEW_ELEMENT=$4
    
    echo "🚀 开始完整拆书-换元-仿写流程..."
    
    # 执行分析
    perform_analysis "$PROJECT_DIR" "$CHAPTER_START" "$CHAPTER_END"
    
    # 执行换元设计
    perform_swap_design "$PROJECT_DIR" "$CHAPTER_START" "$CHAPTER_END" "$NEW_ELEMENT"
    
    # 执行仿写实施
    perform_rewrite "$PROJECT_DIR" "$CHAPTER_START" "$CHAPTER_END" "$NEW_ELEMENT"
    
    # 生成最终报告
    local OUTPUT_DIR="$PROJECT_DIR/composite-revision-analysis"
    local FINAL_REPORT="$OUTPUT_DIR/final-composite-report.md"
    {
        echo "# 拆书-换元-仿写完整流程报告"
        echo ""
        echo "## 项目信息"
        echo "- 项目路径: $PROJECT_DIR"
        echo "- 处理范围: 第${CHAPTER_START}章 到 第${CHAPTER_END}章"
        echo "- 新元素: $NEW_ELEMENT"
        echo "- 完成时间: $(date -Iseconds)"
        echo ""
        echo "## 流程详情"
        echo "- 拆书分析: 已完成"
        echo "- 换元设计: 已完成"
        echo "- 仿写实施: 已完成"
        echo ""
        echo "## 结果概览"
        echo "- 原始章节已备份至: $OUTPUT_DIR/backup-YYYYMMDD_HHMMSS/"
        echo "- 拆书分析报告: $OUTPUT_DIR/analysis/composite-analysis.md"
        echo "- 换元设计方案: $OUTPUT_DIR/swap-design/swap-design-report.md"
        echo "- 重写章节文件: $OUTPUT_DIR/rewrites/"
        echo ""
        echo "## 注意事项"
        echo "- 修订后的章节已在项目chapters目录中更新"
        echo "- 原始文件已备份，如需恢复可在备份目录找到"
        echo "- 本次流程成功融入新元素: $NEW_ELEMENT"
        echo "- 建议后续进行整体一致性检查"
    } > "$FINAL_REPORT"
    
    echo "✅ 完整流程完成！最终报告已生成: $FINAL_REPORT"
}

# 主逻辑
COMMAND=$1
if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

shift  # 移除命令参数

case $COMMAND in
    "analyze")
        if [ $# -lt 3 ]; then
            echo "❌ analyze命令需要提供: 项目路径 起始章 结束章"
            exit 1
        fi
        perform_analysis "$1" "$2" "$3"
        ;;
    "swap")
        if [ $# -lt 4 ]; then
            echo "❌ swap命令需要提供: 项目路径 起始章 结束章 新元素"
            exit 1
        fi
        perform_swap_design "$1" "$2" "$3" "$4"
        ;;
    "rewrite")
        if [ $# -lt 4 ]; then
            echo "❌ rewrite命令需要提供: 项目路径 起始章 结束章 新元素"
            exit 1
        fi
        perform_rewrite "$1" "$2" "$3" "$4"
        ;;
    "full")
        if [ $# -lt 4 ]; then
            echo "❌ full命令需要提供: 项目路径 起始章 结束章 新元素"
            exit 1
        fi
        perform_full_process "$1" "$2" "$3" "$4"
        ;;
    "merge")
        if [ $# -lt 3 ]; then
            echo "❌ merge命令需要提供: 项目路径 起始章 结束章 [分支名]"
            exit 1
        fi
        perform_merge "$1" "$2" "$3" "$4"
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