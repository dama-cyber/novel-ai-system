#!/bin/bash
# scripts/08-revise-book.sh - 拆书-换元-仿写流程脚本

set -e

PROJECT_DIR=$1
CHAPTER_START=$2
CHAPTER_END=$3
NEW_ELEMENT=$4  # 新元素，如新角色、新设定、新情节等

if [ -z "$PROJECT_DIR" ] || [ -z "$CHAPTER_START" ] || [ -z "$CHAPTER_END" ] || [ -z "$NEW_ELEMENT" ]; then
    echo "用法: $0 <项目目录> <起始章节> <结束章节> <新元素描述>"
    echo "例如: $0 \"./projects/我的玄幻小说\" 1 10 \"加入一个神秘导师角色\""
    exit 1
fi

echo "🔄 开始拆书-换元-仿写流程（第${CHAPTER_START}章到第${CHAPTER_END}章，添加:${NEW_ELEMENT}）..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
OUTPUT_DIR="$PROJECT_DIR/revision-process"
BACKUP_DIR="$OUTPUT_DIR/backup-$(date +%Y%m%d_%H%M%S)"

# 创建输出和备份目录
mkdir -p "$OUTPUT_DIR"
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

# 1. 拆书阶段 - 详细分析章节
echo "🔍 阶段1: 拆书分析"
SPLIT_ANALYSIS_DIR="$OUTPUT_DIR/split-analysis"
mkdir -p "$SPLIT_ANALYSIS_DIR"

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
        echo "   正在分析第${i}章..."
        
        # 提取章节标题
        CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
        
        # 提取章节内容
        CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
        
        # 构建拆书分析提示词
        SPLIT_PROMPT="你是一个专业的拆书专家和小说分析员，擅长深入分析小说内容。

请对以下章节进行深度拆书分析：

章节信息：
- 章节：第${i}章
- 标题：${CHAPTER_TITLE}

章节正文：
${CHAPTER_CONTENT}

请按以下结构进行详细分析：

1. **结构分析**
   - 段落结构
   - 情节节点划分
   - 节奏安排

2. **内容分析**
   - 情节概述（关键事件、转折点）
   - 角色表现（行为、性格、关系变化）
   - 世界观展现（场景、设定、规则）

3. **技巧分析**
   - 写作技法（描写手法、对白技巧、情节推进技巧）
   - 语言特色（词汇选择、句式特点、语调风格）
   - 修辞运用（比喻、象征、对比等）

4. **伏笔与呼应**
   - 本章埋设的伏笔
   - 对前文伏笔的呼应
   - 与后续情节的联系

5. **情感与氛围**
   - 营造的情感氛围
   - 情感调动手段
   - 读者心理影响

6. **修改建议**
   - 基于${NEW_ELEMENT}的修改建议（在下一阶段使用）

请用markdown格式输出分析结果。"

        # 调用Qwen进行拆书分析
        ANALYSIS_FILE="$SPLIT_ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
        echo "$SPLIT_PROMPT" | qwen > "$ANALYSIS_FILE"
        
        echo "   ✅ 第${i}章拆书分析完成"
    fi
done

# 2. 换元阶段 - 基于分析添加新元素
echo "🔄 阶段2: 换元设计"
SWAP_ANALYSIS_DIR="$OUTPUT_DIR/swap-analysis"
mkdir -p "$SWAP_ANALYSIS_DIR"

for ((i=CHAPTER_START; i<=CHAPTER_END; i++)); do
    FORMATTED_CHAPTER=$(printf "%03d" $i)
    
    ANALYSIS_FILE="$SPLIT_ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
    CHAPTER_FILE=""
    for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
        if [ -f "$file" ]; then
            CHAPTER_FILE="$file"
            break
        fi
    done
    
    if [ -f "$ANALYSIS_FILE" ] && [ -n "$CHAPTER_FILE" ]; then
        echo "   正在设计第${i}章的换元方案..."
        
        # 提取章节内容
        CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
        CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2")
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
        SWAP_FILE="$SWAP_ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_swap-plan.md"
        echo "$SWAP_PROMPT" | qwen > "$SWAP_FILE"
        
        echo "   ✅ 第${i}章换元设计完成"
    fi
done

# 3. 仿写阶段 - 实施修改
echo "✍️  阶段3: 仿写实施"
for ((i=CHAPTER_START; i<=CHAPTER_END; i++)); do
    FORMATTED_CHAPTER=$(printf "%03d" $i)
    
    ANALYSIS_FILE="$SPLIT_ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_analysis.md"
    SWAP_FILE="$SWAP_ANALYSIS_DIR/chapter_${FORMATTED_CHAPTER}_swap-plan.md"
    CHAPTER_FILE=""
    for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
        if [ -f "$file" ]; then
            CHAPTER_FILE="$file"
            break
        fi
    done
    
    if [ -f "$ANALYSIS_FILE" ] && [ -f "$SWAP_FILE" ] && [ -n "$CHAPTER_FILE" ]; then
        echo "   正在仿写第${i}章..."
        
        # 提取原章节各部分
        CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
        CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2")
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
            
            echo "   ✅ 第${i}章仿写完成"
        else
            echo "   ⚠️  第${i}章仿写失败，保留原始文件"
        fi
    fi
done

# 生成修订流程报告 - 使用printf避免引号问题
REPORT_FILE="$OUTPUT_DIR/revision-report.md"
printf '%s\n' "# 拆书-换元-仿写流程报告" '' \
"## 项目信息" \
"- 项目路径: $PROJECT_DIR" \
"- 修订范围: 第${CHAPTER_START}章 到 第${CHAPTER_END}章" \
"- 新元素: $NEW_ELEMENT" \
"- 修订时间: $(date -Iseconds)" \
"- 备份路径: $BACKUP_DIR" \
'' \
"## 流程详情" \
"- 阶段1: 拆书分析 - 完成" \
"- 阶段2: 换元设计 - 完成" \
"- 阶段3: 仿写实施 - 完成" \
'' \
"## 统计信息" \
"- 修订章节数: $((CHAPTER_END - CHAPTER_START + 1))" \
"- 备份原始文件至: $BACKUP_DIR" \
'' \
"## 文件说明" \
"- 拆书分析: $SPLIT_ANALYSIS_DIR" \
"- 换元设计: $SWAP_ANALYSIS_DIR" \
"- 修订报告: $REPORT_FILE" \
'' \
"## 注意事项" \
"1. 重写后的章节已重命名以包含'修订版'标识" \
"2. 原始章节已备份至 $BACKUP_DIR" \
"3. 如需恢复原始版本，请从备份目录复制文件至 chapters 目录" \
"4. 本次修订已融入新元素: $NEW_ELEMENT" > "$REPORT_FILE"

echo "✅ 拆书-换元-仿写流程完成！报告已生成: $REPORT_FILE"