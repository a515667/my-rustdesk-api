@echo off
setlocal EnableDelayedExpansion
echo ========================================================
echo Auto Sync to GitHub - Smart Mode
echo ========================================================
echo.

set "GIT_EXE="

REM 1. 尝试从 PATH 查找
where git >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('where git') do set "GIT_EXE=%%i" & goto :Found
)

REM 2. 尝试搜索 GitHub Desktop 的安装路径 (自动处理版本号)
echo Searching for GitHub Desktop's Git...
if exist "C:\Users\%USERNAME%\AppData\Local\GitHubDesktop" (
    cd /d "C:\Users\%USERNAME%\AppData\Local\GitHubDesktop"
    for /d %%d in (app-*) do (
        if exist "%%d\resources\app\git\cmd\git.exe" (
            set "GIT_EXE=%%d\resources\app\git\cmd\git.exe"
            goto :Found
        )
    )
)

REM 3. 如果没找到，让用户手动输入
echo.
echo [ERROR] Could not auto-detect Git.
echo Please enter the FULL path to git.exe (e.g. C:\Path\To\git.exe)
echo.
set /p USER_PATH="Path: "
REM 去除引号
set USER_PATH=%USER_PATH:"=%

REM 检查用户输入的是否是文件夹，如果是，尝试追加 \git.exe
if exist "%USER_PATH%\git.exe" (
    set "GIT_EXE=%USER_PATH%\git.exe"
    goto :Found
)

REM 检查用户输入的是否直接是文件
if exist "%USER_PATH%" (
    set "GIT_EXE=%USER_PATH%"
    goto :Found
)

echo.
echo [FATAL] Git executable not found at: "%USER_PATH%"
pause
exit /b

:Found
echo.
echo [INFO] Using Git at: "!GIT_EXE!"
echo.

REM 切换回项目目录
cd /d "E:\前端源码\rustdesk-api-master"

REM 执行同步逻辑
if not exist .git (
    "!GIT_EXE!" init
)

"!GIT_EXE!" add .
"!GIT_EXE!" commit -m "feat: sync code"
"!GIT_EXE!" branch -M main
"!GIT_EXE!" remote remove origin >nul 2>nul
"!GIT_EXE!" remote add origin https://github.com/a515667/my-rustdesk-api.git

echo.
echo [ACTION] Pushing to GitHub...
echo Please check for any login pop-ups!
echo.
"!GIT_EXE!" push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Done!
) else (
    echo.
    echo [ERROR] Push failed.
)

pause
