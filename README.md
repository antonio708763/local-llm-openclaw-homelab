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
    `-- web_search --> SearXNG on 127.0.0.1:8888 --> upstream search engines

Forge tool execution
    |
    v
Docker sandbox
    +-- user: sandbox, UID 1000
    +-- Debian 12
    +-- /workspace <-> ~/.openclaw/workspace (read/write)
    +-- bridge networking for outbound DNS and HTTPS
    `-- Ubuntu host home and Dual_Boot_Share are not mounted
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

### Docker sandbox

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

## Validated results

```text
Model:              qwen3-coder:30b
Processor:          100% GPU
Context:            32768 tokens
GPU memory:         approximately 21.7 GiB / 24.6 GiB
Gateway bind:       127.0.0.1:18789
Gateway RPC probe:  ok
Exec host:          sandbox
Exec security:      allowlist
Exec approval:      ask-on-miss
Sandbox image:      openclaw-sandbox:bookworm-slim
Sandbox user:       sandbox, UID 1000
Sandbox OS:         Debian GNU/Linux 12
Workspace mount:    /workspace, read/write
Host home visible:  no
DNS:                working
Outbound HTTPS:     working
SearXNG bind:        127.0.0.1:8888
SearXNG JSON API:    working
OpenClaw web_search: working through SearXNG
Compaction reserve: 8192 tokens
Recent-token keep:  6000 tokens
Durable memory:     verified across sessions
```

## Current checkpoint

The self-hosted search and durable-memory phase is complete. Docker, Ollama, the OpenClaw Gateway, and SearXNG were all healthy at the stopping point. `MEMORY.md` records the current project state and identifies the next task.

## Next tasks

1. Configure and test the isolated OpenClaw managed browser.
2. Keep the managed browser separate from the personal browser profile.
3. Rerun `openclaw security audit --deep` after browser configuration.
4. Decide whether and how to mount selected `Dual_Boot_Share` folders.
5. Configure authenticated trusted-LAN access.
6. Audit NetBird for remote access.

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
│   └── 14-searxng-compaction-and-memory.md
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
7. Test infrastructure changes against lab systems first.
8. Do not commit tokens, API keys, SearXNG secret keys, or `openclaw.json` secrets.
9. Keep documentation and change history in Git.
