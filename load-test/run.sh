#!/bin/sh

DURATION=30s
RATE=50
TARGETS=targets.txt

echo "🚀 Starting Vegeta load test"
echo "   Duration : $DURATION"
echo "   Rate     : $RATE/s"
echo "   Targets  : $TARGETS"

# Jalankan vegeta attack
vegeta attack -duration=$DURATION -rate=$RATE -targets=$TARGETS > results.bin

# Generate report
echo "📊 Generating reports..."
vegeta report results.bin > report.txt
vegeta plot results.bin > report.html

echo "✅ Reports saved: report.txt (text)"