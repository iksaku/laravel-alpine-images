# Laravel Alpine Docker Images

This project provides Docker images containing the *bare minimum* requirements
needed to run your Laravel application. We use PHP's official CLI images based
on Alpine Linux to further reduce the size of these images.

You may notice that your favorite PHP extensions and NodeJS are _missing_ from
these images, but this is actually a _feature_ ✨. The intention with these
images is to have the *absolute minimum requirements* ready, and you, the main
player, will pull these images and further customize them with everything you need.

## Available Images

You can choose the PHP version you want to run by specifying it as the tag for your image.
Currently, we build the following images:
  * `laravel-alpine:8.0`
  * `laravel-alpine:8.1`

If you want to add [Laravel Octane](https://laravel.com/docs/octane) support to your
images, you can append `-octane-{runtime}` to the PHP version tag, where `{runtime}`
could be either `roadrunner` or `swoole`:
  * `laravel-alpine:8.0-octane-swoole`
  * `laravel-alpine:8.0-octane-roadrunner`
  * `laravel-alpine:8.1-octane-swoole`
  * `laravel-alpine:8.1-octane-roadrunner`

## Running on Laravel Sail

As opposed to [Laravel Sail](https://laravel.com/docs/sail), you don't need to import
this repository as a package nor _publish_ our `Dockerfile` assets most of the time,
you can just use our images directly in your `docker-compose.yml` file, or use them
as a base for your custom `Dockerfile`.

Before anything else, you must know that our images dynamically workout Group and User
permissions, while Laravel Sail builds the image based on Group permissions, so the first
change you must make is to move the `WWWGROUP` argument to be part of the `environment`
variables of your `docker-compose.yml` file:
```diff
services:
    laravel.test:
        build:
            context: ./vendor/laravel/sail/runtimes/8.1
-            args:
-                WWWGROUP: '${WWWGROUP}'
#        ports: ...
        envrionment:
            WWWUSER: '${WWWUSER}'
+            WWWGROUP: '${WWWGROUP}'
#            ...
```

To run our images without modifications in Laravel Sail, you can replace the `build`
option with `image` in your `docker-compose.yml` file:
```diff
services:
    laravel.test:
-        build:
-            context: ./vendor/laravel/sail/runtimes/8.1
+        image: laravel-alpine:8.1
```

> **Note**
> Our Octane images should also run in Laravel Sail without any modifications ⚡.

> **Note**
> Remember that you can always pull the latest version of your chosen image
> using `sail pull` 📥.

If you opt into customizing your image, then work with the `build` option in your
`docker-compose.yml` file:
```diff
services:
    laravel.test:
        build:
-            context: ./vendor/laravel/sail/runtimes/8.1
            context: .
            dockerfile: ./path/to/your/Dockerfile
```

## Deploying to Production

TODO...

```dockerfile
FROM laravel-alpine:8.1

COPY shared/crontab /usr/local/etc/crontab
RUN /usr/bin/crontab /usr/local/etc/crontab

COPY . /var/www/html

RUN composer install --optimize-autoloader --no-dev

RUN mkdir -p storage/logs \
    && chown -R laravel:laravel /var/www/html \
    && chmod -R ug+w /var/www/html/storage \
    && chmod -R 755 /var/www/html

RUN sed -i 's/protected \$proxies/protected \$proxies = "*"/g' app/Http/Middleware/TrustProxies.php
```

# Credits

As this intends to be an alternative version of Laravel Sail images, most of the credit
goes to the @laravel team itself for building and maintaining Laravel Sail for us 💖.

Also, much inspiration (and snippets) come from @fideloper's public work on Fly.io's Laravel
Template 🤩.