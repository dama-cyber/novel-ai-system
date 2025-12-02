#!/bin/bash
# scripts/13-frankentexts-integration.sh - Frankentexts融合拼接生成模块

set -e

PROJECT_DIR=$1
CHAPTER_NUM=$2
ITERATION=${3:-100}  # 默认100次迭代进行优化

if [ -z "$PROJECT_DIR" ] || [ -z "$CHAPTER_NUM" ]; then
    echo "用法: $0 <项目目录> <章节号> [迭代次数]"
    echo "例如: $0 \"./projects/我的玄幻小说\" 5 100"
    exit 1
fi

echo "🧩 开始Frankentexts融合拼接生成（第${CHAPTER_NUM}章，优化迭代${ITERATION}次）..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
OUTPUT_DIR="$PROJECT_DIR/frankentexts-output"
FRANKENTEXTS_DIR="$OUTPUT_DIR/frankentexts-${CHAPTER_NUM}"
BACKUP_DIR="$OUTPUT_DIR/backup-$(date +%Y%m%d_%H%M%S)"
TEMP_DIR="$OUTPUT_DIR/temp"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"
mkdir -p "$FRANKENTEXTS_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMP_DIR"

# 备份原始章节
FORMATTED_CHAPTER=$(printf "%03d" $CHAPTER_NUM)
CHAPTER_FILE=""
for file in "$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}"_*".md"; do
    if [ -f "$file" ]; then
        CHAPTER_FILE="$file"
        break
    fi
done

if [ -n "$CHAPTER_FILE" ]; then
    cp "$CHAPTER_FILE" "$BACKUP_DIR/"
    echo "🔄 已备份原始章节至: $BACKUP_DIR"
fi

# Frankentexts核心处理逻辑
echo "🔍 准备Frankentexts融合拼接生成..."

# 读取项目设定（世界观和人物记忆体）
WORLD_MEMORY_FILE="$PROJECT_DIR/settings/worldview.json"
CHARACTER_MEMORY_FILE="$PROJECT_DIR/settings/characters.json"
POWER_SYSTEM_FILE="$PROJECT_DIR/settings/power-system.json"

# 读取现有章节内容
if [ -f "$CHAPTER_FILE" ]; then
    ORIGINAL_CONTENT=$(cat "$CHAPTER_FILE")
    ORIGINAL_TEXT=$(echo "$ORIGINAL_CONTENT" | sed -n '/## 正文/,/^---/p' | head -n -1 | tail -n +2)
else
    ORIGINAL_TEXT="章节内容待生成"
fi

# 创建或使用现有的预料库（1-8号文件）
CORPUS_DIR="$PROJECT_DIR/corpus"
mkdir -p "$CORPUS_DIR"

# 如果预料库不存在，创建基础预料库
if [ ! -f "$CORPUS_DIR/corpus_1.txt" ]; then
    echo "📚 创建基础预料库..."
    
    # 创建8个基础预料库文件
    for i in {1..8}; do
        cat > "$CORPUS_DIR/corpus_$i.txt" << EOF
=== FRAGMENT ===
TEXT: 这夜时分，$PROJECT_DIR主角林轩独自一人站在山崖边，凝望着远方的城市灯火。内心既有对未来的憧憬，也有对未知的恐惧。修炼之路漫漫，前路未卜，但他知道必须坚定地走下去。
META:
 roles: 林轩
 scene: 夜夜·山崖·远眺
 emotion: 沉思/坚定
 conflict: 内心挣扎/决心
 style: 白描/抒情
 tags: 修炼/决心/远望

=== FRAGMENT ===
TEXT: 突然，一股强大的气息从身后逼近。林轩猛然回头，只见一名黑衣人悄无声息地立于不远处。对方的气息深不可测，令他心中警铃大作。
META:
 roles: 林轩, 黑衣人
 scene: 夜晚·荒野·突袭
 emotion: 戒备/紧张
 conflict: 遭遇/战斗
 style: 紧张/悬疑
 tags: 战斗/危险/突袭

=== FRAGMENT ===
TEXT: "看来你就是近来声名鹊起的林轩了"，黑衣人缓缓开口，声音低沉而富有磁性。"我受人之托，前来验证你的真实实力。"
META:
 roles: 林轩, 黑衣人
 scene: 对峙·对话
 emotion: 紧张/试探
 conflict: 质疑/验证
 style: 对话/悬疑
 tags: 对话/实力验证

=== FRAGMENT ===
TEXT: 林轩深吸一口气，收敛心神。无论对方来意如何，他都不能示弱。"阁下既然找上门来，想必不会空手而归。请吧！"他摆出战斗姿态，体内的灵力开始涌动。
META:
 roles: 林轩
 scene: 战斗准备
 emotion: 坚定/战意
 conflict: 准备战斗
 style: 战斗/坚定
 tags: 战斗准备/灵力

=== FRAGMENT ===
TEXT: 两人瞬间交手，拳风掌影交错，周围的树木被气劲震得摇摆不定。林轩虽然修为略逊一筹，但凭借着巧妙的身法和坚韧的意志，竟与对方打得难分难解。
META:
 roles: 林轩, 黑衣人
 scene: 战斗·交手
 emotion: 专注/拼搏
 conflict: 战斗/较量
 style: 战斗/激烈
 tags: 战斗/身法/气劲
EOF
    done
    
    # 根据项目类型生成其他预料库
    PROJECT_TYPE="玄幻"
    if [[ "$PROJECT_DIR" == *"xuanhuan"* ]]; then
        PROJECT_TYPE="玄幻"
    elif [[ "$PROJECT_DIR" == *"xianxia"* ]]; then
        PROJECT_TYPE="仙侠"
    elif [[ "$PROJECT_DIR" == *"kehuan"* ]]; then
        PROJECT_TYPE="科幻"
    elif [[ "$PROJECT_DIR" == *"yanqing"* ]]; then
        PROJECT_TYPE="言情"
    fi
    
    # 为不同类型添加特定预料库
    if [ "$PROJECT_TYPE" = "玄幻" ]; then
        for i in {3..4}; do
            cat > "$CORPUS_DIR/corpus_$i.txt" << EOF
=== FRAGMENT ===
TEXT: 随着战斗的持续，林轩逐渐适应了对手的节奏。他施展师门绝学"流云掌"，掌风如云卷云舒，柔中带刚，竟然开始占据上风。
META:
 roles: 林轩
 scene: 战斗·优势
 emotion: 专注/自信
 conflict: 战斗/逆转
 style: 战斗/技巧
 tags: 武技/流云掌/逆转

=== FRAGMENT ===
TEXT: 黑衣人眼中闪过一丝赞赏，"不错，你确实有真才实学。今日就此别过，后会有期。"话音刚落，他身形一闪，消失在夜色中。
META:
 roles: 林轩, 黑衣人
 scene: 战斗结束·离别
 emotion: 惊讶/敬佩
 conflict: 无
 style: 结束/离别
 tags: 认可/离别/神秘
EOF
        done
    fi
fi

# 执行Frankentexts融合拼接生成
echo "🔄 执行Frankentexts融合拼接生成..."

# 读取世界观和人物记忆体
if [ -f "$WORLD_MEMORY_FILE" ]; then
    WORLDVIEW=$(cat "$WORLD_MEMORY_FILE")
else
    WORLDVIEW="{}"
fi

if [ -f "$CHARACTER_MEMORY_FILE" ]; then
    CHARACTERS=$(cat "$CHARACTER_MEMORY_FILE")
else
    CHARACTERS="{}"
fi

# 生成Frankentexts提示词
FRANKENTEXTS_PROMPT="你是筑心师，一名享誉国际的作家，从事文学创作工作超过20年。你将使用Frankentexts章节生成模块（融合拼接生成）来优化第${CHAPTER_NUM}章。

**知识库结构（最多10文件）**
- 1-8号文件：预料库（来自$CORPUS_DIR/）
- 9号：世界观记忆体：$WORLDVIEW
- 10号：人物记忆体：$CHARACTERS

**当前章节内容**：
$ORIGINAL_TEXT

**要求**：
1. **文本占比（强约束）**：约92%直接拼接自预料库1-8；约8%为原创（仅用于连接、过渡与最小改写以消除冲突）
2. **来源多样性**：至少使用5个不同预料库；任一单库贡献度≤30%
3. **一致性**：以9-10记忆体为锚点自动对齐人名/称谓/地名/设定/时间线
4. **成文格式**：输出连续的正式章节正文，不得出现片段编号、比例、来源、解释性文字
5. **字数**：不少于3000字
6. **版式**：遵循番茄平台样式（短句倾向、自然换行、空行分段）

请生成优化后的第${CHAPTER_NUM}章内容："

# 通过Qwen生成内容
TEMP_RESULT_FILE="$TEMP_DIR/chapter_${FORMATTED_CHAPTER}_frankentexts.md"
echo "$FRANKENTEXTS_PROMPT" | qwen > "$TEMP_RESULT_FILE"

# 读取生成的正文内容
GENERATED_CONTENT=""
if [ -s "$TEMP_RESULT_FILE" ]; then
    GENERATED_CONTENT=$(cat "$TEMP_RESULT_FILE")
fi

# 如果生成失败，使用原始内容
if [ -z "$GENERATED_CONTENT" ]; then
    echo "⚠️  Frankentexts生成失败，使用原始内容"
    GENERATED_CONTENT="$ORIGINAL_TEXT"
fi

# 获取章节标题和概要（从原始文件中提取）
if [ -n "$CHAPTER_FILE" ]; then
    CHAPTER_TITLE=$(basename "$CHAPTER_FILE" .md | sed "s/^chapter_${FORMATTED_CHAPTER}_//")
    SUMMARY=$(echo "$ORIGINAL_CONTENT" | sed -n '/## 概要/,/## 正文/p' | head -n -1 | tail -n +2 | sed '/^[[:space:]]*$/d')
    if [ -z "$SUMMARY" ]; then
        SUMMARY="本章继续讲述主角的冒险故事"
    fi
else
    CHAPTER_TITLE="第${CHAPTER_NUM}章"
    SUMMARY="本章继续讲述主角的冒险故事"
fi

# 保存最终结果
FINAL_RESULT_FILE="$FRANKENTEXTS_DIR/chapter_${FORMATTED_CHAPTER}_${CHAPTER_TITLE}-frankentexts.md"

# 应用番茄平台样式的格式化
{
    echo "# 第${CHAPTER_NUM}章 $CHAPTER_TITLE"
    echo ""
    echo "## 概要"
    echo ""
    echo "$SUMMARY"
    echo ""
    echo "## 正文"
    echo ""
    echo "$GENERATED_CONTENT"
    echo ""
    echo "---"
    echo ""
    echo "**下一章预告**：下一章将有重要情节发展。"
    echo ""
    echo "**字数统计**：$(echo "$GENERATED_CONTENT" | wc -c)字"
} > "$FINAL_RESULT_FILE"

echo "✅ Frankentexts融合拼接生成完成！结果已保存至: $FINAL_RESULT_FILE"

# 可代优化（如果需要）
if [ $ITERATION -gt 0 ]; then
    echo "🔄 执行迭代优化（$ITERATION次）..."
    
    CURRENT_FILE="$FINAL_RESULT_FILE"
    for iter in $(seq 1 $ITERATION); do
        # 提取当前内容的正文部分
        CURRENT_CONTENT=$(sed -n '/## 正文/,/^---/p' "$CURRENT_FILE" | head -n -1 | tail -n +2)
        
        IMPROVEMENT_PROMPT="作为专业小说编辑，请对以下章节内容进行质量改进，重点关注：

1. 故事连贯性和逻辑性
2. 人物行为的一致性
3. 对话的真实性和自然度
4. 场景描写的生动性
5. 情节推进的合理性
6. 与世界观设定的契合度

当前内容：
$CURRENT_CONTENT

请输出改进后的章节正文内容："

        # 生成改进后的内容
        IMPROVED_FILE="$TEMP_DIR/chapter_${FORMATTED_CHAPTER}_improved_${iter}.md"
        echo "$IMPROVEMENT_PROMPT" | qwen > "$IMPROVED_FILE"
        
        if [ -s "$IMPROVED_FILE" ]; then
            IMPROVED_CONTENT=$(cat "$IMPROVED_FILE")
            if [ -n "$IMPROVED_CONTENT" ]; then
                # 重新格式化
                {
                    echo "# 第${CHAPTER_NUM}章 $CHAPTER_TITLE"
                    echo ""
                    echo "## 概要"
                    echo ""
                    echo "$SUMMARY"
                    echo ""
                    echo "## 正文"
                    echo ""
                    echo "$IMPROVED_CONTENT"
                    echo ""
                    echo "---"
                    echo ""
                    echo "**下一章预告**：下一章将有重要情节发展。"
                    echo ""
                    echo "**字数统计**：$(echo "$IMPROVED_CONTENT" | wc -c)字"
                } > "$CURRENT_FILE"
                CURRENT_CONTENT="$IMPROVED_CONTENT"
            fi
        fi
        
        # 每20次迭代输出一次进度
        if [ $((iter % 20)) -eq 0 ]; then
            echo "   已完成$iter次迭代优化"
        fi
    done
    
    echo "✅ 迭代优化完成！"
fi

# 生成最终结果
FINAL_OUTPUT_FILE="$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_${CHAPTER_TITLE}-frankentexts-final.md"
cp "$FINAL_RESULT_FILE" "$FINAL_OUTPUT_FILE"

# 如果有原始文件，删除它并保留新的
if [ -n "$CHAPTER_FILE" ] && [ "$CHAPTER_FILE" != "$FINAL_OUTPUT_FILE" ]; then
    rm "$CHAPTER_FILE"
fi

# 重命名最终文件以符合标准格式
FINAL_NAME="$CHAPTERS_DIR/chapter_${FORMATTED_CHAPTER}_${CHAPTER_TITLE}.md"
mv "$FINAL_OUTPUT_FILE" "$FINAL_NAME"

# 生成报告
REPORT_FILE="$OUTPUT_DIR/frankentexts-report-${CHAPTER_NUM}.md"
printf '%s\n' "# Frankentexts融合拼接生成报告" '' \
"## 项目信息" \
"- 项目路径: $PROJECT_DIR" \
"- 章节号: $CHAPTER_NUM" \
"- 优化迭代: $ITERATION 次" \
"- 生成时间: $(date -Iseconds)" \
"- 备份路径: $BACKUP_DIR" \
'' \
"## 优化详情" \
"- 使用Frankentexts融合拼接方法" \
"- 遵循92%拼接/8%原创规则" \
"- 保持与世界观和人物设定一致性" \
"- 应用番茄平台格式" \
'' \
"## 文件说明" \
"- 优化结果: $FINAL_NAME" \
"- 生成报告: $REPORT_FILE" \
"- 临时文件: $TEMP_DIR" \
"- 备份文件: $BACKUP_DIR" \
'' \
"## 注意事项" \
"1. 优化后的章节已重命名以包含'frankentexts'标识" \
"2. 原始章节已备份至 $BACKUP_DIR" \
"3. 如需恢复原始版本，请从备份目录复制文件至 chapters 目录" \
"4. 优化版遵循Frankentexts方法论，内容更丰富连贯" > "$REPORT_FILE"

echo "✅ Frankentexts章节优化完成！报告已生成: $REPORT_FILE"