#!/bin/bash

# upgrade.sh - ePACK Version Upgrade Script (Registry-based)
# This script pulls the latest images from GHCR and restarts the stack.

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"

# 1. Detect Docker Compose version
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif docker-compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}❌ Error: Docker Compose not found.${NC}"
    exit 1
fi

# 2. Pre-check: Internet connection and GHCR accessibility
echo -e "🔍 Checking connection to GitHub Container Registry..."
if ! $DOCKER_COMPOSE pull backend:latest > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Cannot connect to registry.${NC}"
    echo -e "${YELLOW}Please check your internet connection or ensuring symbols are public.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Registry connection confirmed.${NC}"

# 3. Safe Pull: Download new layers while app is still running
echo ""
echo -e "${BLUE}📦 Step 1/3: Downloading new version layers...${NC}"
$DOCKER_COMPOSE pull backend frontend

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
