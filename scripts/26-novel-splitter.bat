@echo off
REM scripts/26-novel-splitter.bat - 小说分割工具 (批处理版)
REM 将整本小说按章节分割成独立文件，然后可以进行逐章分析

setlocal enabledelayedexpansion

if "%~1"=="" goto show_help
if /i "%~1"=="help" goto show_help
if /i "%~1"=="-h" goto show_help
if /i "%~1"=="--help" goto show_help

set COMMAND=%~1
shift

if /i "!COMMAND!"=="split" (
    if "%~1"=="" (
        echo ❌ split命令需要提供: 小说文件 输出目录 [项目名]
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ split命令需要提供: 小说文件 输出目录 [项目名]
        exit /b 1
    )
    call :split_novel "%~1" "%~2" "%~3"
    goto :eof
)

if /i "!COMMAND!"=="analyze" (
    if "%~1"=="" (
        echo ❌ analyze命令需要提供: 项目路径 起始章 结束章
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ analyze命令需要提供: 项目路径 起始章 结束章
        exit /b 1
    )
    if "%~3"=="" (
        echo ❌ analyze命令需要提供: 项目路径 起始章 结束章
        exit /b 1
    )
    call :analyze_chapters "%~1" %~2 %~3
    goto :eof
)

if /i "!COMMAND!"=="full" (
    if "%~1"=="" (
        echo ❌ full命令需要提供: 小说文件 输出目录 [项目名]
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ full命令需要提供: 小说文件 输出目录 [项目名]
        exit /b 1
    )
    call :full_process "%~1" "%~2" "%~3"
    goto :eof
)

echo ❌ 未知命令: %~1
goto show_help

:show_help
echo ✂️  小说分割工具 ^(批处理版^)
echo.
echo 用法: %%0 ^<命令^> [参数]
echo.
echo 可用命令:
echo   split    ^<整本小说文件^> ^<输出目录^> [项目名]  按章节分割整本小说
echo   analyze  ^<项目路径^> ^<起始章^> ^<结束章^>      对分割后的章节进行逐章分析
echo   full     ^<整本小说文件^> ^<输出目录^> [项目名]  完整流程^(分割+分析^)
echo   help                                      显示此帮助信息
echo.
echo 示例:
echo   %%0 split "novel.txt" ".\projects\我的小说" "我的玄幻小说"
echo   %%0 analyze ".\projects\我的小说" 1 10
echo   %%0 full "novel.txt" ".\projects\我的小说" "我的玄幻小说"
goto :eof

:split_novel
set NOVEL_FILE=%~1
set OUTPUT_DIR=%~2
set PROJECT_NAME=%~3

if not defined PROJECT_NAME set PROJECT_NAME=未命名小说

if not exist "%NOVEL_FILE%" (
    echo ❌ 小说文件不存在: %NOVEL_FILE%
    exit /b 1
)

echo ✂️  开始分割小说: %NOVEL_FILE%

REM 创建输出目录
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%OUTPUT_DIR%\chapters" mkdir "%OUTPUT_DIR%\chapters"
if not exist "%OUTPUT_DIR%\settings" mkdir "%OUTPUT_DIR%\settings"

REM 创建元数据文件
set METADATA_FILE=%OUTPUT_DIR%\metadata.json
echo {} > "%METADATA_FILE%"

echo { > "%METADATA_FILE%"
echo   "title": "%PROJECT_NAME%, >> "%METADATA_FILE%"
echo   "totalChapters": 0, >> "%METADATA_FILE%"
echo   "created": "%date:~0,4%-%date:~5,2%-%date:~8,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%Z", >> "%METADATA_FILE%"
echo   "status": "splitting" >> "%METADATA_FILE%"
echo } >> "%METADATA_FILE%"

echo 🔍 尝试分割章节...

REM 使用PowerShell脚本按章节分割文件
powershell -Command ^
"$content = Get-Content '%NOVEL_FILE%' -Raw; " ^
"$chapterRegex = [regex]'^第\d+[章节回].*$'; " ^
"$matches = $chapterRegex.Matches($content); " ^
"$chapterCount = 0; " ^
"$startIndex = 0; " ^
"foreach ($match in $matches) { " ^
"  $currentPos = $match.Index; " ^
"  $chapterContent = $content.Substring($startIndex, $currentPos - $startIndex); " ^
"  if ($chapterContent.Trim() -ne \"\") { " ^
"    $chapterCount++; " ^
"    $formattedChapter = $chapterCount.ToString(\"D3\"); " ^
"    $chapterTitle = $match.Value.Trim(); " ^
"    $cleanTitle = $chapterTitle -replace '[^\\w\\u4e00-\\u9fa5]', '_'; " ^
"    $chapterFile = Join-Path '%OUTPUT_DIR%/chapters' \"chapter_${formattedChapter}_${cleanTitle}.md\"; " ^
"    $chapterContentFormatted = \"# ${chapterTitle}`n`n## 概要`n待AI生成`n`n## 正文`n`n${chapterContent}\"; " ^
"    $chapterContentFormatted | Out-File -FilePath $chapterFile -Encoding UTF8; " ^
"    Write-Host \"  发现并保存章节: ${chapterTitle} (第${chapterCount}章)\"; " ^
"  } " ^
"  $startIndex = $currentPos + $match.Length; " ^
"} " ^
"if ($startIndex -lt $content.Length) { " ^
"  $remainingContent = $content.Substring($startIndex); " ^
"  if ($remainingContent.Trim() -ne \"\") { " ^
"    $chapterCount++; " ^
"    $formattedChapter = $chapterCount.ToString(\"D3\"); " ^
"    $chapterTitle = \"第${chapterCount}章 未命名\"; " ^
"    $chapterFile = Join-Path '%OUTPUT_DIR%/chapters' \"chapter_${formattedChapter}_第${chapterCount}章.md\"; " ^
"    $chapterContentFormatted = \"# ${chapterTitle}`n`n## 概要`n待AI生成`n`n## 正文`n`n${remainingContent}\"; " ^
"    $chapterContentFormatted | Out-File -FilePath $chapterFile -Encoding UTF8; " ^
"    Write-Host \"  保存最后一章: ${chapterTitle} (第${chapterCount}章)\"; " ^
"  } " ^
"} " ^
"$updatedMetadata = @{ " ^
"  title = '%PROJECT_NAME%'; " ^
"  totalChapters = $chapterCount; " ^
"  created = (Get-Date).ToString(\"yyyy-MM-ddTHH:mm:ssZ\"); " ^
"  status = \"split_complete\"; " ^
"  sourceFile = Split-Path '%NOVEL_FILE%' -Leaf " ^
"}; " ^
"$updatedMetadata | ConvertTo-Json | Out-File -FilePath '%METADATA_FILE%' -Encoding UTF8; " ^
"Write-Host \"✅ 分割完成，共 $chapterCount 章\" -ForegroundColor Green;"

echo 📁 章节文件已保存至: %OUTPUT_DIR%\chapters
echo 📊 分割完成！
goto :eof

:analyze_chapters
set PROJECT_DIR=%~1
set START_CHAPTER=%~2
set END_CHAPTER=%~3

if not exist "%PROJECT_DIR%" (
    echo ❌ 项目目录不存在: %PROJECT_DIR%
    exit /b 1
)

echo 🔍 开始逐章分析（第%START_CHAPTER%章到第%END_CHAPTER%章）...

set CHAPTERS_DIR=%PROJECT_DIR%\chapters

for /L %%i in (%START_CHAPTER%,1,%END_CHAPTER%) do (
    set "FORMATTED_CHAPTER=000%%i"
    set "FORMATTED_CHAPTER=!FORMATTED_CHAPTER:~-3!"
    
    REM 查找章节文件
    for %%f in ("%CHAPTERS_DIR%\chapter_!FORMATTED_CHAPTER!_*") do (
        if exist "%%f" (
            echo   正在分析第%%i章: %%~nxf
            REM 调用逐章分析器
            powershell -Command "bash -c './scripts/25-chapter-by-chapter-analyzer.sh analyze \"%PROJECT_DIR%\" %%i \"%%f\"'"
        )
    )
)

echo ✅ 逐章分析完成！
goto :eof

:full_process
set NOVEL_FILE=%~1
set OUTPUT_DIR=%~2
set PROJECT_NAME=%~3

if not defined PROJECT_NAME set PROJECT_NAME=未命名小说

echo 🔄 开始完整处理流程...

call :split_novel "%NOVEL_FILE%" "%OUTPUT_DIR%" "%PROJECT_NAME%"

REM 读取元数据获取章节数
for /f "tokens=2 delims=:" %%a in ('findstr /c:"totalChapters" "%OUTPUT_DIR%\metadata.json"') do (
    set /a TOTAL_CHAPTERS=%%a
    set TOTAL_CHAPTERS=!TOTAL_CHAPTERS: =!
    set TOTAL_CHAPTERS=!TOTAL_CHAPTERS:,=!
)

if !TOTAL_CHAPTERS! gtr 0 (
    echo 📈 检测到 !TOTAL_CHAPTERS! 章，开始分析...
    call :analyze_chapters "%OUTPUT_DIR%" 1 !TOTAL_CHAPTERS!
) else (
    echo ⚠️  未检测到章节，跳过分析步骤
)

echo ✅ 完整流程完成！
goto :eof