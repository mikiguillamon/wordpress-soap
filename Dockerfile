FROM wordpress:latest

# SOAP para Redsys
RUN apt-get update && \
    apt-get install -y libxml2-dev && \
    docker-php-ext-install soap && \
    rm -rf /var/lib/apt/lists/*

# OPcache
RUN docker-php-ext-install opcache

# Redis para PHP
RUN pecl install redis && \
    docker-php-ext-enable redis

# OPcache para producción
RUN { \
      echo 'opcache.enable=1'; \
      echo 'opcache.memory_consumption=256'; \
      echo 'opcache.interned_strings_buffer=16'; \
      echo 'opcache.max_accelerated_files=20000'; \
      echo 'opcache.revalidate_freq=0'; \
      echo 'opcache.validate_timestamps=0'; \
    } > /usr/local/etc/php/conf.d/opcache.ini

# Límites PHP
RUN { \
      echo 'memory_limit = 512M'; \
      echo 'max_execution_time = 120'; \
      echo 'max_input_time = 120'; \
      echo 'post_max_size = 64M'; \
      echo 'upload_max_filesize = 64M'; \
    } > /usr/local/etc/php/conf.d/custom-resources.ini

# Apache prefork
RUN sed -ri \
      's/^[[:space:]]*StartServers[[:space:]]+[0-9]+/StartServers             4/' \
      /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -ri \
      's/^[[:space:]]*MinSpareServers[[:space:]]+[0-9]+/MinSpareServers          4/' \
      /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -ri \
      's/^[[:space:]]*MaxSpareServers[[:space:]]+[0-9]+/MaxSpareServers          8/' \
      /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -ri \
      's/^[[:space:]]*MaxRequestWorkers[[:space:]]+[0-9]+/MaxRequestWorkers      16/' \
      /etc/apache2/mods-available/mpm_prefork.conf && \
    sed -ri \
      's/^[[:space:]]*MaxConnectionsPerChild[[:space:]]+[0-9]+/MaxConnectionsPerChild 300/' \
      /etc/apache2/mods-available/mpm_prefork.conf

# HTTP / KeepAlive
RUN { \
      echo 'Timeout 120'; \
      echo 'KeepAlive On'; \
      echo 'MaxKeepAliveRequests 100'; \
      echo 'KeepAliveTimeout 2'; \
    } > /etc/apache2/conf-available/jff-performance.conf && \
    a2enconf jff-performance
