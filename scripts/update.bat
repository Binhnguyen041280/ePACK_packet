@echo off
echo 🔄 ePACK Configuration Update
echo =============================
echo Stopping services...
call stop.bat

echo.
echo ⏳ Waiting 5 seconds for cleanup...
timeout /t 5 /nobreak

echo.
echo 🚀 Restarting services...
call start.bat
