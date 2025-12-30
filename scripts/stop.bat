@echo off
setlocal EnableDelayedExpansion

echo 🛑 ePACK Docker - Stopping Application Stack
echo.

:: Default values
set REMOVE_VOLUMES=false
set REMOVE_ORPHANS=false

:: Parse arguments (simplified for batch)
if "%1"=="--volumes" set REMOVE_VOLUMES=true
if "%1"=="-v" set REMOVE_VOLUMES=true
if "%1"=="--orphans" set REMOVE_ORPHANS=true
if "%1"=="-o" set REMOVE_ORPHANS=true
if "%1"=="--all" (
    set REMOVE_VOLUMES=true
    set REMOVE_ORPHANS=true
)
if "%1"=="-a" (
    set REMOVE_VOLUMES=true
    set REMOVE_ORPHANS=true
)

echo 🟡 Stopping ePACK services...
set COMPOSE_CMD=docker-compose down

if "!REMOVE_ORPHANS!"=="true" (
    set COMPOSE_CMD=!COMPOSE_CMD! --remove-orphans
    echo ⚠️  Removing orphan containers
)

if "!REMOVE_VOLUMES!"=="true" (
    echo ⚠️  WARNING: This will remove all volumes and delete data!
    echo    - Database files
    echo    - Logs
    echo    - Uploads
    echo    - Cache
    echo    - Video input/output
    echo.
    set /p confirm="Are you sure you want to remove volumes? (yes/no): "
    if "!confirm!"=="yes" (
        set COMPOSE_CMD=!COMPOSE_CMD! -v
        echo 🗑️  Removing volumes...
    ) else (
        echo ✅ Volumes preserved
    )
)

:: Execute command
echo.
call !COMPOSE_CMD!

echo.
echo ✅ ePACK stack stopped successfully
echo.

echo 🎉 Done!
pause
