# Quick Setup Guide

## Step 1: VPS Preparation

SSH into your VPS:
```bash
ssh your-user@your-vps-ip
```

Create the deployment directory:
```bash
sudo mkdir -p /opt/valheim-server
sudo chown $USER:$USER /opt/valheim-server
cd /opt/valheim-server
```

## Step 2: Clone Repository

```bash
git clone https://github.com/YOUR-USERNAME/valheim-server.git .
```

## Step 3: Configure Environment

```bash
cp .env.example .env
nano .env
```

**Required settings:**
```env
SERVER_NAME=YourServerName
WORLD_NAME=YourWorldName
SERVER_PASSWORD=YourStrongPassword123
```

## Step 4: Open Firewall Ports

### Using UFW (Ubuntu/Debian):
```bash
sudo ufw allow 2456:2458/udp
sudo ufw allow 2456/tcp
sudo ufw reload
```

### Using firewalld (CentOS/RHEL):
```bash
sudo firewall-cmd --permanent --add-port=2456-2458/udp
sudo firewall-cmd --permanent --add-port=2456/tcp
sudo firewall-cmd --reload
```

### Check if ports are open:
```bash
sudo netstat -tulpn | grep 245
```

## Step 5: Start Server

```bash
docker-compose up -d
```

## Step 6: Verify Everything Works

Check server status:
```bash
docker-compose ps
```

View logs:
```bash
docker-compose logs -f
```

Look for: `Game server connected`

## Step 7: Setup GitHub Actions (Optional)

### Generate SSH key on VPS:
```bash
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github-deploy
cat ~/.ssh/github-deploy.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Copy private key:
```bash
cat ~/.ssh/github-deploy
```

### Add GitHub Secrets:
Go to: `GitHub Repo → Settings → Secrets and variables → Actions`

Add these secrets:
- **VPS_HOST**: Your VPS IP address
- **VPS_USERNAME**: Your SSH username
- **VPS_SSH_KEY**: The private key content from above
- **VPS_PORT**: `22` (or your custom SSH port)

### Test deployment:
Push to main branch or manually trigger workflow from GitHub Actions tab.

## Step 8: Connect from Game

1. Open Valheim
2. Select "Start Game"
3. Choose "Join Game"
4. Select "Community" tab
5. Search for your server name
6. Or use "Add server" with your VPS IP:2456

## Troubleshooting

### Server not appearing in list?
- Set `SERVER_PUBLIC=1` in `.env`
- Restart: `docker-compose restart`

### Can't connect?
```bash
# Check if ports are listening
sudo netstat -tulpn | grep 2456

# Check firewall
sudo ufw status
# or
sudo firewall-cmd --list-all
```

### Server keeps restarting?
```bash
# Check logs for errors
docker-compose logs --tail=100

# Common issue: password too short
# Make sure SERVER_PASSWORD is at least 5 characters
```

## Useful Commands

```bash
# View logs
make logs

# Check status
make status

# Restart server
make restart

# Create backup
make backup

# List backups
make list-backups
```

## Getting Help

Check the full [README.md](README.md) for detailed documentation.

## Notes

- First startup takes 5-10 minutes (downloading Valheim server)
- World data persists in Docker volumes
- Backups run every hour by default
- Server auto-updates on restart
