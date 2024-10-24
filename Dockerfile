FROM php:8.3.12-fpm-alpine3.20

ENV SNAPPYMAIL_VERSION=2.38.2

#    && docker-php-ext-install -j$(nproc) mbstring \
#    && docker-php-ext-install -j$(nproc) dom \
#    && docker-php-ext-install -j$(nproc) curl \
#    && docker-php-ext-install -j$(nproc) exif \
#    && docker-php-ext-install -j$(nproc) pdo_mysql \
#    && docker-php-ext-install -j$(nproc) sodium \
#    && docker-php-ext-install -j$(nproc) zip \
#\

#    && find /snappymail -type d -exec chmod 755 {} + \
#    && find /snappymail -type f -exec chmod 644 {} + \

RUN apk --no-cache --update add nginx bash ca-certificates supervisor tzdata libpq \
    && apk --no-cache --update --virtual builddeps add postgresql-dev \
\
\
    && curl -s -L -o /tmp/snappymail.zip "https://github.com/the-djmaze/snappymail/releases/download/v${SNAPPYMAIL_VERSION}/snappymail-${SNAPPYMAIL_VERSION}.zip" \
    && apk del builddeps \
\
    && mkdir /snappymail \
    && unzip -q /tmp/snappymail.zip -d /snappymail \
    && ln -sf /dev/stdout /tmp/nginx_access.log \
    && ln -sf /dev/stderr /tmp/nginx_error.log 


# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY files/listener.py /listener.py
COPY files/nginx_site.conf /etc/nginx/http.d/default.conf
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/start.sh /
RUN chmod +x /start.sh

CMD [ "/start.sh" ]
