`sudo apt install python3`
Сделайте скрипт исполняемым (необязательно, но хорошая практика):

**<h3>Bash</h3>**

`chmod +x /path/to/your/send_alert_email.py`

Теперь вы можете вызывать этот скрипт из командной строки или из другого Bash-скрипта, передавая тему и тело сообщения как аргументы:
```# Пример вызова из командной строки:
python3 /path/to/your/send_alert_email.py "Тестовый алерт от сервера" "Это тестовое сообщение для проверки отправки алерта."

# Пример вызова из Bash-скрипта (как мы обсуждали в emergency_backup.sh):
# Предполагается, что переменные ALERT_SUBJECT и ALERT_BODY уже определены
ALERT_SUBJECT="[СРОЧНЫЙ БЭКАП] Сервер ${HOSTNAME} пережил множественные перезагрузки!"
ALERT_BODY="Детали: $(cat /var/log/emergency_backup.log)" # Или любой другой текст

python3 /usr/local/bin/send_alert_email.py "$ALERT_SUBJECT" "$ALERT_BODY"```
