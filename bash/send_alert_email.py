import smtplib
from email.mime.text import MIMEText
import sys
import os # Импортируем os для проверки существования файла, хотя в данном скрипте это не основная функция

# --- КОНФИГУРАЦИЯ ПОЧТЫ ---
# Важно: используйте "пароль приложения" для Gmail, а не основной пароль Google.
# Инструкции по созданию пароля приложения можно найти по ссылке:
# https://support.google.com/accounts/answer/185833
SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587  # Порт для STARTTLS (рекомендуется)
# SMTP_PORT = 465 # Используйте этот порт для SSL/TLS (если ваш сервер требует)
SENDER_EMAIL = 'ваша_почта@gmail.com'          # Замените на вашу электронную почту
SENDER_PASSWORD = 'ваш_пароль_приложения_gmail' # Замените на ваш реальный пароль приложения
RECEIVER_EMAIL = 'получатель_алертов@example.com' # Замените на почту получателя или вашу собственную

# --- Функция отправки email ---
def send_email_alert(subject, body_content):
    """
    Отправляет email-оповещение с заданной темой и содержимым.
    """
    msg = MIMEText(body_content, 'plain', 'utf-8')
    msg['Subject'] = subject
    msg['From'] = SENDER_EMAIL
    msg['To'] = RECEIVER_EMAIL

    try:
        # Используем контекстный менеджер with для автоматического закрытия соединения
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()  # Начинаем TLS-шифрование (для 587 порта)
            # Если используете порт 465, возможно, вместо starttls() нужно использовать smtplib.SMTP_SSL()
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.send_message(msg)
        print("Email alert sent successfully!")
        return True
    except Exception as e:
        print(f"Error sending email: {e}", file=sys.stderr)
        return False

# --- Главная часть скрипта ---
if __name__ == "__main__":
    # Скрипт ожидает минимум два аргумента командной строки:
    # 1. Тема письма
    # 2. Тело письма
    if len(sys.argv) < 3:
        print("Usage: python3 send_alert_email.py \"<Subject>\" \"<Body Content>\"", file=sys.stderr)
        sys.exit(1)

    # Первый аргумент (sys.argv[0]) - это имя самого скрипта
    # Второй аргумент (sys.argv[1]) - это тема письма
    # Третий аргумент (sys.argv[2]) - это тело письма
    alert_subject = sys.argv[1]
    alert_body = sys.argv[2]

    send_email_alert(alert_subject, alert_body)
  # Советую прочитать readme.md чтобы проверить исполняемый скрипт
