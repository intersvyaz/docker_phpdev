#!/usr/bin/env sh

# Копируем конфиги приложения в зависимости от переменной окружения
ENVIRONMENT=${ENVIRONMENT:-"production"}

if [[ -e "/usr/local/etc/php/php.ini-${ENVIRONMENT}" ]] ; then
    cp "/usr/local/etc/php/php.ini-${ENVIRONMENT}" "/usr/local/etc/php/php.ini"
fi

# Включение XDEBUG.
# Entrypoint может запускаться несколько раз. Проверим, что xdebug не конфигирировался при предыдущем запуске.
XDEBUG_INI="/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
PHP_XDEBUG_ENABLED="${PHP_XDEBUG_ENABLED:-0}"

if [[ "${PHP_XDEBUG_ENABLED}" = "1" ]] && [[ ! -f "${XDEBUG_INI}" ]] ; then
    docker-php-ext-enable xdebug

    echo 'xdebug.remote_enable="1"' >> "${XDEBUG_INI}"
    echo 'xdebug.remote_port=9000' >> "${XDEBUG_INI}"

    # Задание переменной в случае, если она не задана.
    PHP_XDEBUG_CONNECT_BACK="${PHP_XDEBUG_CONNECT_BACK:-0}"

    # Если адрес для xdebug не установлен и жесткий PHP_XDEBUG_CONNECT_BACK не установлен, то попробуем получить
    # PHP_XDEBUG_REMOTE из host.docker.internal (работает для Windows & Mac).
    # Для Windows & Mac единственная возможность достучаться до хостовой машины - host.docker.internal.
    if [ ! -n "$PHP_XDEBUG_REMOTE" ] && [ "$PHP_XDEBUG_CONNECT_BACK" -ne 1 ] ; then
        PHP_XDEBUG_REMOTE=host.docker.internal
    fi

    # Если установлен XDEBUG_REMOTE и жесткий XDEBUG_CONNECT_BACK не установлен, то коннектимся к XDEBUG_REMOTE.
    if [ -n "$PHP_XDEBUG_REMOTE" ] && [ "$PHP_XDEBUG_CONNECT_BACK" -ne 1 ] ; then
        echo 'xdebug.remote_connect_back="0"' >> "${XDEBUG_INI}"
        echo 'xdebug.remote_host="'$PHP_XDEBUG_REMOTE'"' >> "${XDEBUG_INI}"
    else
        echo 'xdebug.remote_connect_back="1"' >> "${XDEBUG_INI}"
    fi

    # настройка профайлера
    echo 'xdebug.profiler_enable=0' >> "${XDEBUG_INI}"
    echo 'xdebug.profiler_enable_trigger=1' >> "${XDEBUG_INI}"
    echo 'xdebug.profiler_output_name="cachegrind.out.%R.%t"' >> "${XDEBUG_INI}"

    # Папка для размещения файлов профиля, если нужен доступ с хост машины надо добавить её в volumes
    PHP_XDEBUG_PROFILER_OUTPUT_DIR="${PHP_XDEBUG_PROFILER_OUTPUT_DIR:-/tmp}"
    echo 'xdebug.profiler_output_dir="'$PHP_XDEBUG_PROFILER_OUTPUT_DIR'"' >> "${XDEBUG_INI}"
fi

PHP_SPX_PROFILE_INI="/usr/local/etc/php/conf.d/docker-php-ext-spx.ini"
if [[ -n "$PHP_SPX_PROFILE" && ! -f "${PHP_SPX_PROFILE_INI}" ]]; then
    docker-php-ext-enable spx
    echo 'spx.http_enabled=1' >> "${PHP_SPX_PROFILE_INI}"
    echo 'spx.http_key="dev"' >> "${PHP_SPX_PROFILE_INI}"
    echo 'spx.http_ip_whitelist="'`ip ro | grep default | cut -d\  -f3`'"' >> "${PHP_SPX_PROFILE_INI}"
fi

# Установка композера
if [ ! -e /usr/local/bin/composer ] ; then
    curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --quiet
else
    composer self-update --quiet
fi

exec docker-php-entrypoint "$@"