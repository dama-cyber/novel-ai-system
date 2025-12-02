# novelai.ps1 - PowerShell入口脚本
# 为Windows用户提供统一入口

param(
    [string]$Command = "",
    [string]$ProjectName = "",
    [int]$ChapterCount = 0,
    [string]$Genre = "小说",
    [string]$Protagonist = "主角",
    [string]$Conflict = "冲突"
)

function Show-Help {
    Write-Host "?? ??AI" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Usage: .\novelai.ps1 [command] [parameters]"
    Write-Host ""
    Write-Host "Available commands:"
    Write-Host "  init    <project name> <chapter count> [genre]  Initialize project"
    Write-Host "  create  <project name> <chapter count> [genre] [protagonist] [conflict]  Create novel"
    Write-Host "  sandbox <project path>             Sandbox creation (first 10 chapters)"
    Write-Host "  expand  <project path> <start chapter> <end chapter> Expand creation"
    Write-Host "  analyze <project path>             Analyze project"
    Write-Host "  check   <project path>             Quality check"
    Write-Host "  help                          Show help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\novelai.ps1 create 'My Fantasy Novel' 100 'Fantasy' 'Lin Xuan' 'Cultivation'"
    Write-Host ""
}

# Ensure we're in the project root directory
Set-Location $PSScriptRoot

switch ($Command) {
    "init" {
        if (-not $ProjectName -or $ChapterCount -eq 0) {
            Write-Host "Error: Project name and chapter count are required" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Initializing project: $ProjectName ($ChapterCount chapters)" -ForegroundColor Green
        
        # Try executing using sh first, then fallback to wsl
        $scriptsDir = Join-Path $PSScriptRoot "scripts"
        $initScript = Join-Path $scriptsDir "01-init-project.sh"
        
        try {
            $result = bash -c "cd '$PSScriptRoot' && bash '$initScript' '$ProjectName' '$ChapterCount'"
            Write-Host $result
        }
        catch {
            Write-Host "bash failed, trying wsl..." -ForegroundColor Yellow
            $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$initScript' '$ProjectName' '$ChapterCount'"
            Write-Host $wslResult
        }
    }
    
    "create" {
        if (-not $ProjectName -or $ChapterCount -eq 0) {
            Write-Host "Error: Project name and chapter count are required" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Creating novel: $ProjectName ($ChapterCount chapters)" -ForegroundColor Green
        Write-Host "   Genre: $Genre" -ForegroundColor Yellow
        Write-Host "   Protagonist: $Protagonist" -ForegroundColor Yellow
        Write-Host "   Conflict: $Conflict" -ForegroundColor Yellow
        
        # Initialize project
        $scriptsDir = Join-Path $PSScriptRoot "scripts"
        $initScript = Join-Path $scriptsDir "01-init-project.sh"
        
        try {
            $result = bash -c "cd '$PSScriptRoot' && bash '$initScript' '$ProjectName' '$ChapterCount'"
            Write-Host $result
        }
        catch {
            Write-Host "bash init failed, trying wsl..." -ForegroundColor Yellow
            $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$initScript' '$ProjectName' '$ChapterCount'"
            Write-Host $wslResult
        }
        
        # Generate outline
        $projectPath = Join-Path $PSScriptRoot "projects" $ProjectName
        $outlinePath = Join-Path $projectPath "outline.md"
        
        # Create outline content
        $outlineContent = "# $ProjectName Outline`n`n"
        $outlineContent += "## Novel Information`n"
        $outlineContent += "- Protagonist: $Protagonist`n"
        $outlineContent += "- Main Conflict: $Conflict`n"
        $outlineContent += "- Chapter Count: $ChapterCount`n`n"
        
        # Add chapter summaries
        for ($i = 1; $i -le $ChapterCount; $i++) {
            $outlineContent += "#### Chapter $($i): Chapter Title $($i)`n"
            $outlineContent += "Summary for chapter $($i).`n`n"
        }
        
        # Save outline file
        Set-Content -Path $outlinePath -Value $outlineContent -Encoding UTF8
        Write-Host "Outline generated: $outlinePath" -ForegroundColor Green
        
        # Batch create chapters (in batches to prevent token limit)
        $batchSize = 5
        $currentChapter = 1
        
        while ($currentChapter -le $ChapterCount) {
            $endChapter = [Math]::Min($currentChapter + $batchSize - 1, $ChapterCount)
            
            Write-Host "Creating chapters $currentChapter to $endChapter..." -ForegroundColor Yellow
            $createScript = Join-Path $scriptsDir "03-batch-create.sh"
            
            try {
                $result = bash -c "cd '$PSScriptRoot' && bash '$createScript' '$projectPath' $currentChapter $endChapter"
                Write-Host $result
            }
            catch {
                Write-Host "bash create failed, trying wsl..." -ForegroundColor Yellow
                $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$createScript' '$projectPath' $currentChapter $endChapter"
                Write-Host $wslResult
            }
            
            $currentChapter = $endChapter + 1
            
            # Pause between batches to manage token usage
            if ($currentChapter -le $ChapterCount) {
                Write-Host "Pausing 15 seconds to manage token usage..." -ForegroundColor Cyan
                Start-Sleep -Seconds 15
            }
        }
        
        # Quality check
        Write-Host "Performing quality check..." -ForegroundColor Green
        $checkScript = Join-Path $scriptsDir "04-quality-check.sh"
        
        try {
            $result = bash -c "cd '$PSScriptRoot' && bash '$checkScript' '$projectPath'"
            Write-Host $result
        }
        catch {
            Write-Host "bash check failed, trying wsl..." -ForegroundColor Yellow
            $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$checkScript' '$projectPath'"
            Write-Host $wslResult
        }
        
        Write-Host "Novel creation complete!" -ForegroundColor Green
        Write-Host "Project location: $projectPath" -ForegroundColor Cyan
    }
    
    "sandbox" {
        if (-not $ProjectName) {
            Write-Host "Error: Project path is required" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Sandbox phase creation: $ProjectName (Chapters 1-10)" -ForegroundColor Green
        $scriptsDir = Join-Path $PSScriptRoot "scripts"
        $sandboxScript = Join-Path $scriptsDir "20-sandbox-creation.sh"
        
        try {
            $result = bash -c "cd '$PSScriptRoot' && bash '$sandboxScript' sandbox '$ProjectName'"
            Write-Host $result
        }
        catch {
            Write-Host "bash sandbox failed, trying wsl..." -ForegroundColor Yellow
            $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$sandboxScript' sandbox '$ProjectName'"
            Write-Host $wslResult
        }
    }
    
    "expand" {
        if (-not $ProjectName -or $ChapterCount -eq 0 -or -not $Genre) {
            Write-Host "Error: Project path, start chapter, and end chapter are required" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Expanding creation: $ProjectName (Chapters $ChapterCount-$Genre)" -ForegroundColor Green
        $scriptsDir = Join-Path $PSScriptRoot "scripts"
        $expandScript = Join-Path $scriptsDir "20-sandbox-creation.sh"
        
        try {
            $result = bash -c "cd '$PSScriptRoot' && bash '$expandScript' expand '$ProjectName' $ChapterCount $Genre"
            Write-Host $result
        }
        catch {
            Write-Host "bash expand failed, trying wsl..." -ForegroundColor Yellow
            $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$expandScript' expand '$ProjectName' $ChapterCount $Genre"
            Write-Host $wslResult
        }
    }
    
    "analyze" {
        if (-not $ProjectName) {
            Write-Host "Error: Project path is required" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Analyzing project: $ProjectName" -ForegroundColor Green
        $scriptsDir = Join-Path $PSScriptRoot "scripts"
        $analyzeScript = Join-Path $scriptsDir "20-sandbox-creation.sh"
        
        try {
            $result = bash -c "cd '$PSScriptRoot' && bash '$analyzeScript' analyze '$ProjectName'"
            Write-Host $result
        }
        catch {
            Write-Host "bash analyze failed, trying wsl..." -ForegroundColor Yellow
            $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$analyzeScript' analyze '$ProjectName'"
            Write-Host $wslResult
        }
    }
    
    "check" {
        if (-not $ProjectName) {
            Write-Host "Error: Project path is required" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Quality check: $ProjectName" -ForegroundColor Green
        $scriptsDir = Join-Path $PSScriptRoot "scripts"
        $checkScript = Join-Path $scriptsDir "04-quality-check.sh"
        
        try {
            $result = bash -c "cd '$PSScriptRoot' && bash '$checkScript' '$ProjectName'"
            Write-Host $result
        }
        catch {
            Write-Host "bash check failed, trying wsl..." -ForegroundColor Yellow
            $wslResult = wsl bash -c "cd '$PSScriptRoot' && bash '$checkScript' '$ProjectName'"
            Write-Host $wslResult
        }
    }
    
    "help" {
        Show-Help
    }
    
    default {
        Write-Host "Error: Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}