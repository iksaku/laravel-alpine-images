#!/usr/bin/env sh

if [ ! -z "$LARAVEL_SAIL" ] && [ "$LARAVEL_SAIL" = '1' ]; then
    if ! id 'sail' &>/dev/null; then
        useradd -MNo -g laravel -u $(id -u laravel) sail
    fi
    
    if [ ! -z "$WWWUSER" ]; then
        usermod -ou $WWWUSER sail
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
    exec su-exec $WWWUSER "$@"
else
    /usr/bin/supervisord -c /usr/local/etc/supervisor/conf.d/supervisord.conf
fi
