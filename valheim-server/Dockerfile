FROM cm2network/steamcmd:root

# Install dependencies
RUN apt-get update && apt-get install -y \
    libsdl2-2.0-0 \
    libpulse0 \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create Valheim user and directories
RUN useradd -m -u 1000 valheim && \
    mkdir -p /home/valheim/valheim-server /home/valheim/.config/unity3d/IronGate/Valheim /home/valheim/backups && \
    chown -R valheim:valheim /home/valheim

# Switch to valheim user
USER valheim
WORKDIR /home/valheim

# Install Valheim Dedicated Server
RUN /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/valheim/valheim-server \
    +login anonymous \
    +app_update 896660 validate \
    +quit

# Copy scripts
COPY --chown=valheim:valheim scripts/start-server.sh /home/valheim/start-server.sh
COPY --chown=valheim:valheim scripts/backup.sh /home/valheim/backup.sh
RUN chmod +x /home/valheim/start-server.sh /home/valheim/backup.sh

# Expose ports
# 2456-2457: Game ports (UDP)
# 2458: Query port (UDP)
EXPOSE 2456-2458/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep -f "valheim_server.x86_64" || exit 1

# Volume for world data and backups
VOLUME ["/home/valheim/.config/unity3d/IronGate/Valheim", "/home/valheim/backups"]

CMD ["/home/valheim/start-server.sh"]
