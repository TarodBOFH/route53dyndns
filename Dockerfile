FROM python:3.12-alpine

# OCI Image Labels
LABEL org.opencontainers.image.title="Route53 DDNS Updater" \
      org.opencontainers.image.description="Updates AWS Route53 record from EdgeRouter WAN IP" \
      org.opencontainers.image.version="1.1.0" \
      org.opencontainers.image.authors="cbr600f"

WORKDIR /app

# Default Environment Variables (overridable via container environment)
ENV WAN_IF="pppoe1" \
    GW_USER="root" \
    GW_IP="192.168.1.1"

# Install openssh-client and python dependencies in a single cached layer
COPY requirements.txt .
RUN apk add --no-cache openssh-client && \
    pip install --no-cache-dir -r requirements.txt && \
    rm requirements.txt && \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    echo "0.0.0.0" > /var/lastip

# Copy executable scripts
COPY change_ip.sh route53.py entrypoint.sh ./
RUN chmod +x change_ip.sh entrypoint.sh


ENTRYPOINT ["/app/entrypoint.sh"]

# Build and tag
# docker build -t route53-updater:v1.1.0 -t route53-updater:latest .
