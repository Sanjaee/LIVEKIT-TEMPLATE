#!/bin/bash

# Script untuk fix nginx SSL error
# Jalankan script ini jika nginx error karena SSL certificate belum ada

set -e

echo "🔧 Fixing nginx SSL configuration..."

# Step 1: Copy HTTP-only config
echo "📝 Copying HTTP-only nginx configuration..."
if [ ! -f nginx-http-only.conf ]; then
    echo "❌ nginx-http-only.conf not found!"
    exit 1
fi

sudo cp nginx-http-only.conf /etc/nginx/sites-available/zoom.zascript.com

# Step 2: Test nginx config
echo "🧪 Testing nginx configuration..."
sudo nginx -t

# Step 3: Restart nginx
echo "🔄 Restarting nginx..."
sudo systemctl restart nginx

# Step 4: Request SSL certificate
echo "🔒 Requesting SSL certificate..."
echo "⚠️  Make sure domain zoom.zascript.com points to IP 8.215.196.12!"
read -p "Press Enter to continue..."

sudo certbot --nginx -d zoom.zascript.com --non-interactive --agree-tos --email admin@zascript.com --redirect

# Step 5: Verify certificate exists
if [ ! -f /etc/letsencrypt/live/zoom.zascript.com/fullchain.pem ]; then
    echo "❌ SSL certificate not found. Please check certbot logs."
    exit 1
fi

# Step 6: Update dengan full HTTPS config
echo "📝 Updating with full HTTPS configuration..."
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com

# Step 7: Test nginx config dengan SSL
echo "🧪 Testing nginx configuration (with SSL)..."
sudo nginx -t

# Step 8: Reload nginx
echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Fix complete!"
echo ""
echo "📋 Check status:"
echo "   sudo systemctl status nginx"
echo "   sudo certbot certificates"

