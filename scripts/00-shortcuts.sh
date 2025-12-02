#!/bin/bash
# scripts/00-shortcuts.sh - 简化指令包装脚本
# 将简化指令映射到完整脚本，实现快速调用

set -e

show_help() {
    echo "📖 小说AI系统简化指令包装器"
    echo "使用 'na <指令> [参数]' 格式调用"
    echo ""
    echo "示例:"
    echo "  na p-init \"我的小说\" 100                    # 初始化项目"
    echo "  na s-analyze \"./projects/我的小说\" 1 10     # 拆书分析"
    echo "  na x-sbox \"./projects/我的小说\"             # 沙盒创作"
}

# 检查是否提供了命令
if [ "$#" -eq 0 ]; then
    show_help
    exit 1
fi

# 解析主命令
MAIN_CMD="$1"
shift

case "$MAIN_CMD" in
    "p")
        # 项目管理命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "init")
                ./scripts/01-init-project.sh "$@"
                ;;
            "outline")
                ./scripts/02-create-outline.sh "$@"
                ;;
            "create")
                ./scripts/03-batch-create.sh "$@"
                ;;
            "check")
                ./scripts/04-quality-check.sh "$@"
                ;;
            "compress")
                ./scripts/05-compress-session.sh "$@"
                ;;
            *)
                echo "❌ 未知项目管理命令: $SUB_CMD"
                echo "可用命令: init, outline, create, check, compress"
                ;;
        esac
        ;;
    "s")
        # 拆书分析命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "analyze")
                ./scripts/22-split-book-analyzer.sh "$@"
                ;;
            "swap")
                ./scripts/23-element-swapper.sh "$@"
                ;;
            "rewrite")
                ./scripts/24-content-rewriter.sh "$@"
                ;;
            "full")
                ./scripts/21-combined-revision.sh full "$@"
                ;;
            *)
                echo "❌ 未知拆书命令: $SUB_CMD"
                echo "可用命令: analyze, swap, rewrite, full"
                ;;
        esac
        ;;
    "x")
        # 沙盒创作命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "init")
                ./scripts/20-sandbox-creation.sh init "$@"
                ;;
            "sbox"|"sandbox")
                ./scripts/20-sandbox-creation.sh sandbox "$@"
                ;;
            "expand")
                ./scripts/20-sandbox-creation.sh expand "$@"
                ;;
            "complete")
                ./scripts/20-sandbox-creation.sh complete "$@"
                ;;
            "analyze")
                ./scripts/20-sandbox-creation.sh analyze "$@"
                ;;
            *)
                echo "❌ 未知沙盒命令: $SUB_CMD"
                echo "可用命令: init, sbox/sandbox, expand, complete, analyze"
                ;;
        esac
        ;;
    "e")
        # 增强功能命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "cont"|"continue")
                ./scripts/14-enhancement-suite.sh continue "$@"
                ;;
            "revise")
                ./scripts/14-enhancement-suite.sh revise "$@"
                ;;
            "opt"|"optimize")
                ./scripts/14-enhancement-suite.sh optimize "$@"
                ;;
            "analyze"|"proj")
                ./scripts/14-enhancement-suite.sh analyze "$@"
                ;;
            "expand")
                ./scripts/14-enhancement-suite.sh expand "$@"
                ;;
            *)
                echo "❌ 未知增强命令: $SUB_CMD"
                echo "可用命令: cont/continue, revise, opt/optimize, analyze/proj, expand"
                ;;
        esac
        ;;
    "n")
        # NovelWriter相关命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "md")
                ./scripts/15-novelwriter-integration.sh export-md "$@"
                ;;
            "html")
                ./scripts/15-novelwriter-integration.sh export-html "$@"
                ;;
            "compile")
                ./scripts/15-novelwriter-integration.sh compile-book "$@"
                ;;
            "nalyze"|"analyze")
                ./scripts/15-novelwriter-integration.sh analyze-project "$@"
                ;;
            "scenes")
                ./scripts/15-novelwriter-integration.sh split-scenes "$@"
                ;;
            *)
                echo "❌ 未知NovelWriter命令: $SUB_CMD"
                echo "可用命令: md, html, compile, nalyze/analyze, scenes"
                ;;
        esac
        ;;
    "na")
        # NovelWriter高级分析命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "wc"|"wordcount")
                ./scripts/16-novelwriter-advanced.sh word-count "$@"
                ;;
            "stats")
                ./scripts/16-novelwriter-advanced.sh chapter-stats "$@"
                ;;
            "pov")
                ./scripts/16-novelwriter-advanced.sh pov-analysis "$@"
                ;;
            "dial"|"dialogue")
                ./scripts/16-novelwriter-advanced.sh dialogue-check "$@"
                ;;
            "read"|"readability")
                ./scripts/16-novelwriter-advanced.sh readability "$@"
                ;;
            "timeline")
                ./scripts/16-novelwriter-advanced.sh timeline "$@"
                ;;
            "char"|"character")
                ./scripts/16-novelwriter-advanced.sh character-tracker "$@"
                ;;
            "cons"|"consistency")
                ./scripts/16-novelwriter-advanced.sh consistency-check "$@"
                ;;
            *)
                echo "❌ 未知高级分析命令: $SUB_CMD"
                echo "可用命令: wc/wordcount, stats, pov, dial/dialogue, read/readability, timeline, char/character, cons/consistency"
                ;;
        esac
        ;;
    "l")
        # LexicraftAI命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "vocab")
                ./scripts/17-lexicraftai-integration.sh vocabulary-analysis "$@"
                ;;
            "freq")
                ./scripts/17-lexicraftai-integration.sh word-frequency "$@"
                ;;
            "syn")
                ./scripts/17-lexicraftai-integration.sh synonym-replacer "$@"
                ;;
            "style")
                ./scripts/17-lexicraftai-integration.sh style-analyzer "$@"
                ;;
            "sent")
                ./scripts/17-lexicraftai-integration.sh sentiment-check "$@"
                ;;
            "read"|"readability")
                ./scripts/17-lexicraftai-integration.sh readability-improver "$@"
                ;;
            "gen"|"generate")
                ./scripts/17-lexicraftai-integration.sh generate-vocabulary "$@"
                ;;
            "exp"|"export")
                ./scripts/17-lexicraftai-integration.sh export-lexicon "$@"
                ;;
            "ctx"|"context")
                ./scripts/17-lexicraftai-integration.sh context-optimizer "$@"
                ;;
            "prose")
                ./scripts/17-lexicraftai-integration.sh prose-enhancer "$@"
                ;;
            *)
                echo "❌ 未知词汇分析命令: $SUB_CMD"
                echo "可用命令: vocab, freq, syn, style, sent, read/readability, gen/generate, exp/export, ctx/context, prose"
                ;;
        esac
        ;;
    "sys")
        # 系统工具命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "val"|"validate")
                ./scripts/98-project-validator.sh "$@"
                ;;
            "fix"|"checker")
                ./scripts/99-error-checker.sh "$@"
                ;;
            *)
                echo "❌ 未知系统工具命令: $SUB_CMD"
                echo "可用命令: val/validate, fix/checker"
                ;;
        esac
        ;;
    "fv")
        # 流程可视化命令
        ./scripts/flow-visualizer.sh "$@"
        ;;
    "workflow"|"w")
        # 工作流命令
        ./scripts/11-unified-workflow.sh "$@"
        ;;
    "full"|"f")
        # 完整工作流命令
        ./scripts/09-full-workflow.sh "$@"
        ;;
    "a")
        # 逐章累积分析命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "init")
                ./scripts/25-chapter-by-chapter-analyzer.sh init "$@"
                ;;
            "analyze")
                ./scripts/25-chapter-by-chapter-analyzer.sh analyze "$@"
                ;;
            "view")
                ./scripts/25-chapter-by-chapter-analyzer.sh view "$@"
                ;;
            "export")
                ./scripts/25-chapter-by-chapter-analyzer.sh export "$@"
                ;;
            *)
                echo "❌ 未知逐章分析命令: $SUB_CMD"
                echo "可用命令: init, analyze, view, export"
                ;;
        esac
        ;;
    "n")
        # 小说分割命令
        SUB_CMD="$1"
        shift
        case "$SUB_CMD" in
            "split")
                ./scripts/26-novel-splitter.sh split "$@"
                ;;
            "analyze-split")
                ./scripts/26-novel-splitter.sh analyze "$@"
                ;;
            "full-split")
                ./scripts/26-novel-splitter.sh full "$@"
                ;;
            *)
                echo "❌ 未知小说分割命令: $SUB_CMD"
                echo "可用命令: split, analyze-split, full-split"
                ;;
        esac
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ 未知主命令: $MAIN_CMD"
        echo ""
        echo "可用主命令:"
        echo "  p   - 项目管理 (init, outline, create, check, compress)"
        echo "  s   - 拆书分析 (analyze, swap, rewrite, full)"
        echo "  x   - 沙盒创作 (init, sbox, expand, complete, analyze)"
        echo "  e   - 增强功能 (cont, revise, opt, analyze, expand)"
        echo "  n   - NovelWriter (md, html, compile, analyze, scenes)"
        echo "  na  - NovelWriter高级 (wc, stats, pov, dial, read, timeline, char, cons)"
        echo "  l   - LexicraftAI (vocab, freq, syn, style, sent, read, gen, exp, ctx, prose)"
        echo "  sys - 系统工具 (val, fix)"
        echo "  fv  - 流程可视化"
        echo "  w   - 工作流"
        echo "  f   - 完整工作流"
        echo "  help - 显示此帮助"
        ;;
esac