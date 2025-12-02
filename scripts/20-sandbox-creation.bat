@echo off
REM scripts\20-sandbox-creation.bat - 沙盒创作法专用批处理脚本
REM 基于沙盒创作法的分阶段小说生成流程

setlocal enabledelayedexpansion

if "%~1"=="" goto show_help
if /i "%~1"=="help" goto show_help
if /i "%~1"=="-h" goto show_help
if /i "%~1"=="--help" goto show_help

set COMMAND=%~1
shift

if /i "!COMMAND!"=="init" (
    if "%~1"=="" (
        echo ❌ init命令需要提供: 项目名 章节数 [类型]
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ init命令需要提供: 项目名 章节数 [类型]
        exit /b 1
    )
    call :init_sandbox_project %*
    goto :eof
)

if /i "!COMMAND!"=="sandbox" (
    if "%~1"=="" (
        echo ❌ sandbox命令需要提供: 项目路径
        exit /b 1
    )
    call :sandbox_phase %*
    goto :eof
)

if /i "!COMMAND!"=="expand" (
    if "%~1"=="" (
        echo ❌ expand命令需要提供: 项目路径 开始章 结束章
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ expand命令需要提供: 项目路径 开始章 结束章
        exit /b 1
    )
    if "%~3"=="" (
        echo ❌ expand命令需要提供: 项目路径 开始章 结束章
        exit /b 1
    )
    call :expand_phase %*
    goto :eof
)

if /i "!COMMAND!"=="complete" (
    if "%~1"=="" (
        echo ❌ complete命令需要提供: 项目路径
        exit /b 1
    )
    call :complete_flow %*
    goto :eof
)

if /i "!COMMAND!"=="analyze" (
    if "%~1"=="" (
        echo ❌ analyze命令需要提供: 项目路径
        exit /b 1
    )
    call :analyze_project %*
    goto :eof
)

echo ❌ 未知命令: %~1
goto show_help

:show_help
echo 🏰 沙盒创作法专用批处理脚本
echo.
echo 用法: %%0 ^<命令^> [参数]
echo.
echo 可用命令:
echo   init      ^<项目名^> ^<章节数^> [类型]  初始化沙盒项目
echo   sandbox   ^<项目路径^>              沙盒阶段创作（前10章）
echo   expand    ^<项目路径^> ^<开始章^> ^<结束章^> 扩展阶段创作
echo   complete  ^<项目路径^>              完成整个创作流程
echo   analyze   ^<项目路径^>              分析项目完整性
echo   help                              显示此帮助信息
echo.
echo 示例:
echo   %%0 init "我的玄幻小说" 100 "玄幻"
echo   %%0 sandbox "./projects/我的玄幻小说"
echo   %%0 expand "./projects/我的玄幻小说" 11 30
echo   %%0 complete "./projects/我的玄幻小说"
goto :eof

:init_sandbox_project
set PROJECT_NAME=%~1
set CHAPTER_COUNT=%~2
set GENRE=%~3

if "%GENRE%"=="" set GENRE=小说

echo 🏰 初始化沙盒项目: !PROJECT_NAME! (^!CHAPTER_COUNT!章, !GENRE!类型)

REM 调用初始化脚本
if exist "01-init-project.sh" (
    bash 01-init-project.sh "!PROJECT_NAME!" "!CHAPTER_COUNT!" 2>nul
    if errorlevel 1 (
        echo ❌ 无法运行初始化脚本，可能需要安装Git Bash
    )
) else (
    echo ❌ 找不到初始化脚本: 01-init-project.sh
)

set PROJECT_PATH=../projects/!PROJECT_NAME!

echo 📝 请完善以下设定文件:
echo   - !PROJECT_PATH!/settings/worldview.json (世界观)
echo   - !PROJECT_PATH!/settings/power-system.json (力量体系)
echo   - !PROJECT_PATH!/settings/characters.json (角色档案)
echo.
echo 💡 提示: 可以参考 examples/ 目录下的示例项目
goto :eof

:sandbox_phase
set PROJECT_PATH=%~1

if not exist "!PROJECT_PATH!" (
    echo ❌ 项目路径不存在: !PROJECT_PATH!
    exit /b 1
)

echo 🔍 沙盒阶段创作: !PROJECT_PATH! (第1-10章)
echo 此阶段将创建一个封闭环境，验证核心设定和人物关系

echo ✅ 检查设定文件...
set SETTINGS_DIR=!PROJECT_PATH!/settings

if not exist "!SETTINGS_DIR!/worldview.json" (
    echo ⚠️  未找到世界观设定文件，使用默认设定
    echo {"setting":"默认世界","rules":{},"cultures":[],"geography":"","history":"","magicSystem":{},"technologyLevel":"","socialStructure":""} > "!SETTINGS_DIR!/worldview.json"
)

if not exist "!SETTINGS_DIR!/characters.json" (
    echo ⚠️  未找到角色设定文件，使用默认设定
    echo {"protagonist":{"name":"","description":"","personality":"","abilities":[],"development":[],"characterArc":[]},"supporting":[],"antagonists":[]} > "!SETTINGS_DIR!/characters.json"
)

REM 调用批量创作脚本
if exist "03-batch-create.sh" (
    bash 03-batch-create.sh "!PROJECT_PATH!" 1 10 2>nul
    if errorlevel 1 (
        echo ❌ 无法运行批量创作脚本，可能需要安装Git Bash
    )
) else (
    echo ❌ 找不到批量创作脚本: 03-batch-create.sh
)

echo ✅ 沙盒阶段完成！请评估:
echo   - 设定是否一致？
echo   - 人物是否生动？
echo   - 情节是否有吸引力？
echo.
echo 如需调整，可修改 settings/ 目录下的设定文件，然后继续扩展阶段
goto :eof

:expand_phase
set PROJECT_PATH=%~1
set START_CHAPTER=%~2
set END_CHAPTER=%~3

if not exist "!PROJECT_PATH!" (
    echo ❌ 项目路径不存在: !PROJECT_PATH!
    exit /b 1
)

echo 🚀 扩展阶段创作: !PROJECT_PATH! (第!START_CHAPTER!-!END_CHAPTER!章)
echo 此阶段将逐步扩大世界观，深化情节发展

REM 调用批量创作脚本
if exist "03-batch-create.sh" (
    bash 03-batch-create.sh "!PROJECT_PATH!" !START_CHAPTER! !END_CHAPTER! 2>nul
    if errorlevel 1 (
        echo ❌ 无法运行批量创作脚本，可能需要安装Git Bash
    )
) else (
    echo ❌ 找不到批量创作脚本: 03-batch-create.sh
)

echo ✅ 扩展阶段完成！
goto :eof

:complete_flow
set PROJECT_PATH=%~1

if not exist "!PROJECT_PATH!" (
    echo ❌ 项目路径不存在: !PROJECT_PATH!
    exit /b 1
)

echo 🎊 完整创作流程: !PROJECT_PATH!

REM 检查是否有第1-10章
set CHAPTER_1_EXISTS=0
set CHAPTER_10_EXISTS=0

for %%f in ("!PROJECT_PATH!/chapters/chapter_001_*") do (
    if exist "%%f" set CHAPTER_1_EXISTS=1
)

for %%f in ("!PROJECT_PATH!/chapters/chapter_010_*") do (
    if exist "%%f" set CHAPTER_10_EXISTS=1
)

if !CHAPTER_1_EXISTS! == 1 (
    if !CHAPTER_10_EXISTS! == 1 (
        echo ✅ 检测到沙盒章节，跳过沙盒阶段
    )
) else (
    echo 🔍 执行沙盒阶段 (第1-10章)...
    call :sandbox_phase !PROJECT_PATH!
)

REM 读取元数据以确定总章节数
set METADATA_FILE=!PROJECT_PATH!/metadata.json
if exist "!METADATA_FILE!" (
    REM 简单解析metadata.json获取章节数
    for /f "tokens=2 delims=:" %%a in ('findstr "chapterCount" "!METADATA_FILE!" 2^>nul') do (
        set /a TOTAL_CHAPTERS=%%a
        set TOTAL_CHAPTERS=!TOTAL_CHAPTERS: =!
        set TOTAL_CHAPTERS=!TOTAL_CHAPTERS:,=!
    )
    
    for /f "tokens=2 delims=:" %%a in ('findstr "currentChapter" "!METADATA_FILE!" 2^>nul') do (
        set /a CURRENT_CHAPTER=%%a
        set CURRENT_CHAPTER=!CURRENT_CHAPTER: =!
        set CURRENT_CHAPTER=!CURRENT_CHAPTER:,=!
    )
    
    if defined CURRENT_CHAPTER (
        if !CURRENT_CHAPTER! LSS 10 (
            set /a START_EXPAND=11
        ) else (
            set /a START_EXPAND=!CURRENT_CHAPTER!+1
        )
    ) else (
        set START_EXPAND=11
    )
) else (
    echo ⚠️  未找到元数据文件，假设有100章
    set TOTAL_CHAPTERS=100
    set START_EXPAND=11
)

set /a REMAINING=!TOTAL_CHAPTERS!-!START_EXPAND!+1
if !REMAINING! GTR 0 (
    echo 🚀 执行扩展阶段 (第!START_EXPAND!-!TOTAL_CHAPTERS!章)...
    
    set CURRENT=!START_EXPAND!
    :expand_loop
    if !CURRENT! GTR !TOTAL_CHAPTERS! goto after_expand_loop
    
    set /a END_BATCH=!CURRENT!+19
    if !END_BATCH! GTR !TOTAL_CHAPTERS! set END_BATCH=!TOTAL_CHAPTERS!
    
    echo   创作第!CURRENT!-!END_BATCH!章...
    call :expand_phase !PROJECT_PATH! !CURRENT! !END_BATCH!
    
    set /a CURRENT=!END_BATCH!+1
    
    REM 每批完成后暂停一下
    if !CURRENT! LEQ !TOTAL_CHAPTERS! (
        echo   暂停10秒...
        timeout /t 10 /nobreak >nul
    )
    
    goto expand_loop
    :after_expand_loop
)

REM 质量检查
echo ✅ 执行最终质量检查...
if exist "04-quality-check.sh" (
    bash 04-quality-check.sh "!PROJECT_PATH!" 2>nul
    if errorlevel 1 (
        echo ❌ 无法运行质量检查脚本，可能需要安装Git Bash
    )
) else (
    echo ❌ 找不到质量检查脚本: 04-quality-check.sh
)

REM 生成项目总结
set SUMMARY_FILE=!PROJECT_PATH!/final-summary.md
echo # 《%%~n1》创作总结> "!SUMMARY_FILE!"
echo.>> "!SUMMARY_FILE!"
echo ## 项目信息>> "!SUMMARY_FILE!"
echo - 项目名称: %%~n1>> "!SUMMARY_FILE!"
echo - 总章节数: !TOTAL_CHAPTERS!>> "!SUMMARY_FILE!"
for /f "tokens=* USEBACKQ" %%f in (`date /t`) do set DATE=%%f
for /f "tokens=* USEBACKQ" %%f in (`time /t`) do set TIME=%%f
echo - 完成时间: !DATE! !TIME!>> "!SUMMARY_FILE!"
echo - 采用方法: 沙盒创作法>> "!SUMMARY_FILE!"
echo.>> "!SUMMARY_FILE!"
echo ## 创作阶段>> "!SUMMARY_FILE!"
echo 1. 沙盒阶段: 1-10章 (核心设定验证)>> "!SUMMARY_FILE!"
echo 2. 扩展阶段: !START_EXPAND!-!TOTAL_CHAPTERS!章 (世界观扩大)>> "!SUMMARY_FILE!"
echo.>> "!SUMMARY_FILE!"
echo ## 项目统计>> "!SUMMARY_FILE!"
echo - 总字数: 0 字 (待计算)>> "!SUMMARY_FILE!"
echo - 章节数: 0 (待计算)>> "!SUMMARY_FILE!"
echo.>> "!SUMMARY_FILE!"
echo ## 项目结构>> "!SUMMARY_FILE!"
tree "!PROJECT_PATH!" >> "!SUMMARY_FILE!" 2>nul || echo tree命令不可用 >> "!SUMMARY_FILE!"

echo 🎊 项目完成！总结文件: !SUMMARY_FILE!
goto :eof

:analyze_project
set PROJECT_PATH=%~1

if not exist "!PROJECT_PATH!" (
    echo ❌ 项目路径不存在: !PROJECT_PATH!
    exit /b 1
)

echo 🔬 分析项目完整性: !PROJECT_PATH!
echo.

echo 📋 设定文件检查:
set SETTINGS_DIR=!PROJECT_PATH!/settings
if exist "!SETTINGS_DIR!" (
    for %%f in ("!SETTINGS_DIR!\*.json") do (
        if exist "%%f" (
            echo   ✅ %%~nxf
        )
    )
) else (
    echo   ❌ 未找到设定目录
)

echo.
echo 📖 章节文件检查:
set CHAPTERS_DIR=!PROJECT_PATH!/chapters
if exist "!CHAPTERS_DIR!" (
    set COUNT=0
    for %%f in ("!CHAPTERS_DIR!\chapter_*.md") do (
        set /a COUNT+=1
    )
    echo   ✅ 总章节数: !COUNT!
    
    if !COUNT! GTR 0 (
        REM 简单获取最后一章的编号
        set LAST_CHAPTER=0
        for /f "delims=" %%f in ('dir /b /on "!CHAPTERS_DIR!\chapter_*.md" 2^>nul') do (
            set "TEMP_FILE=%%f"
            set "TEMP_FILE=!TEMP_FILE:~8,3!"
            set /a LAST_CHAPTER=!TEMP_FILE!
        )
        echo   ✅ 最后一章: !LAST_CHAPTER!
    )
) else (
    echo   ❌ 未找到章节目录
)

echo.
echo 📊 项目分析完成
goto :eof