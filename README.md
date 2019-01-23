# docker_phpdev

PHP-FPM докер контейнер для разработки.

Сделан специально для {IT.IS} Upgrade

Дополнительно к стандартному контейнеру php:7.3-fpm, добавлены следующие модули: pdo_mysql, intl, opcache, gd, apcu, redis, xdebug, php_spx.
Также, во время запуска контейнера, устанавливается/обновляется composer. 

# Запуск контейнера через docker-compose

```yml
version: '3'

services:
    # ...

    php:
        image: miramir/itis_phpdev:7.3-fpm-alpine
        volumes:
            - ./:/app
        environment:
            - ENVIRONMENT=development
#           - PHP_XDEBUG_ENABLED=1
#           - PHP_XDEBUG_PROFILER_OUTPUT_DIR=/app/runtime
#           - PHP_SPX_PROFILE=1

    # ...
```

# Переменные для настройки контейнера

* ENVIRONMENT - окружение ('production', 'development'), определяет какие конфиги php.ini будут применены
* PHP_XDEBUG_ENABLED - активировать ли расширение xdebug (более подробно настройки смотрите в entrypoint.sh)
* PHP_SPX_PROFILE - активировать ли расширение php_spx (более подробно настройки смотрите в entrypoint.sh)