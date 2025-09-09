module github.com/IrzhaAdji28/api-performance-benchmark-draft-/load-test

go 1.24.6

require (
	github.com/IrzhaAdji28/api-performance-benchmark-draft-/grpc-server v0.0.0-00010101000000-000000000000
	github.com/gorilla/websocket v1.5.3
	github.com/spf13/cobra v1.10.1
	google.golang.org/grpc v1.75.0
)

require (
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/spf13/pflag v1.0.9 // indirect
	golang.org/x/net v0.41.0 // indirect
	golang.org/x/sys v0.33.0 // indirect
	golang.org/x/text v0.26.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20250707201910-8d1bb00bc6a7 // indirect
	google.golang.org/protobuf v1.36.8 // indirect
)

replace github.com/IrzhaAdji28/api-performance-benchmark-draft-/grpc-server => ../grpc-server

replace github.com/IrzhaAdji28/api-performance-benchmark-draft-/stats => ../stats
