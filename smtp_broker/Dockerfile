FROM python:3.12

RUN apt-get update;

RUN apt-get -y install locales && \
    locale-gen ru_RU.UTF-8 && \
    echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen

ENV LANG='ru_RU.UTF-8' \
    LANGUAGE='ru_RU.UTF-8' \
    LC_ALL='ru_RU.UTF-8'

# Set timezone Europe/Moscow
RUN apt-get -y install tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

WORKDIR /usr/src
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["python3", "app"]