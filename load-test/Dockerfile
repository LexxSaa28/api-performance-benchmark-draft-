FROM debian:bullseye-slim

WORKDIR /app

# Install tools
RUN apt-get update && apt-get install -y \
    jq netcat curl bash ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download vegeta binary (linux amd64)
RUN curl -L https://github.com/tsenart/vegeta/releases/download/v12.11.1/vegeta-12.11.1-linux-amd64.tar.gz \
    -o /tmp/vegeta.tar.gz \
    && tar -xzf /tmp/vegeta.tar.gz -C /usr/local/bin \
    && rm /tmp/vegeta.tar.gz

CMD ["tail", "-f", "/dev/null"]
