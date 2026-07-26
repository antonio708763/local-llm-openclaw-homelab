# SearXNG, Compaction, and Durable Memory

## Goal

Add self-hosted web search to Forge, tune OpenClaw for the 32,768-token local model, and create durable project memory that survives fresh TUI sessions.

## Self-hosted SearXNG

### OpenClaw plugin

```bash
openclaw plugins install @openclaw/searxng-plugin
```

The plugin installed under the OpenClaw user configuration. The Gateway must be restarted after plugin or tool-policy changes.

### Initial container

```bash
docker run -d \
  --name searxng \
  --restart unless-stopped \
  -p 127.0.0.1:8888:8080 \
  searxng/searxng
```

The loopback-only bind keeps the service unavailable to other LAN devices.

Validation:

```bash
docker ps --filter name=searxng
curl -fsS http://127.0.0.1:8888 | head
```

The HTML interface loaded successfully.

## Enable the JSON API

The first JSON request returned HTTP 403 because JSON output was not enabled in the default settings.

Create persistent configuration:

```bash
mkdir -p ~/searxng
SEARXNG_SECRET="$(openssl rand -hex 32)"

cat > ~/searxng/settings.yml <<EOF
use_default_settings: true

search:
  formats:
    - html
    - json

server:
  secret_key: "$SEARXNG_SECRET"
EOF

unset SEARXNG_SECRET
chmod 644 ~/searxng/settings.yml
```

> Never commit the real SearXNG secret key to Git.

Recreate the container with the configuration mounted read-only:

```bash
docker rm -f searxng

docker run -d \
  --name searxng \
  --restart unless-stopped \
  -p 127.0.0.1:8888:8080 \
  -e FORCE_OWNERSHIP=false \
  -v "$HOME/searxng/settings.yml:/etc/searxng/settings.yml:ro" \
  searxng/searxng
```

Validation:

```bash
curl -fsS \
  'http://127.0.0.1:8888/search?q=OpenClaw&format=json' \
  | head -c 500

echo
```

The request returned JSON search results.

## Connect OpenClaw to SearXNG

```bash
openclaw config set tools.web.search.provider '"searxng"' --strict-json

openclaw config set \
  plugins.entries.searxng.config.webSearch.baseUrl \
  '"http://127.0.0.1:8888"' \
  --strict-json

openclaw config set \
  plugins.entries.searxng.config.webSearch.language \
  '"en"' \
  --strict-json
```

The sandbox policy also needed to expose the web tools:

```bash
openclaw config set \
  tools.sandbox.tools.alsoAllow \
  '["web_search","web_fetch"]' \
  --strict-json

openclaw config validate
openclaw gateway restart
```

`openclaw sandbox explain --session agent:main:main` then listed `web_search` and `web_fetch` in the global sandbox allow set.

## Web-search validation

A fresh TUI session was created so it would receive the updated tool definitions.

Test prompt:

```text
Use the web_search tool to find the official OpenClaw SearXNG documentation.
Give me three results and identify the search provider.
```

Forge returned three search results and identified SearXNG as the provider.

Validated path:

```text
Forge
  -> OpenClaw web_search
  -> local SearXNG at 127.0.0.1:8888
  -> configured upstream search engines
```

The LLM remains local. Search queries and ordinary result-fetching requests leave the machine through SearXNG.

## Compaction problem

OpenClaw reported that auto-compaction could not recover the current turn. The visible TUI token counter did not represent all startup context.

`/context detail` showed that the full prompt also included:

- System instructions
- Injected workspace files
- Skills
- Tool definitions and JSON schemas
- Conversation history

Observed tracked startup estimate:

```text
approximately 8,929 tokens
```

## Compaction configuration

For the 32,768-token Qwen context, the following values were applied:

```bash
openclaw config set agents.defaults.compaction.reserveTokens 8192 --strict-json
openclaw config set agents.defaults.compaction.reserveTokensFloor 8192 --strict-json
openclaw config set agents.defaults.compaction.keepRecentTokens 6000 --strict-json
openclaw config validate
openclaw gateway restart
```

Verified configuration:

```json
{
  "reserveTokens": 8192,
  "keepRecentTokens": 6000,
  "reserveTokensFloor": 8192
}
```

Meaning:

- `reserveTokens`: preserve room for model output, tool results, and runtime overhead.
- `reserveTokensFloor`: do not allow the effective reserve to fall below 8,192 tokens.
- `keepRecentTokens`: retain approximately 6,000 recent tokens verbatim when older history is summarized.

These values do not enlarge the model's context window. They change when and how aggressively OpenClaw summarizes older conversation history.

## Durable memory

OpenClaw sessions preserve conversation history, while workspace memory files preserve selected durable facts across fresh sessions.

Created:

```text
~/.openclaw/workspace/MEMORY.md
~/.openclaw/workspace/memory/2026-07-26.md
```

`MEMORY.md` contains stable information:

- Antonio and Forge identities
- Learning and explanation preferences
- Safety and approval rules
- Homelab and future service-business goals
- Current hardware, model, sandbox, and search architecture
- Current project checkpoint and next task

The dated note contains detailed milestone history:

- Docker sandbox validation
- Host isolation
- Workspace persistence
- DNS and outbound HTTPS tests
- SearXNG deployment and JSON API
- OpenClaw web-search validation
- Compaction troubleshooting

## Memory verification

The files were verified directly from Ubuntu:

```bash
cat ~/.openclaw/workspace/MEMORY.md
cat ~/.openclaw/workspace/memory/2026-07-26.md
```

A new TUI session was then asked to answer only from saved memory. Forge correctly recalled:

- The self-hosted, locally controlled, FOSS-oriented homelab goal
- The future standardized residential-service goal
- Ubuntu, RTX 4090, and `ollama/qwen3-coder:30b`
- The Docker-sandbox and approval safety rules

The first recall test did not identify the next task because it was only in the dated note. A `Current Project Checkpoint` section was therefore added to `MEMORY.md` with:

```text
Next task: configure and test the isolated OpenClaw managed browser.
```

## Semantic memory status

OpenAI-backed semantic memory search remains disabled because no OpenAI API key is configured. This does not prevent `MEMORY.md` or recent dated notes from being loaded into fresh sessions.

A later phase can add a local embedding provider for semantic search across a larger archive of memory notes.

## Stopping-point validation

The following were healthy at the checkpoint:

```text
Docker:          active
Ollama:          active
OpenClaw Gateway enabled and running
Gateway probe:   ok
Gateway bind:    127.0.0.1:18789
SearXNG:         running
SearXNG bind:    127.0.0.1:8888
```

## Resume commands

```bash
systemctl is-active docker
systemctl is-active ollama
docker ps --filter name=searxng
openclaw gateway status --require-rpc
openclaw tui
```

## Next task

Configure and test an isolated OpenClaw-managed browser. It must remain separate from the user's personal browser profile, cookies, stored credentials, and normal browsing data.
