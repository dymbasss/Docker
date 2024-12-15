# -*- coding: utf-8 -*-
import os
import logging
import asyncio

from logging.handlers import RotatingFileHandler

import config
import consumer

os.chdir("app")

if "log" not in os.listdir():
    os.mkdir(os.path.join(os.getcwd(), "log"))

if "data" not in os.listdir():
    os.mkdir(os.path.join(os.getcwd(), "data"))


for log in [logging.getLogger(name) for name in logging.root.manager.loggerDict]:
    log.setLevel(logging.DEBUG)
console_log = logging.StreamHandler()

rot_file_handler = RotatingFileHandler(
    f"./log/{config.LOG_FILE_NAME}.log",
    maxBytes=10 * 1024 * 1024,
    backupCount=3,
    encoding="utf-8",
)

logging.basicConfig(
    handlers=[rot_file_handler, console_log],
    format='[%(asctime)s] (%(filename)s:%(lineno)d %(threadName)s) %(levelname)s - %(name)s: "%(message)s"',
)

asyncio.run(consumer.run())
