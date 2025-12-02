#!/bin/bash
# scripts/flow-visualizer.sh - 小说生成流程可视化脚本

set -e

show_flow() {
    echo "🎨 超长篇小说AI创作系统 v16.0 - 生成流程可视化"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────────────┐"
    echo "│                        📘 项目初始化 (01-init-project.sh)                 │"
    echo "│  📁 创建目录结构  │  📄 生成配置文件  │  ⚙️ 设置项目参数                   │"
    echo "└─────────────────────────────────────────────────────────────────────────┘"
    echo "                                    │"
    echo "                                    ▼"
    echo "┌─────────────────────────────────────────────────────────────────────────┐"
    echo "│                        📋 大纲生成 (02-create-outline.sh)                 │"
    echo "│  👤 用户输入  │  🤖 Qwen生成  │  💾 保存大纲到outline.md                   │"
    echo "└─────────────────────────────────────────────────────────────────────────┘"
    echo "                                    │"
    echo "                                    ▼"
    echo "┌─────────────────────────────────────────────────────────────────────────┐"
    echo "│                      ✍️  章节创作 (03-batch-create.sh)                    │"
    echo "│  📚 读取设定  │  🧩 构建提示词  │  🤖 Qwen生成  │  💾 保存章节  │  🗜️ 会话压缩 │"
    echo "└─────────────────────────────────────────────────────────────────────────┘"
    echo "                                    │"
    echo "                                    ▼"
    echo "┌─────────────────────────────────────────────────────────────────────────┐"
    echo "│                      ✅ 质量控制 (04-quality-check.sh)                    │"
    echo "│  🔄 连续性检查  │  👥 人物一致性  │  📖 情节逻辑  │  📊 生成报告            │"
    echo "└─────────────────────────────────────────────────────────────────────────┘"
    echo "                                    │"
    echo "                                    ▼"
    echo "┌─────────────────────────────────────────────────────────────────────────┐"
    echo "│                       🔧 后期优化 (增强套件等)                            │"
    echo "│  ➕ 续写章节  │  ✏️ 修改章节  │  🌟 优化内容  │  📊 分析统计  │  📝 词汇管理    │"
    echo "└─────────────────────────────────────────────────────────────────────────┘"
    echo "                                    │"
    echo "                                    ▼"
    echo "┌─────────────────────────────────────────────────────────────────────────┐"
    echo "│                      📤 导出与分析 (导出工具)                            │"
    echo "│  📝 Markdown  │  🌐 HTML  │  📚 NovelWriter  │  📖 完整书籍编译          │"
    echo "└─────────────────────────────────────────────────────────────────────────┘"
    echo ""
    echo "🔧 Token管理策略:"
    echo "   • 限制: 32000 tokens (Qwen CLI)"
    echo "   • 安全阈值: 25000 tokens (保留20%余量)"
    echo "   • 中文: 1字≈1.5 tokens"
    echo "   • 英文: 1词≈1.3 tokens"
    echo ""
    echo "🔄 会话工程优化:"
    echo "   • 每5章自动压缩会话历史"
    echo "   • 上下文构建策略:"
    echo "     - 核心设定 (永久保留，≈2000 tokens)"
    echo "     - 近期情节 (最近5章，≈3000 tokens)"
    echo "     - 历史总结 (压缩版，≈2000 tokens)"
    echo "     - 记忆提醒 (≈1000 tokens)"
    echo "     - 前情提要 (≈500 tokens)"
    echo "   • 总计约8500 tokens，远低于32000限制"
    echo ""
}

show_commands() {
    echo "🚀 快速开始命令:"
    echo ""
    echo "方法1: 一键交互式创作 (推荐)"
    echo "   ./scripts/11-unified-workflow.sh -i"
    echo ""
    echo "方法2: 一键自动创作"
    echo "   ./scripts/11-unified-workflow.sh -a \"我的玄幻小说\" 100 \"玄幻\" \"林轩\" \"废材逆袭\""
    echo ""
    echo "方法3: 分步创作"
    echo "   # 步骤1: 初始化项目"
    echo "   ./scripts/01-init-project.sh \"我的玄幻小说\" 100"
    echo ""
    echo "   # 步骤2: 生成大纲 (按提示输入类型/主角/冲突)"
    echo "   ./scripts/02-create-outline.sh \"./projects/我的玄幻小说\" 100"
    echo ""
    echo "   # 步骤3: 批量创作章节 (推荐分批进行)"
    echo "   ./scripts/03-batch-create.sh \"./projects/我的玄幻小说\" 1 20    # 第1批"
    echo "   ./scripts/03-batch-create.sh \"./projects/我的玄幻小说\" 21 40   # 第2批"
    echo "   ./scripts/03-batch-create.sh \"./projects/我的玄幻小说\" 41 60   # 第3批"
    echo "   # ... 继续直到完成"
    echo ""
    echo "   # 步骤4: 质量检查"
    echo "   ./scripts/04-quality-check.sh \"./projects/我的玄幻小说\""
    echo ""
}

case $1 in
    "commands"|"-c"|"--commands")
        show_commands
        ;;
    "flow"|"-f"|"--flow"|*)
        show_flow
        show_commands
        ;;
esac