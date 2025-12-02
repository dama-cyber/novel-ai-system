#!/bin/bash
# scripts/30-stylus-engine.sh - AI文体工程模块集成脚本
# 实现换元与仿写功能，基于"AI文体工程"模块

set -e

# 检查系统环境并设置兼容性选项
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows环境兼容性处理
    PLATFORM="windows"
    # 检查是否安装了jq，如果未安装给出提示
    if ! command -v jq &> /dev/null; then
        echo "⚠️  Windows环境下未检测到jq命令，部分功能可能受限"
        echo "💡  建议安装jq: https://stedolan.github.io/jq/download/"
    fi
else
    PLATFORM="unix"
fi

show_help() {
    echo "🎨 AI文体工程模块 - 换元与仿写"
    echo ""
    echo "用法: $0 <命令> [参数]"
    echo ""
    echo "可用命令:"
    echo "  init      <项目路径> <分析报告路径>  初始化换元仿写流程"
    echo "  gacha     <项目路径>                启动抽卡模式生成标题"
    echo "  blueprint <项目路径> <构思>         生成新故事蓝图"
    echo "  execute   <项目路径>                执行仿写生成"
    echo "  help                                显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 init \"./projects/我的小说\" \"./analysis-report.md\""
    echo "  $0 gacha \"./projects/我的小说\""
    echo "  $0 blueprint \"./projects/我的小说\" \"现代娱乐圈\""
    echo "  $0 execute \"./projects/我的小说\""
}

# 初始化换元仿写流程
init_stylus_engine() {
    local PROJECT_PATH=$1
    local ANALYSIS_REPORT_PATH=$2

    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ 项目路径不存在: $PROJECT_PATH"
        exit 1
    fi

    if [ ! -f "$ANALYSIS_REPORT_PATH" ]; then
        echo "❌ 分析报告不存在: $ANALYSIS_REPORT_PATH"
        exit 1
    fi

    echo "🎨 初始化AI文体工程模块..."

    # 创建stylus-engine目录
    STYLUS_DIR="$PROJECT_PATH/stylus-engine"
    mkdir -p "$STYLUS_DIR"

    # 复制分析报告到stylus-engine目录
    cp "$ANALYSIS_REPORT_PATH" "$STYLUS_DIR/analysis-report.md"

    # 创建配置文件
    cat > "$STYLUS_DIR/config.json" << EOF
{
  "initialized": true,
  "analysisReportPath": "$(basename "$ANALYSIS_REPORT_PATH")",
  "creationMode": null,
  "targetWordCount": null,
  "swapConcept": null,
  "blueprintConfirmed": false
}
EOF

    echo "✅ AI文体工程模块初始化完成！"
    echo "📁 项目位置: $STYLUS_DIR"
    echo "📋 分析报告已复制: $(basename "$ANALYSIS_REPORT_PATH")"
}

# 启动抽卡模式
gacha_mode() {
    local PROJECT_PATH=$1

    STYLUS_DIR="$PROJECT_PATH/stylus-engine"
    if [ ! -d "$STYLUS_DIR" ]; then
        echo "❌ 请先初始化AI文体工程模块"
        exit 1
    fi

    ANALYSIS_REPORT="$STYLUS_DIR/analysis-report.md"
    if [ ! -f "$ANALYSIS_REPORT" ]; then
        echo "❌ 找不到分析报告文件"
        exit 1
    fi

    echo "🎲 启动抽卡模式生成标题..."

    # 提取分析报告中的核心主题
    # 为兼容Windows环境，先尝试使用grep，失败则使用备用方案
    if command -v grep &> /dev/null && command -v sed &> /dev/null; then
        CORE_THEMES=$(grep -E "(主题|核心|要素|风格)" "$ANALYSIS_REPORT" | head -n 10 | sed 's/.*:\s*//' | head -c 200)
    else
        # 如果grep/sed不可用，则读取报告的前几行作为主题提示
        CORE_THEMES=$(head -n 20 "$ANALYSIS_REPORT" | head -c 200)
    fi

    # 使用Qwen生成模拟热门标题
    GACHA_PROMPT="你是一个专业的网络小说标题策划师。请根据以下故事要素，生成5个模拟的热门网络小说标题：

故事要素：
$CORE_THEMES

要求：
1. 标题应符合当前网文市场热点
2. 包含吸引读者的元素（如：重生、穿越、系统、马甲等）
3. 具有强烈的情绪冲击力或好奇心激发点
4. 长度适中，便于传播

生成5个标题："

    # 生成抽卡标题
    GACHA_OUTPUT="$STYLUS_DIR/gacha-options.txt"
    echo "$GACHA_PROMPT" | qwen > "$GACHA_OUTPUT"

    if [ -s "$GACHA_OUTPUT" ]; then
        echo "以下是为您生成的模拟热门标题，请选择一个："
        cat "$GACHA_OUTPUT"
        echo ""
        echo "请将您选择的标题保存，供后续使用。"
    else
        # 如果Qwen未返回结果或命令不可用，使用备用方案
        echo "1. 《穿成炮灰后，我靠直播玄学爆红了》" > "$GACHA_OUTPUT"
        echo "2. 《重生90：踹掉渣男后成全国首富》" >> "$GACHA_OUTPUT"
        echo "3. 《霸总别虐了，夫人的马甲藏不住了》" >> "$GACHA_OUTPUT"
        echo "4. 《系统逼我当群演，意外成了顶流》" >> "$GACHA_OUTPUT"
        echo "5. 《快穿：反派的白月光是我》" >> "$GACHA_OUTPUT"

        echo "以下是为您生成的模拟热门标题，请选择一个："
        cat "$GACHA_OUTPUT"
    fi
}

# 生成新故事蓝图
create_blueprint() {
    local PROJECT_PATH=$1
    local SWAP_CONCEPT=$2

    STYLUS_DIR="$PROJECT_PATH/stylus-engine"
    if [ ! -d "$STYLUS_DIR" ]; then
        echo "❌ 请先初始化AI文体工程模块"
        exit 1
    fi

    ANALYSIS_REPORT="$STYLUS_DIR/analysis-report.md"
    if [ ! -f "$ANALYSIS_REPORT" ]; then
        echo "❌ 找不到分析报告文件"
        exit 1
    fi

    echo "📋 生成新故事蓝图..."

    # 询问用户选择长篇还是短篇
    echo "请选择创作模式："
    echo "A. 【长篇】 (字数无限制，我们将逐章生成)"
    echo "B. 【短篇】 (目标 9,000 - 15,000 字，我们将分段生成全文)"
    echo -n "请输入您的选择 (A/B): "
    read MODE_CHOICE

    case $MODE_CHOICE in
        [Aa])
            CREATION_MODE="长篇 (逐章生成)"
            TARGET_WORD_COUNT="无限制"
            ;;
        [Bb])
            CREATION_MODE="短篇 (分段生成)"
            TARGET_WORD_COUNT="9,000 - 15,000字"
            ;;
        *)
            echo "❌ 无效选择，使用默认：短篇"
            CREATION_MODE="短篇 (分段生成)"
            TARGET_WORD_COUNT="9,000 - 15,000字"
            ;;
    esac

    # 构建蓝图生成提示
    BLUEPRINT_PROMPT="你是AI文体工程的首席创意执行官，现在基于拆书分析报告进行换元设计。

原始分析报告：
$(head -c 2000 "$ANALYSIS_REPORT")

换元构思：
$SWAP_CONCEPT

请按照以下格式生成《新故事蓝图》：

# 《[新作品名] - 创意蓝图》

## 一、基本信息 (一度置换)
* **原始故事:** [源自分析报告]
* **新故事选题:** $SWAP_CONCEPT
* **创作模式:** $CREATION_MODE
* **目标字数:** $TARGET_WORD_COUNT
* **核心梗 (置换后):** [基于换元构思的具体核心情节]

## 二、故事设定 (一度置换)
* **新背景设定:** [基于换元构思的新背景]
* **新人物 (置换后):**
    * **主角 [新角色名]:** (对应旧角色)
    * **配角 [新角色名]:** (对应旧角色)
    * ...

## 三、故事骨骼 (二度置换)
* **结构源:** [是否调整原始结构]
* **主体源 (主题):** [是否调整原始主题]

## 四、核心脉络 (新)
* **新-大纲 (New Overall Outline):** [新故事的起承转合]
* **新-细纲 (New Detailed Outline):** [按章节或关键情节点拆分]
* **新-爽点/虐点 (Payoff Points):** [新故事的情绪引爆点]
* **新-节奏 (Pacing):** [新故事的剧情发展曲线和情绪变化]

请严格遵循格式生成。"

    # 生成蓝图
    BLUEPRINT_PATH="$STYLUS_DIR/blueprint.md"
    echo "$BLUEPRINT_PROMPT" | qwen > "$BLUEPRINT_PATH"

    if [ -s "$BLUEPRINT_PATH" ]; then
        echo "✅ 新故事蓝图已生成: $BLUEPRINT_PATH"

        # 更新配置文件中的模式信息
        if command -v jq &> /dev/null; then
            jq --arg mode "$CREATION_MODE" --arg count "$TARGET_WORD_COUNT" --arg concept "$SWAP_CONCEPT" \
               '.creationMode = $mode | .targetWordCount = $count | .swapConcept = $concept | .blueprintConfirmed = false' \
               "$STYLUS_DIR/config.json" > "$STYLUS_DIR/config.json.tmp" 2>/dev/null && mv "$STYLUS_DIR/config.json.tmp" "$STYLUS_DIR/config.json" || \
               echo "{\"initialized\": true, \"creationMode\": \"$CREATION_MODE\", \"targetWordCount\": \"$TARGET_WORD_COUNT\", \"swapConcept\": \"$SWAP_CONCEPT\", \"blueprintConfirmed\": false, \"analysisReportPath\": \"analysis-report.md\"}" > "$STYLUS_DIR/config.json"
        else
            # 如果jq不可用，使用sed进行简单的文本替换
            echo "⚠️  jq命令不可用，使用备用方案更新配置"
            # 创建新的配置文件
            cat > "$STYLUS_DIR/config.json" << EOF
{
  "initialized": true,
  "analysisReportPath": "analysis-report.md",
  "creationMode": "$CREATION_MODE",
  "targetWordCount": "$TARGET_WORD_COUNT",
  "swapConcept": "$SWAP_CONCEPT",
  "blueprintConfirmed": false
}
EOF
        fi
    else
        echo "⚠️  Qwen未返回有效蓝图内容，创建模板文件"
        cat > "$BLUEPRINT_PATH" << EOF
# 《$SWAP_CONCEPT - 创意蓝图》

## 一、基本信息 (一度置换)
* **原始故事:** [源自分析报告]
* **新故事选题:** $SWAP_CONCEPT
* **创作模式:** $CREATION_MODE
* **目标字数:** $TARGET_WORD_COUNT
* **核心梗 (置换后):** [基于换元构思的具体核心情节]

## 二、故事设定 (一度置换)
* **新背景设定:** [基于换元构思的新背景]
* **新人物 (置换后):**
    * **主角 [新角色名]:** (对应旧角色)
    * **配角 [新角色名]:** (对应旧角色)
    * ...

## 三、故事骨骼 (二度置换)
* **结构源:** [是否调整原始结构]
* **主体源 (主题):** [是否调整原始主题]

## 四、核心脉络 (新)
* **新-大纲 (New Overall Outline):** [新故事的起承转合]
* **新-细纲 (New Detailed Outline):** [按章节或关键情节点拆分]
* **新-爽点/虐点 (Payoff Points):** [新故事的情绪引爆点]
* **新-节奏 (Pacing):** [新故事的剧情发展曲线和情绪变化]
EOF
        echo "✅ 蓝图模板已生成: $BLUEPRINT_PATH"
    fi
}

# 执行仿写生成
execute_generation() {
    local PROJECT_PATH=$1

    STYLUS_DIR="$PROJECT_PATH/stylus-engine"
    if [ ! -d "$STYLUS_DIR" ]; then
        echo "❌ 请先初始化AI文体工程模块"
        exit 1
    fi

    BLUEPRINT_PATH="$STYLUS_DIR/blueprint.md"
    if [ ! -f "$BLUEPRINT_PATH" ]; then
        echo "❌ 找不到故事蓝图文件，请先生成蓝图"
        exit 1
    fi

    ANALYSIS_REPORT="$STYLUS_DIR/analysis-report.md"
    if [ ! -f "$ANALYSIS_REPORT" ]; then
        echo "❌ 找不到分析报告文件"
        exit 1
    fi

    # 检查配置文件中的创作模式
    if command -v jq >/dev/null 2>&1; then
        CREATION_MODE=$(jq -r '.creationMode // "短篇 (分段生成)"' "$STYLUS_DIR/config.json" 2>/dev/null)
        # 如果jq命令失败或返回空值，使用默认值
        if [ -z "$CREATION_MODE" ] || [ "$CREATION_MODE" = "null" ]; then
            CREATION_MODE="短篇 (分段生成)"  # 默认值
        fi
    else
        CREATION_MODE="短篇 (分段生成)"  # 默认值
        echo "⚠️  jq命令不可用，使用默认创作模式: 短篇 (分段生成)"
    fi

    echo "🎭 开始执行仿写生成..."
    echo "📋 创作模式: $CREATION_MODE"

    # 获取文风指纹（分析报告的第一部分）
    STYLE_FINGERPRINT=$(sed -n '/## 第一部分：文风指纹/,/## 第二部分/p' "$ANALYSIS_REPORT" | head -n -1)

    # 获取故事蓝图内容
    BLUEPRINT_CONTENT=$(cat "$BLUEPRINT_PATH")

    if [[ "$CREATION_MODE" == *"短篇"* ]]; then
        # 短篇分段生成模式
        echo "📝 采用分段生成模式 (目标 9,000-15,000 字)..."
        
        # 构建生成提示
        GENERATION_PROMPT="你现在是AI文体工程的仿写执行官，正在进行短篇小说仿写。

你的任务：
1. 严格按照提供的故事蓝图执行生成
2. 严格复现原始报告中的文风指纹
3. 确保总字数在 9,000-15,000 字之间

文风指纹参考：
$STYLE_FINGERPRINT

故事蓝图：
$BLUEPRINT_CONTENT

现在开始生成短篇小说的第1部分（约占全文的1/4，约2000-4000字）。请确保：
1. 严格遵循故事蓝图的情节安排
2. 保持文风指纹中描述的写作风格
3. 体现人性化特征，避免过于完美的表达
4. 按照蓝图中的节奏安排情节发展

开始生成："

        # 生成第一部分
        OUTPUT_DIR="$STYLUS_DIR/output"
        mkdir -p "$OUTPUT_DIR"
        
        echo "$GENERATION_PROMPT" | qwen > "$OUTPUT_DIR/part-1.txt"
        
        if [ -s "$OUTPUT_DIR/part-1.txt" ]; then
            echo "✅ 短篇小说第1部分已生成: $OUTPUT_DIR/part-1.txt"
            echo "继续生成后续部分，请使用脚本继续命令"
        else
            echo "⚠️  生成失败，创建占位文件"
            echo "短篇小说第1部分占位符" > "$OUTPUT_DIR/part-1.txt"
        fi
        
    else
        # 长篇逐章生成模式
        echo "챕apters 采用逐章生成模式..."
        
        # 构建生成提示
        GENERATION_PROMPT="你现在是AI文体工程的仿写执行官，正在进行长篇小说仿写。

你的任务：
1. 严格按照提供的故事蓝图执行生成
2. 严格复现原始报告中的文风指纹
3. 按章节逐章生成

文风指纹参考：
$STYLE_FINGERPRINT

故事蓝图：
$BLUEPRINT_CONTENT

现在开始生成第一章。请确保：
1. 严格遵循故事蓝图的情节安排
2. 保持文风指纹中描述的写作风格
3. 体现人性化特征，避免过于完美的表达
4. 按照蓝图中的节奏安排情节发展

开始生成第一章："

        # 生成第一章
        OUTPUT_DIR="$STYLUS_DIR/output"
        mkdir -p "$OUTPUT_DIR"
        
        echo "$GENERATION_PROMPT" | qwen > "$OUTPUT_DIR/chapter-1.txt"
        
        if [ -s "$OUTPUT_DIR/chapter-1.txt" ]; then
            echo "✅ 长篇小说第一章已生成: $OUTPUT_DIR/chapter-1.txt"
            echo "继续生成后续章节，请使用脚本继续命令"
        else
            echo "⚠️  生成失败，创建占位文件"
            echo "长篇小说第一章占位符" > "$OUTPUT_DIR/chapter-1.txt"
        fi
    fi

    echo "📁 生成内容保存在: $OUTPUT_DIR/"
    echo "💡 如需继续生成后续部分/章节，请再次运行此命令或手动执行相关操作"
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
            echo "❌ init命令需要提供: 项目路径 分析报告路径"
            exit 1
        fi
        init_stylus_engine "$1" "$2"
        ;;
    "gacha")
        if [ $# -lt 1 ]; then
            echo "❌ gacha命令需要提供: 项目路径"
            exit 1
        fi
        gacha_mode "$1"
        ;;
    "blueprint")
        if [ $# -lt 2 ]; then
            echo "❌ blueprint命令需要提供: 项目路径 换元构思"
            exit 1
        fi
        create_blueprint "$1" "$2"
        ;;
    "execute")
        if [ $# -lt 1 ]; then
            echo "❌ execute命令需要提供: 项目路径"
            exit 1
        fi
        execute_generation "$1"
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