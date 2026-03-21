FROM dunglas/frankenphp:latest

WORKDIR /app

RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    gd \
    zip

COPY . /app

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

RUN chmod -R 775 storage bootstrap/cache

COPY Caddyfile /etc/frankenphp/Caddyfile