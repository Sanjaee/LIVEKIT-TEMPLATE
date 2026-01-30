package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"github.com/livekit/protocol/auth"
)

type JoinRequest struct {
	RoomName string `json:"roomName"`
	Username string `json:"username"`
}

type TokenResponse struct {
	Token string `json:"token"`
	URL   string `json:"url"`
}

var (
	livekitURL string
	apiKey     string
	apiSecret  string
)

func main() {
	livekitURL = getEnv("LIVEKIT_URL", "wss://zoom.zascript.com/rtc")
	apiKey = getEnv("LIVEKIT_API_KEY", "devkey")
	apiSecret = getEnv("LIVEKIT_API_SECRET", "6RfzN3B2Lqj8vzdP9XC4tFkp57YhUBsM")

	r := mux.NewRouter()

	// Enable CORS
	r.Use(corsMiddleware)

	r.HandleFunc("/api/token", getTokenHandler).Methods("POST", "OPTIONS")
	r.HandleFunc("/health", healthHandler).Methods("GET")

	log.Println("Backend server running on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}

func getTokenHandler(w http.ResponseWriter, r *http.Request) {
	// OPTIONS requests are handled by CORS middleware
	if r.Method == "OPTIONS" {
		return
	}

	var req JoinRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	if req.RoomName == "" || req.Username == "" {
		http.Error(w, "Room name and username required", http.StatusBadRequest)
		return
	}

	// Generate LiveKit token
	at := auth.NewAccessToken(apiKey, apiSecret)
	grant := &auth.VideoGrant{
		RoomJoin: true,
		Room:     req.RoomName,
	}
	at.AddGrant(grant).
		SetIdentity(req.Username).
		SetValidFor(time.Hour * 24)

	token, err := at.ToJWT()
	if err != nil {
		log.Printf("Error generating token: %v", err)
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	response := TokenResponse{
		Token: token,
		URL:   livekitURL,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")

		// Allowed origins
		allowedOrigins := []string{
			"https://zoom.zascript.com",
			"https://zoom.zacloth.com",
			"http://localhost:3000",
			"http://localhost:8080",
		}

		// Check if origin is allowed
		allowed := false
		for _, allowedOrigin := range allowedOrigins {
			if origin == allowedOrigin {
				allowed = true
				break
			}
		}

		// Set CORS headers
		if allowed && origin != "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Access-Control-Allow-Credentials", "true")
		} else {
			// Fallback to wildcard if no origin or not in allowed list
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, Accept")
		w.Header().Set("Access-Control-Max-Age", "3600")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
