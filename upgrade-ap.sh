#!/bin/bash

set -euo pipefail

# Upgrade the Analytics Platform custom components (identity, data-pipeline,
# api-gateway, dhis2-superset-gateway) by pulling the latest JARs from S3 and
# recreating only those containers. Third-party services (Postgres, Redis,
# ClickHouse, Pulsar, Nginx) are left untouched.
#
# Usage:
#   ./upgrade-ap.sh                  # upgrade all four AP components
#   ./upgrade-ap.sh identity gateway # upgrade a subset

ALL_COMPONENTS=(identity data-pipeline gateway dhis2-gateway)

# Map compose service name -> (image tag, build context)
image_for() {
  case "$1" in
    identity)       echo "bao-identity-native bao-identity" ;;
    data-pipeline)  echo "bao-data-pipeline-native bao-data-pipeline" ;;
    gateway)        echo "bao-api-gateway-native bao-api-gateway" ;;
    dhis2-gateway)  echo "dhis2-superset-gateway-native dhis2-superset-gateway" ;;
    *) echo ""; return 1 ;;
  esac
}

if [ "$#" -eq 0 ]; then
  COMPONENTS=("${ALL_COMPONENTS[@]}")
else
  COMPONENTS=("$@")
fi

echo "🔧 Upgrading AP components: ${COMPONENTS[*]}"

for svc in "${COMPONENTS[@]}"; do
  mapping=$(image_for "$svc") || { echo "❌ Unknown component: $svc"; exit 1; }
  read -r tag ctx <<< "$mapping"
  echo "🏗️  Building $tag (no cache, fetches latest JAR)..."
  docker build --no-cache --pull -t "$tag" "./$ctx"
done

echo "🚀 Recreating containers: ${COMPONENTS[*]}"
docker compose up -d "${COMPONENTS[@]}"

echo "🧹 Pruning dangling images..."
docker image prune -f >/dev/null

echo "✅ Upgrade complete. Check health with: docker compose ps"
