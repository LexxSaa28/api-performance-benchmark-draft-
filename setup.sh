#!/bin/bash
# setup.sh - Complete setup script for the load testing framework

set -e

echo "🚀 Setting up Backend Load Testing Framework"
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is required but not installed"
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is required but not installed"
    exit 1
fi

# Check Go
if ! command -v go &> /dev/null; then
    print_error "Go is required but not installed"
    exit 1
fi

print_success "All prerequisites are installed"

# Create directory structure
print_status "Creating directory structure..."

mkdir -p backends/grpc-server/proto
mkdir -p backends/websocket-server
mkdir -p loadtest-client
mkdir -p monitoring/grafana/{dashboards,provisioning/dashboards,provisioning/datasources}
mkdir -p monitoring/graphite

print_success "Directory structure created"

# System optimization
print_status "Applying system optimizations..."

# Create system optimization script
cat << 'EOF' > loadtest-client/optimize_system.sh
#!/bin/bash

# System optimization script for high-performance load testing

echo "🔧 Optimizing system for high-performance load testing..."

# Increase file descriptor limits
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Increase process limits
echo "* soft nproc 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nproc 65536" | sudo tee -a /etc/security/limits.conf

# TCP optimization
sudo sysctl -w net.core.somaxconn=65536
sudo sysctl -w net.core.netdev_max_backlog=5000
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=65536
sudo sysctl -w net.ipv4.tcp_keepalive_time=600
sudo sysctl -w net.ipv4.tcp_keepalive_intvl=60
sudo sysctl -w net.ipv4.tcp_keepalive_probes=3

# Ephemeral port range
sudo sysctl -w net.ipv4.ip_local_port_range="1024 65535"

# Memory optimization
sudo sysctl -w vm.overcommit_memory=1

# Apply immediately
ulimit -n 65536
ulimit -u 65536

echo "✅ System optimization complete!"
echo "Note: Some changes require a reboot to take full effect."
EOF

chmod +x loadtest-client/optimize_system.sh

print_success "System optimization script created"

# Create Grafana datasource configuration
print_status "Creating Grafana configuration..."

cat << 'EOF' > monitoring/grafana/provisioning/datasources/graphite.yml
apiVersion: 1

datasources:
  - name: Graphite
    type: graphite
    access: proxy
    url: http://statsd:80
    basicAuth: false
    isDefault: true
    version: 1
    editable: true
    jsonData:
      graphiteVersion: "1.1"
      httpMethod: "GET"
EOF

cat << 'EOF' > monitoring/grafana/provisioning/dashboards/dashboard.yml
apiVersion: 1

providers:
  - name: 'Backend Performance'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

print_success "Grafana configuration created"

# Build and start services
print_status "Building and starting services..."

cd monitoring

# Start monitoring stack
docker-compose up -d

print_success "Monitoring stack started"

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 30

# Check service health
print_status "Checking service health..."

# Check Grafana
if curl -s http://localhost:3000/api/health > /dev/null; then
    print_success "Grafana is ready at http://localhost:3000 (admin/admin)"
else
    print_warning "Grafana might not be fully ready yet"
fi

# Check Graphite
if curl -s http://localhost:8081/render?target=carbon.agents.*.metricsReceived > /dev/null; then
    print_success "Graphite is ready at http://localhost:8081"
else
    print_warning "Graphite might not be fully ready yet"
fi

# Check StatsD
if nc -z localhost 8125; then
    print_success "StatsD is ready on port 8125"
else
    print_warning "StatsD might not be ready yet"
fi

cd ..

print_status "Building load test client..."
cd loadtest-client
go mod tidy
go build -o loadtest-client .
cd ..

print_success "Load test client built successfully"

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "📊 Services:"
echo "  - Grafana Dashboard: http://localhost:3000 (admin/admin)"
echo "  - Graphite Web UI:   http://localhost:8081"
echo "  - StatsD:           localhost:8125 (UDP)"
echo ""
echo "🚀 To start load testing:"
echo "  1. Start backend services:"
echo "     cd monitoring && docker-compose up -d"
echo ""
echo "  2. Run system optimization (recommended):"
echo "     cd loadtest-client && sudo ./optimize_system.sh"
echo ""
echo "  3. Run load tests:"
echo "     cd loadtest-client"
echo "     ./loadtest-client --list                    # List scenarios"
echo "     ./loadtest-client --target grpc             # Run gRPC tests"
echo "     ./loadtest-client --target websocket        # Run WebSocket tests"
echo "     ./loadtest-client --target both             # Run both"
echo ""
echo "📈 Monitor results in real-time at http://localhost:3000"
echo ""
