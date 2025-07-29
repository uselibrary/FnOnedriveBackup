#!/usr/bin/env bash

# 1. 检查是否为root权限
if [ "$EUID" -ne 0 ]; then
  echo "请以root权限运行此脚本。"
  exit 1
fi

# 2. 创建/opt/FnOnedriveBackup目录并下载rclone
INSTALL_DIR="/opt/FnOnedriveBackup"
RCLONE_URL="https://downloads.rclone.org/rclone-current-linux-amd64.zip"
RCLONE_ZIP="/tmp/rclone-current-linux-amd64.zip"

mkdir -p "$INSTALL_DIR"
cd /tmp
curl -O "$RCLONE_URL"
unzip -o "$RCLONE_ZIP"
RCLONE_FOLDER=$(unzip -Z -1 "$RCLONE_ZIP" | head -n1 | cut -d/ -f1)
cp "/tmp/$RCLONE_FOLDER/rclone" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/rclone"

# 3. 配置参数，SRC_DIR和DEST_REMOTE手动输入
read -p "请输入本地源目录（SRC_DIR）：" SRC_DIR
read -p "请输入目标远程（DEST_REMOTE）：" DEST_REMOTE
RCLONE_BIN="$INSTALL_DIR/rclone"
RCLONE_CONF="$INSTALL_DIR/rclone.conf"
LOG_DIR="$INSTALL_DIR/error.log"

cat > "$INSTALL_DIR/config.env" <<EOF
SRC_DIR="$SRC_DIR"
DEST_REMOTE="$DEST_REMOTE"
RCLONE_BIN="$RCLONE_BIN"
RCLONE_CONF="$RCLONE_CONF"
LOG_DIR="$LOG_DIR"
EOF

echo "配置已写入 $INSTALL_DIR/config.env"

# 4. 写入crontab，每天凌晨3点运行fn_onedrive_backup.sh
BACKUP_SCRIPT="/home/imes/Code/Shell/FnOnedriveBackup/fn_onedrive_backup.sh"
CRON_JOB="0 3 * * * $BACKUP_SCRIPT"
(crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT"; echo "$CRON_JOB") | crontab -
echo "已添加定时任务：每天凌晨3点运行 $BACKUP_SCRIPT"

# 5. 唤起rclone配置
"$RCLONE_BIN" config --config "$RCLONE_CONF"
