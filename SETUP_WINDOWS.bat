@echo off
setlocal EnableDelayedExpansion

echo ========================================================
echo           ePACK Production Setup (Windows)
echo ========================================================

:: 1. Check for .env file
if exist .env (
    echo [WARNING] .env file already exists.
    set /p overwrite="Do you want to overwrite it? (y/N): "
    if /i "!overwrite!" neq "y" (
        echo Setup cancelled. Existing .env file preserved.
        goto :EOF
    )
    echo Backing up existing .env to .env.bak...
    copy /y .env .env.bak >nul
)

:: 2. Copy template
echo Creating .env from template...
if not exist .env.docker.example (
    echo [ERROR] .env.docker.example not found!
    pause
    exit /b 1
)
copy /y .env.docker.example .env >nul

:: 3. Generate Secrets using PowerShell
echo Generating security keys...

:: Generate SECRET_KEY (32 bytes hex)
for /f "delims=" %%i in ('powershell -Command "[convert]::ToHexString((1..32 | %%{ Get-Random -Minimum 0 -Maximum 256 }))"') do set SECRET_KEY=%%i

:: Generate ENCRYPTION_KEY (Fernet compatible - 32 bytes base64 urlsafe)
:: Note: Fernet requires URL-safe Base64. Standard Base64 is close enough for many libs but let's try to be precise.
:: PowerShell's [Convert]::ToBase64String uses + and /, we need - and _ for URL safe.
for /f "delims=" %%i in ('powershell -Command "$bytes = new-object byte[] 32; (new-object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes); [Convert]::ToBase64String($bytes).Replace('+', '-').Replace('/', '_').TrimEnd('=')"') do set ENCRYPTION_KEY=%%i

:: 4. Update .env file
echo Updating configuration...
powershell -Command "(Get-Content .env) -replace '<REPLACE_WITH_YOUR_SECRET_KEY>', '%SECRET_KEY%' -replace '<REPLACE_WITH_YOUR_ENCRYPTION_KEY>', '%ENCRYPTION_KEY%' | Set-Content .env"

:: 5. Add EPACK_INSTALL_DIR to .env
echo. >> .env
echo # Installation directory for auto-restart >> .env
echo EPACK_INSTALL_DIR=%CD% >> .env

:: 6. Add scripts mount to docker-compose.yml
echo Adding scripts mount to docker-compose.yml...
powershell -Command "if (-not (Select-String -Path docker-compose.yml -Pattern './scripts:/app/scripts' -Quiet)) { (Get-Content docker-compose.yml) -replace '      - ./.env:/app/.env:rw', '      - ./.env:/app/.env:rw`n      - ./scripts:/app/scripts:ro' | Set-Content docker-compose.yml; Write-Host 'Scripts mount added' } else { Write-Host 'Scripts mount already exists' }"

echo.
echo ========================================================
echo                 Setup Complete!
echo ========================================================
echo 1. Configuration saved to: .env
echo 2. Secret keys generated and applied.
echo 3. Scripts mount added for auto-restart capability.
echo.

:: 7. Auto-start ePACK
echo Starting ePACK automatically...
call scripts\start.bat
