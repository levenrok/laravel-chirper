# Pull PHP image
FROM php:8.4-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpq-dev \
    supervisor \
    && curl -sL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-install pdo pdo_pgsql

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/html/laravel-chirper

# Copy the frontend files and package.json/package-lock.json
COPY package.json package-lock.json /var/www/html/laravel-chirper/

# Install frontend dependencies (node_modules)
RUN npm install

# Copy the remaining project files
COPY . .

# # Build the frontend assets
# RUN npm run build
# Install PHP dependencies using Composer
RUN composer install --no-dev --optimize-autoloader

# Set permissions for PHP and storage directories
RUN chmod -R 775 storage bootstrap/cache

# Expose port 8000 for Laravel
EXPOSE 8000

# Install Supervisor (if needed for running queue workers)
COPY cront.conf /etc/supervisor/conf.d/cront.conf

# Start Supervisor to manage Laravel and queue workers
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/cront.conf"]
