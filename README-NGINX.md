# Setup Nginx dan SSL untuk Zoom Video Call App

## Prerequisites

1. Domain `zoom.zascript.com` sudah di-point ke IP VPS `8.215.196.12`
2. VPS sudah memiliki Docker dan Docker Compose terinstall
3. Aplikasi sudah di-deploy dan berjalan di:
   - Frontend: `localhost:3000`
   - Backend: `localhost:8080`
   - LiveKit: `localhost:7880`

## Langkah-langkah Setup

### 1. Pastikan Domain Sudah Di-Point

Pastikan DNS record untuk `zoom.zascript.com` sudah mengarah ke IP `8.215.196.12`:

```bash
# Test dengan ping
ping zoom.zascript.com

# Atau dengan dig
dig zoom.zascript.com
```

### 2. Upload File ke VPS

Upload file berikut ke VPS:
- `nginx.conf`
- `setup-nginx.sh`

```bash
# Menggunakan SCP
scp nginx.conf setup-nginx.sh user@8.215.196.12:/home/user/

# Atau menggunakan SFTP
```

### 3. Jalankan Setup Script

```bash
# SSH ke VPS
ssh user@8.215.196.12

# Berikan permission execute
chmod +x setup-nginx.sh

# Jalankan script
./setup-nginx.sh
```

### 4. Manual Setup (Jika Script Gagal)

Jika script otomatis gagal, ikuti langkah manual:

```bash
# 1. Install Nginx dan Certbot
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

# 2. Copy konfigurasi
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com

# 3. Create symbolic link
sudo ln -s /etc/nginx/sites-available/zoom.zascript.com /etc/nginx/sites-enabled/

# 4. Remove default site
sudo rm /etc/nginx/sites-enabled/default

# 5. Test konfigurasi
sudo nginx -t

# 6. Request SSL certificate
sudo certbot --nginx -d zoom.zascript.com

# 7. Reload nginx
sudo systemctl reload nginx
```

## Konfigurasi Docker Compose

Pastikan `docker-compose.yml` sudah dikonfigurasi dengan benar:

```yaml
services:
  frontend:
    ports:
      - "3000:80"  # Internal port 80, external 3000
      
  backend:
    ports:
      - "8080:8080"
      
  livekit:
    ports:
      - "7880:7880"
      - "7881:7881"
      - "7882:7882/udp"
```

## Update Frontend untuk Menggunakan HTTPS

Update `frontend/index.html`:

```javascript
// Ganti API_URL
const API_URL = 'https://zoom.zascript.com';

// Atau gunakan relative URL
const API_URL = window.location.origin;
```

## Update Backend untuk Menggunakan HTTPS URL

Update environment variable di `docker-compose.yml`:

```yaml
backend:
  environment:
    - LIVEKIT_URL=wss://zoom.zascript.com/rtc
```

## Testing

1. **Test HTTP redirect:**
   ```bash
   curl -I http://zoom.zascript.com
   # Harus redirect ke HTTPS
   ```

2. **Test HTTPS:**
   ```bash
   curl -I https://zoom.zascript.com
   # Harus return 200 OK
   ```

3. **Test WebSocket:**
   - Buka browser console
   - Cek apakah WebSocket connection berhasil

4. **Test dari browser:**
   - Buka https://zoom.zascript.com
   - Pastikan SSL certificate valid (gembok hijau)

## Troubleshooting

### SSL Certificate Gagal

```bash
# Check error log
sudo tail -f /var/log/nginx/zoom_error.log

# Test certbot manual
sudo certbot certonly --nginx -d zoom.zascript.com

# Check certificate
sudo certbot certificates
```

### WebSocket Tidak Connect

```bash
# Check nginx error log
sudo tail -f /var/log/nginx/zoom_error.log

# Test WebSocket connection
wscat -c wss://zoom.zascript.com/rtc
```

### 502 Bad Gateway

```bash
# Check apakah aplikasi berjalan
docker ps

# Check nginx upstream
sudo nginx -t

# Check backend/frontend logs
docker compose logs backend
docker compose logs frontend
```

### Port Already in Use

```bash
# Check port yang digunakan
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop service yang menggunakan port
sudo systemctl stop apache2  # Jika ada
```

## Maintenance

### Renew SSL Certificate

SSL certificate akan auto-renew, tapi bisa manual:

```bash
sudo certbot renew
sudo systemctl reload nginx
```

### Check SSL Expiry

```bash
sudo certbot certificates
```

### Update Nginx Configuration

```bash
# Edit config
sudo nano /etc/nginx/sites-available/zoom.zascript.com

# Test
sudo nginx -t

# Reload
sudo systemctl reload nginx
```

## Security Best Practices

1. ✅ SSL/TLS enabled
2. ✅ HTTP redirect ke HTTPS
3. ✅ Security headers configured
4. ✅ Firewall configured (jika perlu)
5. ✅ Regular SSL renewal

## Firewall Configuration (Opsional)

```bash
# Install UFW
sudo apt install ufw

# Allow HTTP, HTTPS, dan SSH
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

## Monitoring

```bash
# Check nginx status
sudo systemctl status nginx

# Check nginx logs
sudo tail -f /var/log/nginx/zoom_access.log
sudo tail -f /var/log/nginx/zoom_error.log

# Check SSL certificate status
sudo certbot certificates
```

