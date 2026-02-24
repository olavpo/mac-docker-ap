#!/bin/bash

echo "🔄 Analytics Platform: Complete Reset and Run"

# 1. Stop everything
echo "🛑 Stopping all containers..."
docker compose down 2>/dev/null || true

# 2. Clean up Docker
echo "🗑️ Cleaning Docker system..."
docker volume prune -f 2>/dev/null || true
docker system prune -f 2>/dev/null || true

# 3. Remove data directories
echo "📂 Removing old data..."
sudo rm -rf data/ 2>/dev/null || true

# 4. Create fresh directories
echo "📁 Creating fresh data directories..."
mkdir data

# 5. Start containers
echo "🚀 Starting containers..."
docker compose up -d

# 6. Wait for initialization
echo "⏳ Waiting for services to initialize..."
sleep 30

# 7. Initialize Superset
echo "📦 Initializing Superset..."
docker compose exec superset superset db upgrade 2>/dev/null || echo "Superset already initialized"
docker compose exec superset superset fab create-admin --username admin --firstname Superset --lastname Admin --email admin@superset.com --password admin 2>/dev/null || echo "Admin already exists"
