# Local LLM + OpenClaw Homelab

A documented build for running a self-hosted coding assistant on a dual-boot workstation, with future trusted LAN and encrypted remote access.

## Target system

- **Agent:** Forge
- **Model:** `qwen3-coder:30b`
- **Model runtime:** Ollama `0.32.3`
- **Agent layer:** OpenClaw `2026.7.1-2`
- **Host OS:** Ubuntu, dual-booted with Windows 10
- **GPU:** NVIDIA RTX 4090, 24 GB VRAM
- **CPU:** AMD Ryzen 9 7950X
- **Memory:** 64 GB DDR5
- **Container runtime:** Docker Engine `29.6.2`
- **Search service:** self-hosted SearXNG on `127.0.0.1:8888`
- **Managed browser:** isolated Chromium container using `openclaw-sandbox-browser:bookworm-slim`
- **Shared storage:** `Dual_Boot_Share`, NTFS, mounted at `/mnt/Dual_Boot_Share`

## Current architecture

```text
OpenClaw TUI
    |
    | ws://127.0.0.1:18789
    v
OpenClaw Gateway
    |
    +-- http://127.0.0.1:11434 --> Ollama --> qwen3-coder:30b --> RTX 4090
    |
    +-- web_search --> SearXNG on 127.0.0.1:8888 --> upstream search engines
    |
    `-- browser tool --> isolated Chromium browser container

Forge command execution
    |
    v
Docker command sandbox
    +-- image: openclaw-sandbox:bookworm-slim
    +-- user: sandbox, UID 1000
    +-- Debian 12
    +-- /workspace <-> ~/.openclaw/workspace (read/write)
    +-- bridge networking for outbound DNS and HTTPS
    `-- Ubuntu host home and Dual_Boot_Share are not mounted

Forge browser automation
    |
    v
Docker browser sandbox
    +-- image: openclaw-sandbox-browser:bookworm-slim
    +-- dedicated network: openclaw-sandbox-browser
    +-- host-browser control: disabled
    +-- personal browser profiles: not mounted
    +-- /workspace mounted read/write
    `-- screenshots stored under ~/.openclaw/media on Ubuntu
```

The Gateway, Ollama, and SearXNG remain loopback-only. No public port forwarding, LAN binding, remote exposure, or sandbox access to `Dual_Boot_Share` has been enabled.

## Completed

### Storage and dual boot

- [x] Kept Windows and Ubuntu on separate NVMe drives
- [x] Backed up important Windows data
- [x] Repaired and verified the Windows NTFS filesystem
- [x] Resized the Windows partition safely
- [x] Created an approximately 500 GB `Dual_Boot_Share` NTFS partition
- [x] Mounted it permanently at `/mnt/Dual_Boot_Share`
- [x] Confirmed the mount survives an Ubuntu reboot

### Ollama and Qwen

- [x] Installed and enabled Ollama `0.32.3`
- [x] Downloaded and tested `qwen3-coder:30b`
- [x] Confirmed `100% GPU` residency
- [x] Validated approximately 21.7 GiB VRAM use
- [x] Set OpenClaw and Ollama context to `32768`

### OpenClaw

- [x] Installed OpenClaw `2026.7.1-2`
- [x] Connected it to `http://127.0.0.1:11434`
- [x] Selected `ollama/qwen3-coder:30b`
- [x] Installed the Gateway as an enabled systemd user service
- [x] Kept the Gateway on `127.0.0.1:18789` with token authentication
- [x] Confirmed Gateway and Ollama auto-start after reboot
- [x] Created the Forge identity
- [x] Disabled broken OpenAI-backed semantic memory search for now
- [x] Disabled insecure Control UI authentication
- [x] Applied the cautious execution policy
- [x] Set normal command execution to `host=sandbox`
- [x] Tuned compaction for the 32,768-token model
- [x] Created and verified durable `MEMORY.md` and dated memory notes
- [x] Confirmed durable memory is available in a fresh session

### Docker command sandbox

- [x] Installed Docker Engine from Docker's official Ubuntu repository
- [x] Validated Docker with `hello-world`
- [x] Built `openclaw-sandbox:bookworm-slim`
- [x] Enabled sandbox mode `all`, Docker backend, and agent scope
- [x] Mounted the OpenClaw workspace read/write at `/workspace`
- [x] Enabled Docker bridge networking
- [x] Confirmed the first Forge tool request automatically created a sandbox runtime
- [x] Confirmed commands run as the unprivileged `sandbox` user on Debian 12
- [x] Confirmed `/home/antonio` is not visible inside the sandbox
- [x] Confirmed writes in `/workspace` persist to `~/.openclaw/workspace`
- [x] Confirmed outbound DNS resolution and HTTPS access

### Self-hosted web search

- [x] Installed the OpenClaw SearXNG plugin
- [x] Deployed SearXNG as a Docker container
- [x] Bound SearXNG only to `127.0.0.1:8888`
- [x] Persisted SearXNG configuration at `~/searxng/settings.yml`
- [x] Enabled HTML and JSON search output
- [x] Added `web_search` and `web_fetch` to the sandbox tool allowlist
- [x] Connected OpenClaw `web_search` to the local SearXNG service
- [x] Completed a successful fresh-session web search test
- [x] Pinned the plugin to `@openclaw/searxng-plugin@2026.7.1`

### Isolated managed browser

- [x] Built `openclaw-sandbox-browser:bookworm-slim` from the matching OpenClaw `v2026.7.1` source tag
- [x] Enabled the sandbox browser and automatic startup
- [x] Disabled host-browser control
- [x] Placed the browser on the dedicated `openclaw-sandbox-browser` Docker network
- [x] Added the `browser` tool to both required policy gates
- [x] Opened and inspected `https://example.com`
- [x] Verified the page title and main heading
- [x] Generated a browser snapshot and screenshot
- [x] Confirmed screenshots were saved under `~/.openclaw/media`
- [x] Confirmed no personal Chrome, Chromium, Firefox, or credential directories were mounted
- [x] Reran the deep OpenClaw security audit

## Validated results

```text
Model:                   qwen3-coder:30b
Processor:               100% GPU
Context:                 32768 tokens
GPU memory:              approximately 21.7 GiB / 24.6 GiB
Gateway bind:            127.0.0.1:18789
Gateway RPC probe:       ok
Exec host:               sandbox
Exec security:           allowlist
Exec approval:           ask-on-miss
Command sandbox image:   openclaw-sandbox:bookworm-slim
Command sandbox user:    sandbox, UID 1000
Command sandbox OS:      Debian GNU/Linux 12
Workspace mount:         /workspace, read/write
Host home visible:       no
DNS:                     working
Outbound HTTPS:          working
SearXNG bind:             127.0.0.1:8888
SearXNG JSON API:         working
SearXNG plugin pin:       @openclaw/searxng-plugin@2026.7.1
OpenClaw web_search:      working through SearXNG
Browser sandbox image:   openclaw-sandbox-browser:bookworm-slim
Browser network:         openclaw-sandbox-browser
Host-browser control:    disabled
Personal browser mounts: none
Browser navigation:      working
Browser snapshot:        working
Browser screenshot:      working
Compaction reserve:      8192 tokens
Recent-token keep:       6000 tokens
Durable memory:          verified across sessions
```

## Security-audit position

The most recent deep audit reports:

- **1 critical:** OpenClaw classifies `qwen3-coder:30b` as a small model for untrusted web inputs while `web_search` and `web_fetch` are enabled.
- **1 warning:** `trustedProxies` is empty while the Gateway is loopback-only.

The trusted-proxies warning requires no action until a reverse proxy is deliberately introduced. The small-model finding is accepted residual risk for the current single-user lab because command and browser activity are sandboxed, the Gateway is loopback-only, personal browser profiles are excluded, and unrelated host files are not mounted.

The managed browser must not be used for banking, personal email, password managers, or sensitive administrative accounts.

## Current checkpoint

The isolated managed-browser phase is complete, including navigation, snapshot, screenshot, mount-isolation verification, plugin pinning, and the deep security audit.

The attempted Forge memory update did not complete. The existing `MEMORY.md` still names managed-browser configuration as the next task, and `memory/2026-07-28.md` has not yet been created. A local evidence bundle was created successfully under:

```text
~/.openclaw/workspace/checkpoints/2026-07-28-managed-browser/
```

## Next tasks

1. Repair the pending `MEMORY.md` checkpoint and create `memory/2026-07-28.md`.
2. Review the local browser evidence bundle for secrets before committing selected text artifacts.
3. Create a dedicated `Dual_Boot_Share/Forge_Shared` folder.
4. Mount only that folder into the command sandbox.
5. Keep the browser sandbox from inheriting the shared-folder mount.
6. Test controlled read/write access and confirm unrelated data remains unavailable.
7. Configure authenticated trusted-LAN access.
8. Audit NetBird for remote access.

## Repository map

```text
.
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── 00-project-overview.md
│   ├── 01-hardware-and-os-layout.md
│   ├── 02-storage-layout.md
│   ├── 03-shared-partition-build-log.md
│   ├── 04-backup-and-recovery.md
│   ├── 05-network-access-plan.md
│   ├── 06-security-model.md
│   ├── 07-implementation-roadmap.md
│   ├── 08-validation-checklists.md
│   ├── 09-troubleshooting-log.md
│   ├── 10-ollama-and-model-validation.md
│   ├── 11-openclaw-local-onboarding.md
│   ├── 12-docker-and-sandbox.md
│   ├── 13-sandbox-runtime-validation.md
│   ├── 14-searxng-compaction-and-memory.md
│   └── 15-managed-browser-and-security-audit.md
├── docker/
│   └── openclaw-sandbox/
│       └── Dockerfile
├── scripts/
└── assets/screenshots/
```

## Safety rules

1. Keep Ollama, SearXNG, and the Gateway private and loopback-only until authenticated access is deliberately configured.
2. Require authentication for OpenClaw LAN and remote access.
3. Keep command execution approval-controlled.
4. Run generated commands inside a sandbox whenever practical.
5. Do not mount production data into the sandbox by default.
6. Keep the managed browser separate from personal browser profiles and credentials.
7. Do not use the managed browser for banking, personal email, password managers, or sensitive administration.
8. Treat webpage content and search results as untrusted input.
9. Test infrastructure changes against lab systems first.
10. Do not commit tokens, API keys, SearXNG secret keys, or `openclaw.json` secrets.
11. Keep documentation and change history in Git.
