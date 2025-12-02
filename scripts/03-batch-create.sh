#!/bin/bash
# scripts/03-batch-create.sh - 批量创作章节

set -e

PROJECT_DIR=$1
START_CHAPTER=$2
END_CHAPTER=$3

if [ -z "$PROJECT_DIR" ] || [ -z "$START_CHAPTER" ] || [ -z "$END_CHAPTER" ]; then
    echo "用法: $0 <项目目录> <起始章> <结束章>"
    echo "例如: $0 \"./projects/我的玄幻小说\" 1 100"
    exit 1
fi

echo "📚 开始批量创作章节（第${START_CHAPTER}章到第${END_CHAPTER}章）..."

# 设置项目路径
CHAPTERS_DIR="$PROJECT_DIR/chapters"
SETTINGS_DIR="$PROJECT_DIR/settings"
SUMMARIES_DIR="$PROJECT_DIR/summaries"

# 从大纲中提取章节信息
OUTLINE_FILE="$PROJECT_DIR/outline.md"

for ((i=START_CHAPTER; i<=END_CHAPTER; i++)); do
    # 格式化章节号（补零）
    FORMATTED_CHAPTER=$(printf "%03d" $i)

    echo "正在创作第${i}章..."

    # 读取章节标题和描述（从大纲中）
    CHAPTER_TITLE="第${i}章"
    CHAPTER_DESC="章节内容"

    # 提取章节内容
    if [ -f "$OUTLINE_FILE" ]; then
        # 尝试从大纲中提取对应章节的信息
        # 匹配 #### 第X章 格式的标题
        CHAPTER_LINE=$(grep -E "^#### 第${i}章" "$OUTLINE_FILE")
        if [ -n "$CHAPTER_LINE" ]; then
            # 提取章节标题部分
            # 匹配从 #### 第X章 开始直到 ( 开始的部分
            extracted_title=$(echo "$CHAPTER_LINE" | sed -n "s/^#### 第${i}章 \([^ (]*\).*/\1/p")
            if [ -z "$extracted_title" ]; then
                # 如果上面的模式未匹配到，尝试匹配直到括号的部分
                extracted_title=$(echo "$CHAPTER_LINE" | sed -n "s/^#### 第${i}章 \([^)]*\).*/\1/p" | sed 's/ (.*//')
            fi

            if [ -n "$extracted_title" ]; then
                # 进一步清理标题
                extracted_title=$(echo "$extracted_title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '\r\n')
                if [ -n "$extracted_title" ]; then
                    # 避免标题中包含特殊字符导致后续sed命令错误
                    CHAPTER_TITLE="$extracted_title"
                else
                    CHAPTER_TITLE="第${i}章"
                fi
            else
                CHAPTER_TITLE="第${i}章"
            fi
        else
            CHAPTER_TITLE="第${i}章"
        fi
    fi

    # 从设定文件中读取信息
    if [ -f "$SETTINGS_DIR/characters.json" ]; then
        CHARACTERS=$(cat "$SETTINGS_DIR/characters.json")
    else
        CHARACTERS="{}"
    fi

    if [ -f "$SETTINGS_DIR/worldview.json" ]; then
        WORLDVIEW=$(cat "$SETTINGS_DIR/worldview.json")
    else
        WORLDVIEW="{}"
    fi

    if [ -f "$SETTINGS_DIR/power-system.json" ]; then
        POWER_SYSTEM=$(cat "$SETTINGS_DIR/power-system.json")
    else
        POWER_SYSTEM="{}"
    fi

    # 构建前情提要（如果章节>1）
    RECAP=""
    if [ $i -gt 1 ]; then
        PREV_CHAPTER=$((i-1))
        PREV_CHAPTER_FILE=""
        # 查找上一章的文件名
        for file in "$CHAPTERS_DIR/chapter_$(printf "%03d" $PREV_CHAPTER)"_*".md"; do
            if [ -f "$file" ]; then
                PREV_CHAPTER_FILE="$file"
                break
            fi
        done

        if [ -n "$PREV_CHAPTER_FILE" ]; then
            # 提取上一章的概要作为回顾
            SUMMARY_SECTION=$(sed -n '/## 概要/,/## 正文/p' "$PREV_CHAPTER_FILE" | head -n -1)
            if [ -n "$SUMMARY_SECTION" ]; then
                RECAP="$SUMMARY_SECTION"
            fi
        fi
    fi

    # 加载章节创作提示词模板
    PROMPT_TEMPLATE=$(cat << 'EOF'
# 角色设定
你是一位10年经验的{{GENRE}}类网文大神，代表作累计2000万字。

你的写作特点：
✅ 情节推进快速，3000字必有2个爽点
✅ 人物性格鲜明，对话生动有趣
✅ 擅长伏笔和反转
✅ 语言简练，杜绝水文
❌ 不用AI常用套话（"然而"、"显然"、"毫无疑问"）
❌ 不写教科书式说明

---

# 小说设定

## 核心角色
{{CHARACTER_CARDS}}

## 世界观
{{WORLDVIEW}}

## 力量体系
{{POWER_SYSTEM}}

---

# 前情回顾
{{RECAP}}

---

# 创作要求

## 本章信息
- 章节号：第{{CHAPTER_NUM}}章
- 章节标题：{{CHAPTER_TITLE}}
- 目标字数：3000字

现在开始创作...
EOF
    )

    # 使用更安全的方式替换模板中的变量
    PROMPT="$PROMPT_TEMPLATE"
    # 使用临时分隔符避免特殊字符问题
    PROMPT=$(echo "$PROMPT" | sed "s|{{GENRE}}|玄幻|g")
    # 为JSON字符串转义特殊字符
    ESCAPED_CHARACTERS=$(printf '%s\n' "$CHARACTERS" | sed 's/"/\\"/g' | sed 's/\r//g')
    ESCAPED_WORLDVIEW=$(printf '%s\n' "$WORLDVIEW" | sed 's/"/\\"/g' | sed 's/\r//g')
    ESCAPED_POWER_SYSTEM=$(printf '%s\n' "$POWER_SYSTEM" | sed 's/"/\\"/g' | sed 's/\r//g')
    # 使用更安全的替换方法处理可能包含特殊字符的变量
    PROMPT=$(printf '%s\n' "$PROMPT" | sed "s|{{CHARACTER_CARDS}}|${ESCAPED_CHARACTERS}|g")
    PROMPT=$(printf '%s\n' "$PROMPT" | sed "s|{{WORLDVIEW}}|${ESCAPED_WORLDVIEW}|g")
    PROMPT=$(printf '%s\n' "$PROMPT" | sed "s|{{POWER_SYSTEM}}|${ESCAPED_POWER_SYSTEM}|g")
    # 使用临时标记替换可能包含特殊字符的内容
    TEMP_RECAP=$(echo "$RECAP" | sed 's/|/\\VERTBAR/g' | sed 's/\\/\\\\/g' | sed 's/\$/\\DOLLAR/g' | sed 's/&/\\AMPERSAND/g')
    PROMPT=$(printf '%s\n' "$PROMPT" | sed "s|{{RECAP}}|${TEMP_RECAP}|g" | sed 's/\\VERTBAR/|/g' | sed 's/\\DOLLAR/\$/g' | sed 's/\\AMPERSAND/&/g')
    PROMPT=$(printf '%s\n' "$PROMPT" | sed "s|{{CHAPTER_NUM}}|$i|g")
    # 为章节标题转义特殊字符
    ESCAPED_CHAPTER_TITLE=$(printf '%s\n' "$CHAPTER_TITLE" | sed 's/|/\\VERTBAR/g' | sed 's/\\/\\\\/g' | sed 's/\$/\\DOLLAR/g' | sed 's/&/\\AMPERSAND/g')
    PROMPT=$(printf '%s\n' "$PROMPT" | sed "s|{{CHAPTER_TITLE}}|${ESCAPED_CHAPTER_TITLE}|g" | sed 's/\\VERTBAR/|/g' | sed 's/\\DOLLAR/\$/g' | sed 's/\\AMPERSAND/&/g')

    # 使用Qwen创建章节内容
    echo "$PROMPT" | qwen > "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_draft.md"

    # 重命名文件以包含章节标题（转义特殊字符）
    safe_title=$(echo "$CHAPTER_TITLE" | sed 's/[/\\:*?"<>|]/_/g' | tr -d '\r\n')
    mv "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_draft.md" "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_${safe_title}.md"

    echo "✅ 第${i}章创作完成"

    # 每5章主动压缩会话
    if [ $((i % 5)) -eq 0 ]; then
        echo "🔧 每5章自动压缩会话历史..."
        qwen /compress
    fi
done

echo "✅ 所有章节创作完成！"