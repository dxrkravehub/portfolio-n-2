#!/bin/bash
# /usr/local/bin/reboot_monitor.sh

LOG_FILE="/var/log/reboot_monitor.log"
LAST_REBOOT_FILE="/tmp/last_reboot_timestamps"
REBOOT_THRESHOLD=2 # Количество перезагрузок, при котором срабатывает триггер
TIME_WINDOW_MINUTES=10 # Временное окно для отслеживания перезагрузок

# Получаем временные метки последних перезагрузок
CURRENT_REBOOT_TIMES=$(last reboot | head -n $(($REBOOT_THRESHOLD + 1)) | awk '{print $5, $6, $7, $8}')

# Сохраняем текущие временные метки
echo "$CURRENT_REBOOT_TIMES" > "$LAST_REBOOT_FILE"

# Считываем временные метки
REBOOT_TIMESTAMPS=()
while read -r line; do
    # Преобразуем дату и время в Unix timestamp
    TS=$(date -d "$(echo "$line" | awk '{print $NF, $(NF-1)}')")
    REBOOT_TIMESTAMPS+=("$TS")
done <<< "$CURRENT_REBOOT_TIMES"

# Проверяем, достаточно ли перезагрузок для анализа
if [ ${#REBOOT_TIMESTAMPS[@]} -ge $REBOOT_THRESHOLD ]; then
    # Получаем самую старую перезагрузку в окне и самую новую
    OLDEST_REBOOT_TS=${REBOOT_TIMESTAMPS[$(($REBOOT_THRESHOLD - 1))]}
    NEWEST_REBOOT_TS=${REBOOT_TIMESTAMPS[0]}

    TIME_DIFF_SECONDS=$((NEWEST_REBOOT_TS - OLDEST_REBOOT_TS))
    TIME_WINDOW_SECONDS=$((TIME_WINDOW_MINUTES * 60))

    if [ "$TIME_DIFF_SECONDS" -le "$TIME_WINDOW_SECONDS" ]; then
        echo "$(date): CRITICAL: Server rebooted $REBOOT_THRESHOLD times within $TIME_WINDOW_MINUTES minutes! Initiating emergency backup." | tee -a "$LOG_FILE"
        # Вызов скрипта экстренного бэкапа
        /usr/local/bin/emergency_backup.sh
        # Чтобы не запускать бэкап каждый раз, можно добавить флаг или лок-файл
        # Например, создать файл-флаг и проверять его наличие перед запуском бэкапа.
        # Если файл существует, бэкап не запускается до его удаления или истечения времени.
        exit 0 # Выходим, чтобы предотвратить дальнейшие проверки до следующей итерации cron
    fi
fi

echo "$(date): Server stable. Last reboots: $CURRENT_REBOOT_TIMES" | tee -a "$LOG_FILE"
