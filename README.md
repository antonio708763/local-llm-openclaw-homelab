# Local LLM + OpenClaw Homelab

A documented build for running a self-hosted coding assistant on a dual-boot workstation, with authenticated trusted-LAN access and future encrypted remote access.

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
- **Forge exchange folder:** `/mnt/Dual_Boot_Share/Forge_Shared`, exposed only to the command sandbox as `/forge-share`
- **First trusted client:** Ubuntu Linux on an Alienware laptop
- **Trusted-client transport:** persistent SSH local-forward tunnel

## Current architecture

```text
Trusted Alienware Linux client
    |
    | browser -> http://127.0.0.1:18789
    |
    | dedicated Ed25519 key
    | encrypted SSH local forward to 192.168.110.187:22
    v
OpenSSH on Forge host
    |
    v
OpenClaw Gateway 127.0.0.1:18789
    |
    +-- http://127.0.0.1:11434 --> Ollama --> qwen3-coder:30b --> RTX 4090
    |
    +-- web_search --> SearXNG on 127.0.0.1:8888 --> upstream search engines
    |
    `-- browser tool --> isolated Chromium browser container

Local OpenClaw TUI
    |
    | ws://127.0.0.1:18789
    v
OpenClaw Gateway

Forge command execution
    |
    v
Docker command sandbox
    +-- image: openclaw-sandbox:bookworm-slim
    +-- user: sandbox, UID 1000
    +-- Debian 12
    +-- /workspace <-> ~/.openclaw/workspace (read/write)
    +-- /forge-share <-> /mnt/Dual_Boot_Share/Forge_Shared (read/write)
    +-- bridge networking for outbound DNS and HTTPS
    `-- Ubuntu host home and the rest of Dual_Boot_Share are not mounted

Forge browser automation
    |
    v
Docker browser sandbox
    +-- image: openclaw-sandbox-browser:bookworm-slim
    +-- dedicated network: openclaw-sandbox-browser
    +-- host-browser control: disabled
    +-- personal browser profiles: not mounted
    +-- /workspace mounted read/write
    +-- no Forge_Shared or Dual_Boot_Share mount
    `-- screenshots stored under ~/.openclaw/media on Ubuntu
```

The Gateway, Ollama, and SearXNG remain loopback-only. The Gateway has not been bound directly to the LAN and no reverse proxy or public port forwarding has been enabled. One trusted Linux client reaches the Gateway through an authenticated SSH local-forward tunnel. Forge can access only the dedicated `Forge_Shared` folder on `Dual_Boot_Share`; the rest of the partition remains unavailable to both sandboxes.

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
- [x] Updated durable memory after the managed-browser and controlled-share milestones

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

### Controlled shared-folder access

- [x] Created `/mnt/Dual_Boot_Share/Forge_Shared`
- [x] Mounted only that folder into the command sandbox as `/forge-share:rw`
- [x] Explicitly kept browser binds empty
- [x] Recreated the command and browser sandbox runtimes
- [x] Confirmed Forge can read a host-created file
- [x] Confirmed Forge can create a file that appears on the Ubuntu host
- [x] Confirmed the rest of `/mnt/Dual_Boot_Share` is hidden inside the command sandbox
- [x] Confirmed `/home/antonio` remains hidden inside the command sandbox
- [x] Inspected the actual Docker mounts for both containers
- [x] Confirmed the browser cannot see `/forge-share` or `/mnt/Dual_Boot_Share`
- [x] Updated durable memory and created a controlled-share evidence bundle

### First trusted Linux client

- [x] Inventoried the Forge host interfaces, routes, Gateway bind, listening sockets, and firewall implementation
- [x] Reserved the Forge host at `192.168.110.187`
- [x] Disabled unused Samba services and closed ports 139 and 445
- [x] Installed and validated OpenSSH Server
- [x] Created a dedicated Ed25519 client key
- [x] Confirmed key-only SSH login from the Alienware client
- [x] Kept the OpenClaw Gateway bound to loopback
- [x] Forwarded client `127.0.0.1:18789` to Forge-host `127.0.0.1:18789` through SSH
- [x] Disabled the Alienware's conflicting older local OpenClaw Gateway
- [x] Loaded the remote dashboard and authenticated with the Forge Gateway token
- [x] Created `forge-gateway-tunnel.service` as a persistent systemd user service
- [x] Enabled user lingering for pre-login operation
- [x] Rebooted the client and confirmed the tunnel automatically returned
- [x] Confirmed the dashboard, existing Forge chat, and durable memory remain accessible after reboot
- [x] Confirmed the tunnel automatically recovers after the Alienware disconnects and reconnects to Wi-Fi
- [x] Tuned SSH retry behavior with `ConnectTimeout 10` and `ConnectionAttempts 1`
- [x] Tuned systemd recovery behavior with `Restart=on-failure` and `RestartSec=30`
- [x] Preserved pre-tuning backups of the SSH profile and systemd user unit on the client

## Validated results

```text
Model:                     qwen3-coder:30b
Processor:                 100% GPU
Context:                   32768 tokens
GPU memory:                approximately 21.7 GiB / 24.6 GiB
Gateway bind:              127.0.0.1:18789
Gateway RPC probe:         ok
Gateway authentication:    token
Forge host LAN address:    192.168.110.187
LAN access method:         SSH local forwarding
Forge host SSH port:       22
Trusted client:            user-Alienware-15-R3
Client forwarded bind:     127.0.0.1:18789
Tunnel service:            forge-gateway-tunnel.service
Tunnel after reboot:       enabled and active
Tunnel after Wi-Fi loss:   recovered automatically
Tunnel restart policy:     on-failure, 30-second delay
SSH connection timeout:    10 seconds
SSH connection attempts:   1 per service start
Dashboard through tunnel:  HTTP/1.1 200 OK
Exec host:                 sandbox
Exec security:             allowlist
Exec approval:             ask-on-miss
Command sandbox image:     openclaw-sandbox:bookworm-slim
Command sandbox user:      sandbox, UID 1000
Command sandbox OS:        Debian GNU/Linux 12
Workspace mount:           /workspace, read/write
Forge shared mount:        /forge-share, read/write
Forge shared host source:  /mnt/Dual_Boot_Share/Forge_Shared
Whole share visible:       no
Host home visible:         no
DNS:                       working
Outbound HTTPS:            working
SearXNG bind:              127.0.0.1:8888
SearXNG JSON API:           working
SearXNG plugin pin:         @openclaw/searxng-plugin@2026.7.1
OpenClaw web_search:        working through SearXNG
Browser sandbox image:     openclaw-sandbox-browser:bookworm-slim
Browser network:           openclaw-sandbox-browser
Host-browser control:      disabled
Personal browser mounts:   none
Browser shared mount:      none
Browser navigation:        working
Browser snapshot:          working
Browser screenshot:        working
Compaction reserve:        8192 tokens
Recent-token keep:         6000 tokens
Durable memory:            verified and current
```

## Security-audit position

The most recent deep audit reports:

- **1 critical:** OpenClaw classifies `qwen3-coder:30b` as a small model for untrusted web inputs while `web_search` and `web_fetch` are enabled.
- **1 warning:** `trustedProxies` is empty while the Gateway is loopback-only.

The trusted-proxies warning requires no action until a reverse proxy is deliberately introduced. The small-model finding is accepted residual risk for the current single-user lab because command and browser activity are sandboxed, the Gateway is loopback-only, personal browser profiles are excluded, and external data access is limited to one deliberately selected folder.

The managed browser must not be used for banking, personal email, password managers, or sensitive administrative accounts.

The trusted-client tunnel adds SSH as a LAN-facing service. SSH password authentication is still enabled and must be hardened before Phase 7 is treated as complete.

## Planned inference-engine migration

The current deployment continues to use Ollama because its service management, model pulling, API, and OpenClaw integration keep the present build simple and reproducible.

A future milestone is to transition the inference backend to a standalone `llama.cpp` server after side-by-side validation. This is not based on a finding that Ollama is inherently untrustworthy. The goal is to reduce abstraction and gain:

- More direct visibility into the upstream inference runtime.
- Finer control over build flags, context and KV-cache settings, batching, GPU offload, and server options.
- Earlier access to upstream `llama.cpp` fixes and optimizations.
- Easier low-level debugging and performance comparison.
- A smaller and more directly auditable inference stack.

The migration must preserve loopback-only binding, OpenClaw compatibility, model quality, context length, GPU acceleration, automatic startup, recovery behavior, and a tested rollback path to Ollama. Ollama remains the active runtime until the standalone `llama.cpp` deployment passes those checks.

## Current checkpoint

The first trusted Linux client milestone now includes automatic recovery after client reboot and after a controlled Wi-Fi interruption. The Alienware reaches the loopback-only Forge Gateway through a dedicated-key SSH tunnel maintained by a lingering systemd user service. The final retry policy uses bounded SSH connection attempts and a 30-second systemd delay, preventing the rapid retry storm observed during an extended outage.

The tunnel is active, the client loopback listener is owned by SSH, and the remote dashboard returns HTTP 200. OpenClaw, Ollama, and SearXNG remain loopback-only, and no public port forwarding or direct Gateway LAN bind has been introduced.

## Next tasks

1. Test automatic tunnel recovery after a controlled Forge-host reboot or SSH-service restart.
2. Confirm emergency key access, then disable SSH password authentication.
3. Evaluate a dedicated restricted account for tunnel-only access.
4. Restrict SSH ingress with UFW and OPNsense.
5. Confirm Guest and IoT VLANs cannot reach TCP port 22 on the Forge host.
6. Review and deliberately select SearXNG upstream engines.
7. Audit NetBird for encrypted remote access without public port forwarding.
8. Begin controlled management of a lab computer.
9. Design a separate high-trust OpenClaw instance for `ollama/hf.co/mradermacher/Qwen3-30B-A3B-abliterated-erotic-i1-GGUF:Q4_K_M`, with explicit approval before high-impact actions and remote control limited to a deliberately selected lab computer.
10. Benchmark Ollama against a standalone `llama.cpp` server, then transition the inference backend after compatibility, performance, security, startup, recovery, and rollback validation succeeds.

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
│   ├── 15-managed-browser-and-security-audit.md
│   ├── 16-controlled-shared-folder-access.md
│   └── 17-trusted-linux-client-ssh-tunnel.md
├── docker/
│   └── openclaw-sandbox/
│       └── Dockerfile
├── scripts/
└── assets/screenshots/
```

## Safety rules

1. Keep Ollama, SearXNG, and the Gateway loopback-only while SSH forwarding meets the access requirement.
2. Require both SSH authentication and OpenClaw token authentication for trusted-client access.
3. Do not publish OpenClaw, Ollama, SearXNG, or SSH through a public router port-forward.
4. Keep command execution approval-controlled.
5. Run generated commands inside a sandbox whenever practical.
6. Mount only the smallest deliberately selected external folder; never mount an entire production or archive drive by default.
7. Keep secrets, tokens, private keys, and sensitive personal files out of `Forge_Shared`.
8. Keep the managed browser separate from personal browser profiles, credentials, and external data binds.
9. Do not use the managed browser for banking, personal email, password managers, or sensitive administration.
10. Treat webpage content and search results as untrusted input.
11. Keep SSH private keys off Git and revoke a trusted client by removing its exact authorized-key entry.
12. Test infrastructure changes against lab systems first.
13. Do not commit tokens, API keys, SearXNG secret keys, or `openclaw.json` secrets.
14. Keep documentation and change history in Git.
15. Keep any future unsandboxed or high-trust agent separate from Forge, scoped to a dedicated lab computer, and approval-gated for high-impact actions.