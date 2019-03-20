FROM php:7.3-fpm-alpine

ENV BUILD_DEPS autoconf gcc cmake g++ make icu-dev freetype-dev libjpeg-turbo-dev libpng-dev zlib-dev wget

RUN apk add --update --no-cache icu freetype libjpeg-turbo libpng zlib \
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) pdo_mysql intl opcache gd \
    && pecl install -o -f apcu redis xdebug-2.7.0beta1 \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable apcu \
    && rm -rf /tmp/pear \
    # устанавливаем php-spx
    && wget https://github.com/NoiseByNorthwest/php-spx/archive/v0.4.0.tar.gz \
    && tar -xzf v0.4.0.tar.gz \
    && cd php-spx-0.4.0 \
    && phpize && ./configure && make && make install \
    && cd ../ && rm -rf php-spx-0.4.0 && rm -rf v0.4.0.tar.gz \
    && apk del .build-deps


COPY entrypoint.sh /usr/local/bin

WORKDIR /app
ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
