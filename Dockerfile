FROM dunglas/frankenphp:latest

WORKDIR /app

# Permitir composer como root (importante en Docker)
ENV COMPOSER_ALLOW_SUPERUSER=1

# Instalar extensiones necesarias para Laravel
RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    gd \
    zip

# Copiar proyecto
COPY . /app

# Instalar composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instalar dependencias
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Permisos necesarios para Laravel
RUN chmod -R 775 storage bootstrap/cache

# Copiar configuración de FrankenPHP (Caddy)
COPY Caddyfile /etc/frankenphp/Caddyfile

EXPOSE 80