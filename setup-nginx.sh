#!/bin/bash

# Script untuk setup Nginx dan SSL untuk Zoom Video Call App
# Domain: zoom.zascript.com
# VPS IP: 8.215.196.12

set -e

echo "🚀 Setting up Nginx and SSL for zoom.zascript.com"

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Nginx
echo "📦 Installing Nginx..."
sudo apt install -y nginx

# Install Certbot untuk SSL
echo "📦 Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

# Backup konfigurasi nginx default jika ada
if [ -f /etc/nginx/sites-available/default ]; then
    echo "💾 Backing up default nginx config..."
    sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
fi

# Create directory untuk certbot challenge
echo "📁 Creating certbot directory..."
sudo mkdir -p /var/www/certbot

# Step 1: Copy HTTP-only config untuk certbot challenge
echo "📝 Copying HTTP-only nginx configuration (for SSL setup)..."
sudo cp nginx-http-only.conf /etc/nginx/sites-available/zoom.zascript.com

# Create symbolic link
echo "🔗 Creating symbolic link..."
sudo ln -sf /etc/nginx/sites-available/zoom.zascript.com /etc/nginx/sites-enabled/

# Remove default site jika ada
if [ -L /etc/nginx/sites-enabled/default ]; then
    echo "🗑️  Removing default site..."
    sudo rm /etc/nginx/sites-enabled/default
fi

# Test nginx configuration (HTTP only)
echo "🧪 Testing nginx configuration (HTTP only)..."
sudo nginx -t

# Start/reload nginx
echo "🔄 Starting nginx..."
sudo systemctl restart nginx

# Setup SSL dengan Let's Encrypt
echo "🔒 Setting up SSL certificate..."
echo "⚠️  Make sure domain zoom.zascript.com points to IP 8.215.196.12 before continuing!"
read -p "Press Enter to continue with SSL setup..."

# Request SSL certificate (certbot akan otomatis update nginx config)
echo "📜 Requesting SSL certificate from Let's Encrypt..."
sudo certbot --nginx -d zoom.zascript.com --non-interactive --agree-tos --email admin@zascript.com --redirect

# Certbot sudah otomatis update config, tapi kita perlu pastikan HTTPS config lengkap
# Copy full HTTPS config jika certbot tidak update dengan benar
echo "📝 Verifying SSL configuration..."
if [ ! -f /etc/letsencrypt/live/zoom.zascript.com/fullchain.pem ]; then
    echo "❌ SSL certificate not found. Please check certbot logs."
    exit 1
fi

# Update dengan full HTTPS config (jika certbot tidak update dengan benar)
echo "📝 Updating nginx config with full HTTPS configuration..."
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com

# Test nginx configuration dengan SSL
echo "🧪 Testing nginx configuration (with SSL)..."
sudo nginx -t

# Reload nginx
echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

# Enable nginx to start on boot
echo "✅ Enabling nginx to start on boot..."
sudo systemctl enable nginx

# Setup auto-renewal untuk SSL
echo "🔄 Setting up SSL auto-renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Make sure Docker containers are running:"
echo "   docker compose up -d"
echo ""
echo "2. Check nginx status:"
echo "   sudo systemctl status nginx"
echo ""
echo "3. Check SSL certificate:"
echo "   sudo certbot certificates"
echo ""
echo "4. Test your site:"
echo "   https://zoom.zascript.com"

