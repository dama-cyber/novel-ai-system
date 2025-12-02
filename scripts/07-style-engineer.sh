#!/bin/bash
# scripts/07-style-engineer.sh - 文体工程师脚本

set -e

PROJECT_DIR=$1
TARGET_STYLE=$2
CHAPTER_START=$3
CHAPTER_END=$4

if [ -z "$PROJECT_DIR" ] || [ -z "$TARGET_STYLE" ] || [ -z "$CHAPTER_START" ] || [ -z "$CHAPTER_END" ]; then
    echo "用法: $0 <项目目录> <目标风格> <起始章节> <结束章节>"
    echo "例如: $0 \"./projects/我的玄幻小说\" \"轻松幽默\" 1 10"
    exit 1
fi

echo "🎨 开始文体工程任务（${TARGET_STYLE}风格，第${CHAPTER_START}章到第${CHAPTER_END}章）..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
OUTPUT_DIR="$PROJECT_DIR/style-engineering"
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

# 进行文体工程转换
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
        echo "正在转换第${i}章为${TARGET_STYLE}风格..."
        
        # 提取章节标题
        CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
        
        # 提取章节内容
        CHAPTER_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2")
        
        # 提取概要
        SUMMARY=$(sed -n '/## 概要/,/## 正文/p' "$CHAPTER_FILE" | head -n -1 | tail -n +2 | sed '/^[[:space:]]*$/d')
        
        # 构建文体工程提示词
        STYLE_PROMPT="你是一位专业的文体工程师和文学风格转换专家，擅长将文本转换为特定风格。

请将以下章节内容转换为${TARGET_STYLE}风格：

原章节信息：
- 章节：第${i}章
- 标题：${CHAPTER_TITLE}
- 概要：${SUMMARY}

原章节正文：
${CHAPTER_CONTENT}

要求：
1. 保持原有情节和角色行为不变
2. 仅改变表达方式、语言风格、修辞手法以符合${TARGET_STYLE}风格
3. 保持段落结构和字数大致相同
4. 保留关键人物名称和专业术语
5. 确保转换后的文本流畅自然

请输出转换后的完整章节内容，保持以下模板结构：
# 第${i}章 ${CHAPTER_TITLE}

## 概要

${SUMMARY}

## 正文

[转换后的正文内容]

---

**下一章预告**：[保留原预告或根据转换后内容调整]

**字数统计**：[保留原字数或更新字数统计]
"

        # 调用Qwen进行文体工程转换
        CONVERTED_CONTENT=$(echo "$STYLE_PROMPT" | qwen)
        
        if [ -n "$CONVERTED_CONTENT" ]; then
            # 生成新文件名（在标题后添加风格标识）
            NEW_TITLE="${CHAPTER_TITLE}-${TARGET_STYLE}"
            NEW_FILE="$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_${NEW_TITLE}.md"
            
            # 保存转换后的内容
            echo "$CONVERTED_CONTENT" > "$NEW_FILE"
            
            # 删除原始文件
            rm "$CHAPTER_FILE"
            
            echo "✅ 第${i}章文体工程完成"
        else
            echo "⚠️  第${i}章文体工程转换失败，保留原始文件"
        fi
    else
        echo "⚠️  第${i}章文件不存在"
    fi
done

# 生成样式转换报告 - 使用printf避免引号问题
REPORT_FILE="$OUTPUT_DIR/style-engineering-report.md"
printf '%s\n' "# 文体工程转换报告" '' \
"## 项目信息" \
"- 项目路径: $PROJECT_DIR" \
"- 转换风格: $TARGET_STYLE" \
"- 转换范围: 第${CHAPTER_START}章 到 第${CHAPTER_END}章" \
"- 转换时间: $(date -Iseconds)" \
"- 备份路径: $BACKUP_DIR" \
'' \
"## 转换详情" \
"- 已转换: $((CHAPTER_END - CHAPTER_START + 1)) 章" \
"- 备份原始文件至: $BACKUP_DIR" \
'' \
"## 注意事项" \
"1. 转换后的章节已重命名以包含风格标识" \
"2. 原始章节已备份至 $BACKUP_DIR" \
"3. 如需恢复原始版本，请从备份目录复制文件至 chapters 目录" > "$REPORT_FILE"

echo "✅ 文体工程任务完成！报告已生成: $REPORT_FILE"