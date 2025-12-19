#!/bin/bash

# setup_prod.sh - Automated Production Setup Script for ePACK/ePACK
# This script configures the environment for production deployment.

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"
echo "Working directory: $PROJECT_ROOT"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ePACK Production Setup ===${NC}"

# 1. Check for .env file
if [ -f .env ]; then
    echo -e "${YELLOW}Warning: .env file already exists.${NC}"
    read -p "Do you want to overwrite it? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. Existing .env file preserved."
        exit 0
    fi
    echo "Backing up existing .env to .env.bak..."
    cp .env .env.bak
fi

# 2. Copy template
echo "Creating .env from template..."
if [ ! -f .env.docker.example ]; then
    echo -e "${RED}Error: .env.docker.example not found!${NC}"
    exit 1
fi
cp .env.docker.example .env

# 3. Generate Secrets
echo "Generating security keys..."

# Function to generate random hex string
generate_secret() {
    if command -v python3 &>/dev/null; then
        python3 -c "import secrets; print(secrets.token_hex(32))"
    elif command -v python &>/dev/null; then
        python -c "import secrets; print(secrets.token_hex(32))"
    elif command -v openssl &>/dev/null; then
        openssl rand -hex 32
    else
        echo -e "${RED}Error: Python or OpenSSL required to generate keys.${NC}"
        exit 1
    fi
}

# Function to generate Fernet key (requires python cryptography or specific format)
generate_encryption_key() {
     if command -v python3 &>/dev/null; then
        # Try to use cryptography if installed, otherwise fallback to base64 of 32 random bytes
        if python3 -c "from cryptography.fernet import Fernet" 2>/dev/null; then
             python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
        else
             # Fallback: Generate 32 bytes and base64 encode it (urlsafe)
             python3 -c "import secrets, base64; print(base64.urlsafe_b64encode(secrets.token_bytes(32)).decode())"
        fi
    elif command -v python &>/dev/null; then
         if python -c "from cryptography.fernet import Fernet" 2>/dev/null; then
             python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
        else
             python -c "import secrets, base64; print(base64.urlsafe_b64encode(secrets.token_bytes(32)).decode())"
        fi
    elif command -v openssl &>/dev/null; then
        openssl rand -base64 32
    else
        echo -e "${RED}Error: Python or OpenSSL required to generate keys.${NC}"
        exit 1
    fi
}

SECRET_KEY=$(generate_secret)
ENCRYPTION_KEY=$(generate_encryption_key)

# 4. Update .env file
# MacOS sed requires empty string for -i
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_OPTS=(-i "")
else
    SED_OPTS=(-i)
fi

# Use | as delimiter to avoid issues with / in keys
sed "${SED_OPTS[@]}" "s|<REPLACE_WITH_YOUR_SECRET_KEY>|$SECRET_KEY|g" .env
sed "${SED_OPTS[@]}" "s|<REPLACE_WITH_YOUR_ENCRYPTION_KEY>|$ENCRYPTION_KEY|g" .env

# 5. Set Permissions
echo "Securing .env file..."
chmod 600 .env

# 6. Add EPACK_INSTALL_DIR to .env for auto-restart capability
echo "" >> .env
echo "# Installation directory for auto-restart" >> .env
echo "EPACK_INSTALL_DIR=$PROJECT_ROOT" >> .env

# 7. Add scripts mount to docker-compose.yml for auto-restart from container
echo "Adding scripts mount to docker-compose.yml..."
if [ -f docker-compose.yml ]; then
    # Check if scripts mount already exists
    if ! grep -q "./scripts:/app/scripts" docker-compose.yml; then
        # Use sed to add scripts mount after .env mount line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's|      - ./.env:/app/.env:rw|      - ./.env:/app/.env:rw\n      - ./scripts:/app/scripts:ro|g' docker-compose.yml
        else
            sed -i 's|      - ./.env:/app/.env:rw|      - ./.env:/app/.env:rw\n      - ./scripts:/app/scripts:ro|g' docker-compose.yml
        fi
        echo "✅ Scripts mount added to docker-compose.yml"
    else
        echo "ℹ️  Scripts mount already exists in docker-compose.yml"
    fi
fi

# 8. Create data directories (including input placeholder)
echo "Creating data directories..."
DATA_DIR="${HOME}/docker/volumes/epack"
mkdir -p "$DATA_DIR/database"
mkdir -p "$DATA_DIR/logs"
mkdir -p "$DATA_DIR/sessions"
mkdir -p "$DATA_DIR/cache"
mkdir -p "$DATA_DIR/uploads"
mkdir -p "$DATA_DIR/output"
mkdir -p "$DATA_DIR/input"   # Placeholder for LOCAL_VIDEO_PATH
echo "Data directory created: $DATA_DIR"

echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo -e "1. Configuration saved to: ${YELLOW}.env${NC}"
echo -e "2. Secret keys generated and applied."
echo -e "3. Scripts mount added for auto-restart capability."
echo ""

# 9. Auto-start ePACK
echo -e "${GREEN}🚀 Starting ePACK automatically...${NC}"
./scripts/start.sh
