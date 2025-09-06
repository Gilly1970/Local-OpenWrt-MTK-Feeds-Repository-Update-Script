# Local-OpenWrt-MTK-Feeds-Repository-Update-Script

I've created a simple, standalone shell script for updating both "openwrt" and "mtk-openwrt-feeds" repositories to keep the local repository up to date.

# **Setting Up**
How to Automate this Script....

Create a repo directory e.g.. /home/user/repo

1. cd /home/user/repo

2. Clone openwrt  git clone --branch openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git openwrt

3. git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds

4. clone this repo and place the script inside your local repo

5. Make the Script Executable - `chmod +x update_repos.sh`

6. Edit Your Crontab**

7. `crontab -e` - (If it's your first time, it might ask you to choose a text editor like `nano`).

8. Add the following line to the end of the file. This example will run the script every day at 3:00 AM.

9.  `0 3 * * * /home/user/repos/update_repos.sh >> /home/user/repos/update.log 2>&1`

10. Your local repo will now keep up to date automatically, which you can chack with the log 

