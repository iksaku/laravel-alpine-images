#!/usr/bin/env sh

if [ ! -z "$LARAVEL_SAIL" ] && [ "$LARAVEL_SAIL" = '1' ]; then
    if ! id 'sail' &>/dev/null; then
        useradd -MNo -g laravel -u $(id -u laravel) sail
    fi
    
    if [ ! -z "$WWWUSER" ]; then
        usermod -ou $WWWUSER sail &>/dev/null
    fi
fi

if [ ! -z "$WWWUSER" ]; then
    usermod -ou $WWWUSER laravel &>/dev/null
fi

if [ ! -z "$WWWGROUP" ]; then
    groupmod -og $WWWGROUP laravel &>/dev/null
fi

if [ ! -d /.composer ]; then
    mkdir /.composer
fi

chmod -R ugo+rw /.composer

if [ $# -gt 0 ]; then
    # Execute given command under container's user.
    exec su-exec ${WWWUSER:-laravel} "$@"
else
    if [ "${APP_ENV}" = 'production' ]; then
        for SCRIPT in ${APP_DIRECTORY}/.deploy/*.sh; do
            exec su-exec laravel sh ${SCRIPT}
        done
    fi

    # If no command is given, execute start script.
    exec su-exec laravel /usr/local/bin/start-server
fi
