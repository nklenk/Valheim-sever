# Valheim Dedicated Server

A Dockerized Valheim dedicated server with automated deployment and backups for VPS hosting.

## 🎮 Features

- **Dockerized**: Isolated, reproducible server environment
- **Auto-updates**: Server automatically updates on restart
- **Automated Backups**: Configurable backup intervals and retention
- **Resource Limited**: Configured for 2 CPU cores and 4-6GB RAM
- **CI/CD Deployment**: GitHub Actions workflow for automated deployment
- **Central Timezone**: Configured for America/Chicago timezone

## 📋 Requirements

- VPS with Docker and Docker Compose installed
- 2+ CPU cores
- 4-6GB RAM available
- Ports 2456-2458 open (UDP)

## 🚀 Initial VPS Setup

### 1. Install Docker (if not already installed)

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 2. Clone Repository on VPS

```bash
sudo mkdir -p /opt/valheim-server
sudo chown $USER:$USER /opt/valheim-server
cd /opt/valheim-server
git clone <your-repo-url> .
```

### 3. Configure Environment

```bash
cp .env.example .env
nano .env
```

**Important**: Set at least these values:
- `SERVER_NAME` - Your server name
- `WORLD_NAME` - Your world name
- `SERVER_PASSWORD` - Strong password (min 5 characters)

### 4. Configure Firewall

```bash
# UFW example
sudo ufw allow 2456:2458/udp
sudo ufw allow 2456/tcp

# Or firewalld
sudo firewall-cmd --permanent --add-port=2456-2458/udp
sudo firewall-cmd --permanent --add-port=2456/tcp
sudo firewall-cmd --reload
```

### 5. Start Server

```bash
docker-compose up -d
```

### 6. Monitor Logs

```bash
docker-compose logs -f
```

## 🔄 GitHub Actions Deployment

### Setup Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

| Secret | Description | Example |
|--------|-------------|---------|
| `VPS_HOST` | VPS IP address or hostname | `123.45.67.89` |
| `VPS_USERNAME` | SSH username | `root` or `ubuntu` |
| `VPS_SSH_KEY` | Private SSH key for authentication | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `VPS_PORT` | SSH port (optional, defaults to 22) | `22` |

### Generate SSH Key for GitHub Actions

On your VPS:

```bash
# Generate deployment key
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github-deploy

# Add public key to authorized_keys
cat ~/.ssh/github-deploy.pub >> ~/.ssh/authorized_keys

# Display private key (copy this to GitHub Secrets)
cat ~/.ssh/github-deploy
```

### Deployment Trigger

The workflow automatically deploys when:
- You push to the `main` branch
- You manually trigger it from GitHub Actions tab

## 🗂️ Backup System

Backups are automatically created based on your configuration:

- **Location**: `/home/valheim/backups` (inside container)
- **Access backups**: `docker-compose exec valheim-server ls -lh /home/valheim/backups`
- **Extract backup**: 
  ```bash
  docker cp valheim-server:/home/valheim/backups/<backup-file>.tar.gz .
  ```

### Restore from Backup

```bash
# Stop server
docker-compose down

# Extract backup to world directory
docker run --rm -v valheim-data:/data -v $(pwd):/backup \
  busybox tar -xzf /backup/<backup-file>.tar.gz -C /data/worlds/

# Start server
docker-compose up -d
```

## 🔧 Configuration Options

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | My Valheim Server | Server display name |
| `WORLD_NAME` | Dedicated | World/save name |
| `SERVER_PASSWORD` | - | Server password (required, min 5 chars) |
| `SERVER_PUBLIC` | 0 | Public visibility (0=private, 1=public) |
| `SERVER_PORT` | 2456 | Server port |
| `BACKUP_ENABLED` | true | Enable automatic backups |
| `BACKUP_INTERVAL` | 3600 | Backup interval in seconds (1 hour) |
| `BACKUP_RETENTION` | 7 | Days to keep backups |

## 📊 Resource Usage

Configured limits:
- **CPU**: 2 cores (limit), 1 core (reservation)
- **RAM**: 6GB (limit), 4GB (reservation)

Monitor usage:
```bash
docker stats valheim-server
```

## 🛠️ Management Commands

### View Logs
```bash
docker-compose logs -f
```

### Restart Server
```bash
docker-compose restart
```

### Update Server
```bash
docker-compose pull
docker-compose up -d
```

### Stop Server
```bash
docker-compose down
```

### Rebuild from Scratch
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 🐛 Troubleshooting

### Server won't start
1. Check logs: `docker-compose logs`
2. Verify password is set and ≥5 characters
3. Ensure ports aren't in use: `netstat -tulpn | grep 245`

### Can't connect to server
1. Verify firewall rules: `sudo ufw status` or `sudo firewall-cmd --list-all`
2. Check server is running: `docker-compose ps`
3. Verify ports are exposed: `docker port valheim-server`

### Out of memory
1. Check usage: `docker stats`
2. Increase memory limit in `docker-compose.yml`
3. Consider reducing other services on VPS

## 📁 Directory Structure

```
valheim-server/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions deployment
├── scripts/
│   ├── start-server.sh         # Server startup script
│   └── backup.sh               # Backup automation script
├── docker-compose.yml          # Docker Compose configuration
├── Dockerfile                  # Docker image definition
├── .env.example               # Environment template
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## 🔒 Security Notes

- Never commit `.env` file to Git (it's in `.gitignore`)
- Use strong passwords (consider password manager)
- Keep SSH keys secure
- Regularly update the server: `docker-compose pull`
- Consider using a non-standard SSH port on your VPS
- Keep your VPS system updated: `sudo apt update && sudo apt upgrade`

## 📝 License

This setup is provided as-is for personal use.

Valheim is © Iron Gate AB. Visit [valheim.com](https://www.valheim.com/) for more information.
