# -*- coding: utf-8 -*-
import logging
import smtplib

from email import encoders  # Импортируем энкодер
from email.mime.base import MIMEBase  # Общий тип
from email.mime.text import MIMEText  # Текст/HTML
from email.mime.image import MIMEImage  # Изображения
from email.mime.audio import MIMEAudio  # Аудио
from email.mime.multipart import MIMEMultipart  # Многокомпонентный объект

import model as smtp_model
import config

logger = logging.getLogger(__name__)


def attach_file(msg, file: smtp_model.File):
    """Функция по добавлению конкретного файла к сообщению

    Args:
        msg (_type_): _description_
        file (schemas.File): _description_
    """
    _payload = file.decode_payload(file.payload)
    _type, _sub_type = file.get_mime().split("/", maxsplit=1)
    if _type == "text":  # Если текстовый файл
        _file = MIMEText(_payload, _sub_type)  # Используем тип MIMEText
    elif _type == "image":  # Если изображение
        _file = MIMEImage(_payload, _sub_type)
    elif _type == "audio":  # Если аудио
        _file = MIMEAudio(_payload, _sub_type)
    else:  # Неизвестный тип файла
        _file = MIMEBase(_type, "application/octet-stream")  # Используем общий MIME-тип
        _file.set_payload(
            _payload
        )  # Добавляем содержимое общего типа (полезную нагрузку)
        encoders.encode_base64(_file)  # Содержимое должно кодироваться как Base64
    _file.add_header(
        "Content-Disposition", "attachment", filename=f"{file.name}.{file.type}"
    )  # Добавляем заголовки
    msg.attach(_file)  # Присоединяем файл к сообщению


def run_smtp(
    data: smtp_model.SMTPBody,
):

    msg = MIMEMultipart()

    msg.attach(MIMEText(data.text))

    if data.file:
        attach_file(msg, data.file)

    msg["Subject"] = data.subject
    msg["From"] = config.SMTP["username"] if not data.from_ else data.from_.username
    msg["To"] = data.to

    max_retry = 0
    while True:
        try:
            with smtplib.SMTP_SSL(
                host=config.SMTP["host"] if not data.from_ else data.from_.host,
                port=config.SMTP["port"] if not data.from_ else data.from_.port,
                timeout=config.SMTP["timeout"],
            ) as smtp:
                # print(smtp._host, smtp.port)
                # smtp.set_debuglevel(1)
                # smtp.starttls()
                smtp.login(
                    config.SMTP["username"] if not data.from_ else data.from_.username,
                    config.SMTP["password"] if not data.from_ else data.from_.password,
                )
                smtp.send_message(msg)
            break
        except smtplib.SMTPRecipientsRefused:
            raise
        except smtplib.SMTPException as err:
            max_retry += 1
            if max_retry == 3:
                logger.info(f"Retry {max_retry}/3. {err}\n\n")
                raise
