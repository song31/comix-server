FROM php:apache

RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y libzip-dev; \
    apt-get purge -y --auto-remove; \
    rm -rf /var/lib/apt/lists/*; \
    pecl install zip rar; \
    pecl clear-cache; \
    docker-php-ext-enable zip.so rar.so; \
    rm -rf /tmp/*

RUN echo "open_basedir=/var/www/html:/volume" \
        >> /usr/local/etc/php/conf.d/aircomix.ini

RUN mkdir /var/www/auth ; \
    cd /var/www/auth && htpasswd -cb .htpasswd AirComix 1234

COPY conf/htaccess /var/www/html/.htaccess
COPY *.php /var/www/html/

COPY conf/httpd.conf-comix /etc/apache2/sites-enabled/001-aircomix.conf

VOLUME /volume/

EXPOSE 31257

