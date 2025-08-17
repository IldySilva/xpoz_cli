# Troubleshooting

Common issues and solutions.

## Connection Issues

### "Failed to connect to tunnel server"

**Causes:**
- Network connectivity issues
- Firewall blocking WebSocket connections
- Server is down

**Solutions:**
```bash
# Test connectivity
curl -I https://api.xpoz.xyz

# Try alternative server
xpoz  http 3000 --server wss://backup.xpoz.xyz

# Check firewall settings
```

### "Tunnel disconnected"

**Causes:**
- Network interruption
- Server restart
- Idle timeout

**Solutions:**
- The CLI automatically reconnects with backoff
- Check your internet connection
- Ensure your local app is still running

## Performance Issues

### "Slow response times"

**Solutions:**
```bash
# Reduce max connections
xpoz  http 3000 --max-connections 10

# Use a server closer to your location
xpoz  http 3000 --server wss://eu.xpoz.xyz
```

## Getting Help

If you're still having issues:

1. Check the [GitHub Issues](https://github.com/your-username/xpoz/issues)
2. Enable debug logging: `XPOZ_DEBUG=1 xpoz  http 3000`
3. Create a new issue with your debug output
```

### docs/about/roadmap.md
```markdown