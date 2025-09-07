#!/bin/bash
set -e

# Default values
PROTOCOL=${1:-rest}   # rest | grpc | ws
DURATION=${DURATION:-30s}
RATE=${RATE:-100}
EXTRA_ARGS=${@:2}

echo "🚀 Starting load test"
echo "   Protocol : $PROTOCOL"
echo "   Duration : $DURATION"
echo "   Rate     : $RATE/s"

# Run load test directly from host
cd "$(dirname "$0")/../load-test"

go run runner.go \
  --protocol="$PROTOCOL" \
  --duration="$DURATION" \
  --rate="$RATE" \
  $EXTRA_ARGS
