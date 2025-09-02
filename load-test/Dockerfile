FROM golang:1.24.6 AS builder

# Install vegeta (tool untuk load test REST/HTTP)
RUN go install github.com/tsenart/vegeta@latest

# Stage final
FROM debian:bullseye-slim
WORKDIR /app

COPY --from=builder /go/bin/vegeta /usr/local/bin/vegeta

CMD ["tail", "-f", "/dev/null"]