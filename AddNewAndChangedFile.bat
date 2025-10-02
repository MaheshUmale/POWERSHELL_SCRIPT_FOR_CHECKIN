@echo off
setlocal enabledelayedexpansion

rem --- Configuration ---
set "branch=main"
rem ---------------------

rem Check if Git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Please install Git and ensure it's in your system's PATH.
    pause
    exit /b 1
)

echo.
echo === Processing .csv files for individual commits ===
echo.

rem Loop through all .csv files in the current directory
for %%f in (*.csv) do (
    rem Get the status of the file
    git status --porcelain "%%f" > status.tmp

    rem Read the status code
    set "status_line="
    for /f "tokens=*" %%g in (status.tmp) do (
        set "status_line=%%g"
    )

    rem Check if the file is new (untracked) or modified
    if "!status_line:~0,2!"=="???" (
        echo --- New file found: %%f ---
        echo Staging "%%f"...
        git add "%%f"
        echo Committing "%%f"...
        git commit -m "Add new file: %%f"
        echo Pushing "%%f" to the remote branch "%branch%"...
        git push origin "%branch%"
    ) else if "!status_line:~0,2!"==" M" (
        echo --- Modified file found: %%f ---
        echo Staging "%%f"...
        git add "%%f"
        echo Committing "%%f"...
        git commit -m "Update file: %%f"
        echo Pushing "%%f" to the remote branch "%branch%"...
        git push origin "%branch%"
    ) else (
        echo --- No changes detected for "%%f". Skipping. ---
    )
    echo.
)

del status.tmp >nul 2>&1
endlocal
echo All .csv files have been processed.
pause
