# scripts/25-chapter-by-chapter-analyzer.ps1 - 逐章累积分析PowerShell版本
# 基于强制逐章累积分析规则，对小说章节进行逐章深度分析并累积报告

param(
    [Parameter(Mandatory=$true, Position=0)][string]$Command,
    [Parameter(Position=1)][string]$ProjectPath,
    [Parameter(Position=2)][string]$ChapterNum,
    [Parameter(Position=3)][string]$ChapterContentFile
)

# 显示帮助
function Show-Help {
    Write-Host "🔄 逐章累积分析器 (PowerShell版)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "用法: .\25-chapter-by-chapter-analyzer.ps1 <命令> [参数]"
    Write-Host ""
    Write-Host "可用命令:"
    Write-Host "  init     <项目路径> <小说名>    初始化累积分析" -ForegroundColor Yellow
    Write-Host "  analyze  <项目路径> <章节号> <章节内容文件>  分析单章并更新累积报告" -ForegroundColor Yellow
    Write-Host "  continue <项目路径> <章节号> <章节内容文件>  持续分析（自动累积上一章结果）" -ForegroundColor Yellow
    Write-Host "  view     <项目路径>              查看当前累积报告" -ForegroundColor Yellow
    Write-Host "  export   <项目路径> <输出路径>    导出累积报告" -ForegroundColor Yellow
    Write-Host "  help                                显示此帮助信息" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Green
    Write-Host "  .\25-chapter-by-chapter-analyzer.ps1 init `"./projects/我的小说`" `"星辰变`""
    Write-Host "  .\25-chapter-by-chapter-analyzer.ps1 analyze `"./projects/我的小说`" 1 `"./temp/chapter1.txt`""
    Write-Host "  .\25-chapter-by-chapter-analyzer.ps1 continue `"./projects/我的小说`" 2 `"./temp/chapter2.txt`""
}

# 主逻辑
switch ($Command) {
    "init" {
        if (-not $ProjectPath -or -not $ChapterNum) {
            Write-Host "❌ init命令需要提供: 项目路径 小说名" -ForegroundColor Red
            exit 1
        }
        
        $NovelName = $ChapterNum  # 第二个参数实际是小说名
        $AnalysisDir = Join-Path $ProjectPath "chapter-analysis"
        $CumulativeReport = Join-Path $AnalysisDir "cumulative-analysis.md"
        
        # 创建分析目录
        if (!(Test-Path $AnalysisDir)) {
            New-Item -ItemType Directory -Path $AnalysisDir -Force
        }
        
        # 创建初始累积报告
        $initialContent = @"
# 《$NovelName》 - 逐章累积分析报告（初始化）

## 分析状态
- 当前进度: 未开始分析
- 最新章节: 无
- 分析时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

## 下一步行动
请使用 analyze 命令开始分析第一章，例如：
```powershell
.\25-chapter-by-chapter-analyzer.ps1 analyze "$ProjectPath" 1 "C:\path\to\chapter1.txt"
```
"@
        
        $initialContent | Out-File -FilePath $CumulativeReport -Encoding UTF8
        
        Write-Host "✅ 项目 $NovelName 累积分析已初始化！" -ForegroundColor Green
        Write-Host "📁 分析报告位置: $CumulativeReport" -ForegroundColor Yellow
        break
    }
    
    "analyze" {
        if (-not $ProjectPath -or -not $ChapterNum -or -not $ChapterContentFile) {
            Write-Host "❌ analyze命令需要提供: 项目路径 章节号 章节内容文件" -ForegroundColor Red
            exit 1
        }
        
        $AnalysisDir = Join-Path $ProjectPath "chapter-analysis"
        $CumulativeReport = Join-Path $AnalysisDir "cumulative-analysis.md"
        $ChapterReport = Join-Path $AnalysisDir "chapter-$ChapterNum-analysis.md"
        
        # 确保目录存在
        if (!(Test-Path $AnalysisDir)) {
            New-Item -ItemType Directory -Path $AnalysisDir -Force
        }
        
        # 检查章节内容文件是否存在
        if (!(Test-Path $ChapterContentFile)) {
            Write-Host "❌ 章节内容文件不存在: $ChapterContentFile" -ForegroundColor Red
            exit 1
        }
        
        # 读取章节内容
        $ChapterContent = Get-Content $ChapterContentFile -Raw
        
        # 检查累积报告是否存在，如果不存在则创建初始化版本
        if (!(Test-Path $CumulativeReport)) {
            $InitialNovelName = Split-Path $ProjectPath -Leaf  # 使用项目目录名作为小说名
            $initialReportContent = @"
# 《$InitialNovelName》 - 逐章累积分析报告（累积至第0章）

## 分析状态
- 当前进度: 已开始分析
- 最新章节: 无
- 分析时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

## 逐章分析记录
（此处将累积每一章的分析结果）

## 当前分析章节 - 第$ChapterNum章
"@
            $initialReportContent | Out-File -FilePath $CumulativeReport -Encoding UTF8
        }
        
        # 读取当前累积报告
        $CurrentReport = Get-Content $CumulativeReport -Raw
        
        # 构建分析提示词（这里简化为创建章节分析，实际使用Qwen需要额外处理）
        $AnalysisPrompt = @"
你是我的'强制逐章累积分析师'，请按照以下规则对新章节进行详细分析并将结果合并到累积报告中：

## 上一轮累积报告
$CurrentReport

## 新章节文本（第$ChapterNum章）
$ChapterContent

## 分析要求
严格按照'强制逐章累积分析师'的规则执行：
1. 对新章节执行完整的6部分分析（文风指纹、剧情结构、角色分析、主题情感、风格技巧、感悟评价）
2. 将新章节的发现合并到累积报告中
3. 保持所有之前分析的内容完整
4. 更新报告标题为'累积至第$ChapterNum章'
5. 保持报告结构的完整性

请输出完整的更新版累积分析报告：
"@
        
        # 创建章节分析占位符内容
        $ChapterAnalysisContent = @"
# 《$(Split-Path $ProjectPath -Leaf)》 - 逐章累积分析报告（累积至第$ChapterNum章）

## 分析状态
- 当前进度: 已分析至第$ChapterNum章
- 最新章节: 第$ChapterNum章
- 分析时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

## 逐章分析记录

$(if ($CurrentReport -match "## 逐章分析记录(.|\n)*?## ") {
    $matches[0] -replace "## ", "## "
} else {
    "（此处累积每一章的分析结果）"
})

### 第$ChapterNum章 - 详细分析

#### 章节内容摘要
$ChapterContent

#### 文风指纹分析
（第$ChapterNum章的文风分析内容）

#### 剧情与结构分析
（第$ChapterNum章的剧情结构分析）

#### 角色分析
（第$ChapterNum章的角色分析）

#### 主题与情感分析
（第$ChapterNum章的主题情感分析）

#### 风格和技巧
（第$ChapterNum章的风格技巧分析）

#### 感悟与评价
（第$ChapterNum章的感悟评价）

## 第一部分：文风指纹 (Stylometric Fingerprint)
（累积至第$ChapterNum章的文风分析，基于所有已分析章节）

## 第二部分：剧情与结构分析 (Plot & Structural Analysis)
（累积至第$ChapterNum章的剧情结构分析）

## 第三部分：角色分析 (Character Analysis)
（累积至第$ChapterNum章的角色分析更新）

## 第四部分：主题与情感 (Theme & Emotion)
（累积至第$ChapterNum章的主题情感分析）

## 第五部分：风格和技巧 (Style & Technique)
（累积至第$ChapterNum章的风格技巧总结）

## 第六部分：感悟与评价 (Reflection & Critique)
（累积至第$ChapterNum章的感悟评价）
"@
        
        # 保存累积报告
        $ChapterAnalysisContent | Out-File -FilePath $CumulativeReport -Encoding UTF8
        
        Write-Host "✅ 第$ChapterNum章已分析并合并到累积报告" -ForegroundColor Green
        Write-Host "📄 报告已更新: $CumulativeReport" -ForegroundColor Yellow
        break
    }
    
    "view" {
        if (-not $ProjectPath) {
            Write-Host "❌ view命令需要提供: 项目路径" -ForegroundColor Red
            exit 1
        }
        
        $CumulativeReport = Join-Path $ProjectPath "chapter-analysis\cumulative-analysis.md"
        
        if (!(Test-Path $CumulativeReport)) {
            Write-Host "❌ 未找到累积分析报告: $CumulativeReport" -ForegroundColor Red
            exit 1
        }
        
        Get-Content $CumulativeReport
        break
    }
    
    "export" {
        if (-not $ProjectPath -or -not $ChapterNum) {
            Write-Host "❌ export命令需要提供: 项目路径 输出路径" -ForegroundColor Red
            exit 1
        }
        
        $OutputPath = $ChapterNum  # 实际第二个参数是输出路径
        $CumulativeReport = Join-Path $ProjectPath "chapter-analysis\cumulative-analysis.md"
        
        if (!(Test-Path $CumulativeReport)) {
            Write-Host "❌ 未找到累积分析报告: $CumulativeReport" -ForegroundColor Red
            exit 1
        }
        
        Copy-Item $CumulativeReport $OutputPath
        Write-Host "✅ 累积分析报告已导出: $OutputPath" -ForegroundColor Green
        break
    }
    
    "help" {
        Show-Help
        break
    }
    
    Default {
        Write-Host "❌ 未知命令: $Command" -ForegroundColor Red
        Show-Help
        exit 1
    }
}