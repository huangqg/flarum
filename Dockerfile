FROM php:5-apache

RUN apt-get update && apt-get install -y \
        curl \
        git \
        libmcrypt-dev \
        libxml2-dev \
        libgd-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        mysql-client \
    && docker-php-ext-install -j$(nproc) mbstring zip pdo pdo_mysql json dom fileinfo mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
    
RUN a2enmod rewrite

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

VOLUME /var/www/html

RUN mkdir -p /usr/src/flarum \
    && cd /usr/src/flarum \
    && curl -sSL https://github.com/flarum/flarum/archive/v0.1.0-beta.4.tar.gz | tar --strip-components=1 -xz \
    && sed -i 's|"\*"|"0.3.0"|g' composer.json \
    && sed -i 's|"^0.1.0"|">=0.1.0 <=0.1.0-beta.4"|g' composer.json \
    && composer install
    # && composer create-project flarum/flarum . v0.1.0-beta.4 --stability=beta

COPY config.* /usr/src/flarum/

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
