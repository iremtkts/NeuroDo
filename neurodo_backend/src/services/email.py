import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from src.core.config import settings

def send_verification_email(to_email: str, code: str):
    subject = "NeuroDo - E-posta Doğrulama Kodu"
    body = f"""
    Merhaba,
    
    Kayıt işlemini tamamlamak için doğrulama kodunuz: {code}
    
    NeuroDo ekibi
    """
    msg = MIMEMultipart()
    msg['From'] = settings.EMAIL_HOST_USER
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP(settings.EMAIL_HOST, settings.EMAIL_PORT)
        server.starttls()
        server.login(settings.EMAIL_HOST_USER, settings.EMAIL_HOST_PASSWORD)
        server.sendmail(settings.EMAIL_HOST_USER, to_email, msg.as_string())
        server.quit()
    except Exception as e:
        print(f"E-posta gönderilemedi: {e}") 