#!/bin/bash

echo "Building Native ARM64 images for Analytics Platform..."

# Build all custom services with native ARM64 support
echo "Building bao-identity (native ARM64)..."
docker build -t bao-identity-native -f bao-identity/Dockerfile ./bao-identity

echo "Building bao-data-pipeline (native ARM64)..."
docker build -t bao-data-pipeline-native -f bao-data-pipeline/Dockerfile ./bao-data-pipeline

echo "Building bao-api-gateway (native ARM64)..."
docker build -t bao-api-gateway-native -f bao-api-gateway/Dockerfile ./bao-api-gateway

echo "Building dhis2-superset-gateway (native ARM64)..."
docker build -t dhis2-superset-gateway-native -f dhis2-superset-gateway/Dockerfile ./dhis2-superset-gateway

echo "Building superset (native ARM64)..."
docker build -t superset-native -f superset/Dockerfile ./superset

echo "All native ARM64 images built successfully!"

echo "You can now run the platform with:"
echo "docker compose -f docker-compose.yml up -d"