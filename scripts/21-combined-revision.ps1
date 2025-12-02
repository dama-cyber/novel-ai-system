# scripts/21-combined-revision.ps1 - 拆书分析与换元仿写一体化PowerShell脚本
# 结合06拆书和08修订功能，提供从分析到实现的完整流程

# 检查PowerShell版本
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "❌ 此脚本需要PowerShell 3.0或更高版本" -ForegroundColor Red
    exit 1
}

function Show-Help {
    Write-Host "🔄 拆书分析与换元仿写一体化PowerShell脚本" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "用法: .\21-combined-revision.ps1 <命令> [参数]"
    Write-Host ""
    Write-Host "可用命令:"
    Write-Host "  analyze  <项目路径> <起始章> <结束章>  拆书分析"
    Write-Host "  swap     <项目路径> <起始章> <结束章> <新元素>  换元设计"
    Write-Host "  rewrite  <项目路径> <起始章> <结束章> <新元素>  仿写实施"
    Write-Host "  full     <项目路径> <起始章> <结束章> <新元素>  完整流程"
    Write-Host "  merge    <项目路径> <起始章> <结束章> [分支]  合并版本"
    Write-Host "  help                                  显示此帮助信息"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  .\21-combined-revision.ps1 analyze `"./projects/我的小说`" 1 10"
    Write-Host "  .\21-combined-revision.ps1 swap `"./projects/我的小说`" 1 10 `"加入神秘导师角色`""
    Write-Host "  .\21-combined-revision.ps1 full `"./projects/我的小说`" 1 10 `"加入神秘导师角色`""
}

function Invoke-Analysis {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectDir,
        [Parameter(Mandatory=$true)][int]$ChapterStart,
        [Parameter(Mandatory=$true)][int]$ChapterEnd
    )
    
    Write-Host "🔍 开始拆书分析（第$ChapterStart章到第$ChapterEnd章）..." -ForegroundColor Cyan
    
    $chaptersDir = Join-Path $ProjectDir "chapters"
    $outputDir = Join-Path $ProjectDir "composite-revision-analysis"
    $analysisDir = Join-Path $outputDir "analysis"
    
    # 创建输出目录
    if (!(Test-Path $analysisDir)) {
        New-Item -ItemType Directory -Path $analysisDir -Force
    }
    
    # 用于汇总分析结果的文件
    $analysisFile = Join-Path $analysisDir "composite-analysis.md"
    @"
# 复合拆书分析报告

## 项目信息
- 项目路径: $ProjectDir
- 分析范围: 第$ChapterStart章 到 第$ChapterEnd章
- 生成时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

## 拆书详情

"@ | Out-File -FilePath $analysisFile -Encoding UTF8
    
    # 执行拆书分析
    for ($i = $ChapterStart; $i -le $ChapterEnd; $i++) {
        $formattedChapter = "{0:D3}" -f $i
        
        # 查找章节文件
        $chapterFile = $null
        $chapterPattern = Join-Path $chaptersDir "chapter_$formattedChapter*_*.md"
        $files = Get-ChildItem -Path $chaptersDir -Filter "chapter_$formattedChapter*_*.md" -ErrorAction SilentlyContinue
        
        if ($files) {
            $chapterFile = $files[0].FullName
        }
        
        if ($chapterFile -and (Test-Path $chapterFile)) {
            Write-Host "  正在分析第$i章..." -ForegroundColor Green
            
            # 提取章节标题
            $chapterTitle = Split-Path $chapterFile -Leaf
            $chapterTitle = $chapterTitle -replace "^chapter_$formattedChapter_", ""
            $chapterTitle = $chapterTitle -replace ".md$", ""
            
            # 提取章节内容
            $chapterContent = ""
            $lines = Get-Content $chapterFile -Raw
            $contentMatch = [regex]::Match($lines, '(?s)## 正文.*?(?=^---|\z)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            if ($contentMatch.Success) {
                $chapterContent = $contentMatch.Value.Substring(6).Trim()  # 移除"## 正文"
            }
            
            # 构建拆书分析提示词
            $splitPrompt = @"
你是一个专业的拆书专家和小说分析员，擅长深入分析小说内容。

请对以下章节进行拆书分析：

章节信息：
- 章节：第${i}章
- 标题：${chapterTitle}

章节正文：
${chapterContent}

请按以下结构进行分析：

1. **核心情节总结**：简要概述本章的主要情节
2. **人物发展**：分析本章中角色的成长、变化或行为
3. **情节推进**：说明本章如何推动整体故事前进
4. **冲突与转折**：指出本章中的冲突点或剧情转折
5. **伏笔与呼应**：识别本章埋设的伏笔或呼应前面情节的内容
6. **写作技巧**：分析作者使用的写作技巧、修辞手法等
7. **情感调动**：分析本章如何调动读者情感
8. **节奏控制**：分析本章的节奏安排

请用markdown格式输出分析结果。
"@
            
            # 调用Qwen进行拆书分析（如果可用）
            $analysisOutput = Join-Path $analysisDir "chapter_$formattedChapter`_analysis.md"
            try {
                $splitPrompt | qwen > $analysisOutput
                Write-Host "    保存分析到: $analysisOutput" -ForegroundColor Gray
            }
            catch {
                # 如果qwen不可用，创建示例分析文件
                @"
## 第${i}章分析结果

这是一个示例分析结果。

### 核心情节总结
示例情节总结内容。

### 人物发展
示例人物发展内容。

### 情节推进
示例情节推进内容。

### 冲突与转折
示例冲突与转折内容。

### 伏笔与呼应
示例伏笔与呼应内容。

### 写作技巧
示例写作技巧内容。

### 情感调动
示例情感调动内容。

### 节奏控制
示例节奏控制内容。
"@ | Out-File -FilePath $analysisOutput -Encoding UTF8
                Write-Host "    qwen不可用，创建示例分析文件" -ForegroundColor Yellow
            }
            
            # 将结果追加到汇总报告
@"
### 第${i}章：${chapterTitle}

<details>
<summary>点击查看拆书分析</summary>

$(Get-Content $analysisOutput -Raw)

</details>

"@ | Out-File -FilePath $analysisFile -Append -Encoding UTF8
            
            Write-Host "  ✅ 第$i章拆书分析完成" -ForegroundColor Green
        }
        else {
            Write-Host "  ⚠️  第$i章文件不存在" -ForegroundColor Yellow
            
            # 在汇总报告中记录缺失章节
@"
### 第${i}章：文件不存在

> 该章节文件未找到，无法进行拆书分析

"@ | Out-File -FilePath $analysisFile -Append -Encoding UTF8
        }
    }
    
    Write-Host "✅ 拆书分析完成！分析报告已生成: $analysisFile" -ForegroundColor Green
}

function Invoke-SwapDesign {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectDir,
        [Parameter(Mandatory=$true)][int]$ChapterStart,
        [Parameter(Mandatory=$true)][int]$ChapterEnd,
        [Parameter(Mandatory=$true)][string]$NewElement
    )
    
    Write-Host "🔄 开始换元设计（第$ChapterStart章到第$ChapterEnd章，添加:$NewElement）..." -ForegroundColor Cyan
    
    $chaptersDir = Join-Path $ProjectDir "chapters"
    $outputDir = Join-Path $ProjectDir "composite-revision-analysis"
    $analysisDir = Join-Path $outputDir "analysis"
    $swapDir = Join-Path $outputDir "swap-design"
    
    # 创建输出目录
    if (!(Test-Path $swapDir)) {
        New-Item -ItemType Directory -Path $swapDir -Force
    }
    
    # 换元设计汇总报告
    $swapReport = Join-Path $swapDir "swap-design-report.md"
    @"
# 换元设计方案报告

## 项目信息
- 项目路径: $ProjectDir
- 设计范围: 第${ChapterStart}章 到 第${ChapterEnd}章
- 新元素: $NewElement
- 生成时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

## 换元设计方案

"@ | Out-File -FilePath $swapReport -Encoding UTF8
    
    for ($i = $ChapterStart; $i -le $ChapterEnd; $i++) {
        $formattedChapter = "{0:D3}" -f $i
        
        $analysisFile = Join-Path $analysisDir "chapter_$formattedChapter`_analysis.md"
        $chapterFile = $null
        $files = Get-ChildItem -Path $chaptersDir -Filter "chapter_$formattedChapter*_*.md" -ErrorAction SilentlyContinue
        if ($files) {
            $chapterFile = $files[0].FullName
        }
        
        if ((Test-Path $analysisFile) -and $chapterFile) {
            Write-Host "  正在设计第$i章的换元方案..." -ForegroundColor Green
            
            # 提取章节内容
            $chapterTitle = Split-Path $chapterFile -Leaf
            $chapterTitle = $chapterTitle -replace "^chapter_$formattedChapter_", ""
            $chapterTitle = $chapterTitle -replace ".md$", ""
            
            $chapterContent = ""
            $lines = Get-Content $chapterFile -Raw
            $contentMatch = [regex]::Match($lines, '(?s)## 正文.*?(?=^---|\z)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            if ($contentMatch.Success) {
                $chapterContent = $contentMatch.Value.Substring(6).Trim()
            }
            
            $summary = ""
            $summaryMatch = [regex]::Match($lines, '(?s)## 概要.*?(?=## 正文|\z)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            if ($summaryMatch.Success) {
                $summary = $summaryMatch.Value.Substring(6).Trim()
            }
            
            # 获取拆书分析结果
            $analysisContent = Get-Content $analysisFile -Raw
            
            # 构建换元设计提示词
            $swapPrompt = @"
你是一个专业的换元设计师和故事重构专家。

基于以下拆书分析和原章节内容，设计如何在章节中融入新元素：$NewElement

原章节信息：
- 章节：第${i}章
- 标题：${chapterTitle}
- 概要：${summary}

原章节正文：
${chapterContent}

拆书分析：
${analysisContent}

新元素描述：${NewElement}

请按以下要求设计换元方案：

1. **融合方案**
   - 如何自然地引入新元素
   - 与原情节的结合点
   - 对角色关系/情节的影响

2. **具体修改点**
   - 哪些段落需要修改
   - 哪些情节需要调整
   - 需要新增的场景或对话

3. **保持一致性**
   - 如何保持原有的故事节奏
   - 如何保持原有语言风格
   - 对后续章节的影响

4. **实施计划**
   - 修改优先级
   - 需要注意的问题
   - 预期效果

请提供详细的换元设计方案。
"@

            # 调用Qwen进行换元设计
            $swapFile = Join-Path $swapDir "chapter_$formattedChapter`_swap-plan.md"
            try {
                $swapPrompt | qwen > $swapFile
                Write-Host "    保存换元方案到: $swapFile" -ForegroundColor Gray
            }
            catch {
                # 如果qwen不可用，创建示例方案文件
                @"
## 第${i}章换元设计方案

这是一个示例换元设计方案。

### 融合方案
如何自然地引入新元素的示例。

### 具体修改点
需要修改的段落和情节示例。

### 保持一致性
保持原有故事节奏和风格的示例。

### 实施计划
修改优先级和注意事项示例。
"@ | Out-File -FilePath $swapFile -Encoding UTF8
                Write-Host "    qwen不可用，创建示例换元方案文件" -ForegroundColor Yellow
            }
            
            # 追加到汇总报告
@"
### 第${i}章：${chapterTitle}

<details>
<summary>点击查看换元设计方案</summary>

$(Get-Content $swapFile -Raw)

</details>

"@ | Out-File -FilePath $swapReport -Append -Encoding UTF8
            
            Write-Host "  ✅ 第$i章换元设计完成" -ForegroundColor Green
        }
    }
    
    Write-Host "✅ 换元设计完成！方案报告已生成: $swapReport" -ForegroundColor Green
}

function Invoke-Rewrite {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectDir,
        [Parameter(Mandatory=$true)][int]$ChapterStart,
        [Parameter(Mandatory=$true)][int]$ChapterEnd,
        [Parameter(Mandatory=$true)][string]$NewElement
    )
    
    Write-Host "✍️  开始仿写实施（第$ChapterStart章到第$ChapterEnd章，添加:$NewElement）..." -ForegroundColor Cyan
    
    $chaptersDir = Join-Path $ProjectDir "chapters"
    $outputDir = Join-Path $ProjectDir "composite-revision-analysis"
    $analysisDir = Join-Path $outputDir "analysis"
    $swapDir = Join-Path $outputDir "swap-design"
    $rewriteDir = Join-Path $outputDir "rewrites"
    $backupDir = Join-Path $outputDir "backup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    # 创建输出和备份目录
    if (!(Test-Path $rewriteDir)) {
        New-Item -ItemType Directory -Path $rewriteDir -Force
    }
    if (!(Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force
    }
    
    # 备份原始章节
    Write-Host "🔄 正在备份原始章节..." -ForegroundColor Yellow
    for ($i = $ChapterStart; $i -le $ChapterEnd; $i++) {
        $formattedChapter = "{0:D3}" -f $i
        
        # 查找章节文件
        $chapterFile = $null
        $files = Get-ChildItem -Path $chaptersDir -Filter "chapter_$formattedChapter*_*.md" -ErrorAction SilentlyContinue
        if ($files) {
            $chapterFile = $files[0].FullName
        }
        
        if ($chapterFile) {
            $backupFile = Join-Path $backupDir (Split-Path $chapterFile -Leaf)
            Copy-Item $chapterFile $backupFile
        }
    }
    
    # 仿写实施
    for ($i = $ChapterStart; $i -le $ChapterEnd; $i++) {
        $formattedChapter = "{0:D3}" -f $i
        
        $analysisFile = Join-Path $analysisDir "chapter_$formattedChapter`_analysis.md"
        $swapFile = Join-Path $swapDir "chapter_$formattedChapter`_swap-plan.md"
        $chapterFile = $null
        $files = Get-ChildItem -Path $chaptersDir -Filter "chapter_$formattedChapter*_*.md" -ErrorAction SilentlyContinue
        if ($files) {
            $chapterFile = $files[0].FullName
        }
        
        if ((Test-Path $analysisFile) -and (Test-Path $swapFile) -and $chapterFile) {
            Write-Host "  正在仿写第$i章..." -ForegroundColor Green
            
            # 提取原章节各部分
            $chapterTitle = Split-Path $chapterFile -Leaf
            $chapterTitle = $chapterTitle -replace "^chapter_$formattedChapter_", ""
            $chapterTitle = $chapterTitle -replace ".md$", ""
            
            $chapterContent = ""
            $lines = Get-Content $chapterFile -Raw
            $contentMatch = [regex]::Match($lines, '(?s)## 正文.*?(?=^---|\z)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            if ($contentMatch.Success) {
                $chapterContent = $contentMatch.Value.Substring(6).Trim()
            }
            
            $summary = ""
            $summaryMatch = [regex]::Match($lines, '(?s)## 概要.*?(?=## 正文|\z)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            if ($summaryMatch.Success) {
                $summary = $summaryMatch.Value.Substring(6).Trim()
            }
            
            # 查找下一章预告和字数统计
            $nextTeaser = "下一章预告待定"
            if ($lines -match "下一章预告.*") {
                $nextTeaser = ($lines | Select-String "下一章预告.*" | Select-Object -First 1).Line.Trim()
            }
            
            $wordCount = "字数统计待定"
            if ($lines -match "字数统计.*") {
                $wordCount = ($lines | Select-String "字数统计.*" | Select-Object -First 1).Line.Trim()
            }
            
            # 获取分析和换元方案
            $analysisContent = Get-Content $analysisFile -Raw
            $swapPlan = Get-Content $swapFile -Raw
            
            # 构建仿写提示词
            $rewritePrompt = @"
你是一个专业的仿写专家和故事重构大师。

请根据拆书分析、换元方案和原内容，重写章节内容融入新元素：${NewElement}

要求：
1. 保留原章节核心情节和结构
2. 自然融入新元素：${NewElement}
3. 参考换元方案中的具体建议
4. 保持原作的语言风格和节奏
5. 适当调整相关情节以保持逻辑一致性
6. 确保内容流畅自然

原始章节信息：
- 章节：第${i}章
- 标题：${chapterTitle}
- 概要：${summary}

原始正文：
${chapterContent}

拆书分析：
${analysisContent}

换元方案：
${swapPlan}

请按以下模板输出重写后的内容：

# 第${i}章 ${chapterTitle}

## 概要

[保持或根据新元素调整后的概要]

## 正文

[重写后的正文内容，融入了${NewElement}]

---

**下一章预告**：${nextTeaser}

**字数统计**：${wordCount}

注意保持章节的完整性。
"@
            
            # 调用Qwen进行仿写
            try {
                $rewrittenContent = $rewritePrompt | qwen
                
                if ($rewrittenContent) {
                    # 生成新文件名（在标题后添加修订标识）
                    $newTitle = "${chapterTitle}-修订版"
                    $newFile = Join-Path $chaptersDir "chapter_$formattedChapter`_${newTitle}.md"
                    
                    # 保存重写后的内容
                    $rewrittenContent | Out-File -FilePath $newFile -Encoding UTF8
                    
                    # 删除原始文件
                    Remove-Item $chapterFile -Force
                    
                    # 同时保存重写版本到单独文件
                    $rewriteFile = Join-Path $rewriteDir "chapter_$formattedChapter`_revised.md"
                    $rewrittenContent | Out-File -FilePath $rewriteFile -Encoding UTF8
                    
                    Write-Host "  ✅ 第$i章仿写完成" -ForegroundColor Green
                }
                else {
                    Write-Host "  ⚠️  第$i章仿写失败，保留原始文件" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "  ❌ 第$i章仿写失败: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "✅ 仿写实施完成！" -ForegroundColor Green
}

function Invoke-Merge {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectDir,
        [Parameter(Mandatory=$true)][int]$ChapterStart,
        [Parameter(Mandatory=$true)][int]$ChapterEnd,
        [string]$Branch = "main"
    )
    
    Write-Host "🔗 开始合井版本（第$ChapterStart章到第$ChapterEnd章）..." -ForegroundColor Cyan
    
    $chaptersDir = Join-Path $ProjectDir "chapters"
    $outputDir = Join-Path $ProjectDir "composite-revision-analysis"
    $mergeDir = Join-Path $outputDir "merge-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    if (!(Test-Path $mergeDir)) {
        New-Item -ItemType Directory -Path $mergeDir -Force
    }
    
    # 创建合并报告
    $mergeReport = Join-Path $mergeDir "merge-report.md"
    @"
# 版本合并报告

## 项目信息
- 项目路径: $ProjectDir
- 合并范围: 第${ChapterStart}章 到 第${ChapterEnd}章
- 合并分支: $Branch
- 合并时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

## 合并详情

"@ | Out-File -FilePath $mergeReport -Encoding UTF8
    
    for ($i = $ChapterStart; $i -le $ChapterEnd; $i++) {
        $formattedChapter = "{0:D3}" -f $i
        
        # 查找章节文件
        $chapterFile = $null
        $files = Get-ChildItem -Path $chaptersDir -Filter "chapter_$formattedChapter*_*.md" -ErrorAction SilentlyContinue
        if ($files) {
            $chapterFile = $files[0].FullName
        }
        
        if ($chapterFile) {
            Write-Host "  处理第${i}章合并..." -ForegroundColor Green
            
            # 提取章节内容
            $chapterTitle = Split-Path $chapterFile -Leaf
            $chapterTitle = $chapterTitle -replace "^chapter_$formattedChapter_", ""
            $chapterTitle = $chapterTitle -replace ".md$", ""
            
            $chapterContent = ""
            $lines = Get-Content $chapterFile -Raw
            $contentMatch = [regex]::Match($lines, '(?s)## 正文.*?(?=^---|\z)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
            if ($contentMatch.Success) {
                $chapterContent = $contentMatch.Value.Substring(6).Trim()
            }
            
            # 构建合并策略提示词
            $mergePrompt = @"
你是一个专业的版本合并专家。

以下是第${i}章的当前版本内容：

章节标题：${chapterTitle}
章节内容：
${chapterContent}

请考虑以下因素进行版本合并策略制定：
1. 如何处理不同版本间的冲突
2. 如何保持故事连贯性
3. 如何保留有价值的修改
4. 如何保持整体风格统一

请为章节合并提供策略建议。
"@
            
            # 获取合并策略
            $mergeStrategy = Join-Path $mergeDir "chapter_$formattedChapter`_merge-strategy.md"
            try {
                $mergePrompt | qwen > $mergeStrategy
            }
            catch {
                # 如果qwen不可用，创建示例策略文件
                @"
## 第${i}章合并策略

这是一个示例合并策略。

### 冲突处理
处理版本冲突的示例。

### 连续性保持
保持故事连贯性的示例。

### 修改保留
保留有价值修改的示例。

### 风格统一
保持整体风格统一的示例。
"@ | Out-File -FilePath $mergeStrategy -Encoding UTF8
            }
            
            @"
### 第${i}章：${chapterTitle}

<details>
<summary>点击查看合并策略</summary>

$(Get-Content $mergeStrategy -Raw)

</details>

"@ | Out-File -FilePath $mergeReport -Append -Encoding UTF8
            
            Write-Host "  ✅ 第${i}章合并策略制定完成" -ForegroundColor Green
        }
    }
    
    Write-Host "✅ 版本合并策略制定完成！报告已生成: $mergeReport" -ForegroundColor Green
}

function Invoke-FullProcess {
    param(
        [Parameter(Mandatory=$true)][string]$ProjectDir,
        [Parameter(Mandatory=$true)][int]$ChapterStart,
        [Parameter(Mandatory=$true)][int]$ChapterEnd,
        [Parameter(Mandatory=$true)][string]$NewElement
    )
    
    Write-Host "🚀 开始完整拆书-换元-仿写流程..." -ForegroundColor Green
    
    # 执行分析
    Invoke-Analysis -ProjectDir $ProjectDir -ChapterStart $ChapterStart -ChapterEnd $ChapterEnd
    
    # 执行换元设计
    Invoke-SwapDesign -ProjectDir $ProjectDir -ChapterStart $ChapterStart -ChapterEnd $ChapterEnd -NewElement $NewElement
    
    # 执行仿写实施
    Invoke-Rewrite -ProjectDir $ProjectDir -ChapterStart $ChapterStart -ChapterEnd $ChapterEnd -NewElement $NewElement
    
    # 生成最终报告
    $outputDir = Join-Path $ProjectDir "composite-revision-analysis"
    $finalReport = Join-Path $outputDir "final-composite-report.md"
    @"
# 拆书-换元-仿写完整流程报告

## 项目信息
- 项目路径: $ProjectDir
- 处理范围: 第${ChapterStart}章 到 第${ChapterEnd}章
- 新元素: $NewElement
- 完成时间: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

## 流程详情
- 拆书分析: 已完成
- 换元设计: 已完成
- 仿写实施: 已完成

## 结果概览
- 原始章节已备份至: $outputDir\backup-YYYYMMDD_HHMMSS\
- 拆书分析报告: $outputDir\analysis\composite-analysis.md
- 换元设计方案: $outputDir\swap-design\swap-design-report.md
- 重写章节文件: $outputDir\rewrites\

## 注意事项
- 修订后的章节已在项目chapters目录中更新
- 原始文件已备份，如需恢复可在备份目录找到
- 本次流程成功融入新元素: $NewElement
- 建议后续进行整体一致性检查
"@ | Out-File -FilePath $finalReport -Encoding UTF8
    
    Write-Host "✅ 完整流程完成！最终报告已生成: $finalReport" -ForegroundColor Green
}

# 解析参数
param(
    [Parameter(Mandatory=$true, Position=0)][string]$Command,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments
)

switch ($Command) {
    "analyze" {
        if ($Arguments.Count -lt 3) {
            Write-Host "❌ analyze命令需要提供: 项目路径 起始章 结束章" -ForegroundColor Red
            exit 1
        }
        Invoke-Analysis -ProjectDir $Arguments[0] -ChapterStart ([int]$Arguments[1]) -ChapterEnd ([int]$Arguments[2])
    }
    "swap" {
        if ($Arguments.Count -lt 4) {
            Write-Host "❌ swap命令需要提供: 项目路径 起始章 结束章 新元素" -ForegroundColor Red
            exit 1
        }
        Invoke-SwapDesign -ProjectDir $Arguments[0] -ChapterStart ([int]$Arguments[1]) -ChapterEnd ([int]$Arguments[2]) -NewElement $Arguments[3]
    }
    "rewrite" {
        if ($Arguments.Count -lt 4) {
            Write-Host "❌ rewrite命令需要提供: 项目路径 起始章 结束章 新元素" -ForegroundColor Red
            exit 1
        }
        Invoke-Rewrite -ProjectDir $Arguments[0] -ChapterStart ([int]$Arguments[1]) -ChapterEnd ([int]$Arguments[2]) -NewElement $Arguments[3]
    }
    "full" {
        if ($Arguments.Count -lt 4) {
            Write-Host "❌ full命令需要提供: 项目路径 起始章 结束章 新元素" -ForegroundColor Red
            exit 1
        }
        Invoke-FullProcess -ProjectDir $Arguments[0] -ChapterStart ([int]$Arguments[1]) -ChapterEnd ([int]$Arguments[2]) -NewElement $Arguments[3]
    }
    "merge" {
        if ($Arguments.Count -lt 3) {
            Write-Host "❌ merge命令需要提供: 项目路径 起始章 结束章 [分支名]" -ForegroundColor Red
            exit 1
        }
        $branch = if ($Arguments.Count -gt 3) { $Arguments[3] } else { "main" }
        Invoke-Merge -ProjectDir $Arguments[0] -ChapterStart ([int]$Arguments[1]) -ChapterEnd ([int]$Arguments[2]) -Branch $branch
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