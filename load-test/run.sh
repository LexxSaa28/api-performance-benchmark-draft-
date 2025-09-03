#!/bin/sh


DURATION=${DURATION:-30s}
RATE=${RATE:-50}
TARGETS=${TARGETS:-targets-rest.txt}
NAME=${NAME:-rest}  # rest | grpc | ws

echo "🚀 Starting Vegeta load test"
echo "   Protocol : $NAME"
echo "   Duration : $DURATION"
echo "   Rate     : $RATE/s"
echo "   Targets  : $TARGETS"

# Jalankan vegeta attack
vegeta attack -duration=$DURATION -rate=$RATE -targets=$TARGETS | tee results-$NAME.bin | vegeta report > report-$NAME.txt

# Generate HTML plot
vegeta plot results-$NAME.bin > report-$NAME.html

# Generate histogram
vegeta report -type="hist[0,100ms,200ms,500ms,1s,2s]" results-$NAME.bin > histogram-$NAME.txt

echo "✅ Reports saved:"
echo "   - report-$NAME.txt (summary)"
echo "   - report-$NAME.html (chart)"
echo "   - histogram-$NAME.txt (latency distribution)"

# Kirim ke StatsD
if command -v vegeta >/dev/null 2>&1; then
  echo "📡 Sending metrics to StatsD..."
  cat results-$NAME.bin | vegeta report -type=json | jq -c '.latencies' | nc -u -w1 statsd 8125
fi
