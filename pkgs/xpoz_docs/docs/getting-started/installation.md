
# Installation

## Automatic Install (Recommended)

The easiest way to install Xpoz CLI:

```bash
curl -fsSL https://cli.xpoz.xyz/install.sh | bash
```
### This script will:

- Download the latest binary for your platform
- Install it to ```/usr/local/bin/xpoz```
- Make it executable and available in your PATH

## Manual Install

#### Download Binary
Visit the (https://github.com/ildysilva/xpoz_cli/releases)[releases page] and download the appropriate binary for your platform:

- xpoz-linux-amd64 - Linux 64-bit
- xpoz-darwin-amd64 - macOS Intel
- xpoz-darwin-arm64 - macOS Apple Silicon

## Install Binary

 Make it executable
```bash
# Make it executable
chmod +x xpoz-*
```

```bash
# Move to PATH
sudo mv xpoz-* /usr/local/bin/xpoz
```
## Verify Installation
``` xpoz --version```

You should see the version number displayed.

## System Requirements

- Linux or macOS
- Internet connection for tunneling
- No additional dependencies required
