FROM php:7.0-apache

MAINTAINER Alex Marston <alexander.marston@gmail.com>

# Install vnstat & supervisor
RUN set -xe \
    && apt-get update \
    && apt-get install -y vnstat vnstati supervisor \
    && sed -i '/UseLogging/s/2/0/' /etc/vnstat.conf \
    && rm -rf /var/lib/apt/lists/*

# Copy application source code to html directory
COPY ./app/ /var/www/html/

# Install vnstat-dashboard
RUN apt-get update \
    && apt-get install -y git unzip \
    && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
    && composer install

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Let supervisord start vnstat & vnstat-dashboard
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

VOLUME /var/lib/vnstat