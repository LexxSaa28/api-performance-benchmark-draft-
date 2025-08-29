package main

import (
    "fmt"
    "log"
)

func main() {
    cfg, err := LoadConfig("test-config.json")
    if err != nil {
        log.Fatalf("Config error: %v", err)
    }
    InitMetrics()

    fmt.Printf("Starting load test: %s (%s)\n", cfg.Target, cfg.Protocol)

    switch cfg.Protocol {
    case "grpc":
        RunGRPCTest(cfg.Target, cfg.Concurrency, cfg.Duration)
    case "websocket":
        RunWebSocketTest(cfg.Target, cfg.Concurrency, cfg.Duration)
    default:
        log.Fatalf("Unknown protocol: %s", cfg.Protocol)
    }

    fmt.Println("Load test finished!")
}
