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

if [ ! -d /.composer ]; then
    mkdir /.composer
fi

chmod -R ugo+rw /.composer

if [ $# -gt 0 ]; then
    # Execute given command under container's user.
    su-exec laravel "$@"
else
    if [ "$LARAVEL_SAIL" != '1' ] && [ "$RUN_DEPLOY_SCRIPTS" = '1' ]; then
        chown -R laravel:laravel $APP_DIRECTORY

        if [ -d $APP_DIRECTORY/.deploy ]; then
            for SCRIPT in $APP_DIRECTORY/.deploy/*.sh; do
                su-exec laravel sh $SCRIPT
            done
        fi
    fi

    # If no command is given, execute start script.
    su-exec laravel /usr/local/bin/start-server
fi
