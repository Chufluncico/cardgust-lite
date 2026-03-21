# ---------- STAGE 1: Node ----------
FROM node:20 AS node

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ---------- STAGE 2: PHP ----------
FROM dunglas/frankenphp:latest

WORKDIR /app

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    gd \
    zip

COPY . /app

# copiar assets compilados
COPY --from=node /app/public/build /app/public/build

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chmod -R 775 storage bootstrap/cache

EXPOSE 80