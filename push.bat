@echo off
echo =================================
echo   Git Hero Automator
echo =================================

:: Ask for the commit message
set /p msg="Commit Message: "

:: Validate that message is not empty
if "%msg%"=="" (
    echo Error: Commit message is required.
    pause
    exit /b
)

:: Ask for the optional description
set /p desc="Description (Optional): "

:: Git operations
git add .

if "%desc%"=="" (
    git commit -m "%msg%"
) else (
    git commit -m "%msg%" -m "%desc%"
)

git push

echo =================================
echo   Successfully Pushed!
echo =================================
pause