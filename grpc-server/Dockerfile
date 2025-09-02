# Stage 1: Build
FROM golang:1.24.6 AS builder

WORKDIR /app

# Copy go mod dan sum
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build binary untuk gRPC server
RUN go build -o grpc-server main.go

# Stage 2: Runtime
FROM debian:bullseye-slim

WORKDIR /app
COPY --from=builder /app/grpc-server .

EXPOSE 9000

CMD ["./grpc-server"]