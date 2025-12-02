# scripts/26-novel-splitter.ps1 - 小说分割工具 (PowerShell版)
# 将整本小说按章节分割成独立文件，然后可以进行逐章分析

param(
    [Parameter(Mandatory=$true, Position=0)][string]$Command,
    [Parameter(Position=1)][string]$Param1,
    [Parameter(Position=2)][string]$Param2,
    [Parameter(Position=3)][string]$Param3
)

# 显示帮助
function Show-Help {
    Write-Host "✂️  小说分割工具 (PowerShell版)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "用法: .\26-novel-splitter.ps1 <命令> [参数]"
    Write-Host ""
    Write-Host "可用命令:" -ForegroundColor Yellow
    Write-Host "  split    <整本小说文件> <输出目录> [项目名]  按章节分割整本小说" -ForegroundColor White
    Write-Host "  analyze  <项目路径> <起始章> <结束章>      对分割后的章节进行逐章分析" -ForegroundColor White
    Write-Host "  full     <整本小说文件> <输出目录> [项目名]  完整流程（分割+分析）" -ForegroundColor White
    Write-Host "  help                                    显示此帮助信息" -ForegroundColor White
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Green
    Write-Host "  .\26-novel-splitter.ps1 split `"novel.txt`" `"./projects/我的小说`" `"我的玄幻小说`"" -ForegroundColor White
    Write-Host "  .\26-novel-splitter.ps1 analyze `"./projects/我的小说`" 1 10" -ForegroundColor White
    Write-Host "  .\26-novel-splitter.ps1 full `"novel.txt`" `"./projects/我的小说`" `"我的玄幻小说`"" -ForegroundColor White
}

# 按章节分割整本小说
function Split-Novel {
    param(
        [string]$NovelFile,
        [string]$OutputDir,
        [string]$ProjectName = "未命名小说"
    )
    
    if (!(Test-Path $NovelFile)) {
        Write-Host "❌ 小说文件不存在: $NovelFile" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✂️  开始分割小说: $NovelFile" -ForegroundColor Cyan
    
    # 创建输出目录
    $chaptersDir = Join-Path $OutputDir "chapters"
    $settingsDir = Join-Path $OutputDir "settings"
    $metadataFile = Join-Path $OutputDir "metadata.json"
    
    if (!(Test-Path $chaptersDir)) {
        New-Item -ItemType Directory -Path $chaptersDir -Force
    }
    if (!(Test-Path $settingsDir)) {
        New-Item -ItemType Directory -Path $settingsDir -Force
    }
    
    # 初始化项目元数据
    $metadata = @{
        title = $ProjectName
        totalChapters = 0
        created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        status = "splitting"
    }
    $metadata | ConvertTo-Json | Out-File -FilePath $metadataFile -Encoding UTF8
    
    Write-Host "🔍 尝试使用不同模式分割章节..." -ForegroundColor Yellow
    
    # 读取小说内容
    $content = Get-Content $NovelFile -Raw
    
    # 使用正则表达式分割章节（匹配"第X章"、"第X节"等）
    $chapterRegex = [regex]"(?m)^第[0-9一二三四五六七八九十百千万零\s]+[章节回部节].*$"
    
    $matches = $chapterRegex.Matches($content)
    $chapterCount = 0
    $startIndex = 0
    
    foreach ($match in $matches) {
        $currentPos = $match.Index
        $chapterContent = $content.Substring($startIndex, $currentPos - $startIndex)
        
        if ($chapterContent.Trim() -ne "") {
            $chapterCount++
            $formattedChapter = $chapterCount.ToString("D3")
            $chapterTitle = $match.Value.Trim()
            
            # 生成文件名（只保留合法字符）
            $cleanTitle = $chapterTitle -replace '[^\w\u4e00-\u9fa5]', '_'
            $chapterFile = Join-Path $chaptersDir "chapter_${formattedChapter}_${cleanTitle}.md"
            
            # 创建章节文件（包含Markdown结构）
            $chapterContentFormatted = @"
# $chapterTitle

## 概要
待AI生成

## 正文

$chapterContent

---
**下一章预告**: 待定

**字数统计**: $(($chapterContent -split '\s+' | Where-Object { $_ -ne "" }).Count) 字
"@
            
            $chapterContentFormatted | Out-File -FilePath $chapterFile -Encoding UTF8
            
            Write-Host "  发现并保存章节: $chapterTitle (第${chapterCount}章)" -ForegroundColor Green
        }
        
        $startIndex = $currentPos
    }
    
    # 处理最后一章（如果文件末尾不是章节标题）
    if ($startIndex -lt $content.Length) {
        $remainingContent = $content.Substring($startIndex)
        if ($remainingContent.Trim() -ne "") {
            $chapterCount++
            $formattedChapter = $chapterCount.ToString("D3")
            $chapterTitle = "第${chapterCount}章 未命名章节"
            $chapterFile = Join-Path $chaptersDir "chapter_${formattedChapter}_第${chapterCount}章.md"
            
            $chapterContentFormatted = @"
# $chapterTitle

## 概要
待AI生成

## 正文

$remainingContent

---
**下一章预告**: 待定

**字数统计**: $(($remainingContent -split '\s+' | Where-Object { $_ -ne "" }).Count) 字
"@
            
            $chapterContentFormatted | Out-File -FilePath $chapterFile -Encoding UTF8
            
            Write-Host "  保存最后一章: $chapterTitle (第${chapterCount}章)" -ForegroundColor Green
        }
    }
    
    # 更新元数据
    $updatedMetadata = @{
        title = $ProjectName
        totalChapters = $chapterCount
        created = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        status = "split_complete"
        sourceFile = (Split-Path $NovelFile -Leaf)
    }
    $updatedMetadata | ConvertTo-Json | Out-File -FilePath $metadataFile -Encoding UTF8
    
    Write-Host "✅ 小说分割完成！" -ForegroundColor Green
    Write-Host "📁 章节文件已保存至: $chaptersDir" -ForegroundColor Yellow
    Write-Host "📊 共分割出: $chapterCount 章" -ForegroundColor Yellow
}

# 对分割后的章节进行逐章分析
function Analyze-SplitChapters {
    param(
        [string]$ProjectDir,
        [int]$StartChapter,
        [int]$EndChapter
    )
    
    if (!(Test-Path $ProjectDir)) {
        Write-Host "❌ 项目目录不存在: $ProjectDir" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "🔍 开始逐章分析（第$StartChapter章到第$EndChapter章）..." -ForegroundColor Cyan
    
    $chaptersDir = Join-Path $ProjectDir "chapters"
    $chapterFiles = Get-ChildItem -Path $chaptersDir -Filter "chapter_*.md" | Sort-Object Name
    
    for ($i = $StartChapter; $i -le $EndChapter; $i++) {
        $formattedChapter = $i.ToString("D3")
        $chapterFile = $chapterFiles | Where-Object { $_.Name -match "^chapter_${formattedChapter}_" }
        
        if ($chapterFile) {
            Write-Host "  正在分析第$i章: $($chapterFile.Name)" -ForegroundColor Green
            
            # 使用逐章累积分析器处理此章节
            $scriptsDir = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts"
            $analyzerScript = Join-Path $scriptsDir "25-chapter-by-chapter-analyzer.sh"
            
            # 调用分析脚本
            & $analyzerScript analyze $ProjectDir $i $chapterFile.FullName 2>$null
        } else {
            Write-Host "  ⚠️  第$i章文件不存在" -ForegroundColor Yellow
        }
    }
    
    Write-Host "✅ 逐章分析完成！" -ForegroundColor Green
}

# 完整流程（分割+分析）
function Start-FullProcess {
    param(
        [string]$NovelFile,
        [string]$OutputDir,
        [string]$ProjectName = "未命名小说"
    )
    
    Write-Host "🔄 开始完整处理流程..." -ForegroundColor Cyan
    
    # 步骤1: 分割小说
    Split-Novel -NovelFile $NovelFile -OutputDir $OutputDir -ProjectName $ProjectName
    
    # 步骤2: 获取章节总数进行分析
    $metadataFile = Join-Path $OutputDir "metadata.json"
    if (Test-Path $metadataFile) {
        $metadata = Get-Content $metadataFile -Raw | ConvertFrom-Json
        $totalChapters = $metadata.totalChapters
        
        if ($totalChapters -gt 0) {
            Write-Host "📈 检测到 $totalChapters 章，开始分析..." -ForegroundColor Yellow
            Analyze-SplitChapters -ProjectDir $OutputDir -StartChapter 1 -EndChapter $totalChapters
        } else {
            Write-Host "⚠️  未检测到章节，跳过分析步骤" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  元数据文件不存在，跳过分析步骤" -ForegroundColor Yellow
    }
    
    Write-Host "✅ 完整处理流程完成！" -ForegroundColor Green
}

# 主逻辑
switch ($Command) {
    "split" {
        if (!$Param1 -or !$Param2) {
            Write-Host "❌ split命令需要提供: 小说文件 输出目录 [项目名]" -ForegroundColor Red
            exit 1
        }
        $projectName = if ($Param3) { $Param3 } else { "未命名小说" }
        Split-Novel -NovelFile $Param1 -OutputDir $Param2 -ProjectName $projectName
        break
    }
    
    "analyze" {
        if (!$Param1 -or !$Param2 -or !$Param3) {
            Write-Host "❌ analyze命令需要提供: 项目路径 起始章 结束章" -ForegroundColor Red
            exit 1
        }
        Analyze-SplitChapters -ProjectDir $Param1 -StartChapter ([int]$Param2) -EndChapter ([int]$Param3)
        break
    }
    
    "full" {
        if (!$Param1 -or !$Param2) {
            Write-Host "❌ full命令需要提供: 小说文件 输出目录 [项目名]" -ForegroundColor Red
            exit 1
        }
        $projectName = if ($Param3) { $Param3 } else { "未命名小说" }
        Start-FullProcess -NovelFile $Param1 -OutputDir $Param2 -ProjectName $projectName
        break
    }
    
    "help" {
        Show-Help
        break
    }
    
    default {
        Write-Host "❌ 未知命令: $Command" -ForegroundColor Red
        Show-Help
        exit 1
    }
}