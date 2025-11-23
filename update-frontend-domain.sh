#!/bin/bash

# Script untuk update frontend/index.html dengan domain HTTPS
# Domain: zoom.zascript.com

echo "🔄 Updating frontend to use HTTPS domain..."

# Backup file original
cp frontend/index.html frontend/index.html.backup

# Update API_URL di frontend/index.html
# Ganti localhost dengan domain HTTPS
sed -i "s|const API_URL = 'http://localhost:8080';|const API_URL = 'https://zoom.zascript.com';|g" frontend/index.html
sed -i "s|const API_URL = 'http://8.215.196.12:8080';|const API_URL = 'https://zoom.zascript.com';|g" frontend/index.html

echo "✅ Frontend updated!"
echo "📝 Changed API_URL to: https://zoom.zascript.com"
echo ""
echo "⚠️  Don't forget to rebuild frontend container:"
echo "   docker compose build frontend"
echo "   docker compose up -d frontend"

