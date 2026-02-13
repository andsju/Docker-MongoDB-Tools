FROM mongo:7.0

# Install additional tools if needed (mongo image already contains mongodump)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data
