# 📋 Instruksi Deploy Zoom Video Call ke VPS dengan SSL

## 🎯 Tujuan
Setup aplikasi Zoom Video Call di VPS `8.215.196.12` dengan domain `zoom.zascript.com` dan SSL certificate.

## 📦 File yang Dibutuhkan

1. `nginx.conf` - Konfigurasi Nginx
2. `setup-nginx.sh` - Script setup Nginx dan SSL
3. `update-frontend-domain.sh` - Script update domain di frontend
4. `deploy.sh` - Script deploy aplikasi
5. `docker-compose.yml` - Konfigurasi Docker (sudah diupdate)

## 🚀 Langkah-langkah Deploy

### Step 1: Setup DNS

Pastikan domain `zoom.zascript.com` sudah di-point ke IP VPS `8.215.196.12`:

**A Record:**
```
Type: A
Name: zoom
Value: 8.215.196.12
TTL: 3600
```

**Verifikasi DNS:**
```bash
ping zoom.zascript.com
# Harus return IP: 8.215.196.12
```

### Step 2: Upload File ke VPS

```bash
# Upload semua file ke VPS
scp nginx.conf setup-nginx.sh update-frontend-domain.sh deploy.sh docker-compose.yml user@8.215.196.12:/home/user/zoom/

# Atau clone dari git jika sudah di-push
```

### Step 3: SSH ke VPS

```bash
ssh user@8.215.196.12
cd /home/user/zoom
```

### Step 4: Setup Nginx dan SSL

```bash
# Berikan permission execute
chmod +x setup-nginx.sh

# Jalankan setup
./setup-nginx.sh
```

Script ini akan:
- ✅ Install Nginx
- ✅ Install Certbot
- ✅ Setup konfigurasi Nginx
- ✅ Request SSL certificate dari Let's Encrypt
- ✅ Setup auto-renewal SSL

**Catatan:** Pastikan domain sudah di-point sebelum menjalankan script!

### Step 5: Update Frontend Domain

```bash
# Update domain di frontend
chmod +x update-frontend-domain.sh
./update-frontend-domain.sh
```

### Step 6: Deploy Aplikasi

```bash
# Deploy aplikasi
chmod +x deploy.sh
./deploy.sh
```

Script ini akan:
- ✅ Update frontend domain
- ✅ Build Docker images
- ✅ Start semua containers
- ✅ Test services
- ✅ Reload Nginx

### Step 7: Verifikasi

1. **Test dari browser:**
   ```
   https://zoom.zascript.com
   ```
   - Harus muncul halaman join
   - SSL certificate harus valid (gembok hijau)

2. **Test API:**
   ```bash
   curl https://zoom.zascript.com/health
   # Harus return: OK
   ```

3. **Test WebSocket:**
   - Buka browser console
   - Join room
   - Cek apakah WebSocket connection berhasil

## 🔧 Konfigurasi Nginx

Nginx akan:
- ✅ Listen di port 80 (HTTP) - redirect ke HTTPS
- ✅ Listen di port 443 (HTTPS) - serve aplikasi
- ✅ Proxy `/api/*` ke backend (port 8080)
- ✅ Proxy `/rtc` ke LiveKit WebSocket (port 7880)
- ✅ Proxy `/` ke frontend (port 3000)

## 🔒 SSL Certificate

SSL certificate akan:
- ✅ Auto-renew setiap 90 hari
- ✅ Valid untuk domain `zoom.zascript.com`
- ✅ Menggunakan Let's Encrypt (gratis)

**Check SSL status:**
```bash
sudo certbot certificates
```

**Manual renew (jika perlu):**
```bash
sudo certbot renew
sudo systemctl reload nginx
```

## 📝 Update Manual Frontend Domain

Jika script tidak berjalan, update manual:

Edit `frontend/index.html`:
```javascript
// Ganti baris ini:
const API_URL = 'http://localhost:8080';

// Menjadi:
const API_URL = 'https://zoom.zascript.com';
```

Lalu rebuild frontend:
```bash
docker compose build frontend
docker compose up -d frontend
```

## 🐛 Troubleshooting

### SSL Certificate Gagal

**Error:** `Failed to obtain certificate`

**Solusi:**
1. Pastikan domain sudah di-point ke IP VPS
2. Pastikan port 80 tidak diblokir firewall
3. Check DNS propagation: `dig zoom.zascript.com`

```bash
# Test manual certbot
sudo certbot certonly --nginx -d zoom.zascript.com
```

### 502 Bad Gateway

**Error:** `502 Bad Gateway`

**Solusi:**
1. Check apakah containers berjalan:
   ```bash
   docker compose ps
   ```

2. Check logs:
   ```bash
   docker compose logs backend
   docker compose logs frontend
   ```

3. Check nginx error log:
   ```bash
   sudo tail -f /var/log/nginx/zoom_error.log
   ```

### WebSocket Tidak Connect

**Error:** WebSocket connection failed

**Solusi:**
1. Check nginx config untuk WebSocket:
   ```bash
   sudo nginx -t
   ```

2. Check LiveKit container:
   ```bash
   docker compose logs livekit
   ```

3. Test WebSocket manual:
   ```bash
   wscat -c wss://zoom.zascript.com/rtc
   ```

### Port Already in Use

**Error:** `Address already in use`

**Solusi:**
```bash
# Check port yang digunakan
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop service yang menggunakan port
sudo systemctl stop apache2  # Jika ada
```

## 🔄 Update Aplikasi

Setelah update code:

```bash
# Pull latest code
git pull

# Rebuild dan restart
docker compose down
docker compose build
docker compose up -d

# Reload nginx
sudo systemctl reload nginx
```

## 📊 Monitoring

### Check Service Status

```bash
# Docker containers
docker compose ps

# Nginx
sudo systemctl status nginx

# SSL certificate
sudo certbot certificates
```

### Check Logs

```bash
# Application logs
docker compose logs -f

# Nginx access log
sudo tail -f /var/log/nginx/zoom_access.log

# Nginx error log
sudo tail -f /var/log/nginx/zoom_error.log
```

## 🔐 Security Checklist

- ✅ SSL/TLS enabled
- ✅ HTTP redirect ke HTTPS
- ✅ Security headers configured
- ✅ Firewall configured (opsional)
- ✅ Regular SSL renewal
- ✅ Nginx updated

## 📞 Support

Jika ada masalah:
1. Check logs: `docker compose logs`
2. Check nginx logs: `sudo tail -f /var/log/nginx/zoom_error.log`
3. Test services: `curl https://zoom.zascript.com/health`

## ✅ Checklist Deploy

- [ ] DNS sudah di-point ke IP VPS
- [ ] Nginx dan SSL sudah di-setup
- [ ] Docker containers berjalan
- [ ] Frontend bisa diakses via HTTPS
- [ ] Backend API bisa diakses
- [ ] WebSocket LiveKit berfungsi
- [ ] SSL certificate valid
- [ ] Auto-renewal SSL aktif

---

**Selamat! Aplikasi sudah siap digunakan di https://zoom.zascript.com** 🎉

