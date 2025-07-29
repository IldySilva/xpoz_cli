# Xpoz CLI — Secure and Instant Local Tunneling

Expose your local apps to the internet securely with a single command.

------------------------------------------------------------
BADGES (optional):
[Build Status] [Latest Release] [License] [Downloads]
------------------------------------------------------------

## TL;DR

Install:
  curl -fsSL https://get.xpoz.xyz/install.sh | bash

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
- 🚦 Concurrency limit to protect your machine
- 🧩 Config file & flags (server, token, limits)
- 🧰 Cross‑platform (macOS / Linux)

Planned:
- 🧪 Preview URLs from branches/PRs (Git‑first)
- 🛡️ Auth tokens & ACLs
- 📈 Dashboard and metrics
- 🔌 VS Code / JetBrains integrations

------------------------------------------------------------

## Installation

Recommended (auto‑detects OS/arch, installs to /usr/local/bin or ~/.xpoz/bin):

  curl -fsSL https://cli.xpoz.xyz/install.sh | bash

Install a specific version (e.g., v1.0.0):

  curl -fsSL https://cli.xpoz.xyz/install.sh | bash -s v1.0.0

Check:
  which xpoz
  xpoz --version

If your shell can’t find it, add this to your shell rc:
  export PATH="$HOME/.xpoz/bin:$PATH"

------------------------------------------------------------

## Quick Start

Expose a local HTTP server on port 3000:
  xpoz  http 3000

Use a custom server (self‑hosted):
  xpoz  http 3000 --server wss://ws.xpoz.xyz

  xpoz  http 3000 --max-connections 50

------------------------------------------------------------

## Usage

General:
  xpoz <command> [options] -- [args]

Commands:
  expose http <port>      Expose a local HTTP service
  --version               Show CLI version
  --help                  Show help

Common Options:
  -s, --server <url>          Tunnel server (default: wss://ws.xpoz.xyz)
      --json-logs             Emit JSON logs
      --no-color              Disable colored output

Examples:
  xpoz expose http 8080
  xpoz expose http 3000 --server wss://ws.xpoz.xyz --max-connections 100
  xpoz expose http 5173 --token $(cat ~/.xpoz/token)

------------------------------------------------------------

## Configuration

File:
  ~/.xpoz/config.yaml

Example:
  server: wss://ws.xpoz.xyz


Environment (optional overrides):
  XPOZ_SERVER, 

Precedence:
  CLI flag > ENV var > config file > default

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

## Troubleshooting

Nothing appears after install:
  which xpoz
  If empty, export PATH="$HOME/.xpoz/bin:$PATH" and restart shell.

Install script errors on macOS (cut/jq):
  Ensure the installer uses sed/jq‑free parsing or installs jq: brew install jq

Public URL returns 404:
  Ensure your local app is actually running on the given port.
  Check server logs and CLI output for “http_request” activity.

Binary assets not found:
  Make sure releases contain the files named:
  xpoz-linux-amd64, xpoz-linux-arm64, xpoz-darwin-arm64, (optionally xpoz-darwin-amd64)

Rate limiting:
  Increase --max-connections cautiously; your local app may still be the bottleneck.

------------------------------------------------------------

## Development

Prereqs:
  Dart SDK (stable)

Run (dev):
  dart run bin/xpoz.dart --help
  dart run bin/xpoz.dart expose http 3000

Compile native (current OS/arch):
  dart compile exe bin/xpoz.dart -o dist/xpoz-<os>-<arch>

Script:
  bash scripts/build_all.sh

Tests:
  dart test

------------------------------------------------------------

## Release Workflow (GitHub Releases)

1) Tag:
  git tag v1.0.0 && git push origin v1.0.0

2) Build binaries (via CI matrix or local per OS):
  dist/xpoz-linux-amd64
  dist/xpoz-linux-arm64
  dist/xpoz-darwin-arm64
  (optional) dist/xpoz-darwin-amd64

3) Checksums:
  (cd dist && shasum -a 256 * > checksums.txt)   # macOS
  (cd dist && sha256sum * > checksums.txt)       # Linux

4) Create Release and upload artifacts.

Install script will fetch:
  https://github.com/<owner>/xpoz_cli/releases/download/<tag>/<asset>

------------------------------------------------------------

## Security

- Use tokens for private tunnels.
- Avoid piping unknown scripts to bash; review install.sh if concerned.
- Consider rotating tokens and limiting IPs when server‑side ACLs ship.

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
