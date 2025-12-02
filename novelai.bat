@echo off
setlocal enabledelayedexpansion

:: novelai.bat - Windows批处理入口脚本
:: 为Windows用户提供统一入口

if "%~1"=="" goto :show_help
if "%~1"=="help" goto :show_help

:: 检查必要参数
set command=%~1
set project_name=%~2
set chapter_count=%~3

:: 根据命令处理
if "%command%"=="init" (
    if "%project_name%"=="" (
        echo Error: Project name is required
        goto :show_help
    )
    if "%chapter_count%"=="" (
        echo Error: Chapter count is required
        goto :show_help
    )
    echo Initializing project: %project_name% (%chapter_count% chapters)
    call scripts\01-init-project.sh "%project_name%" "%chapter_count%"
    goto :eof
)

if "%command%"=="create" (
    if "%project_name%"=="" (
        echo Error: Project name is required
        goto :show_help
    )
    if "%chapter_count%"=="" (
        echo Error: Chapter count is required
        goto :show_help
    )
    set genre=%~4
    if "%genre%"=="" set genre=小说
    set protagonist=%~5
    if "%protagonist%"=="" set protagonist=主角
    set conflict=%~6
    if "%conflict%"=="" set conflict=冲突

    echo Creating novel: %project_name% (%chapter_count% chapters)
    echo    Genre: !genre!
    echo    Protagonist: !protagonist!
    echo    Conflict: !conflict!

    :: 初始化项目
    call scripts\01-init-project.sh "%project_name%" "%chapter_count%"

    :: 生成大纲
    set project_path=.\projects\%project_name%
    set outline_path=!project_path!\outline.md
    echo # %project_name% 大纲 > "!outline_path!"
    echo. >> "!outline_path!"
    echo ## 小说信息 >> "!outline_path!"
    echo - 主角: !protagonist! >> "!outline_path!"
    echo - 主要冲突: !conflict! >> "!outline_path!"
    echo - 章节数: %chapter_count% >> "!outline_path!"
    echo. >> "!outline_path!"

    :: 添加章节概要
    for /L %%i in (1,1,%chapter_count%) do (
        echo #### 第%%i章 章节标题%%i >> "!outline_path!"
        echo 第%%i章的情节概要。 >> "!outline_path!"
        echo. >> "!outline_path!"
    )

    echo Outline generated: !outline_path!

    :: 批量创作章节（分批进行，防止token超限）
    set batch_size=5
    set current_chapter=1
    
    :create_batch
    if !current_chapter! gtr %chapter_count% goto :quality_check
    set /a end_chapter=!current_chapter! + !batch_size! - 1
    if !end_chapter! gtr %chapter_count% set end_chapter=%chapter_count%
    
    echo Creating chapters !current_chapter! to !end_chapter!...
    call scripts\03-batch-create.sh "!project_path!" !current_chapter! !end_chapter!
    
    set /a current_chapter=!end_chapter! + 1
    if !current_chapter! leq %chapter_count% (
        echo Pausing to manage token usage...
        timeout /t 15 /nobreak >nul
    )
    goto :create_batch

    :quality_check
    echo Performing quality check...
    call scripts\04-quality-check.sh "!project_path!"
    
    echo Novel creation complete!
    echo Project location: !project_path!
    goto :eof
)

if "%command%"=="sandbox" (
    if "%project_name%"=="" (
        echo Error: Project path is required
        goto :show_help
    )
    echo Sandbox phase creation: %project_name% (Chapters 1-10)
    call scripts\20-sandbox-creation.sh sandbox "%project_name%"
    goto :eof
)

if "%command%"=="expand" (
    if "%project_name%"=="" (
        echo Error: Project path is required
        goto :show_help
    )
    set start_chapter=%~3
    set end_chapter=%~4
    if "%start_chapter%"=="" (
        echo Error: Start chapter is required
        goto :show_help
    )
    if "%end_chapter%"=="" (
        echo Error: End chapter is required
        goto :show_help
    )
    echo Expanding creation: %project_name% (Chapters %start_chapter%-%end_chapter%)
    call scripts\20-sandbox-creation.sh expand "%project_name%" %start_chapter% %end_chapter%
    goto :eof
)

if "%command%"=="analyze" (
    if "%project_name%"=="" (
        echo Error: Project path is required
        goto :show_help
    )
    echo Analyzing project: %project_name%
    call scripts\20-sandbox-creation.sh analyze "%project_name%"
    goto :eof
)

if "%command%"=="check" (
    if "%project_name%"=="" (
        echo Error: Project path is required
        goto :show_help
    )
    echo Quality check: %project_name%
    call scripts\04-quality-check.sh "%project_name%"
    goto :eof
)

:show_help
echo ?? AI
echo.
echo Usage: novelai [command] [parameters]
echo.
echo Available commands:
echo   init    ^<project name^> ^<chapter count^>          Initialize project
echo   create  ^<project name^> ^<chapter count^> [genre] [protagonist] [conflict]  Create novel
echo   sandbox ^<project path^>                           Sandbox creation (first 10 chapters)
echo   expand  ^<project path^> ^<start chapter^> ^<end chapter^>  Expand creation
echo   analyze ^<project path^>                           Analyze project
echo   check   ^<project path^>                           Quality check
echo   help                                             Show help
echo.
echo Examples:
echo   novelai create "My Fantasy Novel" 100 "Fantasy" "Lin Xuan" "Cultivation"
echo.
goto :eof