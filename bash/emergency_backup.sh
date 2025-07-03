#!/bin/bash
# /usr/local/bin/emergency_backup.sh

BACKUP_SOURCE_DIRS=("/var/www/html" "/etc" "/home/user/critical_data") # Каталоги для бэкапа
BACKUP_DEST="user@backup.example.com:/path/to/emergency_backups/" # Удаленное хранилище SSH
BACKUP_LOG="/var/log/emergency_backup.log"
PYTHON_ALERT_SCRIPT="/usr/local/bin/bash/send_alert_email.py" # Путь к вашему Python-скрипту

# Проверка, был ли экстренный бэкап запущен недавно (чтобы избежать дублирования)
LOCK_FILE="/tmp/emergency_backup.lock"
LOCK_TIMEOUT_SECONDS=3600 # 1 час

if [ -f "$LOCK_FILE" ]; then
    LAST_RUN_TIME=$(stat -c %Y "$LOCK_FILE")
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - LAST_RUN_TIME)) -lt "$LOCK_TIMEOUT_SECONDS" ]; then
        echo "$(date): Emergency backup already initiated recently. Exiting." >> "$BACKUP_LOG"
        exit 0
    fi
fi
touch "$LOCK_FILE" # Создаем или обновляем лок-файл

echo "$(date): Starting emergency backup due to server instability..." | tee -a "$BACKUP_LOG"

BACKUP_SUCCESS=true
for DIR in "${BACKUP_SOURCE_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        rsync -az --delete "$DIR" "$BACKUP_DEST" >> "$BACKUP_LOG" 2>&1
        if [ $? -ne 0 ]; then
            echo "$(date): Rsync failed for $DIR" >> "$BACKUP_LOG"
            BACKUP_SUCCESS=false
        fi
    else
        echo "$(date): Source directory $DIR not found." >> "$BACKUP_LOG"
        BACKUP_SUCCESS=false
    fi
done

# Отправка оповещения через Python
ALERT_SUBJECT="[СРОЧНЫЙ БЭКАП] Сервер ${HOSTNAME} пережил множественные перезагрузки!"
ALERT_BODY=$(cat "$BACKUP_LOG")

if "$PYTHON_ALERT_SCRIPT" "$ALERT_SUBJECT" "$ALERT_BODY"; then
    echo "$(date): Emergency backup alert sent successfully." | tee -a "$BACKUP_LOG"
else
    echo "$(date): Failed to send emergency backup alert via Python script." | tee -a "$BACKUP_LOG"
fi

# Сброс лок-файла, можно добавить время жизни для лок-файла
# rm "$LOCK_FILE" # Удалить сразу, если логика монитора не имеет другого способа сброса
# Или оставить, чтобы монитор не запускал бэкап снова в течение LOCK_TIMEOUT_SECONDS
