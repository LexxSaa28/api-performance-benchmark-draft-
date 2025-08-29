cat << 'EOF' > README.md
# 🚀 Backend Performance Load Testing Framework

High-performance load testing framework for gRPC and WebSocket backend services with real-time monitoring and visualization.

## ✨ Features

- **🔌 Multi-Protocol Support**: gRPC and WebSocket load testing
- **📊 Real-time Monitoring**: StatsD + Graphite + Grafana integration
- **🎯 Scenario-Based Testing**: JSON configuration with multiple test scenarios
- **⚡ High Performance**: Optimized for high concurrency and throughput
- **🔧 System Optimization**: Automated system tuning for maximum performance
- **📈 Rich Visualizations**: Comprehensive Grafana dashboards

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Test     │───▶│  gRPC Server    │───▶│     StatsD      │
│    Client       │    │  (Port 50051)   │    │  (Port 8125)    │
│                 │    └─────────────────┘    └─────────────────┘
│                 │                                     │
│                 │    ┌─────────────────┐              ▼
│                 │───▶│ WebSocket Server│    ┌─────────────────┐
└─────────────────┘    │  (Port 8080)    │───▶│    Graphite     │
                       └─────────────────┘    │  (Port 8081)    │
                                              └─────────────────┘
                                                        │
                                                        ▼
                                              ┌─────────────────┐
                                              │    Grafana      │
                                              │  (Port 3000)    │
                                              └─────────────────┘
```

## 🚀 Quick Start

### 1. Setup (One-time)

```bash
# Clone repository
git clone <repository-url>
cd api-performance-backend-test

# Run setup script
chmod +x setup.sh
./setup.sh
```

### 2. Start Services

```bash
# Start monitoring and backend services
cd monitoring
docker-compose up -d

# Verify services are running
docker-compose ps
```

### 3. Run Load Tests

```bash
cd loadtest-client

# System optimization (recommended)
sudo ./optimize_system.sh

# List available scenarios
./loadtest-client --list

# Run specific tests
./loadtest-client --target grpc --scenario hello_high
./loadtest-client --target websocket --scenario echo_stress
./loadtest-client --target both
```

### 4. Monitor Results

- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Real-time Metrics**: Auto-refreshing every 5 seconds
- **Historical Data**: 7 days retention with aggregation

## 📊 Test Scenarios

### gRPC Test Types

| Type | Description | Metrics |
|------|-------------|---------|
| `hello` | Simple greeting service | Latency, throughput, success rate |
| `compute` | CPU-intensive computation | Processing time, resource usage |
| `echo` | Message echo with size variation | Message size impact, latency |
| `stream` | Server-side streaming | Stream performance, message rates |

### WebSocket Test Types

| Type | Description | Metrics |
|------|-------------|---------|
| `echo` | Bidirectional message echo | Message latency, throughput |
| `compute` | CPU tasks over WebSocket | Computation time, connection efficiency |
| `stream` | Streaming message sequences | Stream performance, connection stability |
| `ping` | Latency measurement | Round-trip time, connection health |

## 🎯 Load Scenarios

### Light Load
- gRPC: 100-1000 requests, 10-50 concurrent
- WebSocket: 10-100 connections, 10-20 messages/conn

### Medium Load  
- gRPC: 1000-5000 requests, 50-100 concurrent
- WebSocket: 100-500 connections, 20-50 messages/conn

### High Load
- gRPC: 5000+ requests, 100+ concurrent  
- WebSocket: 500-1000 connections, 50+ messages/conn

## 📈 Monitoring & Metrics

### Key Metrics Collected

#### gRPC Metrics
- Request latency (mean, P90, P95, P99)
- Throughput (requests/second)
- Success/error rates by method
- Connection pool utilization

#### WebSocket Metrics
- Connection establishment time
- Message latency and throughput
- Concurrent connection count
- Connection drop rates

### Grafana Dashboards

1. **Overview Dashboard**: System-wide performance summary
2. **gRPC Performance**: Detailed gRPC service metrics
3. **WebSocket Analytics**: WebSocket connection and message analysis
4. **Error Analysis**: Error rates and types
5. **Resource Utilization**: System resource usage

## 🔧 Configuration

### Test Configuration (test-config.json)

```json
{
  "grpc_scenarios": [
    {
      "name": "hello_high",
      "total_requests": 5000,
      "concurrency": 100,
      "test_type": "hello"
    }
  ],
  "websocket_scenarios": [
    {
      "name": "echo_stress", 
      "total_connections": 500,
      "messages_per_conn": 50,
      "test_type": "echo"
    }
  ]
}
```

### Environment Variables

```bash
# StatsD Configuration
STATSD_HOST=localhost
STATSD_PORT=8125

# Service Endpoints
GRPC_HOST=localhost
GRPC_PORT=50051
WEBSOCKET_HOST=localhost  
WEBSOCKET_PORT=8080
```

## 🛠️ Development

### Project Structure

```
├── backends/
│   ├── grpc-server/           # gRPC backend service
│   └── websocket-server/      # WebSocket backend service  
├── loadtest-client/           # Load testing client
├── monitoring/                # Docker compose + configs
│   ├── grafana/              # Grafana dashboards
│   └── graphite/             # Graphite configurations
└── setup.sh                  # Automated setup script
```

### Building Services

```bash
# Build all services
docker-compose -f monitoring/docker-compose.yml build

# Build individual service
docker build -t grpc-backend backends/grpc-server
docker build -t websocket-backend backends/websocket-server

# Build load test client
cd loadtest-client
go build -o loadtest-client .
```

### Adding New Test Scenarios

1. **Edit Configuration**: Add new scenario to `test-config.json`
2. **Implement Logic**: Add test logic in client code if needed
3. **Update Metrics**: Define new metric names in StatsD integration
4. **Dashboard Updates**: Add panels for new metrics in Grafana

### Custom Metrics

```go
// Send custom metrics from your test
metricsClient.Incr("custom.metric.name", []string{"tag:value"}, 1)
metricsClient.Timing("custom.latency", duration, nil, 1)
metricsClient.Gauge("custom.gauge", value, nil, 1)
```

## 🎛️ Advanced Usage

### Custom Load Patterns

```bash
# Run specific scenario with custom parameters
./loadtest-client --target grpc --scenario custom \
  --requests 10000 \
  --concurrency 200 \
  --duration 300s
```

### Stress Testing

```bash
# Maximum load testing
sudo ./optimize_system.sh
./loadtest-client --target both --scenario stress_all
```

### Long-running Tests

```bash
# Extended stability testing
./loadtest-client --target websocket \
  --scenario connection_endurance \
  --duration 1h
```

## 📊 Performance Benchmarks

### Expected Performance (Optimized System)

#### gRPC Performance
- **Hello Service**: 10,000+ RPS, <5ms P95 latency
- **Compute Service**: 1,000+ RPS (depends on computation)
- **Echo Service**: 8,000+ RPS with 1KB messages
- **Stream Service**: 500+ concurrent streams

#### WebSocket Performance  
- **Concurrent Connections**: 5,000+ stable connections
- **Message Throughput**: 50,000+ messages/second
- **Connection Time**: <10ms establishment
- **Message Latency**: <2ms round-trip

## 🐛 Troubleshooting

### Common Issues

#### 1. Connection Refused Errors
```bash
# Check if services are running
docker-compose ps

# Check service logs
docker-compose logs grpc-backend
docker-compose logs websocket-backend
```

#### 2. High Latency/Low Throughput
```bash
# Apply system optimization
sudo ./optimize_system.sh

# Check system limits
ulimit -n
cat /proc/sys/fs/file-max
```

#### 3. StatsD Connection Issues
```bash
# Test StatsD connectivity
echo "test.metric:1|c" | nc -u localhost 8125

# Check StatsD logs
docker-compose logs statsd-graphite
```

#### 4. Grafana Dashboard Issues
```bash
# Reset Grafana data
docker-compose down -v
docker-compose up -d

# Check datasource connection in Grafana UI
```

### Performance Tuning

#### System Level
```bash
# Increase file descriptors
echo 'fs.file-max = 1048576' >> /etc/sysctl.conf

# TCP tuning
echo 'net.core.rmem_max = 134217728' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 134217728' >> /etc/sysctl.conf

# Apply changes
sysctl -p
```

#### Application Level
- Adjust connection pool sizes in client code
- Tune garbage collection settings: `GOGC=100`
- Use connection reuse for gRPC clients
- Implement proper backpressure for WebSocket

### Debugging

#### Enable Debug Logging
```bash
export DEBUG=1
export GRPC_VERBOSITY=debug
export GRPC_TRACE=all
```

#### Monitor Resource Usage
```bash
# CPU and memory usage
top -p $(pgrep -f "grpc-backend|websocket-backend|loadtest-client")

# Network connections
ss -tuln | grep -E "8080|50051|8125"

# File descriptors
lsof -p $(pgrep loadtest-client) | wc -l
```

## 🔒 Security Considerations

### Network Security
- Services exposed only on localhost by default
- No authentication in test environment
- Use proper TLS in production

### Resource Limits
- Container resource limits configured
- System limits applied via optimization script
- Rate limiting available in test scenarios

## 🚀 Production Deployment

### Docker Compose Production
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  grpc-backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '1'
          memory: 512M
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-backend
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: grpc-backend
        image: grpc-backend:latest
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

## 📚 References

- [gRPC Performance Best Practices](https://grpc.io/docs/guides/performance/)
- [WebSocket Performance Tuning](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [StatsD Protocol](https://github.com/statsd/statsd/blob/master/docs/metric_types.md)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-test-type`
3. Add tests and documentation
4. Submit pull request

## 📄 License

MIT License - see LICENSE file for details.

---

**🎯 Ready to load test your backend services?**

Run `./setup.sh` and start monitoring your performance in real-time!
EOF

print_success "Documentation created"

print_status "Creating quick start script..."

cat << 'EOF' > quick-start.sh
#!/bin/bash

# Quick start script for immediate load testing

echo "⚡ Quick Start - Backend Load Testing"
echo "===================================="

# Check if setup was run
if [ ! -f "loadtest-client/loadtest-client" ]; then
    echo "❌ Setup not completed. Please run ./setup.sh first"
    exit 1
fi

# Start services if not running
echo "🚀 Starting services..."
cd monitoring
if ! docker-compose ps | grep -q "Up"; then
    docker-compose up -d
    echo "⏳ Waiting for services to start..."
    sleep 30
fi
cd ..

# Quick smoke test
echo "🔥 Running quick smoke tests..."

cd loadtest-client

echo "📡 Testing gRPC Hello service..."
./loadtest-client --target grpc --scenario hello_light

echo "🔌 Testing WebSocket Echo service..."
./loadtest-client --target websocket --scenario echo_light

echo ""
echo "✅ Quick tests completed!"
echo ""
echo "📊 View results at:"
echo "   Grafana: http://localhost:3000 (admin/admin)"
echo "   Graphite: http://localhost:8081"
echo ""
echo "🚀 Run more tests:"
echo "   ./loadtest-client --list"
echo "   ./loadtest-client --target both"
echo ""
EOF

chmod +x quick-start.sh

print_success "Quick start script created"

echo ""
echo "🎉 Framework setup completed successfully!"
echo ""
echo "📁 Files created:"
echo "  ├── setup.sh (main setup script)"
echo "  ├── quick-start.sh (immediate testing)"
echo "  ├── README.md (comprehensive documentation)"
echo "  ├── backends/"
echo "  │   ├── grpc-server/ (Dockerfile, configs)"
echo "  │   └── websocket-server/ (Dockerfile, configs)"
echo "  ├── loadtest-client/"
echo "  │   └── optimize_system.sh (performance tuning)"
echo "  └── monitoring/"
echo "      ├── docker-compose.yml"
echo "      ├── grafana/ (provisioning, dashboards)"
echo "      └── graphite/ (storage configs)"
echo ""
echo "🚀 Next steps:"
echo "  1. Run: ./setup.sh"
echo "  2. Test: ./quick-start.sh"
echo "  3. Monitor: http://localhost:3000"
echo ""