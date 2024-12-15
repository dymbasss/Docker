# -*- coding: utf-8 -*-
import aio_pika
import asyncio
import config
import json
import logging

import model

from smtp import run_smtp

logger = logging.getLogger(__name__)


def more_retry(headers: aio_pika.abc.HeadersType):

    death = (headers or {}).get("x-death")
    if not death:
        return True
    # config.RETRY_COUNT покрутится в очереди и удалится
    if death[0]["count"] >= config.RETRY_COUNT:
        return False
    return True


async def process_message(
    message: aio_pika.abc.AbstractIncomingMessage,
) -> None:

    # https://docs.aio-pika.com/apidoc.html#aio_pika.IncomingMessage.process
    async with message.process(ignore_processed=True):
        logger.info(f"\nHEADERS: {message.headers}\nBODY: {message.body}")
        if not more_retry(message.headers):
            await message.reject()
        else:
            # print(message.body)
            data = model.SMTPBody(**json.loads(message.body))
            await asyncio.to_thread(run_smtp, data)
            await message.ack()


async def run() -> None:

    connection = await aio_pika.connect_robust(config.RABBITMQ["url"], timeout=5)

    channel = await connection.channel()

    # Максиально скольк может через себя пропустить канал сообщений за раз
    await channel.set_qos(prefetch_count=5)

    # Дексларируем обменики
    await channel.declare_exchange(
        config.RABBITMQ["dead_exchange"], type=aio_pika.exchange.ExchangeType.FANOUT
    )

    await channel.declare_exchange(
        config.RABBITMQ["in_exchange"], type=aio_pika.exchange.ExchangeType.FANOUT
    )

    # Декларируем очереди
    dead_queue = await channel.declare_queue(
        config.RABBITMQ["dead_queue"],
        # auto_delete=True,
        durable=True,
        arguments={
            # сообщения из in_exchange при nack-е
            # будут попадать в dead_letter_smtp
            "x-message-ttl": config.RABBITMQ["TTL"],
            # также не забываем, что у очереди "мертвых" сообщений
            # должен быть свой dead letter exchange
            "x-dead-letter-exchange": config.RABBITMQ["in_exchange"],
        },
    )
    await dead_queue.bind(config.RABBITMQ["dead_exchange"])

    queue = await channel.declare_queue(
        config.RABBITMQ["in_queue"],
        # auto_delete=True,
        durable=True,
        arguments={
            # сообщения из in_exchange при nack-е
            # будут попадать в dead_letter_smtp
            "x-dead-letter-exchange": config.RABBITMQ["dead_exchange"],
        },
    )
    await queue.bind(config.RABBITMQ["in_exchange"])

    await queue.consume(process_message)

    try:
        # Wait until terminate
        await asyncio.Future()
    finally:
        await connection.close()
