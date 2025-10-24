#!/bin/bash
set -e

echo "Starting Valheim Dedicated Server..."
echo "Server Name: ${SERVER_NAME}"
echo "World Name: ${WORLD_NAME}"
echo "Server Port: ${SERVER_PORT}"
echo "Public Server: ${SERVER_PUBLIC}"

# Validate password
if [ -z "${SERVER_PASSWORD}" ] || [ ${#SERVER_PASSWORD} -lt 5 ]; then
    echo "ERROR: SERVER_PASSWORD must be at least 5 characters long"
    exit 1
fi

# Start backup service in background if enabled
if [ "${BACKUP_ENABLED}" = "true" ]; then
    echo "Backup service enabled (interval: ${BACKUP_INTERVAL}s, retention: ${BACKUP_RETENTION} days)"
    /home/valheim/backup.sh &
fi

# Update server to latest version
echo "Checking for server updates..."
/home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/valheim/valheim-server \
    +login anonymous \
    +app_update 896660 validate \
    +quit

echo "Starting Valheim server..."
cd /home/valheim/valheim-server

# Start the server
exec ./valheim_server.x86_64 \
    -name "${SERVER_NAME}" \
    -port ${SERVER_PORT} \
    -world "${WORLD_NAME}" \
    -password "${SERVER_PASSWORD}" \
    -public ${SERVER_PUBLIC} \
    -savedir "/home/valheim/.config/unity3d/IronGate/Valheim" \
    -logFile /dev/stdout
