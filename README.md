# Xpoz CLI — Secure and Instant Local Tunneling

Expose your local apps to the internet securely with a single command.

------------------------------------------------------------

Install:
  ```bash curl -fsSL https://cli.xpoz.xyz/install.sh | bash```

Expose a local app:
  xpoz expose http 3000

That’s it. You’ll get a public URL that forwards to http://localhost:3000.

------------------------------------------------------------

## Features

- ⚡ One‑line install & one‑line expose
- 🔒 End‑to‑end via secure WebSocket (wss)
- 🎯 Stable subdomains (server‑assigned)
- 📡 Full HTTP proxy support (headers, body, binary)
- 🔁 Auto reconnect with backoff + heartbeat

Planned:
- 🧪 Preview URLs from branches/PRs (Git‑first)
- 🛡️ Auth tokens & ACLs
- 📈 Dashboard and metrics
- 🔌 VS Code / JetBrains integrations
- 🚦 Concurrency limit to protect your machine
- 🧩 Config file & flags (server, token, limits)
- 🧰 Cross‑platform (macOS / Linux)

------------------------------------------------------------

## Quick Start

Expose a local HTTP server on port 3000:
```bash
  xpoz  http 3000
 ```

Use a custom server (self‑hosted):
```bash
  xpoz  http 3000 --server wss://ws.xpoz.xyz
 ```

```bash
  xpoz  http 3000 --max-connections 50
  ```

------------------------------------------------------------

## How It Works (High Level)

1) CLI establishes a secure WebSocket (wss) to the Xpoz server.
2) Server assigns a public URL (subdomain).
3) Incoming HTTP requests at the public URL are sent to the CLI over WS.
4) The CLI forwards them to your local app (localhost:<port>) and streams the response back.

Notes:
- Binary bodies are base64‑encoded over the tunnel.
- Headers like Host/Connection/Transfer‑Encoding are sanitized to prevent conflicts.
- Heartbeat + backoff keep the tunnel alive and reconnect if needed.

------------------------------------------------------------

## Roadmap

- Auth tokens + per‑tunnel ACLs
- Branch/PR preview URLs (Git‑first)
- Dashboard (stats, logs, stop/start)
- TCP and WebSocket native modes
- Plugins/IDE integrations

------------------------------------------------------------

## License

MIT (or your preferred license). See LICENSE.

------------------------------------------------------------

## Credits

Built with ❤️ . Feedback and PRs welcome!
