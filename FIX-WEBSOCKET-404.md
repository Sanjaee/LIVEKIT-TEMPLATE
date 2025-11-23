# 🔧 Fix WebSocket 404 Error

## ❌ Masalah

WebSocket connection gagal dengan error 404:
```
WebSocket connection to 'wss://zoom.zascript.com/rtc?access_token=...' failed
GET https://zoom.zascript.com/rtc/validate?access_token=... 404 (Not Found)
```

## 🔍 Penyebab

1. Nginx tidak bisa proxy `/rtc` ke LiveKit dengan benar
2. Rewrite rules mungkin tidak bekerja untuk WebSocket
3. LiveKit container mungkin tidak accessible

## ✅ Solusi yang Diterapkan

### 1. Update Nginx Config dengan Map Directive

**File: `nginx.conf` dan `nginx-http-only.conf`**

Ditambahkan map directive untuk WebSocket upgrade:
```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
```

### 2. Perbaikan Location /rtc

```nginx
location /rtc {
    # Strip /rtc prefix
    rewrite ^/rtc/?(.*)$ /$1 break;
    
    proxy_pass http://livekit_ws;
    proxy_http_version 1.1;
    
    # WebSocket headers
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    ...
}
```

## 📋 Langkah Deploy Fix

### 1. Update Nginx Config di VPS

```bash
# Copy nginx.conf yang sudah di-update
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com

# Test nginx config
sudo nginx -t

# Jika error, check syntax
# Pastikan map directive di bagian atas (sebelum server block)
```

### 2. Reload Nginx

```bash
sudo systemctl reload nginx
```

### 3. Verify LiveKit Container

```bash
# Check LiveKit container
docker compose ps livekit

# Check LiveKit logs
docker compose logs livekit

# Test LiveKit langsung
curl -I http://localhost:7880
```

### 4. Test WebSocket

```bash
# Test via Nginx
curl -I https://zoom.zascript.com/rtc

# Atau gunakan test script
chmod +x test-websocket.sh
./test-websocket.sh
```

## 🐛 Troubleshooting

### Nginx Config Error

**Error:** `nginx: [emerg] unknown "connection_upgrade" variable`

**Solusi:**
- Pastikan `map` directive ada di bagian atas file (sebelum server block)
- Test config: `sudo nginx -t`

### LiveKit Not Accessible

**Error:** `502 Bad Gateway` atau `Connection refused`

**Solusi:**
```bash
# Check LiveKit container
docker compose ps livekit

# Restart LiveKit
docker compose restart livekit

# Check logs
docker compose logs livekit
```

### WebSocket Still 404

**Check:**
1. Nginx error log: `sudo tail -f /var/log/nginx/zoom_error.log`
2. Nginx access log: `sudo tail -f /var/log/nginx/zoom_access.log`
3. LiveKit logs: `docker compose logs -f livekit`

**Test manual:**
```bash
# Test LiveKit langsung
curl -v http://localhost:7880

# Test via Nginx
curl -v http://localhost/rtc
```

## 🔍 Debugging Steps

### 1. Check Nginx Config

```bash
sudo nginx -t
sudo cat /etc/nginx/sites-available/zoom.zascript.com | grep -A 20 "location /rtc"
```

### 2. Check LiveKit

```bash
# Check container
docker compose ps

# Check port
netstat -tulpn | grep 7880

# Test connection
curl -I http://localhost:7880
```

### 3. Check Nginx Logs

```bash
# Error log
sudo tail -f /var/log/nginx/zoom_error.log

# Access log
sudo tail -f /var/log/nginx/zoom_access.log
```

### 4. Test WebSocket Manual

```bash
# Install wscat jika belum ada
npm install -g wscat

# Test WebSocket
wscat -c wss://zoom.zascript.com/rtc
```

## ✅ Verifikasi Setelah Fix

1. **Nginx config valid:**
   ```bash
   sudo nginx -t
   # Harus: syntax is ok
   ```

2. **LiveKit accessible:**
   ```bash
   curl -I http://localhost:7880
   # Harus: HTTP/1.1 200 OK atau 400 Bad Request (normal untuk root)
   ```

3. **Nginx proxy working:**
   ```bash
   curl -I https://zoom.zascript.com/rtc
   # Harus: HTTP/1.1 400 Bad Request (normal, karena butuh WebSocket upgrade)
   ```

4. **WebSocket connection:**
   - Buka browser console
   - Join room
   - Check Network tab → WS filter
   - Harus: `wss://zoom.zascript.com/rtc?access_token=...` dengan status 101 Switching Protocols

---

**Setelah fix, WebSocket harus berhasil connect!** 🎉

