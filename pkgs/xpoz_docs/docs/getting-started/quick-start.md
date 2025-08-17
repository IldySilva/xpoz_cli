# Quick Start

Get your first tunnel running in under 60 seconds.

## 1. Start Your Local App

First, make sure you have a local application running. For example:

```bash
# Simple HTTP server on port 3000
python -m http.server 3000
```

## 2. Expose It

In another terminal, expose your local app:

```bash
xpoz expose http 3000
```

You'll see output like:

```
✓ Connected to tunnel server
✓ Tunnel established
→ Local:  http://localhost:3000
→ Public: https://abc123.xpoz.xyz

Press Ctrl+C to stop the tunnel
```

## 3. Test It

Open the public URL in your browser or test with curl:

```bash
curl https://abc123.xpoz.xyz
```

That's it! Your local app is now accessible from anywhere on the internet.

## Common Use Cases

### Web Development

```bash
# Expose your dev server
xpoz expose http 3000
```

### API Testing

```bash
# Share your API with teammates
xpoz expose http 8080
```

### Webhook Testing

```bash
# Receive webhooks locally
xpoz expose http 4000
```

## Next Steps

- Learn about [configuration options](../usage/configuration.md)
- Explore [all available commands](../usage/commands.md)

