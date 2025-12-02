#!/bin/bash
# scripts/11-unified-workflow.sh - 统一工作流脚本（Qwen Coder CLI优化版）
# 提供交互式和自动化两种模式

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo "📚 超长篇小说AI创作系统 v16.0 - 统一工作流"
    echo ""
    echo "用法: $0 [选项] [参数]"
    echo ""
    echo "模式选择:"
    echo "  -i, --interactive     启动交互式模式"
    echo "  -a, --auto            自动模式 (需要提供所有参数)"
    echo "  -h, --help           显示此帮助信息"
    echo ""
    echo "自动模式参数:"
    echo "  <项目名称> <章节数> [类型] [主角] [冲突]"
    echo ""
    echo "示例:"
    echo "  $0 -i                    # 交互式模式"
    echo "  $0 -a \"我的玄幻小说\" 100 \"玄幻\" \"林轩\" \"宗门试炼\"  # 自动模式"
}

# 解析命令行参数
MODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            MODE="interactive"
            shift
            ;;
        -a|--auto)
            MODE="auto"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# 交互式模式
interactive_mode() {
    echo -e "${BLUE}🚀 欢迎使用超长篇小说AI创作系统 v16.0${NC}"
    echo ""
    
    echo -n "📝 请输入项目名称: "
    read PROJECT_NAME
    
    while true; do
        echo -n "📝 请输入章节数 (建议10-500): "
        read CHAPTER_COUNT
        if [[ $CHAPTER_COUNT =~ ^[0-9]+$ ]] && [ $CHAPTER_COUNT -ge 1 ] && [ $CHAPTER_COUNT -le 1000 ]; then
            break
        else
            echo -e "${RED}❌ 请输入有效的章节数 (1-1000)${NC}"
        fi
    done
    
    echo -n "📝 请选择小说类型 (玄幻/都市/科幻/仙侠/历史): "
    read GENRE
    if [ -z "$GENRE" ]; then
        GENRE="小说"
    fi
    
    echo -n "👤 请输入主角姓名: "
    read PROTAGONIST
    
    echo -n "⚡ 请输入主要冲突/故事背景: "
    read CONFLICT
    
    echo ""
    echo -e "${YELLOW}✅ 确认项目信息:${NC}"
    echo "   项目名称: $PROJECT_NAME"
    echo "   章节数: $CHAPTER_COUNT"
    echo "   类型: $GENRE"
    echo "   主角: $PROTAGONIST"
    echo "   主要冲突: $CONFLICT"
    echo ""
    echo -n "是否开始创作? (y/N): "
    read CONFIRM
    
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        echo "❌ 操作已取消"
        exit 0
    fi
    
    # 开始自动创作流程
    auto_creation "$PROJECT_NAME" "$CHAPTER_COUNT" "$GENRE" "$PROTAGONIST" "$CONFLICT"
}

# 自动创作流程
auto_creation() {
    PROJECT_NAME=$1
    CHAPTER_COUNT=$2
    GENRE=$3
    PROTAGONIST=$4
    CONFLICT=$5
    
    PROJECT_DIR="./projects/$PROJECT_NAME"
    
    echo -e "${BLUE}🚀 开始创作项目: $PROJECT_NAME${NC}"
    
    # 步骤1: 初始化项目
    echo -e "${BLUE}📝 步骤1: 初始化项目...${NC}"
    ./scripts/01-init-project.sh "$PROJECT_NAME" "$CHAPTER_COUNT"
    echo -e "${GREEN}✅ 项目初始化完成${NC}"
    
    # 步骤2: 生成大纲
    echo -e "${BLUE}📋 步骤2: 生成详细大纲...${NC}"
    generate_outline "$PROJECT_DIR" "$GENRE" "$PROTAGONIST" "$CONFLICT" "$CHAPTER_COUNT"
    echo -e "${GREEN}✅ 大纲生成完成${NC}"
    
    # 步骤3: 批量创作章节
    echo -e "${BLUE}✍️  步骤3: 批量创作章节...${NC}"
    create_chapters "$PROJECT_DIR" "$CHAPTER_COUNT"
    echo -e "${GREEN}✅ 章节创作完成${NC}"
    
    # 步骤4: 质量检查
    echo -e "${BLUE}🔍 步骤4: 质量检查...${NC}"
    ./scripts/04-quality-check.sh "$PROJECT_DIR"
    echo -e "${GREEN}✅ 质量检查完成${NC}"
    
    # 步骤5: 生成项目总结
    echo -e "${BLUE}📊 步骤5: 生成总结...${NC}"
    generate_summary "$PROJECT_DIR" "$PROJECT_NAME" "$GENRE" "$CHAPTER_COUNT"
    echo -e "${GREEN}✅ 项目总结生成完成${NC}"
    
    echo ""
    echo -e "${GREEN}🎉 恭喜！《$PROJECT_NAME》创作完成！${NC}"
    echo -e "${YELLOW}📁 项目位置: $PROJECT_DIR${NC}"
    echo -e "${YELLOW}📈 章节数量: $CHAPTER_COUNT${NC}"
    echo -e "${YELLOW}📖 总结文件: $PROJECT_DIR/summary.md${NC}"
}

# 生成大纲
generate_outline() {
    PROJECT_DIR=$1
    GENRE=$2
    PROTAGONIST=$3
    CONFLICT=$4
    CHAPTER_COUNT=$5
    
    # 创建大纲提示
    cat > /tmp/outline_prompt.txt << EOF
# 角色设定
你是一位10年经验的$GENRE类网文大神，代表作累计2000万字。

# 任务
请为$GENRE小说《$PROJECT_NAME》生成一个详细大纲。

# 小说信息
- 主角: $PROTAGONIST
- 主要冲突: $CONFLICT
- 章节数: $CHAPTER_COUNT
- 目标字数: 约$(($CHAPTER_COUNT * 3000))字

# 大纲要求
- 每章有一个吸引人的标题（包含章节号和简短描述）
- 每章有简短的情节概要（50-100字）
- 确保情节连贯，有明确的开端、发展、高潮、结尾
- 合理安排伏笔和回收
- 控制在$CHAPTER_COUNT章完成主要故事线

# 格式要求
- 使用markdown格式
- 每章用四级标题(####)开头
- 格式: #### 第X章 [章节标题] ([可选副标题])
- 然后是章节概要

# 示例格式
#### 第1章 废柴觉醒 (意外获得传承)
主角林轩在宗门试炼中意外跌落山崖，却获得上古大能传承，从此踏上修炼之路...

现在开始生成大纲：
EOF

    # 调用Qwen生成大纲
    cat /tmp/outline_prompt.txt | qwen > "$PROJECT_DIR/outline.md"
    
    # 检查生成结果
    if [ ! -s "$PROJECT_DIR/outline.md" ]; then
        echo -e "${RED}❌ 大纲生成失败，使用备用大纲${NC}"
        create_fallback_outline "$PROJECT_DIR" "$CHAPTER_COUNT"
    fi
}

# 备用大纲生成
create_fallback_outline() {
    PROJECT_DIR=$1
    CHAPTER_COUNT=$2
    
    echo "# $PROJECT_NAME 大纲" > "$PROJECT_DIR/outline.md"
    echo "" >> "$PROJECT_DIR/outline.md"
    
    for i in $(seq 1 $CHAPTER_COUNT); do
        echo "#### 第${i}章 章节标题$i" >> "$PROJECT_DIR/outline.md"
        echo "第${i}章的情节概要。" >> "$PROJECT_DIR/outline.md"
        echo "" >> "$PROJECT_DIR/outline.md"
    done
}

# 创建章节
create_chapters() {
    PROJECT_DIR=$1
    CHAPTER_COUNT=$2
    
    # 检查大纲是否生成
    if [ ! -f "$PROJECT_DIR/outline.md" ]; then
        echo -e "${RED}❌ 大纲未生成，无法创作章节${NC}"
        exit 1
    fi

    echo "开始分批创作章节..."

    # 按每批5章进行创作，以更好地管理令牌使用
    BATCH_SIZE=5
    CURRENT_CHAPTER=1

    while [ $CURRENT_CHAPTER -le $CHAPTER_COUNT ]; do
        END_CHAPTER=$((CURRENT_CHAPTER + BATCH_SIZE - 1))
        if [ $END_CHAPTER -gt $CHAPTER_COUNT ]; then
            END_CHAPTER=$CHAPTER_COUNT
        fi
        
        echo -e "${YELLOW}创作第$CURRENT_CHAPTER章到第$END_CHAPTER章...${NC}"
        ./scripts/03-batch-create.sh "$PROJECT_DIR" $CURRENT_CHAPTER $END_CHAPTER
        
        CURRENT_CHAPTER=$((END_CHAPTER + 1))
        
        # 每批完成后暂停一下，管理令牌使用
        if [ $CURRENT_CHAPTER -le $CHAPTER_COUNT ]; then
            echo "批次完成，暂停15秒以管理令牌使用..."
            sleep 15
        fi
    done
}

# 生成项目总结
generate_summary() {
    PROJECT_DIR=$1
    PROJECT_NAME=$2
    GENRE=$3
    CHAPTER_COUNT=$4
    
    SUMMARY_FILE="$PROJECT_DIR/summary.md"
    
    cat > "$SUMMARY_FILE" << EOF
# 《$PROJECT_NAME》项目总结

## 📋 项目信息
- 项目名称: $PROJECT_NAME
- 小说类型: $GENRE
- 章节数: $CHAPTER_COUNT
- 创建时间: $(date -Iseconds)
- 完成时间: $(date -Iseconds)

## 📖 章节列表
EOF

    # 添加章节列表到总结
    for file in "$PROJECT_DIR/chapters/"*.md; do
        if [ -f "$file" ]; then
            # 从文件名提取章节信息
            BASENAME=$(basename "$file")
            CHAPTER_NUM=$(echo "$BASENAME" | sed -n 's/chapter_\([0-9]*\)_\(.*\)\.md$/\1/p')
            CHAPTER_TITLE=$(echo "$BASENAME" | sed -n 's/chapter_\([0-9]*\)_\(.*\)\.md$/\2/p')
            
            if [ -n "$CHAPTER_NUM" ] && [ -n "$CHAPTER_TITLE" ]; then
                echo "  - 第${CHAPTER_NUM}章: $CHAPTER_TITLE" >> "$SUMMARY_FILE"
            fi
        fi
    done
    
    echo "" >> "$SUMMARY_FILE"
    echo "## 📊 项目统计" >> "$SUMMARY_FILE"
    
    # 统计总字数（近似）
    TOTAL_WORDS=0
    for file in "$PROJECT_DIR/chapters/"*.md; do
        if [ -f "$file" ]; then
            WORD_COUNT=$(wc -w < "$file")
            TOTAL_WORDS=$((TOTAL_WORDS + WORD_COUNT))
        fi
    done
    
    echo "  - 总字数: ~$TOTAL_WORDS 字" >> "$SUMMARY_FILE"
    echo "  - 平均每章: ~$((TOTAL_WORDS / CHAPTER_COUNT)) 字" >> "$SUMMARY_FILE"

    echo "" >> "$SUMMARY_FILE"
    echo "## 📝 备注" >> "$SUMMARY_FILE"
    echo "- 此项目使用Qwen Coder CLI自动化生成" >> "$SUMMARY_FILE"
    echo "- 项目文件路径: $PROJECT_DIR" >> "$SUMMARY_FILE"
}

# 主逻辑
case $MODE in
    "interactive")
        interactive_mode
        ;;
    "auto")
        if [ $# -lt 5 ]; then
            echo -e "${RED}❌ 自动模式需要提供: 项目名称 章节数 类型 主角 冲突${NC}"
            exit 1
        fi
        auto_creation "$1" "$2" "$3" "$4" "$5"
        ;;
    *)
        show_help
        exit 1
        ;;
esac