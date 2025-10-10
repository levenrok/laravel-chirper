# Stage 1: Base - Setup common dependencies and a non-root user
FROM php:8.4-fpm-alpine AS base

RUN apk add --no-cache libpq-dev gnutls-dev autoconf build-base zlib-dev libzip-dev \
    curl-dev nginx supervisor shadow bash

RUN addgroup --system --gid 1000 appgroup
RUN adduser --system --ingroup appgroup --uid 1000 appuser

WORKDIR /app

COPY ./docker/production/php/php.ini $PHP_INI_DIR/
COPY ./docker/production/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker/production/php/conf.d/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini

COPY ./docker/production/nginx/nginx.conf ./docker/production/nginx/fastcgi_params ./docker/production/nginx/fastcgi_fpm ./docker/production/nginx/gzip_params /etc/nginx/
RUN mkdir -p /var/lib/nginx/tmp /var/log/nginx /run/nginx /var/run/supervisor
RUN /usr/sbin/nginx -t -c /etc/nginx/nginx.conf

RUN chown -R appuser:appgroup /var/lib/nginx /var/log/nginx /run/nginx
RUN chown -R appuser:appgroup /usr/local/etc/php-fpm.d
RUN chown -R appuser:appgroup /var/run/supervisor

COPY ./docker/production/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY ./docker/production/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

USER appuser


# Stage 2: Build - Install Composer dependencies and compile assets
FROM base AS build

USER root

RUN apk add --no-cache unzip nodejs npm

RUN docker-php-ext-install pdo pdo_pgsql zip

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN npm install

RUN npm run build


# Stage 3: Production - Create the final, lean production image
FROM base AS production

COPY --from=build /app /app

USER root

RUN chown -R appuser:appgroup storage bootstrap/cache

RUN passwd -l root
RUN usermod -s /usr/sbin/nologin root

USER appuser

# Run Laravel optimization commands.
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
