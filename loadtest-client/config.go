package main

import (
    "encoding/json"
    "os"
)

type Config struct {
    Target      string `json:"target"`
    Protocol    string `json:"protocol"`
    Concurrency int    `json:"concurrency"`
    Duration    int    `json:"duration"`
}

func LoadConfig(path string) (*Config, error) {
    file, err := os.ReadFile(path)
    if err != nil {
        return nil, err
    }
    var cfg Config
    err = json.Unmarshal(file, &cfg)
    return &cfg, err
}
