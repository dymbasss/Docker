https://dockerhosting.ru/blog/zapusk-prometheus-v-docker/

или

https://www.dmosk.ru/miniinstruktions.php?mini=prometheus-stack-docker

Prometheus — это приложение для мониторинга с открытым исходным кодом. 
Оно сканирует HTTP-конечные точки для сбора показателей в простом текстовом формате, охватывает множество аспектов мониторинга, таких как генерация и сбор показателей, построение графиков на информационных панелях и оповещение об аномалиях.  С недавнего времени, Prometheus умеет работать с Telegram из коробки. Об этом ниже.

В этом руководстве мы узнаем, как установить три ключевых компонента для использования Prometheus в Docker. Это:

Сервер Prometheus для сбора показателей и запроса к ним;
Node Exporter для экспорта системных показателей в формате, совместимом с Prometheus;
Grafana — это веб-приложение для создания графических информационных панелей, которое поддерживает Prometheus и другие серверные части.
Подразумевается, что у нас уже установлен Docker и docker-compose, в противном случае, можно воспользоваться инструкцией Установка Docker на VPS/VDS.

Запуск Prometheus + Node Exporter в Docker
Node Exporter — это небольшое приложение, которое собирает метрики операционной системы и предоставляет к ним доступ по HTTP.

Node Exporter измеряет различные метрики, такие как:

- общая память (RAM);
- используемая память (RAM);
- кэш памяти (RAM);
- свободный диск;
- пространство для IOPS;
- монтирования;
- загрузка процессора;
- сеть (трафик, поток TCP, соединения).

Node Exporter устанавливается на всех серверах или виртуальных машинах для сбора данных обо всех узлах. По умолчанию он выставляет метрики в по адресу: http://IP-адрес:9100/metrics.

На примере Node Exporter мы будем собирать метрики узла и передавать их в Prometheus и визуализируем их в Grafana.

И так приступим к установке, создадим директорию для размещения docker-compose файла:
```
mkdir -p /prometheus
```
Перейдем в созданный каталог:

cd /prometheus
Создадим файл docker-compose.yml, содержащий следующие сервисы:
```
nano docker-compose.yml
```
Перенесем содержимое ниже в файл docker-compose.yml:
```
version: '3.9'

services:

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./configuration/:/etc/prometheus/
      - ./data/:/prometheus/
    container_name: prometheus
    hostname: prometheus
    command:
      - --config.file=/etc/prometheus/prometheus.yml
    ports:
      - 9090:9090
    restart: unless-stopped
    environment:
      TZ: "Europe/Moscow"
    networks:
      - default

  node-exporter:
    image: prom/node-exporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    container_name: exporter
    hostname: exporter
    command:
      - --path.procfs=/host/proc
      - --path.sysfs=/host/sys
      - --collector.filesystem.ignored-mount-points
      - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
    ports:
      - 9100:9100
    restart: unless-stopped
    environment:
      TZ: "Europe/Moscow"
    networks:
      - default

networks:
  default:
    ipam:
      driver: default
      config:
        - subnet: 172.28.0.0/16
```
Для сбора статистики Node Exporter мы смонтировали /proc /sys и / в режиме чтения.

Находясь в директории prometheus/, создадим два каталога для хранения конфигурационных файлов и накопленных данных:
```
mkdir -p configuration
mkdir -p data
```
Выдадим права на созданный каталог data:
```
chown 65534:65534 data
```

В каталоге configuration создадим конфигурационный файл prometheus.yml:

nano configuration/prometheus.yml
```
scrape_configs:
  - job_name: node
    scrape_interval: 5s
    static_configs:
    - targets: ['node-exporter:9100']
```

Из каталога prometheus/ запустим docker-compose:
```
docker-compose up -d
```

http://<IP_узла_установки>:9090 — prometheus (по умолчанию аутентификация у сервиса отсутствует).

По адресу http://<IP_узла_установки>:9100 — страница Node Exporter