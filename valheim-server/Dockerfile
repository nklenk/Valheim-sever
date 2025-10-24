FROM cm2network/steamcmd:root

# Install dependencies
RUN apt-get update && apt-get install -y \
    libsdl2-2.0-0 \
    libpulse0 \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# The base image already has a 'steam' user with UID 1000
# We'll use that user and set up the directories
USER steam
WORKDIR /home/steam

# Create necessary directories
RUN mkdir -p /home/steam/valheim-server \
             /home/steam/.config/unity3d/IronGate/Valheim \
             /home/steam/backups

# Install Valheim Dedicated Server
RUN /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/valheim-server \
    +login anonymous \
    +app_update 896660 validate \
    +quit

# Copy scripts
COPY --chown=steam:steam scripts/start-server.sh /home/steam/start-server.sh
COPY --chown=steam:steam scripts/backup.sh /home/steam/backup.sh
RUN chmod +x /home/steam/start-server.sh /home/steam/backup.sh

# Expose ports
# 2456-2457: Game ports (UDP)
# 2458: Query port (UDP)
EXPOSE 2456-2458/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep -f "valheim_server.x86_64" || exit 1

# Volume for world data and backups
VOLUME ["/home/steam/.config/unity3d/IronGate/Valheim", "/home/steam/backups"]

CMD ["/home/steam/start-server.sh"]
