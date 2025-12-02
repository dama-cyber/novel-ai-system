#!/bin/bash
# scripts/02-create-outline.sh - 生成大纲

set -e

PROJECT_DIR=$1
CHAPTER_COUNT=$2
GENRE=$3
PROTAGONIST=$4
CONFLICT=$5

if [ -z "$PROJECT_DIR" ] || [ -z "$CHAPTER_COUNT" ] || [ -z "$GENRE" ] || [ -z "$PROTAGONIST" ] || [ -z "$CONFLICT" ]; then
    echo "用法: $0 <项目目录> <章节数> <小说类型> <主角设定> <核心冲突>"
    echo "例如: $0 \"./projects/我的玄幻小说\" 100 \"玄幻\" \"林轩\" \"废材逆袭，挑战权威\""
    exit 1
fi

echo "📝 开始生成大纲（共${CHAPTER_COUNT}章）..."

# 加载提示词模板
PROMPT_TEMPLATE=$(cat << 'EOF'
你是一位资深网文大纲师，擅长{{GENRE}}类型小说。

要求：
1. 大纲需包含{{CHAPTER_COUNT}}章
2. 每章需有章节标题和简要情节描述
3. 确保剧情连贯性和逻辑性
4. 在章节间埋设伏笔并逐步回收
5. 主角需有成长弧线

结构要求：
- 开篇（1-10章）：设定介绍，主角背景，冲突引入
- 发展（11-{{MID_CHAPTER}}章）：情节推进，角色成长，冲突升级
- 高潮（{{MID_CHAPTER}}-${CHAPTER_COUNT}章）：最终对决，伏笔回收，结局

现在开始生成详细大纲...
EOF
)

# 计算中间章节号
MID_CHAPTER=$((CHAPTER_COUNT / 2 + CHAPTER_COUNT / 4))

# 替换模板中的变量并构建最终提示词
FINAL_PROMPT=$(echo "$PROMPT_TEMPLATE" | sed "s/{{GENRE}}/$GENRE/g" | sed "s/{{CHAPTER_COUNT}}/$CHAPTER_COUNT/g" | sed "s/{{MID_CHAPTER}}/$MID_CHAPTER/g")

# 构建项目信息部分
PROJECT_INFO="项目信息：
- 章节数：${CHAPTER_COUNT}章
- 主角：${PROTAGONIST}
- 核心冲突：${CONFLICT}

$FINAL_PROMPT

现在开始生成详细大纲..."

# 调用Qwen CLI生成大纲
echo "$PROJECT_INFO" | qwen > "${PROJECT_DIR}/outline.md"

echo "✅ 大纲生成完成: ${PROJECT_DIR}/outline.md"