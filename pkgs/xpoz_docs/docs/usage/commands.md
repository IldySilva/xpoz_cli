# Commands Reference

## http

Expose a local HTTP server to the internet.

```bash
xpoz  http <port> [options]
```

### Examples

```bash
# Basic usage
xpoz  http 3000


# Custom server
xpoz  http 3000 --server wss://ws.xpoz.xyz

# Limit connections
xpoz  http 3000 --max-connections 50
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--server` | Custom tunnel server URL | `wss://api.xpoz.xyz` |
| `--max-connections` | Maximum concurrent connections | `100` |

## Global Options

| Option | Description |
|--------|-------------|
| `--help`, `-h` | Show help |
| `--version`, `-v` | Show version |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Connection failed |
| 3 | Invalid arguments |
```

### docs/usage/configuration.md
```markdown
# Configuration

Xpoz CLI can be configured through command-line flags or environment variables.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `XPOZ_SERVER` | Default tunnel server | `wss://api.xpoz.xyz` |
| `XPOZ_MAX_CONNECTIONS` | Default max connections | `100` |

## Examples

```bash
# Set default server
export XPOZ_SERVER=wss://my-server.com
xpoz expose http 3000

# Set max connections
export XPOZ_MAX_CONNECTIONS=25
xpoz  http 3000
```

## Configuration File (Planned)

Future versions will support a config file at `~/.xpoz/config.yml`:

```yaml
server: wss://my-server.com
max_connections: 50
auth_token: your-token-here
```
