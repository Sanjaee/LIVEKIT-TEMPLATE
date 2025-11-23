#!/bin/bash

# Script untuk test WebSocket connection ke LiveKit

echo "🧪 Testing WebSocket connection..."

# Test 1: Check LiveKit container
echo "1. Checking LiveKit container..."
docker compose ps livekit

# Test 2: Check LiveKit port
echo ""
echo "2. Checking LiveKit port 7880..."
curl -I http://localhost:7880 || echo "❌ LiveKit not accessible on localhost:7880"

# Test 3: Test via Nginx (HTTP)
echo ""
echo "3. Testing via Nginx HTTP..."
curl -I http://localhost/rtc || echo "❌ Nginx /rtc not accessible"

# Test 4: Test via Nginx (HTTPS)
echo ""
echo "4. Testing via Nginx HTTPS..."
curl -I https://zoom.zascript.com/rtc || echo "❌ Nginx HTTPS /rtc not accessible"

# Test 5: Check Nginx config
echo ""
echo "5. Checking Nginx configuration..."
sudo nginx -t

# Test 6: Check Nginx logs
echo ""
echo "6. Recent Nginx error logs:"
sudo tail -5 /var/log/nginx/zoom_error.log

echo ""
echo "✅ Test complete!"
echo ""
echo "📋 If WebSocket still fails, check:"
echo "   1. LiveKit container is running"
echo "   2. Nginx config is correct"
echo "   3. Nginx is reloaded: sudo systemctl reload nginx"
echo "   4. Firewall allows port 80 and 443"

