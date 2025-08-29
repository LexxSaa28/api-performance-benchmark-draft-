package main

import (
    "log"
    "time"

    statsd "github.com/cactus/go-statsd-client/statsd"
)

var client statsd.Statter

func InitMetrics() {
    var err error
    client, err = statsd.NewClient("localhost:8125", "loadtest")
    if err != nil {
        log.Fatalf("StatsD error: %v", err)
    }
}

func ReportMetric(name string, value int64) {
    if client != nil {
        client.Inc(name, value, 1.0)
    }
}

func ReportLatency(name string, duration time.Duration) {
    if client != nil {
        client.TimingDuration(name, duration, 1.0)
    }
}
