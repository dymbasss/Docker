# -*- coding: utf-8 -*-
import os

RETRY_COUNT = 11

LOG_FILE_NAME = os.environ.get("CONTAINER_NAME", "smtp_broker")

RABBITMQ = {
    "in_queue": "q.smtp",
    "in_exchange": "e.smtp",
    "dead_exchange": "e.dead.letter.smtp",
    "dead_queue": "q.dead.letter.smtp",
    "TTL": 300 * 1000,
    "url": f"amqp://{os.environ.get('RABBITMQ_USER','guest')}:"
    + f"{os.environ.get('RABBITMQ_PASS','guest')}@"
    + f"{os.environ.get('RABBITMQ_HOST', '1.1.1.1')}",
}

SMTP = {
    "host": os.environ.get("SMTP_HOST", "smtp.mail.ru"),
    "port": os.environ.get("SMTP_PORT", 465),
    "username": os.environ.get("SMTP_USER", ""),
    "password": os.environ.get("SMTP_PASS", ""),
    "timeout": 10,
}
