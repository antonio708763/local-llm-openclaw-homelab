# Changelog

## 2026-07-29

### Completed

- Repeated the Alienware Wi-Fi interruption test while both the client and Forge host were awake and healthy.
- Confirmed the persistent SSH tunnel automatically returned after Wi-Fi reconnected.
- Confirmed `forge-gateway-tunnel.service` returned to `active/running` with a new SSH process.
- Confirmed client loopback port `18789` was restored and owned by the SSH process.
- Confirmed the remote OpenClaw dashboard returned `HTTP/1.1 200 OK` after recovery.
- Added `ConnectTimeout 10` and `ConnectionAttempts 1` to the trusted-client SSH profile.
- Changed the tunnel service from `Restart=always` to `Restart=on-failure`.
- Increased the systemd restart delay from 10 seconds to 30 seconds.
- Verified the effective systemd policy reports `Restart=on-failure` and `RestartUSec=30s`.
- Preserved local pre-tuning backups of the SSH profile and systemd user unit.
- Updated `docs/17-trusted-linux-client-ssh-tunnel.md` with the validated recovery procedure and final retry policy.

### Pending

- Test automatic tunnel recovery after a controlled Forge-host reboot or SSH-service restart.
- Confirm emergency key access, then disable SSH password authentication.
- Evaluate a dedicated restricted tunnel account.
- Restrict SSH ingress with UFW and OPNsense.
- Confirm Guest and IoT VLANs cannot reach the Forge host SSH service.
- Review and deliberately select SearXNG upstream engines.
- Audit NetBird for encrypted remote access.
- Begin controlled management of a lab computer.
- Design a separate high-trust OpenClaw instance for `ollama/hf.co/mradermacher/Qwen3-30B-A3B-abliterated-erotic-i1-GGUF:Q4_K_M`, with explicit approval before high-impact actions and access limited to a deliberately selected lab computer.

### Current checkpoint

The trusted Alienware tunnel now survives both a client reboot and a controlled Wi-Fi interruption. Retry behavior is bounded by a 10-second SSH connection timeout, one connection attempt per systemd service start, and a 30-second `Restart=on-failure` delay. The Gateway, Ollama, and SearXNG remain loopback-only, and the remote dashboard continues to require both SSH key authentication and the OpenClaw Gateway token.

## 2026-07-28

### Added

- `docs/15-managed-browser-and-security-audit.md`.
- `docs/16-controlled-shared-folder-access.md`.
- `docs/17-trusted-linux-client-ssh-tunnel.md`.
- Isolated OpenClaw managed-browser image `openclaw-sandbox-browser:bookworm-slim`.
- Dedicated Docker network `openclaw-sandbox-browser` for browser automation.
- Browser snapshot and screenshot validation.
- Dedicated exchange folder `/mnt/Dual_Boot_Share/Forge_Shared`.
- Narrow command-sandbox bind from `Forge_Shared` to `/forge-share:rw`.
- Local managed-browser evidence bundle under `~/.openclaw/workspace/checkpoints/2026-07-28-managed-browser/`.
- Local controlled-share evidence bundle under `~/.openclaw/workspace/checkpoints/2026-07-28-controlled-share/`.
- Dedicated Ed25519 key for the first trusted Linux client.
- Persistent client-side `forge-gateway-tunnel.service` systemd user unit.

### Completed

#### Managed browser and security

- Identified that the OpenClaw npm package did not expose a usable `gitHead` value for browser-image source retrieval.
- Matched OpenClaw `2026.7.1-2` to the `v2026.7.1` Git tag.
- Cloned the matching OpenClaw source and built the official sandbox-browser image.
- Enabled the isolated browser sandbox and automatic startup.
- Configured the browser image and dedicated Docker network.
- Disabled host-browser control.
- Enabled noVNC support while keeping browser automation isolated.
- Added `browser` to the global and sandbox tool policy gates.
- Created the first browser container automatically through a Forge browser request.
- Opened `https://example.com` and validated the final URL, title, and main heading.
- Generated a browser snapshot and screenshot.
- Verified screenshot files under `~/.openclaw/media/browser` and `~/.openclaw/media/outbound`.
- Inspected browser mounts and confirmed that no personal Chrome, Chromium, Firefox, or credential directories were exposed.
- Confirmed the browser container uses `openclaw-sandbox-browser:bookworm-slim` and the `openclaw-sandbox-browser` network.
- Pinned SearXNG to `@openclaw/searxng-plugin@2026.7.1`.
- Reran `openclaw security audit --deep`.
- Reduced the audit from one critical and two warnings to one critical and one warning.
- Accepted the small-model-with-web-tools finding as residual risk under the current single-user, sandboxed, loopback-only design.
- Determined that the trusted-proxies warning requires no change while the Gateway remains loopback-only and no reverse proxy is in use.
- Created browser configuration, image, runtime, policy, plugin, and audit evidence files locally.

#### Durable memory

- Repaired the managed-browser checkpoint in `MEMORY.md` after the first Forge write request did not complete.
- Created and verified `memory/2026-07-28.md`.
- Preserved the original file as `MEMORY.md.before-managed-browser-update.bak`.
- Updated durable memory again after controlled shared-folder validation.
- Recorded trusted-LAN access as the next phase.

#### Controlled shared-folder access

- Created `/mnt/Dual_Boot_Share/Forge_Shared` on the NTFS partition.
- Confirmed the parent partition is mounted read/write with the `ntfs3` driver.
- Enabled external Docker bind sources deliberately.
- Mounted only `Forge_Shared` into the command sandbox as `/forge-share:rw`.
- Explicitly configured browser binds as an empty array.
- Recreated the command and browser sandbox runtimes.
- Confirmed Forge runs as the unprivileged `sandbox` user while accessing the folder.
- Confirmed Forge can read `host-created.txt`.
- Confirmed Forge can create `forge-created.txt` and that the file appears on the Ubuntu host.
- Confirmed the command sandbox cannot see the rest of `/mnt/Dual_Boot_Share`.
- Confirmed the command sandbox cannot see `/home/antonio`.
- Inspected the actual Docker mounts for the command and browser containers.
- Confirmed the browser does not inherit `/forge-share` or any `Dual_Boot_Share` mount.
- Ran direct browser-container tests that passed for both hidden paths.
- Confirmed the managed browser still works after the bind changes.
- Created command-bind, browser-bind, mount, partition, and host-verification evidence files locally.
- Documented rollback commands.

#### Trusted Linux client access

- Inventoried the Forge host network interfaces, routes, Gateway configuration, listening sockets, NetworkManager state, and firewall implementation.
- Confirmed the Forge host uses reserved address `192.168.110.187` on the trusted LAN.
- Disabled unused `smbd` and `nmbd` services.
- Confirmed Samba ports 139 and 445 are no longer listening.
- Installed and enabled OpenSSH Server on the Forge host.
- Confirmed `sshd -t` reports a valid configuration.
- Created a dedicated Ed25519 key on the Ubuntu Alienware client.
- Installed the public key for the Forge-host `antonio` account.
- Validated key-only SSH login.
- Created the `forge-gateway` SSH profile with a loopback-only local forward from client port `18789` to the Forge Gateway.
- Kept the OpenClaw Gateway bound to `127.0.0.1:18789`.
- Kept Ollama and SearXNG bound to loopback.
- Identified the client's older local OpenClaw Gateway as the cause of the initial `Address already in use` error.
- Stopped and disabled the client's older OpenClaw Gateway service.
- Confirmed the SSH process owns client-side loopback port `18789`.
- Confirmed the remote dashboard returns `HTTP/1.1 200 OK` through the tunnel.
- Logged in using the Forge Gateway token.
- Opened the existing Forge chat and durable memory from the trusted client.
- Created and enabled `forge-gateway-tunnel.service`.
- Enabled systemd user lingering and confirmed `Linger=yes`.
- Rebooted the trusted client.
- Confirmed the tunnel service returned as enabled and active after reboot.
- Confirmed the client loopback listener and HTTP 200 response returned automatically after reboot.

### Pending

- Review both local evidence bundles before selected artifacts are committed publicly.
- Review and deliberately select SearXNG upstream engines.
- Test tunnel recovery after Wi-Fi interruption.
- Test tunnel recovery after a Forge-host or SSH-service restart.
- Disable SSH password authentication after recovery access is confirmed.
- Evaluate a dedicated restricted tunnel account.
- Restrict SSH ingress with UFW and OPNsense.
- Confirm Guest and IoT VLANs cannot reach the Forge host SSH service.
- Audit NetBird for encrypted remote access.

### Current checkpoint

The first trusted Linux client milestone is complete. The Ubuntu Alienware client reaches the loopback-only Forge Gateway through a dedicated-key SSH local-forward tunnel maintained by a systemd user service. The tunnel survived a client reboot, returned HTTP 200, and allowed token-authenticated access to the existing Forge chat and durable memory. OpenClaw, Ollama, and SearXNG remain loopback-only, and no public port forwarding or direct Gateway LAN bind has been introduced.

## 2026-07-26

### Added

- `docs/13-sandbox-runtime-validation.md`.
- `docs/14-searxng-compaction-and-memory.md`.
- Self-hosted SearXNG container bound to `127.0.0.1:8888`.
- Persistent SearXNG configuration at `~/searxng/settings.yml` with HTML and JSON output enabled.
- OpenClaw SearXNG plugin and local `web_search` integration.
- Durable `MEMORY.md` and dated memory-note workflow.
- Current project checkpoint in `MEMORY.md`.

### Completed

- Changed normal OpenClaw command execution from `host=gateway` to `host=sandbox`.
- Preserved the cautious policy with `security=allowlist`, `ask=on-miss`, and deny fallback.
- Ran Forge's first harmless command set inside the Docker sandbox.
- Confirmed OpenClaw automatically created and started an `openclaw-sbx-agent-main-...` runtime.
- Confirmed the runtime uses `openclaw-sandbox:bookworm-slim`.
- Confirmed commands run as the unprivileged `sandbox` user with UID and GID `1000`.
- Confirmed the working directory is `/workspace` and the container OS is Debian GNU/Linux 12.
- Confirmed `/home/antonio` is not visible from inside the sandbox.
- Created `/workspace/sandbox-test.txt` from Forge.
- Confirmed the file appeared on Ubuntu at `~/.openclaw/workspace/sandbox-test.txt`.
- Confirmed outbound DNS resolution and HTTPS access from the sandbox.
- Installed the OpenClaw SearXNG plugin.
- Deployed SearXNG in Docker with loopback-only port publishing.
- Resolved the initial JSON search `403` by enabling `search.formats: [html, json]`.
- Added `web_search` and `web_fetch` to the sandbox tool allowlist.
- Confirmed OpenClaw can search through the self-hosted SearXNG provider in a fresh session.
- Tuned compaction for the 32,768-token context using an 8,192-token reserve and 6,000 recent tokens.
- Inspected the detailed context breakdown and recorded approximately 8,929 tokens of startup context.
- Created and verified `MEMORY.md` and `memory/2026-07-26.md` from Ubuntu.
- Confirmed a new session recalled the durable homelab goals, hardware, model, and safety rules.
- Added the managed-browser task to the durable current-project checkpoint.
- Confirmed Docker, Ollama, the OpenClaw Gateway, and SearXNG were healthy at the stopping point.

### Current checkpoint

The self-hosted search, compaction, and durable-memory milestone is complete. The next task is to configure and test an isolated OpenClaw managed browser that remains separate from the personal browser profile.

## 2026-07-25

### Added

- Docker Engine installation from Docker's official Ubuntu repository.
- Docker Compose plugin.
- Reusable `docker/openclaw-sandbox/Dockerfile`.
- `docs/12-docker-and-sandbox.md`.
- Screenshot evidence for Docker installation, reboot validation, sandbox image creation, sandbox configuration, policy inspection, and the pre-runtime checkpoint.

### Completed

- Confirmed `Dual_Boot_Share` mounts automatically after reboot.
- Confirmed Docker, Ollama, and the OpenClaw Gateway start correctly after reboot.
- Created the Forge identity and operating characteristics.
- Applied OpenClaw's cautious execution policy: `security=allowlist`, `ask=on-miss`.
- Disabled unavailable OpenAI-backed memory search.
- Disabled insecure Control UI authentication.
- Removed the temporary provider-specific web/browser deny rule.
- Corrected OpenClaw's Qwen context advertisement and Ollama `num_ctx` to `32768`.
- Installed Docker Engine `29.6.2` and Docker Compose `v5.3.1`.
- Successfully ran Docker's `hello-world` test.
- Added the Ubuntu administrator account to the Docker group and verified non-root Docker access after reboot.
- Built `openclaw-sandbox:bookworm-slim`.
- Configured OpenClaw sandbox mode `all`, Docker backend, agent scope, read/write workspace access, and bridge networking.
- Confirmed `openclaw sandbox explain` reports a sandboxed runtime with `/workspace` mapped to `~/.openclaw/workspace`.

## 2026-07-24

### Added

- Initial repository structure.
- Hardware and dual-boot architecture documentation.
- Windows-to-Ubuntu shared-partition build log.
- Backup and recovery notes.
- Network and security plans for OpenClaw.
- Read-only Windows and Ubuntu validation scripts.
- Screenshot evidence for storage, Ollama installation, model download, model response, and GPU validation.
- Detailed Ollama and `qwen3-coder:30b` validation record.
- OpenClaw local installation and onboarding documentation.
- Shutdown and restart commands for safely resuming the project.

### Completed

- Verified Windows data integrity after the partition resize.
- Configured `Dual_Boot_Share` at `/mnt/Dual_Boot_Share` using UUID `48003BD2003BC62A`.
- Confirmed NTFS read/write access from Ubuntu using the `ntfs3` driver.
- Verified NVIDIA driver and CUDA access.
- Installed Ollama `0.32.3` as an enabled systemd service.
- Downloaded `qwen3-coder:30b`.
- Confirmed `100% GPU` model residency on the RTX 4090.
- Validated a 32,768-token Ollama context allocation with approximately 21.7 GiB of VRAM in use.
- Installed OpenClaw `2026.7.1-2` and Node.js `24.18.0`.
- Connected OpenClaw to local Ollama.
- Installed and validated the local Gateway and TUI.
