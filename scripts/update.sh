#!/bin/bash

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"

echo "🔄 ePACK Configuration Update"
echo "============================="
echo "Stopping services..."
./scripts/stop.sh

echo ""
echo "⏳ Waiting 5 seconds for cleanup..."
sleep 5

echo ""
echo "🚀 Restarting services..."
./scripts/start.sh
