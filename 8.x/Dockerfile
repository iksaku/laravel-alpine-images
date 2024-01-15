ARG PHP_VERSION
ARG VARIANT
FROM php:${PHP_VERSION}-${VARIANT}-alpine as base

ENV APP_DIRECTORY=/var/www/html

WORKDIR ${APP_DIRECTORY}

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
        intl \
        pcntl \
        mysqli pdo_mysql \
        pgsql pdo_pgsql \
        redis

RUN setcap "cap_net_bind_service=+ep" /usr/local/bin/php

COPY shared/entrypoint.sh /usr/local/bin/entrypoint
COPY shared/start-server.sh /usr/local/bin/start-server
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/start-server

COPY shared/php.ini /usr/local/etc/php/conf.d/php.ini

# Install Laravel Scheduler to crontab.
# Expected to be run crond as root, then su-exec takes over.
COPY shared/crontab /var/spool/cron/crontabs/root

RUN useradd -ms /bin/sh -u 1337 -U laravel

EXPOSE 80

ENTRYPOINT ["entrypoint"]
