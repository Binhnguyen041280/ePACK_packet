@echo off
REM ============================================================================
REM ePACK Docker - Start Script (Windows)
REM Starts the ePACK application stack using Docker Compose
REM ============================================================================

setlocal EnableDelayedExpansion

REM Colors (simulated)
echo [BLUE] ePACK Docker - Starting Application Stack
echo.

REM Check if .env file exists
if not exist .env (
    echo [YELLOW] .env file not found. Creating from template...
    if exist .env.docker.example (
        copy .env.docker.example .env >nul
        echo [YELLOW] IMPORTANT: Edit .env and configure SECRET_KEY and ENCRYPTION_KEY
        echo [YELLOW] Generate keys using Python if installed, or ask your admin.
        echo.
        pause
    ) else (
        echo [RED] .env.docker.example not found
        exit /b 1
    )
)

REM Check if Docker images exist
echo [BLUE] Checking Docker images...

REM Check for epack.tar and load if exists
if exist epack.tar (
    echo [YELLOW] Found epack.tar. Loading images...
    docker load -i epack.tar
    echo [GREEN] Images loaded from epack.tar
)

REM Check backend image
docker images | findstr "epack-backend" >nul
if %errorlevel% neq 0 (
    if exist images\epack-backend.tar (
        echo [YELLOW] Loading backend image from tar...
        docker load -i images\epack-backend.tar
        echo [GREEN] Backend image loaded
    ) else (
        echo [RED] Backend image not found. Please ensure images\epack-backend.tar exists.
        exit /b 1
    )
)

REM Check frontend image
docker images | findstr "epack-frontend" >nul
if %errorlevel% neq 0 (
    if exist images\epack-frontend.tar (
        echo [YELLOW] Loading frontend image from tar...
        docker load -i images\epack-frontend.tar
        echo [GREEN] Frontend image loaded
    ) else (
        echo [RED] Frontend image not found. Please ensure images\epack-frontend.tar exists.
        exit /b 1
    )
)

echo [GREEN] Docker images ready
echo.

REM Start services
echo [BLUE] Starting ePACK Application...
echo.
docker-compose up -d

echo.
echo [GREEN] ePACK stack started successfully
echo.
echo [BLUE] Container Status:
docker-compose ps
echo.
echo [BLUE] Access URLs:
echo    Frontend:  http://localhost:3000
echo    Backend:   http://localhost:8080
echo    Health:    http://localhost:8080/health
echo.
echo [GREEN] ePACK is ready!
pause
