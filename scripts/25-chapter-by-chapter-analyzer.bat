@echo off
REM scripts/25-chapter-by-chapter-analyzer.bat - 逐章累积分析批处理版本
REM 基于强制逐章累积分析规则，对小说章节进行逐章深度分析并累积报告

setlocal enabledelayedexpansion

if "%~1"=="" goto show_help
if /i "%~1"=="help" goto show_help
if /i "%~1"=="-h" goto show_help
if /i "%~1"=="--help" goto show_help

set COMMAND=%~1
set PROJECT_PATH=%~2
set CHAPTER_NUM=%~3
set CHAPTER_CONTENT_FILE=%~4

if /i "!COMMAND!"=="init" (
    if "%~2"=="" (
        echo ❌ init命令需要提供: 项目路径 小说名
        exit /b 1
    )
    if "%~3"=="" (
        echo ❌ init命令需要提供: 项目路径 小说名
        exit /b 1
    )
    
    set NOVEL_NAME=%~3
    set ANALYSIS_DIR=%PROJECT_PATH%\chapter-analysis
    set CUMULATIVE_REPORT=!ANALYSIS_DIR!\cumulative-analysis.md
    
    REM 创建分析目录
    if not exist "!ANALYSIS_DIR!" mkdir "!ANALYSIS_DIR!"
    
    REM 创建初始累积报告
    echo # 《!NOVEL_NAME!》 - 逐章累积分析报告（初始化）> "!CUMULATIVE_REPORT!"
    echo. >> "!CUMULATIVE_REPORT!"
    echo ## 分析状态>> "!CUMULATIVE_REPORT!"
    echo - 当前进度: 未开始分析>> "!CUMULATIVE_REPORT!"
    echo - 最新章节: 无>> "!CUMULATIVE_REPORT!"
    echo - 分析时间: %date:~0,4%-%date:~5,2%-%date:~8,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%Z>> "!CUMULATIVE_REPORT!"
    echo.>> "!CUMULATIVE_REPORT!"
    echo ## 下一步行动>> "!CUMULATIVE_REPORT!"
    echo 请使用 analyze 命令开始分析第一章，例如：>> "!CUMULATIVE_REPORT!"
    echo ^^^^```>> "!CUMULATIVE_REPORT!"
    echo ^^^^```bash>> "!CUMULATIVE_REPORT!"
    echo   %%0 analyze "!PROJECT_PATH!" 1 "C:\path\to\chapter1.txt">> "!CUMULATIVE_REPORT!"
    echo ^^^^```>> "!CUMULATIVE_REPORT!"
    
    echo ✅ 项目 !NOVEL_NAME! 累积分析已初始化！
    echo 📁 分析报告位置: !CUMULATIVE_REPORT!
    goto :eof
)

if /i "!COMMAND!"=="analyze" (
    if "!PROJECT_PATH!"=="" (
        echo ❌ analyze命令需要提供: 项目路径 章节号 章节内容文件
        exit /b 1
    )
    if "!CHAPTER_NUM!"=="" (
        echo ❌ analyze命令需要提供: 项目路径 章节号 章节内容文件
        exit /b 1
    )
    if "!CHAPTER_CONTENT_FILE!"=="" (
        echo ❌ analyze命令需要提供: 项目路径 章节号 章节内容文件
        exit /b 1
    )
    
    if not exist "!CHAPTER_CONTENT_FILE!" (
        echo ❌ 章节内容文件不存在: !CHAPTER_CONTENT_FILE!
        exit /b 1
    )
    
    set ANALYSIS_DIR=!PROJECT_PATH!\chapter-analysis
    set CUMULATIVE_REPORT=!ANALYSIS_DIR!\cumulative-analysis.md
    set CHAPTER_REPORT=!ANALYSIS_DIR!\chapter-!CHAPTER_NUM!-analysis.md
    
    REM 确保目录存在
    if not exist "!ANALYSIS_DIR!" mkdir "!ANALYSIS_DIR!" 2>nul
    
    REM 检查累积报告是否存在，如果不存在则创建初始化版本
    if not exist "!CUMULATIVE_REPORT!" (
        set "NOVEL_NAME=%%~n1"
        echo # 《!NOVEL_NAME!》 - 逐章累积分析报告（累积至第0章）> "!CUMULATIVE_REPORT!"
        echo.>> "!CUMULATIVE_REPORT!"
        echo ## 分析状态>> "!CUMULATIVE_REPORT!"
        echo - 当前进度: 已开始分析>> "!CUMULATIVE_REPORT!"
        echo - 最新章节: 无>> "!CUMULATIVE_REPORT!"
        echo - 分析时间: %date:~0,4%-%date:~5,2%-%date:~8,2%T%time:~0,2%:%time:~3,2%:%time:~6,2%Z>> "!CUMULATIVE_REPORT!"
        echo.>> "!CUMULATIVE_REPORT!"
        echo ## 逐章分析记录>> "!CUMULATIVE_REPORT!"
        echo （此处将累积每一章的分析结果）>> "!CUMULATIVE_REPORT!"
        echo.>> "!CUMULATIVE_REPORT!"
        echo ## 当前分析章节 - 第!CHAPTER_NUM!章>> "!CUMULATIVE_REPORT!"
        echo.>> "!CUMULATIVE_REPORT!"
    )
    
    REM 读取当前累积报告内容
    set CURRENT_REPORT=
    for /f "delims=" %%i in ('type "!CUMULATIVE_REPORT!" 2^>nul') do (
        set "CURRENT_REPORT=!CURRENT_REPORT!%%i"
        set "CURRENT_REPORT=!CURRENT_REPORT!;"
    )
    
    REM 读取章节内容
    set CHAPTER_CONTENT=
    for /f "delims=" %%i in ('type "!CHAPTER_CONTENT_FILE!" 2^>nul') do (
        set "CHAPTER_CONTENT=!CHAPTER_CONTENT!%%i"
        set "CHAPTER_CONTENT=!CHAPTER_CONTENT!;"
    )
    
    REM 更新报告标题为包含当前章节号
    set "UPDATED_TITLE=# 《!NOVEL_NAME!》 - 逐章累积分析报告（累积至第!CHAPTER_NUM!章）"
    
    REM 创建新的累积报告
    echo !UPDATED_TITLE!> "!CUMULATIVE_REPORT!.tmp"
    echo.>> "!CUMULATIVE_REPORT!.tmp"
    
    REM 跳过原报告的标题行，复制其余内容
    for /f "skip=1 tokens=*" %%i in ('type "!CUMULATIVE_REPORT!"') do (
        echo %%i>> "!CUMULATIVE_REPORT!.tmp"
    )
    
    REM 添加当前章节的分析占位符
    echo.>> "!CUMULATIVE_REPORT!.tmp"
    echo ### 第!CHAPTER_NUM!章 - 详细分析>> "!CUMULATIVE_REPORT!.tmp"
    echo.>> "!CUMULATIVE_REPORT!.tmp"
    echo 章节内容：>> "!CUMULATIVE_REPORT!.tmp"
    type "!CHAPTER_CONTENT_FILE!">> "!CUMULATIVE_REPORT!.tmp"
    echo.>> "!CUMULATIVE_REPORT!.tmp"
    echo **章节分析待Qwen处理**>> "!CUMULATIVE_REPORT!.tmp"
    echo.>> "!CUMULATIVE_REPORT!.tmp"
    
    REM 替换原报告
    move /y "!CUMULATIVE_REPORT!.tmp" "!CUMULATIVE_REPORT!" >nul
    
    echo ✅ 第!CHAPTER_NUM!章已分析并合并到累积报告
    echo 📄 报告已更新: !CUMULATIVE_REPORT!
    goto :eof
)

if /i "!COMMAND!"=="view" (
    if "!PROJECT_PATH!"=="" (
        echo ❌ view命令需要提供: 项目路径
        exit /b 1
    )
    
    set CUMULATIVE_REPORT=!PROJECT_PATH!\chapter-analysis\cumulative-analysis.md
    
    if not exist "!CUMULATIVE_REPORT!" (
        echo ❌ 未找到累积分析报告: !CUMULATIVE_REPORT!
        exit /b 1
    )
    
    type "!CUMULATIVE_REPORT!"
    goto :eof
)

if /i "!COMMAND!"=="export" (
    if "!PROJECT_PATH!"=="" (
        echo ❌ export命令需要提供: 项目路径 输出路径
        exit /b 1
    )
    if "!CHAPTER_NUM!"=="" (
        echo ❌ export命令需要提供: 项目路径 输出路径
        exit /b 1
    )
    
    set OUTPUT_PATH=!CHAPTER_NUM!  REM 第三个参数实际上是输出路径
    set CUMULATIVE_REPORT=!PROJECT_PATH!\chapter-analysis\cumulative-analysis.md
    
    if not exist "!CUMULATIVE_REPORT!" (
        echo ❌ 未找到累积分析报告: !CUMULATIVE_REPORT!
        exit /b 1
    )
    
    copy "!CUMULATIVE_REPORT!" "!OUTPUT_PATH!" >nul
    if !ERRORLEVEL! equ 0 (
        echo ✅ 累积分析报告已导出: !OUTPUT_PATH!
    ) else (
        echo ❌ 导出失败
        exit /b 1
    )
    goto :eof
)

echo ❌ 未知命令: %~1
goto show_help

:show_help
echo 🔄 逐章累积分析器 ^(批处理版^)
echo.
echo 用法: %%0 ^<命令^> [参数]
echo.
echo 可用命令:
echo   init     ^<项目路径^> ^<小说名^>    初始化累积分析
echo   analyze  ^<项目路径^> ^<章节号^> ^<章节内容文件^>  分析单章并更新累积报告
echo   view     ^<项目路径^>              查看当前累积报告
echo   export   ^<项目路径^> ^<输出路径^>    导出累积报告
echo   help                                 显示此帮助信息
echo.
echo 示例:
echo   %%0 init "^^./projects/我的小说" "星辰变"
echo   %%0 analyze "^^./projects/我的小说" 1 "^^./temp/chapter1.txt"
echo   %%0 view "^^./projects/我的小说"
echo   %%0 export "^^./projects/我的小说" "^^./exports/cumulative-report.md"
goto :eof