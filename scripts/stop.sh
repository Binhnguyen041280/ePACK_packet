#!/bin/bash
# ============================================================================
# ePACK Docker - Stop Script
# Stops the ePACK application stack using Docker Compose
# ============================================================================


# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"
set -e

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

echo -e "${BLUE}🛑 ePACK Docker - Stopping Application Stack${NC}"
echo ""

# Parse command line arguments
REMOVE_VOLUMES=false
REMOVE_ORPHANS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --volumes|-v)
            REMOVE_VOLUMES=true
            shift
            ;;
        --orphans|-o)
            REMOVE_ORPHANS=true
            shift
            ;;
        --all|-a)
            REMOVE_VOLUMES=true
            REMOVE_ORPHANS=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./stop.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --volumes, -v           Remove volumes (WARNING: Data loss!)"
            echo "  --orphans, -o           Remove orphan containers"
            echo "  --all, -a               Remove volumes and orphans"
            echo "  --help, -h              Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./stop.sh               # Stop services, keep data"
            echo "  ./stop.sh --volumes     # Stop services and remove volumes"
            echo "  ./stop.sh --all         # Stop and clean everything"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Run './stop.sh --help' for usage information"
            exit 1
            ;;
    esac
done

# Build docker-compose command
echo -e "${YELLOW}Stopping ePACK services...${NC}"
COMPOSE_CMD="$DOCKER_COMPOSE down"

if [ "$REMOVE_ORPHANS" = true ]; then
    COMPOSE_CMD="$COMPOSE_CMD --remove-orphans"
    echo -e "${YELLOW}⚠️  Removing orphan containers${NC}"
fi

if [ "$REMOVE_VOLUMES" = true ]; then
    echo -e "${RED}⚠️  WARNING: This will remove all volumes and delete data!${NC}"
    echo -e "${RED}   - Database files${NC}"
    echo -e "${RED}   - Logs${NC}"
    echo -e "${RED}   - Uploads${NC}"
    echo -e "${RED}   - Cache${NC}"
    echo -e "${RED}   - Video input/output${NC}"
    echo ""
    read -p "Are you sure you want to remove volumes? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        COMPOSE_CMD="$COMPOSE_CMD -v"
        echo -e "${RED}🗑️  Removing volumes...${NC}"
    else
        echo -e "${GREEN}✅ Volumes preserved${NC}"
    fi
fi

# Execute the command
echo ""
eval $COMPOSE_CMD

echo ""
echo -e "${GREEN}✅ ePACK stack stopped successfully${NC}"
echo ""

# Show remaining containers
REMAINING=$(docker ps -a --filter "name=vtrack" --format "{{.Names}}" | wc -l)
if [ $REMAINING -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some containers still exist:${NC}"
    docker ps -a --filter "name=vtrack"
    echo ""
    echo -e "${YELLOW}   To remove them: docker rm -f \$(docker ps -a -q --filter name=vtrack)${NC}"
    echo ""
fi

# Show remaining volumes
if [ "$REMOVE_VOLUMES" != true ]; then
    VOLUMES=$(docker volume ls --filter "name=vtrack" --format "{{.Name}}" | wc -l)
    if [ $VOLUMES -gt 0 ]; then
        echo -e "${BLUE}📦 Data volumes preserved:${NC}"
        docker volume ls --filter "name=vtrack"
        echo ""
        echo -e "${BLUE}   To remove volumes: ./stop.sh --volumes${NC}"
        echo ""
    fi
fi

echo -e "${GREEN}🎉 Done!${NC}"
