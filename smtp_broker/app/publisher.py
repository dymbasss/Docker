# coding: utf-8 -*-
import aio_pika
import json

import model
import config


def check_type(data):

    if isinstance(data, model.SMTPBody):
        data = data.dict()
    elif isinstance(data, str):
        return data.encode("utf-8")

    return json.dumps(data).encode("utf-8")


async def run(in_exchange: str, data: model.SMTPBody | str) -> None:

    connection = await aio_pika.connect_robust(
        config.RABBITMQ["url"],
    )

    async with connection:

        routing_key = in_exchange

        channel = await connection.channel()

        exchange = await channel.declare_exchange(
            routing_key, type=aio_pika.exchange.ExchangeType.FANOUT
        )

        await exchange.publish(
            aio_pika.Message(body=check_type(data)),
            routing_key=routing_key,
        )
