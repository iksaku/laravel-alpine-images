FROM php:8.1-cli-alpine as base

WORKDIR /var/www/html

# Get php extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install system dependencies
RUN set -eux \
    && apk --update add --no-cache \
        git \
        # Required to serve our Laravel application
        supervisor \
        libcap \
        # Required for Laravel scheduler crontab entry
        su-exec \
        # Compatibility layer for user and group commands
        shadow \

    # Install missing PHP extensions required by Laravel
    && install-php-extensions \
        @composer \
        bcmath \

    # Clean up
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/local/bin/php

COPY shared/start-container.sh /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

COPY shared/php.ini /usr/local/etc/php/conf.d/php.ini

COPY shared/supervisord.conf /usr/local/etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor/

RUN useradd -ms /bin/sh -u 1337 -U laravel

EXPOSE 8080

ENTRYPOINT ["start-container"]
