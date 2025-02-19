FROM nginx:1.19.6

RUN apt-get update;
ENV LANG='ru_RU.UTF-8' \
    LANGUAGE='ru_RU:ru' \
    LC_ALL='ru_RU.UTF-8' \
    LC_MESSAGES='en_US.UTF-8'

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen

RUN apt-get -y install locales && \
    locale-gen en_US.UTF-8 ru_RU.UTF-8

RUN ln -fs /usr/share/zoneinfo/Erope/Moscow /etc/localtime

WORKDIR /usr/src
COPY cert.pem .
COPY key.pem .
COPY default.conf /etc/nginx/conf.d/default.conf
# COPY nginx ./nginx
CMD ["nginx-debug", "-g", "daemon off;"]