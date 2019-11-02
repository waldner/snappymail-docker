FROM php:7.3.11-fpm-alpine3.10

ENV RAINLOOP_VERSION=1.13.0

RUN apk --no-cache --update add nginx bash ca-certificates supervisor tzdata libpq \
    && apk --no-cache --update --virtual builddeps add postgresql-dev \
\
    && docker-php-ext-install -j$(nproc) pdo_pgsql \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
\
    && curl -s -L -o /tmp/rainloop.zip "https://github.com/RainLoop/rainloop-webmail/releases/download/v${RAINLOOP_VERSION}/rainloop-${RAINLOOP_VERSION}.zip" \
    && apk del builddeps \
\
    && mkdir /rainloop \
    && unzip -q /tmp/rainloop.zip -d /rainloop \
    && find /rainloop -type d -exec chmod 755 {} + \
    && find /rainloop -type f -exec chmod 644 {} + \
    && ln -sf /dev/stdout /tmp/nginx_access.log \
    && ln -sf /dev/stderr /tmp/nginx_error.log 

COPY files/listener.py /listener.py
COPY files/nginx_site.conf /etc/nginx/conf.d/default.conf
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/start.sh /
RUN chmod +x /start.sh

CMD [ "/start.sh" ]
