# ---------- PHP ----------
FROM dunglas/frankenphp:latest AS php

WORKDIR /app

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    gd \
    zip

COPY . /app

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

RUN composer install --no-dev --optimize-autoloader --no-interaction

# ---------- NODE ----------
FROM node:20 AS node

WORKDIR /app

COPY --from=php /app /app

RUN npm install
RUN npm run build

# ---------- FINAL ----------
FROM dunglas/frankenphp:latest

WORKDIR /app

# MUY IMPORTANTE: instalar otra vez aquí
RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    gd \
    zip

COPY --from=php /app /app
COPY --from=node /app/public/build /app/public/build

COPY Caddyfile /etc/frankenphp/Caddyfile

RUN chmod -R 775 storage bootstrap/cache

EXPOSE 80