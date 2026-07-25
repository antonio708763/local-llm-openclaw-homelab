# Local LLM + OpenClaw Homelab

A documented build for running a local coding model on a dual-boot workstation and making it available to trusted LAN and remote devices.

## Target system

- **Model:** `qwen3-coder:30b`
- **Model runtime:** Ollama `0.32.3`
- **Agent/orchestration layer:** OpenClaw `2026.7.1-2`
- **Primary host OS:** Ubuntu
- **Secondary OS:** Windows 10
- **GPU:** NVIDIA RTX 4090, 24 GB VRAM
- **CPU:** AMD Ryzen 9 7950X
- **Memory:** 64 GB DDR5
- **Storage:** Separate NVMe drives for Windows and Ubuntu
- **Shared storage:** `Dual_Boot_Share`, NTFS, mounted at `/mnt/Dual_Boot_Share`
- **Remote-access goal:** LAN access plus encrypted remote access
- **Likely remote networking:** Existing self-hosted NetBird deployment, pending audit

## Current project status

### Completed

- [x] Kept Windows and Ubuntu on separate NVMe drives
- [x] Disabled Windows Fast Startup and hibernation
- [x] Confirmed BitLocker is not enabled
- [x] Backed up important Windows data to `SSD_Archive(1)`
- [x] Repaired and verified the Windows NTFS filesystem
- [x] Resized the Windows NTFS partition using GParted
- [x] Created an approximately 500 GB NTFS shared partition
- [x] Named the shared partition `Dual_Boot_Share`
- [x] Verified Windows data integrity after the resize
- [x] Configured and tested the Ubuntu mount at `/mnt/Dual_Boot_Share`
- [x] Recorded the shared-partition UUID as `48003BD2003BC62A`
- [x] Verified the NVIDIA driver and CUDA access
- [x] Installed and enabled Ollama `0.32.3`
- [x] Downloaded and tested `qwen3-coder:30b`
- [x] Confirmed the model runs with `100% GPU` residency
- [x] Confirmed a 32,768-token Ollama context allocation
- [x] Installed OpenClaw `2026.7.1-2`
- [x] Connected OpenClaw to local Ollama at `http://127.0.0.1:11434`
- [x] Selected `ollama/qwen3-coder:30b` as the default model
- [x] Installed and enabled the OpenClaw Gateway as a systemd user service
- [x] Kept the Gateway loopback-only on port `18789` with token authentication
- [x] Confirmed the Gateway RPC probe and Ollama service are healthy
- [x] Connected successfully through the OpenClaw TUI

### Next phases

- [ ] Confirm the shared partition mounts automatically after a reboot
- [ ] Confirm Ollama and the OpenClaw Gateway start correctly after a reboot
- [ ] Complete the OpenClaw identity/bootstrap conversation
- [ ] Inspect current tool permissions and approval behavior
- [ ] Decide which folders OpenClaw may access
- [ ] Run one harmless local tool test
- [ ] Reconcile the TUI's displayed `262k` token capacity with Ollama's observed 32,768-token allocation
- [ ] Reserve a stable LAN address and configure authenticated LAN access
- [ ] Audit the existing NetBird deployment
- [ ] Enable authenticated remote access
- [ ] Add tightly scoped OpenClaw node access to lab systems
- [ ] Keep production systems read-only until the workflow is proven

## Current local architecture

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
```

Both the Gateway and Ollama are currently local-only. No LAN, NetBird, Tailscale, messaging channel, or web-search exposure has been enabled yet.

## Validated model result

```text
Model:           qwen3-coder:30b
Processor:       100% GPU
Ollama context:  32768 tokens
GPU memory:      approximately 21.7 GiB used of 24.6 GiB
GPU utilization: 90%
GPU temperature: 47 C
```

## Validated OpenClaw result

```text
OpenClaw version: 2026.7.1-2
Provider:         Ollama, local only
Model:            ollama/qwen3-coder:30b
Ollama URL:       http://127.0.0.1:11434
Gateway bind:     127.0.0.1
Gateway port:     18789
Gateway auth:     Token
Gateway service:  enabled and running
RPC read probe:   ok
Ollama service:   active
```

## Stop and resume

Before shutting down:

```bash
# Leave the TUI first with Ctrl+C.
openclaw gateway status --require-rpc
systemctl is-active ollama
sudo shutdown now
```

After booting Ubuntu again:

```bash
systemctl is-active ollama
openclaw gateway status --require-rpc
openclaw tui
```

If the Gateway did not start:

```bash
openclaw gateway start
openclaw tui
```

## Repository map

```text
.
├── README.md
├── CHANGELOG.md
├── .gitignore
├── docs
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
│   └── 11-openclaw-local-onboarding.md
├── scripts
│   ├── ubuntu
│   │   ├── inventory-host.sh
│   │   └── verify-shared-partition.sh
│   └── windows
│       ├── backup-user-profile.ps1
│       └── verify-windows-volume.ps1
└── assets
    └── screenshots
        ├── README.md
        ├── dual-boot-share-mounted.webp
        ├── permanent-ntfs-mount-test.webp
        ├── ollama-installation.webp
        ├── qwen3-coder-pull-complete.webp
        ├── qwen3-coder-gpu-validation.webp
        ├── qwen3-coder-first-response.webp
        ├── openclaw-installation.webp
        ├── openclaw-ollama-onboarding.webp
        ├── openclaw-tui-connected.webp
        └── openclaw-gateway-status.webp
```

## Safety rules

1. Back up important files before changing partitions, bootloaders, model runtimes, or agent permissions.
2. Identify drives by **size, filesystem, label, and partition layout**, not only by `/dev/nvmeXnY`; Linux device numbers can change between boots.
3. Do not expose Ollama directly to the public Internet.
4. Require authentication for OpenClaw LAN and remote access.
5. Start with read-only or approval-required actions.
6. Test infrastructure changes against lab systems before production.
7. Keep scripts, configuration files, and change history in Git.
