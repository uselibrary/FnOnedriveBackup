#!/usr/bin/env bash

# 加载配置
CONFIG_FILE="/opt/FnOnedriveBackup/config.env"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "未找到配置文件: $CONFIG_FILE"
  exit 1
fi
source "$CONFIG_FILE"

# 检查rclone和配置文件
if [ ! -x "$RCLONE_BIN" ]; then
  echo "rclone未找到: $RCLONE_BIN"
  exit 1
fi
if [ ! -f "$RCLONE_CONF" ]; then
  echo "rclone配置文件未找到: $RCLONE_CONF"
  exit 1
fi

# 执行备份
"$RCLONE_BIN" sync "$SRC_DIR" "$DEST_REMOTE" \
  --config "$RCLONE_CONF" \
  --log-file "$LOG_DIR" \
  --log-level INFO

RET=$?
if [ $RET -eq 0 ]; then
  echo "[$(date)] 备份成功" >> "$LOG_DIR"
else
  echo "[$(date)] 备份失败，错误码：$RET" >> "$LOG_DIR"
fi
