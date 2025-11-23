#!/bin/bash

# Script untuk deploy aplikasi Zoom Video Call ke VPS
# Domain: zoom.zascript.com
# VPS IP: 8.215.196.12

set -e

echo "🚀 Deploying Zoom Video Call App to VPS"

# Check if running on VPS
if [ ! -f "/etc/nginx/sites-available/zoom.zascript.com" ]; then
    echo "⚠️  Nginx configuration not found. Please run setup-nginx.sh first!"
    exit 1
fi

# Update frontend domain
echo "🔄 Updating frontend domain..."
./update-frontend-domain.sh

# Build and start containers
echo "🐳 Building and starting Docker containers..."
docker compose down
docker compose build --no-cache
docker compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "📊 Checking service status..."
docker compose ps

# Test backend
echo "🧪 Testing backend..."
curl -f http://localhost:8080/health || echo "⚠️  Backend health check failed"

# Test frontend
echo "🧪 Testing frontend..."
curl -f http://localhost:3000 || echo "⚠️  Frontend check failed"

# Reload nginx
echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Deployment complete!"
echo ""
echo "🌐 Your app is now available at:"
echo "   https://zoom.zascript.com"
echo ""
echo "📋 Check logs:"
echo "   docker compose logs -f"
echo ""
echo "📋 Check nginx status:"
echo "   sudo systemctl status nginx"

