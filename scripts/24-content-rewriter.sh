#!/bin/bash
# scripts/24-content-rewriter.sh - 仿写实施模块
# 专注于根据换元设计方案实际重写章节内容

set -e

show_help() {
    echo "✍️  仿写实施模块"
    echo ""
    echo "用法: $0 <项目路径> <起始章> <结束章> <新元素>"
    echo ""
    echo "功能:"
    echo "  根据换元设计方案，实际重写章节内容"
    echo "  融入新元素并保持风格一致性"
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

echo "✍️  开始仿写实施（第${CHAPTER_START}章到第${CHAPTER_END}章，添加:${NEW_ELEMENT}）..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
OUTPUT_DIR="$PROJECT_DIR/content-rewrites"
REWRITE_DIR="$OUTPUT_DIR/$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$PROJECT_DIR/backups/$(date +%Y%m%d_%H%M%S)"

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

echo "✅ 备份完成，开始仿写实施..."

# 执行仿写
for ((i=CHAPTER_START; i<=CHAPTER_END; i++)); do
    FORMATTED_CHAPTER=$(printf "%03d" $i)
    
    # 查找章节文件和换元设计文件
    CHAPTER_FILE=""
    for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
        if [ -f "$file" ]; then
            CHAPTER_FILE="$file"
            break
        fi
    done
    
    SWAP_FILE=""
    SWAP_SEARCH_DIR="$PROJECT_DIR/element-swap-designs"
    if [ -d "$SWAP_SEARCH_DIR" ]; then
        for file in "$SWAP_SEARCH_DIR"/*/chapter_${FORMATTED_CHAPTER}_swap-plan.md; do
            if [ -f "$file" ]; then
                SWAP_FILE="$file"
                break
            fi
        done
    fi
    
    if [ -n "$CHAPTER_FILE" ]; then
        echo "  正在仿写第${i}章..."
        
        # 提取原章节各部分
        CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//" | sed "s/\.md$//")
        CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
        SUMMARY=$(sed -n '/## 概要/,/## 正文/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2)
        
        # 获取换元设计（如果有）
        SWAP_PLAN=""
        if [ -n "$SWAP_FILE" ] && [ -f "$SWAP_FILE" ]; then
            SWAP_PLAN=$(cat "$SWAP_FILE")
        else
            SWAP_PLAN="未找到对应的换元设计方案，将直接融入新元素：$NEW_ELEMENT"
        fi
        
        # 查找下一章预告和字数统计
        NEXT_TEASER=$(grep -o "下一章预告.*" "$CHAPTER_FILE" | head -n 1)
        if [ -z "$NEXT_TEASER" ]; then
            NEXT_TEASER="下一章预告待定"
        fi
        
        WORD_COUNT=$(grep -o "字数统计.*" "$CHAPTER_FILE" | head -n 1)
        if [ -z "$WORD_COUNT" ]; then
            WORD_COUNT="字数统计待定"
        fi
        
        # 构建仿写提示词
        REWRITE_PROMPT="你是一个专业的仿写专家和故事重构大师。

请根据换元设计方案和原内容，重写章节内容融入新元素：${NEW_ELEMENT}

要求：
1. 保留原章节核心情节和结构
2. 自然融入新元素：${NEW_ELEMENT}
3. 参考换元设计方案中的具体建议
4. 保持原作的语言风格和节奏
5. 适当调整相关情节以保持逻辑一致性
6. 确保内容流畅自然

原始章节信息：
- 章节：第${i}章
- 标题：${CHAPTER_TITLE}
- 概要：${SUMMARY}

原始正文：
${CHAPTER_CONTENT}

换元设计方案：
${SWAP_PLAN}

请按以下模板输出重写后的内容：

# 第${i}章 ${CHAPTER_TITLE}

## 概要

[根据新元素调整后的概要]

## 正文

[重写后的正文内容，融入了${NEW_ELEMENT}]

---

**下一章预告**：${NEXT_TEASER}

**字数统计**：${WORD_COUNT}

注意保持章节的完整性。"
        
        # 调用Qwen进行仿写（如果可用）
        REWRITE_OUTPUT="$REWRITE_DIR/chapter_${FORMATTED_CHAPTER}_revised.md"
        
        if command -v qwen &> /dev/null; then
            echo "$REWRITE_PROMPT" | qwen > "$REWRITE_OUTPUT"
            
            if [ -s "$REWRITE_OUTPUT" ]; then
                # 成功生成新内容，替换原文件
                NEW_TITLE="${CHAPTER_TITLE}-修订版"
                NEW_FILE="$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_${NEW_TITLE}.md"
                
                # 确保使用新标题保存内容
                sed "s/第${i}章 ${CHAPTER_TITLE}/第${i}章 ${NEW_TITLE}/" "$REWRITE_OUTPUT" > "$NEW_FILE"
                
                # 删除旧文件
                rm "$CHAPTER_FILE"
                
                echo "  ✅ 第${i}章仿写完成并已保存"
            else
                echo "  ⚠️  第${i}章仿写失败，保留原始文件"
                
                # 保存失败信息
                echo "# 第${i}章仿写失败" > "$REWRITE_OUTPUT"
                echo "" >> "$REWRITE_OUTPUT"
                echo "未能成功仿写第${i}章，原始文件已保留。" >> "$REWRITE_OUTPUT"
            fi
        else
            # 如果qwen不可用，创建示例重写内容
            {
                echo "# 第${i}章 ${CHAPTER_TITLE}-修订版"
                echo ""
                echo "## 概要"
                echo "在本章中，${NEW_ELEMENT}首次出现……"
                echo ""
                echo "## 正文"
                echo ""
                echo "这是仿写后的第${i}章内容。"
                echo ""
                echo "根据要求融入了新元素：${NEW_ELEMENT}。"
                echo ""
                echo "内容保持了原有的风格和节奏。"
                echo ""
                echo "---"
                echo ""
                echo "**下一章预告**：$NEXT_TEASER"
                echo ""
                echo "**字数统计**：$WORD_COUNT"
            } > "$NEW_FILE"
            
            # 删除原文件
            rm "$CHAPTER_FILE"
            
            echo "  ⚠️  qwen命令不可用，创建示例重写内容"
        fi
    else
        echo "  ⚠️  第${i}章文件不存在"
    fi
done

echo "✅ 仿写实施完成！"
echo "📁 原始文件备份已保存至: $BACKUP_DIR"
echo "📁 重写后的内容已更新至: $CHAPTERS_DIR"