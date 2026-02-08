#!/bin/bash
# ==================================================================================
# Single-Target OpenWrt Update Script (Centralized Paths)
# ==================================================================================

set -uo pipefail

# --- BASE PATH (Change this ONE line to move everything) ---
readonly REPO_BASE_DIR="/home/user/repo/openwrt"

# --- Target Configuration (Defaults) ---
DEFAULT_BRANCH="openwrt-25.12"
DEFAULT_OPENWRT_DIR="${REPO_BASE_DIR}/openwrt"

readonly MTK_REPO_PATH="${REPO_BASE_DIR}/mtk-openwrt-feeds"
readonly LOG_FILE="${REPO_BASE_DIR}/repo_update.log"

readonly OPENWRT_PRIMARY="https://git.openwrt.org/openwrt/openwrt.git"
readonly OPENWRT_BACKUP="https://github.com/openwrt/openwrt.git"
readonly MTK_PRIMARY="https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds"

# INPUT HANDLING

TARGET_BRANCH="${1:-$DEFAULT_BRANCH}"

TARGET_DIR="${2:-$DEFAULT_OPENWRT_DIR}"

# FUNCTIONS

log_message() {
    local level="$1"
    local message="$2"
    echo "--------------------------------------------------" | tee -a "$LOG_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
    echo "--------------------------------------------------" | tee -a "$LOG_FILE"
}

exec_cmd() {
    "$@" 2>&1 | tee -a "$LOG_FILE"
    return ${PIPESTATUS[0]}
}

safe_reclone() {
    local repo_path="$1"
    local remote_url="$2"
    local branch="$3"
    local tmp_path="${repo_path}_tmp_clone"

    log_message "CRITICAL" "Attempting SAFE RE-CLONE from $remote_url..."
    rm -rf "$tmp_path"

    if exec_cmd git clone --branch "$branch" "$remote_url" "$tmp_path"; then
        log_message "INFO" "Clone successful. Swapping directories..."
        rm -rf "$repo_path"
        mv "$tmp_path" "$repo_path"
        log_message "INFO" "[SUCCESS] Repo restored via fresh clone."
        return 0
    else
        log_message "ERROR" "FATAL: Server appears down (Clone failed). Preserving existing repository."
        rm -rf "$tmp_path"
        return 1
    fi
}

update_repo() {
    local repo_path="$1"
    local repo_name="$2"
    local primary_url="$3"
    local backup_url="$4"
    local target_branch="$5"

    log_message "INFO" "Starting update for $repo_name (Branch: $target_branch)"

    if [ ! -d "$repo_path/.git" ]; then
        log_message "WARN" "$repo_name not found. Attempting initial clone..."
        if exec_cmd git clone --branch "$target_branch" "$primary_url" "$repo_path"; then return 0; fi
        if [ -n "$backup_url" ] && exec_cmd git clone --branch "$target_branch" "$backup_url" "$repo_path"; then return 0; fi
        log_message "ERROR" "Could not clone $repo_name from any source."
        return 1
    fi

    cd "$repo_path" || return 1
    git fetch --all > /dev/null 2>&1 

    echo ">>> [1/3] Pulling from Primary..." | tee -a "$LOG_FILE"
    if exec_cmd git remote set-url origin "$primary_url" && exec_cmd git pull origin "$target_branch"; then
        log_message "INFO" "[SUCCESS] $repo_name updated via Primary."
        return
    fi

    if [ -n "$backup_url" ]; then
        echo ">>> [2/3] Primary failed. Switching to Backup Remote..." | tee -a "$LOG_FILE"
        if exec_cmd git remote set-url origin "$backup_url" && exec_cmd git pull origin "$target_branch"; then
            log_message "INFO" "[SUCCESS] $repo_name updated via Backup."
            return
        fi
    fi

    log_message "WARN" "Pulls failed. Attempting Hard Reset..."
    exec_cmd git remote set-url origin "$primary_url"
    if exec_cmd git fetch --all && exec_cmd git reset --hard "origin/$target_branch"; then return; fi

    cd ..
    if safe_reclone "$repo_path" "$primary_url" "$target_branch"; then return; fi
    if [ -n "$backup_url" ] && safe_reclone "$repo_path" "$backup_url" "$target_branch"; then return; fi

    log_message "ERROR" "All attempts failed for $repo_name."
}

# EXECUTION

if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE" 2>/dev/null || echo "Warning: Cannot create log file at $LOG_FILE"
fi

update_repo "$TARGET_DIR" "OpenWrt" "$OPENWRT_PRIMARY" "$OPENWRT_BACKUP" "$TARGET_BRANCH"

update_repo "$MTK_REPO_PATH" "MTK-Feeds" "$MTK_PRIMARY" "" "master"

if [ -f "$LOG_FILE" ]; then
    tail -n 5000 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

log_message "INFO" "Update cycle finished."

