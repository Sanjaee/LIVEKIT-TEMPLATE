# 🔧 Quick Fix untuk Nginx SSL Error

## ❌ Error yang Terjadi

```
nginx: [emerg] cannot load certificate "/etc/letsencrypt/live/zoom.zascript.com/fullchain.pem": 
BIO_new_file() failed (SSL: error:80000002:system library::No such file or directory)
```

## 🔍 Penyebab

Nginx mencoba load SSL certificate yang belum ada. Certificate akan dibuat oleh certbot, jadi kita perlu setup nginx tanpa SSL dulu.

## ✅ Solusi Cepat

### Opsi 1: Gunakan Script Fix (Recommended)

```bash
# Upload file fix-nginx-ssl.sh dan nginx-http-only.conf ke VPS
scp fix-nginx-ssl.sh nginx-http-only.conf user@8.215.196.12:/home/user/zoom/

# SSH ke VPS
ssh user@8.215.196.12
cd /home/user/zoom

# Jalankan fix script
chmod +x fix-nginx-ssl.sh
./fix-nginx-ssl.sh
```

### Opsi 2: Manual Fix

```bash
# 1. Copy HTTP-only config
sudo cp nginx-http-only.conf /etc/nginx/sites-available/zoom.zascript.com

# 2. Test nginx
sudo nginx -t

# 3. Restart nginx
sudo systemctl restart nginx

# 4. Request SSL certificate
sudo certbot --nginx -d zoom.zascript.com --non-interactive --agree-tos --email admin@zascript.com --redirect

# 5. Update dengan full HTTPS config
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com

# 6. Test nginx
sudo nginx -t

# 7. Reload nginx
sudo systemctl reload nginx
```

## 📋 Langkah-langkah Detail

### Step 1: Copy HTTP-Only Config

```bash
sudo cp nginx-http-only.conf /etc/nginx/sites-available/zoom.zascript.com
```

File ini tidak memerlukan SSL certificate, jadi nginx bisa start.

### Step 2: Test dan Restart Nginx

```bash
sudo nginx -t
sudo systemctl restart nginx
```

### Step 3: Request SSL Certificate

```bash
sudo certbot --nginx -d zoom.zascript.com --non-interactive --agree-tos --email admin@zascript.com --redirect
```

Certbot akan:
- ✅ Request certificate dari Let's Encrypt
- ✅ Otomatis update nginx config dengan SSL

### Step 4: Update dengan Full HTTPS Config

```bash
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com
```

File ini memiliki konfigurasi lengkap untuk HTTPS.

### Step 5: Test dan Reload

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 🧪 Verifikasi

```bash
# Check nginx status
sudo systemctl status nginx

# Check SSL certificate
sudo certbot certificates

# Test HTTP redirect
curl -I http://zoom.zascript.com
# Harus redirect ke HTTPS

# Test HTTPS
curl -I https://zoom.zascript.com
# Harus return 200 OK
```

## 🐛 Troubleshooting

### Certbot Error: Domain tidak resolve

**Solusi:**
```bash
# Check DNS
dig zoom.zascript.com
# Harus return IP: 8.215.196.12

# Wait untuk DNS propagation (bisa sampai 24 jam)
```

### Certbot Error: Port 80 diblokir

**Solusi:**
```bash
# Check firewall
sudo ufw status

# Allow port 80
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Nginx masih error setelah certbot

**Solusi:**
```bash
# Check nginx config yang di-update certbot
sudo cat /etc/nginx/sites-available/zoom.zascript.com

# Jika perlu, copy manual nginx.conf
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com
sudo nginx -t
sudo systemctl reload nginx
```

## ✅ Setelah Fix

Setelah fix berhasil:
- ✅ Nginx berjalan tanpa error
- ✅ SSL certificate terpasang
- ✅ HTTP redirect ke HTTPS
- ✅ Aplikasi accessible via https://zoom.zascript.com

## 📝 Catatan

1. **nginx-http-only.conf** - Untuk setup awal (tanpa SSL)
2. **nginx.conf** - Untuk production (dengan SSL)
3. Certbot akan otomatis update config, tapi kita copy nginx.conf untuk memastikan konfigurasi lengkap

---

**Jalankan fix script atau ikuti langkah manual di atas!** 🚀

