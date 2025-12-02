# scripts/20-sandbox-creation.ps1 - 沙盒创作法专用PowerShell脚本
# 基于沙盒创作法的分阶段小说生成流程

# 检查PowerShell版本
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "❌ 此脚本需要PowerShell 3.0或更高版本" -ForegroundColor Red
    exit 1
}

function Show-Help {
    Write-Host "🏰 沙盒创作法专用PowerShell脚本" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "用法: .\20-sandbox-creation.ps1 <命令> [参数]"
    Write-Host ""
    Write-Host "可用命令:"
    Write-Host "  init      <项目名> <章节数> [类型]  初始化沙盒项目"
    Write-Host "  sandbox   <项目路径>              沙盒阶段创作（前10章）"
    Write-Host "  expand    <项目路径> <开始章> <结束章> 扩展阶段创作"
    Write-Host "  complete  <项目路径>              完成整个创作流程"
    Write-Host "  analyze   <项目路径>              分析项目完整性"
    Write-Host "  help                              显示此帮助信息"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  .\20-sandbox-creation.ps1 init `"我的玄幻小说`" 100 `"玄幻`""
    Write-Host "  .\20-sandbox-creation.ps1 sandbox `"./projects/我的玄幻小说`""
    Write-Host "  .\20-sandbox-creation.ps1 expand `"./projects/我的玄幻小说`" 11 30"
    Write-Host "  .\20-sandbox-creation.ps1 complete `"./projects/我的玄幻小说`""
}

function Initialize-SandboxProject {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectName,
        [Parameter(Mandatory=$true)][int]$ChapterCount,
        [string]$Genre = "小说"
    )

    if ([string]::IsNullOrEmpty($ProjectName) -or $ChapterCount -le 0) {
        Write-Host "❌ 项目名和章节数为必填项" -ForegroundColor Red
        exit 1
    }

    Write-Host "🏰 初始化沙盒项目: $ProjectName ($ChapterCount章, $Genre类型)" -ForegroundColor Green
    
    # 调用初始化脚本
    $initScript = Join-Path $PSScriptRoot "01-init-project.sh"
    if (Test-Path $initScript) {
        # 在PowerShell中调用bash脚本（如果可用）
        try {
            $result = bash $initScript $ProjectName $ChapterCount 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ 无法运行初始化脚本，可能需要安装Git Bash或WSL" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ bash命令不可用，请安装Git Bash或WSL" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ 找不到初始化脚本: $initScript" -ForegroundColor Red
    }
    
    $projectPath = Join-Path ".." "projects" $ProjectName
    
    Write-Host "📝 请完善以下设定文件:" -ForegroundColor Cyan
    Write-Host "  - $projectPath\settings\worldview.json (世界观)"
    Write-Host "  - $projectPath\settings\power-system.json (力量体系)"
    Write-Host "  - $projectPath\settings\characters.json (角色档案)"
    Write-Host ""
    Write-Host "💡 提示: 可以参考 examples\ 目录下的示例项目" -ForegroundColor Yellow
}

function Start-SandboxPhase {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath
    )

    if (!(Test-Path $ProjectPath)) {
        Write-Host "❌ 项目路径不存在: $ProjectPath" -ForegroundColor Red
        exit 1
    }

    Write-Host "🔍 沙盒阶段创作: $ProjectPath (第1-10章)" -ForegroundColor Green
    Write-Host "此阶段将创建一个封闭环境，验证核心设定和人物关系" -ForegroundColor Yellow
    
    # 检查设定文件
    Write-Host "✅ 检查设定文件..." -ForegroundColor Green
    $settingsDir = Join-Path $ProjectPath "settings"
    
    $worldviewPath = Join-Path $settingsDir "worldview.json"
    if (!(Test-Path $worldviewPath)) {
        Write-Host "⚠️  未找到世界观设定文件，使用默认设定" -ForegroundColor Yellow
        $defaultWorldview = @{
            setting = "默认世界"
            rules = @{}
            cultures = @()
            geography = ""
            history = ""
            magicSystem = @{}
            technologyLevel = ""
            socialStructure = ""
        } | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($worldviewPath, $defaultWorldview, [System.Text.Encoding]::UTF8)
    }
    
    $charactersPath = Join-Path $settingsDir "characters.json"
    if (!(Test-Path $charactersPath)) {
        Write-Host "⚠️  未找到角色设定文件，使用默认设定" -ForegroundColor Yellow
        $defaultCharacters = @{
            protagonist = @{
                name = ""
                description = ""
                personality = ""
                abilities = @()
                development = @()
                characterArc = @()
            }
            supporting = @()
            antagonists = @()
        } | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($charactersPath, $defaultCharacters, [System.Text.Encoding]::UTF8)
    }
    
    # 调用批量创作脚本
    $batchScript = Join-Path $PSScriptRoot "03-batch-create.sh"
    if (Test-Path $batchScript) {
        try {
            $result = bash $batchScript $ProjectPath 1 10 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ 无法运行批量创作脚本，可能需要安装Git Bash或WSL" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ bash命令不可用，请安装Git Bash或WSL" -ForegroundColor Red
        }
    }
    
    Write-Host "✅ 沙盒阶段完成！请评估:" -ForegroundColor Green
    Write-Host "  - 设定是否一致？"
    Write-Host "  - 人物是否生动？"
    Write-Host "  - 情节是否有吸引力？"
    Write-Host ""
    Write-Host "如需调整，可修改 settings\ 目录下的设定文件，然后继续扩展阶段" -ForegroundColor Yellow
}

function Start-ExpandPhase {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath,
        [Parameter(Mandatory=$true)][int]$StartChapter,
        [Parameter(Mandatory=$true)][int]$EndChapter
    )

    if (!(Test-Path $ProjectPath)) {
        Write-Host "❌ 项目路径不存在: $ProjectPath" -ForegroundColor Red
        exit 1
    }

    Write-Host "🚀 扩展阶段创作: $ProjectPath (第$StartChapter-$EndChapter章)" -ForegroundColor Green
    Write-Host "此阶段将逐步扩大世界观，深化情节发展" -ForegroundColor Yellow
    
    $batchScript = Join-Path $PSScriptRoot "03-batch-create.sh"
    if (Test-Path $batchScript) {
        try {
            $result = bash $batchScript $ProjectPath $StartChapter $EndChapter 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ 无法运行批量创作脚本，可能需要安装Git Bash或WSL" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ bash命令不可用，请安装Git Bash或WSL" -ForegroundColor Red
        }
    }
    
    Write-Host "✅ 扩展阶段完成！" -ForegroundColor Green
}

function Complete-CreationFlow {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath
    )

    if (!(Test-Path $ProjectPath)) {
        Write-Host "❌ 项目路径不存在: $ProjectPath" -ForegroundColor Red
        exit 1
    }

    Write-Host "🎊 完整创作流程: $ProjectPath" -ForegroundColor Green
    
    # 检查是否有第1-10章
    $chapterFiles = Get-ChildItem -Path (Join-Path $ProjectPath "chapters") -Filter "chapter_001_*" -ErrorAction SilentlyContinue
    $chapter10Files = Get-ChildItem -Path (Join-Path $ProjectPath "chapters") -Filter "chapter_010_*" -ErrorAction SilentlyContinue
    
    if ($chapterFiles -and $chapter10Files) {
        Write-Host "✅ 检测到沙盒章节，跳过沙盒阶段" -ForegroundColor Green
    } else {
        Write-Host "🔍 执行沙盒阶段 (第1-10章)..." -ForegroundColor Cyan
        Start-SandboxPhase $ProjectPath
    }
    
    # 读取元数据以确定总章节数
    $metadataFile = Join-Path $ProjectPath "metadata.json"
    if (Test-Path $metadataFile) {
        try {
            $metadata = Get-Content $metadataFile -Raw | ConvertFrom-Json
            $totalChapters = $metadata.chapterCount
            $currentChapter = if ($metadata.PSObject.Properties.Name -contains "currentChapter") { $metadata.currentChapter } else { 0 }
            
            if ($currentChapter -lt 10) {
                $startExpand = 11
            } else {
                $startExpand = $currentChapter + 1
            }
        }
        catch {
            Write-Host "⚠️  无法读取元数据文件，假设有100章" -ForegroundColor Yellow
            $totalChapters = 100
            $startExpand = 11
        }
    } else {
        Write-Host "⚠️  未找到元数据文件，假设有100章" -ForegroundColor Yellow
        $totalChapters = 100
        $startExpand = 11
    }
    
    if ($startExpand -le $totalChapters) {
        Write-Host "🚀 执行扩展阶段 (第${startExpand}-${totalChapters}章)..." -ForegroundColor Cyan
        
        # 分批进行，每批20章
        $current = $startExpand
        while ($current -le $totalChapters) {
            $endBatch = [Math]::Min($current + 19, $totalChapters)
            
            Write-Host "  创作第$current-$endBatch章..." -ForegroundColor Cyan
            Start-ExpandPhase $ProjectPath $current $endBatch
            
            $current = $endBatch + 1
            
            # 每批完成后暂停一下
            if ($current -le $totalChapters) {
                Write-Host "  暂停10秒..." -ForegroundColor Yellow
                Start-Sleep -Seconds 10
            }
        }
    }
    
    # 质量检查
    Write-Host "✅ 执行最终质量检查..." -ForegroundColor Green
    $qualityScript = Join-Path $PSScriptRoot "04-quality-check.sh"
    if (Test-Path $qualityScript) {
        try {
            $result = bash $qualityScript $ProjectPath 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ 无法运行质量检查脚本，可能需要安装Git Bash或WSL" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ bash命令不可用，请安装Git Bash或WSL" -ForegroundColor Red
        }
    }
    
    # 生成项目总结
    $summaryFile = Join-Path $ProjectPath "final-summary.md"
    $summaryContent = @"
# 《$(Split-Path $ProjectPath -Leaf)》创作总结

## 项目信息
- 项目名称: $(Split-Path $ProjectPath -Leaf)
- 总章节数: $totalChapters
- 完成时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
- 采用方法: 沙盒创作法

## 创作阶段
1. 沙盒阶段: 1-10章 (核心设定验证)
2. 扩展阶段: ${startExpand}-${totalChapters}章 (世界观扩大)

## 项目统计
- 总字数: $(Get-ChildItem -Path (Join-Path $ProjectPath "chapters") -Filter "*.md" -Recurse | ForEach-Object { (Get-Content $_.FullName -Raw) } | ForEach-Object { ($_ -split '\s+' | Where-Object { $_ -match '\S' }).Count } | Measure-Object -Sum).Sum 字
- 章节数: $(Get-ChildItem -Path (Join-Path $ProjectPath "chapters") -Filter "chapter_*.md" -Recurse | Measure-Object | Select-Object -ExpandProperty Count)

## 项目结构
$(try { tree $ProjectPath 2>$null } catch { "tree命令不可用" })

"@
    
    [System.IO.File]::WriteAllText($summaryFile, $summaryContent, [System.Text.Encoding]::UTF8)

    Write-Host "🎊 项目完成！总结文件: $summaryFile" -ForegroundColor Green
}

function Analyze-Project {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectPath
    )

    if (!(Test-Path $ProjectPath)) {
        Write-Host "❌ 项目路径不存在: $ProjectPath" -ForegroundColor Red
        exit 1
    }

    Write-Host "🔬 分析项目完整性: $ProjectPath" -ForegroundColor Yellow
    Write-Host ""
    
    # 检查设定文件
    Write-Host "📋 设定文件检查:" -ForegroundColor Cyan
    $settingsDir = Join-Path $ProjectPath "settings"
    if (Test-Path $settingsDir) {
        Get-ChildItem -Path $settingsDir -Filter "*.json" | ForEach-Object {
            Write-Host "  ✅ $($_.Name)"
        }
    } else {
        Write-Host "  ❌ 未找到设定目录"
    }
    
    # 检查章节文件
    Write-Host ""
    Write-Host "📖 章节文件检查:" -ForegroundColor Cyan
    $chaptersDir = Join-Path $ProjectPath "chapters"
    if (Test-Path $chaptersDir) {
        $chapterFiles = Get-ChildItem -Path $chaptersDir -Filter "chapter_*.md" -Recurse
        $totalChapters = $chapterFiles.Count
        Write-Host "  ✅ 总章节数: $totalChapters"
        
        # 检查连续性
        if ($totalChapters -gt 0) {
            $chapterNumbers = $chapterFiles | ForEach-Object { [int]($_.Name -replace 'chapter_(\d+)_.*', '$1') } | Sort-Object
            $lastChapter = $chapterNumbers | Select-Object -Last 1
            Write-Host "  ✅ 最后一章: $lastChapter"
        }
    } else {
        Write-Host "  ❌ 未找到章节目录"
    }
    
    Write-Host ""
    Write-Host "📊 项目分析完成" -ForegroundColor Green
}

# 主逻辑
param(
    [Parameter(Mandatory=$true, Position=0)][string]$Command,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments
)

switch ($Command) {
    "init" {
        if ($Arguments.Count -lt 2) {
            Write-Host "❌ init命令需要提供: 项目名 章节数 [类型]" -ForegroundColor Red
            exit 1
        }
        Initialize-SandboxProject -ProjectName $Arguments[0] -ChapterCount ([int]$Arguments[1]) -Genre $Arguments[2]
    }
    "sandbox" {
        if ($Arguments.Count -lt 1) {
            Write-Host "❌ sandbox命令需要提供: 项目路径" -ForegroundColor Red
            exit 1
        }
        Start-SandboxPhase -ProjectPath $Arguments[0]
    }
    "expand" {
        if ($Arguments.Count -lt 3) {
            Write-Host "❌ expand命令需要提供: 项目路径 开始章 结束章" -ForegroundColor Red
            exit 1
        }
        Start-ExpandPhase -ProjectPath $Arguments[0] -StartChapter ([int]$Arguments[1]) -EndChapter ([int]$Arguments[2])
    }
    "complete" {
        if ($Arguments.Count -lt 1) {
            Write-Host "❌ complete命令需要提供: 项目路径" -ForegroundColor Red
            exit 1
        }
        Complete-CreationFlow -ProjectPath $Arguments[0]
    }
    "analyze" {
        if ($Arguments.Count -lt 1) {
            Write-Host "❌ analyze命令需要提供: 项目路径" -ForegroundColor Red
            exit 1
        }
        Analyze-Project -ProjectPath $Arguments[0]
    }
    "help" {
        Show-Help
    }
    Default {
        Write-Host "❌ 未知命令: $Command" -ForegroundColor Red
        Show-Help
        exit 1
    }
}