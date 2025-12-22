#!/bin/bash

# --- CONFIGURATION ---
mkdir -p logs
LOG_FILE="logs/process_log_$(date +'%Y-%m-%d').log"
VENV_PATH="./venv/bin/activate"

# Cleanup: Delete logs older than 30 days
find logs/ -name "process_log_*.log" -type f -mtime +30 -delete

# Start logging everything
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===================================================="
echo "Starting MaStR Automation: $(date)"
echo "===================================================="

# 1. Activate Virtual Environment
if [ -f "$VENV_PATH" ]; then
    source "$VENV_PATH"
else
    echo "Error: Virtual environment not found."
    exit 1
fi

# 2. Run Import Script
echo "Status: Running Import_MaStR.py..."
python3 Import_MaStR.py

# 3. Run Analysis Script
echo "Status: Running Analysis_MaStR.py..."
python3 Analysis_MaStR.py

# 4. Sync with GitHub 
echo "Status: Syncing with GitHub..."
# Get any HTML updates from laptop
git pull --rebase origin main

# Add only the specific results
git add -f solar_berlin_yearly.csv
git commit -m "Auto-update solar data: $(date +'%Y-%m-%d')"
git push origin main

echo "===================================================="
echo "Finished Successfully: $(date)"
echo "===================================================="
