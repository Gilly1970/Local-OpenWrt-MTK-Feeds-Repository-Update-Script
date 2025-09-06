#!/bin/bash
# ==================================================================================
# Local OpenWrt & MTK-Feeds Repository Update Script
# ==================================================================================
# This script is designed to be run automatically (e.g., via a cron job) to
# keep local clones of the OpenWrt and Mediatek Feeds repositories up-to-date.
# It navigates to each repository directory and runs 'git pull' to fetch and
# merge the latest changes from their respective remote branches.
#
# ==================================================================================

set -euo pipefail

# --- Configuration ---
# Please ensure these paths point to the root of your local git repositories.
readonly OPENWRT_REPO_PATH="/home/user/repos/openwrt"
readonly MTK_FEEDS_REPO_PATH="/home/user/repos/mtk-openwrt-feeds"

# --- Function to update a single git repository ---
update_repo() {
    local repo_path="$1"
    local repo_name="$2"

    echo "--- Updating $repo_name repository at $repo_path ---"

    if [ ! -d "$repo_path/.git" ]; then
        echo "ERROR: Git repository not found at: $repo_path. Skipping."
        return
    fi

    (
        cd "$repo_path" || exit
        echo "Currently in $(pwd)"
        echo "Fetching latest changes from remote..."

        if git pull; then
            echo "SUCCESS: $repo_name repository is now up-to-date."
        else
            echo "WARNING: 'git pull' for $repo_name reported an issue. This could be due to local changes or merge conflicts. Please check the repository manually."
        fi
    )
    echo "--------------------------------------------------"
    echo ""
}

# --- Main Execution ---
echo "=================================================="
echo "Starting daily repository update process at $(date)"
echo "=================================================="
echo ""

update_repo "$OPENWRT_REPO_PATH" "OpenWrt"
update_repo "$MTK_FEEDS_REPO_PATH" "Mediatek Feeds"

echo "Update process finished at $(date)."
echo ""

exit 0