package main

import (
    "context"
    "log"
    "sync"
    "time"

    pb "grpc-server"

    "google.golang.org/grpc"
)

func RunGRPCTest(target string, concurrency, duration int) {
    var wg sync.WaitGroup
    ctx, cancel := context.WithTimeout(context.Background(), time.Duration(duration)*time.Second)
    defer cancel()

    for i := 0; i < concurrency; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            conn, err := grpc.Dial(target, grpc.WithInsecure())
            if err != nil {
                log.Printf("Dial error: %v", err)
                return
            }
            defer conn.Close()

            client := pb.NewTestServiceClient(conn)

            for {
                select {
                case <-ctx.Done():
                    return
                default:
                    start := time.Now()
                    _, err := client.Ping(context.Background(), &pb.PingRequest{Message: "Hello"})
                    latency := time.Since(start)
                    if err != nil {
                        log.Printf("Error: %v", err)
                    } else {
                        ReportMetric("grpc.success", 1)
                        ReportLatency("grpc.latency", latency)
                    }
                }
            }
        }(i)
    }
    wg.Wait()
}
