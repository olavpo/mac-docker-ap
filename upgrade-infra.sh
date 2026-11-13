#!/bin/bash

set -euo pipefail

# Upgrade third-party infrastructure services to the latest image matching
# their pinned tag in docker-compose.yml. Major versions are pinned, so this
# only pulls minor/patch updates.
#
#   ap-db      postgres:16          → latest 16.x patch
#   redis      redis:8-alpine       → latest 8.x patch
#   nginx      nginx:stable-alpine  → latest stable patch
#   clickhouse clickhouse-server:25.8 → latest 25.8.x patch
#
# Pulsar (zookeeper/bookie/pulsar) is intentionally excluded — it's fully
# pinned (3.3.9) and version upgrades require deliberate coordination.
#
# Usage:
#   ./upgrade-infra.sh                  # upgrade all infra services
#   ./upgrade-infra.sh ap-db clickhouse # upgrade a subset

ALL_SERVICES=(ap-db redis nginx clickhouse)

valid_service() {
  case "$1" in
    ap-db|redis|nginx|clickhouse) return 0 ;;
    *) return 1 ;;
  esac
}

if [ "$#" -eq 0 ]; then
  SERVICES=("${ALL_SERVICES[@]}")
else
  SERVICES=("$@")
  for s in "${SERVICES[@]}"; do
    if ! valid_service "$s"; then
      echo "❌ Unknown service: $s (allowed: ${ALL_SERVICES[*]})"
      exit 1
    fi
  done
fi

# Compose service name for the proxy is "proxy" (nginx is its image)
declare -A COMPOSE_NAME=(
  [ap-db]=ap-db
  [redis]=redis
  [nginx]=proxy
  [clickhouse]=clickhouse
)

COMPOSE_SERVICES=()
for s in "${SERVICES[@]}"; do
  COMPOSE_SERVICES+=("${COMPOSE_NAME[$s]}")
done

echo "⬇️  Pulling latest images for: ${SERVICES[*]}"
docker compose pull "${COMPOSE_SERVICES[@]}"

echo "🚀 Recreating containers: ${COMPOSE_SERVICES[*]}"
docker compose up -d "${COMPOSE_SERVICES[@]}"

echo "🧹 Pruning dangling images..."
docker image prune -f >/dev/null

echo "✅ Infra upgrade complete. Check health with: docker compose ps"
