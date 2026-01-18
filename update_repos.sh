#!/bin/bash
# ==================================================================================
# Local OpenWrt & MTK-Feeds Repository Update Script (Verbose & Tiered Recovery)
# ==================================================================================

set -uo pipefail

# --- Configuration ---
readonly OPENWRT_REPO_PATH="/home/user/repo/openwrt"
readonly MTK_FEEDS_REPO_PATH="/home/uder/repo/mtk-openwrt-feeds"
readonly LOG_FILE="/home/user/repo/repo_update.log"

# Repository Remote URLs
readonly OPENWRT_REMOTE_URL="https://git.openwrt.org/openwrt/openwrt.git"
readonly MTK_FEEDS_REMOTE_URL="https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds"

# --- Logging Function ---
log_message() {
    local level="$1"
    local message="$2"
    echo "--------------------------------------------------" >> "$LOG_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
    echo "--------------------------------------------------" >> "$LOG_FILE"
}

# --- Function to update, repair, or re-clone ---
update_repo() {
    local repo_path="$1"
    local repo_name="$2"
    local remote_url="$3"

    log_message "INFO" "Starting process for $repo_name"

    if [ ! -d "$repo_path/.git" ]; then
        log_message "WARN" "Repository $repo_name not found. Performing initial clone..."
        if git clone "$remote_url" "$repo_path" >> "$LOG_FILE" 2>&1; then
            log_message "INFO" "Initial clone successful."
            return
        else
            log_message "ERROR" "Failed to perform initial clone."
            return 1
        fi
    fi

    cd "$repo_path" || { log_message "ERROR" "Could not enter directory $repo_path"; return 1; }

    echo "[1/3] Attempting standard git pull..." | tee -a "$LOG_FILE"
    if git pull >> "$LOG_FILE" 2>&1; then
        log_message "INFO" "[SUCCESS] $repo_name updated normally."
        cd ..
        return
    fi

    log_message "WARN" "[2/3] Pull failed. Attempting Hard Reset..."
    if git fetch --all >> "$LOG_FILE" 2>&1 && git reset --hard @{u} >> "$LOG_FILE" 2>&1; then
        log_message "INFO" "[SUCCESS] $repo_name recovered via Hard Reset."
        cd ..
        return
    fi

    log_message "CRITICAL" "[3/3] Hard Reset failed. Deleting and re-cloning..."
    cd ..
    rm -rf "$repo_path"
    
    if git clone "$remote_url" "$repo_path" >> "$LOG_FILE" 2>&1; then
        log_message "INFO" "[SUCCESS] $repo_name restored via fresh clone."
    else
        log_message "ERROR" "FATAL: Could not restore $repo_name."
    fi
}

# --- Main Execution ---
touch "$LOG_FILE"

update_repo "$OPENWRT_REPO_PATH" "OpenWrt" "$OPENWRT_REMOTE_URL"
update_repo "$MTK_FEEDS_REPO_PATH" "MTK-Feeds" "$MTK_FEEDS_REMOTE_URL"

# --- Log Rotation (Increased to 5000 lines to account for verbose git logs) ---
if [ -f "$LOG_FILE" ]; then
    tail -n 5000 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

log_message "INFO" "Update cycle finished."

