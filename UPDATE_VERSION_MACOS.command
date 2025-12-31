#!/bin/bash
cd "$(dirname "$0")"
chmod +x scripts/*.sh
./scripts/upgrade.sh
