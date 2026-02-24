#!/bin/bash

set -euo pipefail

echo "🔄 Analytics Platform: Complete Reset and Run"

# 1. Stop everything for this project
echo "🛑 Stopping all containers..."
docker compose down || true

# 2. Remove project-specific data (adjust paths/volumes as needed)
echo "📂 Removing old data..."
sudo rm -rf data/ 2>/dev/null || true
mkdir -p data

# 3. Start containers
echo "🚀 Starting containers..."
docker compose up -d

# 4. Wait for Superset to be healthy (it already has a /health endpoint)
echo "⏳ Waiting for Superset to report healthy..."
until docker compose exec -T superset curl -sf http://localhost:8088/health >/dev/null 2>&1; do
  echo "   Superset not healthy yet, waiting..."
  sleep 5
done

# 5. Initialize Superset (DB migrations + roles/permissions)
echo "📦 Running Superset migrations..."
docker compose exec -T superset superset db upgrade

echo "🔐 Creating admin user (if needed)..."
docker compose exec -T superset superset fab create-admin \
  --username admin \
  --firstname Superset \
  --lastname Admin \
  --email admin@superset.com \
  --password district \
  || echo "Admin already exists"

echo "⚙️ Running superset init (roles & permissions)..."
docker compose exec -T superset superset init

echo "✅ Analytics platform reset & startup complete."
