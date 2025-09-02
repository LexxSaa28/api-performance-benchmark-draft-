# Stage 1: Build
FROM golang:1.24.6 AS builder

WORKDIR /app

# Copy go mod dan sum
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build binary untuk WebSocket server
RUN go build -o ws-server main.go

# Stage 2: Runtime
FROM debian:bullseye-slim

WORKDIR /app
COPY --from=builder /app/ws-server .

EXPOSE 7000

CMD ["./ws-server"]