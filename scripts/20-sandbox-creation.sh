#!/bin/bash
# scripts/20-sandbox-creation.sh - 沙盒创作法专用脚本
# 基于沙盒创作法的分阶段小说生成流程

set -e

show_help() {
    echo "🏰 沙盒创作法专用脚本"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  init      <项目名> <章节数> [类型]  初始化沙盒项目"
    echo "  sandbox   <项目路径>              沙盒阶段创作（前10章）"
    echo "  expand    <项目路径> <开始章> <结束章> 扩展阶段创作"
    echo "  complete  <项目路径>              完成整个创作流程"
    echo "  analyze   <项目路径>              分析项目完整性"
    echo "  help                              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 init \"我的玄幻小说\" 100 \"玄幻\""
    echo "  $0 sandbox \"./projects/我的玄幻小说\""
    echo "  $0 expand \"./projects/我的玄幻小说\" 11 30"
    echo "  $0 complete \"./projects/我的玄幻小说\""
}

# 初始化沙盒项目
init_sandbox_project() {
    PROJECT_NAME=$1
    CHAPTER_COUNT=$2
    GENRE=$3

    if [ -z "$PROJECT_NAME" ] || [ -z "$CHAPTER_COUNT" ]; then
        echo "❌ 项目名和章节数为必填项"
        exit 1
    fi

    if [ -z "$GENRE" ]; then
        GENRE="小说"
    fi

    echo "🏰 初始化沙盒项目: $PROJECT_NAME ($CHAPTER_COUNT章, $GENRE类型)"
    
    # 创建项目
    ./scripts/01-init-project.sh "$PROJECT_NAME" "$CHAPTER_COUNT"
    
    PROJECT_PATH="./projects/$PROJECT_NAME"
    
    # 提示用户完善设定
    echo "📝 请完善以下设定文件:"
    echo "  - $PROJECT_PATH/settings/worldview.json (世界观)"
    echo "  - $PROJECT_PATH/settings/power-system.json (力量体系)"
    echo "  - $PROJECT_PATH/settings/characters.json (角色档案)"
    echo ""
    echo "💡 提示: 可以参考 examples/ 目录下的示例项目"
    echo ""
}

# 沙盒阶段创作
sandbox_phase() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔍 沙盒阶段创作: $PROJECT_PATH (第1-10章)"
    echo "此阶段将创建一个封闭环境，验证核心设定和人物关系"
    
    # 检查设定文件
    echo "✅ 检查设定文件..."
    if [ ! -f "$PROJECT_PATH/settings/worldview.json" ]; then
        echo "⚠️  未找到世界观设定文件，使用默认设定"
        echo '{"setting":"默认世界","rules":{},"cultures":[],"geography":"","history":"","magicSystem":{},"technologyLevel":"","socialStructure":""}' > "$PROJECT_PATH/settings/worldview.json"
    fi
    
    if [ ! -f "$PROJECT_PATH/settings/characters.json" ]; then
        echo "⚠️  未找到角色设定文件，使用默认设定"
        echo '{"protagonist":{"name":"","description":"","personality":"","abilities":[],"development":[],"characterArc":[]},"supporting":[],"antagonists":[]}' > "$PROJECT_PATH/settings/characters.json"
    fi
    
    # 批量创作沙盒章节
    ./scripts/03-batch-create.sh "$PROJECT_PATH" 1 10
    
    echo "✅ 沙盒阶段完成！请评估:"
    echo "  - 设定是否一致？"
    echo "  - 人物是否生动？"
    echo "  - 情节是否有吸引力？"
    echo ""
    echo "如需调整，可修改 settings/ 目录下的设定文件，然后继续扩展阶段"
}

# 扩展阶段创作
expand_phase() {
    PROJECT_PATH=$1
    START_CHAPTER=$2
    END_CHAPTER=$3
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    if [ -z "$START_CHAPTER" ] || [ -z "$END_CHAPTER" ]; then
        echo "❌ 请输入起始章和结束章号"
        exit 1
    fi
    
    echo "🚀 扩展阶段创作: $PROJECT_PATH (第$START_CHAPTER-$END_CHAPTER章)"
    echo "此阶段将逐步扩大世界观，深化情节发展"
    
    ./scripts/03-batch-create.sh "$PROJECT_PATH" $START_CHAPTER $END_CHAPTER
    
    echo "✅ 扩展阶段完成！"
}

# 完成整个创作流程
complete_flow() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🎊 完整创作流程: $PROJECT_PATH"
    
    # 检查是否有第1-10章
    CHAPTER_1_EXISTS=$(find "$PROJECT_PATH/chapters" -name "chapter_001_*" | head -n 1)
    CHAPTER_10_EXISTS=$(find "$PROJECT_PATH/chapters" -name "chapter_010_*" | head -n 1)
    
    if [ -n "$CHAPTER_1_EXISTS" ] && [ -n "$CHAPTER_10_EXISTS" ]; then
        echo "✅ 检测到沙盒章节，跳过沙盒阶段"
    else
        echo "🔍 执行沙盒阶段 (第1-10章)..."
        sandbox_phase "$PROJECT_PATH"
    fi
    
    # 计算剩余章节
    METADATA_FILE="$PROJECT_PATH/metadata.json"
    if [ -f "$METADATA_FILE" ]; then
        TOTAL_CHAPTERS=$(grep -o '"chapterCount":[0-9]*' "$METADATA_FILE" | cut -d: -f2)
        CURRENT_CHAPTER=$(grep -o '"currentChapter":[0-9]*' "$METADATA_FILE" | cut -d: -f2)
        
        if [ -z "$CURRENT_CHAPTER" ] || [ "$CURRENT_CHAPTER" -lt 10 ]; then
            START_EXPAND=11
        else
            START_EXPAND=$((CURRENT_CHAPTER + 1))
        fi
    else
        echo "⚠️  未找到元数据文件，假设有100章"
        START_EXPAND=11
        TOTAL_CHAPTERS=100
    fi
    
    if [ $START_EXPAND -le $TOTAL_CHAPTERS ]; then
        echo "🚀 执行扩展阶段 (第${START_EXPAND}-${TOTAL_CHAPTERS}章)..."
        
        # 分批进行，每批20章
        CURRENT=$START_EXPAND
        while [ $CURRENT -le $TOTAL_CHAPTERS ]; do
            END_BATCH=$((CURRENT + 19))
            if [ $END_BATCH -gt $TOTAL_CHAPTERS ]; then
                END_BATCH=$TOTAL_CHAPTERS
            fi
            
            echo "  创作第$CURRENT-$END_BATCH章..."
            expand_phase "$PROJECT_PATH" $CURRENT $END_BATCH
            
            CURRENT=$((END_BATCH + 1))
            
            # 每批完成后暂停一下
            if [ $CURRENT -le $TOTAL_CHAPTERS ]; then
                echo "  暂停10秒..."
                sleep 10
            fi
        done
    fi
    
    # 质量检查
    echo "✅ 执行最终质量检查..."
    ./scripts/04-quality-check.sh "$PROJECT_PATH"
    
    # 生成项目总结
    SUMMARY_FILE="$PROJECT_PATH/final-summary.md"
    cat > "$SUMMARY_FILE" << EOF
# 《$(basename "$PROJECT_PATH")》创作总结

## 项目信息
- 项目名称: $(basename "$PROJECT_PATH")
- 总章节数: $TOTAL_CHAPTERS
- 完成时间: $(date -Iseconds)
- 采用方法: 沙盒创作法

## 创作阶段
1. 沙盒阶段: 1-10章 (核心设定验证)
2. 扩展阶段: ${START_EXPAND}-${TOTAL_CHAPTERS}章 (世界观扩大)

## 项目统计
- 总字数: $(find "$PROJECT_PATH/chapters" -name "*.md" -exec cat {} \; | wc -w) 字
- 章节数: $(find "$PROJECT_PATH/chapters" -name "chapter_*.md" | wc -l)

## 项目结构
EOF
    tree "$PROJECT_PATH" >> "$SUMMARY_FILE" 2>/dev/null || echo "tree命令不可用"

    echo "🎊 项目完成！总结文件: $SUMMARY_FILE"
}

# 分析项目完整性
analyze_project() {
    PROJECT_PATH=$1
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi
    
    echo "🔬 分析项目完整性: $PROJECT_PATH"
    echo ""
    
    # 检查设定文件
    echo "📋 设定文件检查:"
    SETTINGS_DIR="$PROJECT_PATH/settings"
    if [ -d "$SETTINGS_DIR" ]; then
        for file in "$SETTINGS_DIR"/*.json; do
            if [ -f "$file" ]; then
                echo "  ✅ $(basename "$file")"
            fi
        done
    else
        echo "  ❌ 未找到设定目录"
    fi
    
    # 检查章节文件
    echo ""
    echo "📖 章节文件检查:"
    CHAPTERS_DIR="$PROJECT_PATH/chapters"
    if [ -d "$CHAPTERS_DIR" ]; then
        TOTAL_CHAPTERS=$(find "$CHAPTERS_DIR" -name "chapter_*.md" | wc -l)
        echo "  ✅ 总章节数: $TOTAL_CHAPTERS"
        
        # 检查连续性
        if [ $TOTAL_CHAPTERS -gt 0 ]; then
            LAST_CHAPTER=$(find "$CHAPTERS_DIR" -name "chapter_*.md" | sort | tail -n 1 | grep -o 'chapter_[0-9]*' | grep -o '[0-9]*')
            echo "  ✅ 最后一章: $LAST_CHAPTER"
        fi
    else
        echo "  ❌ 未找到章节目录"
    fi
    
    # 运行项目分析
    echo ""
    echo "📊 运行项目分析..."
    ./scripts/16-novelwriter-advanced.sh chapter-stats "$PROJECT_PATH"
    
    # 运行词汇分析
    echo ""
    echo "🔤 运行词汇分析..."
    ./scripts/17-lexicraftai-integration.sh vocabulary-analysis "$PROJECT_PATH"
}

# 主逻辑
COMMAND=$1
if [ -z "$COMMAND" ]; then
    show_help
    exit 1
fi

shift  # 移除命令参数

case $COMMAND in
    "init")
        if [ $# -lt 2 ]; then
            echo "❌ init命令需要提供: 项目名 章节数 [类型]"
            exit 1
        fi
        init_sandbox_project "$1" "$2" "$3"
        ;;
    "sandbox")
        if [ $# -lt 1 ]; then
            echo "❌ sandbox命令需要提供: 项目路径"
            exit 1
        fi
        sandbox_phase "$1"
        ;;
    "expand")
        if [ $# -lt 3 ]; then
            echo "❌ expand命令需要提供: 项目路径 开始章 结束章"
            exit 1
        fi
        expand_phase "$1" "$2" "$3"
        ;;
    "complete")
        if [ $# -lt 1 ]; then
            echo "❌ complete命令需要提供: 项目路径"
            exit 1
        fi
        complete_flow "$1"
        ;;
    "analyze")
        if [ $# -lt 1 ]; then
            echo "❌ analyze命令需要提供: 项目路径"
            exit 1
        fi
        analyze_project "$1"
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