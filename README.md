# Laravel Alpine Docker Images

This project provides Docker images containing the *bare minimum* requirements
needed to run your Laravel application. We use PHP's official CLI images based
on Alpine Linux to further reduce the size of these images.

You may notice that your favorite PHP extensions and NodeJS are _missing_ from
these images, but this is actually a _feature_ ✨. The intention with these
images is to provide the *absolute minimum requirements* so that you, the
developer, pull these images and further customize them with everything
you need.

## Available Images

You can choose the PHP version you want to run by specifying it as the tag for your image.
Currently, we build the following images:
  * `ghcr.io/iksaku/laravel-alpine:8.0`
  * `ghcr.io/iksaku/laravel-alpine:8.1`

If you want to run [Laravel Octane](https://laravel.com/docs/octane), you can
append `-octane-{runtime}` to the PHP version tag, where `{runtime}` could be
either `roadrunner` or `swoole`. Example:
  * `ghcr.io/iksaku/laravel-alpine:8.0-octane-roadrunner`
  * `ghcr.io/iksaku/laravel-alpine:8.1-octane-swoole`

Checkout the available image tag list
[here](https://github.com/iksaku/laravel-alpine-images/pkgs/container/laravel-alpine/versions?filters%5Bversion_type%5D=tagged).

## Running on Laravel Sail

As opposed to [Laravel Sail](https://laravel.com/docs/sail), you don't need to import
this repository as a package nor _publish_ our `Dockerfile` assets most of the time,
you can just use our images directly in your `docker-compose.yml` file, or use them
as a base for your custom `Dockerfile`.

### About container permissions
Before proceeding, it is important to know that our images dynamically adjust Group and User
permissions when your container _starts_, while Laravel Sail adjust the Group permissions
_on build_, so the first change you must make is to move the `WWWGROUP` argument to be
part of the `environment` variables of your `docker-compose.yml` file:
```diff
services:
    laravel.test:
        build:
            context: ./vendor/laravel/sail/runtimes/8.1
-           args:
-               WWWGROUP: '${WWWGROUP}'
#       ...
        envrionment:
            WWWUSER: '${WWWUSER}'
+           WWWGROUP: '${WWWGROUP}'
#            ...
```

### Running base images
To run our images in Laravel Sail, you can replace the `build` option with `image`
in your `docker-compose.yml` file:
```diff
services:
    laravel.test:
-       build:
-           context: ./vendor/laravel/sail/runtimes/8.1
+       image: ghcr.io/iksaku/laravel-alpine:8.1
```

> **Note**
> You can always update to the latest version of your chosen image
> using `sail pull` 📥.

### Running octane images
Octane images also run in Laravel Sail, you just need to change your `image`
reference to specify you want to run octane:
```diff
services:
    laravel.test:
-       image: ghcr.io/iksaku/laravel-alpine:8.1
+       image: ghcr.io/iksaku/laravel-alpine:8.1-octane-roadrunner
```

### Running modified images
If you want to further customize your image, then work with the `build` option in your
`docker-compose.yml` file:
```sh
super-duper-project
├── app
├── bootstrap
│   ...
├── docker
│   └── super-duper-runtime
│       └── Dockerfile
└── docker-compose.yml
```

```diff
services:
    laravel.test:
        build:
-           image: ghcr.io/iksaku/laravel-alpine:8.1
+           context: ./docker/super-duper-runtime
```

## Deploying to Production

Published images can also be used in production, but in order to run the best
in class service, it is 100% recommended that you take a look into customizing
the image to your needs, as well as to make sure that the build process is
tailored to your needs.

The following script can be a good starting point for most projects:

```dockerfile
# Based on @fideloper's fly.io laravel template
# https://github.com/superfly/flyctl/blob/94fec0925c75cfe30921f1a4df25fa9cbf2877e9/scanner/templates/laravel/Dockerfile

FROM ghcr.io/iksaku/laravel-alpine:8.1

# Install Laravel Scheduler into Crontab
COPY shared/crontab /usr/local/etc/crontab
RUN /usr/bin/crontab /usr/local/etc/crontab

# Copy our project files into the container
COPY . /var/www/html

# Install composer dependencies
RUN composer install --optimize-autoloader --no-dev

# Make sure our container has the correct permissions
# to tap into our project storage
RUN mkdir -p storage/logs \
    && chown -R laravel:laravel /var/www/html \
    && chmod -R ug+w /var/www/html/storage \
    && chmod -R 755 /var/www/html

# (Optional) Allow requests when running behind a proxy (i.e. fly.io)
RUN sed -i 's/protected \$proxies/protected \$proxies = "*"/g' app/Http/Middleware/TrustProxies.php
```

# Credits

As this intends to be an alternative version of Laravel Sail images, most of the credit
goes to the [@laravel](https://laravel.com/team) team itself for building and
maintaining Laravel Sail for us 💖.

Also, much inspiration (and snippets) come from [@fideloper](https://github.com/fideloper)'s
public work on Fly.io's Laravel Template 🔮.