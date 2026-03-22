#!/bin/sh

set -e

echo "Post-deploy Cardgust iniciado..."

# -----------------------------
# STORAGE (estructura mínima)
# -----------------------------
echo "Inicializando storage..."

mkdir -p /app/storage/app/public
mkdir -p /app/storage/framework/cache/data
mkdir -p /app/storage/framework/sessions
mkdir -p /app/storage/framework/views
mkdir -p /app/storage/logs

# -----------------------------
# PERMISOS
# -----------------------------
echo "Ajustando permisos..."

chown -R www-data:www-data /app/storage
chmod -R 775 /app/storage

# -----------------------------
# STORAGE LINK
# -----------------------------
echo "Creando storage link..."

php artisan storage:link || true

# -----------------------------
# LIMPIEZA Y CACHE
# -----------------------------
echo "Limpiando caches..."

php artisan optimize:clear

# (opcional, puedes activar luego)
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Post-deploy completado"