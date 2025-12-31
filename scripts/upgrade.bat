@echo off
setlocal enabledelayedexpansion

echo 🔍 Checking Docker...
docker compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Docker Compose not found. Please install Docker Desktop.
    pause
    exit /b 1
)

echo.
echo 📦 Step 1/3: Downloading new version layers...
docker compose pull backend frontend

echo.
echo 🔄 Step 2/3: Applying updates (Restarting services)...
call scripts\stop.bat
timeout /t 2 /nobreak >nul
call scripts\start.bat

echo.
echo 🏥 Step 3/3: Verifying system health...
timeout /t 5 /nobreak >nul
docker ps

echo.
echo 🎉 Upgrade Complete! You are now running the latest version.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pause
