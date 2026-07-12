@echo off
setlocal

REM Move to the project root (this script lives in scripts/)
cd /d "%~dp0.."

echo ============================================
echo    GitHub Update - ATB Banking App
echo ============================================
echo.

REM 1. Check whether there is anything to push
set CHANGES=
for /f "delims=" %%i in ('git status --porcelain') do set CHANGES=1
if not defined CHANGES (
    echo No changes detected. The repository is already up to date.
    goto :end
)

REM 2. Commit message: script argument, or a default dated message
set MSG=%*
if "%MSG%"=="" set MSG=Update on %date% at %time:~0,8%

REM 3. Stage all files (new, modified, deleted)
echo [1/4] Staging files...
git add -A

REM 4. Create the commit
echo [2/4] Creating commit: "%MSG%"
git commit -m "%MSG%"
if errorlevel 1 goto :error

REM 5. Pull remote changes before pushing to avoid conflicts
echo [3/4] Syncing with GitHub (pull --rebase)...
git pull --rebase origin main
if errorlevel 1 goto :error

REM 6. Push to GitHub
echo [4/4] Pushing to GitHub...
git push origin main
if errorlevel 1 goto :error

echo.
echo ============================================
echo    Update completed successfully!
echo ============================================
goto :end

:error
echo.
echo !!! ERROR: read the message above to understand the problem. !!!

:end
echo.
pause
