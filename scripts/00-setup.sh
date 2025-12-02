#!/bin/bash
# scripts/00-setup.sh - 环境设置和依赖安装脚本

set -e

echo "🔧 开始设置超长篇小说AI创作系统 v16.0..."

# 检查Node.js
echo "🧱 检查Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "  ✅ Node.js $NODE_VERSION 已安装"
    
    # 检查版本是否满足要求
    if [[ $(node -v | sed 's/v//; s/\..*//') -ge 20 ]]; then
        echo "  ✅ Node.js 版本满足要求 (≥ 20.0)"
    else
        echo "  ❌ Node.js 版本过低，需要 ≥ 20.0"
        exit 1
    fi
else
    echo "  ❌ Node.js 未安装"
    echo "  请先安装Node.js (版本 ≥ 20.0)"
    exit 1
fi

# 检查Qwen CLI
echo "🤖 检查Qwen CLI..."
if command -v qwen &> /dev/null; then
    echo "  ✅ Qwen CLI 已安装"
else
    echo "  ⚠️ Qwen CLI 未安装，正在安装..."
    npm install -g @qwen-code/qwen-code@latest
    
    if command -v qwen &> /dev/null; then
        echo "  ✅ Qwen CLI 安装成功"
    else
        echo "  ❌ Qwen CLI 安装失败"
        exit 1
    fi
fi

# 设置Qwen认证
echo "🔑 检查Qwen认证..."
if [ ! -f "$HOME/.qwen/token" ]; then
    echo "  Qwen CLI 未认证"
    echo "  请运行 'qwen auth' 进行认证"
    echo "  推荐使用 Qwen OAuth 授权，每天2000次免费请求"
else
    echo "  ✅ Qwen CLI 已认证"
fi

# 检查必要目录
echo "📂 创建必要目录..."
DIRECTORIES=(
    "projects"
    "chapters"
    "summaries"
    "settings"
    "scripts/utils"
    "prompts/outline"
    "prompts/chapter"
    "prompts/character"
    "prompts/worldview"
    "templates"
    "tools"
    "config"
    "exports"
    "novelwriter-export"
    "lexicons"
)

for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "  创建目录: $dir"
    fi
done

# 检查配置文件
echo "⚙️  检查配置文件..."
CONFIG_FILES=(
    "config/qwen-settings.json"
    "config/novel-template.json"
    "config/prompt-library.json"
    "config/lexicraft-config.json"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "  ⚠️ $file 不存在，创建默认配置"
        case $file in
            "config/qwen-settings.json")
                cat > "$file" << 'EOF'
{
  "sessionTokenLimit": 32000,
  "tokenSafetyMargin": 7000,
  "experimental": {
    "vlmSwitchMode": "once",
    "visionModelPreview": false
  },
  "novel": {
    "autoSave": true,
    "autoBackup": true,
    "backupInterval": 10,
    "compressionThreshold": 25000,
    "maxChapterLength": 3000,
    "summaryChunkSize": 4000,
    "autoCompressInterval": 5
  },
  "revision": {
    "splitBook": {
      "analysisDepth": "detailed",
      "outputFormat": "markdown",
      "includeSuggestions": true
    },
    "styleEngineering": {
      "preservePlot": true,
      "maintainWordCount": true,
      "styleGuidePath": "./config/style-guides/"
    },
    "revisionProcess": {
      "phases": ["analysis", "planning", "implementation"],
      "backupOnModify": true,
      "validationRequired": true
    }
  },
  "api": {
    "timeout": 120000,
    "retryAttempts": 3,
    "retryDelay": 1000
  },
  "qwenCoderCLI": {
    "enhancedMode": true,
    "autoTokenManagement": true,
    "batchSize": 5,
    "pauseBetweenBatches": 15,
    "interactiveMode": {
      "enableColorOutput": true,
      "showProgress": true,
      "confirmMajorActions": true
    }
  },
  "lexicraftAI": {
    "vocabularyAnalysis": {
      "minWordLength": 2,
      "minFrequency": 3,
      "maxVocabularySuggestions": 50,
      "enableSynonymReplacement": true
    },
    "styleAnalysis": {
      "maxSentenceLength": 50,
      "minDialogueRatio": 10,
      "maxDescriptiveRatio": 5,
      "maxToneWordRatio": 3
    }
  }
}
EOF
                ;;
            "config/novel-template.json")
                cat > "$file" << 'EOF'
{
  "template": {
    "title": "{{NOVEL_TITLE}}",
    "author": "{{AUTHOR_NAME}}",
    "genre": "{{GENRE}}",
    "chapterCount": "{{CHAPTER_COUNT}}",
    "wordCountPerChapter": 3000,
    "characterCards": [],
    "worldview": {},
    "powerSystem": {},
    "foreshadows": []
  }
}
EOF
                ;;
            "config/prompt-library.json")
                cat > "$file" << 'EOF'
{
  "prompts": {
    "outline": {
      "detailed-outline": "./prompts/outline/detailed-outline.txt"
    },
    "chapter": {
      "mid-chapter": "./prompts/chapter/mid-chapter.txt"
    },
    "character": {
      "character-profile": "./prompts/character/character-profile.txt"
    },
    "worldview": {
      "worldview-setting": "./prompts/worldview/worldview-setting.txt"
    }
  }
}
EOF
                ;;
            "config/lexicraft-config.json")
                cat > "$file" << 'EOF'
{
  "lexicraftAI": {
    "vocabularyAnalysis": {
      "minWordLength": 2,
      "minFrequency": 3,
      "maxVocabularySuggestions": 50,
      "enableSynonymReplacement": true
    },
    "styleAnalysis": {
      "maxSentenceLength": 50,
      "minDialogueRatio": 10,
      "maxDescriptiveRatio": 5,
      "maxToneWordRatio": 3
    },
    "sentimentAnalysis": {
      "positiveWords": ["好", "美", "爱", "快乐", "幸福", "喜悦", "温暖", "阳光", "希望", "美好", "善良", "优美", "开心", "愉快"],
      "negativeWords": ["坏", "恨", "痛苦", "悲伤", "绝望", "黑暗", "恐惧", "害怕", "仇恨", "沮丧", "愤怒", "恶劣", "讨厌", "伤心"],
      "emotionIntensityThreshold": 7
    },
    "readabilityOptimization": {
      "simplifyComplexSentences": true,
      "replaceDifficultWords": true,
      "improveParagraphStructure": true,
      "enhanceClarity": true
    },
    "proseEnhancement": {
      "addImagery": true,
      "useRhetoricalDevices": true,
      "optimizeRhythm": true,
      "enhanceVisualization": true,
      "increaseImpact": true
    },
    "contextOptimization": {
      "improveTransitions": true,
      "enhanceContinuity": true,
      "maintainOriginalMeaning": true,
      "prepareForNextChapter": true
    }
  }
}
EOF
                ;;
        esac
    fi
done

# 设置脚本权限
echo "🔒 设置脚本权限..."
find scripts -name "*.sh" -exec chmod +x {} \;
find tools -name "*.py" -exec chmod +x {} \;

# 运行项目验证
echo "✅ 运行项目验证..."
./scripts/98-project-validator.sh

echo "🎉 环境设置完成！"
echo ""
echo "📝 接下来您可以："
echo "   1. 运行 './scripts/11-unified-workflow.sh -i' 开始新项目"
echo "   2. 运行 'node tools/diagnostic.js' 进行环境诊断"
echo "   3. 查看 README.md 获取详细使用说明"