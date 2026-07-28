# Managed Browser and Security Audit

## Goal

Give Forge a dedicated browser for web interaction without exposing the personal Ubuntu browser profile, cookies, saved passwords, extensions, or unrelated host files.

The browser is separate from the command sandbox:

```text
Command sandbox
  image: openclaw-sandbox:bookworm-slim
  network: bridge

Browser sandbox
  image: openclaw-sandbox-browser:bookworm-slim
  network: openclaw-sandbox-browser
```

## Initial inspection

The browser plugin was already enabled, but no browser configuration or browser image existed.

Observed state:

```text
Browser plugin: enabled
Browser control endpoint: reachable
Browser profile: openclaw
Browser runtime: not running
Sandbox-browser image: absent
```

The host-managed browser was not started. The design goal was a Docker-isolated browser instead.

## Build the matching browser image

OpenClaw was installed from npm as `2026.7.1-2`. The npm package did not expose a usable `gitHead`, so a commit-specific raw download could not be constructed.

Candidate Git tags were checked, and the installed package was matched to:

```text
v2026.7.1
```

The matching source was cloned:

```bash
BUILD_DIR="/tmp/openclaw-browser-build"
rm -rf "$BUILD_DIR"

git clone \
  --depth 1 \
  --branch v2026.7.1 \
  https://github.com/openclaw/openclaw.git \
  "$BUILD_DIR"
```

The official setup script built the browser image:

```bash
cd "$BUILD_DIR"
bash scripts/sandbox-browser-setup.sh
```

Validation:

```bash
docker images openclaw-sandbox-browser:bookworm-slim
```

Observed result:

```text
Image:         openclaw-sandbox-browser:bookworm-slim
Image ID:      33fbbf1cd311
Disk usage:    1.67 GB
Content size:  469 MB
```

## Browser configuration

The isolated browser was enabled with the following values:

```bash
openclaw config set \
  agents.defaults.sandbox.browser.enabled \
  true \
  --strict-json

openclaw config set \
  agents.defaults.sandbox.browser.image \
  '"openclaw-sandbox-browser:bookworm-slim"' \
  --strict-json

openclaw config set \
  agents.defaults.sandbox.browser.network \
  '"openclaw-sandbox-browser"' \
  --strict-json

openclaw config set \
  agents.defaults.sandbox.browser.allowHostControl \
  false \
  --strict-json

openclaw config set \
  agents.defaults.sandbox.browser.autoStart \
  true \
  --strict-json

openclaw config set \
  agents.defaults.sandbox.browser.headless \
  false \
  --strict-json

openclaw config set \
  agents.defaults.sandbox.browser.enableNoVnc \
  true \
  --strict-json
```

Important controls:

- `allowHostControl: false` prevents Forge from targeting the normal Ubuntu browser.
- The dedicated Docker network separates the browser from the normal command-sandbox network.
- `autoStart: true` creates and starts the browser container when Forge first calls the browser tool.
- noVNC is enabled for optional observation without merging the browser into the host profile.

## Tool-policy configuration

The browser tool had to pass two policy gates:

```bash
openclaw config set \
  tools.alsoAllow \
  '["browser"]' \
  --strict-json

openclaw config set \
  tools.sandbox.tools.alsoAllow \
  '["web_search","web_fetch","browser"]' \
  --strict-json

openclaw config validate
openclaw gateway restart
```

`openclaw sandbox explain --session agent:main:main` then listed:

```text
web_search
web_fetch
browser
```

## First browser test

A fresh TUI session was used so the updated tool definition would be injected.

Forge was instructed to use only the browser tool and:

1. Open `https://example.com`.
2. Report the final URL.
3. Report the page title.
4. Report the main heading.
5. Take a browser snapshot.
6. Take a screenshot.
7. Avoid external links, downloads, and data entry.

Observed result:

```text
Final URL:    https://example.com/
Page title:   Example Domain
Main heading: Example Domain
Browser type: sandbox browser
```

## Browser runtime validation

```bash
openclaw sandbox list --browser

docker ps --format \
  'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Networks}}'
```

Observed browser runtime:

```text
Container: openclaw-sbx-browser-agent-main-f331f052
Image:     openclaw-sandbox-browser:bookworm-slim
Status:    running
Network:   openclaw-sandbox-browser
CDP:       32769
noVNC:     32768
Session:   agent:main
```

The normal command sandbox remained a separate container on the Docker `bridge` network.

## Mount-isolation validation

The browser container mounts were inspected with:

```bash
docker inspect "$BROWSER_CONTAINER" \
  --format '{{range .Mounts}}{{println .Source "->" .Destination}}{{end}}'
```

Observed mounts:

```text
~/.openclaw/workspace -> /workspace
~/.openclaw/sandbox/skills-workspaces/.../skills -> /workspace/.openclaw/sandbox-skills/skills
```

No personal browser or credential locations were mounted, including:

```text
~/.config/google-chrome
~/.config/chromium
~/.mozilla
password-manager data
Dual_Boot_Share
```

This confirms the browser is isolated from the personal browser profile and unrelated host data.

## Screenshot validation

Recent image files were located under:

```text
~/.openclaw/media/browser/
~/.openclaw/media/outbound/
```

The screenshot was opened on Ubuntu and visually confirmed to show the Example Domain page.

## Pin the SearXNG plugin

The first deep security audit warned that SearXNG was installed from an unpinned package specification.

Inspection showed version `2026.7.1`, so it was reinstalled with an exact pin:

```bash
openclaw plugins install \
  npm:@openclaw/searxng-plugin@2026.7.1 \
  --pin \
  --force

openclaw gateway restart
```

Runtime inspection confirmed:

```text
spec:         @openclaw/searxng-plugin@2026.7.1
resolvedSpec: @openclaw/searxng-plugin@2026.7.1
version:      2026.7.1
```

The unpinned-plugin warning disappeared from the next audit.

## Deep security audit

Command:

```bash
openclaw security audit --deep
```

Final result:

```text
1 critical
1 warning
1 informational finding
```

### Critical: small model with web tools

OpenClaw classifies `qwen3-coder:30b` as a small model for untrusted web input while `web_search` and `web_fetch` are enabled.

This is not a container escape report. It is a prompt-injection and tool-misuse warning. A malicious webpage or search result could attempt to manipulate the model into misusing tools that the model legitimately possesses.

Accepted residual-risk controls:

- One trusted operator
- Gateway bound to loopback
- Token authentication
- Docker command sandbox
- Separate Docker browser sandbox
- Host-browser control disabled
- No personal browser profile mounted
- No unrelated host files mounted
- Approval-controlled command execution
- No secrets stored in `/workspace`

Operational restrictions:

- Do not use the managed browser for banking.
- Do not use it for personal email.
- Do not sign into password managers.
- Do not use sensitive cloud, network, identity, or production administration accounts.
- Treat all webpage and search-result content as untrusted input.

### Warning: trusted proxies missing

The Gateway remains bound to loopback and is not behind a reverse proxy. No change is required now.

When a reverse proxy is deliberately introduced, configure `gateway.trustedProxies` before exposing the Control UI through it.

## Local evidence bundle

A local evidence directory was created:

```text
~/.openclaw/workspace/checkpoints/2026-07-28-managed-browser/
```

Files created:

```text
browser-config.json
browser-image.txt
browser-runtime.txt
sandbox-tool-policy.json
searxng-plugin.json
security-audit.txt
```

These files have not been committed automatically. Review them for tokens, secrets, private paths, and unnecessary runtime identifiers before adding selected evidence to a public repository.

## Memory-update status

The attempted Forge memory update did not complete.

Direct Ubuntu verification showed:

```text
MEMORY.md still names the managed browser as the next task.
memory/2026-07-28.md does not exist.
```

This is a pending documentation task, not a managed-browser failure.

## Rollback

Disable the sandbox browser:

```bash
openclaw config set \
  agents.defaults.sandbox.browser.enabled \
  false \
  --strict-json

openclaw gateway restart
```

Remove browser access from the policy gates:

```bash
openclaw config unset tools.alsoAllow

openclaw config set \
  tools.sandbox.tools.alsoAllow \
  '["web_search","web_fetch"]' \
  --strict-json

openclaw config validate
openclaw gateway restart
```

Remove the browser image only after browser containers are stopped and the rollback is intentional:

```bash
docker image rm openclaw-sandbox-browser:bookworm-slim
```

## Next task

Repair the durable-memory checkpoint, then create a dedicated `Forge_Shared` folder on `Dual_Boot_Share` and expose only that folder to the command sandbox. The browser sandbox should not inherit the shared-data mount.
