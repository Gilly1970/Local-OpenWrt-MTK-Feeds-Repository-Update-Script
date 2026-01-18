## How to Automate this Script

**Step 1:** Clone this Repo
- Create a repo directory then inside the new directory clone this repo, openwrt and mtk-openwrt-feeds
```csharp
Bash
```
```
cd /home/user/repo
sudo mkdir /home/user/repo
git clone https://github.com/Gilly1970/Local-OpenWrt-MTK-Feeds-Repository-Update-Script.git
git clone https://git.openwrt.org/openwrt/openwrt.git
git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds
```

**Step 2:** Edit repo_update.sh
- Replace `/home/user/repo` with the actual, full path to your new repo.

```csharp
Bash
```
```csharp
 --- Configuration ---
readonly OPENWRT_REPO_PATH="/home/user/repo/openwrt"
readonly MTK_FEEDS_REPO_PATH="/home/user/repo/mtk-openwrt-feeds"
readonly LOG_FILE="/home/user/repo/repo_update.log"
```
**Step 3:** Make the Script Executable
- Script needs the correct permission to run.
 
```csharp
Bash
```
```csharp
cd /home/user/repo
sudo chmod 775 -R /home/user/repo
sudo chmod +x update_repos.sh
```
**Step 4:** Edit Your Crontab
- Next, you'll add a new entry to your user's `crontab`. Run this command to open the editor:
 - (If it's your first time, it might ask you to choose a text editor like `nano`).
```csharp
Bash
```
```csharp
crontab -e
```
**Step 5:** Add the Scheduled Job
- Add the following line to the end of the file. This example will run the script every day at 3:00 AM.
```csharp
0 3 * * * /home/gilly/user/update_repos.sh >> /home/user/repos/update.log 2>&1
```
>[!IMPORTANT]
>Replace `/path/to/your/update_repos.sh` with the actual, full path to where you saved the script.
>The `>> /path/to/your/update.log 2>&1` part is optional but highly recommended. It will save the output of the script to a log file, so you can check if the updates were successful.

Save and close the file. The cron job is now active and will run automatically at the scheduled time.

> [!NOTE]
> Updated script with better error handling

