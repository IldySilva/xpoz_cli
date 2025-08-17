# Self-Hosting

You can run your own Xpoz tunnel server for complete control and privacy.

## Server Requirements

- Linux server with public IP
- Domain name (for SSL certificates)
- Docker (recommended) or Go runtime

## Docker Setup (Recommended)

```bash
# Clone the server repository
git clone https://github.com/your-username/xpoz-server
cd xpoz-server

# Configure environment
cp .env.example .env
# Edit .env with your domain and settings

# Start the server
docker-compose up -d
```

## Manual Setup

```bash
# Download server binary
wget https://github.com/your-username/xpoz-server/releases/latest/download/xpoz-server-linux-amd64

# Make executable
chmod +x xpoz-server-linux-amd64

# Run server
./xpoz-server-linux-amd64 --domain your-domain.com --port 443
```

## Client Configuration

Point your CLI to your server:

```bash
xpoz expose http 3000 --server wss://your-domain.com
```

Or set as default:

```bash
export XPOZ_SERVER=wss://your-domain.com
```