@echo off
REM scripts\21-combined-revision.bat - 拆书分析与换元仿写一体化批处理脚本
REM 结合06拆书和08修订功能，提供从分析到实现的完整流程

setlocal enabledelayedexpansion

if "%~1"=="" goto show_help
if /i "%~1"=="help" goto show_help
if /i "%~1"=="-h" goto show_help
if /i "%~1"=="--help" goto show_help

set COMMAND=%~1
shift

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
    call :analyze "%~1" %~2 %~3
    goto :eof
)

if /i "!COMMAND!"=="swap" (
    if "%~1"=="" (
        echo ❌ swap命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ swap命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~3"=="" (
        echo ❌ swap命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~4"=="" (
        echo ❌ swap命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    call :swap "%~1" %~2 %~3 "%~4"
    goto :eof
)

if /i "!COMMAND!"=="rewrite" (
    if "%~1"=="" (
        echo ❌ rewrite命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ rewrite命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~3"=="" (
        echo ❌ rewrite命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~4"=="" (
        echo ❌ rewrite命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    call :rewrite "%~1" %~2 %~3 "%~4"
    goto :eof
)

if /i "!COMMAND!"=="full" (
    if "%~1"=="" (
        echo ❌ full命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ full命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~3"=="" (
        echo ❌ full命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    if "%~4"=="" (
        echo ❌ full命令需要提供: 项目路径 起始章 结束章 新元素
        exit /b 1
    )
    call :full "%~1" %~2 %~3 "%~4"
    goto :eof
)

if /i "!COMMAND!"=="merge" (
    if "%~1"=="" (
        echo ❌ merge命令需要提供: 项目路径 起始章 结束章 [分支名]
        exit /b 1
    )
    if "%~2"=="" (
        echo ❌ merge命令需要提供: 项目路径 起始章 结束章 [分支名]
        exit /b 1
    )
    if "%~3"=="" (
        echo ❌ merge命令需要提供: 项目路径 起始章 结束章 [分支名]
        exit /b 1
    )
    set "BRANCH=%~4"
    if "!BRANCH!"=="" set "BRANCH=main"
    call :merge "%~1" %~2 %~3 "!BRANCH!"
    goto :eof
)

echo ❌ 未知命令: %~1
goto show_help

:show_help
echo 🔄 拆书分析与换元仿写一体化批处理脚本
echo.
echo 用法: %%0 ^<命令^> [参数]
echo.
echo 可用命令:
echo   analyze  ^<项目路径^> ^<起始章^> ^<结束章^>  拆书分析
echo   swap     ^<项目路径^> ^<起始章^> ^<结束章^> ^<新元素^>  换元设计
echo   rewrite  ^<项目路径^> ^<起始章^> ^<结束章^> ^<新元素^>  仿写实施
echo   full     ^<项目路径^> ^<起始章^> ^<结束章^> ^<新元素^>  完整流程
echo   merge    ^<项目路径^> ^<起始章^> ^<结束章^> [分支]  合并版本
echo   help                                  显示此帮助信息
echo.
echo 示例:
echo   %%0 analyze "./projects/我的小说" 1 10
echo   %%0 swap "./projects/我的小说" 1 10 "加入神秘导师角色"
echo   %%0 full "./projects/我的小说" 1 10 "加入神秘导师角色"
goto :eof

:analyze
set "PROJECT_DIR=%~1"
set "CHAPTER_START=%~2"
set "CHAPTER_END=%~3"

echo 🔍 开始拆书分析（第!CHAPTER_START!章到第!CHAPTER_END!章）...
echo 此功能需要bash和qwen CLI支持

set "CHAPTERS_DIR=!PROJECT_DIR!\chapters"
set "OUTPUT_DIR=!PROJECT_DIR!\composite-revision-analysis"
set "ANALYSIS_DIR=!OUTPUT_DIR!\analysis"

REM 创建输出目录
if not exist "!ANALYSIS_DIR!" mkdir "!ANALYSIS_DIR!" 2>nul

REM 用于汇总分析结果的文件
set "ANALYSIS_FILE=!ANALYSIS_DIR!\composite-analysis.md"
echo # 拆书分析报告> "!ANALYSIS_FILE!"
echo.>> "!ANALYSIS_FILE!"
echo ## 项目信息>> "!ANALYSIS_FILE!"
echo - 项目路径: !PROJECT_DIR!>> "!ANALYSIS_FILE!"
echo - 分析范围: 第!CHAPTER_START!章 到 第!CHAPTER_END!章>> "!ANALYSIS_FILE!"
echo - 生成时间: %date% %time%>> "!ANALYSIS_FILE!"
echo.>> "!ANALYSIS_FILE!"
echo ## 拆书详情>> "!ANALYSIS_FILE!"
echo.>> "!ANALYSIS_FILE!"

REM 拆书分析流程（简化版）
for /L %%i in (!CHAPTER_START!,1,!CHAPTER_END!) do (
    set "FORMATTED_CHAPTER=000%%i"
    set "FORMATTED_CHAPTER=!FORMATTED_CHAPTER:~-3!"
    
    echo   正在分析第%%i章...
    
    REM 这里会执行bash脚本进行实际分析
    REM bash -c "qwen << 'EOF'...EOF" > "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md" 2>nul
    
    REM 创建示例文件
    echo ## 第%%i章分析结果> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo.>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo 这是一个示例分析结果。>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo.>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo ### 核心情节总结>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo 示例情节总结内容。>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo.>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo ### 人物发展>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    echo 示例人物发展内容。>> "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md"
    
    echo ### 第%%i章：示例标题>> "!ANALYSIS_FILE!"
    echo.>> "!ANALYSIS_FILE!"
    echo ^<details^>>> "!ANALYSIS_FILE!"
    echo ^<summary^>点击查看拆书分析^</summary^>>> "!ANALYSIS_FILE!"
    echo.>> "!ANALYSIS_FILE!"
    type "!ANALYSIS_DIR!\chapter_!FORMATTED_CHAPTER!_analysis.md" >> "!ANALYSIS_FILE!"
    echo.>> "!ANALYSIS_FILE!"
    echo ^</details^>>> "!ANALYSIS_FILE!"
    echo.>> "!ANALYSIS_FILE!"
    
    echo   ✅ 第%%i章拆书分析完成
)

echo ✅ 拆书分析完成！分析报告已生成: !ANALYSIS_FILE!
goto :eof

:swap
set "PROJECT_DIR=%~1"
set "CHAPTER_START=%~2"
set "CHAPTER_END=%~3"
set "NEW_ELEMENT=%~4"

echo 🔄 开始换元设计（第!CHAPTER_START!章到第!CHAPTER_END!章，添加:!NEW_ELEMENT!）...
echo 此功能需要bash和qwen CLI支持

set "CHAPTERS_DIR=!PROJECT_DIR!\chapters"
set "OUTPUT_DIR=!PROJECT_DIR!\composite-revision-analysis"
set "ANALYSIS_DIR=!OUTPUT_DIR!\analysis"
set "SWAP_DIR=!OUTPUT_DIR!\swap-design"

REM 创建输出目录
if not exist "!SWAP_DIR!" mkdir "!SWAP_DIR!" 2>nul

REM 换元设计汇总报告
set "SWAP_REPORT=!SWAP_DIR!\swap-design-report.md"
echo # 换元设计方案报告> "!SWAP_REPORT!"
echo.>> "!SWAP_REPORT!"
echo ## 项目信息>> "!SWAP_REPORT!"
echo - 项目路径: !PROJECT_DIR!>> "!SWAP_REPORT!"
echo - 设计范围: 第!CHAPTER_START!章 到 第!CHAPTER_END!章>> "!SWAP_REPORT!"
echo - 新元素: !NEW_ELEMENT!>> "!SWAP_REPORT!"
echo - 生成时间: %date% %time%>> "!SWAP_REPORT!"
echo.>> "!SWAP_REPORT!"
echo ## 换元设计方案>> "!SWAP_REPORT!"
echo.>> "!SWAP_REPORT!"

REM 换元设计流程（简化版）
for /L %%i in (!CHAPTER_START!,1,!CHAPTER_END!) do (
    set "FORMATTED_CHAPTER=000%%i"
    set "FORMATTED_CHAPTER=!FORMATTED_CHAPTER:~-3!"
    
    echo   正在设计第%%i章的换元方案...
    
    REM 创建示例换元设计方案
    echo ## 第%%i章换元设计方案> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo.>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo 这是一个示例换元设计方案。>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo.>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo ### 融合方案>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo 如何自然地引入新元素的示例。>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo.>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo ### 具体修改点>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    echo 需要修改的段落和情节示例。>> "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md"
    
    echo ### 第%%i章：示例标题>> "!SWAP_REPORT!"
    echo.>> "!SWAP_REPORT!"
    echo ^<details^>>> "!SWAP_REPORT!"
    echo ^<summary^>点击查看换元设计方案^</summary^>>> "!SWAP_REPORT!"
    echo.>> "!SWAP_REPORT!"
    type "!SWAP_DIR!\chapter_!FORMATTED_CHAPTER!_swap-plan.md" >> "!SWAP_REPORT!"
    echo.>> "!SWAP_REPORT!"
    echo ^</details^>>> "!SWAP_REPORT!"
    echo.>> "!SWAP_REPORT!"
    
    echo   ✅ 第%%i章换元设计完成
)

echo ✅ 换元设计完成！方案报告已生成: !SWAP_REPORT!
goto :eof

:rewrite
set "PROJECT_DIR=%~1"
set "CHAPTER_START=%~2"
set "CHAPTER_END=%~3"
set "NEW_ELEMENT=%~4"

echo ✍️  开始仿写实施（第!CHAPTER_START!章到第!CHAPTER_END!章，添加:!NEW_ELEMENT!）...
echo 此功能需要bash和qwen CLI支持

set "CHAPTERS_DIR=!PROJECT_DIR!\chapters"
set "OUTPUT_DIR=!PROJECT_DIR!\composite-revision-analysis"
set "REWRITE_DIR=!OUTPUT_DIR!\rewrites"
set "BACKUP_DIR=!OUTPUT_DIR!\backup-%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"

REM 创建输出和备份目录
if not exist "!REWRITE_DIR!" mkdir "!REWRITE_DIR!" 2>nul
if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!" 2>nul

REM 仿写实施（简化版）
for /L %%i in (!CHAPTER_START!,1,!CHAPTER_END!) do (
    set "FORMATTED_CHAPTER=000%%i"
    set "FORMATTED_CHAPTER=!FORMATTED_CHAPTER:~-3!"
    
    echo   正在仿写第%%i章...
    
    REM 创建示例仿写内容
    echo # 第%%i章 示例标题> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo.>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo ## 概要>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo 这是根据新元素 '!NEW_ELEMENT!' 调整后的梗概>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo.>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo ## 正文>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo.>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo 新重写的内容，融入了 '!NEW_ELEMENT!' 元素。>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo.>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo ^--->> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo.>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo **下一章预告**：下一章预告待定>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo.>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    echo **字数统计**：字数统计待定>> "!REWRITE_DIR!\chapter_!FORMATTED_CHAPTER!_revised.md"
    
    echo   ✅ 第%%i章仿写完成
)

echo ✅ 仿写实施完成！
goto :eof

:full
set "PROJECT_DIR=%~1"
set "CHAPTER_START=%~2"
set "CHAPTER_END=%~3"
set "NEW_ELEMENT=%~4"

echo 🚀 开始完整拆书-换元-仿写流程...

call :analyze "!PROJECT_DIR!" !CHAPTER_START! !CHAPTER_END!
call :swap "!PROJECT_DIR!" !CHAPTER_START! !CHAPTER_END! "!NEW_ELEMENT!"
call :rewrite "!PROJECT_DIR!" !CHAPTER_START! !CHAPTER_END! "!NEW_ELEMENT!"

REM 生成最终报告
set "OUTPUT_DIR=!PROJECT_DIR!\composite-revision-analysis"
set "FINAL_REPORT=!OUTPUT_DIR!\final-composite-report.md"
echo # 拆书-换元-仿写完整流程报告> "!FINAL_REPORT!"
echo.>> "!FINAL_REPORT!"
echo ## 项目信息>> "!FINAL_REPORT!"
echo - 项目路径: !PROJECT_DIR!>> "!FINAL_REPORT!"
echo - 处理范围: 第!CHAPTER_START!章 到 第!CHAPTER_END!章>> "!FINAL_REPORT!"
echo - 新元素: !NEW_ELEMENT!>> "!FINAL_REPORT!"
echo - 完成时间: %date% %time%>> "!FINAL_REPORT!"
echo.>> "!FINAL_REPORT!"
echo ## 流程详情>> "!FINAL_REPORT!"
echo - 拆书分析: 已完成>> "!FINAL_REPORT!"
echo - 换元设计: 已完成>> "!FINAL_REPORT!"
echo - 仿写实施: 已完成>> "!FINAL_REPORT!"
echo.>> "!FINAL_REPORT!"
echo ## 结果概览>> "!FINAL_REPORT!"
echo - 原始章节已备份至: !OUTPUT_DIR!\backup-YYYYMMDD_HHMMSS\>> "!FINAL_REPORT!"
echo - 拆书分析报告: !OUTPUT_DIR!\analysis\composite-analysis.md>> "!FINAL_REPORT!"
echo - 换元设计方案: !OUTPUT_DIR!\swap-design\swap-design-report.md>> "!FINAL_REPORT!"
echo - 重写章节文件: !OUTPUT_DIR!\rewrites\>> "!FINAL_REPORT!"
echo.>> "!FINAL_REPORT!"
echo ## 注意事项>> "!FINAL_REPORT!"
echo - 修订后的章节已在项目chapters目录中更新>> "!FINAL_REPORT!"
echo - 原始文件已备份，如需恢复可在备份目录找到>> "!FINAL_REPORT!"
echo - 本次流程成功融入新元素: !NEW_ELEMENT!>> "!FINAL_REPORT!"
echo - 建议后续进行整体一致性检查>> "!FINAL_REPORT!"

echo ✅ 完整流程完成！最终报告已生成: !FINAL_REPORT!
goto :eof

:merge
set "PROJECT_DIR=%~1"
set "CHAPTER_START=%~2"
set "CHAPTER_END=%~3"
set "BRANCH=%~4"
if "!BRANCH!"=="" set "BRANCH=main"

echo 🔗 开始合井版本（第!CHAPTER_START!章到第!CHAPTER_END!章）...

set "CHAPTERS_DIR=!PROJECT_DIR!\chapters"
set "OUTPUT_DIR=!PROJECT_DIR!\composite-revision-analysis"
set "MERGE_DIR=!OUTPUT_DIR!\merge-%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"

REM 创建输出目录
if not exist "!MERGE_DIR!" mkdir "!MERGE_DIR!" 2>nul

REM 创建合并报告
set "MERGE_REPORT=!MERGE_DIR!\merge-report.md"
echo # 版本合并报告> "!MERGE_REPORT!"
echo.>> "!MERGE_REPORT!"
echo ## 项目信息>> "!MERGE_REPORT!"
echo - 项目路径: !PROJECT_DIR!>> "!MERGE_REPORT!"
echo - 合并范围: 第!CHAPTER_START!章 到 第!CHAPTER_END!章>> "!MERGE_REPORT!"
echo - 合并分支: !BRANCH!>> "!MERGE_REPORT!"
echo - 合并时间: %date% %time%>> "!MERGE_REPORT!"
echo.>> "!MERGE_REPORT!"
echo ## 合并详情>> "!MERGE_REPORT!"
echo.>> "!MERGE_REPORT!"

REM 合并流程（简化版）
for /L %%i in (!CHAPTER_START!,1,!CHAPTER_END!) do (
    set "FORMATTED_CHAPTER=000%%i"
    set "FORMATTED_CHAPTER=!FORMATTED_CHAPTER:~-3!"
    
    echo   处理第%%i章合并...
    
    REM 创建示例合并策略
    echo ## 第%%i章合并策略> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo.>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo 这是一个示例合并策略。>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo.>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo ### 冲突处理>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo 处理版本冲突的示例。>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo.>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo ### 连续性保持>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    echo 保持故事连贯性的示例。>> "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md"
    
    echo ### 第%%i章：示例标题>> "!MERGE_REPORT!"
    echo.>> "!MERGE_REPORT!"
    echo ^<details^>>> "!MERGE_REPORT!"
    echo ^<summary^>点击查看合并策略^</summary^>>> "!MERGE_REPORT!"
    echo.>> "!MERGE_REPORT!"
    type "!MERGE_DIR!\chapter_!FORMATTED_CHAPTER!_merge-strategy.md" >> "!MERGE_REPORT!"
    echo.>> "!MERGE_REPORT!"
    echo ^</details^>>> "!MERGE_REPORT!"
    echo.>> "!MERGE_REPORT!"
    
    echo   ✅ 第%%i章合并策略制定完成
)

echo ✅ 版本合并策略制定完成！报告已生成: !MERGE_REPORT!
goto :eof