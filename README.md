# 🚀 Deploy de Laravel en Coolify (Guía Simplificada Producción)

## 🧠 Objetivo

Desplegar una aplicación Laravel en Coolify con:

* Docker (FrankenPHP)
* HTTPS
* Redis (cache + sesiones)
* Storage persistente
* Deploy reproducible

---

# 🧱 1. Requisitos previos

* App Laravel funcionando en local
* Repositorio Git (GitHub, etc.)
* `.env.example` configurado
* Node + Vite funcionando (`npm run build`)

---

# 🐳 2. Dockerfile

Crear `Dockerfile` en la raíz:

```dockerfile
FROM dunglas/frankenphp:latest AS php

WORKDIR /app

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    gd \
    zip \
    intl \
    opcache \
    redis

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

RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    bcmath \
    gd \
    zip \
    intl \
    opcache \
    redis

COPY --from=php /app /app
COPY --from=node /app/public/build /app/public/build

COPY Caddyfile /etc/frankenphp/Caddyfile

RUN chown -R www-data:www-data /app \
    && chmod -R 775 /app/storage /app/bootstrap/cache

EXPOSE 80

CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]
```

---

# 🌐 3. Crear app en Coolify

1. New Resource → Application
2. Source: Git Repository
3. Build: Dockerfile

---

# 🌍 4. Dominio

* Usar dominio de Coolify (`*.sslip.io`) o propio
* Configurar DNS si aplica

⚠️ Probar primero en HTTP antes de activar HTTPS

---

# 🔒 5. HTTPS

Activar HTTPS en Coolify cuando la app funcione correctamente

---

# ⚙️ 6. Variables de entorno

Ejemplo base:

```env
APP_NAME=Cardgust Lite
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false
APP_URL=https://tudominio

DB_CONNECTION=mysql
DB_HOST=servicio_db
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=...
DB_PASSWORD=...

REDIS_HOST=servicio_redis
REDIS_PASSWORD=...
REDIS_PORT=6379

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

---

# 🧠 7. Redis

1. Crear servicio Redis en Coolify
2. Usar sus credenciales en `.env`

---

# 💾 8. Volumen storage (CRÍTICO)

Añadir volumen:

```
Destination: /app/storage
```

👉 Hace persistentes:

* logs
* sesiones
* cache
* archivos

---

# ⚠️ 9. Problema importante

El volumen reemplaza `/storage` → queda vacío → Laravel falla

---

# 🔧 10. Post-deploy (SOLUCIÓN)

Crear archivo:

```
docker/post-deploy.sh
```

```bash
#!/bin/sh

mkdir -p /app/storage/app/public
mkdir -p /app/storage/framework/cache/data
mkdir -p /app/storage/framework/sessions
mkdir -p /app/storage/framework/views
mkdir -p /app/storage/logs

chown -R www-data:www-data /app/storage
chmod -R 775 /app/storage

php artisan storage:link || true
php artisan optimize:clear
```

En Coolify:

```
sh docker/post-deploy.sh
```

---

# 🔗 11. storage:link

```bash
php artisan storage:link
```

Crea:

```
public/storage → storage/app/public
```

---

# 🔐 12. HTTPS y proxies

En `bootstrap/app.php`:

```php
->withMiddleware(function ($middleware) {
    $middleware->trustProxies(at: '*');
})
```

---

# 🧪 13. Comprobaciones

* ✔ La web carga
* ✔ Login funciona
* ✔ No hay warnings HTTPS
* ✔ Sesiones persisten tras redeploy
* ✔ Storage funciona
* ✔ Redis guarda datos

---

# 🧠 14. Conceptos clave

### Storage

* No viene de Git
* Lo controla el volumen
* Se inicializa en runtime

### Docker

* Build ≠ Runtime
* El volumen reemplaza contenido

### Redis

* Cache
* Sesiones
* Preparado para colas

---

# 🎯 Estado final

* Laravel funcionando en producción
* HTTPS activo
* Redis integrado
* Storage persistente
* Deploy reproducible

---

# 📋 Próximos pasos

* Backups (base de datos + storage)
* Logs y monitorización
* Optimización Laravel (cache, routes, views)
* Seguridad básica
* Queue workers (más adelante)

---

# 💬 Resumen

> Deploy real no es solo que funcione
> Es que sea estable, reproducible y recuperable

```
```
