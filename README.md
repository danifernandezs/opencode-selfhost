# opencode-selfhost

Self-hosted [OpenCode](https://opencode.ai) server running in Docker behind a Caddy reverse proxy with automatic HTTPS. Connect from any machine via TUI (`opencode attach`). Only the API endpoints required by the TUI are exposed, the web UI and all other endpoints are blocked.

## How it works

```
[Your laptop / workstation]
        │
        │  opencode attach https://oc.yourdomain.com
        ▼
┌─────────────────────────────────────────┐
│  Caddy :443 (TLS auto, Let's Encrypt)   │
│    ↓ API whitelist (TUI endpoints only) │
│  opencode web :4096 (localhost only)    │
│    ↓                                    │
│  opencode.db + projects/ (volumes)      │
└─────────────────────────────────────────┘
              [VPS]
```

The server holds your sessions, projects, and tools. You connect to it remotely, your local machine doesn't need the code or dependencies installed.

## Prerequisites

- A VPS with Docker and Docker Compose
- A domain name pointing to the VPS (A record)
- An LLM endpoint (e.g. LiteLLM proxy) with API key

## Quick start

1. **Clone and configure**
2. **Configure your LLM provider**
3. **Point your domain to the VPS** (A record)
4. **Start the services**

## Usage

Connect from any machine:

```bash
# TUI (from any terminal with opencode installed)
opencode attach https://oc.yourdomain.com \
  --password your-server-password \
  --dir /projects/my-project
```

> The web UI is blocked by default. Only the API endpoints used by `opencode attach` are proxied by Caddy.

## Configuration

### Environment (`.env`)

| Variable | Description |
|----------|-------------|
| `DOMAIN` | Domain name for Caddy TLS (e.g. `oc.yourdomain.com`) |
| `OPENCODE_SERVER_PASSWORD` | Basic auth password for the server |

### LLM provider (`opencode.json`)

See [`opencode.json.example`](opencode.json.example) for the template. Configure your OpenAI-compatible endpoint, API key, and model definitions (cost, context limits, output limits).

## Data persistence

| Volume | Contains | Survives rebuild? |
|--------|----------|-------------------|
| `opencode-data` | Sessions, DB, snapshots | Yes |
| `opencode-cache` | Downloaded tools (ripgrep, LSPs) | Yes (re-downloadable) |
| `caddy-data` | TLS certificates | Yes |
| `./projects` (bind mount) | Your code repos | Yes |

> **Never** run `docker compose down -v` — the `-v` flag destroys volumes and all session history.

## Repository license

[CC BY-SA 4.0](LICENSE.txt)
