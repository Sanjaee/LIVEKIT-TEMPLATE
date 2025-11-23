# 📝 Perubahan untuk Production (HTTPS)

## ✅ Perubahan yang Sudah Dilakukan

### 1. Frontend (`frontend/index.html`)

**Sebelum:**
```javascript
const API_URL = 'http://8.215.196.12:8080';
```

**Sesudah:**
```javascript
const API_URL = window.location.origin; // Otomatis menggunakan domain saat ini
```

**Keuntungan:**
- ✅ Otomatis menggunakan HTTPS jika diakses via HTTPS
- ✅ Bekerja di development (localhost) dan production (zoom.zascript.com)
- ✅ Tidak perlu hardcode domain

### 2. Backend (`backend/main.go`)

**Sebelum:**
```go
livekitURL = getEnv("LIVEKIT_URL", "ws://8.215.196.12:7880")
```

**Sesudah:**
```go
livekitURL = getEnv("LIVEKIT_URL", "wss://zoom.zascript.com/rtc")
```

**Keuntungan:**
- ✅ Fallback menggunakan HTTPS (WSS)
- ✅ Menggunakan path `/rtc` yang sudah di-configure di Nginx
- ✅ Environment variable di `docker-compose.yml` sudah benar

### 3. Docker Compose (`docker-compose.yml`)

**Sudah benar:**
```yaml
backend:
  environment:
    - LIVEKIT_URL=wss://zoom.zascript.com/rtc
```

## 🔄 Alur Request

### Development (Local)
```
Frontend (localhost:3000) 
  → API_URL = "http://localhost:3000"
  → Backend (localhost:8080)
  → LiveKit (ws://localhost:7880)
```

### Production (HTTPS)
```
Frontend (https://zoom.zascript.com)
  → API_URL = "https://zoom.zascript.com" (otomatis)
  → Backend (https://zoom.zascript.com/api/*)
  → LiveKit (wss://zoom.zascript.com/rtc)
```

## 📋 Checklist Deploy

- [x] Frontend API_URL menggunakan `window.location.origin`
- [x] Backend LIVEKIT_URL fallback menggunakan WSS
- [x] Docker Compose environment variable sudah benar
- [x] Nginx configuration sudah setup
- [x] SSL certificate sudah di-setup

## 🧪 Testing

### Test Frontend
```bash
# Buka browser
https://zoom.zascript.com

# Check console
# API_URL harus: "https://zoom.zascript.com"
```

### Test Backend
```bash
curl https://zoom.zascript.com/health
# Harus return: OK
```

### Test LiveKit
```bash
# Check di browser console saat join room
# WebSocket URL harus: wss://zoom.zascript.com/rtc
```

## 🔍 Verifikasi

### 1. Check Frontend API URL
Buka browser console di `https://zoom.zascript.com`:
```javascript
console.log(API_URL);
// Harus output: "https://zoom.zascript.com"
```

### 2. Check Backend LiveKit URL
Check di backend logs:
```bash
docker compose logs backend | grep LIVEKIT_URL
# Harus output: wss://zoom.zascript.com/rtc
```

### 3. Check WebSocket Connection
Buka browser console saat join room:
```javascript
// Check WebSocket URL di Network tab
// Harus: wss://zoom.zascript.com/rtc?access_token=...
```

## 🐛 Troubleshooting

### Frontend masih menggunakan HTTP

**Masalah:** API_URL masih `http://`

**Solusi:**
1. Pastikan mengakses via HTTPS: `https://zoom.zascript.com`
2. Clear browser cache
3. Hard refresh: `Ctrl+Shift+R` (Windows) atau `Cmd+Shift+R` (Mac)

### WebSocket connection failed

**Masalah:** WebSocket tidak connect

**Solusi:**
1. Check Nginx config untuk `/rtc` path
2. Check LiveKit container running:
   ```bash
   docker compose ps livekit
   ```
3. Check Nginx logs:
   ```bash
   sudo tail -f /var/log/nginx/zoom_error.log
   ```

### Backend tidak bisa connect ke LiveKit

**Masalah:** Backend error saat generate token

**Solusi:**
1. Check environment variable:
   ```bash
   docker compose exec backend env | grep LIVEKIT_URL
   ```
2. Check LiveKit container:
   ```bash
   docker compose logs livekit
   ```

## 📝 Catatan Penting

1. **Frontend menggunakan relative URL** - Ini lebih fleksibel dan bekerja di development dan production
2. **Backend menggunakan environment variable** - Bisa di-override via docker-compose.yml
3. **Semua menggunakan HTTPS/WSS** - Untuk security dan browser compatibility

## ✅ Semua Sudah Siap!

Semua perubahan sudah dilakukan. Aplikasi siap untuk production dengan HTTPS! 🎉

