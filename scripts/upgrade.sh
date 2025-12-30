#!/bin/bash

# upgrade.sh - ePACK Version Upgrade Script (Registry-based)
# This script pulls the latest images from GHCR and restarts the stack.

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"

# Load colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 ePACK Software Upgrade (Cloud-based)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 1. Pre-check: Check if docker-compose.yml exists
if [ ! -f docker-compose.yml ]; then
    echo -e "${RED}❌ Error: docker-compose.yml not found in $PROJECT_ROOT${NC}"
    exit 1
fi

# 2. Pre-check: Internet connection and GHCR accessibility
echo -e "🔍 Checking connection to GitHub Container Registry..."
if ! docker pull ghcr.io/binhnguyen041280/epack-backend:latest > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Cannot connect to registry.${NC}"
    echo -e "${YELLOW}Please check your internet connection or ensuring symbols are public.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Registry connection confirmed.${NC}"

# 3. Safe Pull: Download new layers while app is still running
echo ""
echo -e "${BLUE}📦 Step 1/3: Downloading new version layers...${NC}"
docker compose pull backend frontend

# 4. Atomic Restart: Apply new images
echo ""
echo -e "${BLUE}🔄 Step 2/3: Applying updates (Restarting services)...${NC}"
./scripts/stop.sh
sleep 2
./scripts/start.sh

# 5. Post-check: Verify health
echo ""
echo -e "${BLUE}🏥 Step 3/3: Verifying system health...${NC}"
sleep 5
./scripts/status.sh

echo ""
echo -e "${GREEN}🎉 Upgrade Complete! You are now running the latest version.${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
