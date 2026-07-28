# Managed Browser and Security Audit

## Goal

Give Forge a dedicated browser for web interaction without exposing the personal Ubuntu browser profile, cookies, saved passwords, extensions, unrelated host files, or the dedicated `Forge_Shared` exchange folder.

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

The browser plugin was enabled, but no browser runtime image existed.

Observed state:

```text
Browser plugin: enabled
Browser control endpoint: reachable
Browser profile: openclaw
Browser runtime: not running
Sandbox-browser image: absent
```

The design goal was a Docker-isolated browser rather than the normal Ubuntu browser.

## Build the matching browser image

OpenClaw was installed from npm as `2026.7.1-2`. The npm package did not expose a usable `gitHead`, so a commit-specific raw source URL could not be constructed.

The republish suffix was removed, candidate Git tags were checked, and the installed package was matched to:

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

The isolated browser was enabled with these values:

```bash
openclaw config set agents.defaults.sandbox.browser.enabled true --strict-json

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

- `allowHostControl: false` prevents Forge from targeting the personal Ubuntu browser.
- The dedicated Docker network separates browser automation from the command sandbox.
- `autoStart: true` creates the browser container when Forge first calls the browser tool.
- noVNC allows optional observation without merging the browser into the host profile.

## Tool-policy configuration

The browser tool had to pass two policy gates:

```bash
openclaw config set tools.alsoAllow '["browser"]' --strict-json

openclaw config set \
  tools.sandbox.tools.alsoAllow \
  '["web_search","web_fetch","browser"]' \
  --strict-json

openclaw config validate
openclaw gateway restart
```

A fresh TUI session then exposed `browser` alongside `web_search` and `web_fetch`.

## Browser test

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

Commands:

```bash
openclaw sandbox list --browser

docker ps --format \
  'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Networks}}'
```

Observed runtime:

```text
Container: openclaw-sbx-browser-agent-main-f331f052
Image:     openclaw-sandbox-browser:bookworm-slim
Status:    running
Network:   openclaw-sandbox-browser
CDP:       32769
noVNC:     32768
Session:   agent:main
```

The normal command sandbox remained a separate container on Docker's `bridge` network.

## Mount-isolation validation

The browser container mounts were inspected directly:

```bash
docker inspect "$BROWSER_CONTAINER" \
  --format '{{range .Mounts}}{{println .Source "->" .Destination "(" .RW ")"}}{{end}}'
```

Observed mounts:

```text
~/.openclaw/workspace
  -> /workspace (read/write)

~/.openclaw/sandbox/skills-workspaces/.../skills
  -> /workspace/.openclaw/sandbox-skills/skills (read-only)
```

No personal browser or credential locations were mounted, including:

```text
~/.config/google-chrome
~/.config/chromium
~/.mozilla
password-manager data
Dual_Boot_Share
Forge_Shared
```

After controlled shared-folder access was added to the command sandbox, browser binds were explicitly set to `[]`. Direct container tests later confirmed:

```text
PASS: browser cannot see Forge_Shared
PASS: browser cannot see Dual_Boot_Share
```

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

OpenClaw classifies `qwen3-coder:30b` as a small model for untrusted web input while web tools are enabled.

This is a prompt-injection and tool-misuse warning, not a reported container escape. A malicious webpage or search result could attempt to manipulate the model into misusing tools that it legitimately possesses.

Accepted residual-risk controls:

- One trusted operator
- Gateway bound to loopback
- Token authentication
- Docker command sandbox
- Separate Docker browser sandbox
- Host-browser control disabled
- No personal browser profile mounted
- Browser has no external shared-data bind
- Approval-controlled command execution
- No secrets stored in `/workspace` or `Forge_Shared`

Operational restrictions:

- Do not use the managed browser for banking.
- Do not use it for personal email.
- Do not sign into password managers.
- Do not use sensitive cloud, network, identity, or production administration accounts.
- Treat webpage and search-result content as untrusted input.

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

These files were not committed automatically. Review them for tokens, secrets, private paths, and unnecessary runtime identifiers before adding selected evidence to a public repository.

## Durable-memory status

The first Forge request to update durable memory did not complete. Direct Ubuntu verification caught the mismatch before it was treated as successful.

The memory checkpoint was then repaired directly from Ubuntu:

- The original `MEMORY.md` was backed up.
- The `Current Project Checkpoint` section was updated.
- `memory/2026-07-28.md` was created and verified.
- Durable memory was later updated again after the controlled-share milestone.

Current durable memory now identifies trusted-LAN access as the next phase.

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

Remove the browser image only after browser containers are stopped and rollback is intentional:

```bash
docker image rm openclaw-sandbox-browser:bookworm-slim
```

## Next task

The controlled `Forge_Shared` phase is documented in `16-controlled-shared-folder-access.md` and is complete. The next phase is network inventory followed by authenticated trusted-LAN Gateway access without public port forwarding.