# 🔧 Fix WebSocket URL Double Path Issue

## ❌ Masalah

WebSocket URL menjadi double path: `wss://zoom.zascript.com/rtc/rtc`

**Error:**
```
WebSocket connection to 'wss://zoom.zascript.com/rtc/rtc?access_token=...' failed
404 page not found
```

## 🔍 Penyebab

1. **Backend mengembalikan URL dengan `/rtc`**: `wss://zoom.zascript.com/rtc`
2. **LiveKit client SDK otomatis menambahkan `/rtc`** saat connect
3. **Hasilnya**: `wss://zoom.zascript.com/rtc/rtc` ❌

## ✅ Solusi

### 1. Backend - Hapus `/rtc` dari URL

**File: `backend/main.go`**
```go
// Sebelum
livekitURL = getEnv("LIVEKIT_URL", "wss://zoom.zascript.com/rtc")

// Sesudah
livekitURL = getEnv("LIVEKIT_URL", "wss://zoom.zascript.com")
```

**File: `docker-compose.yml`**
```yaml
# Sebelum
- LIVEKIT_URL=wss://zoom.zascript.com/rtc

# Sesudah
- LIVEKIT_URL=wss://zoom.zascript.com
```

### 2. Nginx - Strip `/rtc` path saat proxy

**File: `nginx.conf`**
```nginx
# Sebelum
location /rtc {
    proxy_pass http://livekit_ws;
    ...
}

# Sesudah
location ~ ^/rtc(/.*)?$ {
    proxy_pass http://livekit_ws$1;
    ...
}
```

Ini akan:
- Match `/rtc` atau `/rtc/...`
- Strip `/rtc` dan proxy sisa path ke LiveKit
- `/rtc` → proxy ke `/` (root LiveKit)
- `/rtc/validate` → proxy ke `/validate`

## 🔄 Alur Request Setelah Fix

1. **Frontend request**: `wss://zoom.zascript.com/rtc?access_token=...`
2. **Nginx receive**: `/rtc?access_token=...`
3. **Nginx strip `/rtc`**: Proxy ke `http://localhost:7880/?access_token=...`
4. **LiveKit receive**: Root path dengan query params ✅

## 📋 Langkah Deploy Fix

### 1. Update Backend

```bash
# Update docker-compose.yml
# LIVEKIT_URL=wss://zoom.zascript.com (tanpa /rtc)

# Rebuild backend
docker compose build backend
docker compose up -d backend
```

### 2. Update Nginx Config

```bash
# Copy nginx.conf yang sudah di-update
sudo cp nginx.conf /etc/nginx/sites-available/zoom.zascript.com

# Test nginx config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 3. Rebuild Frontend (jika perlu)

```bash
# Frontend tidak perlu diubah, karena menggunakan URL dari backend
# Tapi rebuild untuk memastikan
docker compose build frontend
docker compose up -d frontend
```

## 🧪 Testing

### 1. Check Backend URL

```bash
# Test API endpoint
curl https://zoom.zascript.com/api/token \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"roomName":"test","username":"test"}'

# Response harus:
# {
#   "token": "...",
#   "url": "wss://zoom.zascript.com"  // Tanpa /rtc
# }
```

### 2. Check WebSocket Connection

Buka browser console saat join room:
```javascript
// Network tab → WS filter
// Harus: wss://zoom.zascript.com/rtc?access_token=...
// BUKAN: wss://zoom.zascript.com/rtc/rtc?access_token=...
```

### 3. Check Nginx Logs

```bash
# Check access log
sudo tail -f /var/log/nginx/zoom_access.log

# Check error log
sudo tail -f /var/log/nginx/zoom_error.log
```

## ✅ Hasil Setelah Fix

- ✅ Backend mengembalikan: `wss://zoom.zascript.com` (tanpa `/rtc`)
- ✅ LiveKit client menambahkan: `/rtc` → `wss://zoom.zascript.com/rtc`
- ✅ Nginx strip `/rtc` dan proxy ke LiveKit root
- ✅ WebSocket connection berhasil ✅

## 🐛 Troubleshooting

### Masih error 404

**Check:**
1. Nginx config sudah di-reload?
2. Backend sudah di-restart?
3. LiveKit container running?

```bash
# Check containers
docker compose ps

# Check nginx
sudo systemctl status nginx
sudo nginx -t
```

### WebSocket masih double path

**Check:**
1. Backend URL di response API
2. Browser cache (clear cache)

```bash
# Check backend response
curl https://zoom.zascript.com/api/token -X POST -H "Content-Type: application/json" -d '{"roomName":"test","username":"test"}'
```

---

**Setelah fix, WebSocket connection harus berhasil!** 🎉

