#!/usr/bin/env sh

if [[ ! -z "$WWWUSER" ]];
    then usermod -u $WWWUSER laravel;
fi

if [[ ! -z "$WWWGROUP" ]];
    then groupmod -g $WWWGROUP laravel;
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
