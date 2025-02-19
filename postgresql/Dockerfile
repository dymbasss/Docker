FROM ubuntu:22.04

WORKDIR /root/

# Open tcp ports
EXPOSE 5432

# Set variable
RUN apt-get update && \
    apt-get -y install locales && \
        locale-gen en_US.UTF-8 ru_RU.UTF-8
ENV LANG='ru_RU.UTF-8' LANGUAGE='ru_RU:ru' LC_ALL='ru_RU.UTF-8' LC_MESSAGES='en_US.UTF-8'

# Set timezone Europe/Moscow
RUN apt-get -y update && \
        apt-get install -y tzdata && \
        ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
        dpkg-reconfigure -f noninteractive tzdata

# Create the file repository configuration:
RUN sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

RUN apt-get update && \
    yes | apt-get install wget && \
    yes | apt-get install gnupg && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Installation postgres additional packets
RUN apt-get update; \
        yes | apt-get install postgresql
#         yes | apt-get install iputils-ping; \
#         yes | apt-get install curl; \
#         yes | apt-get install net-tools; \
# #        yes | apt-get install htop; \
#         yes | apt-get install nano

# Configs / Backup

WORKDIR /
USER postgres

COPY main/pg_hba.conf /etc/postgresql/14/main/pg_hba.conf
COPY main/postgresql.conf /etc/postgresql/14/main/postgresql.conf
# COPY run.sh /tmp
COPY schema.sql /tmp
# COPY globals.sql /tmp

RUN /etc/init.d/postgresql start && \
    psql --command "CREATE DATABASE gate_io;" && \
    # psql -d gate_io -a -f /tmp/globals.sql && \
    psql -d gate_io -a -f /tmp/schema.sql


# Start
CMD ["/usr/lib/postgresql/14/bin/postgres", "-D", "/var/lib/postgresql/14/main", "-c","config_file=/etc/postgresql/14/main/postgresql.conf"]
# USER root
# RUN chmod +x /tmp/run.sh
# CMD ["./tmp/run.sh"]