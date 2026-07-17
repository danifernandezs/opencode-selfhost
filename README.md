# opencode-selfhost

> Repository: [github.com/danifernandezs/opencode-selfhost](https://github.com/danifernandezs/opencode-selfhost)

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

1. **Clone the repo**

   ```bash
   git clone https://github.com/danifernandezs/opencode-selfhost.git
   cd opencode-selfhost
   ```

2. **Copy and edit the environment file**

   ```bash
   cp .env.example .env
   # Edit .env: set DOMAIN and OPENCODE_SERVER_PASSWORD
   # Generate a password: openssl rand -base64 32
   ```

3. **Copy and edit the LLM config**

   ```bash
   cp opencode.json.example opencode.json
   # Edit opencode.json: set your provider, API key, and models
   ```

4. **Point your domain to the VPS** (A record to your VPS IP)

5. **Start the services**

   ```bash
   docker compose up -d
   ```

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

## License

This project is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) — see [`LICENSE.txt`](LICENSE.txt) for details.
