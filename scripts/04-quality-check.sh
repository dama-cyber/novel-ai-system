#!/bin/bash
# scripts/04-quality-check.sh - 质量检查

set -e

PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
    echo "用法: $0 <项目目录>"
    echo "例如: $0 \"./projects/我的玄幻小说\""
    exit 1
fi

echo "🔍 开始质量检查..."

# 检查章节文件数量
CHAPTERS_DIR="$PROJECT_DIR/chapters"
CHAPTER_COUNT=0
if [ -d "$CHAPTERS_DIR" ]; then
    CHAPTER_COUNT=$(ls "$CHAPTERS_DIR"/*.md | wc -l)
    echo "📊 检测到 $CHAPTER_COUNT 个章节文件"
else
    echo "⚠️  章节目录不存在: $CHAPTERS_DIR"
    CHAPTER_COUNT=0
fi

# 检查必要配置文件
REQUIRED_FILES=(
    "$PROJECT_DIR/settings/characters.json"
    "$PROJECT_DIR/settings/worldview.json"
    "$PROJECT_DIR/settings/power-system.json"
    "$PROJECT_DIR/settings/foreshadows.json"
    "$PROJECT_DIR/metadata.json"
)

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo "❌ 缺少以下必要配置文件:"
    printf '%s\n' "${MISSING_FILES[@]}"
else
    echo "✅ 所有必要配置文件均已存在"
fi

# 检查章节连贯性（使用Qwen）
if [ $CHAPTER_COUNT -gt 0 ]; then
    echo "🔗 检查章节连贯性..."
    CHARTER_LIST=$(ls "$CHAPTERS_DIR"/*.md | head -n 10)  # 检查前10章
    if [ -n "$CHARTER_LIST" ]; then
        ANALYSIS_PROMPT="你是一个专业的小说编辑。请分析以下章节列表的连贯性：
        - 剧情是否连贯
        - 角色是否一致
        - 世界观是否稳定
        - 是否有未回收的伏笔
        - 章节间的过渡是否自然

        请提供具体的改进建议和质量评分（1-100）。"
        echo "$ANALYSIS_PROMPT" | qwen > "$PROJECT_DIR/temp_chapter_coherence.txt"
    fi
fi

# 检查角色一致性
if [ -f "$PROJECT_DIR/settings/characters.json" ]; then
    echo "👥 检查角色一致性..."
    CHARACTERS_PROMPT="你是一个专业的小说编辑。请分析以下角色设定与章节内容的一致性：
    1. 检查角色外貌、性格是否在章节中保持一致
    2. 检查角色能力、背景是否与设定匹配
    3. 检查角色关系是否合理发展
    4. 指出不一致的地方并提供具体建议

    角色设定：$(cat "$PROJECT_DIR/settings/characters.json")

    请提供具体的质量评分（1-100）和改进建议。"
    echo "$CHARACTERS_PROMPT" | qwen > "$PROJECT_DIR/temp_character_consistency.txt"
fi

# 检查世界观一致性
if [ -f "$PROJECT_DIR/settings/worldview.json" ]; then
    echo "🌍 检查世界观一致性..."
    WORLDVIEW_PROMPT="你是一个专业的小说编辑。请分析以下世界观设定与章节内容的一致性：
    1. 检查地理、历史设定是否在章节中保持一致
    2. 检查文化、社会结构是否与设定匹配
    3. 检查魔法/科技体系是否在章节中正确应用
    4. 指出不一致的地方并提供具体建议

    世界观设定：$(cat "$PROJECT_DIR/settings/worldview.json")

    请提供具体的质量评分（1-100）和改进建议。"
    echo "$WORLDVIEW_PROMPT" | qwen > "$PROJECT_DIR/temp_worldview_consistency.txt"
fi

# 运行自定义检查脚本（如果存在）
CUSTOM_CHECK_PATH="$PROJECT_DIR/tools/custom-check.js"
if [ -f "$CUSTOM_CHECK_PATH" ]; then
    node "$CUSTOM_CHECK_PATH" "$PROJECT_DIR"
fi

# 统计字数
WORD_COUNT=0
if [ $CHAPTER_COUNT -gt 0 ]; then
    for chapter_file in "$CHAPTERS_DIR"/*.md; do
        if [ -f "$chapter_file" ]; then
            # 计算正文部分的字数
            content=$(sed -n '/## 正文/,/^---/p' "$chapter_file" | head -n -1 | tail -n +2)
            chapter_words=$(echo "$content" | wc -c)
            WORD_COUNT=$((WORD_COUNT + chapter_words))
        fi
    done
fi

# 生成详细质量报告
REPORT_FILE="$PROJECT_DIR/quality-report.md"
{
    echo "# 质量检查报告"
    echo ""
    echo "## 项目信息"
    echo "- 项目路径: $PROJECT_DIR"
    echo "- 章节数量: $CHAPTER_COUNT"
    echo "- 总字数: $WORD_COUNT"
    echo "- 检查时间: $(date -Iseconds)"
    echo ""
    echo "## 检查项"
    if [ $CHAPTER_COUNT -gt 0 ]; then
        echo "- [x] 章节完整性"
    else
        echo "- [ ] 章节完整性"
    fi
    if [ -f "$PROJECT_DIR/settings/characters.json" ]; then
        echo "- [x] 角色设定文件"
    else
        echo "- [ ] 角色设定文件"
    fi
    if [ -f "$PROJECT_DIR/settings/worldview.json" ]; then
        echo "- [x] 世界观设定文件"
    else
        echo "- [ ] 世界观设定文件"
    fi
    if [ -f "$PROJECT_DIR/settings/power-system.json" ]; then
        echo "- [x] 力量体系设定文件"
    else
        echo "- [ ] 力量体系设定文件"
    fi
    if [ -f "$PROJECT_DIR/metadata.json" ]; then
        echo "- [x] 项目元数据文件"
    else
        echo "- [ ] 项目元数据文件"
    fi
    echo ""
    echo "## AI分析结果"

    if [ -f "$PROJECT_DIR/temp_chapter_coherence.txt" ]; then
        echo "### 章节连贯性分析"
        echo "\`\`\`"
        cat "$PROJECT_DIR/temp_chapter_coherence.txt"
        echo "\`\`\`"
        echo ""
        rm "$PROJECT_DIR/temp_chapter_coherence.txt"  # 清理临时文件
    fi

    if [ -f "$PROJECT_DIR/temp_character_consistency.txt" ]; then
        echo "### 角色一致性分析"
        echo "\`\`\`"
        cat "$PROJECT_DIR/temp_character_consistency.txt"
        echo "\`\`\`"
        echo ""
        rm "$PROJECT_DIR/temp_character_consistency.txt"  # 清理临时文件
    fi

    if [ -f "$PROJECT_DIR/temp_worldview_consistency.txt" ]; then
        echo "### 世界观一致性分析"
        echo "\`\`\`"
        cat "$PROJECT_DIR/temp_worldview_consistency.txt"
        echo "\`\`\`"
        echo ""
        rm "$PROJECT_DIR/temp_worldview_consistency.txt"  # 清理临时文件
    fi

    echo "## 建议"
    echo "1. 根据AI分析结果进行相应修改"
    echo "2. 定期更新设定文件以保持一致性"
    echo "3. 在创作过程中注意伏笔的埋设与回收"
} > "$REPORT_FILE"

echo "✅ 质量检查完成！报告已生成: $REPORT_FILE"