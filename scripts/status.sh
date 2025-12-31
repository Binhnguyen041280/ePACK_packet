#!/bin/bash
# ============================================================================
# ePACK Docker - Status Script
# Check the status of ePACK containers and services
# ============================================================================


# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"

# Detect Docker Compose version
if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
elif docker-compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}❌ Error: Docker Compose not found.${NC}"
    exit 1
fi
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 ePACK Docker - System Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if docker-compose.yml exists
if [ ! -f docker-compose.yml ]; then
    echo -e "${RED}❌ docker-compose.yml not found${NC}"
    exit 1
fi

# Container Status
echo -e "${CYAN}🐳 Container Status:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

RUNNING=$(docker-compose ps --services --filter "status=running" 2>/dev/null | wc -l)
TOTAL=$(docker-compose ps --services 2>/dev/null | wc -l)

if [ $RUNNING -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No containers running${NC}"
    echo -e "${YELLOW}   Start with: ./start.sh${NC}"
else
    $DOCKER_COMPOSE ps
    echo ""

    # Show resource usage
    echo -e "${CYAN}💻 Resource Usage:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" $(docker-compose ps -q 2>/dev/null)

    echo ""

    # Health Check
    echo -e "${CYAN}🏥 Health Check:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check backend
    echo -n "Backend (8080):  "
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        BACKEND_STATUS=$(curl -s http://localhost:8080/health | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        echo -e "${GREEN}✅ Healthy${NC} (status: $BACKEND_STATUS)"

        # Show backend details
        BACKEND_VERSION=$(curl -s http://localhost:8080/health | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        if [ ! -z "$BACKEND_VERSION" ]; then
            echo "                 Version: $BACKEND_VERSION"
        fi
    else
        echo -e "${RED}❌ Unhealthy${NC}"
    fi

    # Check frontend
    echo -n "Frontend (3000): "
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null | grep -q "200"; then
        echo -e "${GREEN}✅ Healthy${NC}"
    else
        echo -e "${RED}❌ Unhealthy${NC}"
    fi

    echo ""
fi

# Docker Images
echo -e "${CYAN}📦 Docker Images:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" | grep -E "REPOSITORY|vtrack"
echo ""

# Docker Volumes
echo -e "${CYAN}💾 Docker Volumes:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
VOLUMES=$(docker volume ls --filter "name=vtrack" --format "{{.Name}}" | wc -l)
if [ $VOLUMES -gt 0 ]; then
    echo -e "${GREEN}Found $VOLUMES volumes:${NC}"
    docker volume ls --filter "name=vtrack" --format "table {{.Name}}\t{{.Driver}}\t{{.Size}}"

    # Show volume sizes if available
    echo ""
    echo -e "${YELLOW}Volume Usage:${NC}"
    for vol in $(docker volume ls --filter "name=vtrack" --format "{{.Name}}"); do
        SIZE=$(docker system df -v 2>/dev/null | grep "$vol" | awk '{print $3}' || echo "N/A")
        echo "  $vol: $SIZE"
    done
else
    echo -e "${YELLOW}⚠️  No volumes found${NC}"
fi
echo ""

# Network
echo -e "${CYAN}🌐 Docker Networks:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if docker network ls | grep -q vtrack-network; then
    docker network inspect vtrack-network --format "Name: {{.Name}}\nDriver: {{.Driver}}\nContainers: {{len .Containers}}"
    echo ""

    # Show connected containers
    if [ $(docker network inspect vtrack-network --format "{{len .Containers}}") -gt 0 ]; then
        echo -e "${YELLOW}Connected Containers:${NC}"
        docker network inspect vtrack-network --format '{{range $k, $v := .Containers}}  - {{$v.Name}} ({{$v.IPv4Address}}){{"\n"}}{{end}}'
    fi
else
    echo -e "${YELLOW}⚠️  Network 'vtrack-network' not found${NC}"
fi
echo ""

# Access URLs
if [ $RUNNING -gt 0 ]; then
    echo -e "${CYAN}🌐 Access URLs:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Frontend:  ${GREEN}http://localhost:3000${NC}"
    echo -e "Backend:   ${GREEN}http://localhost:8080${NC}"
    echo -e "Health:    ${GREEN}http://localhost:8080/health${NC}"
    echo -e "License:   ${GREEN}http://localhost:8080/api/license-status${NC}"
    echo ""
fi

# Quick Commands
echo -e "${CYAN}⚡ Quick Commands:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ $RUNNING -gt 0 ]; then
    echo "  View logs:      ./logs.sh"
    echo "  Stop services:  ./stop.sh"
    echo "  Restart:        $DOCKER_COMPOSE restart"
    echo "  Shell (backend): docker exec -it vtrack-backend bash"
else
    echo "  Start services: ./start.sh"
    echo "  Start dev mode: ./start.sh --dev"
fi
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Status check complete${NC}"
