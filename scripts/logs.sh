#!/bin/bash
# ============================================================================
# ePACK Docker - Logs Script
# View logs from ePACK containers
# ============================================================================


# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
SERVICE=""
FOLLOW="-f"
TAIL="100"
TIMESTAMPS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        backend|frontend|be|fe)
            if [ "$1" = "be" ]; then
                SERVICE="backend"
            elif [ "$1" = "fe" ]; then
                SERVICE="frontend"
            else
                SERVICE="$1"
            fi
            shift
            ;;
        --no-follow|-n)
            FOLLOW=""
            shift
            ;;
        --tail|-t)
            TAIL="$2"
            shift 2
            ;;
        --all|-a)
            TAIL="all"
            shift
            ;;
        --timestamps|--time)
            TIMESTAMPS="--timestamps"
            shift
            ;;
        --help|-h)
            echo -e "${BLUE}ePACK Docker - Logs Viewer${NC}"
            echo ""
            echo "Usage: ./logs.sh [SERVICE] [OPTIONS]"
            echo ""
            echo "Services:"
            echo "  backend, be       Show backend logs only"
            echo "  frontend, fe      Show frontend logs only"
            echo "  (none)            Show logs from all services"
            echo ""
            echo "Options:"
            echo "  --no-follow, -n      Don't follow logs (exit after display)"
            echo "  --tail, -t N         Show last N lines (default: 100)"
            echo "  --all, -a            Show all logs"
            echo "  --timestamps         Show timestamps"
            echo "  --help, -h           Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./logs.sh                     # Follow all logs (last 100 lines)"
            echo "  ./logs.sh backend             # Follow backend logs only"
            echo "  ./logs.sh frontend -n         # Show frontend logs and exit"
            echo "  ./logs.sh --tail 500          # Show last 500 lines from all"
            echo "  ./logs.sh backend --all       # Show all backend logs"
            echo "  ./logs.sh --timestamps        # Show logs with timestamps"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Run './logs.sh --help' for usage information"
            exit 1
            ;;
    esac
done

# Build docker-compose logs command
CMD="docker-compose logs"

if [ ! -z "$FOLLOW" ]; then
    CMD="$CMD $FOLLOW"
fi

if [ ! -z "$TIMESTAMPS" ]; then
    CMD="$CMD $TIMESTAMPS"
fi

if [ "$TAIL" != "all" ]; then
    CMD="$CMD --tail=$TAIL"
fi

if [ ! -z "$SERVICE" ]; then
    CMD="$CMD $SERVICE"
fi

# Display header
echo -e "${BLUE}📝 ePACK Docker Logs${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ! -z "$SERVICE" ]; then
    echo -e "${YELLOW}Service: $SERVICE${NC}"
else
    echo -e "${YELLOW}Services: All (backend + frontend)${NC}"
fi

if [ ! -z "$FOLLOW" ]; then
    echo -e "${YELLOW}Mode: Follow (Ctrl+C to exit)${NC}"
else
    echo -e "${YELLOW}Mode: Display and exit${NC}"
fi

if [ "$TAIL" = "all" ]; then
    echo -e "${YELLOW}Lines: All${NC}"
else
    echo -e "${YELLOW}Lines: Last $TAIL${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if containers are running
RUNNING=$(docker-compose ps --services --filter "status=running" | wc -l)
if [ $RUNNING -eq 0 ]; then
    echo -e "${RED}❌ No running containers found${NC}"
    echo -e "${YELLOW}Start the stack with: ./start.sh${NC}"
    exit 1
fi

# Execute the command
eval $CMD
