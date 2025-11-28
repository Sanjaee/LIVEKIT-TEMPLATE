# 🔧 Fix API Key Mismatch Error

## ❌ Masalah

Error 401 Unauthorized:
```
Error joining room: us: could not establish signal connection: invalid API key: LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99
```

## 🔍 Penyebab

API key di `docker-compose.yml` tidak match dengan yang ada di `livekit.yaml`:
- **livekit.yaml**: key = `devkey`, secret = `LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99`
- **docker-compose.yml**: API_KEY = `LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99` ❌

## ✅ Solusi

### 1. Update docker-compose.yml

**Sebelum:**
```yaml
environment:
  - LIVEKIT_API_KEY=LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99
  - LIVEKIT_API_SECRET=LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99
```

**Sesudah:**
```yaml
environment:
  - LIVEKIT_API_KEY=devkey
  - LIVEKIT_API_SECRET=LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99
```

### 2. Update backend/main.go

**Sebelum:**
```go
apiKey = getEnv("LIVEKIT_API_KEY", "LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99")
```

**Sesudah:**
```go
apiKey = getEnv("LIVEKIT_API_KEY", "devkey")
```

## 📋 Langkah Deploy

### 1. Rebuild dan Restart Backend

```bash
# Rebuild backend dengan environment variable baru
docker compose build backend

# Restart backend
docker compose restart backend

# Atau restart semua
docker compose down
docker compose up -d
```

### 2. Verify Configuration

```bash
# Check environment variable di backend container
docker compose exec backend env | grep LIVEKIT

# Harus output:
# LIVEKIT_URL=wss://zoom.zacloth.com
# LIVEKIT_API_KEY=devkey
# LIVEKIT_API_SECRET=LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99
```

### 3. Test API

```bash
# Test token generation
curl -X POST https://zoom.zacloth.com/api/token \
  -H "Content-Type: application/json" \
  -d '{"roomName":"test","username":"test"}'

# Harus return token dan URL
```

## 🔍 Verifikasi

### Check livekit.yaml
```yaml
keys:
  devkey: LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99
```
- Key: `devkey` ✅
- Secret: `LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99` ✅

### Check docker-compose.yml
```yaml
environment:
  - LIVEKIT_API_KEY=6RfzN3B2Lqj8vzdP9XC4tFkp57YhUBsM  ✅
  - LIVEKIT_API_SECRET=LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99  ✅
```

### Check backend/main.go
```go
apiKey = getEnv("LIVEKIT_API_KEY", "6RfzN3B2Lqj8vzdP9XC4tFkp57YhUBsM")  ✅
apiSecret = getEnv("LIVEKIT_API_SECRET", "LK09asd9A99asd0ASD09asd09as0d9ASD09asd0ASD09asdASD99")  ✅
```

## 🐛 Troubleshooting

### Masih Error 401

**Check:**
1. Backend sudah di-restart?
2. Environment variable sudah benar?
3. LiveKit container sudah di-restart?

```bash
# Restart semua
docker compose restart

# Check logs
docker compose logs backend
docker compose logs livekit
```

### Secret Too Short Warning

Jika masih ada warning tentang secret terlalu pendek, generate secret baru:

```bash
# Generate random secret (32+ characters)
openssl rand -base64 32
```

Lalu update:
- `livekit.yaml`: `devkey: <new-secret>`
- `docker-compose.yml`: `LIVEKIT_API_SECRET=<new-secret>`
- `backend/main.go`: fallback secret

---

**Setelah fix, API key harus match dan WebSocket connection berhasil!** 🎉

