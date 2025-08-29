package main

import (
    "log"
    "sync"
    "time"

    "github.com/gorilla/websocket"
)

func RunWebSocketTest(target string, concurrency, duration int) {
    var wg sync.WaitGroup
    end := time.Now().Add(time.Duration(duration) * time.Second)

    for i := 0; i < concurrency; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            c, _, err := websocket.DefaultDialer.Dial("ws://"+target+"/ws", nil)
            if err != nil {
                log.Printf("Dial error: %v", err)
                return
            }
            defer c.Close()

            for time.Now().Before(end) {
                start := time.Now()
                if err := c.WriteMessage(websocket.TextMessage, []byte("Hello")); err != nil {
                    log.Printf("Write error: %v", err)
                    break
                }
                _, _, err := c.ReadMessage()
                latency := time.Since(start)
                if err != nil {
                    log.Printf("Read error: %v", err)
                    break
                }
                ReportMetric("ws.success", 1)
                ReportLatency("ws.latency", latency)
            }
        }(i)
    }
    wg.Wait()
}
