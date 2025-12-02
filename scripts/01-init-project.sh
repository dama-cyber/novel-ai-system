#!/bin/bash
# scripts/01-init-project.sh - 初始化项目

set -e

PROJECT_NAME=$1
CHAPTER_COUNT=$2

if [ -z "$PROJECT_NAME" ] || [ -z "$CHAPTER_COUNT" ]; then
    echo "用法: $0 <项目名称> <章节数>"
    echo "例如: $0 \"我的玄幻小说\" 100"
    exit 1
fi

# 创建项目目录
PROJECT_DIR="./projects/$PROJECT_NAME"
mkdir -p "$PROJECT_DIR"

# 创建子目录
mkdir -p "$PROJECT_DIR/chapters"
mkdir -p "$PROJECT_DIR/summaries"
mkdir -p "$PROJECT_DIR/settings"
mkdir -p "$PROJECT_DIR/logs"

# 创建基本配置文件
cat > "$PROJECT_DIR/settings/characters.json" << EOF
{
  "protagonist": {
    "name": "",
    "description": "",
    "personality": "",
    "abilities": [],
    "development": [],
    "characterArc": []
  },
  "supporting": [],
  "antagonists": []
}
EOF

cat > "$PROJECT_DIR/settings/worldview.json" << EOF
{
  "setting": "",
  "rules": {},
  "cultures": [],
  "geography": "",
  "history": "",
  "magicSystem": {},
  "technologyLevel": "",
  "socialStructure": ""
}
EOF

cat > "$PROJECT_DIR/settings/power-system.json" << EOF
{
  "name": "",
  "levels": [],
  "requirements": "",
  "limitations": "",
  "acquisitionMethod": "",
  "trainingProcess": "",
  "powerSources": []
}
EOF

cat > "$PROJECT_DIR/settings/foreshadows.json" << EOF
{
  "active": [],
  "resolved": [],
  "planned": [],
  "plotThreads": []
}
EOF

# 创建项目元数据文件
cat > "$PROJECT_DIR/metadata.json" << EOF
{
  "title": "$PROJECT_NAME",
  "chapterCount": $CHAPTER_COUNT,
  "createdAt": "$(date -Iseconds)",
  "lastModified": "$(date -Iseconds)",
  "status": "initialized",
  "currentChapter": 0,
  "totalWords": 0
}
EOF

# 初始化Git仓库
cd "$PROJECT_DIR"
git init
git add .
git commit -m "Initial commit: Project setup with $CHAPTER_COUNT chapters"

echo "✅ 项目已创建: $PROJECT_DIR"
echo "✅ 目录结构已生成"
echo "✅ 配置文件已创建"
echo "✅ 项目元数据已生成"
echo "✅ Git仓库已初始化"