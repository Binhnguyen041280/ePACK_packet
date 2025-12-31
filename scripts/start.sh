#!/bin/bash
# ============================================================================
# ePACK Docker - Start Script
# Starts the ePACK application stack using Docker Compose
# ============================================================================

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"
echo "Working directory: $PROJECT_ROOT"

# Detect Docker Compose version
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif docker-compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}❌ Error: Docker Compose not found.${NC}"
    exit 1
fi

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ePACK Docker - Starting Application Stack${NC}"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from template...${NC}"
    if [ -f .env.docker.example ]; then
        cp .env.docker.example .env
        echo -e "${YELLOW}⚠️  IMPORTANT: Edit .env and configure SECRET_KEY and ENCRYPTION_KEY${NC}"
        echo -e "${YELLOW}   Generate keys with:${NC}"
        echo -e "${YELLOW}   python3 -c \"import secrets; print('SECRET_KEY=' + secrets.token_hex(32))\"${NC}"
        echo -e "${YELLOW}   python3 -c \"from cryptography.fernet import Fernet; print('ENCRYPTION_KEY=' + Fernet.generate_key().decode())\"${NC}"
        echo ""
        read -p "Press Enter after configuring .env to continue..."
    else
        echo -e "${RED}❌ .env.docker.example not found${NC}"
        exit 1
    fi
fi

# Check if Docker images exist locally, otherwise they will be pulled automatically
echo -e "${BLUE}📦 Checking for Docker images...${NC}"
if ! docker images | grep -q "epack-backend"; then
    echo -e "${YELLOW}ℹ️  Images not found locally. They will be pulled from Registry on start.${NC}"
fi
echo -e "${GREEN}✅ Ready to start${NC}"
echo ""

# Parse command line arguments
DETACHED="-d"

while [[ $# -gt 0 ]]; do
    case $1 in
        --attach|-a)
            DETACHED=""
            shift
            ;;
        --help|-h)
            echo "Usage: ./start.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --attach, -a            Run in attached mode (show logs)"
            echo "  --help, -h              Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./start.sh                    # Start services (detached)"
            echo "  ./start.sh --attach           # Start and show logs"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Run './start.sh --help' for usage information"
            exit 1
            ;;
    esac
done

# Start services
echo -e "${BLUE}🚀 Starting ePACK Application...${NC}"
echo ""
$DOCKER_COMPOSE up $DETACHED

# If running in detached mode, show status
if [ ! -z "$DETACHED" ]; then
    echo ""
    echo -e "${GREEN}✅ ePACK stack started successfully${NC}"
    echo ""
    echo -e "${BLUE}📊 Container Status:${NC}"
    $DOCKER_COMPOSE ps
    echo ""
    echo -e "${BLUE}🌐 Access URLs:${NC}"
    echo -e "   Frontend:  ${GREEN}http://localhost:3000${NC}"
    echo -e "   Backend:   ${GREEN}http://localhost:8080${NC}"
    echo -e "   Health:    ${GREEN}http://localhost:8080/health${NC}"
    echo ""
    echo -e "${BLUE}📝 Useful Commands:${NC}"
    echo "   View logs:      ./logs.sh"
    echo "   Stop services:  ./stop.sh"
    echo "   Restart:        docker-compose restart"
    echo ""
    echo -e "${BLUE}🔍 Health Check:${NC}"
    echo "   Waiting for services to be healthy..."
    sleep 5

    # Check backend health
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo -e "   Backend:  ${GREEN}✅ Healthy${NC}"
    else
        echo -e "   Backend:  ${YELLOW}⚠️  Starting...${NC}"
    fi

    # Check frontend health
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo -e "   Frontend: ${GREEN}✅ Healthy${NC}"
    else
        echo -e "   Frontend: ${YELLOW}⚠️  Starting...${NC}"
    fi

    echo ""
    echo -e "${GREEN}🎉 ePACK is ready!${NC}"
fi
