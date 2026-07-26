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
- **Shared storage:** `Dual_Boot_Share`, NTFS, mounted at `/mnt/Dual_Boot_Share`

## Current architecture

```text
OpenClaw TUI
    |
    | ws://127.0.0.1:18789
    v
OpenClaw Gateway
    |
    | http://127.0.0.1:11434
    v
Ollama
    |
    v
qwen3-coder:30b on RTX 4090

Forge tool execution
    |
    v
Docker sandbox
    |
    +-- /workspace  <->  ~/.openclaw/workspace (read/write)
    +-- bridge networking for outbound access
```

The Gateway and Ollama remain loopback-only. No public port forwarding, LAN binding, or remote exposure has been enabled.

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
- [x] Disabled broken OpenAI-backed memory search for now
- [x] Disabled insecure Control UI authentication
- [x] Applied the cautious execution policy: allowlist with approval on miss
- [x] Removed the temporary provider-specific web/browser deny rule

### Docker sandbox

- [x] Installed Docker Engine from Docker's official Ubuntu repository
- [x] Validated Docker with `hello-world`
- [x] Added the administrator account to the Docker group
- [x] Confirmed Docker works without `sudo` after reboot
- [x] Built `openclaw-sandbox:bookworm-slim`
- [x] Enabled sandbox mode `all`
- [x] Selected the Docker backend
- [x] Set sandbox scope to `agent`
- [x] Mounted the OpenClaw workspace read/write at `/workspace`
- [x] Enabled Docker bridge networking
- [x] Confirmed the effective session runtime is `sandboxed`

## Validated model result

```text
Model:           qwen3-coder:30b
Processor:       100% GPU
Context:         32768 tokens
GPU memory:      approximately 21.7 GiB / 24.6 GiB
GPU utilization: 90%
GPU temperature: 47 C
```

## Validated service result

```text
Docker:          active
Ollama:          active
Gateway:         enabled and running
Gateway bind:    127.0.0.1:18789
RPC read probe:  ok
Sandbox image:   openclaw-sandbox:bookworm-slim
Sandbox mode:    all
Sandbox scope:   agent
Workspace mount: /workspace, read/write
Network:         bridge
```

## Current checkpoint

The sandbox configuration is active, but no sandbox runtime has been created yet:

```text
No sandbox runtimes found.
Total: 0 (0 running)
```

This is expected because Forge has not yet executed its first tool request.

## Next tasks

1. Run one harmless read-only command through Forge.
2. Confirm the cautious approval prompt appears.
3. Verify the Docker sandbox container is created.
4. Confirm commands run inside the container rather than on the Ubuntu host.
5. Test outbound Internet access from inside the sandbox.
6. Configure self-hosted web search, likely SearXNG.
7. Configure the managed browser separately, because browser tools are not currently allowed by the default sandbox tool policy.
8. Rerun `openclaw security audit --deep`.
9. Decide whether and how to mount selected folders from `Dual_Boot_Share`.
10. Configure authenticated trusted-LAN access.
11. Audit NetBird for remote access.

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
│   └── 12-docker-and-sandbox.md
├── docker/
│   └── openclaw-sandbox/
│       └── Dockerfile
├── scripts/
└── assets/screenshots/
```

## Safety rules

1. Keep Ollama private and loopback-only.
2. Require authentication for OpenClaw LAN and remote access.
3. Keep command execution approval-required.
4. Run generated commands inside a sandbox whenever practical.
5. Do not mount production data into the sandbox by default.
6. Test infrastructure changes against lab systems first.
7. Do not commit tokens, API keys, or `openclaw.json` secrets.
8. Keep documentation and change history in Git.
