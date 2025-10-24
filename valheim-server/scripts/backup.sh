#!/bin/bash

BACKUP_DIR="/home/valheim/backups"
WORLD_DIR="/home/valheim/.config/unity3d/IronGate/Valheim/worlds"
BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}
BACKUP_RETENTION=${BACKUP_RETENTION:-7}

echo "Backup service started (interval: ${BACKUP_INTERVAL}s, retention: ${BACKUP_RETENTION} days)"

while true; do
    sleep ${BACKUP_INTERVAL}
    
    if [ -d "${WORLD_DIR}" ]; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="${BACKUP_DIR}/valheim_backup_${TIMESTAMP}.tar.gz"
        
        echo "Creating backup: ${BACKUP_FILE}"
        tar -czf "${BACKUP_FILE}" -C "${WORLD_DIR}" . 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Backup created successfully"
            
            # Clean up old backups
            find "${BACKUP_DIR}" -name "valheim_backup_*.tar.gz" -mtime +${BACKUP_RETENTION} -delete
            echo "Old backups cleaned (retention: ${BACKUP_RETENTION} days)"
        else
            echo "Backup failed"
        fi
    else
        echo "World directory not found yet, skipping backup"
    fi
done
