#!/bin/bash

# ==============================================================================
# Script Name: automated_backup.sh
# Description: Incremental Rsync Backup with Rotation and Retention Policy
# Author: [Your Name]
# Context: System Administration 2 - Question 03
# ==============================================================================

# --- Configuration Variables ---
# Source: Server A (10.0.0.6) Data Directory
# Note: Requires SSH Key-based authentication to be configured first.
SOURCE_DIR="root@10.0.0.6:/data/"

# Destination: Local Client Directory
BACKUP_ROOT="/tmp/backup"

# Timestamp format for rotation (YYYY-MM-DD_HH-MM-SS)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Retention Policy: Delete backups older than X days
RETENTION_DAYS=7

# --- Step 1: Backup Rotation (Requirement: Rename previous folder) ---
# If a current 'backup' folder exists, rename it to archive it before new sync.
if [ -d "$BACKUP_ROOT" ]; then
    echo "[INFO] Rotating previous backup..."
    mv "$BACKUP_ROOT" "${BACKUP_ROOT}_${TIMESTAMP}"
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] Previous backup renamed to ${BACKUP_ROOT}_${TIMESTAMP}"
    else
        echo "[ERROR] Failed to rotate backup directory."
        exit 1
    fi
fi

# --- Step 2: Perform Rsync Backup (Requirement: Incremental backup) ---
echo "[INFO] Starting Rsync from Server A (${SOURCE_DIR})..."

# Create fresh destination directory
mkdir -p "$BACKUP_ROOT"

# Run rsync with flags:
# -a: Archive mode (preserves permissions, times, symbolic links)
# -v: Verbose output
# -z: Compress file data during the transfer
rsync -avz "$SOURCE_DIR" "$BACKUP_ROOT"

# Check exit status of rsync
if [ $? -eq 0 ]; then
    echo "[SUCCESS] Backup completed successfully at $(date)"
else
    echo "[ERROR] Backup failed! Please check SSH connectivity and permissions."
    exit 1
fi

# --- Step 3: Retention Policy (Requirement: Delete older than 7 days) ---
echo "[INFO] Checking for old backups to purge (Older than ${RETENTION_DAYS} days)..."

# Find directories named "backup_*" in /tmp that are older than 7 days and delete them
find /tmp -maxdepth 1 -name "backup_*" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;

echo "[INFO] Cleanup operation complete."
echo "======================================================="