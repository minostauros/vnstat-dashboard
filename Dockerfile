FROM php:7.0-apache

MAINTAINER Alex Marston <alexander.marston@gmail.com>

# Install vnstat & supervisor and change port
RUN set -xe \
    && apt-get update \
    && apt-get install -y vnstat vnstati supervisor \
    && sed -i '/UseLogging/s/2/0/' /etc/vnstat.conf \
    && sed -i.bak -e 's/<VirtualHost \*:80>/<VirtualHost \*:${PORT}>/g' /etc/apache2/sites-available/000-default.conf \
    && sed -i.bak '/Listen/{s/\([0-9]\+\)/${PORT}/; :a;n; ba}' /etc/apache2/ports.conf \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy application source code to html directory
COPY ./app/ /var/www/html/

# Install vnstat-dashboard
RUN apt-get update \
    && apt-get install -y git unzip \
    && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer \
    && composer install \
    && apt-get remove -y git \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Let supervisord start vnstat & vnstat-dashboard
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

VOLUME /var/lib/vnstat