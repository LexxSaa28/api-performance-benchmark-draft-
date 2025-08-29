#!/bin/bash

# Quick start script for immediate load testing
# This script provides a fast way to get started with backend performance testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${PURPLE}"
    echo "⚡ ============================================== ⚡"
    echo "    BACKEND PERFORMANCE LOAD TESTING"
    echo "       Quick Start - Ready in 60 seconds!"
    echo "⚡ ============================================== ⚡"
    echo -e "${NC}"
}

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

print_banner

# Check if setup was completed
if [ ! -d "loadtest-client" ]; then
    print_error "Load test client directory not found!"
    echo "Please run setup first:"
    echo "  1. Run: ./setup.sh"
    echo "  2. Then: ./quick-start.sh"
    exit 1
fi

if [ ! -f "loadtest-client/loadtest-client" ] && [ ! -f "loadtest-client/main.go" ]; then
    print_error "Load test client not built!"
    echo "Building client now..."
    cd loadtest-client
    if [ -f "go.mod" ]; then
        go build -o loadtest-client .
        cd ..
    else
        print_error "Go files not found. Please run ./setup.sh first"
        exit 1
    fi
fi

# Start monitoring and backend services
print_status "🚀 Starting monitoring and backend services..."

if [ ! -d "monitoring" ]; then
    print_error "Monitoring directory not found! Please run ./setup.sh first"
    exit 1
fi

cd monitoring

# Check if services are already running
RUNNING_SERVICES=$(docker-compose ps --services --filter "status=running" 2>/dev/null | wc -l)

if [ "$RUNNING_SERVICES" -lt 3 ]; then
    print_status "Starting Docker services..."
    docker-compose up -d
    
    print_status "⏳ Waiting for services to initialize (30 seconds)..."
    
    # Show progress bar
    for i in {1..30}; do
        printf "\r${BLUE}[INFO]${NC} Initializing services... [$i/30] "
        printf "█%.0s" $(seq 1 $((i*2)))
        printf "░%.0s" $(seq 1 $((60-i*2)))
        printf " %d%%" $((i*100/30))
        sleep 1
    done
    echo ""
else
    print_success "Services already running!"
fi

cd ..

# Verify services are healthy
print_status "🔍 Checking service health..."

check_service() {
    local service=$1
    local port=$2
    local name=$3
    
    if curl -s "http://localhost:$port" >/dev/null 2>&1 || nc -z localhost "$port" 2>/dev/null; then
        print_success "$name is ready on port $port"
        return 0
    else
        print_warning "$name might not be ready yet on port $port"
        return 1
    fi
}

# Check each service
GRAFANA_OK=0
GRAPHITE_OK=0
STATSD_OK=0
GRPC_OK=0
WEBSOCKET_OK=0

if check_service "health" "3000" "Grafana"; then GRAFANA_OK=1; fi
if check_service "render" "8081" "Graphite"; then GRAPHITE_OK=1; fi
if nc -z localhost 8125 2>/dev/null; then 
    print_success "StatsD is ready on port 8125"
    STATSD_OK=1
else
    print_warning "StatsD might not be ready yet on port 8125"
fi

# Check if backend services are running in containers
if docker ps | grep -q "grpc-backend"; then
    print_success "gRPC backend is running"
    GRPC_OK=1
else
    print_warning "gRPC backend container not found"
fi

if docker ps | grep -q "websocket-backend"; then
    print_success "WebSocket backend is running"  
    WEBSOCKET_OK=1
else
    print_warning "WebSocket backend container not found"
fi

# Run quick smoke tests
print_status "🔥 Running quick performance tests..."
echo ""

cd loadtest-client

# Ensure binary exists
if [ ! -f "loadtest-client" ]; then
    print_status "Building load test client..."
    go build -o loadtest-client .
fi

echo -e "${CYAN}📡 Testing gRPC Hello Service (Light Load)${NC}"
echo "================================================"
if [ "$GRPC_OK" -eq 1 ]; then
    timeout 30 ./loadtest-client --target grpc --scenario hello_light 2>/dev/null || {
        print_warning "gRPC test timed out or failed - this is normal if backend is still starting"
    }
else
    print_warning "Skipping gRPC test - backend not ready"
fi

echo ""
echo -e "${CYAN}🔌 Testing WebSocket Echo Service (Light Load)${NC}"  
echo "=================================================="
if [ "$WEBSOCKET_OK" -eq 1 ]; then
    timeout 30 ./loadtest-client --target websocket --scenario echo_light 2>/dev/null || {
        print_warning "WebSocket test timed out or failed - this is normal if backend is still starting"
    }
else
    print_warning "Skipping WebSocket test - backend not ready"
fi

cd ..

echo ""
echo -e "${GREEN}✅ Quick Start Completed!${NC}"
echo "=========================="
echo ""
echo -e "${PURPLE}📊 ACCESS YOUR DASHBOARDS:${NC}"
echo "  🎯 Grafana Dashboard: ${CYAN}http://localhost:3000${NC} (admin/admin)"
echo "  📈 Graphite Metrics:  ${CYAN}http://localhost:8081${NC}"
echo "  🔧 Backend Services:"
echo "     - gRPC Server:     ${CYAN}localhost:50051${NC}"
echo "     - WebSocket:       ${CYAN}localhost:8080/ws${NC}"
echo ""
echo -e "${PURPLE}🚀 RUN MORE TESTS:${NC}"
echo "  📋 List scenarios:     ${YELLOW}cd loadtest-client && ./loadtest-client --list${NC}"
echo "  🎯 gRPC tests:         ${YELLOW}./loadtest-client --target grpc${NC}"
echo "  🔌 WebSocket tests:    ${YELLOW}./loadtest-client --target websocket${NC}"
echo "  ⚡ Combined tests:     ${YELLOW}./loadtest-client --target both${NC}"
echo "  🔧 System optimize:    ${YELLOW}sudo ./optimize_system.sh${NC}"
echo ""
echo -e "${PURPLE}📊 MONITORING TIPS:${NC}"
echo "  • Grafana auto-refreshes every 5 seconds"
echo "  • Check 'Backend Performance' dashboard"
echo "  • Metrics appear in real-time during tests"
echo "  • Use time range: 'Last 15 minutes' for active testing"
echo ""

# Show service status summary
echo -e "${PURPLE}🔍 SERVICE STATUS SUMMARY:${NC}"
echo "  Grafana:     $([ $GRAFANA_OK -eq 1 ] && echo -e "${GREEN}✅ Ready${NC}" || echo -e "${YELLOW}⚠️  Starting${NC}")"
echo "  Graphite:    $([ $GRAPHITE_OK -eq 1 ] && echo -e "${GREEN}✅ Ready${NC}" || echo -e "${YELLOW}⚠️  Starting${NC}")"  
echo "  StatsD:      $([ $STATSD_OK -eq 1 ] && echo -e "${GREEN}✅ Ready${NC}" || echo -e "${YELLOW}⚠️  Starting${NC}")"
echo "  gRPC:        $([ $GRPC_OK -eq 1 ] && echo -e "${GREEN}✅ Ready${NC}" || echo -e "${YELLOW}⚠️  Starting${NC}")"
echo "  WebSocket:   $([ $WEBSOCKET_OK -eq 1 ] && echo -e "${GREEN}✅ Ready${NC}" || echo -e "${YELLOW}⚠️  Starting${NC}")"
echo ""

if [ $((GRAFANA_OK + GRAPHITE_OK + STATSD_OK)) -lt 3 ]; then
    print_warning "Some monitoring services are still starting up"
    echo "💡 Wait 1-2 minutes and try accessing Grafana again"
    echo "💡 Or check service logs: cd monitoring && docker-compose logs"
fi

echo -e "${PURPLE}🎉 Happy Load Testing! 🎉${NC}"
echo ""