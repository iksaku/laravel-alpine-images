#!/usr/bin/env sh

if [ "$LARAVEL_SAIL" = '1' ]; then
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

chown -R laravel:laravel $APP_DIRECTORY

if [ $# -gt 0 ]; then
    # Execute given command under container's user.
    su-exec laravel "$@"
else
    if [ -d $APP_DIRECTORY/.deploy ] && [ "$LARAVEL_SAIL" != '1' ] && [ "$RUN_DEPLOY_SCRIPTS" = '1' ]; then
        for SCRIPT in $APP_DIRECTORY/.deploy/*.sh; do
            su-exec laravel sh $SCRIPT
        done
    fi

    # If no command is given, execute start script.
    su-exec laravel /usr/local/bin/start-server
fi
