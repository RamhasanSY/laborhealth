#!/usr/bin/env sh
set -e

echo "[entrypoint] Node version: $(node -v)"
echo "[entrypoint] NPM version: $(npm -v)"

# Ensure Prisma client is generated (idempotent)
echo "[entrypoint] Generating Prisma client..."
npx prisma generate

# Wait a bit for DB readiness (compose has healthchecks, this is extra safety)
echo "[entrypoint] Waiting for database..."
for i in 1 2 3 4 5; do
  if node -e "require('url');" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "[entrypoint] Applying Prisma migrations..."
npx prisma migrate deploy

echo "[entrypoint] Starting server..."
exec npm start

