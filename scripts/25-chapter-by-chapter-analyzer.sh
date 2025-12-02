#!/bin/bash
# scripts/25-chapter-by-chapter-analyzer.sh - 逐章累积分析脚本
# 基于强制逐章累积分析规则，对小说章节进行逐章深度分析并累积报告

set -e

show_help() {
    echo "🔄 逐章累积分析器"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  init     <项目路径> <小说名>    初始化累积分析"
    echo "  analyze  <项目路径> <章节号> <章节内容文件>  分析单章并更新累积报告"
    echo "  continue <项目路径> <章节号> <章节内容文件>  持续分析（会自动累积上一章结果）"
    echo "  view     <项目路径>              查看当前累积报告"
    echo "  export   <项目路径> <输出路径>    导出累积报告"
    echo "  help                                显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 init \"./projects/我的小说\" \"星辰变\""
    echo "  $0 analyze \"./projects/我的小说\" 1 \"./temp/chapter1.txt\""
    echo "  $0 continue \"./projects/我的小说\" 2 \"./temp/chapter2.txt\""
}

PROJECT_PATH=$1
CHAPTER_NUM=$2
CHAPTER_CONTENT_FILE=$3

case $1 in
    "init")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "❌ init命令需要提供: 项目路径 小说名"
            exit 1
        fi
        
        PROJECT_PATH=$2
        NOVEL_NAME=$3
        ANALYSIS_DIR="$PROJECT_PATH/chapter-analysis"
        CUMULATIVE_REPORT="$ANALYSIS_DIR/cumulative-analysis.md"
        
        mkdir -p "$ANALYSIS_DIR"
        
        # 创建初始累积报告
        cat > "$CUMULATIVE_REPORT" << EOF
# 《$NOVEL_NAME》 - 逐章累积分析报告（初始化）

## 分析状态
- 当前进度: 未开始分析
- 最新章节: 无
- 分析时间: $(date -Iseconds)

## 下一步行动
请使用 analyze 命令开始分析第一章，例如：
\`\`\`
$0 analyze "$PROJECT_PATH" 1 "/path/to/chapter1.txt"
\`\`\`
EOF
        
        echo "✅ 项目 $NOVEL_NAME 累积分析已初始化！"
        echo "📁 分析报告位置: $CUMULATIVE_REPORT"
        ;;
        
    "analyze"|"continue")
        if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
            echo "❌ analyze/continue命令需要提供: 项目路径 章节号 章节内容文件"
            exit 1
        fi
        
        PROJECT_PATH=$2
        CHAPTER_NUM=$3
        CHAPTER_CONTENT_FILE=$4
        
        if [ ! -f "$CHAPTER_CONTENT_FILE" ]; then
            echo "❌ 章节内容文件不存在: $CHAPTER_CONTENT_FILE"
            exit 1
        fi
        
        ANALYSIS_DIR="$PROJECT_PATH/chapter-analysis"
        CUMULATIVE_REPORT="$ANALYSIS_DIR/cumulative-analysis.md"
        CHAPTER_REPORT="$ANALYSIS_DIR/chapter-${CHAPTER_NUM}-analysis.md"
        
        # 确保目录存在
        mkdir -p "$ANALYSIS_DIR"
        
        # 读取章节内容
        CHAPTER_CONTENT=$(cat "$CHAPTER_CONTENT_FILE")
        
        # 如果是首次分析且累积报告不存在，创建初始化报告
        if [ ! -f "$CUMULATIVE_REPORT" ]; then
            INITIAL_NOVEL_NAME=$(basename "$PROJECT_PATH")
            cat > "$CUMULATIVE_REPORT" << EOF
# 《$INITIAL_NOVEL_NAME》 - 逐章累积分析报告（累积至第0章）

## 分析状态
- 当前进度: 已开始分析
- 最新章节: 无
- 分析时间: $(date -Iseconds)

## 逐章分析记录
（此处将累积每一章的分析结果）

## 当前分析章节 - 第$CHAPTER_NUM章
EOF
        fi
        
        # 读取当前累积报告
        CURRENT_REPORT=$(cat "$CUMULATIVE_REPORT")
        
        # 构建分析提示词
        ANALYSIS_PROMPT="你是我的'强制逐章累积分析师'，请按照以下规则对新章节进行详细分析并将结果合并到累积报告中：

## 上一轮累积报告
$(echo "$CURRENT_REPORT")

## 新章节文本（第$CHAPTER_NUM章）
$CHAPTER_CONTENT

## 分析要求
严格按照'强制逐章累积分析师'的规则执行：
1. 对新章节执行完整的6部分分析（文风指纹、剧情结构、角色分析、主题情感、风格技巧、感悟评价）
2. 将新章节的发现合并到累积报告中
3. 保持所有之前分析的内容完整
4. 更新报告标题为'累积至第$CHAPTER_NUM章'
5. 保持报告结构的完整性

请输出完整的更新版累积分析报告："
        
        # 调用Qwen进行分析（这将生成新的累积报告）
        echo "$ANALYSIS_PROMPT" | qwen > "$CHAPTER_REPORT"
        
        # 验证Qwen输出并更新累积报告
        if [ -s "$CHAPTER_REPORT" ]; then
            cp "$CHAPTER_REPORT" "$CUMULATIVE_REPORT"
            echo "✅ 第$CHAPTER_NUM章累积分析完成！"
            echo "📄 报告已更新: $CUMULATIVE_REPORT"
        else
            echo "⚠️  Qwen未返回有效内容，创建基于模板的分析报告"
            # 创建一个基于模板的分析报告
            TITLE=$(echo "$CURRENT_REPORT" | head -n 1 | sed "s/（累积至第[0-9]*章）/（累积至第$CHAPTER_NUM章）/")
            PREVIOUS_STATUS=$(echo "$CURRENT_REPORT" | grep -A 5 "## 分析状态")
            cat > "$CUMULATIVE_REPORT" << EOF
$TITLE
$PREVIOUS_STATUS
- 最新章节: 第$CHAPTER_NUM章
- 分析时间: $(date -Iseconds)

## 逐章分析记录

$(tail -n +$(($(echo "$CURRENT_REPORT" | grep -n "## 逐章分析记录" | cut -d: -f1)+1)) <<< "$CURRENT_REPORT"))

### 第$CHAPTER_NUM章 - 分析占位符

此章节的详细分析内容将在下次Qwen处理后更新。

- **章节内容**: 第$CHAPTER_NUM章已记录
- **分析状态**: 待Qwen处理

## 第一部分：文风指纹 (Stylometric Fingerprint)
（累积至第$CHAPTER_NUM章的文风分析，基于所有已分析章节）

## 第二部分：剧情与结构分析 (Plot & Structural Analysis)
（累积至第$CHAPTER_NUM章的剧情结构分析）

## 第三部分：角色分析 (Character Analysis)
（累积至第$CHAPTER_NUM章的角色分析更新）

## 第四部分：主题与情感 (Theme & Emotion)
（累积至第$CHAPTER_NUM章的主题情感分析）

## 第五部分：风格和技巧 (Style & Technique)
（累积至第$CHAPTER_NUM章的风格技巧总结）

## 第六部分：感悟与评价 (Reflection & Critique)
（累积至第$CHAPTER_NUM章的感悟评价）
EOF
        fi
        
        echo "✅ 第$CHAPTER_NUM章已分析并合并到累积报告"
        ;;
    
    "view")
        if [ -z "$2" ]; then
            echo "❌ view命令需要提供: 项目路径"
            exit 1
        fi
        
        PROJECT_PATH=$2
        CUMULATIVE_REPORT="$PROJECT_PATH/chapter-analysis/cumulative-analysis.md"
        
        if [ ! -f "$CUMULATIVE_REPORT" ]; then
            echo "❌ 未找到累积分析报告: $CUMULATIVE_REPORT"
            exit 1
        fi
        
        cat "$CUMULATIVE_REPORT"
        ;;
        
    "export")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "❌ export命令需要提供: 项目路径 输出路径"
            exit 1
        fi
        
        PROJECT_PATH=$2
        OUTPUT_PATH=$3
        CUMULATIVE_REPORT="$PROJECT_PATH/chapter-analysis/cumulative-analysis.md"
        
        if [ ! -f "$CUMULATIVE_REPORT" ]; then
            echo "❌ 未找到累积分析报告: $CUMULATIVE_REPORT"
            exit 1
        fi
        
        cp "$CUMULATIVE_REPORT" "$OUTPUT_PATH"
        echo "✅ 累积分析报告已导出: $OUTPUT_PATH"
        ;;
        
    "help"|"-h"|"--help")
        show_help
        ;;
        
    *)
        echo "❌ 未知命令: $1"
        show_help
        exit 1
        ;;
esac