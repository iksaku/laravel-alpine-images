# Laravel Alpine Docker Images

This project provides Docker images containing the *bare minimum* requirements
to run your Laravel application. We use PHP's official CLI/ZTS images based
on Alpine Linux to further reduce the size of these images.

You may notice that your favorite PHP extensions and NodeJS are _missing_ from
these images, but this is a _feature_ ✨. The intention of these
images is to provide the *absolute minimum requirements* so that you, the
developer, pull these images, and further customize them with everything
you need.

## Available Images

You can choose the PHP version you want to run by specifying it as the tag for your image.
Currently, we are building the following base images:
  * `ghcr.io/iksaku/laravel-alpine:8.0`
  * `ghcr.io/iksaku/laravel-alpine:8.1`
  * `ghcr.io/iksaku/laravel-alpine:8.2`
  * `ghcr.io/iksaku/laravel-alpine:8.3`

We also build images compatible with [Laravel Octane](https://laravel.com/docs/octane),
you can choose your favorite flavor from the following list:

| Runtime      | Supported PHP versions | Image name example                                    |
| ------------ | ---------------------- | ----------------------------------------------------- |
| `openswoole` | `8.0`-`8.3`            | `ghcr.io/iksaku/laravel-alpine:8.3-octane-openswoole` |
| `roadrunner` | `8.0`-`8.3`            | `ghcr.io/iksaku/laravel-alpine:8.3-octane-roadrunner` |
| `swoole`     | `8.0`-`8.3`            | `ghcr.io/iksaku/laravel-alpine:8.3-octane-swoole`     |

### Available PHP extensions

Pre-installed PHP extensions in these images follow [Laravel's Requirements](https://laravel.com/docs/deployment#server-requirements)
and also include a few extras for Database and Octane support:

| Name           | Availability             |
| -------------- | ------------------------ |
| bcmath         | ✓                        |
| ctype          | ✓                        |
| curl           | ✓                        |
| dom            | ✓                        |
| fileinfo        | ✓                        |
| intl           | ✓                        |
| json           | ✓                        |
| mbstring       | ✓                        |
| mysqli         | ✓                        |
| openssl        | ✓                        |
| pcre           | ✓                        |
| pdo            | ✓                        |
| pdo_mysql      | ✓                        |
| pdo_pgsql      | ✓                        |
| pdo_sqlite     | ✓                        |
| pgsql          | ✓                        |
| redis          | ✓                        |
| sqlite3        | ✓                        |
| tokenizer      | ✓                        |
| xml            | ✓                        |
| composer       | ✓                        |
| pcntl          | ✓                        |
| openswoole     | Octane-only (OpenSwoole) |
| sockets        | Octane-only (RoadRunner) |
| swoole         | Octane-only (Swoole)     |

> **Note**
> You can always view the list of installed extensions from your terminal:
> `docker run --rm ghcr.io/iksaku/laravel-alpine:8.1 php -m`

### Installing additional PHP extensions

Our images come with [mlocati's `install-php-extension`](https://github.com/mlocati/docker-php-extension-installer)
binary available, so you can install additional PHP extensions that you may need:

```dockerfile
FROM ghcr.io/iksaku/laravel-alpine:8.1

RUN install-php-extension \
    ffi \
    vips \
    yaml
```

You can see all available extensions at [`install-php-extension`'s repo](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions).

## Running on Laravel Sail

As opposed to [Laravel Sail](https://laravel.com/docs/sail), you don't need to import
this repository as a package nor _publish_ our `Dockerfile` assets most of the time,
you can use our images directly in your `docker-compose.yml` file or use them
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
Octane images also run in Laravel Sail; you need to change your `image`
reference to specify you want to run octane:
```diff
services:
    laravel.test:
-       image: ghcr.io/iksaku/laravel-alpine:8.1
+       image: ghcr.io/iksaku/laravel-alpine:8.1-octane-roadrunner
```

### Running modified images
If you want to customize your image further, then work with the `build` option in your
`docker-compose.yml` file:

```sh
super-duper-project
├── app
├── bootstrap
│   ...
├── docker
│   └── super-duper-runtime
│       └── Dockerfile
├── docker-compose.yml
│   ...
```

```diff
services:
    laravel.test:
        build:
-           image: ghcr.io/iksaku/laravel-alpine:8.1
+           context: ./docker/super-duper-runtime
```

## Deploying to Production

Published images can also be used in production, but to run the best
in-class service, it is 100% recommended that you take a look into customizing
the image to your needs, as well as to make sure that the build process is
tailored to your needs.

The following script can be a good starting point for most projects:

```dockerfile
# Based on @fideloper's fly.io laravel template
# https://github.com/superfly/flyctl/blob/94fec0925c75cfe30921f1a4df25fa9cbf2877e9/scanner/templates/laravel/Dockerfile

FROM ghcr.io/iksaku/laravel-alpine:8.1

# Run the installed Laravel Scheduler in the background.
# You can replace the default entry by copying your own crontab
# file in container's /var/spool/cron/crontabs/root
RUN crond

# Copy our project files into the container
COPY . /var/www/html

# Install composer dependencies
RUN composer install --optimize-autoloader --no-dev

# Make sure our container has the correct permissions
# to tap into our project storage
RUN mkdir -p storage/logs \
    && chmod -R ug+w /var/www/html/storage \
    && chmod -R 755 /var/www/html

# (Optional) Allow requests when running behind a proxy (i.e., fly.io)
RUN sed -i 's/protected \$proxies/protected \$proxies = "*"/g' app/Http/Middleware/TrustProxies.php
```

When deploying your code to different environments, commonly `staging` or `production`, a
need to execute specific commands or script arises, mainly when dealing with Database migrations,
linking storage folders, or performing a general app optimization.

To help out with these tasks, our images support executing scripts inside a `.deploy`
directory before running the Laravel server.
To keep things simple, we do not check for a specific list of environments, instead we
execute deployment scripts when a `RUN_DEPLOY_SCRIPTS` environment variable is available
and has a value of `1`; otherwise, we ignore deployment scripts and jump straight
into server execution.

> **NOTE**
> `RUN_DEPLOY_SCRIPTS` is ignored when running in Laravel Sail to prevent unintended
> side effects.

If you have multiple scripts, you can number them in the order they should be executed:

```
my-laravel-app/
├── .deploy/
│  ├── 01_migrate_database.sh
│  ├── 02_optimize_application.sh
├── app/
├── bootstrap/
│   ...
```

> **NOTE**
> Deploy scripts should be suffixed with the `.sh` extension and will be run using
> Alpine's `sh` shell as we do not have `bash`.

### Deploying to Fly.io

It is recommended that when you deploy your code to a production environment you
run the following commands:
  * `php artisan optimize`
  * `php artisan migrate --force`

It is easy to add such commands to a before/after deploy hook on most cases, but
when deploying to [Fly.io](https://fly.io/) it is rather troublesome that you can't
execute these commands in your `Dockerfile`, as it has no access to envrionment variables
during build.

Another way to execute deployment commands when deploying to Fly.io is by creating a
`on_deploy.sh` script on your app's root directory, and then calling this script from
your `fly.toml` file using the [`deploy.release_command`](https://fly.io/docs/reference/configuration/#run-one-off-commands-before-releasing-a-deployment)
property:

```sh
#!/usr/bin/env sh

php artisan migrate --force
```

```toml
# fly.toml

#  ...

[deploy]
  release_command = "sh ./on_deploy.sh"

# ...
```

When using this method, Fly will spawn a _temporary_ (or _ephemeral_) virtual machine with
access to your app's environment to execute this script, and later on, it will destroy such
VM and queue another VM to take over the given environment. This means that any file-based
changes done while executing the `release_command` will not be persisted, so only procedures
that ping other services not in the VM, like Database migrations, will persist.

Use the above mentioned `.deploy` directory if you are planning to execute commands like
`artisan storage:link` or `artisan optimize`.

> **Note**
> The image's default entrypoint will manage this command, making
> your script execution to be done by the `laravel` user, which is the
> default one configured with all app permissions in your container.

#### Running multiple processes
Fly's support for [multiple process groups](https://fly.io/docs/apps/processes/) allow to run multiple
commands (or processes) in separate machines. This is useful when you want also run a queue worker or
a scheduler:

```toml
# fly.toml

# ...

[processes]
  # This is the default process group running our Laravel app
  app = ""
  # Run the Laravel scheduler using Alpine's crond in the foreground (for logs)
  scheduler = "crond -f"
  # Run the Laravel queue worker
  worker = "php artisan queue:work"
```

For more information on how process groups work and how you can scale them, check out:
* [Run Multiple Process Groups in an App](https://fly.io/docs/apps/processes/).
* [Scale Process Groups](https://fly.io/docs/apps/scale-count/#scale-by-process-group).

## Credits

As this intends to be an alternative version of Laravel Sail images, most of the credit
goes to the [@laravel](https://laravel.com/team) team itself for building and
maintaining Laravel Sail for us 💖.

Also, much inspiration (and snippets) come from [@fideloper](https://github.com/fideloper)'s
public work on [Fly.io's Laravel Template](https://github.com/superfly/flyctl) 🔮.
