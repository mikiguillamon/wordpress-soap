FROM wordpress:latest

# SOAP para Redsys
RUN apt-get update && \
    apt-get install -y libxml2-dev && \
    docker-php-ext-install soap && \
    rm -rf /var/lib/apt/lists/*

# OPcache para acelerar PHP
RUN docker-php-ext-install opcache

# Extensión Redis para PHP
RUN pecl install redis && \
    docker-php-ext-enable redis

# Configuración básica de OPcache para producción
RUN { \
      echo 'opcache.enable=1'; \
      echo 'opcache.memory_consumption=256'; \
      echo 'opcache.interned_strings_buffer=16'; \
      echo 'opcache.max_accelerated_files=20000'; \
      echo 'opcache.revalidate_freq=0'; \
      echo 'opcache.validate_timestamps=0'; \
    } > /usr/local/etc/php/conf.d/opcache.ini

# Aumentar memoria y otros límites de PHP
RUN { \
      echo 'memory_limit = 1024M'; \
      echo 'max_execution_time = 120'; \
      echo 'post_max_size = 64M'; \
      echo 'upload_max_filesize = 64M'; \
    } > /usr/local/etc/php/conf.d/custom-resources.ini