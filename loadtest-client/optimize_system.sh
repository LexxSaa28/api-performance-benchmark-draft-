#!/bin/bash
echo "🚀 Optimizing system for load testing..."
ulimit -n 100000
sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.core.somaxconn=65535
sysctl -w net.core.netdev_max_backlog=65535
echo "✅ Done!"
