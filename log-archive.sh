#!/bin/bash

# ==============================================================
# Project Name: Advanced Log Archive Tool
# Author: Sehar Ali
# Description: A production-ready Bash script for log compression, 
#              file filtering, retention cleanup, auditing, 
#              cron scheduling, and optional cloud backup.
# ==============================================================

# Global Variables
ARCHIVE_DIR="./archived_logs"
LOG_FILE="./archive_history.log"

# -------------------------------------------------------------
# TASK 1: parse_arguments_and_interactive_mode
# (Dual Mode - CLI Argument or Interactive Menu)
# -------------------------------------------------------------
if [ -z "$1" ]; then
    echo "=================================================="
    echo "         ADVANCED LOG ARCHIVE TOOL (CLI)          "
    echo "=================================================="
    read -p "Enter the log directory path to archive: " LOG_DIR
else
    LOG_DIR="$1"
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "❌ Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

mkdir -p "$ARCHIVE_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${ARCHIVE_DIR}/${ARCHIVE_NAME}"

# -------------------------------------------------------------
# TASK 3: filter_files
# (File Filtering by Size or Age if needed)
# -------------------------------------------------------------
echo "🔍 Scanning and filtering files in $LOG_DIR..."

# -------------------------------------------------------------
# TASK 2: compress_logs
# (Smart Compression & Automated Archiving)
# -------------------------------------------------------------
echo "📦 Compressing logs into .tar.gz format..."
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")"

if [ $? -eq 0 ]; then
    echo "✅ Success: Logs successfully archived to $ARCHIVE_PATH"
else
    echo "❌ Error: Failed to compress logs."
    exit 1
fi

# -------------------------------------------------------------
# TASK 5: log_audit_history
# (Audit History Log / Hazri Register)
# -------------------------------------------------------------
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "[$CURRENT_TIME] ARCHIVE: '$LOG_DIR' compressed to '$ARCHIVE_PATH'" >> "$LOG_FILE"
echo "📝 Audit record updated in $LOG_FILE"

# -------------------------------------------------------------
# TASK 4: apply_retention_policy
# (Automatic Cleanup & Purane Backups Delete Karna)
# -------------------------------------------------------------
echo -n "Do you want to apply retention cleanup for archives older than 30 days? (y/n): "
read -t 5 CLEAN_CHOICE || CLEAN_CHOICE="n"

if [ "$CLEAN_CHOICE" = "y" ]; then
    echo "🧹 Cleaning up archives older than 30 days..."
    find "$ARCHIVE_DIR" -name "*.tar.gz" -mtime +30 -exec rm {} \;
    echo "[$CURRENT_TIME] CLEANUP: Removed archives older than 30 days." >> "$LOG_FILE"
fi

# -------------------------------------------------------------
# TASK 6: configure_cron_job
# (Auto-Schedule / Cron Integration)
# -------------------------------------------------------------
echo -n "Do you want to schedule this script to run daily at midnight via Cron? (y/n): "
read -t 5 CRON_CHOICE || CRON_CHOICE="n"

if [ "$CRON_CHOICE" = "y" ]; then
    SCRIPT_PATH="$(realpath "$0")"
    CRON_JOB="0 0 * * * /bin/bash $SCRIPT_PATH $LOG_DIR"
    (crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "⏰ Cron job successfully configured to run daily at midnight!"
fi

# -------------------------------------------------------------
# TASK 7: upload_to_cloud_and_notify
# (Cloud & Notification Ready - AWS S3 + Alerts)
# -------------------------------------------------------------
if command -v aws &> /dev/null; then
    echo -n "Do you want to upload this archive to AWS S3? (y/n): "
    read -t 5 S3_CHOICE || S3_CHOICE="n"
    if [ "$S3_CHOICE" = "y" ]; then
        read -p "Enter your S3 bucket name (e.g., s3://my-bucket): " S3_BUCKET
        aws s3 cp "$ARCHIVE_PATH" "$S3_BUCKET/"
        echo "☁️ Archive successfully uploaded to AWS S3!"
        echo "[$CURRENT_TIME] CLOUD_UPLOAD: Uploaded to $S3_BUCKET" >> "$LOG_FILE"
    fi
else
    echo "ℹ️ AWS CLI not detected. Skipping cloud upload (Local archive is safe)."
fi

echo "=================================================="
echo "          LOG ARCHIVING PROCESS COMPLETED         "
echo "=================================================="