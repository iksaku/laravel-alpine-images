ARG PHP_VERSION
FROM php:${PHP_VERSION}-cli-alpine as base

WORKDIR /var/www/html

# Get php extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install system dependencies
RUN set -eux \
    && apk --update add --no-cache --purge \
        # Required to serve our Laravel application
        libcap \
        su-exec \ 
        # Compatibility layer for user and group commands
        shadow \

    # Install missing PHP extensions required by Laravel
    && install-php-extensions \
        @composer \
        bcmath \
        mysqli pdo_mysql \
        pgsql pdo_pgsql \
        redis

RUN setcap "cap_net_bind_service=+ep" /usr/local/bin/php

COPY shared/entrypoint.sh /usr/local/bin/entrypoint
COPY shared/start-server.sh /usr/local/bin/start-server
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/start-server

COPY shared/php.ini /usr/local/etc/php/conf.d/php.ini

COPY shared/crontab /usr/local/etc/crontab

RUN useradd -ms /bin/sh -u 1337 -U laravel

EXPOSE 8080

ENTRYPOINT ["entrypoint"]
